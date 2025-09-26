// 🏆 SABO ARENA - Match Progression Service
// Handles automatic tournament bracket progression when matches are completed
// Manages winner advancement and loser routing in all tournament formats

import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/tournament_constants.dart';
import 'notification_service.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Service quản lý progression của matches trong tournament bracket
class MatchProgressionService {
  static MatchProgressionService? _instance;
  static MatchProgressionService get instance => _instance ??= MatchProgressionService._();
  MatchProgressionService._();

  final SupabaseClient _supabase = Supabase.instance.client;
  final NotificationService _notificationService = NotificationService.instance;

  // ==================== MAIN PROGRESSION LOGIC ====================

  /// Update match result và tự động advance winners đến next round
  Future<Map<String, dynamic>> updateMatchResult({
    required String matchId,
    required String tournamentId,
    required String winnerId,
    required String loserId,
    required Map<String, int> scores,
    String? notes,
  }) async {
    try {
      debugPrint('🎯 Starting match progression for match $matchId');

      // 1. Update match result in database
      await _updateMatchInDatabase(matchId, winnerId, loserId, scores, notes);

      // 2. Get tournament format để xác định progression logic
      final tournament = await _getTournamentInfo(tournamentId);
      final format = tournament['format'] ?? tournament['tournament_type'];

      // 3. Get bracket structure và current match info
      final bracketInfo = await _getBracketInfo(tournamentId, matchId);

      // 4. Execute format-specific progression
      final progressionResult = await _executeProgression(
        tournamentId: tournamentId,
        matchId: matchId,
        winnerId: winnerId,
        loserId: loserId,
        format: format,
        bracketInfo: bracketInfo,
      );

      // 5. Check if tournament is complete
      final isComplete = await _checkTournamentCompletion(tournamentId, format);

      // 6. Send notifications
      await _sendProgressionNotifications(
        tournamentId: tournamentId,
        winnerId: winnerId,
        loserId: loserId,
        progressionResult: progressionResult,
        isComplete: isComplete,
      );

      return {
        'success': true,
        'match_updated': true,
        'progression_completed': progressionResult['advancement_made'] ?? false,
        'tournament_complete': isComplete,
        'next_matches': progressionResult['next_matches'] ?? [],
        'message': 'Match result updated and bracket progressed successfully',
      };

    } catch (error) {
      debugPrint('❌ Error in match progression: $error');
      return {
        'success': false,
        'error': error.toString(),
        'message': 'Failed to update match and progress bracket',
      };
    }
  }

  // ==================== DATABASE OPERATIONS ====================

  /// Update match result trong database
  Future<void> _updateMatchInDatabase(
    String matchId,
    String winnerId,
    String loserId,
    Map<String, int> scores,
    String? notes,
  ) async {
    await _supabase.from('matches').update({
      'winner_id': winnerId,
      'player1_score': scores['player1'] ?? 0,
      'player2_score': scores['player2'] ?? 0,
      'status': 'completed',
      'completed_at': DateTime.now().toIso8601String(),
      'notes': notes,
    }).eq('id', matchId);

    debugPrint('✅ Match $matchId updated in database');
  }

  /// Get tournament info
  Future<Map<String, dynamic>> _getTournamentInfo(String tournamentId) async {
    final response = await _supabase
        .from('tournaments')
        .select('format, tournament_type, title, status')
        .eq('id', tournamentId)
        .single();
    
    return response;
  }

  /// Get bracket info cho match progression
  Future<Map<String, dynamic>> _getBracketInfo(String tournamentId, String matchId) async {
    // Get current match info
    final matchResponse = await _supabase
        .from('matches')
        .select('*, tournaments!inner(format)')
        .eq('id', matchId)
        .single();

    // Get all matches in tournament
    final allMatches = await _supabase
        .from('matches')
        .select('*')
        .eq('tournament_id', tournamentId)
        .order('round_number')
        .order('match_number');

    return {
      'current_match': matchResponse,
      'all_matches': allMatches,
      'tournament_format': matchResponse['tournaments']['format'],
    };
  }

  // ==================== FORMAT-SPECIFIC PROGRESSION ====================

