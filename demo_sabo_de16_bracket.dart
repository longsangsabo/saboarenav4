// 🏆 SABO ARENA - Sabo Double Elimination DE16 Demo
// Demonstrates the Sabo Double Elimination bracket generation
// Shows complete bracket structure with all 27 matches

import 'lib/services/bracket_generator_service.dart';
import 'lib/core/constants/tournament_constants.dart';

void main() async {
  print('🏆 SABO DOUBLE ELIMINATION DE16 BRACKET DEMO');
  print('=' * 60);
  
  await demonstrateSaboDE16Structure();
  await generateSampleSaboDE16Bracket();
  
  print('\n✅ Sabo DE16 Demo completed!');
}

Future<void> demonstrateSaboDE16Structure() async {
  print('\n📊 SABO DE16 STRUCTURE OVERVIEW');
  print('-' * 40);
  
  final format = TournamentFormats.formatDetails[TournamentFormats.saboDoubleElimination]!;
  
  print('Format: ${format['name']} (${format['nameVi']})');
  print('Description: ${format['description']}');
  print('Players: ${format['minPlayers']} (fixed)');
  print('Total Matches: ${format['totalMatches']}');
  print('');
  
  print('📋 Match Distribution:');
  print('  🏆 Winners Bracket: ${format['winnersMatches']} matches (8+4+2)');
  print('  🥈 Losers Branch A: ${format['losersAMatches']} matches (4+2+1)');
  print('  🥉 Losers Branch B: ${format['losersBMatches']} matches (2+1)');
  print('  🏅 SABO Finals: ${format['finalsMatches']} matches (2 semifinals + 1 final)');
  print('  ────────────────────────────────────');
  print('  📊 TOTAL: ${format['totalMatches']} matches');
}

Future<void> generateSampleSaboDE16Bracket() async {
  print('\n🎮 GENERATING SAMPLE SABO DE16 BRACKET');
  print('-' * 40);
  
  try {
    // Create 16 sample participants with ELO ratings
    final participants = _create16SamplePlayers();
    
    // Generate Sabo DE16 bracket
    final bracket = await BracketGeneratorService.generateBracket(
      tournamentId: 'demo_sabo_de16_001',
      format: TournamentFormats.saboDoubleElimination,
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
    
    // Display detailed rounds
    _displayDetailedRounds(bracket);
    
  } catch (error) {
    print('❌ Error generating bracket: $error');
  }
}

List<TournamentParticipant> _create16SamplePlayers() {
  final players = <TournamentParticipant>[];
  final names = [
    'Efren Reyes', 'Shane Van Boening', 'Joshua Filler', 'Jayson Shaw',
    'Francisco Sanchez-Ruiz', 'Albin Ouschan', 'Ko Pin-yi', 'Mika Immonen',
    'Darren Appleton', 'Alexander Kazakis', 'David Alcaide', 'Chang Jung-lin',
    'Mario He', 'Niels Feijen', 'Thorsten Hohmann', 'Ralf Souquet'
  ];
  
  final eloRatings = [2100, 2050, 2000, 1950, 1900, 1850, 1800, 1750,
                     1700, 1650, 1600, 1550, 1500, 1450, 1400, 1350];
  
  for (int i = 0; i < 16; i++) {
    players.add(TournamentParticipant(
      id: 'player_${i + 1}',
      name: names[i],
      elo: eloRatings[i],
      seed: i + 1,
      rank: _getPlayerRank(eloRatings[i]),
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
  print('Winners Matches: ${structure['winnersMatches']}');
  print('Losers A Matches: ${structure['losersAMatches']}');  
  print('Losers B Matches: ${structure['losersBMatches']}');
  print('Finals Matches: ${structure['finalsMatches']}');
  print('Has Loser Branches: ${structure['hasLosersBranches']}');
  print('Has Sabo Finals: ${structure['hasSaboFinals']}');
}

void _displayDetailedRounds(TournamentBracket bracket) {
  print('\n📋 DETAILED ROUNDS BREAKDOWN');
  print('-' * 40);
  
  // Group rounds by bracket type
  final winnerRounds = <TournamentRound>[];
  final losersARounds = <TournamentRound>[];
  final losersBRounds = <TournamentRound>[];
  final finalsRounds = <TournamentRound>[];
  
  for (final round in bracket.rounds) {
    if (round.type == 'winners') {
      winnerRounds.add(round);
    } else if (round.type == 'losers_a') {
      losersARounds.add(round);
    } else if (round.type == 'losers_b') {
      losersBRounds.add(round);
    } else if (round.type == 'sabo_finals') {
      finalsRounds.add(round);
    }
  }
  
  // Display Winners Bracket
  print('🏆 WINNERS BRACKET (${winnerRounds.length} rounds, ${_countRoundMatches(winnerRounds)} matches)');
  for (final round in winnerRounds) {
    print('  Round ${round.roundNumber}: ${round.name} - ${round.matches.length} matches');
    _displaySampleMatches(round, 2); // Show first 2 matches as sample
  }
  
  // Display Losers Branch A
  print('\n🥈 LOSERS BRANCH A (${losersARounds.length} rounds, ${_countRoundMatches(losersARounds)} matches)');
  for (final round in losersARounds) {
    print('  Round ${round.roundNumber}: ${round.name} - ${round.matches.length} matches');
  }
  
  // Display Losers Branch B
  print('\n🥉 LOSERS BRANCH B (${losersBRounds.length} rounds, ${_countRoundMatches(losersBRounds)} matches)');
  for (final round in losersBRounds) {
    print('  Round ${round.roundNumber}: ${round.name} - ${round.matches.length} matches');
  }
  
  // Display SABO Finals
  print('\n🏅 SABO FINALS (${finalsRounds.length} rounds, ${_countRoundMatches(finalsRounds)} matches)');
  for (final round in finalsRounds) {
    print('  Round ${round.roundNumber}: ${round.name} - ${round.matches.length} matches');
    for (final match in round.matches) {
      final matchId = match.metadata?['saboMatchId'] ?? match.id;
      final matchup = match.metadata?['matchup'] ?? 'TBD vs TBD';
      print('    $matchId: $matchup');
    }
  }
}

void _displaySampleMatches(TournamentRound round, int sampleCount) {
  final matchesToShow = round.matches.take(sampleCount);
  for (final match in matchesToShow) {
    final matchId = match.metadata?['saboMatchId'] ?? match.id;
    final player1Name = match.player1?.name ?? 'TBD';
    final player2Name = match.player2?.name ?? 'TBD';
    final seedInfo = match.metadata?['seedMatch'] ?? '';
    
    if (seedInfo.isNotEmpty) {
      print('    $matchId: $player1Name vs $player2Name ($seedInfo)');
    } else {
      print('    $matchId: $player1Name vs $player2Name');
    }
  }
  if (round.matches.length > sampleCount) {
    print('    ... and ${round.matches.length - sampleCount} more matches');
  }
}

int _countRoundMatches(List<TournamentRound> rounds) {
  return rounds.fold(0, (total, round) => total + round.matches.length);
}