// Simple test to verify ELO constants work
void testEloCalculations() {
  print('🧪 Testing ELO calculations...');

  // Test fixed rewards
  Map<int, int> expectedRewards = {
    1: 75,  // 1st place
    2: 45,  // 2nd place
    3: 30,  // 3rd place
    4: 20,  // 4th place
    5: 10,  // Top 5-8
    6: 10,  // Top 5-8
    7: 10,  // Top 5-8
    8: 10,  // Top 5-8
    9: 5,   // Top 9-16
    10: 5,  // Top 9-16
    15: 5,  // Top 9-16
    16: 5,  // Top 9-16
    17: 0,  // Others
    20: 0,  // Others
  };

  print('\n📊 Testing ELO rewards:');
  expectedRewards.forEach((position, expectedElo) {
    int actualElo = calculateEloChange(position);
    String status = actualElo == expectedElo ? '✅' : '❌';
    print('Position $position: Expected $expectedElo, Got $actualElo $status');
  });
}

/// Simple ELO calculation function
int calculateEloChange(int position) {
  // Fixed positions
  if (position == 1) return 75;   // 1st: +75
  if (position == 2) return 45;   // 2nd: +45
  if (position == 3) return 30;   // 3rd: +30
  if (position == 4) return 20;   // 4th: +20
  
  // Range-based positions
  if (position >= 5 && position <= 8) return 10;     // 5-8: +10
  if (position >= 9 && position <= 16) return 5;     // 9-16: +5
  
  return 0; // Others: 0
}

void testTournamentEloService() {
  print('🧪 Testing TournamentEloService...');
  
  // Test 8-player tournament
  Map<String, int> playerPositions = {
    'player1': 1,  // Winner
    'player2': 2,  // 2nd place
    'player3': 3,  // 3rd place
    'player4': 4,  // 4th place
    'player5': 5,  // Top 5-8
    'player6': 6,  // Top 5-8
    'player7': 7,  // Top 5-8
    'player8': 8,  // Top 5-8
  };
  
  Map<String, int> currentElos = {
    'player1': 1400,
    'player2': 1350,
    'player3': 1300,
    'player4': 1250,
    'player5': 1200,
    'player6': 1150,
    'player7': 1100,
    'player8': 1050,
  };
  
  Map<String, String> currentRanks = {
    'player1': 'H',
    'player2': 'I+',
    'player3': 'I+',
    'player4': 'I',
    'player5': 'I',
    'player6': 'K+',
    'player7': 'K+',
    'player8': 'K',  
  };
  
  // Test ELO calculations
  Map<String, int> eloChanges = TournamentEloService.calculateTournamentEloChanges(
    playerPositions: playerPositions,
    totalParticipants: 8,
  );
  
  print('\n📊 ELO Changes:');
  eloChanges.forEach((playerId, change) {
    print('$playerId: ${change > 0 ? '+' : ''}$change ELO');
  });
  
  // Test full tournament results
  Map<String, Map<String, dynamic>> results = TournamentEloService.getTournamentResults(
    playerPositions: playerPositions,
    currentElos: currentElos,
    currentRanks: currentRanks,
    totalParticipants: 8,
  );
  
  print('\n🏆 Tournament Results:');
  results.forEach((playerId, result) {
    print('$playerId:');
    print('  Position: ${result['position']} (${result['positionCategory']})');
    print('  ELO: ${result['currentElo']} → ${result['newElo']} (${result['eloChange'] > 0 ? '+' : ''}${result['eloChange']})');
    print('  Rank: ${result['currentRank']} → ${result['newRank']} ${result['rankChanged'] ? (result['rankUp'] ? '⬆️' : '⬇️') : ''}');
    print('');
  });
  
  // Test tournament stats
  Map<String, dynamic> stats = TournamentEloService.getTournamentStats(
    playerPositions: playerPositions,
    totalParticipants: 8,
  );
  
  print('📈 Tournament Stats:');
  print('Total Participants: ${stats['totalParticipants']}');
  print('Total ELO Awarded: ${stats['totalEloAwarded']}');
  print('Players with Rewards: ${stats['playersWithRewards']}');
  print('Max ELO Reward: ${stats['maxEloReward']}');
  print('Min ELO Reward: ${stats['minEloReward']}');
  print('Average ELO Change: ${stats['averageEloChange'].toStringAsFixed(1)}');
  
  print('\n✅ TournamentEloService test completed!');
}

void main() {
  testTournamentEloService();
}