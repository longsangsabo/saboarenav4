-- Add winner_advances_to column to matches table
-- Run this SQL in Supabase SQL Editor

ALTER TABLE matches ADD COLUMN IF NOT EXISTS winner_advances_to INTEGER;

CREATE INDEX IF NOT EXISTS idx_matches_winner_advances_to ON matches(winner_advances_to);

-- Verify column was added
SELECT column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_name = 'matches' 
AND column_name = 'winner_advances_to';
