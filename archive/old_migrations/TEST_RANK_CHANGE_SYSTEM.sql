-- Test RPC functions để đảm bảo system hoạt động
-- Run từng query này trong Supabase SQL Editor để test

-- 1. Test submit_rank_change_request function
-- (Chạy với user đã đăng nhập và có rank)
SELECT submit_rank_change_request(
  'A', 
  'Đã cải thiện kỹ thuật đáng kể qua các trận đấu gần đây',
  ARRAY['https://example.com/evidence1.jpg', 'https://example.com/evidence2.jpg']
);

-- 2. Test get_pending_rank_change_requests function
-- (Chạy với user là club admin)
SELECT get_pending_rank_change_requests();

-- 3. Test club_review_rank_change_request function
-- (Thay 'request-uuid-here' bằng ID thật từ query trên)
SELECT club_review_rank_change_request(
  'request-uuid-here'::uuid,
  true,
  'Club admin chấp thuận yêu cầu này'
);

-- 4. Test admin_approve_rank_change_request function
-- (Thay 'request-uuid-here' bằng ID thật)
SELECT admin_approve_rank_change_request(
  'request-uuid-here'::uuid,
  true,
  'Admin phê duyệt cuối cùng'
);

-- 5. Kiểm tra notifications table để xem workflow
SELECT 
  id,
  user_id,
  type,
  title,
  message,
  data->>'workflow_status' as status,
  data->>'current_rank' as current_rank,
  data->>'requested_rank' as requested_rank,
  created_at
FROM notifications 
WHERE type LIKE '%rank_change%'
ORDER BY created_at DESC;

-- 6. Kiểm tra user rank đã được update chưa
-- (Sau khi admin approve)
SELECT id, display_name, rank, updated_at 
FROM users 
WHERE rank IS NOT NULL 
ORDER BY updated_at DESC 
LIMIT 10;