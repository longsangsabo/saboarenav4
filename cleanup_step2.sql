-- Step 2: Drop additional skill level constraints
ALTER TABLE tournaments DROP CONSTRAINT IF EXISTS tournaments_skill_level_check;