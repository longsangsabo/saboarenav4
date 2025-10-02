-- Migration: Add bracket_type column for Double Elimination brackets
-- This column identifies whether a match belongs to winner bracket, loser bracket, or grand final

ALTER TABLE matches ADD COLUMN IF NOT EXISTS bracket_type VARCHAR(20);

-- Create index for efficient queries
CREATE INDEX IF NOT EXISTS idx_matches_bracket_type 
ON matches(bracket_type);

-- Add comment to explain the column
COMMENT ON COLUMN matches.bracket_type IS 
'For Double Elimination: Identifies the bracket type - "winner", "loser", or "grand_final". NULL for other formats.';
