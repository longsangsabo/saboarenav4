// 🧪 SABO ARENA - Tournament Bracket Generator Tests
// Comprehensive tests for all tournament formats and bracket generation

import 'lib/services/bracket_generator_service.dart';
import 'lib/core/constants/tournament_constants.dart';

void main() async {
  print('🧪 SABO ARENA - TOURNAMENT BRACKET GENERATOR TESTS');
  print('=' * 70);
  
  await testAllTournamentFormats();
  
  print('\n✅ All bracket generation tests completed!');
}

/// Test all tournament formats with different player counts
Future<void> testAllTournamentFormats() async {
  await testSingleElimination();
  await testDoubleElimination();
  await testRoundRobin();
  await testSwissSystem();
  await testParallelGroups();
}

/// Test Single Elimination brackets
Future<void> testSingleElimination() async {
  print('\n🏆 TESTING SINGLE ELIMINATION');
  print('-' * 50);
  
  final testCases = [8, 16, 32];
  
  for (final playerCount in testCases) {
    print('\n📊 Testing with $playerCount players:');
    
    final participants = _generateTestParticipants(playerCount);
    
    try {
      final bracket = await BracketGeneratorService.generateBracket(
        tournamentId: 'test_single_$playerCount',
        format: TournamentFormats.singleElimination,
        participants: participants,
        seedingMethod: 'elo_based',
      );
      
      _validateBracket(bracket, TournamentFormats.singleElimination, playerCount);
      print('   ✅ $playerCount players: ${bracket.rounds.length} rounds generated');
      
      // Print bracket structure
      for (final round in bracket.rounds) {
        print('   Round ${round.roundNumber}: ${round.matches.length} matches (${round.name})');
      }
      
    } catch (e) {
      print('   ❌ Error: $e');
    }
  }
}

/// Test Double Elimination brackets
Future<void> testDoubleElimination() async {
  print('\n🏆🏆 TESTING DOUBLE ELIMINATION');
  print('-' * 50);
  
  final testCases = [8, 16];
  
  for (final playerCount in testCases) {
    print('\n📊 Testing with $playerCount players:');
    
    final participants = _generateTestParticipants(playerCount);
    
    try {
      final bracket = await BracketGeneratorService.generateBracket(
        tournamentId: 'test_double_$playerCount',
        format: TournamentFormats.doubleElimination,
        participants: participants,
        seedingMethod: 'elo_based',
      );
      
      _validateBracket(bracket, TournamentFormats.doubleElimination, playerCount);
      
      final winnerRounds = bracket.rounds.where((r) => r.type == 'winner').length;
      final loserRounds = bracket.rounds.where((r) => r.type == 'loser').length;
      final grandFinal = bracket.rounds.where((r) => r.type == 'grand_final').length;
      
      print('   ✅ $playerCount players: $winnerRounds winner rounds, $loserRounds loser rounds, $grandFinal grand final');
      
    } catch (e) {
      print('   ❌ Error: $e');
    }
  }
}

/// Test Round Robin brackets
Future<void> testRoundRobin() async {
  print('\n🔄 TESTING ROUND ROBIN');
  print('-' * 50);
  
  final testCases = [6, 8, 10];
  
  for (final playerCount in testCases) {
    print('\n📊 Testing with $playerCount players:');
    
    final participants = _generateTestParticipants(playerCount);
    
    try {
      final bracket = await BracketGeneratorService.generateBracket(
        tournamentId: 'test_robin_$playerCount',
        format: TournamentFormats.roundRobin,
        participants: participants,
        seedingMethod: 'elo_based',
      );
      
      _validateBracket(bracket, TournamentFormats.roundRobin, playerCount);
      
      final totalMatches = bracket.rounds.fold<int>(0, (sum, round) => sum + round.matches.length);
      final expectedMatches = (playerCount * (playerCount - 1)) ~/ 2;
      
      print('   ✅ $playerCount players: ${bracket.rounds.length} rounds, $totalMatches matches (expected: $expectedMatches)');
      
      if (totalMatches == expectedMatches) {
        print('   ✅ Match count correct!');
      } else {
        print('   ⚠️  Match count mismatch!');
      }
      
    } catch (e) {
      print('   ❌ Error: $e');
    }
  }
}

