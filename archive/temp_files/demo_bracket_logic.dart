// 🧪 SABO ARENA - Simple Bracket Generation Demo
// Test bracket generation logic without Flutter dependencies

void main() async {
  print('🏆 SABO ARENA - BRACKET GENERATION DEMO');
  print('=' * 60);
  
  await demonstrateBracketGeneration();
  
  print('\n✅ Bracket generation demo completed!');
}

/// Simple demonstration of bracket generation logic
Future<void> demonstrateBracketGeneration() async {
  print('\n📊 DEMONSTRATING TOURNAMENT BRACKET LOGIC');
  print('-' * 50);
  
  // Test participants
  final participants = _createTestParticipants(8);
  
  print('\n👥 Tournament Participants:');
  for (int i = 0; i < participants.length; i++) {
    final p = participants[i];
    print('   ${i + 1}. ${p['name']} (ELO: ${p['elo']}, Rank: ${p['rank']})');
  }
  
  // Demonstrate seeding
  await _demonstrateSeeding(participants);
  
  // Demonstrate bracket structures
  await _demonstrateBracketStructures();
  
  // Demonstrate match progression
  await _demonstrateMatchProgression();
}

/// Create test participants with realistic data
List<Map<String, dynamic>> _createTestParticipants(int count) {
  final ranks = ['E+', 'E', 'F+', 'F', 'G+', 'G', 'H+', 'H', 'I+', 'I', 'K+', 'K'];
  final names = ['Nguyễn Văn A', 'Trần Thị B', 'Lê Văn C', 'Phạm Thị D', 
                 'Hoàng Văn E', 'Vũ Thị F', 'Đặng Văn G', 'Bùi Thị H',
                 'Đỗ Văn I', 'Ngô Thị J', 'Dương Văn K', 'Mai Thị L'];
  
  final participants = <Map<String, dynamic>>[];
  
  for (int i = 0; i < count; i++) {
    final elo = 2000 - (i * 50); 
    participants.add({
      'id': 'player_${i + 1}',
      'name': names[i % names.length],
      'rank': ranks[i % ranks.length],
      'elo': elo,
      'seed': i + 1,
    });
  }
  
  return participants;
}

/// Demonstrate seeding methods
Future<void> _demonstrateSeeding(List<Map<String, dynamic>> participants) async {
  print('\n🎯 SEEDING DEMONSTRATION');
  print('-' * 30);
  
  // ELO-based seeding (already sorted)
  print('\n📈 ELO-based Seeding:');
  for (int i = 0; i < participants.length; i++) {
    final p = participants[i];
    print('   Seed ${i + 1}: ${p['name']} (ELO: ${p['elo']})');
  }
  
  // Random seeding simulation
  final randomSeeded = List<Map<String, dynamic>>.from(participants);
  randomSeeded.shuffle();
  
  print('\n🎲 Random Seeding:');
  for (int i = 0; i < randomSeeded.length; i++) {
    final p = randomSeeded[i];
    print('   Seed ${i + 1}: ${p['name']} (ELO: ${p['elo']})');
  }
}

/// Demonstrate different bracket structures
Future<void> _demonstrateBracketStructures() async {
  print('\n🏗️  BRACKET STRUCTURES DEMONSTRATION');
  print('-' * 40);
  
  await _demonstrateSingleEliminationStructure();
  await _demonstrateDoubleEliminationStructure();
  await _demonstrateRoundRobinStructure();
  await _demonstrateSwissStructure();
}

/// Single elimination bracket structure
Future<void> _demonstrateSingleEliminationStructure() async {
  print('\n🏆 Single Elimination (8 players):');
  
  final rounds = _calculateSingleEliminationRounds(8);
  print('   Total rounds: $rounds');
  
  // Show bracket structure
  var playersInRound = 8;
  for (int round = 1; round <= rounds; round++) {
    final matches = playersInRound ~/ 2;
    final roundName = _getRoundName(round, rounds);
    print('   Round $round ($roundName): $matches matches, $playersInRound → ${playersInRound ~/ 2} players');
    playersInRound ~/= 2;
  }
  
  // Show first round pairings
  print('\n   First Round Pairings (Standard Seeding):');
  final pairings = _generateSingleEliminationPairings(8);
  for (int i = 0; i < pairings.length; i++) {
    final pair = pairings[i];
    print('     Match ${i + 1}: Seed ${pair[0]} vs Seed ${pair[1]}');
  }
}

/// Double elimination bracket structure  
Future<void> _demonstrateDoubleEliminationStructure() async {
  print('\n🏆🏆 Double Elimination (8 players):');
  
  final winnerRounds = _calculateSingleEliminationRounds(8);
  final loserRounds = (winnerRounds * 2) - 1;
  
  print('   Winner bracket rounds: $winnerRounds');
  print('   Loser bracket rounds: $loserRounds');
  print('   Grand final: 1 match');
  print('   Total matches: ${_calculateDoubleEliminationMatches(8)}');
}