  /// Execute progression logic dựa trên tournament format
  Future<Map<String, dynamic>> _executeProgression({
    required String tournamentId,
    required String matchId,
    required String winnerId,
    required String loserId,
    required String format,
    required Map<String, dynamic> bracketInfo,
  }) async {
    
    switch (format) {
      case TournamentFormats.singleElimination:
        return await _progressSingleElimination(tournamentId, matchId, winnerId, bracketInfo);
        
      case TournamentFormats.doubleElimination:
        return await _progressDoubleElimination(tournamentId, matchId, winnerId, loserId, bracketInfo);
        
      case TournamentFormats.saboDoubleElimination:
        return await _progressSaboDE16(tournamentId, matchId, winnerId, loserId, bracketInfo);
        
      case TournamentFormats.saboDoubleElimination32:
        return await _progressSaboDE32(tournamentId, matchId, winnerId, loserId, bracketInfo);
        
      case TournamentFormats.roundRobin:
        return await _progressRoundRobin(tournamentId, matchId, winnerId, bracketInfo);
        
      case TournamentFormats.swiss:
        return await _progressSwiss(tournamentId, matchId, winnerId, bracketInfo);
        
      case TournamentFormats.parallelGroups:
        return await _progressParallelGroups(tournamentId, matchId, winnerId, loserId, bracketInfo);
        
      default:
        throw Exception('Unsupported tournament format: $format');
    }
  }

  /// Progress Single Elimination bracket
  Future<Map<String, dynamic>> _progressSingleElimination(
    String tournamentId,
    String matchId,
    String winnerId,
    Map<String, dynamic> bracketInfo,
  ) async {
    final currentMatch = bracketInfo['current_match'];
    final allMatches = bracketInfo['all_matches'] as List;
    
    final currentRound = currentMatch['round_number'] as int;
    final currentMatchNumber = currentMatch['match_number'] as int;
    
    // Find next round match where winner should advance
    final nextRoundNumber = currentRound + 1;
    final nextMatchNumber = ((currentMatchNumber - 1) ~/ 2) + 1;
    
    final nextMatch = allMatches.firstWhere(
      (match) => 
        match['round_number'] == nextRoundNumber &&
        match['match_number'] == nextMatchNumber,
      orElse: () => null,
    );

    if (nextMatch == null) {
      // This was the final match
      return {
        'advancement_made': false,
        'next_matches': [],
        'is_final_match': true,
        'champion': winnerId,
      };
    }

    // Determine if winner goes to player1 or player2 slot
    final isPlayer1Slot = (currentMatchNumber % 2) == 1;
    final updateField = isPlayer1Slot ? 'player1_id' : 'player2_id';
    
    // Update next match with winner
    await _supabase.from('matches').update({
      updateField: winnerId,
    }).eq('id', nextMatch['id']);

    // Check if next match is now ready (both players assigned)
    bool nextMatchReady = false;
    if (nextMatch['player1_id'] != null || nextMatch['player2_id'] != null) {
      final updatedNextMatch = await _supabase
          .from('matches')
          .select('player1_id, player2_id')
          .eq('id', nextMatch['id'])
          .single();
      
      nextMatchReady = updatedNextMatch['player1_id'] != null && 
                      updatedNextMatch['player2_id'] != null;
      
      if (nextMatchReady) {
        await _supabase.from('matches').update({
          'status': 'ready',
        }).eq('id', nextMatch['id']);
      }
    }

    debugPrint('✅ Single elimination: Winner $winnerId advanced to Round $nextRoundNumber');

    return {
      'advancement_made': true,
      'next_matches': [nextMatch['id']],
      'next_match_ready': nextMatchReady,
      'round_advanced_to': nextRoundNumber,
    };
  }

