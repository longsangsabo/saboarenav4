# SABO ARENA - BACKEND SETUP MANUAL

## 🚨 QUAN TRỌNG: Chạy SQL Script Trong Supabase Dashboard

Vì không thể chạy SQL script trực tiếp qua API, bạn cần thực hiện các bước sau:

### Bước 1: Mở Supabase Dashboard
1. Truy cập: https://supabase.com/dashboard/project/mogjjvscxjwvhtpkrlqr
2. Đăng nhập với tài khoản của bạn
3. Chọn project "sabo_arena"

### Bước 2: Chạy SQL Script
1. Vào **SQL Editor** (trong sidebar trái)
2. Tạo một **New Query**
3. Copy toàn bộ nội dung từ file `backend_setup_complete.sql`
4. Paste vào SQL Editor
5. Click **Run** để thực thi

### Bước 3: Kiểm Tra Kết Quả
Sau khi chạy script, bạn sẽ thấy:
- ✅ Các columns mới được thêm vào bảng `matches` và `users`
- ✅ Bảng `challenges` và `spa_transactions` được tạo
- ✅ Các functions API được tạo:
  - `get_nearby_players()`
  - `create_challenge()`
  - `accept_challenge()`
  - `decline_challenge()`
  - `get_user_challenges()`

## 📊 Dữ Liệu Test Cần Thiết

Để test tính năng opponent tab, chúng ta cần:

### 1. Users với Location Data
```sql
-- Update existing users with location data (Hanoi area)
UPDATE users SET 
  latitude = 21.028511 + (RANDOM() - 0.5) * 0.1,
  longitude = 105.804817 + (RANDOM() - 0.5) * 0.1,
  location_name = 'Hà Nội',
  is_available_for_challenges = true,
  preferred_match_type = CASE 
    WHEN RANDOM() < 0.3 THEN 'giao_luu'
    WHEN RANDOM() < 0.6 THEN 'thach_dau' 
    ELSE 'both' 
  END,
  spa_points = 1000 + FLOOR(RANDOM() * 2000)::INTEGER
WHERE id IN (
  SELECT id FROM users 
  WHERE latitude IS NULL 
  LIMIT 10
);
```

### 2. Test Challenges
```sql
-- Create some test challenges
INSERT INTO challenges (challenger_id, challenged_id, challenge_type, message, stakes_amount)
SELECT 
  u1.id,
  u2.id,
  CASE WHEN RANDOM() < 0.5 THEN 'giao_luu' ELSE 'thach_dau' END,
  'Thách đấu cùng nhau!',
  CASE WHEN RANDOM() < 0.5 THEN 0 ELSE 100 END
FROM users u1 
CROSS JOIN users u2 
WHERE u1.id != u2.id 
AND RANDOM() < 0.1
LIMIT 5;
```

## 🧪 Test API Functions

Sau khi setup xong, test các functions:

### Test get_nearby_players:
```bash
curl -X POST \
  'https://mogjjvscxjwvhtpkrlqr.supabase.co/rest/v1/rpc/get_nearby_players' \
  -H 'apikey: ANON_KEY' \
  -H 'Authorization: Bearer USER_JWT' \
  -H 'Content-Type: application/json' \
  -d '{"center_lat": 21.028511, "center_lng": 105.804817, "radius_km": 10}'
```

### Test create_challenge:
```bash
curl -X POST \
  'https://mogjjvscxjwvhtpkrlqr.supabase.co/rest/v1/rpc/create_challenge' \
  -H 'apikey: ANON_KEY' \
  -H 'Authorization: Bearer USER_JWT' \
  -H 'Content-Type: application/json' \
  -d '{
    "challenged_user_id": "USER_ID",
    "challenge_type_param": "giao_luu",
    "message_param": "Let'\''s play!",
    "stakes_amount_param": 0
  }'
```

## ✅ Checklist Hoàn Thành Backend

- [ ] Chạy `backend_setup_complete.sql` trong Supabase Dashboard
- [ ] Verify các bảng và columns mới được tạo
- [ ] Test function `get_nearby_players()` hoạt động
- [ ] Update users với location data
- [ ] Tạo test challenges
- [ ] Test challenge functions hoạt động
- [ ] Kiểm tra RLS policies hoạt động đúng

## 🔧 Troubleshooting

Nếu gặp lỗi:
1. **"function not found"**: Chắc chắn đã chạy toàn bộ SQL script
2. **"permission denied"**: Kiểm tra RLS policies
3. **"user not authenticated"**: Cần JWT token hợp lệ trong Authorization header

## 📱 Frontend Integration

Sau khi backend setup xong, Flutter app sẽ có thể:
- ✅ Tìm nearby players với `get_nearby_players()`
- ✅ Gửi challenge với `create_challenge()`
- ✅ Accept/decline challenges
- ✅ Hiển thị thông tin chi tiết trong PlayerCardWidget
- ✅ Phân biệt giữa "Giao lưu" và "Thách đấu"