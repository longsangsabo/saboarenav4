-- Migration: Add loser_advances_to column for Double Elimination brackets
-- This column stores which match a loser advances to in the loser bracket

ALTER TABLE matches ADD COLUMN IF NOT EXISTS loser_advances_to INTEGER;

-- Create index for efficient queries when finding next match for losers
CREATE INDEX IF NOT EXISTS idx_matches_loser_advances_to 
ON matches(loser_advances_to);

-- Add comment to explain the column
COMMENT ON COLUMN matches.loser_advances_to IS 
'For Double Elimination: The match_number that the loser of this match advances to. NULL if loser is eliminated.';
