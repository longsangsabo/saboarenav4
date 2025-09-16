-- Fix RLS policies for post_comments table
-- Run this script to fix the RLS permission issues

-- First, let's check current user and auth status
SELECT 'Current user info:' as info;
SELECT auth.uid() as current_user_id, auth.role() as current_role;

-- Check if we have proper user authentication setup
SELECT 'Checking users table...' as info;
SELECT id, email, full_name FROM users LIMIT 3;

-- Temporary disable RLS to test basic functionality
SELECT 'Temporarily disabling RLS for testing...' as info;
ALTER TABLE post_comments DISABLE ROW LEVEL SECURITY;

-- Drop existing policies
DROP POLICY IF EXISTS "Users can view all comments" ON post_comments;
DROP POLICY IF EXISTS "Users can create comments" ON post_comments;
DROP POLICY IF EXISTS "Users can update their own comments" ON post_comments;
DROP POLICY IF EXISTS "Users can delete their own comments" ON post_comments;

-- Re-enable RLS
ALTER TABLE post_comments ENABLE ROW LEVEL SECURITY;

-- Create more permissive policies for testing
CREATE POLICY "Allow all users to view comments" ON post_comments
    FOR SELECT USING (true);

CREATE POLICY "Allow authenticated users to create comments" ON post_comments
    FOR INSERT WITH CHECK (
        auth.uid() IS NOT NULL AND 
        auth.uid() = user_id
    );

CREATE POLICY "Allow users to update their own comments" ON post_comments
    FOR UPDATE USING (
        auth.uid() IS NOT NULL AND 
        auth.uid() = user_id
    ) WITH CHECK (
        auth.uid() IS NOT NULL AND 
        auth.uid() = user_id
    );

CREATE POLICY "Allow users to delete their own comments" ON post_comments
    FOR DELETE USING (
        auth.uid() IS NOT NULL AND 
        auth.uid() = user_id
    );

-- Grant necessary permissions to authenticated users
GRANT ALL ON post_comments TO authenticated;
GRANT ALL ON post_comments TO anon;

SELECT 'RLS policies updated successfully!' as result;