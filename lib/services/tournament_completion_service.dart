// 🏆 SABO ARENA - Tournament Completion Service
// Handles complete tournament finishing workflow including ELO updates, 
// prize distribution, social posting, and community notifications

import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/tournament_constants.dart';
import 'tournament_service.dart';
import 'tournament_elo_service.dart';
import 'social_service.dart';
import 'notification_service.dart';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';

/// Service xử lý hoàn thành tournament và các tác vụ liên quan
class TournamentCompletionService {
  static TournamentCompletionService? _instance;
  static TournamentCompletionService get instance => _instance ??= TournamentCompletionService._();
  TournamentCompletionService._();

  final SupabaseClient _supabase = Supabase.instance.client;
  final TournamentService _tournamentService = TournamentService.instance;
  final TournamentEloService _eloService = TournamentEloService.instance;
  final SocialService _socialService = SocialService.instance;
  final NotificationService _notificationService = NotificationService.instance;

  // ==================== MAIN COMPLETION WORKFLOW ====================

  /// Complete tournament với full workflow
  Future<Map<String, dynamic>> completeTournament({
    required String tournamentId,
    bool sendNotifications = true,
    bool postToSocial = true,
    bool updateElo = true,
    bool distributePrizes = true,
  }) async {
    try {
      debugPrint('🏆 Starting tournament completion workflow for $tournamentId');

      // 1. Validate tournament can be completed
      final validationResult = await _validateTournamentCompletion(tournamentId);
      if (!validationResult['canComplete']) {
        throw Exception(validationResult['reason']);
      }

      // 2. Calculate final standings
      final standings = await _calculateFinalStandings(tournamentId);
      debugPrint('✅ Final standings calculated: ${standings.length} participants');

      // 3. Update ELO ratings
      List<Map<String, dynamic>> eloChanges = [];
      if (updateElo) {
        eloChanges = await _processEloUpdates(tournamentId, standings);
        debugPrint('✅ ELO updates processed: ${eloChanges.length} players');
      }

      // 4. Distribute prize pool
      List<Map<String, dynamic>> prizeDistribution = [];
      if (distributePrizes) {
        prizeDistribution = await _distributePrizes(tournamentId, standings);
        debugPrint('✅ Prize distribution completed: ${prizeDistribution.length} recipients');
      }

      // 5. Update tournament status
      await _updateTournamentStatus(tournamentId, standings);

      // 6. Send notifications
      if (sendNotifications) {
        await _sendCompletionNotifications(tournamentId, standings, eloChanges, prizeDistribution);
        debugPrint('✅ Completion notifications sent');
      }

      // 7. Create social posts
      if (postToSocial) {
        await _createSocialPosts(tournamentId, standings);
        debugPrint('✅ Social posts created');
      }

      // 8. Update statistics
      await _updateTournamentStatistics(tournamentId, standings);

      // 9. Create completion report
      final completionReport = await _generateCompletionReport(
        tournamentId,
        standings,
        eloChanges,
        prizeDistribution,
      );

      debugPrint('🎉 Tournament completion workflow finished successfully!');

      return {
        'success': true,
        'tournament_id': tournamentId,
        'completion_time': DateTime.now().toIso8601String(),
        'participants_count': standings.length,
        'champion_id': standings.isNotEmpty ? standings.first['participant_id'] : null,
        'elo_changes': eloChanges.length,
        'prize_recipients': prizeDistribution.length,
        'completion_report': completionReport,
        'message': 'Tournament completed successfully with full workflow',
      };

    } catch (error) {
      debugPrint('❌ Error completing tournament: $error');
      return {
        'success': false,
        'error': error.toString(),
        'message': 'Failed to complete tournament',
      };
    }
  }

  // ==================== VALIDATION ====================

  /// Validate tournament có thể được complete không
  Future<Map<String, dynamic>> _validateTournamentCompletion(String tournamentId) async {
    // Get tournament info
    final tournament = await _supabase
        .from('tournaments')
        .select('status, tournament_type, format')
        .eq('id', tournamentId)
        .single();

    if (tournament['status'] == 'completed') {
      return {
        'canComplete': false,
        'reason': 'Tournament is already completed',
      };
    }

    // Check if all matches are completed
    final matches = await _supabase
        .from('matches')
        .select('status')
        .eq('tournament_id', tournamentId);

    final totalMatches = matches.length;
    final completedMatches = matches.where((m) => m['status'] == 'completed').length;
    
    if (totalMatches == 0) {
      return {
        'canComplete': false,
        'reason': 'No matches found for this tournament',
      };
    }

    if (completedMatches < totalMatches) {
      return {
        'canComplete': false,
        'reason': 'Not all matches are completed ($completedMatches/$totalMatches)',
      };
    }

    // Format-specific validation
    final format = tournament['format'] ?? tournament['tournament_type'];
    final formatValidation = await _validateFormatSpecificCompletion(tournamentId, format);
    if (!formatValidation['valid']) {
      return {
        'canComplete': false,
        'reason': formatValidation['reason'],
      };
    }

    return {
      'canComplete': true,
      'total_matches': totalMatches,
      'completed_matches': completedMatches,
    };
  }

