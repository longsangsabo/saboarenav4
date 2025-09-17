import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/tournament.dart';
import '../models/user_profile.dart';
import '../core/constants/tournament_constants.dart';
import '../core/constants/ranking_constants.dart';
import 'ranking_service.dart';
import 'dart:math' as math;

class TournamentService {
  static TournamentService? _instance;
  static TournamentService get instance => _instance ??= TournamentService._();
  TournamentService._();

  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Tournament>> getTournaments({
    String? status,
    String? clubId,
    String? skillLevel,
    int page = 1,
    int pageSize = 15,
  }) async {
    try {
      var query = _supabase.from('tournaments').select();

      if (status != null) {
        query = query.eq('status', status);
      }
      if (clubId != null) {
        query = query.eq('club_id', clubId);
      }
      if (skillLevel != null) {
        query = query.eq('skill_level_required', skillLevel);
      }

      final from = (page - 1) * pageSize;
      final to = from + pageSize - 1;

      final response = await query
          .eq('is_public', true)
          .order('start_date', ascending: true)
          .range(from, to);

      return response
          .map<Tournament>((json) => Tournament.fromJson(json))
          .toList();
    } catch (error) {
      throw Exception('Failed to get tournaments: $error');
    }
  }

  Future<Tournament> getTournamentById(String tournamentId) async {
    try {
      final response = await _supabase
          .from('tournaments')
          .select()
          .eq('id', tournamentId)
          .single();

      return Tournament.fromJson(response);
    } catch (error) {
      throw Exception('Failed to get tournament: $error');
    }
  }

  Future<List<UserProfile>> getTournamentParticipants(
      String tournamentId) async {
    try {
      final response =
          await _supabase.from('tournament_participants').select('''
            *,
            users (*)
          ''').eq('tournament_id', tournamentId).order('registered_at');

      return response
          .map<UserProfile>((json) => UserProfile.fromJson(json['users']))
          .toList();
    } catch (error) {
      throw Exception('Failed to get tournament participants: $error');
    }
  }

