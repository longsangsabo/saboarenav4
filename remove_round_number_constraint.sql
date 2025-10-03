-- Remove NOT NULL constraint from round_number column
-- We now use stage_round and display_order instead

-- Step 1: Make round_number nullable
ALTER TABLE matches 
ALTER COLUMN round_number DROP NOT NULL;

-- Step 2: Verify the change
SELECT 
    column_name, 
    data_type, 
    is_nullable 
FROM information_schema.columns 
WHERE table_name = 'matches' 
AND column_name IN ('round_number', 'stage_round', 'display_order');
