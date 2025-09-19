// 🎯 SABO ARENA - Tournament Data Generator
// Handles match generation and tournament calculation logic

import 'dart:math';

class TournamentDataGenerator {
  /// Calculate rounds for Single Elimination format
  static List<Map<String, dynamic>> calculateSingleEliminationRounds(int playerCount) {
    final List<Map<String, dynamic>> rounds = [];
    int currentPlayerCount = playerCount;
    int roundNumber = 1;
    
    while (currentPlayerCount > 1) {
      String title;
      if (currentPlayerCount == 2) {
        title = 'Chung kết';
      } else if (currentPlayerCount == 4) {
        title = 'Bán kết';
      } else if (currentPlayerCount == 8) {
        title = 'Tứ kết';
      } else {
        title = 'Vòng $roundNumber';
      }
      
      final matchCount = currentPlayerCount ~/ 2;
      rounds.add({
        'title': title,
        'matches': generateSingleEliminationMatches(roundNumber, currentPlayerCount),
        'matchCount': matchCount,
      });
      
      currentPlayerCount = matchCount;
      roundNumber++;
    }
    
    return rounds;
  }

  /// Generate matches for a Single Elimination round
  static List<Map<String, String>> generateSingleEliminationMatches(int roundNumber, int playerCount) {
    final List<Map<String, String>> matches = [];
    final matchCount = playerCount ~/ 2;
    
    for (int i = 0; i < matchCount; i++) {
      final matchId = 'R${roundNumber}M${i + 1}';
      final player1Num = (i * 2) + 1;
      final player2Num = (i * 2) + 2;
      
      // Generate realistic scores for completed rounds
      final hasResult = roundNumber <= 2 || (roundNumber == 3 && i < 2);
      String score1 = '';
      String score2 = '';
      
      if (hasResult) {
        final isPlayer1Winner = (i + roundNumber) % 2 == 0;
        score1 = isPlayer1Winner ? '2' : ((i + roundNumber) % 3 == 0 ? '0' : '1');
        score2 = isPlayer1Winner ? ((i + roundNumber) % 3 == 0 ? '0' : '1') : '2';
      }
      
      matches.add({
        'matchId': matchId,
        'player1': 'Player $player1Num',
        'player2': 'Player $player2Num',
        'score1': score1,
        'score2': score2,
      });
    }
    
    return matches;
  }

  /// Generate Round Robin standings
  static List<Map<String, dynamic>> generateRoundRobinStandings(int playerCount) {
    final List<Map<String, dynamic>> standings = [];
    
    for (int i = 1; i <= playerCount; i++) {
      // Generate realistic standings data
      final baseWins = (playerCount - i).clamp(0, playerCount - 1);
      final wins = (baseWins + (i % 3)).clamp(0, playerCount - 1);
      final losses = (playerCount - 1) - wins;
      final points = wins * 3;
      
      standings.add({
        'rank': i,
        'name': 'Player $i',
        'wins': wins,
        'losses': losses,
        'points': points,
      });
    }
    
    // Sort by points descending
    standings.sort((a, b) => b['points'].compareTo(a['points']));
    
    // Update ranks after sorting
    for (int i = 0; i < standings.length; i++) {
      standings[i]['rank'] = i + 1;
    }
    
    return standings;
  }

  /// Generate Round Robin matches
  static List<Map<String, String>> generateRoundRobinMatches(int playerCount) {
    final List<Map<String, String>> matches = [];
    int matchCounter = 1;
    
    // Generate some sample matches based on selected player count
    final sampleMatchCount = (playerCount * 0.4).round().clamp(6, 12);
    
    for (int i = 0; i < sampleMatchCount; i++) {
      final player1Num = (i % playerCount) + 1;
      final player2Num = ((i + 1) % playerCount) + 1;
      
      if (player1Num != player2Num) {
        final isPlayer1Winner = i % 2 == 0;
        matches.add({
          'matchId': 'RR$matchCounter',
          'player1': 'Player $player1Num',
          'player2': 'Player $player2Num',
          'score1': isPlayer1Winner ? '2' : '1',
          'score2': isPlayer1Winner ? '1' : '2',
        });
        matchCounter++;
      }
    }
    
    return matches;
  }

