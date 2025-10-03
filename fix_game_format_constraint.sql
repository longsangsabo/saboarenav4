-- Fix game_format constraint to add 10-ball
-- Current constraint: 8-ball, 9-ball, straight, carom, snooker, other
-- Need to add: 10-ball

-- Step 1: Drop the existing constraint
ALTER TABLE tournaments 
DROP CONSTRAINT IF EXISTS check_game_format;

-- Step 2: Add new constraint with 10-ball included
ALTER TABLE tournaments 
ADD CONSTRAINT check_game_format 
CHECK (game_format IN (
  '8-ball',     -- Traditional 8-ball pool
  '9-ball',     -- Sequential 9-ball pool
  '10-ball',    -- Sequential 10-ball pool (NEW)
  'straight',   -- Straight pool / 14.1 continuous
  'carom',      -- Carom billiards
  'snooker',    -- Snooker
  'other'       -- Other game types
));

-- Verify the changes
SELECT 
  conname AS constraint_name,
  pg_get_constraintdef(oid) AS constraint_definition
FROM pg_constraint
WHERE conrelid = 'tournaments'::regclass
AND conname = 'check_game_format';

-- Check current game_format values
SELECT DISTINCT game_format, COUNT(*) as count
FROM tournaments
GROUP BY game_format
ORDER BY game_format;