/// Round robin structure
Future<void> _demonstrateRoundRobinStructure() async {
  print('\n🔄 Round Robin (6 players):');
  
  final players = 6;
  final rounds = players - 1;
  final totalMatches = (players * (players - 1)) ~/ 2;
  final matchesPerRound = players ~/ 2;
  
  print('   Total rounds: $rounds');
  print('   Matches per round: $matchesPerRound');
  print('   Total matches: $totalMatches');
  
  // Show round robin schedule
  final schedule = _generateRoundRobinSchedule(players);
  for (int round = 0; round < schedule.length; round++) {
    print('   Round ${round + 1}: ${schedule[round].join(', ')}');
  }
}

/// Swiss system structure
Future<void> _demonstrateSwissStructure() async {
  print('\n🇨🇭 Swiss System (16 players):');
  
  final players = 16;
  final rounds = _calculateSwissRounds(players);
  final matchesPerRound = players ~/ 2;
  
  print('   Total rounds: $rounds');
  print('   Matches per round: $matchesPerRound');
  print('   Total matches: ${rounds * matchesPerRound}');
  
  print('\n   Round 1 Pairings (Top vs Bottom):');
  for (int i = 0; i < matchesPerRound; i++) {
    final seed1 = i + 1;
    final seed2 = i + matchesPerRound + 1;
    print('     Match ${i + 1}: Seed $seed1 vs Seed $seed2');
  }
}

/// Demonstrate match progression logic
Future<void> _demonstrateMatchProgression() async {
  print('\n⚡ MATCH PROGRESSION DEMONSTRATION');
  print('-' * 40);
  
  print('\n🏆 Single Elimination Match Flow:');
  print('   Round 1: 8 players → 4 winners advance');
  print('   Round 2: 4 players → 2 winners advance'); 
  print('   Round 3: 2 players → 1 champion');
  
  print('\n🏆🏆 Double Elimination Match Flow:');
  print('   Winner Bracket: Same as single elimination');
  print('   Loser Bracket: Losers get second chance');
  print('   Grand Final: WB champion vs LB champion');
  print('   Reset: If LB champion wins, play again');
  
  print('\n🔄 Round Robin Match Flow:');
  print('   All players play each other once');
  print('   Final ranking by wins/points');
  
  print('\n🇨🇭 Swiss System Match Flow:');
  print('   Round 1: Initial pairing');
  print('   Round 2+: Pair by current score');
  print('   No elimination, best record wins');
}

// Helper functions for calculations
int _calculateSingleEliminationRounds(int players) {
  var rounds = 0;
  var remaining = _nearestPowerOfTwo(players);
  while (remaining > 1) {
    rounds++;
    remaining ~/= 2;
  }
  return rounds;
}

int _nearestPowerOfTwo(int n) {
  if (n <= 1) return 2;
  var power = 1;
  while (power < n) {
    power *= 2;
  }
  return power;
}

List<List<int>> _generateSingleEliminationPairings(int players) {
  final bracketSize = _nearestPowerOfTwo(players);
  final pairings = <List<int>>[];
  
  for (int i = 0; i < bracketSize ~/ 2; i++) {
    final seed1 = i + 1;
    final seed2 = bracketSize - i;
    if (seed1 <= players && seed2 <= players) {
      pairings.add([seed1, seed2]);
    }
  }
  
  return pairings;
}

int _calculateDoubleEliminationMatches(int players) {
  final singleElimMatches = players - 1;
  return singleElimMatches * 2 - 1; // Approximate
}

List<List<String>> _generateRoundRobinSchedule(int players) {
  final schedule = <List<String>>[];
  
  for (int round = 1; round < players; round++) {
    final roundMatches = <String>[];
    for (int i = 0; i < players ~/ 2; i++) {
      final player1 = (i == 0) ? players : ((round - 1 + i - 1) % (players - 1)) + 1;
      final player2 = ((round - 1 - i - 1) % (players - 1)) + 1;
      roundMatches.add('P$player1 vs P$player2');
    }
    schedule.add(roundMatches);
  }
  
  return schedule;
}

int _calculateSwissRounds(int players) {
  var rounds = 1;
  var temp = players;
  while (temp > 1) {
    rounds++;
    temp ~/= 2;
  }
  return rounds - 1; // Swiss typically has fewer rounds
}

String _getRoundName(int roundNumber, int totalRounds) {
  final remaining = totalRounds - roundNumber + 1;
  
  switch (remaining) {
    case 1:
      return 'Chung kết';
    case 2:
      return 'Bán kết';
    case 3:
      return 'Tứ kết';
    case 4:
      return 'Vòng 16';
    case 5:
      return 'Vòng 32';
    default:
      return 'Vòng $roundNumber';
  }
}