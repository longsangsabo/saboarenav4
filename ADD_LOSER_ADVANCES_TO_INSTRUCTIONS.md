# HƯỚNG DẪN THÊM COLUMN loser_advances_to

## Cần thêm column mới cho Double Elimination bracket

Để Double Elimination 16 players hoạt động đúng, cần thêm column `loser_advances_to` vào table `matches`.

### CÁCH 1: Qua Supabase Dashboard (KHUYẾN NGHỊ)

1. Mở **Supabase Dashboard**: https://supabase.com/dashboard/project/mogjjvscxjwvhtpkrlqr

2. Vào **SQL Editor** (menu bên trái)

3. Chạy SQL sau:

```sql
-- Add loser_advances_to column
ALTER TABLE matches 
ADD COLUMN IF NOT EXISTS loser_advances_to INTEGER;

-- Create index for performance
CREATE INDEX IF NOT EXISTS idx_matches_loser_advances_to 
ON matches(loser_advances_to);

-- Add comment
COMMENT ON COLUMN matches.loser_advances_to IS 
'For Double Elimination: The match_number that the loser of this match advances to. NULL if loser is eliminated.';
```

4. Click **Run** (hoặc Ctrl+Enter)

5. Kiểm tra kết quả: Nếu thành công sẽ hiển thị "Success. No rows returned"

### CÁCH 2: Qua Table Editor

1. Vào **Table Editor** > Chọn table `matches`

2. Click nút **"+ New column"**

3. Điền thông tin:
   - Name: `loser_advances_to`
   - Type: `int4` (integer)
   - Default value: `NULL`
   - Nullable: ✅ Checked

4. Click **Save**

5. Tạo index (vào SQL Editor chạy):
   ```sql
   CREATE INDEX idx_matches_loser_advances_to ON matches(loser_advances_to);
   ```

### Giải thích

- **winner_advances_to**: Match người THẮNG sẽ tiến tới
- **loser_advances_to**: Match người THUA sẽ tiến tới (vào loser bracket)

Ví dụ Double Elimination:
- Match 1 (Winner Bracket R1):
  - Winner → Match 9 (Winner Bracket R2)
  - Loser → Match 16 (Loser Bracket R1)

### Sau khi thêm column

1. Quay lại VS Code
2. Chạy lại app: `flutter run`
3. Tạo tournament Double Elimination 16 players mới
4. Bracket sẽ tự động có đường đi cho cả winner và loser

### Kiểm tra xem đã có column chưa

Chạy trong terminal:
```bash
python -c "import requests; r = requests.get('https://mogjjvscxjwvhtpkrlqr.supabase.co/rest/v1/matches?limit=1&select=loser_advances_to', headers={'apikey': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ'}); print('✅ Column exists!' if r.ok else '❌ Column missing')"
```

Nếu thấy "✅ Column exists!" là đã sẵn sàng!
