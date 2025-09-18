# 🎯 HƯỚNG DẪN CHẠY MIGRATION SQL CHO QR SYSTEM

## ❌ Vấn đề hiện tại:
Flutter SDK có vẻ bị lỗi, không thể chạy Dart scripts. Nhưng không sao, chúng ta có thể chạy SQL migration trực tiếp!

## ✅ CÁCH THỰC HIỆN:

### Bước 1: Mở Supabase Dashboard
1. Truy cập: https://supabase.com/dashboard
2. Đăng nhập vào project của bạn
3. Chọn project: **mogjjvscxjwvhtpkrlqr**

### Bước 2: Vào SQL Editor
1. Trong sidebar trái, click vào **"SQL Editor"**
2. Click **"New query"** để tạo query mới

### Bước 3: Copy và Execute SQL Migration
Copy toàn bộ nội dung từ file `add_user_qr_system.sql` và paste vào SQL Editor:

```sql
-- Migration: Add QR Code system to user_profiles table
-- Date: 2025-09-19
-- Purpose: Store user_code and qr_data permanently in database for better performance and future features

-- Add user_code and qr_data columns to user_profiles table
ALTER TABLE user_profiles 
ADD COLUMN IF NOT EXISTS user_code TEXT UNIQUE,
ADD COLUMN IF NOT EXISTS qr_data TEXT,
ADD COLUMN IF NOT EXISTS qr_generated_at TIMESTAMP WITH TIME ZONE;

-- Create index for faster user_code lookups (important for QR scanning)
CREATE INDEX IF NOT EXISTS idx_user_profiles_user_code ON user_profiles(user_code);

-- Create index for QR data queries
CREATE INDEX IF NOT EXISTS idx_user_profiles_qr_data ON user_profiles(qr_data);

-- Add comments for documentation
COMMENT ON COLUMN user_profiles.user_code IS 'Unique user code for QR sharing (e.g., SABO123ABC)';
COMMENT ON COLUMN user_profiles.qr_data IS 'QR code data URL for profile sharing';
COMMENT ON COLUMN user_profiles.qr_generated_at IS 'Timestamp when QR code was generated';

-- Function to auto-generate user_code for existing users
CREATE OR REPLACE FUNCTION generate_user_codes_for_existing_users()
RETURNS void AS $$
DECLARE
    user_record RECORD;
    new_user_code TEXT;
    counter INTEGER := 1;
BEGIN
    -- Loop through users without user_code
    FOR user_record IN 
        SELECT id FROM user_profiles WHERE user_code IS NULL
    LOOP
        -- Generate unique code
        LOOP
            new_user_code := 'SABO' || LPAD(counter::TEXT, 6, '0');
            
            -- Check if code already exists
            IF NOT EXISTS (SELECT 1 FROM user_profiles WHERE user_code = new_user_code) THEN
                EXIT;
            END IF;
            
            counter := counter + 1;
        END LOOP;
        
        -- Update user with new code
        UPDATE user_profiles 
        SET 
            user_code = new_user_code,
            qr_data = 'https://saboarena.com/user/' || user_record.id,
            qr_generated_at = NOW()
        WHERE id = user_record.id;
        
        counter := counter + 1;
    END LOOP;
    
    RAISE NOTICE 'Generated user codes for % users', counter - 1;
END;
$$ LANGUAGE plpgsql;

-- Execute the function to generate codes for existing users
SELECT generate_user_codes_for_existing_users();

-- Drop the function after use (optional)
DROP FUNCTION IF EXISTS generate_user_codes_for_existing_users();

-- Create function to auto-generate user_code on new user registration
CREATE OR REPLACE FUNCTION auto_generate_user_code()
RETURNS TRIGGER AS $$
DECLARE
    new_user_code TEXT;
    counter INTEGER := 1;
    base_code TEXT;
BEGIN
    -- Only generate if user_code is not already set
    IF NEW.user_code IS NULL THEN
        -- Generate base code from user ID (last 6 chars)
        base_code := 'SABO' || UPPER(RIGHT(NEW.id::TEXT, 6));
        
        -- Check if base code is available
        IF NOT EXISTS (SELECT 1 FROM user_profiles WHERE user_code = base_code) THEN
            new_user_code := base_code;
        ELSE
            -- Generate alternative with counter
            LOOP
                new_user_code := 'SABO' || LPAD(counter::TEXT, 6, '0');
                
                IF NOT EXISTS (SELECT 1 FROM user_profiles WHERE user_code = new_user_code) THEN
                    EXIT;
                END IF;
                
                counter := counter + 1;
            END LOOP;
        END IF;
        
        -- Set the generated code and QR data
        NEW.user_code := new_user_code;
        NEW.qr_data := 'https://saboarena.com/user/' || NEW.id;
        NEW.qr_generated_at := NOW();
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to auto-generate user_code on INSERT
DROP TRIGGER IF EXISTS trigger_auto_generate_user_code ON user_profiles;
CREATE TRIGGER trigger_auto_generate_user_code
    BEFORE INSERT ON user_profiles
    FOR EACH ROW
    EXECUTE FUNCTION auto_generate_user_code();

-- Grant necessary permissions
GRANT SELECT, UPDATE ON user_profiles TO authenticated;
GRANT SELECT ON user_profiles TO anon;
```

### Bước 4: Click Run
1. Click nút **"Run"** ở góc dưới bên phải
2. Chờ query thực thi (có thể mất 10-30 giây)
3. Kiểm tra kết quả trong **"Results"** tab

### Bước 5: Verify Migration
Sau khi chạy xong, test với query này để kiểm tra:

```sql
-- Check if migration successful
SELECT 
    COUNT(*) as total_users,
    COUNT(user_code) as users_with_qr_codes,
    ROUND(COUNT(user_code) * 100.0 / COUNT(*), 2) as coverage_percentage
FROM user_profiles;

-- Show sample QR codes
SELECT full_name, user_code, qr_data 
FROM user_profiles 
WHERE user_code IS NOT NULL 
LIMIT 5;
```

## 🎉 KẾT QUẢ SAU KHI MIGRATION:

✅ **Tất cả users hiện tại** sẽ có `user_code` và `qr_data`
✅ **Users mới đăng ký** sẽ tự động có QR code  
✅ **QR codes độc nhất** không trùng lặp
✅ **Performance indexes** được tạo cho tìm kiếm nhanh
✅ **Triggers tự động** kích hoạt khi có user mới

## 📱 SỬ DỤNG TRONG APP:

Sau khi migration xong, bạn có thể sử dụng:

```dart
// Hiển thị QR Modal
UserQRCodeModal.show(context, userProfile);

// Hiển thị QR Bottom Sheet  
UserQRCodeBottomSheet.show(context, userProfile);

// Chia sẻ profile
ShareService.shareUserProfile(userProfile);
```

## 🔧 NẾU CÓ LỖI:

Nếu gặp lỗi khi chạy migration, hãy:
1. Kiểm tra table `user_profiles` có tồn tại không
2. Kiểm tra permissions của user
3. Chạy từng phần của migration thay vì chạy tất cả một lúc

**Hoàn thành migration này là bước quan trọng để kích hoạt hệ thống QR Code!** 🚀