  /// Progress Double Elimination bracket
  Future<Map<String, dynamic>> _progressDoubleElimination(
    String tournamentId,
    String matchId,
    String winnerId,
    String loserId,
    Map<String, dynamic> bracketInfo,
  ) async {
    final currentMatch = bracketInfo['current_match'];
    final allMatches = bracketInfo['all_matches'] as List;
    
    // Get match metadata to determine bracket type
    final matchData = currentMatch['match_data'] != null 
        ? jsonDecode(currentMatch['match_data']) 
        : <String, dynamic>{};
    
    final bracketType = matchData['bracketType'] ?? 'winner';
    
    List<String> updatedMatches = [];
    
    if (bracketType == 'winner') {
      // Winner advances in winner bracket
      final winnerResult = await _progressSingleElimination(tournamentId, matchId, winnerId, bracketInfo);
      if (winnerResult['advancement_made']) {
        updatedMatches.addAll(List<String>.from(winnerResult['next_matches']));
      }
      
      // Loser goes to loser bracket
      final loserResult = await _advanceToLoserBracket(tournamentId, matchId, loserId, allMatches);
      if (loserResult['advancement_made']) {
        updatedMatches.addAll(List<String>.from(loserResult['next_matches']));
      }
      
    } else if (bracketType == 'loser') {
      // Winner advances in loser bracket, loser is eliminated
      final loserBracketResult = await _progressLoserBracket(tournamentId, matchId, winnerId, allMatches);
      if (loserBracketResult['advancement_made']) {
        updatedMatches.addAll(List<String>.from(loserBracketResult['next_matches']));
      }
    }

    debugPrint('✅ Double elimination: Winner $winnerId and loser $loserId processed');

    return {
      'advancement_made': updatedMatches.isNotEmpty,
      'next_matches': updatedMatches,
      'bracket_type': bracketType,
    };
  }

  /// Advance loser từ winner bracket vào loser bracket
  Future<Map<String, dynamic>> _advanceToLoserBracket(
    String tournamentId,
    String matchId,
    String loserId,
    List allMatches,
  ) async {
    // Logic để tìm correct loser bracket position
    // Implementation sẽ phụ thuộc vào cách structure loser bracket
    
    // For now, simplified logic - cần implement chi tiết sau
    final loserBracketMatches = allMatches.where(
      (match) {
        final matchData = match['match_data'] != null 
            ? jsonDecode(match['match_data']) 
            : <String, dynamic>{};
        return matchData['bracketType'] == 'loser' && 
               match['status'] == 'pending' &&
               (match['player1_id'] == null || match['player2_id'] == null);
      }
    ).toList();

    if (loserBracketMatches.isNotEmpty) {
      final targetMatch = loserBracketMatches.first;
      final updateField = targetMatch['player1_id'] == null ? 'player1_id' : 'player2_id';
      
      await _supabase.from('matches').update({
        updateField: loserId,
      }).eq('id', targetMatch['id']);

      return {
        'advancement_made': true,
        'next_matches': [targetMatch['id']],
      };
    }

    return {
      'advancement_made': false,
      'next_matches': [],
    };
  }

  /// Progress trong loser bracket
  Future<Map<String, dynamic>> _progressLoserBracket(
    String tournamentId,
    String matchId,
    String winnerId,
    List allMatches,
  ) async {
    // Similar logic to single elimination nhưng trong loser bracket
    // Implementation chi tiết sẽ phức tạp hơn
    
    return {
      'advancement_made': false,
      'next_matches': [],
    };
  }

  /// Progress Sabo DE16 (implementation placeholder)
  Future<Map<String, dynamic>> _progressSaboDE16(
    String tournamentId,
    String matchId,
    String winnerId,
    String loserId,
    Map<String, dynamic> bracketInfo,
  ) async {
    // TODO: Implement Sabo DE16 specific logic
    return {'advancement_made': false, 'next_matches': []};
  }

  /// Progress Sabo DE32 (implementation placeholder)  
  Future<Map<String, dynamic>> _progressSaboDE32(
    String tournamentId,
    String matchId,
    String winnerId,
    String loserId,
    Map<String, dynamic> bracketInfo,
  ) async {
    // TODO: Implement Sabo DE32 specific logic
    return {'advancement_made': false, 'next_matches': []};
  }

  /// Progress Round Robin (no elimination, just update standings)
  Future<Map<String, dynamic>> _progressRoundRobin(
    String tournamentId,
    String matchId,
    String winnerId,
    Map<String, dynamic> bracketInfo,
  ) async {
    // Update standings table
    await _updateRoundRobinStandings(tournamentId, matchId, winnerId);
    
    return {
      'advancement_made': false, // No advancement in round robin
      'next_matches': [],
      'standings_updated': true,
    };
  }

