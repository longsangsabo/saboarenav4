-- DATABASE SCHEMA CLEANUP
-- Remove unused skill_level_required column and constraints

-- 1. Drop skill level constraints
ALTER TABLE tournaments DROP CONSTRAINT IF EXISTS tournaments_skill_level_required_check;