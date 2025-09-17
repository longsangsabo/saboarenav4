// 🏆 SABO ARENA - Tournament Bracket Generator Service
// Generates tournament brackets for all supported formats
// Handles bracket visualization and match progression logic

import '../core/constants/tournament_constants.dart';

/// Tournament participant data
class TournamentParticipant {
  final String id;
  final String name;
  final String? rank;
  final int? elo;
  final int? seed;
  final Map<String, dynamic>? metadata;

  const TournamentParticipant({
    required this.id,
    required this.name,
    this.rank,
    this.elo,
    this.seed,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'rank': rank,
    'elo': elo,
    'seed': seed,
    'metadata': metadata,
  };
}

/// Tournament match representation
class TournamentMatch {
  final String id;
  final String roundId;
  final int roundNumber;
  final int matchNumber;
  final TournamentParticipant? player1;
  final TournamentParticipant? player2;
  final TournamentParticipant? winner;
  final String status; // 'pending', 'in_progress', 'completed', 'bye'
  final Map<String, dynamic>? result;
  final DateTime? scheduledTime;
  final Map<String, dynamic>? metadata;

  const TournamentMatch({
    required this.id,
    required this.roundId,
    required this.roundNumber,
    required this.matchNumber,
    this.player1,
    this.player2,
    this.winner,
    this.status = 'pending',
    this.result,
    this.scheduledTime,
    this.metadata,
  });

  /// Check if this is a bye match (only one player)
  bool get isBye => player1 != null && player2 == null;
  
  /// Check if match is ready to be played
  bool get isReady => player1 != null && player2 != null;

  Map<String, dynamic> toJson() => {
    'id': id,
    'roundId': roundId,
    'roundNumber': roundNumber,
    'matchNumber': matchNumber,
    'player1': player1?.toJson(),
    'player2': player2?.toJson(),
    'winner': winner?.toJson(),
    'status': status,
    'result': result,
    'scheduledTime': scheduledTime?.toIso8601String(),
    'metadata': metadata,
  };
}

/// Tournament round representation
class TournamentRound {
  final String id;
  final int roundNumber;
  final String name;
  final String type; // 'winner', 'loser', 'group', 'swiss', 'final'
  final List<TournamentMatch> matches;
  final Map<String, dynamic>? metadata;

  const TournamentRound({
    required this.id,
    required this.roundNumber,
    required this.name,
    required this.type,
    required this.matches,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'roundNumber': roundNumber,
    'name': name,
    'type': type,
    'matches': matches.map((m) => m.toJson()).toList(),
    'metadata': metadata,
  };
}

/// Complete tournament bracket structure
class TournamentBracket {
  final String tournamentId;
  final String format;
  final List<TournamentParticipant> participants;
  final List<TournamentRound> rounds;
  final Map<String, dynamic> structure;
  final Map<String, dynamic>? metadata;

  const TournamentBracket({
    required this.tournamentId,
    required this.format,
    required this.participants,
    required this.rounds,
    required this.structure,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'tournamentId': tournamentId,
    'format': format,
    'participants': participants.map((p) => p.toJson()).toList(),
    'rounds': rounds.map((r) => r.toJson()).toList(),
    'structure': structure,
    'metadata': metadata,
  };
}

/// Main bracket generator service
class BracketGeneratorService {
  static const String _tag = 'BracketGeneratorService';

  /// Generate complete tournament bracket based on format
  static Future<TournamentBracket> generateBracket({
    required String tournamentId,
    required String format,
    required List<TournamentParticipant> participants,
    String seedingMethod = 'elo_based',
    Map<String, dynamic>? options,
  }) async {
    print('$_tag: Generating bracket for $format with ${participants.length} participants');

    // Validate format and participants
    _validateBracketGeneration(format, participants);

    // Seed participants
    final seededParticipants = await _seedParticipants(
      participants, 
      seedingMethod, 
      options
    );

    // Generate bracket based on format
    switch (format) {
      case TournamentFormats.singleElimination:
        return await _generateSingleEliminationBracket(
          tournamentId, participants: seededParticipants, options: options
        );
      
      case TournamentFormats.doubleElimination:
        return await _generateDoubleEliminationBracket(
          tournamentId, participants: seededParticipants, options: options
        );
      
      case TournamentFormats.roundRobin:
        return await _generateRoundRobinBracket(
          tournamentId, participants: seededParticipants, options: options
        );
      
      case TournamentFormats.swiss:
        return await _generateSwissBracket(
          tournamentId, participants: seededParticipants, options: options
        );
      
      case TournamentFormats.parallelGroups:
        return await _generateParallelGroupsBracket(
          tournamentId, participants: seededParticipants, options: options
        );
      
      default:
        throw Exception('Unsupported tournament format: $format');
    }
  }

