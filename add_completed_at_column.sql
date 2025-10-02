-- Add completed_at column to matches table
-- This column tracks when a match was completed

ALTER TABLE matches 
ADD COLUMN IF NOT EXISTS completed_at TIMESTAMP WITH TIME ZONE;

-- Add comment
COMMENT ON COLUMN matches.completed_at IS 'Timestamp when match was completed';

-- Create index for performance
CREATE INDEX IF NOT EXISTS idx_matches_completed_at ON matches(completed_at);

-- Verify the column was added
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'matches' 
AND column_name = 'completed_at';
