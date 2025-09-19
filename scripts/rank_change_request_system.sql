-- =============================================
-- RANK CHANGE REQUEST SYSTEM INTEGRATION
-- Tích hợp vào bảng notifications hiện có
-- =============================================

-- 1. Tận dụng bảng notifications với type mới
-- Không cần tạo bảng mới, chỉ cần extend notification types

-- 2. RPC Function: Submit rank change request
CREATE OR REPLACE FUNCTION submit_rank_change_request(
    p_requested_rank TEXT,
    p_reason TEXT,
    p_evidence_urls TEXT[] DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_user_id UUID;
    v_current_user RECORD;
    v_user_club_id UUID;
    v_notification_id UUID;
    v_request_data JSONB;
    v_result JSON;
BEGIN
    -- Get current user
    v_user_id := auth.uid();
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'User not authenticated';
    END IF;

    -- Get user info and current rank
    SELECT * INTO v_current_user 
    FROM users 
    WHERE id = v_user_id;
    
    IF v_current_user IS NULL THEN
        RAISE EXCEPTION 'User not found';
    END IF;

    -- Check if user has a rank
    IF v_current_user.rank IS NULL OR v_current_user.rank = '' OR v_current_user.rank = 'unranked' THEN
        RAISE EXCEPTION 'User must have a current rank to request change';
    END IF;

    -- Get user's club (for club admin approval)
    -- Assuming we can get club from club_memberships or similar table
    SELECT club_id INTO v_user_club_id 
    FROM club_memberships 
    WHERE user_id = v_user_id 
    AND status = 'active' 
    LIMIT 1;

    -- Build request data
    v_request_data := jsonb_build_object(
        'request_type', 'rank_change',
        'current_rank', v_current_user.rank,
        'requested_rank', p_requested_rank,
        'reason', p_reason,
        'evidence_urls', COALESCE(p_evidence_urls, ARRAY[]::TEXT[]),
        'user_club_id', v_user_club_id,
        'workflow_status', 'pending_club_review',
        'submitted_at', NOW(),
        'club_approved', false,
        'admin_approved', false,
        'club_reviewed_at', NULL,
        'admin_reviewed_at', NULL,
        'club_reviewer_id', NULL,
        'admin_reviewer_id', NULL,
        'club_comments', NULL,
        'admin_comments', NULL
    );

    -- Create notification for club admins
    INSERT INTO notifications (
        user_id, -- Will be updated to club admin later
        type,
        title,
        message,
        data,
        is_read
    ) VALUES (
        v_user_id, -- Temporary, will update to club admin
        'rank_change_request',
        'Yêu cầu thay đổi hạng mới',
        format('%s yêu cầu thay đổi hạng từ %s thành %s', 
               v_current_user.display_name, 
               v_current_user.rank, 
               p_requested_rank),
        v_request_data,
        false
    ) RETURNING id INTO v_notification_id;

    -- Also create a notification for the user (confirmation)
    INSERT INTO notifications (
        user_id,
        type,
        title,
        message,
        data,
        is_read
    ) VALUES (
        v_user_id,
        'rank_change_request_submitted',
        'Yêu cầu thay đổi hạng đã được gửi',
        format('Yêu cầu thay đổi hạng từ %s thành %s đã được gửi và đang chờ xét duyệt', 
               v_current_user.rank, 
               p_requested_rank),
        v_request_data,
        false
    );

    v_result := json_build_object(
        'success', true,
        'message', 'Rank change request submitted successfully',
        'request_id', v_notification_id,
        'status', 'pending_club_review'
    );

    RETURN v_result;
END;
$$;

-- 3. RPC Function: Get pending rank change requests (for club admin)
CREATE OR REPLACE FUNCTION get_pending_rank_change_requests(
    p_club_id UUID DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_user_id UUID;
    v_is_club_admin BOOLEAN := false;
    v_is_system_admin BOOLEAN := false;
    v_requests JSON;
BEGIN
    v_user_id := auth.uid();
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'User not authenticated';
    END IF;

    -- Check if user is club admin or system admin
    SELECT 
        (role = 'admin') as is_system_admin,
        EXISTS(
            SELECT 1 FROM club_memberships cm 
            WHERE cm.user_id = v_user_id 
            AND cm.club_id = COALESCE(p_club_id, cm.club_id)
            AND cm.role IN ('owner', 'admin')
        ) as is_club_admin
    INTO v_is_system_admin, v_is_club_admin
    FROM users WHERE id = v_user_id;

    IF NOT (v_is_club_admin OR v_is_system_admin) THEN
        RAISE EXCEPTION 'Access denied: User must be club admin or system admin';
    END IF;

    -- Get pending requests
    SELECT json_agg(
        json_build_object(
            'id', n.id,
            'user_id', n.user_id,
            'user_name', u.display_name,
            'user_avatar', u.avatar_url,
            'current_rank', (n.data->>'current_rank'),
            'requested_rank', (n.data->>'requested_rank'),
            'reason', (n.data->>'reason'),
            'evidence_urls', n.data->'evidence_urls',
            'submitted_at', (n.data->>'submitted_at'),
            'workflow_status', (n.data->>'workflow_status'),
            'created_at', n.created_at
        )
    ) INTO v_requests
    FROM notifications n
    JOIN users u ON n.user_id = u.id
    WHERE n.type = 'rank_change_request'
    AND (n.data->>'workflow_status') IN ('pending_club_review', 'pending_admin_review')
    AND (
        v_is_system_admin OR 
        (p_club_id IS NOT NULL AND (n.data->>'user_club_id')::UUID = p_club_id)
    )
    ORDER BY n.created_at DESC;

    RETURN COALESCE(v_requests, '[]'::JSON);
END;
$$;

-- 4. RPC Function: Club review rank change request
CREATE OR REPLACE FUNCTION club_review_rank_change_request(
    p_request_id UUID,
    p_approved BOOLEAN,
    p_comments TEXT DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_user_id UUID;
    v_request_record RECORD;
    v_updated_data JSONB;
    v_result JSON;
BEGIN
    v_user_id := auth.uid();
    
    -- Get request record
    SELECT * INTO v_request_record
    FROM notifications 
    WHERE id = p_request_id AND type = 'rank_change_request';

    IF v_request_record IS NULL THEN
        RAISE EXCEPTION 'Request not found';
    END IF;

    -- Check if user is club admin for this request
    IF NOT EXISTS(
        SELECT 1 FROM club_memberships 
        WHERE user_id = v_user_id 
        AND club_id = (v_request_record.data->>'user_club_id')::UUID
        AND role IN ('owner', 'admin')
    ) THEN
        RAISE EXCEPTION 'Access denied: User must be club admin';
    END IF;

    -- Update request data
    v_updated_data := v_request_record.data || jsonb_build_object(
        'club_approved', p_approved,
        'club_reviewed_at', NOW(),
        'club_reviewer_id', v_user_id,
        'club_comments', p_comments,
        'workflow_status', 
        CASE 
            WHEN p_approved THEN 'pending_admin_review'
            ELSE 'rejected_by_club'
        END
    );

    -- Update notification
    UPDATE notifications 
    SET data = v_updated_data,
        updated_at = NOW()
    WHERE id = p_request_id;

    -- Create notification for user about club decision
    INSERT INTO notifications (
        user_id,
        type,
        title,
        message,
        data
    ) VALUES (
        v_request_record.user_id,
        CASE 
            WHEN p_approved THEN 'rank_change_club_approved'
            ELSE 'rank_change_club_rejected'
        END,
        CASE 
            WHEN p_approved THEN 'Câu lạc bộ đã duyệt yêu cầu thay đổi hạng'
            ELSE 'Câu lạc bộ đã từ chối yêu cầu thay đổi hạng'
        END,
        CASE 
            WHEN p_approved THEN 'Yêu cầu thay đổi hạng của bạn đã được câu lạc bộ duyệt và chuyển lên admin hệ thống để phê duyệt cuối cùng.'
            ELSE format('Yêu cầu thay đổi hạng của bạn đã bị từ chối. Lý do: %s', COALESCE(p_comments, 'Không có lý do cụ thể'))
        END,
        v_updated_data
    );

    v_result := json_build_object(
        'success', true,
        'message', 
        CASE 
            WHEN p_approved THEN 'Request approved and forwarded to system admin'
            ELSE 'Request rejected'
        END,
        'status', v_updated_data->>'workflow_status'
    );

    RETURN v_result;
END;
$$;

-- 5. RPC Function: Admin approve rank change request
CREATE OR REPLACE FUNCTION admin_approve_rank_change_request(
    p_request_id UUID,
    p_approved BOOLEAN,
    p_comments TEXT DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_user_id UUID;
    v_request_record RECORD;
    v_updated_data JSONB;
    v_target_user_id UUID;
    v_new_rank TEXT;
    v_result JSON;
BEGIN
    v_user_id := auth.uid();
    
    -- Check if user is system admin
    IF NOT EXISTS(SELECT 1 FROM users WHERE id = v_user_id AND role = 'admin') THEN
        RAISE EXCEPTION 'Access denied: User must be system admin';
    END IF;

    -- Get request record
    SELECT * INTO v_request_record
    FROM notifications 
    WHERE id = p_request_id AND type = 'rank_change_request';

    IF v_request_record IS NULL THEN
        RAISE EXCEPTION 'Request not found';
    END IF;

    v_target_user_id := v_request_record.user_id;
    v_new_rank := v_request_record.data->>'requested_rank';

    -- Update request data
    v_updated_data := v_request_record.data || jsonb_build_object(
        'admin_approved', p_approved,
        'admin_reviewed_at', NOW(),
        'admin_reviewer_id', v_user_id,
        'admin_comments', p_comments,
        'workflow_status', 
        CASE 
            WHEN p_approved THEN 'approved'
            ELSE 'rejected_by_admin'
        END
    );

    -- Update notification
    UPDATE notifications 
    SET data = v_updated_data,
        updated_at = NOW()
    WHERE id = p_request_id;

    -- If approved, update user's rank
    IF p_approved THEN
        UPDATE users 
        SET rank = v_new_rank,
            updated_at = NOW()
        WHERE id = v_target_user_id;
    END IF;

    -- Create notification for user about final decision
    INSERT INTO notifications (
        user_id,
        type,
        title,
        message,
        data
    ) VALUES (
        v_target_user_id,
        CASE 
            WHEN p_approved THEN 'rank_change_approved'
            ELSE 'rank_change_rejected'
        END,
        CASE 
            WHEN p_approved THEN 'Yêu cầu thay đổi hạng đã được duyệt!'
            ELSE 'Yêu cầu thay đổi hạng đã bị từ chối'
        END,
        CASE 
            WHEN p_approved THEN format('Chúc mừng! Hạng của bạn đã được thay đổi thành %s', v_new_rank)
            ELSE format('Yêu cầu thay đổi hạng đã bị từ chối. Lý do: %s', COALESCE(p_comments, 'Không có lý do cụ thể'))
        END,
        v_updated_data
    );

    v_result := json_build_object(
        'success', true,
        'message', 
        CASE 
            WHEN p_approved THEN 'Rank change request approved and user rank updated'
            ELSE 'Rank change request rejected'
        END,
        'status', v_updated_data->>'workflow_status',
        'new_rank', CASE WHEN p_approved THEN v_new_rank ELSE NULL END
    );

    RETURN v_result;
END;
$$;

-- 6. Grant permissions
GRANT EXECUTE ON FUNCTION submit_rank_change_request TO authenticated;
GRANT EXECUTE ON FUNCTION get_pending_rank_change_requests TO authenticated;
GRANT EXECUTE ON FUNCTION club_review_rank_change_request TO authenticated;
GRANT EXECUTE ON FUNCTION admin_approve_rank_change_request TO authenticated;

-- 7. Add indexes for better performance
CREATE INDEX IF NOT EXISTS idx_notifications_type_data ON notifications(type) 
WHERE type IN ('rank_change_request', 'rank_change_request_submitted', 'rank_change_club_approved', 'rank_change_club_rejected', 'rank_change_approved', 'rank_change_rejected');

CREATE INDEX IF NOT EXISTS idx_notifications_workflow_status ON notifications 
USING GIN ((data->>'workflow_status'))
WHERE type = 'rank_change_request';