  /// Validate bracket generation parameters
  static void _validateBracketGeneration(String format, List<TournamentParticipant> participants) {
    final formatDetails = TournamentFormats.formatDetails[format];
    if (formatDetails == null) {
      throw Exception('Unknown tournament format: $format');
    }

    final minPlayers = formatDetails['minPlayers'] as int;
    final maxPlayers = formatDetails['maxPlayers'] as int;
    final playerCount = participants.length;

    if (playerCount < minPlayers) {
      throw Exception('Not enough players for $format. Minimum: $minPlayers, Got: $playerCount');
    }

    if (playerCount > maxPlayers) {
      throw Exception('Too many players for $format. Maximum: $maxPlayers, Got: $playerCount');
    }

    // Additional format-specific validations
    if (format == TournamentFormats.singleElimination || format == TournamentFormats.doubleElimination) {
      // For elimination tournaments, check if we need byes
      final powerOfTwo = _nearestPowerOfTwo(playerCount);
      if (powerOfTwo != playerCount) {
        print('$_tag: Will generate ${powerOfTwo - playerCount} byes for $format');
      }
    }
  }

  /// Seed participants based on method
  static Future<List<TournamentParticipant>> _seedParticipants(
    List<TournamentParticipant> participants,
    String seedingMethod,
    Map<String, dynamic>? options,
  ) async {
    print('$_tag: Seeding participants using $seedingMethod method');

    switch (seedingMethod) {
      case 'elo_based':
        return _seedByElo(participants);
      
      case 'rank_based':
        return _seedByRank(participants);
      
      case 'random':
        return _seedRandomly(participants);
      
      case 'manual':
        return _seedManually(participants, options?['manual_seeds']);
      
      default:
        return _seedByElo(participants); // Default to ELO
    }
  }

  /// Seed by ELO rating (highest first)
  static List<TournamentParticipant> _seedByElo(List<TournamentParticipant> participants) {
    final seeded = List<TournamentParticipant>.from(participants);
    seeded.sort((a, b) => (b.elo ?? 1200).compareTo(a.elo ?? 1200));
    
    // Assign seed numbers
    final seededWithNumbers = <TournamentParticipant>[];
    for (int i = 0; i < seeded.length; i++) {
      seededWithNumbers.add(TournamentParticipant(
        id: seeded[i].id,
        name: seeded[i].name,
        rank: seeded[i].rank,
        elo: seeded[i].elo,
        seed: i + 1,
        metadata: seeded[i].metadata,
      ));
    }
    
    return seededWithNumbers;
  }

  /// Seed by rank (E+ → K)
  static List<TournamentParticipant> _seedByRank(List<TournamentParticipant> participants) {
    final rankOrder = ['E+', 'E', 'F+', 'F', 'G+', 'G', 'H+', 'H', 'I+', 'I', 'K+', 'K'];
    
    final seeded = List<TournamentParticipant>.from(participants);
    seeded.sort((a, b) {
      final aIndex = rankOrder.indexOf(a.rank ?? 'K');
      final bIndex = rankOrder.indexOf(b.rank ?? 'K');
      return aIndex.compareTo(bIndex);
    });

    final seededWithNumbers = <TournamentParticipant>[];
    for (int i = 0; i < seeded.length; i++) {
      seededWithNumbers.add(TournamentParticipant(
        id: seeded[i].id,
        name: seeded[i].name,
        rank: seeded[i].rank,
        elo: seeded[i].elo,
        seed: i + 1,
        metadata: seeded[i].metadata,
      ));
    }
    
    return seededWithNumbers;
  }

