// 🏆 SABO ARENA - Sabo Double Elimination DE32 Demo
// Demonstrates the Sabo Double Elimination DE32 bracket generation
// Shows complete Two-Group System structure with all 55 matches

import 'lib/services/bracket_generator_service.dart';
import 'lib/core/constants/tournament_constants.dart';

void main() async {
  print('🏆 SABO DOUBLE ELIMINATION DE32 BRACKET DEMO');
  print('=' * 60);
  
  await demonstrateSaboDE32Structure();
  await generateSampleSaboDE32Bracket();
  
  print('\n✅ Sabo DE32 Demo completed!');
}

Future<void> demonstrateSaboDE32Structure() async {
  print('\n📊 SABO DE32 STRUCTURE OVERVIEW');
  print('-' * 40);
  
  final format = TournamentFormats.formatDetails[TournamentFormats.saboDoubleElimination32]!;
  
  print('Format: ${format['name']} (${format['nameVi']})');
  print('Description: ${format['description']}');
  print('Players: ${format['minPlayers']} (fixed)');
  print('Total Matches: ${format['totalMatches']}');
  print('Group Count: ${format['groupCount']}');
  print('Players per Group: ${format['playersPerGroup']}');
  print('Qualifiers per Group: ${format['qualifiersPerGroup']}');
  print('');
  
  print('📋 Match Distribution:');
  print('  🏆 Group A: ${format['groupAMatches']} matches');
  print('    ├── Winners Bracket: 14 matches (8+4+2)');
  print('    ├── Losers Branch A: 7 matches (4+2+1)');
  print('    ├── Losers Branch B: 3 matches (2+1)');
  print('    └── Group Finals: 2 matches → 2 qualifiers');
  print('  🏆 Group B: ${format['groupBMatches']} matches');
  print('    ├── Winners Bracket: 14 matches (8+4+2)');
  print('    ├── Losers Branch A: 7 matches (4+2+1)');
  print('    ├── Losers Branch B: 3 matches (2+1)');
  print('    └── Group Finals: 2 matches → 2 qualifiers');
  print('  🏅 Cross-Bracket Finals: ${format['crossBracketMatches']} matches');
  print('    ├── Semifinals: 2 matches (4→2)');
  print('    └── Final: 1 match (2→1)');
  print('  ────────────────────────────────────');
  print('  📊 TOTAL: ${format['totalMatches']} matches');
}

Future<void> generateSampleSaboDE32Bracket() async {
  print('\n🎮 GENERATING SAMPLE SABO DE32 BRACKET');
  print('-' * 40);
  
  try {
    // Create 32 sample participants with ELO ratings
    final participants = _create32SamplePlayers();
    
    // Generate Sabo DE32 bracket
    final bracket = await BracketGeneratorService.generateBracket(
      tournamentId: 'demo_sabo_de32_001',
      format: TournamentFormats.saboDoubleElimination32,
      participants: participants,
      seedingMethod: 'elo_based',
    );
    
    print('✅ Bracket generated successfully!');
    print('Format: ${bracket.format}');
    print('Participants: ${bracket.participants.length}');
    print('Rounds: ${bracket.rounds.length}');
    print('Total Matches: ${_countTotalMatches(bracket)}');
    print('');
    
    // Display bracket structure
    _displayBracketStructure(bracket);
    
    // Display detailed rounds by group
    _displayDetailedRounds(bracket);
    
  } catch (error) {
    print('❌ Error generating bracket: $error');
  }
}

