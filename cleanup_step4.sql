-- Step 4: Remove skill_level_required column (optional)
ALTER TABLE tournaments DROP COLUMN IF EXISTS skill_level_required;