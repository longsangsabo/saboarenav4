-- Check tournament format
SELECT name, format, bracket_format 
FROM tournaments 
WHERE name = 'sabo1';

-- Check if winner_advances_to has data
SELECT 
  match_number,
  round,
  winner_advances_to,
  player1_id IS NOT NULL as has_player1,
  player2_id IS NOT NULL as has_player2
FROM matches 
WHERE tournament_id = (SELECT id FROM tournaments WHERE name = 'sabo1')
ORDER BY round, match_number;