  /// Validate format-specific completion requirements
  Future<Map<String, dynamic>> _validateFormatSpecificCompletion(String tournamentId, String format) async {
    switch (format) {
      case TournamentFormats.singleElimination:
      case TournamentFormats.doubleElimination:
        // Check if final match exists và completed
        final finalMatch = await _supabase
            .from('matches')
            .select('status')
            .eq('tournament_id', tournamentId)
            .order('round_number', ascending: false)
            .limit(1)
            .maybeSingle();
        
        if (finalMatch == null || finalMatch['status'] != 'completed') {
          return {
            'valid': false,
            'reason': 'Final match not completed',
          };
        }
        break;

      case TournamentFormats.roundRobin:
        // All round robin matches should be completed
        // Additional validation có thể add sau
        break;

      case TournamentFormats.swiss:
        // Check if minimum rounds completed
        break;

      default:
        // Default validation passed
        break;
    }

    return {'valid': true};
  }

  // ==================== FINAL STANDINGS ====================

  /// Calculate final standings dựa trên tournament format
  Future<List<Map<String, dynamic>>> _calculateFinalStandings(String tournamentId) async {
    final tournament = await _supabase
        .from('tournaments')
        .select('format, tournament_type')
        .eq('id', tournamentId)
        .single();

    final format = tournament['format'] ?? tournament['tournament_type'];

    switch (format) {
      case TournamentFormats.singleElimination:
      case TournamentFormats.doubleElimination:
      case TournamentFormats.saboDoubleElimination:
      case TournamentFormats.saboDoubleElimination32:
        return await _calculateEliminationStandings(tournamentId, format);

      case TournamentFormats.roundRobin:
        return await _calculateRoundRobinStandings(tournamentId);

      case TournamentFormats.swiss:
        return await _calculateSwissStandings(tournamentId);

      case TournamentFormats.parallelGroups:
        return await _calculateParallelGroupsStandings(tournamentId);

      default:
        return await _calculateDefaultStandings(tournamentId);
    }
  }

  /// Calculate standings cho elimination formats
  Future<List<Map<String, dynamic>>> _calculateEliminationStandings(String tournamentId, String format) async {
    // Get all participants
    final participants = await _supabase
        .from('tournament_participants')
        .select('''
          user_id,
          users!inner(id, full_name, elo_rating, rank)
        ''')
        .eq('tournament_id', tournamentId);

    // Get all matches để determine elimination order
    final matches = await _supabase
        .from('matches')
        .select('player1_id, player2_id, winner_id, round_number, status')
        .eq('tournament_id', tournamentId)
        .eq('status', 'completed')
        .order('round_number', ascending: false);

    List<Map<String, dynamic>> standings = [];

    // Find champion (winner of final match)
    final finalMatch = matches.first;
    final championId = finalMatch['winner_id'];
    
    if (championId != null) {
      final champion = participants.firstWhere((p) => p['user_id'] == championId);
      standings.add({
        'position': 1,
        'participant_id': championId,
        'participant_name': champion['users']['full_name'],
        'elimination_round': null, // Champion wasn't eliminated
        'matches_played': _countMatchesPlayed(championId, matches),
        'matches_won': _countMatchesWon(championId, matches),
      });
    }

    // Find runner-up
    final runnerUpId = finalMatch['player1_id'] == championId 
        ? finalMatch['player2_id'] 
        : finalMatch['player1_id'];
    
    if (runnerUpId != null) {
      final runnerUp = participants.firstWhere((p) => p['user_id'] == runnerUpId);
      standings.add({
        'position': 2,
        'participant_id': runnerUpId,
        'participant_name': runnerUp['users']['full_name'],
        'elimination_round': matches.first['round_number'],
        'matches_played': _countMatchesPlayed(runnerUpId, matches),
        'matches_won': _countMatchesWon(runnerUpId, matches),
      });
    }

    // Calculate positions cho remaining participants dựa trên elimination order
    final remainingParticipants = participants
        .where((p) => p['user_id'] != championId && p['user_id'] != runnerUpId)
        .toList();

    // Group by elimination round (later rounds = higher positions)
    Map<int, List<String>> eliminationRounds = {};
    
    for (final participant in remainingParticipants) {
      final playerId = participant['user_id'];
      final eliminationRound = _findEliminationRound(playerId, matches);
      
      if (!eliminationRounds.containsKey(eliminationRound)) {
        eliminationRounds[eliminationRound] = [];
      }
      eliminationRounds[eliminationRound]!.add(playerId);
    }

    // Assign positions (higher elimination round = better position)
    int currentPosition = 3;
    final sortedRounds = eliminationRounds.keys.toList()..sort((a, b) => b.compareTo(a));
    
    for (final round in sortedRounds) {
      final playersInRound = eliminationRounds[round]!;
      
      for (final playerId in playersInRound) {
        final participant = participants.firstWhere((p) => p['user_id'] == playerId);
        standings.add({
          'position': currentPosition,
          'participant_id': playerId,
          'participant_name': participant['users']['full_name'],
          'elimination_round': round,
          'matches_played': _countMatchesPlayed(playerId, matches),
          'matches_won': _countMatchesWon(playerId, matches),
        });
      }
      
      currentPosition += playersInRound.length;
    }

    return standings;
  }

