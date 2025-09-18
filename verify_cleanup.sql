-- Verification: Check remaining constraints
SELECT constraint_name, constraint_type 
FROM information_schema.table_constraints 
WHERE table_name = 'tournaments' AND constraint_type = 'CHECK';