  /// Random seeding
  static List<TournamentParticipant> _seedRandomly(List<TournamentParticipant> participants) {
    final seeded = List<TournamentParticipant>.from(participants);
    seeded.shuffle();

    final seededWithNumbers = <TournamentParticipant>[];
    for (int i = 0; i < seeded.length; i++) {
      seededWithNumbers.add(TournamentParticipant(
        id: seeded[i].id,
        name: seeded[i].name,
        rank: seeded[i].rank,
        elo: seeded[i].elo,
        seed: i + 1,
        metadata: seeded[i].metadata,
      ));
    }
    
    return seededWithNumbers;
  }

  /// Manual seeding with provided order
  static List<TournamentParticipant> _seedManually(
    List<TournamentParticipant> participants,
    List<String>? seedOrder,
  ) {
    if (seedOrder == null || seedOrder.length != participants.length) {
      throw Exception('Manual seeding requires seed order for all participants');
    }

    final seeded = <TournamentParticipant>[];
    for (int i = 0; i < seedOrder.length; i++) {
      final participant = participants.firstWhere((p) => p.id == seedOrder[i]);
      seeded.add(TournamentParticipant(
        id: participant.id,
        name: participant.name,
        rank: participant.rank,
        elo: participant.elo,
        seed: i + 1,
        metadata: participant.metadata,
      ));
    }
    
    return seeded;
  }

  /// Find nearest power of 2 greater than or equal to n
  static int _nearestPowerOfTwo(int n) {
    if (n <= 1) return 2;
    int power = 1;
    while (power < n) {
      power *= 2;
    }
    return power;
  }

  /// Generate unique match ID
  static String _generateMatchId(String tournamentId, int round, int match) {
    return '${tournamentId}_R${round}_M${match}';
  }

  /// Generate unique round ID
  static String _generateRoundId(String tournamentId, int round, [String? type]) {
    final typePrefix = type != null ? '${type}_' : '';
    return '${tournamentId}_${typePrefix}R${round}';
  }

  /// Get seeding position for single elimination bracket
  static int _getSingleEliminationPosition(int seed, int bracketSize) {
    // Standard tournament seeding algorithm
    // 1 vs 16 = positions 0,31 | 2 vs 15 = positions 1,30, etc.
    
    if (seed <= bracketSize ~/ 2) {
      return seed - 1;
    } else {
      return bracketSize - (seed - bracketSize ~/ 2);
    }
  }

  /// Get match status based on participants
  static String _getMatchStatus(TournamentParticipant? player1, TournamentParticipant? player2) {
    if (player1 == null && player2 == null) {
      return 'pending';
    } else if (player1 == null || player2 == null) {
      return 'bye';
    } else {
      return 'pending';
    }
  }

  /// Get bye winner if applicable
  static TournamentParticipant? _getByeWinner(TournamentParticipant? player1, TournamentParticipant? player2) {
    if (player1 != null && player2 == null) {
      return player1;
    } else if (player1 == null && player2 != null) {
      return player2;
    }
    return null;
  }

  /// Generate round name based on position and total rounds
  static String _getRoundName(int roundNumber, int totalRounds) {
    final remaining = totalRounds - roundNumber + 1;
    
    switch (remaining) {
      case 1:
        return 'Chung kết'; // Final
      case 2:
        return 'Bán kết'; // Semi-final
      case 3:
        return 'Tứ kết'; // Quarter-final
      case 4:
        return 'Vòng 16'; // Round of 16
      case 5:
        return 'Vòng 32'; // Round of 32
      default:
        return 'Vòng ${roundNumber}'; // Round N
    }
  }

  // Format-specific bracket generation methods will be implemented next...
  
