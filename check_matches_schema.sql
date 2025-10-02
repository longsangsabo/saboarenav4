-- Check current schema of matches table
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_name = 'matches'
ORDER BY ordinal_position;
