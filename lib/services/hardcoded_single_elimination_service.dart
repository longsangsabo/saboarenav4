import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math' as math;

/// Hardcoded Single Elimination Service với advancement được tính sẵn
/// Mỗi match biết trước winner sẽ đi vào match nào ở round tiếp theo
class HardcodedSingleEliminationService {
  static const String _tag = 'HardcodedSE';
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Tạo bracket với hardcoded advancement mapping
  Future<Map<String, dynamic>> createBracketWithAdvancement({
    required String tournamentId,
    required List<String> participantIds,
  }) async {
    try {
      debugPrint('$_tag: 🎯 Creating Single Elimination bracket with HARDCODED advancement');
      debugPrint('$_tag: Tournament: $tournamentId');
      debugPrint('$_tag: Participants: ${participantIds.length} players');

      // Validate
      if (participantIds.length < 2) {
        throw Exception('Need at least 2 participants');
      }

      if (!_isPowerOfTwo(participantIds.length)) {
        throw Exception('Participant count must be power of 2 (2, 4, 8, 16, 32...)');
      }

      // Calculate structure
      final totalRounds = _calculateTotalRounds(participantIds.length);
      final totalMatches = participantIds.length - 1; // n players = n-1 matches
      
      debugPrint('$_tag: 📊 Structure: $totalRounds rounds, $totalMatches total matches');

      // Generate advancement map first
      final advancementMap = _calculateAdvancementMap(participantIds.length);
      debugPrint('$_tag: 🔗 Advancement map created: ${advancementMap.length} mappings');

      // Generate all matches with advancement info
      final allMatches = <Map<String, dynamic>>[];
      int matchCounter = 1;

      for (int round = 1; round <= totalRounds; round++) {
        final matchesInRound = _calculateMatchesInRound(participantIds.length, round);
        
        for (int matchInRound = 1; matchInRound <= matchesInRound; matchInRound++) {
          final currentMatchNumber = matchCounter;
          final nextMatchNumber = advancementMap[currentMatchNumber];
          
          // Calculate display_order: (bracket_priority * 1000) + (stage_round * 100) + position
          // For Single Elimination (Winner Bracket only): priority = 1
          final displayOrder = (1 * 1000) + (round * 100) + matchInRound;
          
          final match = {
            'tournament_id': tournamentId,
            'round_number': round,
            'match_number': currentMatchNumber,
            'player1_id': null,
            'player2_id': null,
            'winner_id': null,
            'player1_score': 0,
            'player2_score': 0,
            'status': 'pending',
            'match_type': 'tournament',
            'winner_advances_to': nextMatchNumber, // ✅ STANDARDIZED: display_order value
            'bracket_format': 'single_elimination',
            // 🔥 STANDARDIZED FIELDS
            'bracket_type': 'WB', // Winner Bracket (Single Elimination only has winner bracket)
            'bracket_group': null, // No groups in Single Elimination
            'stage_round': round, // Normalized round number (1, 2, 3, 4...)
            'display_order': displayOrder, // For UI sorting
            'created_at': DateTime.now().toIso8601String(),
          };

          allMatches.add(match);
          matchCounter++;
          
          if (nextMatchNumber != null) {
            debugPrint('$_tag:   Match $currentMatchNumber (R$round-M$matchInRound) [Order:$displayOrder] → advances to display_order $nextMatchNumber');
          } else {
            debugPrint('$_tag:   Match $currentMatchNumber (R$round-M$matchInRound) [Order:$displayOrder] → FINAL (no advancement)');
          }
        }
      }

      // Assign players to Round 1
      _assignPlayersToRound1(allMatches, participantIds);

      // Save to database
      debugPrint('$_tag: 💾 Saving ${allMatches.length} matches to database...');
      
      final insertedMatches = await _supabase
          .from('matches')
          .insert(allMatches)
          .select();

      debugPrint('$_tag: ✅ Bracket created successfully!');
      debugPrint('$_tag: 📊 Summary:');
      debugPrint('$_tag:    - Total rounds: $totalRounds');
      debugPrint('$_tag:    - Total matches: ${insertedMatches.length}');
      debugPrint('$_tag:    - Matches with advancement: ${advancementMap.length}');
      debugPrint('$_tag:    - Final match: Match $totalMatches');

      return {
        'success': true,
        'message': 'Single Elimination bracket created with hardcoded advancement',
        'total_rounds': totalRounds,
        'total_matches': insertedMatches.length,
        'advancement_mappings': advancementMap.length,
      };

    } catch (e) {
      debugPrint('$_tag: ❌ Error: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// 🔥 STANDARDIZED: Calculate advancement map using display_order
  /// Returns: matchNumber -> winner_advances_to_display_order
  Map<int, int?> _calculateAdvancementMap(int playerCount) {
    final map = <int, int?>{};
    final totalRounds = _calculateTotalRounds(playerCount);
    
    int matchNumber = 1;
    
    for (int round = 1; round <= totalRounds; round++) {
      final matchesInRound = _calculateMatchesInRound(playerCount, round);
      
      for (int matchInRound = 1; matchInRound <= matchesInRound; matchInRound++) {
        final currentMatchNumber = matchNumber;
        
        if (round < totalRounds) {
          // Calculate target match in next round
          final nextRound = round + 1;
          final nextMatchInRound = ((matchInRound - 1) ~/ 2) + 1; // Which match in next round
          
          // ✅ STANDARDIZED: Use display_order instead of match_number
          // Formula: (bracket_priority * 1000) + (stage_round * 100) + match_in_round
          final targetDisplayOrder = (1 * 1000) + (nextRound * 100) + nextMatchInRound;
          
          map[currentMatchNumber] = targetDisplayOrder;
        } else {
          // Final match - no advancement
          map[currentMatchNumber] = null;
        }
        
        matchNumber++;
      }
    }
    
    return map;
  }

  /// Check if number is power of 2
  bool _isPowerOfTwo(int n) {
    return n > 0 && (n & (n - 1)) == 0;
  }

  /// Calculate total rounds needed
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
      round1Matches[i]['status'] = 'pending'; // Changed from 'ready' to 'pending' to match database enum
      
      debugPrint('$_tag: 👥 Match ${round1Matches[i]['match_number']}: '
          '${participantIds[i * 2].substring(0, 8)} vs ${participantIds[i * 2 + 1].substring(0, 8)}');
    }
  }
}
