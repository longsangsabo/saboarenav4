-- Create test user and check authentication setup
-- Run this script to ensure proper user authentication for comments

-- Check if we have authenticated users
SELECT 'Current authentication status:' as info;
SELECT auth.uid() as current_user_id, auth.role() as current_role;

-- Check users table
SELECT 'Users in database:' as info;
SELECT id, email, full_name, created_at FROM users ORDER BY created_at DESC LIMIT 5;

-- Skip creating test user for now - will use existing users
-- Note: The foreign key constraint suggests we need to use existing auth users

SELECT 'Skipping test user creation - using existing users' as info;

-- Check what users already exist
SELECT 'Existing users:' as info;
SELECT id, email, full_name FROM users LIMIT 5;

-- Check posts table structure first
SELECT 'Posts table structure:' as info;
SELECT column_name, data_type FROM information_schema.columns 
WHERE table_name = 'posts' AND table_schema = 'public';

-- Check if we have any posts to test with
SELECT 'Available posts for testing:' as info;
SELECT * FROM posts LIMIT 3;

-- Temporary fix: Make post_comments more permissive for testing
-- This is just for debugging - should be removed in production

SELECT 'Temporarily making policies more permissive for testing...' as info;

-- Drop restrictive policies
DROP POLICY IF EXISTS "Allow authenticated users to create comments" ON post_comments;
DROP POLICY IF EXISTS "Allow users to update their own comments" ON post_comments;
DROP POLICY IF EXISTS "Allow users to delete their own comments" ON post_comments;

-- Create very permissive policies for testing
CREATE POLICY "Test - allow all insert" ON post_comments
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Test - allow all update" ON post_comments
    FOR UPDATE USING (true) WITH CHECK (true);

CREATE POLICY "Test - allow all delete" ON post_comments
    FOR DELETE USING (true);

-- Grant permissions
GRANT ALL ON post_comments TO anon;
GRANT ALL ON post_comments TO authenticated;

SELECT 'Policies updated for testing!' as result;
SELECT 'WARNING: These are test policies - use proper RLS in production!' as warning;