List<TournamentParticipant> _create32SamplePlayers() {
  final players = <TournamentParticipant>[];
  final names = [
    // Group A potential players (first 16)
    'Efren Reyes', 'Shane Van Boening', 'Joshua Filler', 'Jayson Shaw',
    'Francisco Sanchez-Ruiz', 'Albin Ouschan', 'Ko Pin-yi', 'Mika Immonen',
    'Darren Appleton', 'Alexander Kazakis', 'David Alcaide', 'Chang Jung-lin',
    'Mario He', 'Niels Feijen', 'Thorsten Hohmann', 'Ralf Souquet',
    // Group B potential players (next 16)
    'Earl Strickland', 'Johnny Archer', 'Corey Deuel', 'Dennis Orcollo',
    'Wu Jiaqing', 'Oliver Szolnoki', 'Eklent Kaci', 'Chris Melling',
    'Ruslan Chinakhov', 'Carlo Biado', 'Jung Lin Chang', 'Lee Vann Corteza',
    'Mieszko Fortunski', 'Maximilian Lechner', 'Tomasz Kaplan', 'Konrad Juszczyszyn'
  ];
  
  final eloRatings = [
    // Group A ELO ratings (descending)
    2100, 2050, 2000, 1950, 1900, 1850, 1800, 1750,
    1700, 1650, 1600, 1550, 1500, 1450, 1400, 1350,
    // Group B ELO ratings (descending)
    2080, 2030, 1980, 1930, 1880, 1830, 1780, 1730,
    1680, 1630, 1580, 1530, 1480, 1430, 1380, 1330
  ];
  
  for (int i = 0; i < 32; i++) {
    players.add(TournamentParticipant(
      id: 'player_${i + 1}',
      name: names[i],
      elo: eloRatings[i],
      seed: i + 1,
      rank: _getPlayerRank(eloRatings[i]),
      metadata: {
        'suggestedGroup': i < 16 ? 'A' : 'B',
        'globalSeed': i + 1,
      },
    ));
  }
  
  return players;
}

String _getPlayerRank(int elo) {
  if (elo >= 2000) return 'E+';
  if (elo >= 1800) return 'E';
  if (elo >= 1600) return 'D';
  if (elo >= 1400) return 'C';
  return 'B';
}

int _countTotalMatches(TournamentBracket bracket) {
  return bracket.rounds.fold(0, (total, round) => total + round.matches.length);
}

void _displayBracketStructure(TournamentBracket bracket) {
  print('🏗️ BRACKET STRUCTURE');
  print('-' * 30);
  
  final structure = bracket.structure;
  print('Type: ${structure['type']}');
  print('Total Matches: ${structure['totalMatches']}');
  print('Group A Matches: ${structure['groupAMatches']}');
  print('Group B Matches: ${structure['groupBMatches']}');
  print('Cross-Bracket Matches: ${structure['crossBracketMatches']}');
  print('Has Groups: ${structure['hasGroups']}');
  print('Group Count: ${structure['groupCount']}');
  print('Players per Group: ${structure['playersPerGroup']}');
  print('Qualifiers per Group: ${structure['qualifiersPerGroup']}');
}

void _displayDetailedRounds(TournamentBracket bracket) {
  print('\n📋 DETAILED ROUNDS BREAKDOWN');
  print('-' * 40);
  
  // Group rounds by type
  final groupARounds = <TournamentRound>[];
  final groupBRounds = <TournamentRound>[];
  final crossBracketRounds = <TournamentRound>[];
  
  for (final round in bracket.rounds) {
    final groupId = round.metadata?['groupId'];
    
    if (groupId == 'A') {
      groupARounds.add(round);
    } else if (groupId == 'B') {
      groupBRounds.add(round);
    } else if (round.type == 'cross_bracket') {
      crossBracketRounds.add(round);
    }
  }
  
  // Display Group A
  print('🏆 GROUP A (${groupARounds.length} rounds, ${_countRoundMatches(groupARounds)} matches)');
  _displayGroupRounds(groupARounds, 'A');
  
  // Display Group B
  print('\n🏆 GROUP B (${groupBRounds.length} rounds, ${_countRoundMatches(groupBRounds)} matches)');
  _displayGroupRounds(groupBRounds, 'B');
  
  // Display Cross-Bracket Finals
  print('\n🏅 CROSS-BRACKET FINALS (${crossBracketRounds.length} rounds, ${_countRoundMatches(crossBracketRounds)} matches)');
  for (final round in crossBracketRounds) {
    print('  Round ${round.roundNumber}: ${round.name} - ${round.matches.length} matches');
    for (final match in round.matches) {
      final matchId = match.metadata?['saboMatchId'] ?? match.id;
      final matchup = match.metadata?['matchup'] ?? 'TBD vs TBD';
      print('    $matchId: $matchup');
    }
  }
}

