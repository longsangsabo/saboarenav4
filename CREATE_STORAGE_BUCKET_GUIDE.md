# 🗂️ HƯỚNG DẪN TẠO STORAGE BUCKET MỚI

## 🎯 **TẠO BUCKET QUA SUPABASE DASHBOARD**

### **Bước 1: Truy cập Storage**
1. Mở: https://supabase.com/dashboard/project/mogjjvscxjwvhtpkrlqr/storage/buckets
2. Hoặc: Dashboard → Storage → Buckets

### **Bước 2: Tạo Bucket Mới**
1. **Click nút "New bucket"**
2. **Điền thông tin:**
   ```
   Name: user-images
   Public bucket: ✅ CHECKED (rất quan trọng!)
   ```
3. **Click "Create bucket"**

### **Bước 3: Cấu hình Bucket**
1. **Click vào bucket "user-images" vừa tạo**
2. **Vào Settings tab**
3. **Cấu hình:**
   ```
   File size limit: 10 MB
   Allowed MIME types:
   - image/jpeg
   - image/jpg  
   - image/png
   - image/webp
   - image/gif
   ```
4. **Click "Save"**

## 🔧 **CẬP NHẬT CODE**

### **Bước 4: Update StorageService**
Trong file `lib/services/storage_service.dart`, thay đổi:

```dart
// Từ:
await _supabase.storage.from('profiles')

// Thành:
await _supabase.storage.from('user-images')
```

**Tìm và thay thế tất cả:**
- `from('profiles')` → `from('user-images')`

## ✅ **KIỂM TRA HOÀN THÀNH**

### **Bucket Settings Should Be:**
- ✅ Name: user-images
- ✅ Public: enabled 
- ✅ File size: 10MB limit
- ✅ MIME types: image formats only

### **Code Changes:**
- ✅ StorageService updated to use 'user-images'
- ✅ All .from('profiles') changed to .from('user-images')

## 🚀 **TESTING**

### **Sau khi hoàn thành:**
1. **Hot reload app** (nhấn `r` trong terminal)
2. **Test upload avatar/cover photo**
3. **Kiểm tra ảnh có persist sau restart không**

## 📞 **NẾU CÓ VẤN ĐỀ:**

### **Lỗi 403 (Unauthorized):**
```sql
-- Chạy trong Supabase SQL Editor:
ALTER TABLE storage.objects DISABLE ROW LEVEL SECURITY;
ALTER TABLE storage.buckets DISABLE ROW LEVEL SECURITY;
```

### **Lỗi không tìm thấy bucket:**
- Kiểm tra tên bucket trong code
- Đảm bảo bucket đã được tạo thành công

**Bạn hãy làm theo hướng dẫn này và cho tôi biết kết quả!** 🎯