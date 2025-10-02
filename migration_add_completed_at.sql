-- ===================================================================
-- MIGRATION: Add completed_at column to matches table
-- Date: 2025-10-02
-- Purpose: Track when matches are completed for tournament progression
-- ===================================================================

-- Step 1: Add the column if it doesn't exist
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'matches' 
        AND column_name = 'completed_at'
    ) THEN
        ALTER TABLE matches 
        ADD COLUMN completed_at TIMESTAMP WITH TIME ZONE;
        
        RAISE NOTICE 'Column completed_at added successfully';
    ELSE
        RAISE NOTICE 'Column completed_at already exists';
    END IF;
END $$;

-- Step 2: Backfill existing completed matches
UPDATE matches 
SET completed_at = updated_at 
WHERE status = 'completed' 
AND completed_at IS NULL
AND updated_at IS NOT NULL;

-- Step 3: Add index for performance
CREATE INDEX IF NOT EXISTS idx_matches_completed_at 
ON matches(completed_at) 
WHERE completed_at IS NOT NULL;

-- Step 4: Add comment
COMMENT ON COLUMN matches.completed_at IS 'Timestamp when the match was completed/finished';

-- Step 5: Verify the changes
SELECT 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'matches' 
AND column_name IN ('completed_at', 'updated_at', 'created_at')
ORDER BY ordinal_position;

-- Step 6: Show count of matches with completed_at
SELECT 
    COUNT(*) FILTER (WHERE completed_at IS NOT NULL) as matches_with_completed_at,
    COUNT(*) FILTER (WHERE completed_at IS NULL) as matches_without_completed_at,
    COUNT(*) as total_matches
FROM matches;
