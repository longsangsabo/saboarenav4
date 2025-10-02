-- ===================================================================
-- Add winner_advances_to column to matches table
-- This column stores which match the winner will advance to
-- Essential for hardcoded bracket advancement
-- ===================================================================

-- Step 1: Add the column
ALTER TABLE matches 
ADD COLUMN IF NOT EXISTS winner_advances_to INTEGER;

-- Step 2: Add comment
COMMENT ON COLUMN matches.winner_advances_to IS 'Match number that the winner advances to (NULL for final match)';

-- Step 3: Create index for performance
CREATE INDEX IF NOT EXISTS idx_matches_winner_advances_to 
ON matches(winner_advances_to) 
WHERE winner_advances_to IS NOT NULL;

-- Step 4: Verify
SELECT 
    column_name, 
    data_type, 
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'matches' 
AND column_name = 'winner_advances_to';

-- Success message
SELECT '✅ Column winner_advances_to added successfully!' as result;