  /// Calculate standings cho Round Robin
  Future<List<Map<String, dynamic>>> _calculateRoundRobinStandings(String tournamentId) async {
    final participants = await _supabase
        .from('tournament_participants')
        .select('''
          user_id,
          users!inner(id, full_name, elo_rating, rank)
        ''')
        .eq('tournament_id', tournamentId);

    final matches = await _supabase
        .from('matches')
        .select('player1_id, player2_id, winner_id, player1_score, player2_score')
        .eq('tournament_id', tournamentId)
        .eq('status', 'completed');

    List<Map<String, dynamic>> standings = [];

    for (final participant in participants) {
      final playerId = participant['user_id'];
      final playerMatches = matches.where(
        (m) => m['player1_id'] == playerId || m['player2_id'] == playerId
      ).toList();

      int wins = 0;
      int losses = 0;
      int gamesWon = 0;
      int gamesLost = 0;

      for (final match in playerMatches) {
        final isPlayer1 = match['player1_id'] == playerId;
        final playerScore = isPlayer1 ? match['player1_score'] : match['player2_score'];
        final opponentScore = isPlayer1 ? match['player2_score'] : match['player1_score'];

        gamesWon += (playerScore as int? ?? 0);
        gamesLost += (opponentScore as int? ?? 0);

        if (match['winner_id'] == playerId) {
          wins++;
        } else if (match['winner_id'] != null) {
          losses++;
        }
      }

      standings.add({
        'participant_id': playerId,
        'participant_name': participant['users']['full_name'],
        'matches_played': playerMatches.length,
        'matches_won': wins,
        'matches_lost': losses,
        'games_won': gamesWon,
        'games_lost': gamesLost,
        'win_percentage': playerMatches.isEmpty ? 0 : (wins / playerMatches.length * 100).round(),
        'points': wins * 3, // 3 points per match win
      });
    }

    // Sort by points, then by win percentage, then by games difference
    standings.sort((a, b) {
      final pointsCompare = (b['points'] as int).compareTo(a['points'] as int);
      if (pointsCompare != 0) return pointsCompare;

      final winPercentageCompare = (b['win_percentage'] as int).compareTo(a['win_percentage'] as int);
      if (winPercentageCompare != 0) return winPercentageCompare;

      final gamesDiffA = (a['games_won'] as int) - (a['games_lost'] as int);
      final gamesDiffB = (b['games_won'] as int) - (b['games_lost'] as int);
      return gamesDiffB.compareTo(gamesDiffA);
    });

    // Assign positions
    for (int i = 0; i < standings.length; i++) {
      standings[i]['position'] = i + 1;
    }

    return standings;
  }

  /// Calculate standings cho Swiss System
  Future<List<Map<String, dynamic>>> _calculateSwissStandings(String tournamentId) async {
    // Similar to Round Robin nhưng với Swiss scoring
    // Implementation chi tiết sau
    return [];
  }

  /// Calculate standings cho Parallel Groups
  Future<List<Map<String, dynamic>>> _calculateParallelGroupsStandings(String tournamentId) async {
    // Combine group stage results với playoff results
    // Implementation chi tiết sau
    return [];
  }

  /// Default standings calculation
  Future<List<Map<String, dynamic>>> _calculateDefaultStandings(String tournamentId) async {
    // Fallback method
    final participants = await _supabase
        .from('tournament_participants')
        .select('''
          user_id,
          users!inner(id, full_name, elo_rating, rank)
        ''')
        .eq('tournament_id', tournamentId);

    return participants.asMap().entries.map((entry) {
      return {
        'position': entry.key + 1,
        'participant_id': entry.value['user_id'],
        'participant_name': entry.value['users']['full_name'],
        'matches_played': 0,
        'matches_won': 0,
      };
    }).toList();
  }

  // ==================== HELPER METHODS ====================

  /// Count matches played by a player
  int _countMatchesPlayed(String playerId, List matches) {
    return matches.where(
      (m) => m['player1_id'] == playerId || m['player2_id'] == playerId
    ).length;
  }

  /// Count matches won by a player
  int _countMatchesWon(String playerId, List matches) {
    return matches.where((m) => m['winner_id'] == playerId).length;
  }

  /// Find elimination round for a player
  int _findEliminationRound(String playerId, List matches) {
    // Find the last match where player lost
    for (final match in matches) {
      if ((match['player1_id'] == playerId || match['player2_id'] == playerId) &&
          match['winner_id'] != null && match['winner_id'] != playerId) {
        return match['round_number'] as int;
      }
    }
    return 1; // Default to round 1 if no elimination found
  }