  Future<bool> registerForTournament(String tournamentId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Check if already registered
      final existingRegistration = await _supabase
          .from('tournament_participants')
          .select()
          .eq('tournament_id', tournamentId)
          .eq('user_id', user.id)
          .maybeSingle();

      if (existingRegistration != null) {
        throw Exception('Already registered for this tournament');
      }

      // Check if tournament is still accepting registrations
      final tournament = await getTournamentById(tournamentId);
      if (tournament.currentParticipants >= tournament.maxParticipants) {
        throw Exception('Tournament is full');
      }

      if (DateTime.now().isAfter(tournament.registrationDeadline)) {
        throw Exception('Registration deadline has passed');
      }

      // Register for tournament
      await _supabase.from('tournament_participants').insert({
        'tournament_id': tournamentId,
        'user_id': user.id,
        'payment_status': 'pending',
        'registered_at': DateTime.now().toIso8601String(),
      });

      // Update participant count
      await _supabase.rpc('increment_tournament_participants',
          params: {'tournament_id': tournamentId});

      return true;
    } catch (error) {
      throw Exception('Failed to register for tournament: $error');
    }
  }

  Future<bool> unregisterFromTournament(String tournamentId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _supabase
          .from('tournament_participants')
          .delete()
          .eq('tournament_id', tournamentId)
          .eq('user_id', user.id);

      // Update participant count
      await _supabase.rpc('decrement_tournament_participants',
          params: {'tournament_id': tournamentId});

      return true;
    } catch (error) {
      throw Exception('Failed to unregister from tournament: $error');
    }
  }

  Future<bool> isRegisteredForTournament(String tournamentId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      final response = await _supabase
          .from('tournament_participants')
          .select('id')
          .eq('tournament_id', tournamentId)
          .eq('user_id', user.id)
          .maybeSingle();

      return response != null;
    } catch (error) {
      throw Exception('Failed to check tournament registration: $error');
    }
  }

  Future<Tournament> createTournament({
    required String clubId,
    required String title,
    required String description,
    required DateTime startDate,
    required DateTime registrationDeadline,
    required int maxParticipants,
    required double entryFee,
    required double prizePool,
    String? skillLevelRequired,
    String? rules,
    String? requirements,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final tournamentData = {
        'club_id': clubId,
        'organizer_id': user.id,
        'title': title,
        'description': description,
        'start_date': startDate.toIso8601String(),
        'registration_deadline': registrationDeadline.toIso8601String(),
        'max_participants': maxParticipants,
        'entry_fee': entryFee,
        'prize_pool': prizePool,
        'skill_level_required': skillLevelRequired,
        'rules': rules,
        'requirements': requirements,
        'status': 'upcoming',
        'current_participants': 0,
      };

      final response = await _supabase
          .from('tournaments')
          .insert(tournamentData)
          .select()
          .single();

      return Tournament.fromJson(response);
    } catch (error) {
      throw Exception('Failed to create tournament: $error');
    }
  }

  Future<List<Tournament>> getUserTournaments() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response =
          await _supabase.from('tournament_participants').select('''
            tournaments (*)
          ''').eq('user_id', user.id).order('created_at', ascending: false);

      return response
          .map<Tournament>((json) => Tournament.fromJson(json['tournaments']))
          .toList();
    } catch (error) {
      throw Exception('Failed to get user tournaments: $error');
    }
  }

  Future<List<Tournament>> getUserOrganizedTournaments() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _supabase
          .from('tournaments')
          .select()
          .eq('organizer_id', user.id)
          .order('created_at', ascending: false);

      return response
          .map<Tournament>((json) => Tournament.fromJson(json))
          .toList();
    } catch (error) {
      throw Exception('Failed to get organized tournaments: $error');
    }
  }

  Future<List<Tournament>> searchTournaments(String query) async {
    try {
      final response = await _supabase
          .from('tournaments')
          .select()
          .or('title.ilike.%$query%,description.ilike.%$query%')
          .eq('is_public', true)
          .order('start_date', ascending: true)
          .limit(20);

      return response
          .map<Tournament>((json) => Tournament.fromJson(json))
          .toList();
    } catch (error) {
      throw Exception('Failed to search tournaments: $error');
    }
  }

  Future<Map<String, dynamic>> getTournamentStats(String tournamentId) async {
    try {
      final tournament = await getTournamentById(tournamentId);
      final participants = await getTournamentParticipants(tournamentId);

      // Get matches for this tournament
      final matches = await _supabase
          .from('matches')
          .select()
          .eq('tournament_id', tournamentId);

      final completedMatches =
          matches.where((match) => match['status'] == 'completed').length;
      final pendingMatches =
          matches.where((match) => match['status'] == 'pending').length;

      return {
        'total_participants': participants.length,
        'max_participants': tournament.maxParticipants,
        'total_matches': matches.length,
        'completed_matches': completedMatches,
        'pending_matches': pendingMatches,
        'entry_fee': tournament.entryFee,
        'prize_pool': tournament.prizePool,
        'status': tournament.status,
      };
    } catch (error) {
      throw Exception('Failed to get tournament stats: $error');
    }
  }

  // ==================== CORE TOURNAMENT LOGIC ====================

  /// Tạo tournament bracket dựa trên format và danh sách participants
  Future<TournamentBracket> generateBracket({
    required String tournamentId,
    required String format,
    required List<UserProfile> participants,
    String seedingMethod = SeedingMethods.eloRating,
  }) async {
    try {
      // Validate format và số người chơi
      if (!TournamentHelper.isValidPlayerCount(format, participants.length)) {
        throw Exception('Invalid player count for format $format');
      }

      // Seeding participants
      final seededParticipants = await _seedParticipants(participants, seedingMethod);

      // Generate bracket structure dựa trên format
      final bracketStructure = _generateBracketStructure(format, seededParticipants);

      // Tạo matches
      final matches = _generateMatches(tournamentId, bracketStructure, format);

      return TournamentBracket(
        tournamentId: tournamentId,
        format: format,
        participants: seededParticipants,
        matches: matches,
        rounds: TournamentHelper.calculateRounds(format, participants.length),
        status: 'ready',
        createdAt: DateTime.now(),
      );
    } catch (error) {
      throw Exception('Failed to generate bracket: $error');
    }
  }

  /// Seeding participants dựa trên method được chỉ định
  Future<List<SeededParticipant>> _seedParticipants(
    List<UserProfile> participants,
    String seedingMethod,
  ) async {
    List<SeededParticipant> seeded = [];

    switch (seedingMethod) {
      case SeedingMethods.eloRating:
        participants.sort((a, b) => b.eloRating.compareTo(a.eloRating));
        break;
      
      case SeedingMethods.clubRanking:
        // TODO: Implement club ranking logic
        participants.sort((a, b) => b.eloRating.compareTo(a.eloRating));
        break;
        
      case SeedingMethods.previousTournaments:
        // TODO: Implement tournament history logic
        participants.sort((a, b) => b.eloRating.compareTo(a.eloRating));
        break;
        
      case SeedingMethods.hybrid:
        // Combine ELO + tournament history
        participants.sort((a, b) => _calculateHybridSeed(a, b));
        break;
        
      case SeedingMethods.random:
      default:
        participants.shuffle();
        break;
    }

    for (int i = 0; i < participants.length; i++) {
      seeded.add(SeededParticipant(
        participant: participants[i],
        seedNumber: i + 1,
        seedingMethod: seedingMethod,
      ));
    }

    return seeded;
  }

  /// Calculate hybrid seeding score
  int _calculateHybridSeed(UserProfile a, UserProfile b) {
    // Weight: 70% ELO, 30% tournament history
    double scoreA = (a.eloRating * 0.7) + (_getTournamentHistoryScore(a) * 0.3);
    double scoreB = (b.eloRating * 0.7) + (_getTournamentHistoryScore(b) * 0.3);
    return scoreB.compareTo(scoreA);
  }

  /// Get tournament history score for hybrid seeding
  double _getTournamentHistoryScore(UserProfile participant) {
    // TODO: Implement real tournament history calculation
    // For now return base ELO
    return participant.eloRating.toDouble();
  }

  /// Generate bracket structure theo format
  Map<String, dynamic> _generateBracketStructure(
    String format,
    List<SeededParticipant> participants,
  ) {
    switch (format) {
      case TournamentFormats.singleElimination:
        return _generateSingleEliminationBracket(participants);
        
      case TournamentFormats.doubleElimination:
        return _generateDoubleEliminationBracket(participants);
        
      case TournamentFormats.roundRobin:
        return _generateRoundRobinBracket(participants);
        
      case TournamentFormats.swiss:
        return _generateSwissBracket(participants);
        
      case TournamentFormats.parallelGroups:
        return _generateParallelGroupsBracket(participants);
        
      default:
        return _generateSingleEliminationBracket(participants);
    }
  }

  /// Generate single elimination bracket
  Map<String, dynamic> _generateSingleEliminationBracket(List<SeededParticipant> participants) {
    final int playerCount = participants.length;
    final int rounds = math.log(playerCount) ~/ math.log(2);
    
    // Create first round pairings
    List<Map<String, dynamic>> firstRoundPairings = [];
    
    for (int i = 0; i < playerCount; i += 2) {
      firstRoundPairings.add({
        'player1': participants[i],
        'player2': i + 1 < playerCount ? participants[i + 1] : null,
        'round': 1,
        'matchNumber': (i ~/ 2) + 1,
      });
    }

    return {
      'type': 'single_elimination',
      'rounds': rounds,
      'firstRound': firstRoundPairings,
      'structure': 'standard_bracket',
    };
  }

  /// Generate double elimination bracket
  Map<String, dynamic> _generateDoubleEliminationBracket(List<SeededParticipant> participants) {
    // Winner bracket structure
    final winnerBracket = _generateSingleEliminationBracket(participants);
    
    return {
      'type': 'double_elimination',
      'winnerBracket': winnerBracket,
      'loserBracket': _generateLoserBracket(participants.length),
      'grandFinalsRequired': true,
    };
  }

  /// Generate round robin bracket
  Map<String, dynamic> _generateRoundRobinBracket(List<SeededParticipant> participants) {
    List<Map<String, dynamic>> allPairings = [];
    final int playerCount = participants.length;
    
    for (int i = 0; i < playerCount; i++) {
      for (int j = i + 1; j < playerCount; j++) {
        allPairings.add({
          'player1': participants[i],
          'player2': participants[j],
          'round': ((allPairings.length ~/ (playerCount ~/ 2)) + 1),
          'matchNumber': allPairings.length + 1,
        });
      }
    }

    return {
      'type': 'round_robin',
      'totalRounds': playerCount - 1,
      'allPairings': allPairings,
      'pointsSystem': {'win': 3, 'draw': 1, 'loss': 0},
    };
  }

  /// Generate Swiss system bracket (initial round only)
  Map<String, dynamic> _generateSwissBracket(List<SeededParticipant> participants) {
    // First round: pair top half vs bottom half
    List<Map<String, dynamic>> firstRoundPairings = [];
    final int half = participants.length ~/ 2;
    
    for (int i = 0; i < half; i++) {
      firstRoundPairings.add({
        'player1': participants[i],
        'player2': participants[i + half],
        'round': 1,
        'matchNumber': i + 1,
      });
    }

    return {
      'type': 'swiss',
      'totalRounds': TournamentHelper.calculateRounds(TournamentFormats.swiss, participants.length),
      'firstRound': firstRoundPairings,
      'pairingMethod': 'swiss_system',
    };
  }

  /// Generate parallel groups bracket
  Map<String, dynamic> _generateParallelGroupsBracket(List<SeededParticipant> participants) {
    final int playerCount = participants.length;
    final int groupCount = math.min(4, playerCount ~/ 4); // Max 4 groups
    
    List<List<SeededParticipant>> groups = [];
    
    // Distribute players across groups (snake seeding)
    for (int g = 0; g < groupCount; g++) {
      groups.add([]);
    }
    
    for (int i = 0; i < playerCount; i++) {
      final groupIndex = i % groupCount;
      groups[groupIndex].add(participants[i]);
    }

    return {
      'type': 'parallel_groups',
      'groupCount': groupCount,
      'groups': groups.map((group) => _generateRoundRobinBracket(group)).toList(),
      'finalsStructure': 'knockout', // Top players advance to knockout
    };
  }

  /// Generate loser bracket for double elimination
  Map<String, dynamic> _generateLoserBracket(int playerCount) {
    // Simplified loser bracket structure
    return {
      'rounds': (math.log(playerCount) ~/ math.log(2)) * 2 - 1,
      'structure': 'loser_bracket',
      'feedFromWinner': true,
    };
  }

  /// Generate matches từ bracket structure
  List<TournamentMatch> _generateMatches(
    String tournamentId,
    Map<String, dynamic> bracketStructure,
    String format,
  ) {
    List<TournamentMatch> matches = [];
    
    switch (format) {
      case TournamentFormats.singleElimination:
        matches.addAll(_generateSingleEliminationMatches(tournamentId, bracketStructure));
        break;
        
      case TournamentFormats.roundRobin:
        matches.addAll(_generateRoundRobinMatches(tournamentId, bracketStructure));
        break;
        
      case TournamentFormats.swiss:
        matches.addAll(_generateSwissMatches(tournamentId, bracketStructure));
        break;
        
      // Add other formats...
    }
    
    return matches;
  }

  /// Generate single elimination matches
  List<TournamentMatch> _generateSingleEliminationMatches(
    String tournamentId,
    Map<String, dynamic> bracket,
  ) {
    List<TournamentMatch> matches = [];
    final firstRound = bracket['firstRound'] as List<Map<String, dynamic>>;
    
    for (var pairing in firstRound) {
      matches.add(TournamentMatch(
        id: _generateMatchId(),
        tournamentId: tournamentId,
        player1Id: pairing['player1']?.participant.id,
        player2Id: pairing['player2']?.participant?.id,
        round: pairing['round'],
        matchNumber: pairing['matchNumber'],
        status: MatchStatus.scheduled,
        format: 'single_elimination',
        createdAt: DateTime.now(),
      ));
    }
    
    return matches;
  }

  /// Generate round robin matches
  List<TournamentMatch> _generateRoundRobinMatches(
    String tournamentId,
    Map<String, dynamic> bracket,
  ) {
    List<TournamentMatch> matches = [];
    final allPairings = bracket['allPairings'] as List<Map<String, dynamic>>;
    
    for (var pairing in allPairings) {
      matches.add(TournamentMatch(
        id: _generateMatchId(),
        tournamentId: tournamentId,
        player1Id: pairing['player1'].participant.id,
        player2Id: pairing['player2'].participant.id,
        round: pairing['round'],
        matchNumber: pairing['matchNumber'],
        status: MatchStatus.scheduled,
        format: 'round_robin',
        createdAt: DateTime.now(),
      ));
    }
    
    return matches;
  }

  /// Generate Swiss system matches (first round only)
  List<TournamentMatch> _generateSwissMatches(
    String tournamentId,
    Map<String, dynamic> bracket,
  ) {
    List<TournamentMatch> matches = [];
    final firstRound = bracket['firstRound'] as List<Map<String, dynamic>>;
    
    for (var pairing in firstRound) {
      matches.add(TournamentMatch(
        id: _generateMatchId(),
        tournamentId: tournamentId,
        player1Id: pairing['player1'].participant.id,
        player2Id: pairing['player2'].participant.id,
        round: pairing['round'],
        matchNumber: pairing['matchNumber'],
        status: MatchStatus.scheduled,
        format: 'swiss',
        createdAt: DateTime.now(),
      ));
    }
    
    return matches;
  }

  /// Calculate prize distribution dựa trên template và tournament results
  Future<List<PrizeDistributionResult>> calculatePrizeDistribution({
    required String tournamentId,
    required String distributionType,
    required double totalPrizePool,
    required List<TournamentResult> results,
  }) async {
    try {
      final playerCount = results.length;
      final distribution = TournamentHelper.getPrizeDistribution(distributionType, playerCount);
      
      List<PrizeDistributionResult> prizeResults = [];
      
      for (int i = 0; i < distribution.length && i < results.length; i++) {
        final percentage = distribution[i];
        final prizeAmount = totalPrizePool * percentage;
        
        prizeResults.add(PrizeDistributionResult(
          position: i + 1,
          participantId: results[i].participantId,
          prizeAmount: prizeAmount,
          percentage: percentage,
          prizeType: PrizeTypes.cash,
        ));
      }
      
      return prizeResults;
    } catch (error) {
      throw Exception('Failed to calculate prize distribution: $error');
    }
  }

  /// Update tournament status
  Future<void> updateTournamentStatus(String tournamentId, String newStatus) async {
    try {
      await _supabase
          .from('tournaments')
          .update({'status': newStatus, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', tournamentId);
    } catch (error) {
      throw Exception('Failed to update tournament status: $error');
    }
  }

  /// Generate unique match ID
  String _generateMatchId() {
    return 'match_${DateTime.now().millisecondsSinceEpoch}_${math.Random().nextInt(1000)}';
  }

  /// Calculate ELO changes cho tournament results
  Future<List<EloChange>> calculateTournamentEloChanges({
    required String tournamentId,
    required List<TournamentResult> results,
    required String tournamentFormat,
    required int participantCount,
  }) async {
    try {
      List<EloChange> eloChanges = [];
      
      for (int i = 0; i < results.length; i++) {
        final result = results[i];
        final position = i + 1;
        
        // Base ELO reward dựa trên placement
        int baseEloReward = _calculateBaseEloReward(position, participantCount);
        
        // Tournament size bonus
        int sizeBonus = participantCount >= 32 ? 5 : 0;
        
        // Format bonus
        int formatBonus = _getFormatBonus(tournamentFormat);
        
        // Performance bonus (upset, perfect run, etc.)
        int performanceBonus = await _calculatePerformanceBonus(result, results);
        
        final totalEloChange = baseEloReward + sizeBonus + formatBonus + performanceBonus;
        
        eloChanges.add(EloChange(
          participantId: result.participantId,
          oldElo: result.startingElo,
          newElo: result.startingElo + totalEloChange,
          change: totalEloChange,
          reason: 'Tournament #$tournamentId: Position $position/${results.length}',
          baseReward: baseEloReward,
          bonuses: {
            'size_bonus': sizeBonus,
            'format_bonus': formatBonus,
            'performance_bonus': performanceBonus,
          },
        ));
      }
      
      return eloChanges;
    } catch (error) {
      throw Exception('Failed to calculate ELO changes: $error');
    }
  }

  /// Calculate base ELO reward dựa trên position
  int _calculateBaseEloReward(int position, int totalParticipants) {
    if (position == 1) return 25; // Winner
    if (position == 2) return 15; // Runner-up
    if (position <= 4) return 10; // Semi-finalists
    if (position <= 8) return 5;  // Quarter-finalists
    if (position <= totalParticipants / 2) return 2; // Top half
    return -2; // Bottom half (small penalty)
  }

  /// Get format bonus ELO
  int _getFormatBonus(String format) {
    switch (format) {
      case TournamentFormats.doubleElimination:
        return 3; // Harder format
      case TournamentFormats.swiss:
        return 2;
      case TournamentFormats.roundRobin:
        return 1;
      default:
        return 0;
    }
  }

  /// Calculate performance bonuses
  Future<int> _calculatePerformanceBonus(TournamentResult result, List<TournamentResult> allResults) async {
    int bonus = 0;
    
    // Perfect run bonus (no losses in single elimination)
    if (result.matchesLost == 0) {
      bonus += 5;
    }
    
    // Upset bonus (beat higher seeded players)
    if (result.defeatedHigherSeeds > 0) {
      bonus += result.defeatedHigherSeeds * 3;
    }
    
    // TODO: Add streak bonus logic
    
    return bonus;
  }
}

// ==================== DATA MODELS ====================

/// Tournament Bracket Model
class TournamentBracket {
  final String tournamentId;
  final String format;
  final List<SeededParticipant> participants;
  final List<TournamentMatch> matches;
  final int rounds;
  final String status;
  final DateTime createdAt;

  TournamentBracket({
    required this.tournamentId,
    required this.format,
    required this.participants,
    required this.matches,
    required this.rounds,
    required this.status,
    required this.createdAt,
  });
}

/// Seeded Participant Model
class SeededParticipant {
  final UserProfile participant;
  final int seedNumber;
  final String seedingMethod;

  SeededParticipant({
    required this.participant,
    required this.seedNumber,
    required this.seedingMethod,
  });
}

/// Tournament Match Model
class TournamentMatch {
  final String id;
  final String tournamentId;
  final String? player1Id;
  final String? player2Id;
  final int round;
  final int matchNumber;
  final String status;
  final String format;
  final DateTime createdAt;
  final String? winnerId;
  final Map<String, int>? score;
  final DateTime? scheduledTime;
  final String? tableNumber;

  TournamentMatch({
    required this.id,
    required this.tournamentId,
    this.player1Id,
    this.player2Id,
    required this.round,
    required this.matchNumber,
    required this.status,
    required this.format,
    required this.createdAt,
    this.winnerId,
    this.score,
    this.scheduledTime,
    this.tableNumber,
  });
}

/// Match Status Constants
class MatchStatus {
  static const String scheduled = 'scheduled';
  static const String ongoing = 'ongoing';
  static const String completed = 'completed';
  static const String cancelled = 'cancelled';
  static const String postponed = 'postponed';
}

/// Tournament Result Model
class TournamentResult {
  final String participantId;
  final int finalPosition;
  final int matchesPlayed;
  final int matchesWon;
  final int matchesLost;
  final int startingElo;
  final int defeatedHigherSeeds;
  final List<String> defeatedOpponents;

  TournamentResult({
    required this.participantId,
    required this.finalPosition,
    required this.matchesPlayed,
    required this.matchesWon,
    required this.matchesLost,
    required this.startingElo,
    this.defeatedHigherSeeds = 0,
    this.defeatedOpponents = const [],
  });
}

/// Prize Distribution Result Model
class PrizeDistributionResult {
  final int position;
  final String participantId;
  final double prizeAmount;
  final double percentage;
  final String prizeType;

  PrizeDistributionResult({
    required this.position,
    required this.participantId,
    required this.prizeAmount,
    required this.percentage,
    required this.prizeType,
  });
}

/// ELO Change Model
class EloChange {
  final String participantId;
  final int oldElo;
  final int newElo;
  final int change;
  final String reason;
  final int baseReward;
  final Map<String, int> bonuses;

  EloChange({
    required this.participantId,
    required this.oldElo,
    required this.newElo,
    required this.change,
    required this.reason,
    required this.baseReward,
    required this.bonuses,
  });
}