  /// Generate Swiss System standings
  static List<Map<String, dynamic>> generateSwissStandings(int playerCount) {
    final List<Map<String, dynamic>> standings = [];
    
    for (int i = 1; i <= playerCount; i++) {
      // Generate realistic Swiss standings
      final basePoints = (playerCount - i) * 0.5;
      final points = (basePoints + (i % 4) * 0.5).clamp(0.0, (playerCount * 0.8));
      final tiebreak = 14.0 + (i % 5) * 1.0;
      
      standings.add({
        'rank': i,
        'name': 'Player $i',
        'points': points,
        'tiebreak': tiebreak,
      });
    }
    
    // Sort by points descending, then by tiebreak
    standings.sort((a, b) {
      final pointsComparison = b['points'].compareTo(a['points']);
      if (pointsComparison != 0) return pointsComparison;
      return b['tiebreak'].compareTo(a['tiebreak']);
    });
    
    // Update ranks after sorting
    for (int i = 0; i < standings.length; i++) {
      standings[i]['rank'] = i + 1;
    }
    
    return standings.take(8).toList(); // Show top 8 for display
  }

  /// Generate Swiss System round matches
  static List<Map<String, String>> generateSwissRoundMatches(int round, int playerCount) {
    // Generate different pairings for each round based on Swiss system logic
    final matches = <Map<String, String>>[];
    final displayPlayerCount = (playerCount / 2).round().clamp(4, 8);
    
    for (int i = 0; i < displayPlayerCount; i += 2) {
      final player1Num = ((i + round - 1) % playerCount) + 1;
      final player2Num = ((i + round) % playerCount) + 1;
      
      if (player1Num != player2Num) {
        matches.add({
          'matchId': 'S${round}M${(i ~/ 2) + 1}',
          'player1': 'Player $player1Num',
          'player2': 'Player $player2Num',
          'score1': round <= 3 ? ['2', '1', '0'][(i + round) % 3] : '',
          'score2': round <= 3 ? ['0', '2', '1'][(i + round) % 3] : '',
        });
      }
    }
    
    return matches;
  }

  // =============== DOUBLE ELIMINATION METHODS ===============

  /// Calculate Double Elimination rounds with Winners and Losers brackets
  static List<Map<String, dynamic>> calculateDoubleEliminationRounds(int playerCount) {
    final rounds = <Map<String, dynamic>>[];
    
    // Calculate winners bracket rounds
    final winnersRounds = calculateWinnersRounds(playerCount);
    rounds.addAll(winnersRounds);
    
    // Calculate losers bracket rounds
    final losersRounds = calculateLosersRounds(playerCount);
    rounds.addAll(losersRounds);
    
    // Add Grand Final
    final grandFinalRounds = calculateGrandFinalRounds();
    rounds.addAll(grandFinalRounds);
    
    return rounds;
  }

  /// Calculate Winners Bracket rounds
  static List<Map<String, dynamic>> calculateWinnersRounds(int playerCount) {
    final rounds = <Map<String, dynamic>>[];
    int currentPlayerCount = playerCount;
    int roundNumber = 1;
    
    // Winners bracket continues until 1 player remains
    while (currentPlayerCount > 1) {
      final matchCount = currentPlayerCount ~/ 2;
      final roundTitle = roundNumber == 1 
          ? 'Winners Round 1'
          : roundNumber == 2
              ? 'Winners Round 2' 
              : roundNumber == 3
                  ? 'Winners Semifinals'
                  : 'Winners Final';
      
      rounds.add({
        'title': roundTitle,
        'bracketType': 'winners',
        'roundNumber': roundNumber,
        'matchCount': matchCount,
        'matches': generateWinnersBracketMatches(roundNumber, matchCount, playerCount),
      });
      
      currentPlayerCount = matchCount;
      roundNumber++;
    }
    
    return rounds;
  }

  /// Calculate Losers Bracket rounds (more complex with elimination flow)
  static List<Map<String, dynamic>> calculateLosersRounds(int playerCount) {
    final rounds = <Map<String, dynamic>>[];
    final winnersRoundCount = (log(playerCount) / log(2)).ceil();
    
    int roundNumber = 1;
    int playersFromWinners = 0;
    int playersInLosers = 0;
    
    // Losers bracket has alternating pattern:
    // - Rounds where only losers bracket players play
    // - Rounds where winners bracket losers join
    
    for (int i = 1; i < winnersRoundCount * 2 - 1; i++) {
      final isWinnersDropRound = i % 2 == 1;
      
      if (isWinnersDropRound) {
        // Round where players from winners bracket drop down
        playersFromWinners = playerCount ~/ (1 << ((i + 1) ~/ 2));
        playersInLosers += playersFromWinners;
      } else {
        // Round where only losers bracket players compete
        playersInLosers = playersInLosers ~/ 2;
      }
      
      final matchCount = playersInLosers ~/ 2;
      
      if (matchCount > 0) {
        String roundTitle;
        if (i == (winnersRoundCount * 2 - 2)) {
          roundTitle = 'Losers Final';
        } else if (i >= (winnersRoundCount * 2 - 4)) {
          roundTitle = 'Losers Semifinals';
        } else {
          roundTitle = 'Losers Round $roundNumber';
        }
        
        rounds.add({
          'title': roundTitle,
          'bracketType': 'losers',
          'roundNumber': roundNumber,
          'matchCount': matchCount,
          'isWinnersDropRound': isWinnersDropRound,
          'matches': generateLosersBracketMatches(roundNumber, matchCount, isWinnersDropRound),
        });
        
        roundNumber++;
      }
    }
    
    return rounds;
  }