  // ==================== ELO UPDATES ====================

  /// Process ELO updates cho tournament completion
  Future<List<Map<String, dynamic>>> _processEloUpdates(
    String tournamentId, 
    List<Map<String, dynamic>> standings
  ) async {
    try {
      // Get tournament format
      final tournamentResponse = await _supabase
          .from('tournaments')
          .select('tournament_type')
          .eq('id', tournamentId)
          .single();
      
      final tournamentFormat = tournamentResponse['tournament_type'] ?? 'single_elimination';
      
      // TODO: Fix ELO service integration - type mismatch issue
      // return await _eloService.processTournamentEloChanges(
      //   tournamentId: tournamentId,
      //   results: standings,
      //   tournamentFormat: tournamentFormat,
      // );
      
      // Temporary workaround - return empty list
      debugPrint('⚠️ ELO processing temporarily disabled due to type mismatch');
      return [];
    } catch (e) {
      debugPrint('❌ Error processing ELO updates: $e');
      return [];
    }
  }

  // ==================== PRIZE DISTRIBUTION ====================

  /// Distribute prizes dựa trên tournament settings
  Future<List<Map<String, dynamic>>> _distributePrizes(
    String tournamentId,
    List<Map<String, dynamic>> standings,
  ) async {
    // Get tournament prize info
    final tournament = await _supabase
        .from('tournaments')
        .select('prize_pool, entry_fee, max_participants, prize_distribution')
        .eq('id', tournamentId)
        .single();

    final prizePool = tournament['prize_pool'] as int? ?? 0;
    if (prizePool <= 0) {
      debugPrint('⚠️ No prize pool to distribute');
      return [];
    }

    // Get prize distribution template
    final distributionTemplate = tournament['prize_distribution'] ?? 'standard';
    final participantCount = standings.length;

    final distribution = _getPrizeDistribution(distributionTemplate, participantCount);
    List<Map<String, dynamic>> prizeRecipients = [];

    for (int i = 0; i < math.min(distribution.length, standings.length); i++) {
      final percentage = distribution[i];
      final prizeAmount = (prizePool * percentage / 100).round();
      
      if (prizeAmount > 0) {
        final standing = standings[i];
        
        // Update user's SPA points (prize pool)
        // Get current spa_points first
        final currentPoints = await _supabase
            .from('users')
            .select('spa_points')
            .eq('id', standing['participant_id'])
            .single();
        
        final newPoints = (currentPoints['spa_points'] ?? 0) + prizeAmount;
        await _supabase.from('users').update({
          'spa_points': newPoints,
        }).eq('id', standing['participant_id']);

        // Record prize transaction
        await _supabase.from('transactions').insert({
          'user_id': standing['participant_id'],
          'amount': prizeAmount,
          'transaction_type': 'tournament_prize',
          'description': 'Tournament prize - Position ${standing['position']}',
          'tournament_id': tournamentId,
          'status': 'completed',
        });

        prizeRecipients.add({
          'participant_id': standing['participant_id'],
          'participant_name': standing['participant_name'],
          'position': standing['position'],
          'prize_amount': prizeAmount,
          'percentage': percentage,
        });
      }
    }

    debugPrint('💰 Prize distribution completed: ${prizeRecipients.length} recipients');
    return prizeRecipients;
  }

  /// Get prize distribution percentages
  List<double> _getPrizeDistribution(String template, int participantCount) {
    final distributions = PrizeDistribution.allDistributions[template];
    if (distributions == null) return [];

    // Find closest participant count
    final availableKeys = distributions.keys.map(int.parse).toList()..sort();
    int closestKey = availableKeys.last;
    
    for (final key in availableKeys) {
      if (participantCount <= key) {
        closestKey = key;
        break;
      }
    }

    return distributions[closestKey.toString()] ?? [];
  }

  // ==================== STATUS UPDATES ====================

  /// Update tournament status to completed
  Future<void> _updateTournamentStatus(String tournamentId, List<Map<String, dynamic>> standings) async {
    final championId = standings.isNotEmpty ? standings.first['participant_id'] : null;

    await _supabase.from('tournaments').update({
      'status': 'completed',
      'completed_at': DateTime.now().toIso8601String(),
      'champion_id': championId,
    }).eq('id', tournamentId);

    // Update participants with final positions
    for (final standing in standings) {
      await _supabase.from('tournament_participants').update({
        'final_position': standing['position'],
        'matches_played': standing['matches_played'] ?? 0,
        'matches_won': standing['matches_won'] ?? 0,
      }).eq('tournament_id', tournamentId).eq('user_id', standing['participant_id']);
    }
  }