  static Future<TournamentBracket> _generateSingleEliminationBracket(
    String tournamentId, {
    required List<TournamentParticipant> participants,
    Map<String, dynamic>? options,
  }) async {
    print('$_tag: Generating single elimination bracket');
    
    final bracketSize = _nearestPowerOfTwo(participants.length);
    final byeCount = bracketSize - participants.length;
    final rounds = <TournamentRound>[];
    
    print('$_tag: Bracket size: $bracketSize, Byes needed: $byeCount');
    
    // Calculate number of rounds
    int totalRounds = 0;
    int tempSize = bracketSize;
    while (tempSize > 1) {
      totalRounds++;
      tempSize ~/= 2;
    }
    
    // Generate first round with seeded participants and byes
    final firstRoundMatches = <TournamentMatch>[];
    final matchesInFirstRound = bracketSize ~/ 2;
    
    // Standard single elimination seeding: 1 vs 16, 2 vs 15, etc.
    final seededPositions = <TournamentParticipant?>[];
    for (int i = 0; i < bracketSize; i++) {
      seededPositions.add(null);
    }
    
    // Place seeded participants
    for (int i = 0; i < participants.length; i++) {
      final seed = participants[i].seed ?? (i + 1);
      final position = _getSingleEliminationPosition(seed, bracketSize);
      seededPositions[position] = participants[i];
    }
    
    // Create first round matches
    for (int i = 0; i < matchesInFirstRound; i++) {
      final player1 = seededPositions[i * 2];
      final player2 = seededPositions[i * 2 + 1];
      
      final match = TournamentMatch(
        id: _generateMatchId(tournamentId, 1, i + 1),
        roundId: _generateRoundId(tournamentId, 1),
        roundNumber: 1,
        matchNumber: i + 1,
        player1: player1,
        player2: player2,
        status: _getMatchStatus(player1, player2),
        winner: _getByeWinner(player1, player2),
      );
      
      firstRoundMatches.add(match);
    }
    
    rounds.add(TournamentRound(
      id: _generateRoundId(tournamentId, 1),
      roundNumber: 1,
      name: _getRoundName(1, totalRounds),
      type: 'winner',
      matches: firstRoundMatches,
    ));
    
    // Generate subsequent rounds (empty matches to be filled as tournament progresses)
    for (int round = 2; round <= totalRounds; round++) {
      final matchesInRound = bracketSize ~/ (1 << round); // 2^round
      final roundMatches = <TournamentMatch>[];
      
      for (int i = 0; i < matchesInRound; i++) {
        final match = TournamentMatch(
          id: _generateMatchId(tournamentId, round, i + 1),
          roundId: _generateRoundId(tournamentId, round),
          roundNumber: round,
          matchNumber: i + 1,
          status: 'pending',
        );
        roundMatches.add(match);
      }
      
      rounds.add(TournamentRound(
        id: _generateRoundId(tournamentId, round),
        roundNumber: round,
        name: _getRoundName(round, totalRounds),
        type: 'winner',
        matches: roundMatches,
      ));
    }
    
    return TournamentBracket(
      tournamentId: tournamentId,
      format: TournamentFormats.singleElimination,
      participants: participants,
      rounds: rounds,
      structure: {
        'type': 'single_elimination',
        'bracketSize': bracketSize,
        'totalRounds': totalRounds,
        'byeCount': byeCount,
        'seedingMethod': 'standard',
      },
    );
  }

  static Future<TournamentBracket> _generateDoubleEliminationBracket(
    String tournamentId, {
    required List<TournamentParticipant> participants,
    Map<String, dynamic>? options,
  }) async {
    print('$_tag: Generating double elimination bracket');
    
    final bracketSize = _nearestPowerOfTwo(participants.length);
    final byeCount = bracketSize - participants.length;
    final rounds = <TournamentRound>[];
    
    // Calculate rounds for winner and loser brackets
    int winnerRounds = 0;
    int tempSize = bracketSize;
    while (tempSize > 1) {
      winnerRounds++;
      tempSize ~/= 2;
    }
    
    // Loser bracket has approximately 2x rounds - 1
    final loserRounds = (winnerRounds * 2) - 1;
    
    print('$_tag: Winner bracket rounds: $winnerRounds, Loser bracket rounds: $loserRounds');
    
    // Generate Winner Bracket (same as single elimination)
    final winnerBracket = await _generateWinnerBracket(
      tournamentId, participants, bracketSize, winnerRounds
    );
    rounds.addAll(winnerBracket);
    
    // Generate Loser Bracket (elimination rounds for losers)
    final loserBracket = await _generateLoserBracket(
      tournamentId, bracketSize, loserRounds, winnerRounds
    );
    rounds.addAll(loserBracket);
    
    // Add Grand Final (winner of winner bracket vs winner of loser bracket)
    final grandFinal = TournamentMatch(
      id: _generateMatchId(tournamentId, 999, 1), // Special round number
      roundId: _generateRoundId(tournamentId, 999, 'grand_final'),
      roundNumber: 999,
      matchNumber: 1,
      status: 'pending',
      metadata: {'isGrandFinal': true},
    );
    
    rounds.add(TournamentRound(
      id: _generateRoundId(tournamentId, 999, 'grand_final'),
      roundNumber: 999,
      name: 'Chung kết lớn',
      type: 'grand_final',
      matches: [grandFinal],
      metadata: {'isGrandFinal': true},
    ));
    
    return TournamentBracket(
      tournamentId: tournamentId,
      format: TournamentFormats.doubleElimination,
      participants: participants,
      rounds: rounds,
      structure: {
        'type': 'double_elimination',
        'bracketSize': bracketSize,
        'winnerRounds': winnerRounds,
        'loserRounds': loserRounds,
        'byeCount': byeCount,
        'hasGrandFinal': true,
      },
    );
  }

