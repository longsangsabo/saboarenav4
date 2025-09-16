-- Thêm column cover_photo_url vào bảng users
-- Chạy trong Supabase Dashboard > SQL Editor

ALTER TABLE users 
ADD COLUMN cover_photo_url TEXT;

-- Thêm comment cho column mới
COMMENT ON COLUMN users.cover_photo_url IS 'URL của ảnh bìa người dùng từ Supabase Storage';

-- Verify column đã được thêm
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'users' 
AND column_name = 'cover_photo_url';