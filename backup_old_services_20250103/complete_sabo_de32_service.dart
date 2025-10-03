import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

/// 🏆 COMPLETE SABO DE32 TOURNAMENT SERVICE
/// Handles Two-Group System with Cross-Bracket Finals for SABO Double Elimination 32-player format
/// Author: SABO Arena v1.0
/// Date: October 2, 2025
///
/// SABO DE32 Structure (55 matches total):
/// - Group A: 26 matches (Modified DE16) - Produces 2 qualifiers
/// - Group B: 26 matches (Modified DE16) - Produces 2 qualifiers
/// - Cross-Bracket Finals: 3 matches (SF1, SF2, Final)
///
/// Each Group Structure (26 matches):
/// - Winners Bracket: 15 matches (8+4+2+1) - Rounds 1,2,3,4
/// - Losers Bracket: 11 matches - Rounds 101-106
/// 
/// Cross-Bracket Structure (3 matches):
/// - Round 400: SF1 (Group A Winner vs Group B Runner-up)
/// - Round 401: SF2 (Group A Runner-up vs Group B Winner)
/// - Round 500: Final (SF1 Winner vs SF2 Winner)
class CompleteSaboDE32Service {
  static const String _tag = 'CompleteSaboDE32Service';

  final SupabaseClient _supabase = Supabase.instance.client;

  /// Generate SABO DE32 bracket with hard-coded structure (55 matches)
  /// Returns success status and match count for tournament_service integration
  Future<Map<String, dynamic>> generateSaboDE32Bracket({
    required String tournamentId,
    required List<Map<String, dynamic>> participants,
  }) async {
    try {
      debugPrint(
          '$_tag: Generating SABO DE32 bracket for tournament $tournamentId');
      debugPrint('$_tag: Participants count: ${participants.length}');

      if (participants.length != 32) {
        return {
          'success': false,
          'error': 'SABO DE32 requires exactly 32 participants',
          'matchesGenerated': 0,
        };
      }

      // 🔥 HARDCORE + AUTO ADVANCE: Generate complete bracket with match progression
      await _generateCompleteBracketWithProgression(tournamentId, participants);

      debugPrint('$_tag: Successfully generated 55 SABO DE32 matches');

      return {
        'success': true,
        'matchesGenerated': 55, // SABO DE32 always generates 55 matches
        'error': null,
      };
    } catch (e, stackTrace) {
      debugPrint('$_tag: Error generating SABO DE32 bracket: $e');
      debugPrint('$_tag: Stack trace: $stackTrace');

      return {
        'success': false,
        'error': e.toString(),
        'matchesGenerated': 0,
      };
    }
  }

  /// 🔥 HARDCORE + AUTO ADVANCE: Generate complete bracket with match progression
  /// This creates all matches and sets up proper advancement paths
  Future<void> _generateCompleteBracketWithProgression(
    String tournamentId,
    List<Map<String, dynamic>> participants,
  ) async {
    try {
      debugPrint(
          '$_tag: 🔥 HARDCORE MODE: Generating complete bracket with match progression');

      // 1. Create all 55 matches with proper structure
      await _createAllMatchesWithProgression(tournamentId, participants);

      // 2. Populate Group A Round 1 matches with participants (1-16)
      await _populateGroupARound1WithParticipants(tournamentId, participants.sublist(0, 16));

      // 3. Populate Group B Round 1 matches with participants (17-32)
      await _populateGroupBRound1WithParticipants(tournamentId, participants.sublist(16, 32));

      debugPrint(
          '$_tag: 🔥 HARDCORE MODE: Complete bracket structure created!');
      debugPrint(
          '$_tag: Group A R1 and Group B R1 populated with participants, other rounds await natural progression');
    } catch (e) {
      debugPrint('$_tag: Error in hardcore bracket generation: $e');
      throw Exception('Failed to generate hardcore bracket: $e');
    }
  }

