-- Database Relationship Analysis Script
-- Execute this directly in Supabase SQL Editor with service role

-- 1. Check all club-related tables
SELECT '=== STEP 1: All club-related tables ===' as info;
SELECT table_name, table_schema
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND (table_name LIKE '%club%' OR table_name LIKE '%member%')
ORDER BY table_name;

-- 2. Check club_members table structure
SELECT '=== STEP 2: club_members table structure ===' as info;
SELECT 
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns 
WHERE table_schema = 'public' 
AND table_name = 'club_members'
ORDER BY ordinal_position;

-- 3. Check foreign key relationships
SELECT '=== STEP 3: Foreign key constraints ===' as info;
SELECT 
  tc.table_name, 
  kcu.column_name, 
  ccu.table_name AS foreign_table_name,
  ccu.column_name AS foreign_column_name,
  tc.constraint_name
FROM 
  information_schema.table_constraints AS tc 
  JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
  JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
    AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY' 
AND tc.table_schema = 'public'
AND (tc.table_name LIKE '%club%' OR tc.table_name LIKE '%member%')
ORDER BY tc.table_name;

-- 4. Check data in club_members
SELECT '=== STEP 4: club_members data sample ===' as info;
SELECT 
  id,
  club_id,
  user_id,
  role,
  status,
  created_at
FROM club_members 
LIMIT 5;

-- 5. Test join between club_members and auth.users
SELECT '=== STEP 5: Join test with auth.users ===' as info;
SELECT 
  cm.id,
  cm.club_id,
  cm.user_id,
  cm.role,
  cm.status,
  au.email,
  au.created_at as user_created_at
FROM club_members cm
LEFT JOIN auth.users au ON cm.user_id = au.id
LIMIT 3;

-- 6. Check if profiles table exists and test join
SELECT '=== STEP 6: Test join with profiles (if exists) ===' as info;
SELECT 
  cm.id,
  cm.club_id,
  cm.user_id,
  cm.role,
  cm.status,
  p.username,
  p.full_name,
  p.avatar_url
FROM club_members cm
LEFT JOIN profiles p ON cm.user_id = p.id
LIMIT 3;

-- 7. Check clubs table and relationship
SELECT '=== STEP 7: clubs table data ===' as info;
SELECT 
  c.id,
  c.name,
  c.status,
  c.created_at,
  COUNT(cm.id) as member_count
FROM clubs c
LEFT JOIN club_members cm ON c.id = cm.club_id
GROUP BY c.id, c.name, c.status, c.created_at
LIMIT 5;

-- 8. Check RLS policies on club_members
SELECT '=== STEP 8: RLS policies on club_members ===' as info;
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies 
WHERE tablename = 'club_members';

-- 9. Check if club_memberships table still exists
SELECT '=== STEP 9: Check if club_memberships still exists ===' as info;
SELECT EXISTS (
  SELECT 1 
  FROM information_schema.tables 
  WHERE table_schema = 'public' 
  AND table_name = 'club_memberships'
) as club_memberships_exists;

-- 10. Summary of potential issues
SELECT '=== STEP 10: Analysis Summary ===' as info;
SELECT 
  'Check results above for:' as analysis,
  '1. Missing foreign key constraints' as issue1,
  '2. RLS policies blocking access' as issue2,
  '3. Missing profiles table relationship' as issue3,
  '4. Incorrect user_id references' as issue4;