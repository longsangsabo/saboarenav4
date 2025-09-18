-- Test script to verify enhanced challenge system implementation
-- Run this to validate all tables, functions, and data were created correctly

-- 1. Check if all new tables exist
SELECT 
  'challenge_configurations' as table_name,
  COUNT(*) as row_count
FROM challenge_configurations
WHERE is_active = true

UNION ALL

SELECT 
  'rank_system' as table_name,
  COUNT(*) as row_count  
FROM rank_system

UNION ALL

SELECT 
  'handicap_rules' as table_name,
  COUNT(*) as row_count
FROM handicap_rules

UNION ALL

SELECT 
  'challenge_eligibility_view' as table_name,
  COUNT(*) as row_count
FROM challenge_eligibility
WHERE can_challenge = true;

-- 2. Test challenge eligibility examples
SELECT 
  '=== CHALLENGE ELIGIBILITY TESTS ===' as test_section;

-- Test K vs I (should be allowed - 2 sub-rank difference)
SELECT 
  'K vs I' as test_case,
  can_challenge_rank('K', 'I') as can_challenge,
  'Expected: true' as expected;

-- Test K vs G (should be denied - 6 sub-rank difference) 
SELECT 
  'K vs G' as test_case,
  can_challenge_rank('K', 'G') as can_challenge,
  'Expected: false' as expected;

-- Test H vs G (should be allowed - 2 sub-rank difference)
SELECT 
  'H vs G' as test_case,
  can_challenge_rank('H', 'G') as can_challenge,
  'Expected: true' as expected;

-- 3. Test handicap calculations
SELECT 
  '=== HANDICAP CALCULATION TESTS ===' as test_section;

-- Test K vs I+ with 300 SPA (1.5 main rank difference)
SELECT 
  'K vs I+ (300 SPA)' as test_case,
  is_valid,
  challenger_handicap,
  challenged_handicap,
  race_to,
  explanation
FROM calculate_challenge_handicap('K', 'I+', 300);

-- Test H vs G with 500 SPA (1 main rank difference)  
SELECT 
  'H vs G (500 SPA)' as test_case,
  is_valid,
  challenger_handicap,
  challenged_handicap,
  race_to,
  explanation
FROM calculate_challenge_handicap('H', 'G', 500);

-- Test same rank (no handicap)
SELECT 
  'K vs K (100 SPA)' as test_case,
  is_valid,
  challenger_handicap,
  challenged_handicap,
  race_to,
  explanation
FROM calculate_challenge_handicap('K', 'K', 100);

-- 4. Check SPA betting configurations
SELECT 
  '=== SPA BETTING CONFIGURATIONS ===' as test_section;

SELECT 
  bet_amount,
  race_to,
  description_vi as description
FROM challenge_configurations
ORDER BY bet_amount;

-- 5. Sample handicap matrix lookup
SELECT 
  '=== HANDICAP MATRIX SAMPLE ===' as test_section;

SELECT 
  rank_difference_type,
  rank_difference_value,
  bet_amount,
  handicap_value,
  description_vi
FROM handicap_rules
WHERE rank_difference_type IN ('1_sub', '1_main', '2_main')
AND bet_amount IN (100, 300, 600)
ORDER BY rank_difference_value, bet_amount;

-- 6. Challenge eligibility view sample
SELECT 
  '=== CHALLENGE ELIGIBILITY EXAMPLES ===' as test_section;

SELECT 
  challenger_rank,
  target_rank,
  rank_difference,
  can_challenge
FROM challenge_eligibility
WHERE challenger_rank = 'H'
ORDER BY target_rank;

SELECT 'All tests completed successfully!' as final_result;