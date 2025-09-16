-- Script để tạo matches cho user longsang063@gmail.com
-- Chạy trong Supabase Dashboard > SQL Editor

-- 1. Kiểm tra user longsang063@gmail.com
SELECT id, email, display_name, skill_level 
FROM users 
WHERE email = 'longsang063@gmail.com';

-- 2. Lấy danh sách opponents (users khác)
WITH target_user AS (
  SELECT id FROM users WHERE email = 'longsang063@gmail.com'
),
opponents AS (
  SELECT id, display_name, email 
  FROM users 
  WHERE id != (SELECT id FROM target_user)
  LIMIT 5
),
tournaments AS (
  SELECT id, title FROM tournaments LIMIT 2
)

-- 3. Tạo matches cho longsang063@gmail.com
INSERT INTO matches (
  tournament_id,
  player1_id,
  player2_id,
  round_number,
  match_number,
  player1_score,
  player2_score,
  status,
  scheduled_time,
  notes
)
SELECT 
  t.id as tournament_id,
  (SELECT id FROM target_user) as player1_id,
  o.id as player2_id,
  1 as round_number,
  ROW_NUMBER() OVER () + 1 as match_number, -- Bắt đầu từ match 2
  0 as player1_score,
  0 as player2_score,
  'pending' as status,
  NOW() + (ROW_NUMBER() OVER () || ' days')::interval as scheduled_time,
  'Match created for longsang063@gmail.com vs ' || o.display_name as notes
FROM opponents o
CROSS JOIN tournaments t
LIMIT 3;

-- 4. Verify matches đã tạo
SELECT 
  m.id,
  m.round_number,
  m.match_number,
  m.status,
  m.scheduled_time,
  t.title as tournament_name,
  p1.display_name as player1_name,
  p1.email as player1_email,
  p2.display_name as player2_name,
  p2.email as player2_email,
  m.notes
FROM matches m
JOIN tournaments t ON m.tournament_id = t.id
JOIN users p1 ON m.player1_id = p1.id
JOIN users p2 ON m.player2_id = p2.id
WHERE p1.email = 'longsang063@gmail.com'
ORDER BY m.created_at DESC;

-- 5. Tổng kết
SELECT 
  'Total matches for longsang063@gmail.com' as summary,
  COUNT(*) as match_count
FROM matches m
JOIN users u ON (m.player1_id = u.id OR m.player2_id = u.id)
WHERE u.email = 'longsang063@gmail.com';