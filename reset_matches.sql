-- 🔄 SABO ARENA - Reset Tournament Matches SQL Script
-- Run this directly in Supabase SQL Editor

-- Find tournament sabo1
SELECT id, title FROM tournaments WHERE title ILIKE '%sabo1%';

-- OPTION 1: Reset scores to 0-0 and clear winners (keep matches structure)
-- Uncomment the lines below to use:

/*
UPDATE matches 
SET 
  player1_score = 0,
  player2_score = 0,
  winner_id = NULL,
  status = 'pending',
  completed_at = NULL,
  updated_at = NOW()
WHERE tournament_id = (SELECT id FROM tournaments WHERE title ILIKE '%sabo1%' LIMIT 1);
*/

-- OPTION 2: Delete ALL matches (to recreate bracket from scratch)
-- Uncomment the lines below to use:

/*
DELETE FROM matches 
WHERE tournament_id = (SELECT id FROM tournaments WHERE title ILIKE '%sabo1%' LIMIT 1);
*/

-- After running, you can verify:
SELECT 
  round_number,
  match_number, 
  player1_score,
  player2_score,
  winner_id,
  status
FROM matches 
WHERE tournament_id = (SELECT id FROM tournaments WHERE title ILIKE '%sabo1%' LIMIT 1)
ORDER BY round_number, match_number;