  /// Calculate Grand Final rounds
  static List<Map<String, dynamic>> calculateGrandFinalRounds() {
    return [
      {
        'title': 'Grand Final',
        'bracketType': 'grand_final',
        'roundNumber': 1,
        'matchCount': 1,
        'canReset': true,
        'matches': generateGrandFinalMatches(),
      },
      {
        'title': 'Grand Final Reset',
        'bracketType': 'grand_final_reset',
        'roundNumber': 2,
        'matchCount': 1,
        'isConditional': true,
        'matches': generateGrandFinalResetMatches(),
      },
    ];
  }

  /// Generate Winners Bracket matches
  static List<Map<String, String>> generateWinnersBracketMatches(int round, int matchCount, int totalPlayers) {
    final matches = <Map<String, String>>[];
    
    for (int i = 0; i < matchCount; i++) {
      String player1, player2;
      String score1 = '', score2 = '';
      
      if (round == 1) {
        // First round: actual players
        final player1Num = (i * 2) + 1;
        final player2Num = (i * 2) + 2;
        player1 = 'Player $player1Num';
        player2 = 'Player $player2Num';
        
        // Add some demo results for completed matches
        if (i < matchCount - 1) {
          score1 = ['2', '2', '1', '2'][i % 4];
          score2 = ['0', '1', '2', '1'][i % 4];
        }
      } else {
        // Later rounds: winners from previous rounds
        player1 = 'Winner WB${round-1}-${(i*2)+1}';
        player2 = 'Winner WB${round-1}-${(i*2)+2}';
        
        // Add some demo results
        if (round <= 2) {
          score1 = ['2', '1', '2'][i % 3];
          score2 = ['1', '2', '0'][i % 3];
        }
      }
      
      matches.add({
        'matchId': 'WB${round}M${i + 1}',
        'player1': player1,
        'player2': player2,
        'score1': score1,
        'score2': score2,
      });
    }
    
    return matches;
  }

  /// Generate Losers Bracket matches
  static List<Map<String, String>> generateLosersBracketMatches(int round, int matchCount, bool isWinnersDropRound) {
    final matches = <Map<String, String>>[];
    
    for (int i = 0; i < matchCount; i++) {
      String player1, player2;
      String score1 = '', score2 = '';
      
      if (isWinnersDropRound) {
        // Mixed round: some from losers bracket, some from winners bracket
        player1 = 'Loser WB${(round + 1) ~/ 2}-${(i*2)+1}';
        player2 = round == 1 ? 'Loser WB1-${(i*2)+2}' : 'Winner LB${round-1}-${i+1}';
      } else {
        // Pure losers bracket round
        player1 = 'Winner LB${round-1}-${(i*2)+1}';
        player2 = 'Winner LB${round-1}-${(i*2)+2}';
      }
      
      // Add some demo results for early rounds
      if (round <= 3) {
        score1 = ['2', '1', '2', '0'][i % 4];
        score2 = ['0', '2', '1', '2'][i % 4];
      }
      
      matches.add({
        'matchId': 'LB${round}M${i + 1}',
        'player1': player1,
        'player2': player2,
        'score1': score1,
        'score2': score2,
      });
    }
    
    return matches;
  }

  /// Generate Grand Final matches
  static List<Map<String, String>> generateGrandFinalMatches() {
    return [
      {
        'matchId': 'GF1',
        'player1': 'Winners Bracket Champion',
        'player2': 'Losers Bracket Champion',
        'score1': '2',
        'score2': '1',
      },
    ];
  }

  /// Generate Grand Final Reset matches (if losers bracket player wins first GF)
  static List<Map<String, String>> generateGrandFinalResetMatches() {
    return [
      {
        'matchId': 'GF2',
        'player1': 'Winners Bracket Champion',
        'player2': 'Losers Bracket Champion',
        'score1': '',
        'score2': '',
      },
    ];
  }
}