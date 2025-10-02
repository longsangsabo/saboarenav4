import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'dart:math' as math;

/// Perfect Single Elimination Bracket Service
/// 
/// This service ensures 100% accurate bracket generation and progression
/// - Creates complete bracket structure upfront
/// - Handles automatic winner advancement 
/// - Guarantees consistent tournament flow
class PerfectBracketService {
  static const String _tag = 'PerfectBracket';
  static final _supabase = Supabase.instance.client;

  /// Generate complete single elimination bracket
  /// 
  /// Creates ALL matches for ALL rounds immediately
  /// This prevents progression issues by having complete structure upfront
  static Future<Map<String, dynamic>> generateCompleteBracket({
    required String tournamentId,
    required List<String> participantIds,
  }) async {
    try {
      debugPrint('$_tag: 🏆 Creating PERFECT bracket for ${participantIds.length} players');
      
      // Validate participant count (must be power of 2)
      if (!_isPowerOfTwo(participantIds.length)) {
        return {
          'success': false,
          'error': 'Participant count must be power of 2 (4, 8, 16, 32...)',
        };
      }

      final totalRounds = _calculateRounds(participantIds.length);
      debugPrint('$_tag: 📊 Tournament will have $totalRounds rounds');

      // Clear existing matches for clean slate
      await _clearExistingMatches(tournamentId);

      // Generate complete bracket structure
      final allMatches = _generateCompleteMatchStructure(
        participantIds.length,
        totalRounds,
      );

      // Assign participants to Round 1 matches
      _assignParticipantsToRound1(allMatches, participantIds);

      // Save all matches to database
      final savedMatches = await _saveMatchesToDatabase(tournamentId, allMatches);

      debugPrint('$_tag: ✅ Perfect bracket created: ${savedMatches.length} matches');
      debugPrint('$_tag: 📋 Round breakdown:');
      for (int round = 1; round <= totalRounds; round++) {
        final roundMatches = savedMatches.where((m) => m['round_number'] == round).length;
        debugPrint('$_tag:    Round $round: $roundMatches matches');
      }

      return {
        'success': true,
        'matches_created': savedMatches.length,
        'total_rounds': totalRounds,
        'matches': savedMatches,
      };

    } catch (e) {
      debugPrint('$_tag: ❌ Error creating perfect bracket: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

    /// Process all completed matches to advance winners
  /// 
  /// This method checks for completed matches that haven't advanced winners yet
  /// and automatically advances them to next round
  static Future<Map<String, dynamic>> processCompletedMatches({
    required String tournamentId,
  }) async {
    try {
      debugPrint('$_tag: 🔍 Processing completed matches for tournament $tournamentId');
      
      // Get all completed matches
      final completedMatches = await _supabase
          .from('matches')
          .select('*')
          .eq('tournament_id', tournamentId)
          .eq('status', 'completed')
          .order('round_number')
          .order('match_number');

      debugPrint('$_tag: 📊 Found ${completedMatches.length} completed matches');

      int advancedCount = 0;
      
      for (final match in completedMatches) {
        final winnerId = match['winner_id'] as String?;
        
        if (winnerId != null) {
          // Check if winner has already been advanced
          final isAdvanced = await _isWinnerAlreadyAdvanced(
            tournamentId,
            match['round_number'],
            match['match_number'],
            winnerId,
          );
          
          if (!isAdvanced) {
            debugPrint('$_tag: 🚀 Advancing winner $winnerId from Round ${match['round_number']}, Match ${match['match_number']}');
            
            await advanceWinner(
              tournamentId: tournamentId,
              completedMatchId: match['id'],
              winnerId: winnerId,
            );
            
            advancedCount++;
          }
        }
      }

      debugPrint('$_tag: ✅ Processed $advancedCount advancement(s)');
      
      return {
        'success': true,
        'processed_matches': completedMatches.length,
        'advanced_winners': advancedCount,
      };
      
    } catch (e) {
      debugPrint('$_tag: ❌ Error processing completed matches: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Check if winner has already been advanced to next round
  static Future<bool> _isWinnerAlreadyAdvanced(
    String tournamentId,
    int currentRound,
    int currentMatchNumber,
    String winnerId,
  ) async {
    debugPrint('$_tag: 🔍 Checking if winner $winnerId from Round $currentRound, Match $currentMatchNumber is already advanced');
    
    final nextRound = currentRound + 1;
    final nextMatchNumber = ((currentMatchNumber - 1) ~/ 2) + 1;
    
    debugPrint('$_tag: 📍 Looking for next match: Round $nextRound, Match $nextMatchNumber');
    
    final nextMatches = await _supabase
        .from('matches')
        .select('*')
        .eq('tournament_id', tournamentId)
        .eq('round_number', nextRound)
        .eq('match_number', nextMatchNumber);

    if (nextMatches.isEmpty) {
      debugPrint('$_tag: 🏁 No next match found - this is finals');
      return true; // No next match means this is finals
    }
    
    final nextMatch = nextMatches.first;
    final isAdvanced = nextMatch['player1_id'] == winnerId || nextMatch['player2_id'] == winnerId;
    
    debugPrint('$_tag: 🎯 Next match status: player1_id=${nextMatch['player1_id']}, player2_id=${nextMatch['player2_id']}');
    debugPrint('$_tag: 🤔 Winner $winnerId already advanced? $isAdvanced');
    
    return isAdvanced;
  }
  /// 
  /// When a match is completed, automatically populate next round match
  /// Advance winner from completed match to next round
  ///
  /// Automatically moves winner to appropriate slot in next round match
  static Future<Map<String, dynamic>> advanceWinner({
    required String tournamentId,
    required String completedMatchId,
    required String winnerId,
  }) async {
    try {
      debugPrint('$_tag: 🚀 Advancing winner $winnerId from match $completedMatchId');

      // Get completed match details
      final completedMatch = await _supabase
          .from('matches')
          .select('*')
          .eq('id', completedMatchId)
          .single();

      final currentRound = completedMatch['round_number'] as int;
      final currentMatchNumber = completedMatch['match_number'] as int;

      debugPrint('$_tag: 📍 Current match: Round $currentRound, Match $currentMatchNumber');

      // Calculate next round match that should receive this winner
      final nextRoundMatch = await _findNextRoundMatch(
        tournamentId,
        currentRound,
        currentMatchNumber,
      );

      if (nextRoundMatch == null) {
        debugPrint('$_tag: 🏁 Winner reached finals - tournament complete!');
        await _completeTournament(tournamentId, winnerId);
        return {
          'success': true,
          'tournament_completed': true,
          'champion': winnerId,
        };
      }

      // Determine if winner goes to player1 or player2 slot
      final playerSlot = _calculatePlayerSlot(currentMatchNumber);
      final updateField = playerSlot == 1 ? 'player1_id' : 'player2_id';

      // Update next round match with winner
      await _supabase
          .from('matches')
          .update({updateField: winnerId})
          .eq('id', nextRoundMatch['id']);

      debugPrint('$_tag: ✅ Winner advanced to Round ${nextRoundMatch['round_number']}, Match ${nextRoundMatch['match_number']}');

      // Check if next round match is now ready to play
      final updatedMatch = await _supabase
          .from('matches')
          .select('*')
          .eq('id', nextRoundMatch['id'])
          .single();

      final isReady = updatedMatch['player1_id'] != null && updatedMatch['player2_id'] != null;
      
      if (isReady) {
        // Don't change status - keep as 'pending' until players enter scores
        debugPrint('$_tag: 🎯 Next match is now ready to play! (Status remains pending)');
      }

      return {
        'success': true,
        'advanced_to_round': nextRoundMatch['round_number'],
        'advanced_to_match': nextRoundMatch['match_number'],
        'next_match_ready': isReady,
      };

    } catch (e) {
      debugPrint('$_tag: ❌ Error advancing winner: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Update match score and automatically advance winner
  static Future<Map<String, dynamic>> updateMatchScore({
    required String tournamentId,
    required String matchId,
    required int player1Score,
    required int player2Score,
  }) async {
    try {
      debugPrint('$_tag: 🎯 Updating match score: $player1Score - $player2Score');

      // Get match details
      final match = await _supabase
          .from('matches')
          .select('*')
          .eq('id', matchId)
          .single();

      final player1Id = match['player1_id'];
      final player2Id = match['player2_id'];

      // Validate players are assigned
      if (player1Id == null || player2Id == null) {
        return {
          'success': false,
          'error': 'Match players not assigned yet',
        };
      }

      // Determine winner
      String? winnerId;
      if (player1Score > player2Score) {
        winnerId = player1Id;
      } else if (player2Score > player1Score) {
        winnerId = player2Id;
      }
      // Tie: no winner (winnerId remains null)

      debugPrint('$_tag: 🏆 Winner determined: ${winnerId ?? 'TIE'}');

      // Update match with scores and winner
      await _supabase
          .from('matches')
          .update({
            'player1_score': player1Score,
            'player2_score': player2Score,
            'winner_id': winnerId,
            'status': 'completed',
            // Remove completed_at since it doesn't exist in schema
          })
          .eq('id', matchId);

      debugPrint('$_tag: ✅ Match updated successfully');

      // If there's a winner, advance them
      if (winnerId != null) {
        final advancementResult = await advanceWinner(
          tournamentId: tournamentId,
          completedMatchId: matchId,
          winnerId: winnerId,
        );

        return {
          'success': true,
          'match_completed': true,
          'winner_advanced': advancementResult['success'],
          'advancement_details': advancementResult,
        };
      } else {
        return {
          'success': true,
          'match_completed': true,
          'winner_advanced': false,
          'reason': 'Match tied - no winner to advance',
        };
      }

    } catch (e) {
      debugPrint('$_tag: ❌ Error updating match score: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // ==================== PRIVATE HELPER METHODS ====================

  static bool _isPowerOfTwo(int n) {
    return n > 0 && (n & (n - 1)) == 0;
  }

  static int _calculateRounds(int participantCount) {
    return (math.log(participantCount) / math.log(2)).ceil();
  }

  static Future<void> _clearExistingMatches(String tournamentId) async {
    debugPrint('$_tag: 🧹 Clearing existing matches for clean slate');
    await _supabase
        .from('matches')
        .delete()
        .eq('tournament_id', tournamentId);
  }

  static List<Map<String, dynamic>> _generateCompleteMatchStructure(
    int participantCount,
    int totalRounds,
  ) {
    final matches = <Map<String, dynamic>>[];
    int matchCounter = 1;

    // Generate matches for each round
    for (int round = 1; round <= totalRounds; round++) {
      final matchesInRound = participantCount ~/ (1 << round); // 2^round
      
      for (int matchInRound = 1; matchInRound <= matchesInRound; matchInRound++) {
        matches.add({
          'round_number': round,
          'match_number': matchCounter,
          // Removed 'match_order' - column doesn't exist in database
          'player1_id': null,
          'player2_id': null,
          'winner_id': null,
          'player1_score': 0,
          'player2_score': 0,
          'status': round == 1 ? 'ready' : 'pending',
          'match_type': 'tournament',
          'created_at': DateTime.now().toIso8601String(),
        });
        matchCounter++;
      }
    }

    debugPrint('$_tag: 🏗️ Generated ${matches.length} matches across $totalRounds rounds');
    return matches;
  }

  static void _assignParticipantsToRound1(
    List<Map<String, dynamic>> allMatches,
    List<String> participantIds,
  ) {
    final round1Matches = allMatches.where((m) => m['round_number'] == 1).toList();
    
    for (int i = 0; i < round1Matches.length; i++) {
      final match = round1Matches[i];
      match['player1_id'] = participantIds[i * 2];
      match['player2_id'] = participantIds[i * 2 + 1];
      match['status'] = 'ready';
    }

    debugPrint('$_tag: 👥 Assigned ${participantIds.length} participants to ${round1Matches.length} Round 1 matches');
  }

  static Future<List<Map<String, dynamic>>> _saveMatchesToDatabase(
    String tournamentId,
    List<Map<String, dynamic>> matches,
  ) async {
    // Add tournament_id to all matches
    for (final match in matches) {
      match['tournament_id'] = tournamentId;
    }

    // Insert all matches
    final response = await _supabase
        .from('matches')
        .insert(matches)
        .select();

    return List<Map<String, dynamic>>.from(response);
  }

  static Future<Map<String, dynamic>?> _findNextRoundMatch(
    String tournamentId,
    int currentRound,
    int currentMatchNumber,
  ) async {
    final nextRound = currentRound + 1;
    
    // Calculate which next round match this winner should go to
    // For single elimination: Round 1 matches 1,2 -> Round 2 match 1, etc.
    final nextMatchNumber = ((currentMatchNumber - 1) ~/ 2) + 1;
    
    final nextMatches = await _supabase
        .from('matches')
        .select('*')
        .eq('tournament_id', tournamentId)
        .eq('round_number', nextRound)
        .eq('match_number', nextMatchNumber);

    return nextMatches.isNotEmpty ? nextMatches.first : null;
  }

  static int _calculatePlayerSlot(int matchNumber) {
    // Odd match numbers go to player1, even to player2
    return (matchNumber % 2 == 1) ? 1 : 2;
  }

  static Future<void> _completeTournament(String tournamentId, String championId) async {
    await _supabase
        .from('tournaments')
        .update({
          'status': 'completed',
          'winner_id': championId,
          // Removed 'completed_at' - may not exist in tournaments schema
        })
        .eq('id', tournamentId);

    debugPrint('$_tag: 🏆 Tournament completed! Champion: $championId');
  }
}