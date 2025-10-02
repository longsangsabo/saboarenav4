import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math' as math;

/// Simple Single Elimination Service với hardcoded advancement
/// Tạo toàn bộ bracket ngay từ đầu với tất cả rounds
class SimpleSingleEliminationService {
  static const String _tag = 'SimpleSE';
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Tạo bracket single elimination hoàn chỉnh
  Future<Map<String, dynamic>> createBracket({
    required String tournamentId,
    required List<String> participantIds,
  }) async {
    try {
      debugPrint('$_tag: 🎯 Creating Single Elimination bracket for ${participantIds.length} players');

      // Validate participants
      if (participantIds.length < 2) {
        throw Exception('Need at least 2 participants');
      }

      if (!_isPowerOfTwo(participantIds.length)) {
        throw Exception('Participant count must be power of 2 (2, 4, 8, 16, 32...)');
      }

      // Calculate tournament structure
      final totalRounds = _calculateTotalRounds(participantIds.length);
      debugPrint('$_tag: Total rounds needed: $totalRounds');

      // Generate all matches for all rounds
      final allMatches = <Map<String, dynamic>>[];
      int matchCounter = 1;

      for (int round = 1; round <= totalRounds; round++) {
        final matchesInRound = _calculateMatchesInRound(participantIds.length, round);
        debugPrint('$_tag: Round $round needs $matchesInRound matches');

        for (int matchInRound = 1; matchInRound <= matchesInRound; matchInRound++) {
          final match = {
            'tournament_id': tournamentId,
            'round_number': round,
            'match_number': matchCounter,
            'player1_id': null,
            'player2_id': null,
            'winner_id': null,
            'player1_score': 0,
            'player2_score': 0,
            'status': 'pending',
            'match_type': 'tournament',
            'created_at': DateTime.now().toIso8601String(),
          };

          allMatches.add(match);
          matchCounter++;
        }
      }

      // Assign players to Round 1
      _assignPlayersToRound1(allMatches, participantIds);

      // Save all matches to database
      final insertedMatches = await _supabase
          .from('matches')
          .insert(allMatches)
          .select();

      debugPrint('$_tag: ✅ Created ${insertedMatches.length} matches');

      return {
        'success': true,
        'message': 'Single Elimination bracket created',
        'total_rounds': totalRounds,
        'total_matches': insertedMatches.length,
      };

    } catch (e) {
      debugPrint('$_tag: ❌ Error: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Check if number is power of 2
  bool _isPowerOfTwo(int n) {
    return n > 0 && (n & (n - 1)) == 0;
  }

  /// Calculate total rounds
  int _calculateTotalRounds(int playerCount) {
    return (math.log(playerCount) / math.log(2)).toInt();
  }

  /// Calculate matches in specific round
  int _calculateMatchesInRound(int totalPlayers, int round) {
    return totalPlayers ~/ math.pow(2, round).toInt();
  }

  /// Assign players to Round 1 matches
  void _assignPlayersToRound1(List<Map<String, dynamic>> allMatches, List<String> participantIds) {
    final round1Matches = allMatches.where((m) => m['round_number'] == 1).toList();
    
    for (int i = 0; i < round1Matches.length; i++) {
      round1Matches[i]['player1_id'] = participantIds[i * 2];
      round1Matches[i]['player2_id'] = participantIds[i * 2 + 1];
      round1Matches[i]['status'] = 'ready';
    }

    debugPrint('$_tag: ✅ Assigned ${participantIds.length} players to ${round1Matches.length} Round 1 matches');
  }
}