/// Test Swiss System brackets
Future<void> testSwissSystem() async {
  print('\n🇨🇭 TESTING SWISS SYSTEM');
  print('-' * 50);
  
  final testCases = [16, 32];
  
  for (final playerCount in testCases) {
    print('\n📊 Testing with $playerCount players:');
    
    final participants = _generateTestParticipants(playerCount);
    
    try {
      final bracket = await BracketGeneratorService.generateBracket(
        tournamentId: 'test_swiss_$playerCount',
        format: TournamentFormats.swiss,
        participants: participants,
        seedingMethod: 'elo_based',
      );
      
      _validateBracket(bracket, TournamentFormats.swiss, playerCount);
      print('   ✅ $playerCount players: ${bracket.rounds.length} Swiss rounds generated');
      
      // Verify first round pairing (top vs bottom)
      final firstRound = bracket.rounds.first;
      print('   First round pairings:');
      for (final match in firstRound.matches) {
        final p1Seed = match.player1?.seed ?? 0;
        final p2Seed = match.player2?.seed ?? 0;
        print('     Match ${match.matchNumber}: Seed $p1Seed vs Seed $p2Seed');
      }
      
    } catch (e) {
      print('   ❌ Error: $e');
    }
  }
}

/// Test Parallel Groups brackets
Future<void> testParallelGroups() async {
  print('\n📊 TESTING PARALLEL GROUPS');
  print('-' * 50);
  
  final testCases = [
    {'players': 16, 'groupSize': 4},
    {'players': 24, 'groupSize': 6},
  ];
  
  for (final testCase in testCases) {
    final playerCount = testCase['players'] as int;
    final groupSize = testCase['groupSize'] as int;
    
    print('\n📊 Testing with $playerCount players, group size $groupSize:');
    
    final participants = _generateTestParticipants(playerCount);
    
    try {
      final bracket = await BracketGeneratorService.generateBracket(
        tournamentId: 'test_groups_$playerCount',
        format: TournamentFormats.parallelGroups,
        participants: participants,
        seedingMethod: 'elo_based',
        options: {'groupSize': groupSize, 'qualifiersPerGroup': 2},
      );
      
      _validateBracket(bracket, TournamentFormats.parallelGroups, playerCount);
      
      final groupStageRounds = bracket.rounds.where((r) => r.type == 'group').length;
      final playoffRounds = bracket.rounds.where((r) => r.type == 'playoff').length;
      final expectedGroups = (playerCount / groupSize).ceil();
      
      print('   ✅ $playerCount players: $expectedGroups groups, $groupStageRounds group rounds, $playoffRounds playoff rounds');
      
    } catch (e) {
      print('   ❌ Error: $e');
    }
  }
}

/// Generate test participants with ELO ratings
List<TournamentParticipant> _generateTestParticipants(int count) {
  final participants = <TournamentParticipant>[];
  final ranks = ['E+', 'E', 'F+', 'F', 'G+', 'G', 'H+', 'H', 'I+', 'I', 'K+', 'K'];
  
  for (int i = 0; i < count; i++) {
    final elo = 2000 - (i * 50); // Decreasing ELO for seeding
    final rank = ranks[i % ranks.length];
    
    participants.add(TournamentParticipant(
      id: 'player_${i + 1}',
      name: 'Player ${i + 1}',
      rank: rank,
      elo: elo,
      metadata: {'testPlayer': true},
    ));
  }
  
  return participants;
}

/// Validate generated bracket
void _validateBracket(TournamentBracket bracket, String expectedFormat, int playerCount) {
  assert(bracket.format == expectedFormat, 'Format mismatch');
  assert(bracket.participants.length == playerCount, 'Participant count mismatch');
  assert(bracket.rounds.isNotEmpty, 'No rounds generated');
  
  // Validate all matches have proper IDs
  for (final round in bracket.rounds) {
    assert(round.matches.isNotEmpty || round.metadata?['requiresPairing'] == true, 'Round has no matches');
    
    for (final match in round.matches) {
      assert(match.id.isNotEmpty, 'Match missing ID');
      assert(match.roundNumber == round.roundNumber, 'Round number mismatch');
    }
  }
}

/// Display bracket visualization
void displayBracketVisualization(TournamentBracket bracket) {
  print('\n🖼️  BRACKET VISUALIZATION');
  print('Tournament: ${bracket.tournamentId}');
  print('Format: ${bracket.format}');
  print('Participants: ${bracket.participants.length}');
  print('Structure: ${bracket.structure}');
  
  for (final round in bracket.rounds) {
    print('\n${round.name} (Round ${round.roundNumber}):');
    for (final match in round.matches) {
      final p1 = match.player1?.name ?? 'TBD';
      final p2 = match.player2?.name ?? 'TBD';
      final status = match.status.toUpperCase();
      print('  Match ${match.matchNumber}: $p1 vs $p2 [$status]');
    }
  }
}