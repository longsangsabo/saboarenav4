-- Quick validation script - run this AFTER executing create_comments_table.sql
-- This will verify that everything is set up correctly

SELECT 'Checking post_comments table...' as status;
SELECT table_name, column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_name = 'post_comments'
ORDER BY ordinal_position;

SELECT 'Checking RLS policies...' as status;
SELECT policyname, cmd, permissive
FROM pg_policies 
WHERE tablename = 'post_comments';

SELECT 'Checking RPC functions...' as status;
SELECT routine_name, routine_type
FROM information_schema.routines 
WHERE routine_name IN ('create_comment', 'get_post_comments', 'delete_comment', 'update_comment', 'get_post_comment_count')
AND routine_schema = 'public';

SELECT 'Checking triggers...' as status;
SELECT trigger_name, event_manipulation, action_timing
FROM information_schema.triggers 
WHERE trigger_name = 'trigger_update_comment_count';

SELECT 'Database setup complete!' as result;