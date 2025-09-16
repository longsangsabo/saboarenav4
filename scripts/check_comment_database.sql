-- Check if comment system database is set up properly
-- Run this in Supabase Dashboard SQL Editor

-- Test 1: Check if post_comments table exists
SELECT table_name, column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'post_comments'
ORDER BY ordinal_position;

-- Test 2: Check if RPC functions exist
SELECT routine_name, routine_type
FROM information_schema.routines 
WHERE routine_name IN ('create_comment', 'get_post_comments', 'delete_comment');

-- Test 3: Check existing comments
SELECT COUNT(*) as comment_count FROM post_comments;

-- Test 4: Check RLS policies
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
FROM pg_policies 
WHERE tablename = 'post_comments';