  /// Progress Swiss System (pairing for next round)
  Future<Map<String, dynamic>> _progressSwiss(
    String tournamentId,
    String matchId,
    String winnerId,
    Map<String, dynamic> bracketInfo,
  ) async {
    // Update Swiss standings và potentially generate next round pairings
    // Complex logic - implementation sau
    return {'advancement_made': false, 'next_matches': []};
  }

  /// Progress Parallel Groups
  Future<Map<String, dynamic>> _progressParallelGroups(
    String tournamentId,
    String matchId,
    String winnerId,
    String loserId,
    Map<String, dynamic> bracketInfo,
  ) async {
    // Logic để handle group stage và playoff advancement
    return {'advancement_made': false, 'next_matches': []};
  }

  // ==================== HELPER FUNCTIONS ====================

  /// Update Round Robin standings
  Future<void> _updateRoundRobinStandings(String tournamentId, String matchId, String winnerId) async {
    // Implementation cho round robin standings update
    debugPrint('📊 Updating Round Robin standings for tournament $tournamentId');
  }

  /// Check if tournament is complete
  Future<bool> _checkTournamentCompletion(String tournamentId, String format) async {
    final allMatches = await _supabase
        .from('matches')
        .select('status')
        .eq('tournament_id', tournamentId);

    final completedMatches = allMatches.where((m) => m['status'] == 'completed').length;
    final totalMatches = allMatches.length;

    // Basic completion check - all matches completed
    if (completedMatches == totalMatches) {
      await _supabase.from('tournaments').update({
        'status': 'completed',
        'completed_at': DateTime.now().toIso8601String(),
      }).eq('id', tournamentId);
      
      debugPrint('🏆 Tournament $tournamentId marked as completed!');
      return true;
    }

    return false;
  }

  /// Send progression notifications
  Future<void> _sendProgressionNotifications({
    required String tournamentId,
    required String winnerId,
    required String loserId,
    required Map<String, dynamic> progressionResult,
    required bool isComplete,
  }) async {
    try {
      // Notify winner of advancement
      if (progressionResult['advancement_made'] == true) {
        await _notificationService.sendNotification(
          userId: winnerId,
          type: 'tournament_advancement',
          title: 'Tiến vào vòng tiếp theo!',
          message: 'Bạn đã thắng và tiến vào vòng tiếp theo của giải đấu',
          data: {
            'tournament_id': tournamentId,
            'advancement_type': progressionResult['bracket_type'] ?? 'next_round',
          },
        );
      }

      // Notify about tournament completion
      if (isComplete && progressionResult['champion'] == winnerId) {
        await _notificationService.sendNotification(
          userId: winnerId,
          type: 'tournament_champion',
          title: '🏆 Chúc mừng! Bạn đã vô địch!',
          message: 'Bạn đã giành chiến thắng trong giải đấu!',
          data: {
            'tournament_id': tournamentId,
            'achievement': 'champion',
          },
        );
      }

    } catch (e) {
      debugPrint('⚠️ Failed to send progression notifications: $e');
    }
  }

  // ==================== PUBLIC UTILITY METHODS ====================

  /// Get next matches cho một player
  Future<List<Map<String, dynamic>>> getPlayerNextMatches(String playerId, String tournamentId) async {
    final matches = await _supabase
        .from('matches')
        .select('*')
        .eq('tournament_id', tournamentId)
        .or('player1_id.eq.$playerId,player2_id.eq.$playerId')
        .inFilter('status', ['ready', 'pending'])
        .order('round_number')
        .order('match_number');

    return matches;
  }

  /// Get tournament progression status
  Future<Map<String, dynamic>> getTournamentProgress(String tournamentId) async {
    final matches = await _supabase
        .from('matches')
        .select('status, round_number')
        .eq('tournament_id', tournamentId);

    final totalMatches = matches.length;
    final completedMatches = matches.where((m) => m['status'] == 'completed').length;
    final ongoingMatches = matches.where((m) => m['status'] == 'ongoing').length;
    final readyMatches = matches.where((m) => m['status'] == 'ready').length;

    return {
      'total_matches': totalMatches,
      'completed_matches': completedMatches,
      'ongoing_matches': ongoingMatches,
      'ready_matches': readyMatches,
      'completion_percentage': totalMatches > 0 ? (completedMatches / totalMatches * 100).round() : 0,
    };
  }
}