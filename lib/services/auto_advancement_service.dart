import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service tự động advance winner dựa trên winner_advances_to column
/// Đọc từ database và tự động đẩy winner vào match tiếp theo
class AutoAdvancementService {
  static const String _tag = 'AutoAdvance';
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Advance winner sau khi match completed
  Future<Map<String, dynamic>> advanceWinner({
    required String completedMatchId,
    required String winnerId,
  }) async {
    try {
      debugPrint('$_tag: 🚀 Auto-advancing winner $winnerId from match $completedMatchId');

      // 1. Get completed match info including winner_advances_to
      final completedMatch = await _supabase
          .from('matches')
          .select('id, match_number, round_number, winner_advances_to, tournament_id')
          .eq('id', completedMatchId)
          .single();

      final winnerAdvancesTo = completedMatch['winner_advances_to'] as int?;
      final tournamentId = completedMatch['tournament_id'] as String;
      final currentMatchNumber = completedMatch['match_number'] as int;
      final currentRound = completedMatch['round_number'] as int;

      if (winnerAdvancesTo == null) {
        debugPrint('$_tag: 🏆 This is the FINAL match - no advancement needed');
        
        // Update tournament with winner
        await _supabase
            .from('tournaments')
            .update({
              'winner_id': winnerId,
              'status': 'completed',
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', tournamentId);

        return {
          'success': true,
          'is_final': true,
          'tournament_winner': winnerId,
          'message': 'Tournament completed! Winner: $winnerId',
        };
      }

      debugPrint('$_tag: 📍 Current: Match $currentMatchNumber (Round $currentRound)');
      debugPrint('$_tag: ➡️  Advancing to: Match $winnerAdvancesTo');

      // 2. Find target match
      final targetMatches = await _supabase
          .from('matches')
          .select('id, match_number, round_number, player1_id, player2_id, status')
          .eq('tournament_id', tournamentId)
          .eq('match_number', winnerAdvancesTo);

      if (targetMatches.isEmpty) {
        throw Exception('Target match $winnerAdvancesTo not found!');
      }

      final targetMatch = targetMatches.first;
      final targetMatchId = targetMatch['id'] as String;
      final player1Id = targetMatch['player1_id'] as String?;
      final player2Id = targetMatch['player2_id'] as String?;

      // 3. Determine which slot to fill
      Map<String, dynamic> updateData = {};
      String slot = '';

      if (player1Id == null) {
        updateData['player1_id'] = winnerId;
        slot = 'Player 1';
      } else if (player2Id == null) {
        updateData['player2_id'] = winnerId;
        slot = 'Player 2';
      } else {
        debugPrint('$_tag: ⚠️  Target match already has both players!');
        return {
          'success': false,
          'error': 'Target match $winnerAdvancesTo is already full',
        };
      }

      // 4. Update target match
      await _supabase
          .from('matches')
          .update(updateData)
          .eq('id', targetMatchId);

      debugPrint('$_tag: ✅ Winner placed as $slot in Match $winnerAdvancesTo');

      // 5. Check if target match is now ready (both players assigned)
      final updatedTargetMatch = await _supabase
          .from('matches')
          .select('player1_id, player2_id')
          .eq('id', targetMatchId)
          .single();

      final isTargetReady = updatedTargetMatch['player1_id'] != null && 
                           updatedTargetMatch['player2_id'] != null;

      if (isTargetReady) {
        await _supabase
            .from('matches')
            .update({'status': 'ready'})
            .eq('id', targetMatchId);

        debugPrint('$_tag: 🎯 Match $winnerAdvancesTo is now READY to play!');
      } else {
        debugPrint('$_tag: ⏳ Match $winnerAdvancesTo waiting for opponent...');
      }

      return {
        'success': true,
        'is_final': false,
        'advanced_to_match': winnerAdvancesTo,
        'target_match_ready': isTargetReady,
        'slot_filled': slot,
        'message': 'Winner advanced to Match $winnerAdvancesTo as $slot',
      };

    } catch (e) {
      debugPrint('$_tag: ❌ Error advancing winner: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}