  /// Generate winner bracket for double elimination
  static Future<List<TournamentRound>> _generateWinnerBracket(
    String tournamentId,
    List<TournamentParticipant> participants,
    int bracketSize,
    int totalRounds,
  ) async {
    final rounds = <TournamentRound>[];
    
    // Same logic as single elimination but with 'winner' type
    final seededPositions = <TournamentParticipant?>[];
    for (int i = 0; i < bracketSize; i++) {
      seededPositions.add(null);
    }
    
    // Place seeded participants
    for (int i = 0; i < participants.length; i++) {
      final seed = participants[i].seed ?? (i + 1);
      final position = _getSingleEliminationPosition(seed, bracketSize);
      seededPositions[position] = participants[i];
    }
    
    // Generate all winner bracket rounds
    for (int round = 1; round <= totalRounds; round++) {
      final matchesInRound = bracketSize ~/ (1 << round);
      final roundMatches = <TournamentMatch>[];
      
      if (round == 1) {
        // First round with actual participants
        for (int i = 0; i < matchesInRound; i++) {
          final player1 = seededPositions[i * 2];
          final player2 = seededPositions[i * 2 + 1];
          
          final match = TournamentMatch(
            id: _generateMatchId(tournamentId, round, i + 1),
            roundId: _generateRoundId(tournamentId, round, 'winner'),
            roundNumber: round,
            matchNumber: i + 1,
            player1: player1,
            player2: player2,
            status: _getMatchStatus(player1, player2),
            winner: _getByeWinner(player1, player2),
            metadata: {'bracketType': 'winner'},
          );
          roundMatches.add(match);
        }
      } else {
        // Subsequent rounds (empty matches)
        for (int i = 0; i < matchesInRound; i++) {
          final match = TournamentMatch(
            id: _generateMatchId(tournamentId, round, i + 1),
            roundId: _generateRoundId(tournamentId, round, 'winner'),
            roundNumber: round,
            matchNumber: i + 1,
            status: 'pending',
            metadata: {'bracketType': 'winner'},
          );
          roundMatches.add(match);
        }
      }
      
      rounds.add(TournamentRound(
        id: _generateRoundId(tournamentId, round, 'winner'),
        roundNumber: round,
        name: 'WB ${_getRoundName(round, totalRounds)}',
        type: 'winner',
        matches: roundMatches,
        metadata: {'bracketType': 'winner'},
      ));
    }
    
    return rounds;
  }

  /// Generate loser bracket for double elimination
  static Future<List<TournamentRound>> _generateLoserBracket(
    String tournamentId,
    int bracketSize,
    int loserRounds,
    int winnerRounds,
  ) async {
    final rounds = <TournamentRound>[];
    
    // Loser bracket has complex structure
    // Round 1: First round losers
    // Round 2: Round 1 winners vs Second round losers
    // And so on...
    
    for (int round = 1; round <= loserRounds; round++) {
      // Calculate matches in this loser round
      int matchesInRound;
      if (round == 1) {
        matchesInRound = bracketSize ~/ 4; // Half of first winner round
      } else if (round % 2 == 0) {
        // Even rounds: winners from previous loser round vs new dropdowns
        matchesInRound = bracketSize ~/ (1 << ((round ~/ 2) + 2));
      } else {
        // Odd rounds: just advance loser bracket winners
        matchesInRound = bracketSize ~/ (1 << ((round + 1) ~/ 2 + 2));
      }
      
      if (matchesInRound < 1) matchesInRound = 1;
      
      final roundMatches = <TournamentMatch>[];
      for (int i = 0; i < matchesInRound; i++) {
        final match = TournamentMatch(
          id: _generateMatchId(tournamentId, round + 100, i + 1), // Offset to avoid collision
          roundId: _generateRoundId(tournamentId, round + 100, 'loser'),
          roundNumber: round + 100, // Offset for loser bracket
          matchNumber: i + 1,
          status: 'pending',
          metadata: {
            'bracketType': 'loser',
            'loserRoundNumber': round,
          },
        );
        roundMatches.add(match);
      }
      
      rounds.add(TournamentRound(
        id: _generateRoundId(tournamentId, round + 100, 'loser'),
        roundNumber: round + 100,
        name: 'LB Vòng $round',
        type: 'loser',
        matches: roundMatches,
        metadata: {
          'bracketType': 'loser',
          'loserRoundNumber': round,
        },
      ));
    }
    
    return rounds;
  }

