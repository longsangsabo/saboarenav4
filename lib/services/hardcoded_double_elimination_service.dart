import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 🏆 Hardcoded Double Elimination 16 Service
/// với winner_advances_to và loser_advances_to được tính sẵn
/// 
/// Structure:
/// - Total: 31 matches (không tính bracket reset)
/// - Winner Bracket: 15 matches (WB R1-R4)
/// - Loser Bracket: 15 matches (LB R1-R6)  
/// - Grand Final: 1 match
class HardcodedDoubleEliminationService {
  static const String _tag = 'HardcodedDE16';
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Tạo bracket với hardcoded advancement mapping
  Future<Map<String, dynamic>> createBracketWithAdvancement({
    required String tournamentId,
    required List<String> participantIds,
  }) async {
    try {
      debugPrint('$_tag: 🎯 Creating DE16 bracket with HARDCODED advancement');
      debugPrint('$_tag: Tournament: $tournamentId');
      debugPrint('$_tag: Participants: ${participantIds.length} players');

      if (participantIds.length != 16) {
        throw Exception('DE16 requires exactly 16 participants');
      }

      // Generate advancement map
      final advancementMap = _calculateAdvancementMap();
      debugPrint('$_tag: 🔗 Advancement map created: ${advancementMap.length} mappings');

      // Generate all matches with advancement info
      final allMatches = <Map<String, dynamic>>[];
      
      // Winner Bracket Round 1: Matches 1-8
      for (int i = 1; i <= 8; i++) {
        final advancement = advancementMap[i]!;
        allMatches.add({
          'tournament_id': tournamentId,
          'round_number': 1, // WB R1
          'match_number': i,
          'player1_id': participantIds[(i-1) * 2],
          'player2_id': participantIds[(i-1) * 2 + 1],
          'winner_id': null,
          'player1_score': 0,
          'player2_score': 0,
          'status': 'pending',
          'match_type': 'tournament',
          'bracket_format': 'double_elimination',
          'winner_advances_to': advancement['winner'],
          'loser_advances_to': advancement['loser'],
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      // Winner Bracket Round 2: Matches 9-12
      for (int i = 9; i <= 12; i++) {
        final advancement = advancementMap[i]!;
        allMatches.add({
          'tournament_id': tournamentId,
          'round_number': 2, // WB R2
          'match_number': i,
          'player1_id': null,
          'player2_id': null,
          'winner_id': null,
          'player1_score': 0,
          'player2_score': 0,
          'status': 'pending',
          'match_type': 'tournament',
          'bracket_format': 'double_elimination',
          'winner_advances_to': advancement['winner'],
          'loser_advances_to': advancement['loser'],
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      // Winner Bracket Round 3: Matches 13-14
      for (int i = 13; i <= 14; i++) {
        final advancement = advancementMap[i]!;
        allMatches.add({
          'tournament_id': tournamentId,
          'round_number': 3, // WB R3
          'match_number': i,
          'player1_id': null,
          'player2_id': null,
          'winner_id': null,
          'player1_score': 0,
          'player2_score': 0,
          'status': 'pending',
          'match_type': 'tournament',
          'bracket_format': 'double_elimination',
          'winner_advances_to': advancement['winner'],
          'loser_advances_to': advancement['loser'],
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      // Winner Bracket Final: Match 15
      final advancement15 = advancementMap[15]!;
      allMatches.add({
        'tournament_id': tournamentId,
        'round_number': 4, // WB Final
        'match_number': 15,
        'player1_id': null,
        'player2_id': null,
        'winner_id': null,
        'player1_score': 0,
        'player2_score': 0,
        'status': 'pending',
        'match_type': 'tournament',
        'bracket_format': 'double_elimination',
        'winner_advances_to': advancement15['winner'], // To Grand Final
        'loser_advances_to': advancement15['loser'], // To LB Final
        'created_at': DateTime.now().toIso8601String(),
      });

      // Loser Bracket Round 1: Matches 16-23
      for (int i = 16; i <= 23; i++) {
        final advancement = advancementMap[i]!;
        allMatches.add({
          'tournament_id': tournamentId,
          'round_number': 101, // LB R1
          'match_number': i,
          'player1_id': null,
          'player2_id': null,
          'winner_id': null,
          'player1_score': 0,
          'player2_score': 0,
          'status': 'pending',
          'match_type': 'tournament',
          'bracket_format': 'double_elimination',
          'winner_advances_to': advancement['winner'],
          'loser_advances_to': null, // Eliminated
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      // Loser Bracket Round 2: Matches 24-27
      for (int i = 24; i <= 27; i++) {
        final advancement = advancementMap[i]!;
        allMatches.add({
          'tournament_id': tournamentId,
          'round_number': 102, // LB R2
          'match_number': i,
          'player1_id': null,
          'player2_id': null,
          'winner_id': null,
          'player1_score': 0,
          'player2_score': 0,
          'status': 'pending',
          'match_type': 'tournament',
          'bracket_format': 'double_elimination',
          'winner_advances_to': advancement['winner'],
          'loser_advances_to': null, // Eliminated
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      // Loser Bracket Round 3: Matches 28-29
      for (int i = 28; i <= 29; i++) {
        final advancement = advancementMap[i]!;
        allMatches.add({
          'tournament_id': tournamentId,
          'round_number': 103, // LB R3
          'match_number': i,
          'player1_id': null,
          'player2_id': null,
          'winner_id': null,
          'player1_score': 0,
          'player2_score': 0,
          'status': 'pending',
          'match_type': 'tournament',
          'bracket_format': 'double_elimination',
          'winner_advances_to': advancement['winner'],
          'loser_advances_to': null, // Eliminated
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      // Loser Bracket Round 4: Match 30
      final advancement30 = advancementMap[30]!;
      allMatches.add({
        'tournament_id': tournamentId,
        'round_number': 104, // LB R4
        'match_number': 30,
        'player1_id': null,
        'player2_id': null,
        'winner_id': null,
        'player1_score': 0,
        'player2_score': 0,
        'status': 'pending',
        'match_type': 'tournament',
        'bracket_format': 'double_elimination',
        'winner_advances_to': advancement30['winner'], // To Grand Final
        'loser_advances_to': null, // Eliminated
        'created_at': DateTime.now().toIso8601String(),
      });

      // Grand Final: Match 31
      allMatches.add({
        'tournament_id': tournamentId,
        'round_number': 999, // Grand Final
        'match_number': 31,
        'player1_id': null,
        'player2_id': null,
        'winner_id': null,
        'player1_score': 0,
        'player2_score': 0,
        'status': 'pending',
        'match_type': 'tournament',
        'bracket_format': 'double_elimination',
        'winner_advances_to': null, // Champion!
        'loser_advances_to': null, // Runner-up
        'created_at': DateTime.now().toIso8601String(),
      });

      // Create tournament_participants records first
      debugPrint('$_tag: 👥 Creating ${participantIds.length} participant records...');
      final participantRecords = participantIds.map((userId) => {
        'tournament_id': tournamentId,
        'user_id': userId,
        'joined_at': DateTime.now().toIso8601String(),
        'payment_status': 'pending', // or 'completed' depending on your requirements
      }).toList();
      
      await _supabase.from('tournament_participants').insert(participantRecords);
      debugPrint('$_tag: ✅ Participants created successfully');

      // Save matches to database
      debugPrint('$_tag: 💾 Saving ${allMatches.length} matches to database...');
      await _supabase.from('matches').insert(allMatches);

      debugPrint('$_tag: ✅ DE16 bracket created successfully!');
      return {
        'success': true,
        'matches_count': allMatches.length,
        'participants_count': participantIds.length,
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

  /// Calculate advancement map for DE16
  /// Returns: {matchNumber: {'winner': nextMatch, 'loser': loserMatch}}
  Map<int, Map<String, int?>> _calculateAdvancementMap() {
    final map = <int, Map<String, int?>>{};

    // Winner Bracket Round 1 (Matches 1-8)
    // Winners go to WB R2 (Matches 9-12)
    // Losers go to LB R1 (Matches 16-23)
    map[1] = {'winner': 9, 'loser': 16};
    map[2] = {'winner': 9, 'loser': 16};
    map[3] = {'winner': 10, 'loser': 17};
    map[4] = {'winner': 10, 'loser': 17};
    map[5] = {'winner': 11, 'loser': 18};
    map[6] = {'winner': 11, 'loser': 18};
    map[7] = {'winner': 12, 'loser': 19};
    map[8] = {'winner': 12, 'loser': 19};

    // Winner Bracket Round 2 (Matches 9-12)
    // Winners go to WB R3 (Matches 13-14)
    // Losers go to LB R2 (Matches 24-27) to play against LB R1 winners
    map[9] = {'winner': 13, 'loser': 24};
    map[10] = {'winner': 13, 'loser': 25};
    map[11] = {'winner': 14, 'loser': 26};
    map[12] = {'winner': 14, 'loser': 27};

    // Winner Bracket Round 3 (Matches 13-14)
    // Winners go to WB Final (Match 15)
    // Losers go to LB R3 (Matches 28-29)
    map[13] = {'winner': 15, 'loser': 28};
    map[14] = {'winner': 15, 'loser': 29};

    // Winner Bracket Final (Match 15)
    // Winner goes to Grand Final (Match 31)
    // Loser goes to LB R4 (Match 30)
    map[15] = {'winner': 31, 'loser': 30};

    // Loser Bracket Round 1 (Matches 16-23)
    // 8 matches receive losers from WB R1
    // Winners go to LB R2 (24-27) to merge with WB R2 losers
    map[16] = {'winner': 24, 'loser': null}; // LB R1 Match 1
    map[17] = {'winner': 24, 'loser': null}; // LB R1 Match 2
    map[18] = {'winner': 25, 'loser': null}; // LB R1 Match 3
    map[19] = {'winner': 25, 'loser': null}; // LB R1 Match 4
    map[20] = {'winner': 26, 'loser': null}; // LB R1 Match 5
    map[21] = {'winner': 26, 'loser': null}; // LB R1 Match 6
    map[22] = {'winner': 27, 'loser': null}; // LB R1 Match 7
    map[23] = {'winner': 27, 'loser': null}; // LB R1 Match 8

    // Loser Bracket Round 2 (Matches 24-27)
    // Winners go to LB R3 (Matches 28-29)
    map[24] = {'winner': 28, 'loser': null};
    map[25] = {'winner': 28, 'loser': null};
    map[26] = {'winner': 29, 'loser': null};
    map[27] = {'winner': 29, 'loser': null};

    // Loser Bracket Round 3 (Matches 28-29)
    // Winners go to LB R4 (Match 30)
    map[28] = {'winner': 30, 'loser': null};
    map[29] = {'winner': 30, 'loser': null};

    // Loser Bracket Round 4/Final (Match 30)
    // Winner goes to Grand Final (Match 31)
    map[30] = {'winner': 31, 'loser': null};

    // Grand Final (Match 31)
    map[31] = {'winner': null, 'loser': null}; // Tournament complete!

    return map;
  }
}
