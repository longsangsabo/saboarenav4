import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 🏆 Hardcoded SABO DE16 Service
/// ✅ CORRECT STRUCTURE with standardized bracket metadata
/// 
/// Structure:
/// - Total: 27 matches (all created upfront, no dynamic creation)
/// - Winner Bracket: 14 matches (3 rounds: 8+4+2)
/// - Loser Branch A: 7 matches (3 rounds: 4+2+1) - WB R1 losers
/// - Loser Branch B: 3 matches (2 rounds: 2+1) - WB R2 losers
/// - SABO Finals: 3 matches (2 semifinals + 1 final)
/// 
/// Advancement uses display_order values:
/// - WB: 1101-1302 (priority 1, stops at R3)
/// - LB-A: 2101-2301 (priority 2)
/// - LB-B: 3101-3201 (priority 3)
/// - SABO Finals: 4101-4201 (priority 4)
/// 
/// Key Differences from Standard DE16:
/// - NO WB Final: Winners stop at R3 (2 players)
/// - 2 Loser Branches: Branch A (R1 losers), Branch B (R2 losers)
/// - 4-Player Finals: 2 WB + 2 LB champions
/// - NO Bracket Reset: Finals is single elimination
class HardcodedSaboDE16Service {
  static const String _tag = 'HardcodedSaboDE16';
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Tạo SABO DE16 bracket với hardcoded advancement mapping
  Future<Map<String, dynamic>> createBracketWithAdvancement({
    required String tournamentId,
    required List<String> participantIds,
  }) async {
    try {
      debugPrint('$_tag: 🎯 Creating SABO DE16 bracket with HARDCODED advancement');
      debugPrint('$_tag: Tournament: $tournamentId');
      debugPrint('$_tag: Participants: ${participantIds.length} players');

      if (participantIds.length != 16) {
        throw Exception('SABO DE16 requires exactly 16 participants');
      }

      // Generate advancement map
      final advancementMap = _calculateAdvancementMap();
      debugPrint('$_tag: 🔗 Advancement map created: ${advancementMap.length} mappings');

      // Generate all matches with advancement info
      final allMatches = <Map<String, dynamic>>[];
      
      // ========== WINNER BRACKET: 14 matches (3 rounds) ==========
      
      // WB Round 1: Matches 1-8 (display_order 1101-1108)
      for (int i = 1; i <= 8; i++) {
        final advancement = advancementMap[i]!;
        final displayOrder = (1 * 1000) + (1 * 100) + i; // 1101-1108
        allMatches.add({
          'tournament_id': tournamentId,
          'round_number': 1, // WB R1 (legacy)
          'match_number': i,
          'player1_id': participantIds[(i-1) * 2],
          'player2_id': participantIds[(i-1) * 2 + 1],
          'winner_id': null,
          'player1_score': 0,
          'player2_score': 0,
          'status': 'pending',
          'match_type': 'tournament',
          'bracket_format': 'sabo_de16',
          'winner_advances_to': advancement['winner'],
          'loser_advances_to': advancement['loser'],
          // 🔥 STANDARDIZED FIELDS
          'bracket_type': 'WB',
          'bracket_group': null,
          'stage_round': 1,
          'display_order': displayOrder,
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      // WB Round 2: Matches 9-12 (display_order 1201-1204)
      for (int i = 9; i <= 12; i++) {
        final advancement = advancementMap[i]!;
        final displayOrder = (1 * 1000) + (2 * 100) + (i - 8); // 1201-1204
        allMatches.add({
          'tournament_id': tournamentId,
          'round_number': 2, // WB R2 (legacy)
          'match_number': i,
          'player1_id': null,
          'player2_id': null,
          'winner_id': null,
          'player1_score': 0,
          'player2_score': 0,
          'status': 'pending',
          'match_type': 'tournament',
          'bracket_format': 'sabo_de16',
          'winner_advances_to': advancement['winner'],
          'loser_advances_to': advancement['loser'],
          // 🔥 STANDARDIZED FIELDS
          'bracket_type': 'WB',
          'bracket_group': null,
          'stage_round': 2,
          'display_order': displayOrder,
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      // WB Round 3: Matches 13-14 (display_order 1301-1302)
      // ⚠️ NO LOSER ADVANCEMENT - WB stops here, goes to SABO Finals
      for (int i = 13; i <= 14; i++) {
        final advancement = advancementMap[i]!;
        final displayOrder = (1 * 1000) + (3 * 100) + (i - 12); // 1301-1302
        allMatches.add({
          'tournament_id': tournamentId,
          'round_number': 3, // WB R3 (legacy)
          'match_number': i,
          'player1_id': null,
          'player2_id': null,
          'winner_id': null,
          'player1_score': 0,
          'player2_score': 0,
          'status': 'pending',
          'match_type': 'tournament',
          'bracket_format': 'sabo_de16',
          'winner_advances_to': advancement['winner'], // To SABO Finals
          'loser_advances_to': null, // NO LOSER ADVANCE!
          // 🔥 STANDARDIZED FIELDS
          'bracket_type': 'WB',
          'bracket_group': null,
          'stage_round': 3,
          'display_order': displayOrder,
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      // ========== LOSER BRANCH A: 7 matches (3 rounds) ==========
      // Receives WB R1 losers
      
      // LB-A Round 1: Matches 15-18 (display_order 2101-2104)
      for (int i = 15; i <= 18; i++) {
        final advancement = advancementMap[i]!;
        final displayOrder = (2 * 1000) + (1 * 100) + (i - 14); // 2101-2104
        allMatches.add({
          'tournament_id': tournamentId,
          'round_number': 101, // LB-A R1 (legacy)
          'match_number': i,
          'player1_id': null,
          'player2_id': null,
          'winner_id': null,
          'player1_score': 0,
          'player2_score': 0,
          'status': 'pending',
          'match_type': 'tournament',
          'bracket_format': 'sabo_de16',
          'winner_advances_to': advancement['winner'],
          'loser_advances_to': null, // Eliminated
          // 🔥 STANDARDIZED FIELDS
          'bracket_type': 'LB-A', // Loser Branch A
          'bracket_group': 'A',
          'stage_round': 1,
          'display_order': displayOrder,
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      // LB-A Round 2: Matches 19-20 (display_order 2201-2202)
      for (int i = 19; i <= 20; i++) {
        final advancement = advancementMap[i]!;
        final displayOrder = (2 * 1000) + (2 * 100) + (i - 18); // 2201-2202
        allMatches.add({
          'tournament_id': tournamentId,
          'round_number': 102, // LB-A R2 (legacy)
          'match_number': i,
          'player1_id': null,
          'player2_id': null,
          'winner_id': null,
          'player1_score': 0,
          'player2_score': 0,
          'status': 'pending',
          'match_type': 'tournament',
          'bracket_format': 'sabo_de16',
          'winner_advances_to': advancement['winner'],
          'loser_advances_to': null, // Eliminated
          // 🔥 STANDARDIZED FIELDS
          'bracket_type': 'LB-A',
          'bracket_group': 'A',
          'stage_round': 2,
          'display_order': displayOrder,
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      // LB-A Round 3 / Final: Match 21 (display_order 2301)
      final advancement21 = advancementMap[21]!;
      allMatches.add({
        'tournament_id': tournamentId,
        'round_number': 103, // LB-A R3 Final (legacy)
        'match_number': 21,
        'player1_id': null,
        'player2_id': null,
        'winner_id': null,
        'player1_score': 0,
        'player2_score': 0,
        'status': 'pending',
        'match_type': 'tournament',
        'bracket_format': 'sabo_de16',
        'winner_advances_to': advancement21['winner'], // To SABO Finals Semi1
        'loser_advances_to': null, // Eliminated
        // 🔥 STANDARDIZED FIELDS
        'bracket_type': 'LB-A',
        'bracket_group': 'A',
        'stage_round': 3,
        'display_order': 2301,
        'created_at': DateTime.now().toIso8601String(),
      });

      // ========== LOSER BRANCH B: 3 matches (2 rounds) ==========
      // Receives WB R2 losers
      
      // LB-B Round 1: Matches 22-23 (display_order 3101-3102)
      for (int i = 22; i <= 23; i++) {
        final advancement = advancementMap[i]!;
        final displayOrder = (3 * 1000) + (1 * 100) + (i - 21); // 3101-3102
        allMatches.add({
          'tournament_id': tournamentId,
          'round_number': 201, // LB-B R1 (legacy)
          'match_number': i,
          'player1_id': null,
          'player2_id': null,
          'winner_id': null,
          'player1_score': 0,
          'player2_score': 0,
          'status': 'pending',
          'match_type': 'tournament',
          'bracket_format': 'sabo_de16',
          'winner_advances_to': advancement['winner'],
          'loser_advances_to': null, // Eliminated
          // 🔥 STANDARDIZED FIELDS
          'bracket_type': 'LB-B', // Loser Branch B
          'bracket_group': 'B',
          'stage_round': 1,
          'display_order': displayOrder,
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      // LB-B Round 2 / Final: Match 24 (display_order 3201)
      final advancement24 = advancementMap[24]!;
      allMatches.add({
        'tournament_id': tournamentId,
        'round_number': 202, // LB-B R2 Final (legacy)
        'match_number': 24,
        'player1_id': null,
        'player2_id': null,
        'winner_id': null,
        'player1_score': 0,
        'player2_score': 0,
        'status': 'pending',
        'match_type': 'tournament',
        'bracket_format': 'sabo_de16',
        'winner_advances_to': advancement24['winner'], // To SABO Finals Semi2
        'loser_advances_to': null, // Eliminated
        // 🔥 STANDARDIZED FIELDS
        'bracket_type': 'LB-B',
        'bracket_group': 'B',
        'stage_round': 2,
        'display_order': 3201,
        'created_at': DateTime.now().toIso8601String(),
      });

      // ========== SABO FINALS: 3 matches ==========
      // 4-player format: 2 WB champions + 2 LB champions
      
      // Semifinal 1: Match 25 (display_order 4101)
      // WB R3 M13 winner vs LB-A champion
      final advancement25 = advancementMap[25]!;
      allMatches.add({
        'tournament_id': tournamentId,
        'round_number': 250, // SABO Semi1 (legacy)
        'match_number': 25,
        'player1_id': null,
        'player2_id': null,
        'winner_id': null,
        'player1_score': 0,
        'player2_score': 0,
        'status': 'pending',
        'match_type': 'tournament',
        'bracket_format': 'sabo_de16',
        'winner_advances_to': advancement25['winner'], // To Final
        'loser_advances_to': null, // 3rd place
        // 🔥 STANDARDIZED FIELDS
        'bracket_type': 'SABO', // SABO Finals
        'bracket_group': 'SEMI1',
        'stage_round': 1,
        'display_order': 4101,
        'created_at': DateTime.now().toIso8601String(),
      });

      // Semifinal 2: Match 26 (display_order 4102)
      // WB R3 M14 winner vs LB-B champion
      final advancement26 = advancementMap[26]!;
      allMatches.add({
        'tournament_id': tournamentId,
        'round_number': 251, // SABO Semi2 (legacy)
        'match_number': 26,
        'player1_id': null,
        'player2_id': null,
        'winner_id': null,
        'player1_score': 0,
        'player2_score': 0,
        'status': 'pending',
        'match_type': 'tournament',
        'bracket_format': 'sabo_de16',
        'winner_advances_to': advancement26['winner'], // To Final
        'loser_advances_to': null, // 4th place
        // 🔥 STANDARDIZED FIELDS
        'bracket_type': 'SABO',
        'bracket_group': 'SEMI2',
        'stage_round': 1,
        'display_order': 4102,
        'created_at': DateTime.now().toIso8601String(),
      });

      // SABO Finals: Match 27 (display_order 4201)
      allMatches.add({
        'tournament_id': tournamentId,
        'round_number': 300, // SABO Finals (legacy)
        'match_number': 27,
        'player1_id': null,
        'player2_id': null,
        'winner_id': null,
        'player1_score': 0,
        'player2_score': 0,
        'status': 'pending',
        'match_type': 'tournament',
        'bracket_format': 'sabo_de16',
        'winner_advances_to': null, // Champion!
        'loser_advances_to': null, // Runner-up
        // 🔥 STANDARDIZED FIELDS
        'bracket_type': 'SABO',
        'bracket_group': 'FINAL',
        'stage_round': 2,
        'display_order': 4201,
        'created_at': DateTime.now().toIso8601String(),
      });

      // Save matches to database
      debugPrint('$_tag: 💾 Saving ${allMatches.length} matches to database...');
      await _supabase.from('matches').insert(allMatches);

      debugPrint('$_tag: ✅ SABO DE16 bracket created successfully!');
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

  /// ✅ STANDARDIZED: Calculate advancement map for SABO DE16 using display_order
  /// Returns: {matchNumber: {'winner': display_order, 'loser': display_order}}
  /// 🔥 SABO STRUCTURE: 14 WB + 7 LB-A + 3 LB-B + 3 SABO Finals = 27 matches
  Map<int, Map<String, int?>> _calculateAdvancementMap() {
    final map = <int, Map<String, int?>>{};

    // ========== WINNER BRACKET (14 matches) ==========
    
    // WB Round 1 (8 matches → display_order 1101-1108)
    // Winners → WB R2 (1201-1204)
    // Losers → LB-A R1 (2101-2104)
    map[1] = {'winner': 1201, 'loser': 2101};
    map[2] = {'winner': 1201, 'loser': 2101};
    map[3] = {'winner': 1202, 'loser': 2102};
    map[4] = {'winner': 1202, 'loser': 2102};
    map[5] = {'winner': 1203, 'loser': 2103};
    map[6] = {'winner': 1203, 'loser': 2103};
    map[7] = {'winner': 1204, 'loser': 2104};
    map[8] = {'winner': 1204, 'loser': 2104};

    // WB Round 2 (4 matches → display_order 1201-1204)
    // Winners → WB R3 (1301-1302)
    // Losers → LB-B R1 (3101-3102)
    map[9] = {'winner': 1301, 'loser': 3101};
    map[10] = {'winner': 1301, 'loser': 3102};
    map[11] = {'winner': 1302, 'loser': 3101};
    map[12] = {'winner': 1302, 'loser': 3102};

    // WB Round 3 (2 matches → display_order 1301-1302)
    // ⚠️ NO LOSER ADVANCEMENT - WB stops here!
    // Winners → SABO Finals semifinals (4101, 4102)
    map[13] = {'winner': 4101, 'loser': null};  // M13 winner → Semi1
    map[14] = {'winner': 4102, 'loser': null};  // M14 winner → Semi2

    // ========== LOSER BRANCH A (7 matches) ==========
    
    // LB-A Round 1 (4 matches → display_order 2101-2104)
    // Receive: 8 WB R1 losers
    // Winners → LB-A R2 (2201-2202)
    map[15] = {'winner': 2201, 'loser': null};
    map[16] = {'winner': 2201, 'loser': null};
    map[17] = {'winner': 2202, 'loser': null};
    map[18] = {'winner': 2202, 'loser': null};

    // LB-A Round 2 (2 matches → display_order 2201-2202)
    // Winners → LB-A Final (2301)
    map[19] = {'winner': 2301, 'loser': null};
    map[20] = {'winner': 2301, 'loser': null};

    // LB-A Round 3 / Final (1 match → display_order 2301)
    // Winner → SABO Finals Semi1 (4101)
    map[21] = {'winner': 4101, 'loser': null};

    // ========== LOSER BRANCH B (3 matches) ==========
    
    // LB-B Round 1 (2 matches → display_order 3101-3102)
    // Receive: 4 WB R2 losers
    // Winners → LB-B Final (3201)
    map[22] = {'winner': 3201, 'loser': null};
    map[23] = {'winner': 3201, 'loser': null};

    // LB-B Round 2 / Final (1 match → display_order 3201)
    // Winner → SABO Finals Semi2 (4102)
    map[24] = {'winner': 4102, 'loser': null};

    // ========== SABO FINALS (3 matches) ==========
    
    // Semifinal 1 (1 match → display_order 4101)
    // Receives: WB R3 M13 winner + LB-A champion (M21)
    // Winner → SABO Finals (4201)
    map[25] = {'winner': 4201, 'loser': null};

    // Semifinal 2 (1 match → display_order 4102)
    // Receives: WB R3 M14 winner + LB-B champion (M24)
    // Winner → SABO Finals (4201)
    map[26] = {'winner': 4201, 'loser': null};

    // SABO Finals (1 match → display_order 4201)
    // Receives: Semi1 winner + Semi2 winner
    // Winner = TOURNAMENT CHAMPION
    map[27] = {'winner': null, 'loser': null};

    return map;
  }
}
