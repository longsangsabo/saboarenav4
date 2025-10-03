-- Check current constraint on tournaments table
-- This will show what values are currently allowed

-- Get constraint definition
SELECT
    conname AS constraint_name,
    pg_get_constraintdef(oid) AS constraint_definition
FROM pg_constraint
WHERE conrelid = 'tournaments'::regclass
AND conname LIKE '%game_format%';

-- Check current game_format values in database
SELECT DISTINCT game_format, COUNT(*) as count
FROM tournaments
GROUP BY game_format
ORDER BY game_format;

-- Get table column info
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'tournaments'
AND column_name = 'game_format';
