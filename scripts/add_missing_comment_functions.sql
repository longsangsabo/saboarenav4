-- RPC function to get comment count for a specific post
CREATE OR REPLACE FUNCTION get_post_comment_count(post_id UUID)
RETURNS INTEGER AS $$
DECLARE
    comment_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO comment_count
    FROM post_comments
    WHERE post_comments.post_id = get_post_comment_count.post_id;
    
    RETURN COALESCE(comment_count, 0);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- RPC function to update/edit a comment
CREATE OR REPLACE FUNCTION update_comment(comment_id UUID, new_content TEXT)
RETURNS json AS $$
DECLARE
    user_id UUID := auth.uid();
    updated_comment post_comments;
    user_info json;
    result json;
BEGIN
    -- Check if user is authenticated
    IF user_id IS NULL THEN
        RETURN json_build_object('success', false, 'error', 'User not authenticated');
    END IF;

    -- Validate content
    IF new_content IS NULL OR trim(new_content) = '' THEN
        RETURN json_build_object('success', false, 'error', 'Comment content cannot be empty');
    END IF;

    IF length(trim(new_content)) > 1000 THEN
        RETURN json_build_object('success', false, 'error', 'Comment too long (max 1000 characters)');
    END IF;

    -- Update comment (RLS will ensure user can only update their own comments)
    UPDATE post_comments 
    SET content = trim(new_content), updated_at = timezone('utc'::text, now())
    WHERE id = comment_id AND user_id = update_comment.user_id
    RETURNING * INTO updated_comment;

    -- Check if comment was found and updated
    IF updated_comment.id IS NULL THEN
        RETURN json_build_object('success', false, 'error', 'Comment not found or access denied');
    END IF;

    -- Get user info
    SELECT json_build_object(
        'id', u.id,
        'email', u.email,
        'full_name', u.full_name,
        'avatar_url', u.avatar_url
    ) INTO user_info
    FROM users u WHERE u.id = user_id;

    -- Build result with updated comment and user info
    result := json_build_object(
        'success', true,
        'comment', json_build_object(
            'id', updated_comment.id,
            'user_id', updated_comment.user_id,
            'post_id', updated_comment.post_id,
            'content', updated_comment.content,
            'created_at', updated_comment.created_at,
            'updated_at', updated_comment.updated_at,
            'user', user_info
        )
    );

    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;