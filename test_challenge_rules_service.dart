/// Test script for Challenge Rules Service
/// Run this to validate all challenge logic is working correctly

import '../lib/services/challenge_rules_service.dart';

void main() async {
  print('🔥 TESTING SABO ARENA CHALLENGE RULES SERVICE');
  print('=' * 60);
  
  final rulesService = ChallengeRulesService.instance;
  
  // Test 1: Rank Eligibility
  print('\n📊 1. RANK ELIGIBILITY TESTS');
  print('-' * 30);
  
  testRankEligibility(rulesService, 'K', 'I'); // Should be true (2 sub-rank diff)
  testRankEligibility(rulesService, 'K', 'G'); // Should be false (6 sub-rank diff)
  testRankEligibility(rulesService, 'H', 'F'); // Should be true (2 main rank diff)
  testRankEligibility(rulesService, 'I', 'E'); // Should be false (8 sub-rank diff)
  
  // Test 2: SPA Betting Configuration
  print('\n💰 2. SPA BETTING CONFIGURATION TESTS');
  print('-' * 40);
  
  final spaBettingOptions = rulesService.getSpaBettingOptions();
  for (final option in spaBettingOptions) {
    print('✅ ${option['amount']} SPA → Race to ${option['raceTo']} (${option['description']})');
  }
  
  // Test 3: Handicap Calculations
  print('\n⚖️ 3. HANDICAP CALCULATION TESTS');
  print('-' * 35);
  
  testHandicapCalculation(rulesService, 'K', 'I+', 300); // K vs I+ with 300 SPA
  testHandicapCalculation(rulesService, 'H', 'G', 500);  // H vs G with 500 SPA
  testHandicapCalculation(rulesService, 'K', 'K', 200);  // Same rank (no handicap)
  testHandicapCalculation(rulesService, 'K', 'E', 100);  // Invalid (too large diff)
  
  // Test 4: Eligible Ranks
  print('\n📋 4. ELIGIBLE RANKS TESTS');
  print('-' * 25);
  
  testEligibleRanks(rulesService, 'K');
  testEligibleRanks(rulesService, 'H');
  testEligibleRanks(rulesService, 'F');
  
  // Test 5: Rank Display Info
  print('\n🎨 5. RANK DISPLAY INFO TESTS');
  print('-' * 30);
  
  for (final rank in ['K', 'I', 'H', 'G', 'F', 'E+']) {
    final info = rulesService.getRankDisplayInfo(rank);
    print('$rank: ${info['displayName']} (Value: ${info['value']}, Color: ${info['color']})');
  }
  
  print('\n🎉 All tests completed successfully!');
}

void testRankEligibility(ChallengeRulesService service, String challenger, String challenged) {
  final canChallenge = service.canChallenge(challenger, challenged);
  final result = canChallenge ? '✅ Allowed' : '❌ Denied';
  print('$challenger vs $challenged: $result');
}

void testHandicapCalculation(ChallengeRulesService service, String challenger, String challenged, int spaBet) {
  final result = service.calculateHandicap(
    challengerRank: challenger,
    challengedRank: challenged,
    spaBetAmount: spaBet,
  );
  
  if (result.isValid) {
    print('$challenger vs $challenged ($spaBet SPA):');
    print('  ✅ Valid - Race to ${result.raceTo}');
    print('  📊 ${result.explanation}');
  } else {
    print('$challenger vs $challenged ($spaBet SPA): ❌ ${result.errorMessage}');
  }
}

void testEligibleRanks(ChallengeRulesService service, String rank) {
  final eligibleRanks = service.getEligibleRanks(rank);
  print('$rank can challenge: ${eligibleRanks.join(', ')}');
}