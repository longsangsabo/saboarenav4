# 🎯 HƯỚNG DẪN DATABASE SCHEMA CLEANUP

## ✅ VẤN ĐỀ ĐÃ GIẢI QUYẾT:
- ✅ Tournament creation hoạt động bình thường
- ✅ Code đã remove skill_level_required
- ✅ App không còn gửi Vietnamese ranks

## 🧹 OPTIONAL: CLEANUP DATABASE SCHEMA

Hiện tại app hoạt động tốt, nhưng nếu muốn cleanup database schema để loại bỏ cột `skill_level_required` không dùng:

### BƯỚC 1: Truy cập Supabase SQL Editor
1. Mở: https://app.supabase.com/project/mogjjvscxjwvhtpkrlqr/sql/new
2. Đăng nhập vào project của bạn

### BƯỚC 2: Chạy Cleanup Script
Copy đoạn SQL sau và paste vào SQL Editor, sau đó click **"Run"**:

```sql
-- DATABASE SCHEMA CLEANUP
-- Remove unused skill_level_required column and constraints

-- 1. Drop skill level constraints
ALTER TABLE tournaments DROP CONSTRAINT IF EXISTS tournaments_skill_level_required_check;
ALTER TABLE tournaments DROP CONSTRAINT IF EXISTS tournaments_skill_level_check;

-- 2. Drop related indexes
DROP INDEX IF EXISTS idx_tournaments_skill_level;

-- 3. Remove skill_level_required column (optional - can keep for compatibility)
-- ALTER TABLE tournaments DROP COLUMN IF EXISTS skill_level_required;

-- 4. Keep users rank system as-is
-- Users table rank column is still used for Vietnamese ranking system
COMMENT ON COLUMN users.rank IS 'Vietnamese billiards ranking: K, K+, I, I+, H, H+, G, G+, F, F+, E, E+';

-- Cleanup completed
```

### BƯỚC 3: Verification (Optional)
Kiểm tra cleanup thành công:

```sql
-- Check if constraints were removed
SELECT constraint_name, constraint_type 
FROM information_schema.table_constraints 
WHERE table_name = 'tournaments' AND constraint_type = 'CHECK';

-- Test tournament creation still works
INSERT INTO tournaments (
    title, 
    description, 
    start_date, 
    end_date, 
    registration_deadline,
    max_participants, 
    format, 
    status,
    entry_fee,
    prize_pool
) VALUES (
    'Cleanup Test Tournament',
    'Testing after schema cleanup', 
    '2025-01-01',
    '2025-01-02',
    '2024-12-31',
    16,
    'single_elimination',
    'upcoming',
    50000,
    1000000
);
```

## ✅ HIỆN TẠI APP ĐÃ HOẠT ĐỘNG:

1. ✅ **Tournament creation works** - không còn constraint errors
2. ✅ **Code cleaned up** - remove skill_level_required khỏi Flutter code  
3. ✅ **Vietnamese ranks** vẫn được dùng trong requirements text
4. ✅ **Database compatible** - skill_level_required set NULL automatically

## 🔄 NẾU CẦN ROLLBACK:

```sql
-- Restore constraints if needed (not recommended)
ALTER TABLE tournaments ADD CONSTRAINT tournaments_skill_level_check 
CHECK (skill_level_required IN ('beginner', 'intermediate', 'advanced', 'professional') OR skill_level_required IS NULL);
```

---

**💡 KẾT LUẬN:** 
- **App đã hoạt động bình thường** mà không cần skill level constraints
- **Database cleanup là optional** - có thể skip nếu không muốn risk
- **Vietnamese ranking system** vẫn được preserve trong user profiles và requirements