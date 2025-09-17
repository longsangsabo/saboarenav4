-- Fix null roles in club_members table
-- Run this in Supabase SQL Editor

-- 1. Check current role values
SELECT id, club_id, user_id, role, status, created_at 
FROM club_members 
ORDER BY created_at DESC;

-- 2. Update null roles to default 'member'
UPDATE club_members 
SET role = 'member' 
WHERE role IS NULL;

-- 3. Verify the update
SELECT id, club_id, user_id, role, status, created_at 
FROM club_members 
ORDER BY created_at DESC;

-- 4. Add NOT NULL constraint to prevent future nulls
ALTER TABLE club_members 
ALTER COLUMN role SET NOT NULL;

-- 5. Add default value for role
ALTER TABLE club_members 
ALTER COLUMN role SET DEFAULT 'member';

-- Success message
SELECT '✅ Fixed null roles and added constraints!' as result;