  static Future<TournamentBracket> _generateRoundRobinBracket(
    String tournamentId, {
    required List<TournamentParticipant> participants,
    Map<String, dynamic>? options,
  }) async {
    print('$_tag: Generating round robin bracket');
    
    final playerCount = participants.length;
    final rounds = <TournamentRound>[];
    
    // In round robin, each player plays every other player once
    // Total matches = n(n-1)/2
    // Total rounds = n-1 (if even players) or n (if odd players)
    
    final isEven = playerCount % 2 == 0;
    final totalRounds = isEven ? playerCount - 1 : playerCount;
    final matchesPerRound = playerCount ~/ 2;
    
    print('$_tag: $playerCount players, $totalRounds rounds, $matchesPerRound matches per round');
    
    // Use circle method for round robin scheduling
    final schedule = _generateRoundRobinSchedule(participants);
    
    for (int round = 1; round <= totalRounds; round++) {
      final roundMatches = <TournamentMatch>[];
      final roundSchedule = schedule[round - 1];
      
      for (int i = 0; i < roundSchedule.length; i++) {
        final pair = roundSchedule[i];
        if (pair.length == 2) {
          final match = TournamentMatch(
            id: _generateMatchId(tournamentId, round, i + 1),
            roundId: _generateRoundId(tournamentId, round),
            roundNumber: round,
            matchNumber: i + 1,
            player1: pair[0],
            player2: pair[1],
            status: 'pending',
            metadata: {'tournamentType': 'round_robin'},
          );
          roundMatches.add(match);
        }
      }
      
      rounds.add(TournamentRound(
        id: _generateRoundId(tournamentId, round),
        roundNumber: round,
        name: 'Vòng $round',
        type: 'round_robin',
        matches: roundMatches,
      ));
    }
    
    return TournamentBracket(
      tournamentId: tournamentId,
      format: TournamentFormats.roundRobin,
      participants: participants,
      rounds: rounds,
      structure: {
        'type': 'round_robin',
        'totalRounds': totalRounds,
        'matchesPerRound': matchesPerRound,
        'totalMatches': rounds.fold<int>(0, (sum, round) => sum + round.matches.length),
      },
    );
  }

  /// Generate round robin schedule using circle method
  static List<List<List<TournamentParticipant>>> _generateRoundRobinSchedule(
    List<TournamentParticipant> participants,
  ) {
    final players = List<TournamentParticipant>.from(participants);
    final schedule = <List<List<TournamentParticipant>>>[];
    
    // If odd number of players, add a "bye" placeholder
    if (players.length % 2 == 1) {
      players.add(TournamentParticipant(id: 'bye', name: 'BYE'));
    }
    
    final n = players.length;
    final rounds = n - 1;
    
    for (int round = 0; round < rounds; round++) {
      final roundMatches = <List<TournamentParticipant>>[];
      
      for (int i = 0; i < n ~/ 2; i++) {
        final player1Index = i;
        final player2Index = (n - 1 - i + round) % (n - 1);
        
        final player1 = players[player1Index];
        final player2 = players[player2Index == 0 ? n - 1 : player2Index];
        
        // Skip matches with BYE
        if (player1.id != 'bye' && player2.id != 'bye') {
          roundMatches.add([player1, player2]);
        }
      }
      
      schedule.add(roundMatches);
    }
    
    return schedule;
  }