void _displayGroupRounds(List<TournamentRound> rounds, String groupId) {
  // Separate rounds by bracket type
  final winnerRounds = rounds.where((r) => r.type == 'winners').toList();
  final losersARounds = rounds.where((r) => r.type == 'losers_a').toList();
  final losersBRounds = rounds.where((r) => r.type == 'losers_b').toList();
  final groupFinalsRounds = rounds.where((r) => r.type == 'group_finals').toList();
  
  // Display Winners Bracket
  if (winnerRounds.isNotEmpty) {
    print('  🏆 Winners Bracket (${winnerRounds.length} rounds, ${_countRoundMatches(winnerRounds)} matches)');
    for (final round in winnerRounds) {
      print('    Round ${round.roundNumber}: ${round.name} - ${round.matches.length} matches');
    }
  }
  
  // Display Losers Branch A
  if (losersARounds.isNotEmpty) {
    print('  🥈 Losers Branch A (${losersARounds.length} rounds, ${_countRoundMatches(losersARounds)} matches)');
    for (final round in losersARounds) {
      print('    Round ${round.roundNumber}: ${round.name} - ${round.matches.length} matches');
    }
  }
  
  // Display Losers Branch B
  if (losersBRounds.isNotEmpty) {
    print('  🥉 Losers Branch B (${losersBRounds.length} rounds, ${_countRoundMatches(losersBRounds)} matches)');
    for (final round in losersBRounds) {
      print('    Round ${round.roundNumber}: ${round.name} - ${round.matches.length} matches');
    }
  }
  
  // Display Group Finals
  if (groupFinalsRounds.isNotEmpty) {
    print('  🏅 Group Finals (${groupFinalsRounds.length} rounds, ${_countRoundMatches(groupFinalsRounds)} matches)');
    for (final round in groupFinalsRounds) {
      print('    Round ${round.roundNumber}: ${round.name} - ${round.matches.length} matches');
      for (final match in round.matches) {
        final matchId = match.metadata?['saboMatchId'] ?? match.id;
        final matchup = match.metadata?['matchup'] ?? 'TBD vs TBD';
        final qualifierSlot = match.metadata?['qualifierSlot'] ?? '?';
        print('      $matchId: $matchup → Qualifier $qualifierSlot');
      }
    }
  }
}

int _countRoundMatches(List<TournamentRound> rounds) {
  return rounds.fold(0, (total, round) => total + round.matches.length);
}

void demonstrateDE32vsDE16Comparison() {
  print('\n🆚 DE32 vs DE16 COMPARISON');
  print('-' * 30);
  
  print('| Feature | DE16 | DE32 |');
  print('|---------|------|------|');
  print('| Players | 16 | 32 |');
  print('| Total Matches | 27 | 55 |');
  print('| Structure | Single bracket | Two-Group System |');
  print('| Winners Bracket | 14 matches | 28 matches (14×2) |');
  print('| Loser Branches | 2 branches | 4 branches (2×2) |');
  print('| Finals | SABO Finals (3) | Cross-Bracket (3) |');
  print('| Duration | 4-6 hours | 8-12 hours |');
  print('| Qualifiers | 4 to finals | 4 to cross-bracket |');
  print('| Parallel Play | No | Yes (2 groups) |');
  print('| Venue Req | 1 area | 2 areas (recommended) |');
}