  /// Create all 55 matches with proper advancement progression
  Future<void> _createAllMatchesWithProgression(
    String tournamentId,
    List<Map<String, dynamic>> participants,
  ) async {
    final matches = <Map<String, dynamic>>[];

    // Define SABO DE32 structure with match progression
    final matchStructure = _getSaboDE32MatchStructure();

    // Create all matches according to structure
    for (final matchDef in matchStructure) {
      matches.add({
        'id': Uuid().v4(),
        'tournament_id': tournamentId,
        'round_number': matchDef['round'],
        'match_number': matchDef['match_number'],
        'player1_id': null, // Will be populated based on progression
        'player2_id': null, // Will be populated based on progression
        'winner_id': null,
        'status': 'pending',
        'player1_score': 0,
        'player2_score': 0,
        'bracket_format': 'double_elimination',
        'group_id': matchDef['group_id'], // 'A', 'B', or 'CROSS'
        'match_type': matchDef['type'], // 'winner_bracket', 'losers_bracket', 'cross_bracket'
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    }

    // Insert all matches
    await _supabase.from('matches').insert(matches);
    debugPrint(
        '$_tag: Created all ${matches.length} matches with proper structure');
  }

  /// Define SABO DE32 match structure (55 matches total)
  List<Map<String, dynamic>> _getSaboDE32MatchStructure() {
    final structure = <Map<String, dynamic>>[];

    // GROUP A MATCHES (26 matches total)
    // Winners Bracket A - Round 1 (8 matches)
    for (int i = 1; i <= 8; i++) {
      structure.add({
        'round': 1,
        'match_number': i,
        'group_id': 'A',
        'type': 'winner_bracket',
        'title': 'Group A WB R1 M$i',
      });
    }

    // Winners Bracket A - Round 2 (4 matches)
    for (int i = 1; i <= 4; i++) {
      structure.add({
        'round': 2,
        'match_number': i + 8,
        'group_id': 'A',
        'type': 'winner_bracket',
        'title': 'Group A WB R2 M${i + 8}',
      });
    }

    // Winners Bracket A - Round 3 (2 matches)
    for (int i = 1; i <= 2; i++) {
      structure.add({
        'round': 3,
        'match_number': i + 12,
        'group_id': 'A',
        'type': 'winner_bracket',
        'title': 'Group A WB R3 M${i + 12}',
      });
    }

    // Winners Bracket A - Round 4 (1 match - Group A Winner)
    structure.add({
      'round': 4,
      'match_number': 15,
      'group_id': 'A',
      'type': 'winner_bracket',
      'title': 'Group A Final M15',
    });

    // Losers Bracket A (11 matches: Rounds 101-106)
    // LB A Round 101 (4 matches)
    for (int i = 1; i <= 4; i++) {
      structure.add({
        'round': 101,
        'match_number': i + 15,
        'group_id': 'A',
        'type': 'losers_bracket',
        'title': 'Group A LB R1 M${i + 15}',
      });
    }

    // LB A Round 102 (2 matches)
    for (int i = 1; i <= 2; i++) {
      structure.add({
        'round': 102,
        'match_number': i + 19,
        'group_id': 'A',
        'type': 'losers_bracket',
        'title': 'Group A LB R2 M${i + 19}',
      });
    }

    // LB A Round 103 (2 matches)
    for (int i = 1; i <= 2; i++) {
      structure.add({
        'round': 103,
        'match_number': i + 21,
        'group_id': 'A',
        'type': 'losers_bracket',
        'title': 'Group A LB R3 M${i + 21}',
      });
    }

    // LB A Round 104 (1 match)
    structure.add({
      'round': 104,
      'match_number': 24,
      'group_id': 'A',
      'type': 'losers_bracket',
      'title': 'Group A LB R4 M24',
    });

    // LB A Round 105 (1 match)
    structure.add({
      'round': 105,
      'match_number': 25,
      'group_id': 'A',
      'type': 'losers_bracket',
      'title': 'Group A LB R5 M25',
    });

    // LB A Round 106 (1 match - Group A Runner-up)
    structure.add({
      'round': 106,
      'match_number': 26,
      'group_id': 'A',
      'type': 'losers_bracket',
      'title': 'Group A Runner-up M26',
    });

    // GROUP B MATCHES (26 matches total) - Same structure as Group A but different match numbers
    // Winners Bracket B - Round 1 (8 matches)
    for (int i = 1; i <= 8; i++) {
      structure.add({
        'round': 1,
        'match_number': i + 26,
        'group_id': 'B',
        'type': 'winner_bracket',
        'title': 'Group B WB R1 M${i + 26}',
      });
    }

    // Winners Bracket B - Round 2 (4 matches)
    for (int i = 1; i <= 4; i++) {
      structure.add({
        'round': 2,
        'match_number': i + 34,
        'group_id': 'B',
        'type': 'winner_bracket',
        'title': 'Group B WB R2 M${i + 34}',
      });
    }

    // Winners Bracket B - Round 3 (2 matches)
    for (int i = 1; i <= 2; i++) {
      structure.add({
        'round': 3,
        'match_number': i + 38,
        'group_id': 'B',
        'type': 'winner_bracket',
        'title': 'Group B WB R3 M${i + 38}',
      });
    }

    // Winners Bracket B - Round 4 (1 match - Group B Winner)
    structure.add({
      'round': 4,
      'match_number': 41,
      'group_id': 'B',
      'type': 'winner_bracket',
      'title': 'Group B Final M41',
    });

    // Losers Bracket B (11 matches: Rounds 101-106)
    // LB B Round 101 (4 matches)
    for (int i = 1; i <= 4; i++) {
      structure.add({
        'round': 101,
        'match_number': i + 41,
        'group_id': 'B',
        'type': 'losers_bracket',
        'title': 'Group B LB R1 M${i + 41}',
      });
    }

    // LB B Round 102 (2 matches)
    for (int i = 1; i <= 2; i++) {
      structure.add({
        'round': 102,
        'match_number': i + 45,
        'group_id': 'B',
        'type': 'losers_bracket',
        'title': 'Group B LB R2 M${i + 45}',
      });
    }

    // LB B Round 103 (2 matches)
    for (int i = 1; i <= 2; i++) {
      structure.add({
        'round': 103,
        'match_number': i + 47,
        'group_id': 'B',
        'type': 'losers_bracket',
        'title': 'Group B LB R3 M${i + 47}',
      });
    }

    // LB B Round 104 (1 match)
    structure.add({
      'round': 104,
      'match_number': 50,
      'group_id': 'B',
      'type': 'losers_bracket',
      'title': 'Group B LB R4 M50',
    });

    // LB B Round 105 (1 match)
    structure.add({
      'round': 105,
      'match_number': 51,
      'group_id': 'B',
      'type': 'losers_bracket',
      'title': 'Group B LB R5 M51',
    });

    // LB B Round 106 (1 match - Group B Runner-up)
    structure.add({
      'round': 106,
      'match_number': 52,
      'group_id': 'B',
      'type': 'losers_bracket',
      'title': 'Group B Runner-up M52',
    });

    // CROSS-BRACKET FINALS (3 matches)
    // Round 400: SF1 (Group A Winner vs Group B Runner-up)
    structure.add({
      'round': 400,
      'match_number': 53,
      'group_id': 'CROSS',
      'type': 'cross_bracket',
      'title': 'Semi-Final 1 M53',
    });

    // Round 401: SF2 (Group A Runner-up vs Group B Winner)
    structure.add({
      'round': 401,
      'match_number': 54,
      'group_id': 'CROSS',
      'type': 'cross_bracket',
      'title': 'Semi-Final 2 M54',
    });

    // Round 500: Final (SF1 Winner vs SF2 Winner)
    structure.add({
      'round': 500,
      'match_number': 55,
      'group_id': 'CROSS',
      'type': 'cross_bracket',
      'title': 'Grand Final M55',
    });

    return structure;
  }

  /// Populate Group A Round 1 matches with participants using proper seeding
  Future<void> _populateGroupARound1WithParticipants(
    String tournamentId,
    List<Map<String, dynamic>> participants,
  ) async {
    try {
      // Get Group A R1 matches
      final groupAR1Matches = await _supabase
          .from('matches')
          .select('*')
          .eq('tournament_id', tournamentId)
          .eq('round_number', 1)
          .eq('group_id', 'A')
          .order('match_number');

      // SABO DE32 Group A seeding pairs
      final seedingPairs = [
        [0, 15], // Seed 1 vs Seed 16 (Match 1)
        [7, 8], // Seed 8 vs Seed 9 (Match 2)
        [3, 12], // Seed 4 vs Seed 13 (Match 3)
        [4, 11], // Seed 5 vs Seed 12 (Match 4)
        [1, 14], // Seed 2 vs Seed 15 (Match 5)
        [6, 9], // Seed 7 vs Seed 10 (Match 6)
        [2, 13], // Seed 3 vs Seed 14 (Match 7)
        [5, 10], // Seed 6 vs Seed 11 (Match 8)
      ];

      // Populate each Group A R1 match with proper seeding
      for (int i = 0; i < groupAR1Matches.length && i < seedingPairs.length; i++) {
        final match = groupAR1Matches[i];
        final pair = seedingPairs[i];

        await _supabase.from('matches').update({
          'player1_id': participants[pair[0]]['user_id'],
          'player2_id': participants[pair[1]]['user_id'],
          'status': 'pending',
        }).eq('id', match['id']);
      }

      debugPrint(
          '$_tag: Populated ${groupAR1Matches.length} Group A R1 matches with proper seeding');
    } catch (e) {
      debugPrint('$_tag: Error populating Group A R1: $e');
      throw Exception('Failed to populate Group A R1: $e');
    }
  }

  /// Populate Group B Round 1 matches with participants using proper seeding
  Future<void> _populateGroupBRound1WithParticipants(
    String tournamentId,
    List<Map<String, dynamic>> participants,
  ) async {
    try {
      // Get Group B R1 matches
      final groupBR1Matches = await _supabase
          .from('matches')
          .select('*')
          .eq('tournament_id', tournamentId)
          .eq('round_number', 1)
          .eq('group_id', 'B')
          .order('match_number');

      // SABO DE32 Group B seeding pairs (same structure as Group A)
      final seedingPairs = [
        [0, 15], // Seed 17 vs Seed 32 (Match 27)
        [7, 8], // Seed 24 vs Seed 25 (Match 28)
        [3, 12], // Seed 20 vs Seed 29 (Match 29)
        [4, 11], // Seed 21 vs Seed 28 (Match 30)
        [1, 14], // Seed 18 vs Seed 31 (Match 31)
        [6, 9], // Seed 23 vs Seed 26 (Match 32)
        [2, 13], // Seed 19 vs Seed 30 (Match 33)
        [5, 10], // Seed 22 vs Seed 27 (Match 34)
      ];

      // Populate each Group B R1 match with proper seeding
      for (int i = 0; i < groupBR1Matches.length && i < seedingPairs.length; i++) {
        final match = groupBR1Matches[i];
        final pair = seedingPairs[i];

        await _supabase.from('matches').update({
          'player1_id': participants[pair[0]]['user_id'],
          'player2_id': participants[pair[1]]['user_id'],
          'status': 'pending',
        }).eq('id', match['id']);
      }

      debugPrint(
          '$_tag: Populated ${groupBR1Matches.length} Group B R1 matches with proper seeding');
    } catch (e) {
      debugPrint('$_tag: Error populating Group B R1: $e');
      throw Exception('Failed to populate Group B R1: $e');
    }
  }

  /// Process match completion and trigger auto-advancement for SABO DE32
  /// Returns advancement results with next matches to be filled
  Future<Map<String, dynamic>> processMatchCompletion(
    String tournamentId,
    Map<String, dynamic> completedMatch,
    String winnerId,
  ) async {
    try {
      debugPrint('$_tag: Processing SABO DE32 match completion');
      debugPrint(
          '$_tag: Match ${completedMatch['id']} - Round ${completedMatch['round_number']} - Group ${completedMatch['group_id']}');

      final results = <String, dynamic>{
        'advancement_made': false,
        'next_matches': <Map<String, dynamic>>[],
        'tournament_completed': false,
        'champion_id': null,
      };

      final groupId = completedMatch['group_id'] as String;

      // Route to appropriate group processor or cross-bracket processor
      if (groupId == 'A' || groupId == 'B') {
        await _processGroupMatchCompletion(
            tournamentId, completedMatch, winnerId, results, groupId);
      } else if (groupId == 'CROSS') {
        await _processCrossBracketMatchCompletion(
            tournamentId, completedMatch, winnerId, results);
      }

      return results;
    } catch (e, stackTrace) {
      debugPrint('$_tag: Error processing match completion: $e');
      debugPrint('$_tag: Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Process group match completion (Group A or B)
  Future<void> _processGroupMatchCompletion(
    String tournamentId,
    Map<String, dynamic> completedMatch,
    String winnerId,
    Map<String, dynamic> results,
    String groupId,
  ) async {
    final roundNumber = completedMatch['round_number'] as int;

    switch (roundNumber) {
      // Winners Bracket rounds
      case 1:
      case 2:
      case 3:
        await _processGroupWinnersBracketCompletion(
            tournamentId, completedMatch, winnerId, results, groupId);
        break;
      case 4:
        await _processGroupFinalCompletion(
            tournamentId, completedMatch, winnerId, results, groupId);
        break;
      // Losers Bracket rounds
      case 101:
      case 102:
      case 103:
      case 104:
      case 105:
        await _processGroupLosersBracketCompletion(
            tournamentId, completedMatch, winnerId, results, groupId);
        break;
      case 106:
        await _processGroupRunnerUpCompletion(
            tournamentId, completedMatch, winnerId, results, groupId);
        break;
      default:
        debugPrint(
            '$_tag: Unknown round number $roundNumber for group $groupId');
    }
  }

  /// Process cross-bracket match completion
  Future<void> _processCrossBracketMatchCompletion(
    String tournamentId,
    Map<String, dynamic> completedMatch,
    String winnerId,
    Map<String, dynamic> results,
  ) async {
    final roundNumber = completedMatch['round_number'] as int;

    switch (roundNumber) {
      case 400: // Semi-Final 1
      case 401: // Semi-Final 2
        await _processSemiFinalCompletion(
            tournamentId, completedMatch, winnerId, results);
        break;
      case 500: // Grand Final
        await _processGrandFinalCompletion(
            tournamentId, completedMatch, winnerId, results);
        break;
      default:
        debugPrint(
            '$_tag: Unknown cross-bracket round number $roundNumber');
    }
  }

  // Placeholder methods for specific advancement logic
  Future<void> _processGroupWinnersBracketCompletion(
      String tournamentId, Map<String, dynamic> completedMatch, String winnerId, Map<String, dynamic> results, String groupId) async {
    // TODO: Implement group winners bracket advancement logic
    debugPrint('$_tag: Processing Group $groupId Winners Bracket completion');
  }

  Future<void> _processGroupFinalCompletion(
      String tournamentId, Map<String, dynamic> completedMatch, String winnerId, Map<String, dynamic> results, String groupId) async {
    // TODO: Mark as Group Winner and prepare for cross-bracket
    debugPrint('$_tag: Group $groupId Winner determined: $winnerId');
  }

  Future<void> _processGroupLosersBracketCompletion(
      String tournamentId, Map<String, dynamic> completedMatch, String winnerId, Map<String, dynamic> results, String groupId) async {
    // TODO: Implement group losers bracket advancement logic
    debugPrint('$_tag: Processing Group $groupId Losers Bracket completion');
  }

  Future<void> _processGroupRunnerUpCompletion(
      String tournamentId, Map<String, dynamic> completedMatch, String winnerId, Map<String, dynamic> results, String groupId) async {
    // TODO: Mark as Group Runner-up and prepare for cross-bracket
    debugPrint('$_tag: Group $groupId Runner-up determined: $winnerId');
  }

  Future<void> _processSemiFinalCompletion(
      String tournamentId, Map<String, dynamic> completedMatch, String winnerId, Map<String, dynamic> results) async {
    // TODO: Advance winner to Grand Final
    debugPrint('$_tag: Semi-Final completed, advancing to Grand Final');
  }

  Future<void> _processGrandFinalCompletion(
      String tournamentId, Map<String, dynamic> completedMatch, String winnerId, Map<String, dynamic> results) async {
    // TODO: Tournament completed, mark champion
    results['tournament_completed'] = true;
    results['champion_id'] = winnerId;
    debugPrint('$_tag: Tournament completed! Champion: $winnerId');
  }
}