  static Future<TournamentBracket> _generateSwissBracket(
    String tournamentId, {
    required List<TournamentParticipant> participants,
    Map<String, dynamic>? options,
  }) async {
    print('$_tag: Generating Swiss system bracket');
    
    final playerCount = participants.length;
    final rounds = <TournamentRound>[];
    
    // Swiss system: typically log2(n) + 2 rounds
    var totalRounds = 1;
    var temp = playerCount;
    while (temp > 1) {
      totalRounds++;
      temp ~/= 2;
    }
    totalRounds += 1; // Add extra round for Swiss
    
    final matchesPerRound = playerCount ~/ 2;
    
    print('$_tag: $playerCount players, $totalRounds rounds (Swiss system)');
    
    // Generate first round with initial seeding
    final firstRoundMatches = <TournamentMatch>[];
    
    // Swiss round 1: pair top half vs bottom half
    for (int i = 0; i < matchesPerRound; i++) {
      final player1 = participants[i];
      final player2 = participants[i + matchesPerRound];
      
      final match = TournamentMatch(
        id: _generateMatchId(tournamentId, 1, i + 1),
        roundId: _generateRoundId(tournamentId, 1, 'swiss'),
        roundNumber: 1,
        matchNumber: i + 1,
        player1: player1,
        player2: player2,
        status: 'pending',
        metadata: {
          'tournamentType': 'swiss',
          'pairingMethod': 'initial_seeding',
        },
      );
      firstRoundMatches.add(match);
    }
    
    rounds.add(TournamentRound(
      id: _generateRoundId(tournamentId, 1, 'swiss'),
      roundNumber: 1,
      name: 'Swiss Vòng 1',
      type: 'swiss',
      matches: firstRoundMatches,
      metadata: {'pairingMethod': 'initial_seeding'},
    ));
    
    // Generate subsequent rounds (empty, to be paired based on results)
    for (int round = 2; round <= totalRounds; round++) {
      final roundMatches = <TournamentMatch>[];
      
      for (int i = 0; i < matchesPerRound; i++) {
        final match = TournamentMatch(
          id: _generateMatchId(tournamentId, round, i + 1),
          roundId: _generateRoundId(tournamentId, round, 'swiss'),
          roundNumber: round,
          matchNumber: i + 1,
          status: 'pending',
          metadata: {
            'tournamentType': 'swiss',
            'pairingMethod': 'score_based',
            'requiresPairing': true,
          },
        );
        roundMatches.add(match);
      }
      
      rounds.add(TournamentRound(
        id: _generateRoundId(tournamentId, round, 'swiss'),
        roundNumber: round,
        name: 'Swiss Vòng $round',
        type: 'swiss',
        matches: roundMatches,
        metadata: {
          'pairingMethod': 'score_based',
          'requiresPairing': true,
        },
      ));
    }
    
    return TournamentBracket(
      tournamentId: tournamentId,
      format: TournamentFormats.swiss,
      participants: participants,
      rounds: rounds,
      structure: {
        'type': 'swiss',
        'totalRounds': totalRounds,
        'matchesPerRound': matchesPerRound,
        'pairingSystem': 'score_based',
        'allowRematch': false,
      },
    );
  }