  /// Helper method to increment user tournament statistics
  Future<void> _incrementUserStats(String participantId, bool isWinner, bool isPodium) async {
    try {
      // Get current stats
      final userStats = await _supabase
          .from('users')
          .select('total_tournaments, tournament_wins, tournament_podiums')
          .eq('id', participantId)
          .single();
      
      // Calculate new values
      final updates = <String, dynamic>{
        'total_tournaments': (userStats['total_tournaments'] ?? 0) + 1,
      };
      
      if (isWinner) {
        updates['tournament_wins'] = (userStats['tournament_wins'] ?? 0) + 1;
      }
      
      if (isPodium) {
        updates['tournament_podiums'] = (userStats['tournament_podiums'] ?? 0) + 1;
      }
      
      // Update the stats
      await _supabase.from('users').update(updates).eq('id', participantId);
      
    } catch (e) {
      debugPrint('⚠️ Failed to update user stats for $participantId: $e');
    }
  }

  // ==================== NOTIFICATIONS ====================

  /// Send completion notifications
  Future<void> _sendCompletionNotifications(
    String tournamentId,
    List<Map<String, dynamic>> standings,
    List<Map<String, dynamic>> eloChanges,
    List<Map<String, dynamic>> prizeDistribution,
  ) async {
    final tournament = await _supabase
        .from('tournaments')
        .select('title')
        .eq('id', tournamentId)
        .single();

    final tournamentTitle = tournament['title'];

    // Notify champion
    if (standings.isNotEmpty) {
      final champion = standings.first;
      await _notificationService.sendNotification(
        userId: champion['participant_id'],
        type: 'tournament_champion',
        title: '🏆 Chúc mừng! Bạn đã vô địch!',
        message: 'Bạn đã giành chiến thắng trong giải đấu "$tournamentTitle"',
        data: {
          'tournament_id': tournamentId,
          'position': 1,
          'achievement': 'champion',
        },
      );
    }

    // Notify runner-up
    if (standings.length > 1) {
      final runnerUp = standings[1];
      await _notificationService.sendNotification(
        userId: runnerUp['participant_id'],
        type: 'tournament_placement',
        title: '🥈 Á quân giải đấu!',
        message: 'Bạn đã đạt vị trí thứ 2 trong giải đấu "$tournamentTitle"',
        data: {
          'tournament_id': tournamentId,
          'position': 2,
        },
      );
    }

    // Notify top 3
    for (int i = 2; i < math.min(3, standings.length); i++) {
      final participant = standings[i];
      await _notificationService.sendNotification(
        userId: participant['participant_id'],
        type: 'tournament_placement',
        title: '🥉 Top 3 giải đấu!',
        message: 'Bạn đã đạt vị trí thứ ${participant['position']} trong giải đấu "$tournamentTitle"',
        data: {
          'tournament_id': tournamentId,
          'position': participant['position'],
        },
      );
    }

    // Notify prize winners
    for (final prize in prizeDistribution) {
      await _notificationService.sendNotification(
        userId: prize['participant_id'],
        type: 'prize_received',
        title: '💰 Bạn đã nhận được giải thưởng!',
        message: 'Bạn đã nhận ${prize['prize_amount']} SPA từ giải đấu "$tournamentTitle"',
        data: {
          'tournament_id': tournamentId,
          'prize_amount': prize['prize_amount'],
          'position': prize['position'],
        },
      );
    }
  }

  // ==================== SOCIAL POSTS ====================

  /// Create social posts về tournament completion
  Future<void> _createSocialPosts(String tournamentId, List<Map<String, dynamic>> standings) async {
    try {
      final tournament = await _supabase
          .from('tournaments')
          .select('title, organizer_id, max_participants')
          .eq('id', tournamentId)
          .single();

      final tournamentTitle = tournament['title'];
      final organizerId = tournament['organizer_id'];
      final participantCount = standings.length;

      // Create completion post by organizer
      if (organizerId != null && standings.isNotEmpty) {
        final champion = standings.first;
        
        final postContent = '''🏆 Giải đấu "$tournamentTitle" đã kết thúc!

🥇 Vô địch: ${champion['participant_name']}
👥 Tham gia: $participantCount người chơi
🎉 Chúc mừng tất cả các vận động viên!

#SABOArena #Tournament #Champion''';

        await _socialService.createPost(
          content: postContent,
          postType: 'tournament_completion',
          tournamentId: tournamentId,
          hashtags: ['SABOArena', 'Tournament', 'Champion', tournamentTitle.replaceAll(' ', '')],
        );

        debugPrint('📱 Tournament completion post created');
      }

      // Champion có thể tự động share achievement (optional)
      // Implementation sau nếu cần

    } catch (e) {
      debugPrint('⚠️ Failed to create social posts: $e');
    }
  }

  // ==================== STATISTICS ====================

