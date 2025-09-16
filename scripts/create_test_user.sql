-- Giải pháp tạm thời: Tạo anonymous test user cho testing
-- Script này sẽ tạo một test user với ID cố định để test upload

-- 1. Tạo test user với UUID cố định
INSERT INTO users (
  id,
  email,
  username,
  display_name,
  bio,
  created_at,
  updated_at
) VALUES (
  '00000000-0000-0000-0000-000000000001',
  'test@sabo.app',
  'testuser',
  'Test User',
  'Test user for development',
  NOW(),
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  updated_at = NOW();

-- 2. Tạm thời tạo policy cho phép anonymous user update (CHỈ cho testing!)
DROP POLICY IF EXISTS "Allow anonymous test updates" ON users;
CREATE POLICY "Allow anonymous test updates" ON users 
  FOR UPDATE 
  USING (id = '00000000-0000-0000-0000-000000000001');

-- Hiển thị thông tin
SELECT 
  'Test user created with ID: 00000000-0000-0000-0000-000000000001' as info,
  'Email: test@sabo.app' as credentials,
  'Username: testuser' as username_info,
  '⚠️  CHỈ dùng cho testing - xóa policy này trong production!' as warning;