  static Future<TournamentBracket> _generateParallelGroupsBracket(
    String tournamentId, {
    required List<TournamentParticipant> participants,
    Map<String, dynamic>? options,
  }) async {
    print('$_tag: Generating parallel groups bracket');
    
    final playerCount = participants.length;
    final groupSize = options?['groupSize'] ?? 4;
    final groupCount = (playerCount / groupSize).ceil();
    final playersPerGroup = playerCount ~/ groupCount;
    
    print('$_tag: $playerCount players, $groupCount groups, ~$playersPerGroup players per group');
    
    final rounds = <TournamentRound>[];
    
    // Divide participants into groups
    final groups = <List<TournamentParticipant>>[];
    for (int i = 0; i < groupCount; i++) {
      groups.add(<TournamentParticipant>[]);
    }
    
    // Distribute players evenly across groups (snake draft style)
    for (int i = 0; i < participants.length; i++) {
      final groupIndex = i % groupCount;
      groups[groupIndex].add(participants[i]);
    }
    
    for (int groupIndex = 0; groupIndex < groups.length; groupIndex++) {
      final group = groups[groupIndex];
      if (group.length < 2) continue;
      
      // Generate round robin for each group
      final groupSchedule = _generateRoundRobinSchedule(group);
      
      for (int roundInGroup = 0; roundInGroup < groupSchedule.length; roundInGroup++) {
        final existingRound = rounds.firstWhere(
          (r) => r.roundNumber == roundInGroup + 1,
          orElse: () => TournamentRound(
            id: _generateRoundId(tournamentId, roundInGroup + 1, 'group'),
            roundNumber: roundInGroup + 1,
            name: 'Bảng đấu - Vòng ${roundInGroup + 1}',
            type: 'group',
            matches: [],
            metadata: {'phase': 'group_stage'},
          ),
        );
        
        // Add group matches to existing round or create new round
        final groupMatches = groupSchedule[roundInGroup];
        for (int matchIndex = 0; matchIndex < groupMatches.length; matchIndex++) {
          final pair = groupMatches[matchIndex];
          if (pair.length == 2) {
            final match = TournamentMatch(
              id: _generateMatchId(tournamentId, roundInGroup + 1, existingRound.matches.length + 1),
              roundId: existingRound.id,
              roundNumber: roundInGroup + 1,
              matchNumber: existingRound.matches.length + 1,
              player1: pair[0],
              player2: pair[1],
              status: 'pending',
              metadata: {
                'tournamentType': 'parallel_groups',
                'groupIndex': groupIndex,
                'groupName': 'Bảng ${String.fromCharCode(65 + groupIndex)}', // A, B, C...
                'phase': 'group_stage',
              },
            );
            existingRound.matches.add(match);
          }
        }
        
        // Add round if not already added
        if (!rounds.any((r) => r.id == existingRound.id)) {
          rounds.add(existingRound);
        }
      }
    }
    
    // Generate playoffs/finals stage
    final qualifiersPerGroup = options?['qualifiersPerGroup'] ?? 2;
    final totalQualifiers = (groupCount * qualifiersPerGroup).toInt();
    
    if (totalQualifiers >= 4) {
      // Generate playoff bracket for qualifiers
      final playoffRounds = _generatePlayoffRounds(
        tournamentId, 
        totalQualifiers, 
        rounds.length + 1
      );
      rounds.addAll(playoffRounds);
    }
    
    return TournamentBracket(
      tournamentId: tournamentId,
      format: TournamentFormats.parallelGroups,
      participants: participants,
      rounds: rounds,
      structure: {
        'type': 'parallel_groups',
        'groupCount': groupCount,
        'groupSize': playersPerGroup,
        'qualifiersPerGroup': qualifiersPerGroup,
        'hasPlayoffs': totalQualifiers >= 4,
        'phases': ['group_stage', 'playoffs'],
      },
    );
  }

  /// Generate playoff rounds for parallel groups
  static List<TournamentRound> _generatePlayoffRounds(
    String tournamentId,
    int qualifierCount,
    int startingRoundNumber,
  ) {
    final rounds = <TournamentRound>[];
    final bracketSize = _nearestPowerOfTwo(qualifierCount);
    
    var currentRound = startingRoundNumber;
    var playersRemaining = bracketSize;
    
    while (playersRemaining > 1) {
      final matchesInRound = playersRemaining ~/ 2;
      final roundMatches = <TournamentMatch>[];
      
      for (int i = 0; i < matchesInRound; i++) {
        final match = TournamentMatch(
          id: _generateMatchId(tournamentId, currentRound, i + 1),
          roundId: _generateRoundId(tournamentId, currentRound, 'playoff'),
          roundNumber: currentRound,
          matchNumber: i + 1,
          status: 'pending',
          metadata: {
            'tournamentType': 'parallel_groups',
            'phase': 'playoffs',
          },
        );
        roundMatches.add(match);
      }
      
      final roundName = playersRemaining == 2 
          ? 'Chung kết' 
          : playersRemaining == 4 
              ? 'Bán kết' 
              : playersRemaining == 8 
                  ? 'Tứ kết'
                  : 'Playoff Vòng $currentRound';
      
      rounds.add(TournamentRound(
        id: _generateRoundId(tournamentId, currentRound, 'playoff'),
        roundNumber: currentRound,
        name: roundName,
        type: 'playoff',
        matches: roundMatches,
        metadata: {'phase': 'playoffs'},
      ));
      
      currentRound++;
      playersRemaining ~/= 2;
    }
    
    return rounds;
  }
}