-- TẠO MATCHES CHO longsang063@gmail.com
-- Copy và chạy từng phần trong Supabase Dashboard > SQL Editor

-- PHẦN 1: Kiểm tra user và lấy ID
-- (Chạy trước để lấy user_id)
SELECT 
  id as longsang_user_id,
  display_name,
  email,
  skill_level
FROM users 
WHERE email = 'longsang063@gmail.com';

-- PHẦN 2: Lấy opponents và tournaments
-- (Chạy để xem danh sách)
SELECT 'OPPONENTS:' as info, id, display_name, email FROM users WHERE email != 'longsang063@gmail.com' LIMIT 3
UNION ALL
SELECT 'TOURNAMENTS:', id, title, status FROM tournaments LIMIT 2;

-- PHẦN 3: Tạo matches cụ thể
-- (Thay USER_ID bằng ID thật từ PHẦN 1)

-- Match 1: longsang063 vs Admin SABO
INSERT INTO matches (
  tournament_id,
  player1_id,
  player2_id,
  round_number,
  match_number,
  status,
  scheduled_time,
  notes
) VALUES (
  (SELECT id FROM tournaments WHERE title = 'Winter Championship 2024' LIMIT 1),
  (SELECT id FROM users WHERE email = 'longsang063@gmail.com'),
  (SELECT id FROM users WHERE email = 'admin@saboarena.com'),
  1,
  10, -- Match number 10
  'pending',
  NOW() + interval '1 day',
  'Match: longsang063 vs Admin SABO'
);

-- Match 2: longsang063 vs Nguyen Van Duc  
INSERT INTO matches (
  tournament_id,
  player1_id,
  player2_id,
  round_number,
  match_number,
  status,
  scheduled_time,
  notes
) VALUES (
  (SELECT id FROM tournaments WHERE title = 'SABO Arena Open' LIMIT 1),
  (SELECT id FROM users WHERE email = 'longsang063@gmail.com'),
  (SELECT id FROM users WHERE email = 'player1@example.com'),
  1,
  11, -- Match number 11
  'pending',
  NOW() + interval '2 days',
  'Match: longsang063 vs Nguyen Van Duc'
);

-- Match 3: longsang063 vs Tran Thi Mai
INSERT INTO matches (
  tournament_id,
  player1_id,
  player2_id,
  round_number,
  match_number,
  status,
  scheduled_time,
  notes
) VALUES (
  (SELECT id FROM tournaments WHERE title = 'Winter Championship 2024' LIMIT 1),
  (SELECT id FROM users WHERE email = 'longsang063@gmail.com'),
  (SELECT id FROM users WHERE email = 'player2@example.com'),
  1,
  12, -- Match number 12
  'pending',
  NOW() + interval '3 days',
  'Match: longsang063 vs Tran Thi Mai'
);

-- PHẦN 4: Verify kết quả
SELECT 
  'NEW MATCHES CREATED:' as status,
  m.id,
  m.match_number,
  t.title as tournament,
  p1.display_name as player1,
  p2.display_name as player2,
  m.status,
  m.scheduled_time,
  m.notes
FROM matches m
JOIN tournaments t ON m.tournament_id = t.id
JOIN users p1 ON m.player1_id = p1.id
JOIN users p2 ON m.player2_id = p2.id
WHERE p1.email = 'longsang063@gmail.com'
   OR p2.email = 'longsang063@gmail.com'
ORDER BY m.created_at DESC
LIMIT 5;