-- Check if comments exist in database
SELECT 'Comments in post_comments table:' as info;
SELECT 
    id, 
    user_id, 
    post_id, 
    content, 
    created_at 
FROM post_comments 
ORDER BY created_at DESC 
LIMIT 10;

-- Check specific post
SELECT 'Comments for specific post:' as info;
SELECT 
    pc.id, 
    pc.content, 
    pc.created_at,
    u.full_name as author_name
FROM post_comments pc
LEFT JOIN users u ON pc.user_id = u.id
WHERE pc.post_id = '1526eb1e-07bd-4c80-bcf3-b104fc5879f8'
ORDER BY pc.created_at DESC;

-- Test the RPC function
SELECT 'Testing get_post_comments RPC:' as info;
SELECT get_post_comments('1526eb1e-07bd-4c80-bcf3-b104fc5879f8', 10, 0) as rpc_result;