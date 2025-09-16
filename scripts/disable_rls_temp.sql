-- Script để tạm thời disable RLS trên users table
-- CHỈ sử dụng cho testing - KHÔNG dùng trong production!

-- Disable RLS trên users table
ALTER TABLE users DISABLE ROW LEVEL SECURITY;

-- Hoặc tạo policy cho phép anonymous users update (không an toàn!)
-- DROP POLICY IF EXISTS "Users can update own profile" ON users;
-- CREATE POLICY "Allow anonymous updates" ON users FOR UPDATE USING (true);

print('⚠️  RLS đã được DISABLE trên users table');
print('🔴 CHỈ dùng cho testing - nhớ enable lại sau!');