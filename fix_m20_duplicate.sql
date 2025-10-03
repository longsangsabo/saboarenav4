-- Fix M20 duplicate user issue
-- Clear player2_id to allow service to refill it correctly

-- Check M20 current state
SELECT 
  match_number,
  player1_id,
  player2_id,
  status,
  display_order,
  bracket_type
FROM matches 
WHERE match_number = 20;

-- Clear player2_id and keep status as pending (waiting for second player)
UPDATE matches 
SET 
  player2_id = NULL
WHERE match_number = 20
  AND player1_id = player2_id; -- Only update if duplicate exists

-- Verify fix
SELECT 
  match_number,
  player1_id,
  player2_id,
  status
FROM matches 
WHERE match_number = 20;