  /// Update tournament và user statistics
  Future<void> _updateTournamentStatistics(String tournamentId, List<Map<String, dynamic>> standings) async {
    try {
      // Update user tournament statistics
      for (final standing in standings) {
        final participantId = standing['participant_id'];
        final position = standing['position'] as int;
        
        // Update user profile với tournament results
        await _incrementUserStats(
          participantId, 
          position == 1,  // isWinner
          position <= 3   // isPodium
        );
      }

      // Update club statistics (if tournament belongs to club)
      final tournament = await _supabase
          .from('tournaments')
          .select('club_id')
          .eq('id', tournamentId)
          .single();

      if (tournament['club_id'] != null) {
        // Get current tournaments_hosted count
        final clubData = await _supabase
            .from('clubs')
            .select('tournaments_hosted')
            .eq('id', tournament['club_id'])
            .single();
        
        final newCount = (clubData['tournaments_hosted'] ?? 0) + 1;
        await _supabase.from('clubs').update({
          'tournaments_hosted': newCount,
        }).eq('id', tournament['club_id']);
      }

      debugPrint('📊 Tournament statistics updated');

    } catch (e) {
      debugPrint('⚠️ Failed to update statistics: $e');
    }
  }

  // ==================== COMPLETION REPORT ====================

  /// Generate completion report
  Future<Map<String, dynamic>> _generateCompletionReport(
    String tournamentId,
    List<Map<String, dynamic>> standings,
    List<Map<String, dynamic>> eloChanges,
    List<Map<String, dynamic>> prizeDistribution,
  ) async {
    final tournament = await _supabase
        .from('tournaments')
        .select('title, start_date, entry_fee, prize_pool, max_participants')
        .eq('id', tournamentId)
        .single();

    return {
      'tournament_info': {
        'id': tournamentId,
        'title': tournament['title'],
        'start_date': tournament['start_date'],
        'entry_fee': tournament['entry_fee'],
        'prize_pool': tournament['prize_pool'],
        'participants': standings.length,
        'max_participants': tournament['max_participants'],
      },
      'standings': standings.take(10).toList(), // Top 10
      'champion': standings.isNotEmpty ? standings.first : null,
      'elo_changes': eloChanges.length,
      'total_prize_distributed': prizeDistribution.fold<int>(
        0, (sum, prize) => sum + (prize['prize_amount'] as int)
      ),
      'completion_time': DateTime.now().toIso8601String(),
    };
  }

  // ==================== PUBLIC UTILITY METHODS ====================

  /// Get tournament completion status
  Future<Map<String, dynamic>> getTournamentCompletionStatus(String tournamentId) async {
    final validation = await _validateTournamentCompletion(tournamentId);
    return validation;
  }

  /// Preview final standings before completion
  Future<List<Map<String, dynamic>>> previewFinalStandings(String tournamentId) async {
    return await _calculateFinalStandings(tournamentId);
  }

  // ==================== AUTO COMPLETION DETECTION ====================

  /// Tự động kiểm tra và cập nhật trạng thái giải đấu nếu đã hoàn thành
  Future<bool> checkAndAutoCompleteTournament(String tournamentId) async {
    try {
      debugPrint('🏁 Auto-checking tournament completion: $tournamentId');
      
      // 1. Lấy thông tin giải đấu hiện tại
      final tournamentResponse = await _supabase
          .from('tournaments')
          .select('id, title, status, max_participants')
          .eq('id', tournamentId)
          .single();
      
      final tournament = tournamentResponse;
      
      // Nếu đã completed thì không cần kiểm tra nữa
      if (tournament['status'] == 'completed') {
        debugPrint('✅ Tournament already completed');
        return true;
      }
      
      // Chỉ xử lý tournaments đang active/in_progress
      if (!['active', 'in_progress', 'ongoing'].contains(tournament['status'])) {
        debugPrint('⏭️ Tournament not in active state: ${tournament['status']}');
        return false;
      }
      
      // 2. Kiểm tra validation completion
      final validationResult = await _validateTournamentCompletion(tournamentId);
      
      if (validationResult['canComplete'] == true) {
        debugPrint('✅ Tournament ready for auto-completion!');
        
        // 3. Tự động complete với minimal workflow
        await _autoCompleteTournamentMinimal(tournamentId);
        return true;
        
      } else {
        debugPrint('⏳ Tournament not ready: ${validationResult['reason']}');
        return false;
      }
      
    } catch (e) {
      debugPrint('❌ Error in auto-completion check: $e');
      return false;
    }
  }

