// 🎯 CORRECT BRACKET LOGIC SERVICE
// Fix for proper_bracket_service.dart single elimination logic
// Author: SABO v1.0
// Fix date: 2025-01-29

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'tournament_service.dart';
import '../models/user_profile.dart';

class CorrectBracketLogicService {
  static const String _tag = 'CorrectBracketLogic';
  final _supabase = Supabase.instance.client;

  static CorrectBracketLogicService? _instance;
  static CorrectBracketLogicService get instance => _instance ??= CorrectBracketLogicService._();
  CorrectBracketLogicService._();

  // ==================== SINGLE ELIMINATION FIXES ====================

  /// Generate single elimination bracket with hardcore advancement
  Future<Map<String, dynamic>> generateSingleEliminationBracket({
    required String tournamentId,
    required List<Map<String, dynamic>> participants,
  }) async {
    try {
      debugPrint('$_tag: 🚀 Generating HARDCORE ADVANCEMENT single elimination bracket for ${participants.length} participants');
      
      if (participants.isEmpty) {
        throw Exception('No participants provided for bracket generation');
      }

      // Use TournamentService for hardcore advancement
      final tournamentService = TournamentService.instance;
      
      // Use direct method call to generate hardcore advancement bracket  
      final result = await _generateHardcoreAdvancementBracket(
        tournamentId,
        participants,
      );
      
      debugPrint('$_tag: ✅ Hardcore advancement bracket generated: ${result['totalMatches']} matches');
      
      return {
        'success': true,
        'message': 'Hardcore advancement bracket created with ${result['totalMatches']} matches across ${result['rounds']} rounds',
        'totalMatches': result['totalMatches'],
        'rounds': result['rounds'],
      };

    } catch (e) {
      debugPrint('$_tag: ❌ Hardcore advancement bracket generation failed: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Create Round 1 matches from participants
  Future<List<Map<String, dynamic>>> _createRound1Matches(
    String tournamentId,
    List<Map<String, dynamic>> participants,
  ) async {
    final matchCount = participants.length ~/ 2;
    final matches = <Map<String, dynamic>>[];

    for (int i = 0; i < matchCount; i++) {
      final player1 = participants[i * 2];
      final player2 = participants[i * 2 + 1];

      final matchData = {
        'tournament_id': tournamentId,
        'round_number': 1,
        'match_number': i + 1,
        'bracket_position': i + 1,
        'player1_id': player1['user_id'],
        'player2_id': player2['user_id'],
        'winner_id': null,
        'status': 'pending',
        'match_type': 'tournament',
        'format': 'single_elimination',
        'scheduled_time': null,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      matches.add(matchData);
    }

    if (matches.isNotEmpty) {
      await _supabase.from('matches').insert(matches);
      debugPrint('$_tag: ✅ Created ${matches.length} Round 1 matches');
    }

    return matches;
  }

  // ==================== SINGLE ELIMINATION FIXES ====================

  /// FIXED: Create next round matches with CORRECT single elimination logic
  /// Problem: proper_bracket_service uses winners.length ~/ 2
  /// Fix: Single elimination always has n/2 matches for n players in each round
  Future<Map<String, dynamic>> createNextRoundMatches({
    required String tournamentId,
    required int completedRound,
  }) async {
    try {
      debugPrint('$_tag: 🔧 FIXED: Creating Round ${completedRound + 1} matches after Round $completedRound completion');

      // Get winners from completed round
      final winners = await _getRoundWinners(tournamentId, completedRound);
      if (winners.isEmpty) {
        throw Exception('No winners found from Round $completedRound');
      }

      debugPrint('$_tag: 🏆 Found ${winners.length} winners from Round $completedRound');

      // CRITICAL FIX: Check tournament completion logic
      if (winners.length == 1) {
        await _completeTournament(tournamentId, winners.first);
        return {
          'success': true,
          'message': 'Tournament completed! Winner: ${winners.first['full_name']}',
          'tournamentComplete': true,
          'winner': winners.first,
        };
      }

      // FIXED: Single elimination must create winners.length / 2 matches
      // 8 winners → 4 matches (Round 2)
      // 4 winners → 2 matches (Round 3)  
      // 2 winners → 1 match (Finals)
      if (winners.length % 2 != 0) {
        throw Exception('Invalid single elimination: ${winners.length} winners cannot be paired evenly');
      }

      final nextRound = completedRound + 1;
      final nextRoundMatches = await _createCorrectNextRoundMatches(
        tournamentId: tournamentId,
        roundNumber: nextRound,
        winners: winners,
      );

      debugPrint('$_tag: ✅ FIXED: Created ${nextRoundMatches.length} matches for Round $nextRound (from ${winners.length} winners)');

      return {
        'success': true,
        'message': 'FIXED: Created ${nextRoundMatches.length} matches for Round $nextRound',
        'nextRound': nextRound,
        'matchesCreated': nextRoundMatches.length,
        'winnersInput': winners.length,
      };

    } catch (e) {
      debugPrint('$_tag: ❌ Error creating next round: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// FIXED: Create matches for next round with CORRECT pairing logic
  Future<List<Map<String, dynamic>>> _createCorrectNextRoundMatches({
    required String tournamentId,
    required int roundNumber,
    required List<Map<String, dynamic>> winners,
  }) async {
    // FIXED: Single elimination logic - always winners.length / 2 matches
    final matchCount = winners.length ~/ 2;
    final matches = <Map<String, dynamic>>[];

    debugPrint('$_tag: 🎯 FIXED: Creating $matchCount matches from ${winners.length} winners for Round $roundNumber');

    for (int i = 0; i < matchCount; i++) {
      final player1 = winners[i * 2];
      final player2 = winners[i * 2 + 1];

      final matchData = {
        'id': _generateMatchId(),
        'tournament_id': tournamentId,
        'round_number': roundNumber,
        'match_number': i + 1,
        'bracket_position': i + 1,
        'player1_id': player1['id'],
        'player2_id': player2['id'],
        'winner_id': null,
        'status': 'pending',
        'match_type': 'tournament',
        'format': 'single_elimination',
        'scheduled_time': null,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      matches.add(matchData);
      debugPrint('$_tag: 🔧 Match ${i + 1}: ${player1['full_name']} vs ${player2['full_name']}');
    }

    if (matches.isNotEmpty) {
      await _supabase.from('matches').insert(matches);
      debugPrint('$_tag: ✅ FIXED: Successfully inserted ${matches.length} matches for Round $roundNumber');
    }

    return matches;
  }

  /// Get winners from completed round (same logic as original)
  Future<List<Map<String, dynamic>>> _getRoundWinners(String tournamentId, int round) async {
    final response = await _supabase
        .from('matches')
        .select('''
          winner_id,
          winner:users!winner_id (
            id,
            full_name,
            username,
            avatar_url,
            rank_points
          )
        ''')
        .eq('tournament_id', tournamentId)
        .eq('round_number', round)
        .eq('status', 'completed')
        .not('winner_id', 'is', null);

    if (response.isEmpty) {
      return [];
    }

    return response.map((match) => match['winner'] as Map<String, dynamic>).toList();
  }

  /// Complete tournament (same logic as original)
  Future<void> _completeTournament(String tournamentId, Map<String, dynamic> winner) async {
    await _supabase
        .from('tournaments')
        .update({
          'status': 'completed',
          'winner_id': winner['id'],
          'end_date': DateTime.now().toIso8601String(),
        })
        .eq('id', tournamentId);

    debugPrint('$_tag: 🏆 Tournament completed! Winner: ${winner['full_name']}');
  }

  /// Generate match ID (same logic as original)
  String _generateMatchId() {
    return 'match_${DateTime.now().millisecondsSinceEpoch}_${(1000 + (999 * 0.5)).round()}';
  }

  // ==================== BRACKET VALIDATION ====================

  /// Validate single elimination bracket structure
  Future<Map<String, dynamic>> validateBracketStructure(String tournamentId) async {
    try {
      // Get all matches grouped by round
      final response = await _supabase
          .from('matches')
          .select('round_number, match_number, status, player1_id, player2_id, winner_id')
          .eq('tournament_id', tournamentId)
          .order('round_number')
          .order('match_number');

      final matchesByRound = <int, List<Map<String, dynamic>>>{};
      for (var match in response) {
        final round = match['round_number'] as int;
        matchesByRound.putIfAbsent(round, () => []).add(match);
      }

      // Get participant count
      final participantResponse = await _supabase
          .from('tournament_participants')
          .select('id')
          .eq('tournament_id', tournamentId);
      
      final participantCount = participantResponse.length;
      final expectedTotalMatches = participantCount - 1; // n-1 rule

      // Calculate expected matches per round
      var currentPlayers = participantCount;
      final expectedRounds = <int, int>{};
      int round = 1;
      
      while (currentPlayers > 1) {
        final matchesInRound = currentPlayers ~/ 2;
        expectedRounds[round] = matchesInRound;
        currentPlayers = matchesInRound;
        round++;
      }

      // Validate structure
      final validation = {
        'tournamentId': tournamentId,
        'participantCount': participantCount,
        'expectedTotalMatches': expectedTotalMatches,
        'actualTotalMatches': response.length,
        'isValid': response.length == expectedTotalMatches,
        'expectedRounds': expectedRounds,
        'actualRounds': matchesByRound.map((k, v) => MapEntry(k, v.length)),
        'roundValidation': <int, bool>{},
      };

      // Check each round
      for (var entry in expectedRounds.entries) {
        final round = entry.key;
        final expectedMatches = entry.value;
        final actualMatches = matchesByRound[round]?.length ?? 0;
        (validation['roundValidation'] as Map<int, bool>)[round] = actualMatches == expectedMatches;
      }

      return validation;

    } catch (e) {
      return {
        'error': e.toString(),
        'isValid': false,
      };
    }
  }

  // ==================== BRACKET REPAIR ====================

  /// Fix existing tournament with incorrect bracket structure
  Future<Map<String, dynamic>> repairTournamentBracket(String tournamentId) async {
    try {
      debugPrint('$_tag: 🔧 Starting bracket repair for tournament $tournamentId');

      // First validate current structure
      final validation = await validateBracketStructure(tournamentId);
      if (validation['isValid'] == true) {
        return {
          'success': true,
          'message': 'Tournament bracket is already valid',
          'noRepairNeeded': true,
        };
      }

      debugPrint('$_tag: 🚨 Invalid bracket detected, starting repair...');
      debugPrint('$_tag: Expected: ${validation['expectedTotalMatches']}, Actual: ${validation['actualTotalMatches']}');

      // Get current round 1 matches (these should be correct)
      final round1Matches = await _supabase
          .from('matches')
          .select('*')
          .eq('tournament_id', tournamentId)
          .eq('round_number', 1);

      if (round1Matches.isEmpty) {
        throw Exception('No Round 1 matches found - cannot repair');
      }

      debugPrint('$_tag: ✅ Found ${round1Matches.length} Round 1 matches');

      // Delete all matches after Round 1 (they're incorrectly generated)
      await _supabase
          .from('matches')
          .delete()
          .eq('tournament_id', tournamentId)
          .gt('round_number', 1);

      debugPrint('$_tag: 🗑️ Deleted incorrect matches from Round 2+');

      // Progressively create correct rounds based on completed matches
      await _progressivelyCreateRounds(tournamentId);

      return {
        'success': true,
        'message': 'Tournament bracket repaired successfully',
        'round1Preserved': round1Matches.length,
      };

    } catch (e) {
      debugPrint('$_tag: ❌ Bracket repair failed: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Progressively create rounds based on completed matches
  Future<void> _progressivelyCreateRounds(String tournamentId) async {
    int currentRound = 1;
    
    while (true) {
      // Check if current round is complete
      final roundMatches = await _supabase
          .from('matches')
          .select('*')
          .eq('tournament_id', tournamentId)
          .eq('round_number', currentRound);

      if (roundMatches.isEmpty) {
        debugPrint('$_tag: ✅ No more rounds to process');
        break;
      }

      final completedMatches = roundMatches.where((m) => m['status'] == 'completed').toList();
      
      if (completedMatches.length == roundMatches.length) {
        // Round is complete, create next round
        final result = await createNextRoundMatches(
          tournamentId: tournamentId,
          completedRound: currentRound,
        );

        if (result['tournamentComplete'] == true) {
          debugPrint('$_tag: 🏆 Tournament repair complete - winner determined');
          break;
        }
        
        debugPrint('$_tag: ✅ Created Round ${currentRound + 1} with ${result['matchesCreated']} matches');
        currentRound++;
      } else {
        debugPrint('$_tag: ⏸️ Round $currentRound not complete yet (${completedMatches.length}/${roundMatches.length})');
        break;
      }
    }
  }

  /// Generate hardcore advancement bracket - complete tournament structure
  Future<Map<String, dynamic>> _generateHardcoreAdvancementBracket(
    String tournamentId,
    List<Map<String, dynamic>> participants,
  ) async {
    try {
      debugPrint('$_tag: 🚀 Creating hardcore advancement bracket');
      
      final participantCount = participants.length;
      final totalMatches = participantCount - 1; // n-1 rule
      final rounds = _calculateRounds(participantCount);
      
      debugPrint('$_tag: 📊 Creating $totalMatches matches across $rounds rounds');
      
      // Create all matches with hardcore advancement
      final allMatches = <Map<String, dynamic>>[];
      final hardcoreAdvancement = <String, Map<String, dynamic>>{};
      
      int matchCounter = 1;
      
      // Round 1: Real players
      final round1MatchCount = participantCount ~/ 2;
      for (int i = 0; i < round1MatchCount; i++) {
        final player1 = participants[i * 2];
        final player2 = participants[i * 2 + 1];
        
        final match = await _createMatch(
          tournamentId: tournamentId,
          round: 1,
          matchNumber: matchCounter,
          player1Id: player1['user_id'],
          player2Id: player2['user_id'],
        );
        
        allMatches.add(match);
        matchCounter++;
      }
      
      // Rounds 2+: Winner references
      int currentRoundMatches = round1MatchCount;
      for (int round = 2; round <= rounds; round++) {
        final nextRoundMatches = currentRoundMatches ~/ 2;
        
        for (int i = 0; i < nextRoundMatches; i++) {
          final prevMatch1 = ((round - 2) * round1MatchCount ~/ (1 << (round - 2))) + (i * 2) + 1;
          final prevMatch2 = prevMatch1 + 1;
          
          final winnerRef1 = 'WINNER_FROM_R${round - 1}M$prevMatch1';
          final winnerRef2 = 'WINNER_FROM_R${round - 1}M$prevMatch2';
          
          final match = await _createMatch(
            tournamentId: tournamentId,
            round: round,
            matchNumber: matchCounter,
            player1Id: winnerRef1,
            player2Id: winnerRef2,
          );
          
          allMatches.add(match);
          
          // Store hardcore advancement mapping
          final matchKey = 'R${round}M$matchCounter';
          hardcoreAdvancement[matchKey] = {
            'player1_winner_from': winnerRef1,
            'player2_winner_from': winnerRef2,
          };
          
          matchCounter++;
        }
        
        currentRoundMatches = nextRoundMatches;
      }
      
      debugPrint('$_tag: ✅ Created ${allMatches.length} matches with hardcore advancement');
      
      return {
        'matches': allMatches,
        'hardcoreAdvancement': hardcoreAdvancement,
        'totalMatches': allMatches.length,
        'rounds': rounds,
      };
      
    } catch (e) {
      debugPrint('$_tag: ❌ Hardcore advancement generation failed: $e');
      throw Exception('Failed to generate hardcore advancement bracket: $e');
    }
  }

  /// Calculate number of rounds needed
  int _calculateRounds(int participantCount) {
    int rounds = 0;
    int remaining = participantCount;
    while (remaining > 1) {
      remaining = remaining ~/ 2;
      rounds++;
    }
    return rounds;
  }

  /// Create a single match in database
  Future<Map<String, dynamic>> _createMatch({
    required String tournamentId,
    required int round,
    required int matchNumber,
    required String player1Id,
    required String player2Id,
  }) async {
    try {
      final matchData = {
        'tournament_id': tournamentId,
        'round': round,
        'match_number': matchNumber,
        'player1_id': player1Id,
        'player2_id': player2Id,
        'status': 'pending',
        'format': 'single_elimination',
        'created_at': DateTime.now().toIso8601String(),
      };
      
      final result = await Supabase.instance.client
          .from('matches')
          .insert(matchData)
          .select()
          .single();
      
      return result;
      
    } catch (e) {
      debugPrint('$_tag: ❌ Failed to create match R${round}M$matchNumber: $e');
      throw Exception('Failed to create match: $e');
    }
  }
}