  /// Minimal tournament completion - chỉ cập nhật status
  Future<void> _autoCompleteTournamentMinimal(String tournamentId) async {
    try {
      // 1. Tìm winner từ match cuối cùng
      final matchesResponse = await _supabase
          .from('matches')
          .select('winner_id, round_number, match_name')
          .eq('tournament_id', tournamentId)
          .eq('status', 'completed')
          .order('round_number', ascending: false);
      
      final matches = matchesResponse as List<dynamic>;
      String? winnerId;
      
      if (matches.isNotEmpty) {
        // Lấy winner từ round cao nhất
        final finalMatch = matches.first;
        winnerId = finalMatch['winner_id'];
        debugPrint('🏆 Champion found: $winnerId (${finalMatch['match_name'] ?? 'Final'})');
      }
      
      // 2. Cập nhật tournament status
      final updateData = {
        'status': 'completed',
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      await _supabase
          .from('tournaments')
          .update(updateData)
          .eq('id', tournamentId);
      
      debugPrint('🎉 Tournament auto-completed successfully!');
      
      // 3. Apply tournament rewards and update user stats
      await _applyTournamentRewards(tournamentId);
      
      // 4. Send completion notifications to all participants
      await _sendTournamentCompletionNotifications(tournamentId, winnerId);
      
      // 5. Log champion info
      if (winnerId != null) {
        await _logChampionInfo(tournamentId, winnerId);
      }
      
    } catch (e) {
      debugPrint('❌ Error in minimal auto-completion: $e');
      rethrow;
    }
  }

  /// Apply tournament completion rewards
  Future<void> _applyTournamentRewards(String tournamentId) async {
    try {
      debugPrint('💰 Applying tournament completion rewards...');
      
      // 1. Analyze tournament results
      final results = await _analyzeTournamentResults(tournamentId);
      
      // 2. Calculate and apply rewards
      for (final result in results) {
        final position = result['position'] as int;
        final wins = result['wins'] as int;
        final userId = result['user_id'] as String;
        final currentElo = result['current_elo'] as int;
        final currentSpa = result['current_spa'] as int;
        
        // Calculate rewards based on position
        int eloBonus = 0;
        int spaBonus = 5; // Minimum participation reward
        
        if (position == 1) { // Champion
          eloBonus = 50;
          spaBonus = 200;
        } else if (position == 2) { // Runner-up
          eloBonus = 30;
          spaBonus = 100;
        } else if (position == 3) { // 3rd place
          eloBonus = 20;
          spaBonus = 50;
        } else if (position <= 4) { // Top 4
          eloBonus = 10;
          spaBonus = 25;
        } else if (position <= 8) { // Top 8
          eloBonus = 5;
          spaBonus = 10;
        }
        
        // Additional bonus for wins
        eloBonus += wins * 5;
        spaBonus += wins * 10;
        
        // Apply rewards
        await _supabase.from('users').update({
          'elo_rating': currentElo + eloBonus,
          'spa_points': currentSpa + spaBonus,
          'tournaments_played': result['tournaments_played'] + 1,
          'tournament_wins': result['tournament_wins'] + (position == 1 ? 1 : 0),
        }).eq('id', userId);
        
        debugPrint('✅ Rewards applied to ${result['username']}: ELO +$eloBonus, SPA +$spaBonus');
      }
      
      debugPrint('� Tournament rewards applied successfully!');
      
    } catch (e) {
      debugPrint('❌ Error applying tournament rewards: $e');
    }
  }

  /// Analyze tournament results and calculate positions
  Future<List<Map<String, dynamic>>> _analyzeTournamentResults(String tournamentId) async {
    // Get participants
    final participantsResponse = await _supabase
        .from('tournament_participants')
        .select('user_id, users!inner(username, full_name, elo_rating, spa_points, tournaments_played, tournament_wins)')
        .eq('tournament_id', tournamentId);
    
    final participants = participantsResponse as List<dynamic>;
    
    // Get matches
    final matchesResponse = await _supabase
        .from('matches')
        .select('*')
        .eq('tournament_id', tournamentId);
    
    final matches = matchesResponse as List<dynamic>;
    
    // Calculate performance for each user
    final results = <Map<String, dynamic>>[];
    
    for (final participant in participants) {
      final userId = participant['user_id'] as String;
      final user = participant['users'] as Map<String, dynamic>;
      
      // Calculate wins/losses
      final userMatches = matches.where((m) => 
          m['player1_id'] == userId || m['player2_id'] == userId).toList();
      
      final wins = userMatches.where((m) => m['winner_id'] == userId).length;
      final losses = userMatches.where((m) => 
          m['winner_id'] != null && m['winner_id'] != userId).length;
      
      results.add({
        'user_id': userId,
        'username': user['username'] ?? 'Unknown',
        'wins': wins,
        'losses': losses,
        'matches_played': userMatches.length,
        'win_rate': userMatches.isNotEmpty ? wins / userMatches.length : 0.0,
        'current_elo': user['elo_rating'] ?? 1000,
        'current_spa': user['spa_points'] ?? 0,
        'tournaments_played': user['tournaments_played'] ?? 0,
        'tournament_wins': user['tournament_wins'] ?? 0,
      });
    }
    
    // Sort by wins, then win rate
    results.sort((a, b) {
      final winsCompare = (b['wins'] as int).compareTo(a['wins'] as int);
      if (winsCompare != 0) return winsCompare;
      return (b['win_rate'] as double).compareTo(a['win_rate'] as double);
    });
    
    // Assign positions
    for (int i = 0; i < results.length; i++) {
      results[i]['position'] = i + 1;
    }
    
    return results;
  }

  /// Log thông tin champion
  Future<void> _logChampionInfo(String tournamentId, String winnerId) async {
    try {
      final results = await Future.wait([
        _supabase.from('users').select('username, full_name').eq('id', winnerId).maybeSingle(),
        _supabase.from('tournaments').select('title').eq('id', tournamentId).single(),
      ]);
      
      final winner = results[0];
      final tournament = results[1];
      
      if (winner != null) {
        final winnerName = winner['full_name'] ?? winner['username'] ?? 'Unknown';
        debugPrint('🏆 AUTO-COMPLETION CHAMPION: $winnerName');
        debugPrint('🏆 Tournament: ${tournament?['title'] ?? 'Unknown'}');
        debugPrint('🏆 Winner ID: ${winnerId.substring(0, 8)}...');
      }
      
    } catch (e) {
      debugPrint('⚠️ Could not log champion info: $e');
    }
  }

  /// Quét tất cả giải đấu active để tự động complete
  Future<int> scanAndAutoCompleteActiveTournaments() async {
    try {
      debugPrint('🔍 Scanning active tournaments for auto-completion...');
      
      final tournamentsResponse = await _supabase
          .from('tournaments')
          .select('id, title, status')
          .or('status.eq.active,status.eq.in_progress,status.eq.ongoing');
      
      final tournaments = tournamentsResponse as List<dynamic>;
      
      if (tournaments.isEmpty) {
        debugPrint('✅ No active tournaments found');
        return 0;
      }
      
      debugPrint('🔍 Found ${tournaments.length} active tournaments');
      
      int completedCount = 0;
      for (final tournament in tournaments) {
        final wasCompleted = await checkAndAutoCompleteTournament(tournament['id']);
        if (wasCompleted) {
          completedCount++;
          debugPrint('✅ Auto-completed: ${tournament['title']}');
        }
      }
      
      debugPrint('🎯 Auto-completion scan finished: $completedCount tournaments completed');
      return completedCount;
      
    } catch (e) {
      debugPrint('❌ Error scanning tournaments: $e');
      return 0;
    }
  }

  /// Send tournament completion notifications to all participants
  Future<void> _sendTournamentCompletionNotifications(String tournamentId, String? winnerId) async {
    try {
      debugPrint('📨 Sending tournament completion notifications...');
      
      // Get tournament info
      final tournamentResponse = await _supabase
          .from('tournaments')
          .select('title, club_id')
          .eq('id', tournamentId)
          .single();
      
      final tournament = tournamentResponse;
      final tournamentTitle = tournament['title'] ?? 'Tournament';
      
      // Get winner info if available
      String championName = 'Unknown Champion';
      if (winnerId != null) {
        final winnerResponse = await _supabase
            .from('users')
            .select('username, full_name')
            .eq('id', winnerId)
            .maybeSingle();
        
        if (winnerResponse != null) {
          championName = winnerResponse['full_name'] ?? winnerResponse['username'] ?? 'Unknown Champion';
        }
      }
      
      // Get all participants
      final participantsResponse = await _supabase
          .from('tournament_participants')
          .select('user_id')
          .eq('tournament_id', tournamentId);
      
      final participants = participantsResponse as List<dynamic>;
      
      // Send notifications to all participants
      int notificationsSent = 0;
      
      for (final participant in participants) {
        final userId = participant['user_id'] as String;
        
        try {
          // Tournament completion notification
          await _notificationService.sendNotification(
            userId: userId,
            title: '🏆 Giải đấu hoàn thành!',
            message: 'Giải đấu "$tournamentTitle" đã kết thúc. Chúc mừng nhà vô địch $championName! 🎉',
            type: 'tournament_completed',
            data: {
              'tournament_id': tournamentId,
              'tournament_title': tournamentTitle,
              'champion_id': winnerId,
              'champion_name': championName,
            },
          );
          
          // Individual reward notification (if user received rewards)
          if (userId == winnerId) {
            // Champion notification
            await _notificationService.sendNotification(
              userId: userId,
              title: '👑 Chúc mừng nhà vô địch!',
              message: 'Bạn đã giành chiến thắng giải đấu "$tournamentTitle"! Phần thưởng ELO và SPA đã được cộng vào tài khoản. 🏆',
              type: 'tournament_champion',
              data: {
                'tournament_id': tournamentId,
                'tournament_title': tournamentTitle,
                'position': 1,
              },
            );
          } else {
            // Participation reward notification
            await _notificationService.sendNotification(
              userId: userId,
              title: '🎁 Phần thưởng tham gia',
              message: 'Cảm ơn bạn đã tham gia giải đấu "$tournamentTitle". Phần thưởng ELO và SPA đã được cộng vào tài khoản!',
              type: 'tournament_reward',
              data: {
                'tournament_id': tournamentId,
                'tournament_title': tournamentTitle,
              },
            );
          }
          
          notificationsSent += 2; // 2 notifications per user
          
        } catch (e) {
          debugPrint('❌ Error sending notification to user $userId: $e');
        }
      }
      
      debugPrint('✅ Tournament completion notifications sent: $notificationsSent notifications to ${participants.length} participants');
      
    } catch (e) {
      debugPrint('❌ Error sending tournament completion notifications: $e');
    }
  }
}
