import 'package:supabase_flutter/supabase_flutter.dart';

/// SABO DE32 Hardcoded Service
///
/// Structure:
/// - Total: 55 matches (all created upfront, no dynamic creation)
/// - Group A: 24 matches (SABO DE16 structure)
///   - Winner Bracket: 14 matches (3 rounds: 8+4+2)
///   - Loser Branch A: 7 matches (3 rounds: 4+2+1)
///   - Loser Branch B: 3 matches (2 rounds: 2+1)
/// - Group B: 24 matches (SABO DE16 structure)
///   - Winner Bracket: 14 matches (3 rounds: 8+4+2)
///   - Loser Branch A: 7 matches (3 rounds: 4+2+1)
///   - Loser Branch B: 3 matches (2 rounds: 2+1)
/// - Cross-Bracket Finals: 7 matches
///   - Semi-Finals: 4 matches
///   - Finals: 2 matches
///   - Grand Final: 1 match
///
/// Display Order System:
/// - Group A WB: 11xxx (11101-11302)
/// - Group A LB-A: 12xxx (12101-12301)
/// - Group A LB-B: 13xxx (13101-13201)
/// - Group B WB: 21xxx (21101-21302)
/// - Group B LB-A: 22xxx (22101-22301)
/// - Group B LB-B: 23xxx (23101-23201)
/// - Cross Semi-Finals: 31xxx (31101-31104)
/// - Cross Finals: 32xxx (32101-32102)
/// - Grand Final: 33xxx (33101)
///
/// Key Features:
/// - Each group uses SABO DE16 format (24 matches)
/// - WB R3 has NO loser advancement (stops at 2 players per group)
/// - Each group produces 4 qualifiers (2 WB + 1 LB-A + 1 LB-B)
/// - Cross-bracket finals balance WB vs LB representation
class HardcodedSaboDE32Service {
  final SupabaseClient supabase;

  HardcodedSaboDE32Service(this.supabase);

  /// Create SABO DE32 bracket with advancement and save to database
  Future<Map<String, dynamic>> createBracketWithAdvancement({
    required String tournamentId,
    required List<String> participantIds,
  }) async {
    try {
      // Generate bracket structure
      final matches = await generateBracket(
        tournamentId: tournamentId,
        participantIds: participantIds,
      );

      // Save to database
      await supabase.from('matches').insert(matches);

      return {
        'success': true,
        'message': 'SABO DE32 bracket created successfully',
        'total_matches': matches.length,
        'matches_generated': matches.length,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Generate complete SABO DE32 bracket structure
  Future<List<Map<String, dynamic>>> generateBracket({
    required String tournamentId,
    required List<String> participantIds,
  }) async {
    if (participantIds.length != 32) {
      throw Exception('SABO DE32 requires exactly 32 participants');
    }

    final allMatches = <Map<String, dynamic>>[];
    final advancementMap = _calculateAdvancementMap();
    int matchNumber = 1;

    // ========================================
    // GROUP A (24 matches) - Players P1-P16
    // ========================================

    // Group A - WB Round 1 (8 matches): 11101-11108
    final groupAPlayers = participantIds.sublist(0, 16);
    final wbR1Pairs = [
      [0, 15], [7, 8], [3, 12], [4, 11], [1, 14], [6, 9], [2, 13], [5, 10]
    ];

    for (var i = 0; i < wbR1Pairs.length; i++) {
      final pair = wbR1Pairs[i];
      final advancement = advancementMap[matchNumber]!;
      final displayOrder = 11101 + i;

      allMatches.add({
        'tournament_id': tournamentId,
        'match_number': matchNumber,
        'bracket_type': 'WB',
        'bracket_group': 'A',
        'stage_round': 1,
        'display_order': displayOrder,
        'winner_advances_to': advancement['winner'],
        'loser_advances_to': advancement['loser'],
        'player1_id': groupAPlayers[pair[0]],
        'player2_id': groupAPlayers[pair[1]],
        'status': 'pending',
      });
      matchNumber++;
    }

    // Group A - WB Round 2 (4 matches): 11201-11204
    for (var i = 0; i < 4; i++) {
      final advancement = advancementMap[matchNumber]!;
      final displayOrder = 11201 + i;

      allMatches.add({
        'tournament_id': tournamentId,
        'match_number': matchNumber,
        'bracket_type': 'WB',
        'bracket_group': 'A',
        'stage_round': 2,
        'display_order': displayOrder,
        'winner_advances_to': advancement['winner'],
        'loser_advances_to': advancement['loser'],
        'player1_id': null,
        'player2_id': null,
        'status': 'pending',
      });
      matchNumber++;
    }

    // Group A - WB Round 3 (2 matches): 11301-11302 [QUALIFIERS]
    for (var i = 0; i < 2; i++) {
      final advancement = advancementMap[matchNumber]!;
      final displayOrder = 11301 + i;

      allMatches.add({
        'tournament_id': tournamentId,
        'match_number': matchNumber,
        'bracket_type': 'WB',
        'bracket_group': 'A',
        'stage_round': 3,
        'display_order': displayOrder,
        'winner_advances_to': advancement['winner'],
        'loser_advances_to': advancement['loser'], // null - no loser advancement
        'player1_id': null,
        'player2_id': null,
        'status': 'pending',
      });
      matchNumber++;
    }

    // Group A - LB-A Round 1 (4 matches): 12101-12104
    for (var i = 0; i < 4; i++) {
      final advancement = advancementMap[matchNumber]!;
      final displayOrder = 12101 + i;

      allMatches.add({
        'tournament_id': tournamentId,
        'match_number': matchNumber,
        'bracket_type': 'LB-A',
        'bracket_group': 'A',
        'stage_round': 1,
        'display_order': displayOrder,
        'winner_advances_to': advancement['winner'],
        'loser_advances_to': advancement['loser'],
        'player1_id': null,
        'player2_id': null,
        'status': 'pending',
      });
      matchNumber++;
    }

    // Group A - LB-A Round 2 (2 matches): 12201-12202
    for (var i = 0; i < 2; i++) {
      final advancement = advancementMap[matchNumber]!;
      final displayOrder = 12201 + i;

      allMatches.add({
        'tournament_id': tournamentId,
        'match_number': matchNumber,
        'bracket_type': 'LB-A',
        'bracket_group': 'A',
        'stage_round': 2,
        'display_order': displayOrder,
        'winner_advances_to': advancement['winner'],
        'loser_advances_to': advancement['loser'],
        'player1_id': null,
        'player2_id': null,
        'status': 'pending',
      });
      matchNumber++;
    }

    // Group A - LB-A Round 3 (1 match): 12301 [QUALIFIER]
    {
      final advancement = advancementMap[matchNumber]!;
      allMatches.add({
        'tournament_id': tournamentId,
        'match_number': matchNumber,
        'bracket_type': 'LB-A',
        'bracket_group': 'A',
        'stage_round': 3,
        'display_order': 12301,
        'winner_advances_to': advancement['winner'],
        'loser_advances_to': advancement['loser'],
        'player1_id': null,
        'player2_id': null,
        'status': 'pending',
      });
      matchNumber++;
    }

    // Group A - LB-B Round 1 (2 matches): 13101-13102
    for (var i = 0; i < 2; i++) {
      final advancement = advancementMap[matchNumber]!;
      final displayOrder = 13101 + i;

      allMatches.add({
        'tournament_id': tournamentId,
        'match_number': matchNumber,
        'bracket_type': 'LB-B',
        'bracket_group': 'A',
        'stage_round': 1,
        'display_order': displayOrder,
        'winner_advances_to': advancement['winner'],
        'loser_advances_to': advancement['loser'],
        'player1_id': null,
        'player2_id': null,
        'status': 'pending',
      });
      matchNumber++;
    }

    // Group A - LB-B Round 2 (1 match): 13201 [QUALIFIER]
    {
      final advancement = advancementMap[matchNumber]!;
      allMatches.add({
        'tournament_id': tournamentId,
        'match_number': matchNumber,
        'bracket_type': 'LB-B',
        'bracket_group': 'A',
        'stage_round': 2,
        'display_order': 13201,
        'winner_advances_to': advancement['winner'],
        'loser_advances_to': advancement['loser'],
        'player1_id': null,
        'player2_id': null,
        'status': 'pending',
      });
      matchNumber++;
    }

    // ========================================
    // GROUP B (24 matches) - Players P17-P32
    // ========================================

    // Group B - WB Round 1 (8 matches): 21101-21108
    final groupBPlayers = participantIds.sublist(16, 32);
    final wbR1PairsB = [
      [0, 15], [7, 8], [3, 12], [4, 11], [1, 14], [6, 9], [2, 13], [5, 10]
    ];

    for (var i = 0; i < wbR1PairsB.length; i++) {
      final pair = wbR1PairsB[i];
      final advancement = advancementMap[matchNumber]!;
      final displayOrder = 21101 + i;

      allMatches.add({
        'tournament_id': tournamentId,
        'match_number': matchNumber,
        'bracket_type': 'WB',
        'bracket_group': 'B',
        'stage_round': 1,
        'display_order': displayOrder,
        'winner_advances_to': advancement['winner'],
        'loser_advances_to': advancement['loser'],
        'player1_id': groupBPlayers[pair[0]],
        'player2_id': groupBPlayers[pair[1]],
        'status': 'pending',
      });
      matchNumber++;
    }

    // Group B - WB Round 2 (4 matches): 21201-21204
    for (var i = 0; i < 4; i++) {
      final advancement = advancementMap[matchNumber]!;
      final displayOrder = 21201 + i;

      allMatches.add({
        'tournament_id': tournamentId,
        'match_number': matchNumber,
        'bracket_type': 'WB',
        'bracket_group': 'B',
        'stage_round': 2,
        'display_order': displayOrder,
        'winner_advances_to': advancement['winner'],
        'loser_advances_to': advancement['loser'],
        'player1_id': null,
        'player2_id': null,
        'status': 'pending',
      });
      matchNumber++;
    }

    // Group B - WB Round 3 (2 matches): 21301-21302 [QUALIFIERS]
    for (var i = 0; i < 2; i++) {
      final advancement = advancementMap[matchNumber]!;
      final displayOrder = 21301 + i;

      allMatches.add({
        'tournament_id': tournamentId,
        'match_number': matchNumber,
        'bracket_type': 'WB',
        'bracket_group': 'B',
        'stage_round': 3,
        'display_order': displayOrder,
        'winner_advances_to': advancement['winner'],
        'loser_advances_to': advancement['loser'], // null - no loser advancement
        'player1_id': null,
        'player2_id': null,
        'status': 'pending',
      });
      matchNumber++;
    }

    // Group B - LB-A Round 1 (4 matches): 22101-22104
    for (var i = 0; i < 4; i++) {
      final advancement = advancementMap[matchNumber]!;
      final displayOrder = 22101 + i;

      allMatches.add({
        'tournament_id': tournamentId,
        'match_number': matchNumber,
        'bracket_type': 'LB-A',
        'bracket_group': 'B',
        'stage_round': 1,
        'display_order': displayOrder,
        'winner_advances_to': advancement['winner'],
        'loser_advances_to': advancement['loser'],
        'player1_id': null,
        'player2_id': null,
        'status': 'pending',
      });
      matchNumber++;
    }

    // Group B - LB-A Round 2 (2 matches): 22201-22202
    for (var i = 0; i < 2; i++) {
      final advancement = advancementMap[matchNumber]!;
      final displayOrder = 22201 + i;

      allMatches.add({
        'tournament_id': tournamentId,
        'match_number': matchNumber,
        'bracket_type': 'LB-A',
        'bracket_group': 'B',
        'stage_round': 2,
        'display_order': displayOrder,
        'winner_advances_to': advancement['winner'],
        'loser_advances_to': advancement['loser'],
        'player1_id': null,
        'player2_id': null,
        'status': 'pending',
      });
      matchNumber++;
    }

    // Group B - LB-A Round 3 (1 match): 22301 [QUALIFIER]
    {
      final advancement = advancementMap[matchNumber]!;
      allMatches.add({
        'tournament_id': tournamentId,
        'match_number': matchNumber,
        'bracket_type': 'LB-A',
        'bracket_group': 'B',
        'stage_round': 3,
        'display_order': 22301,
        'winner_advances_to': advancement['winner'],
        'loser_advances_to': advancement['loser'],
        'player1_id': null,
        'player2_id': null,
        'status': 'pending',
      });
      matchNumber++;
    }

    // Group B - LB-B Round 1 (2 matches): 23101-23102
    for (var i = 0; i < 2; i++) {
      final advancement = advancementMap[matchNumber]!;
      final displayOrder = 23101 + i;

      allMatches.add({
        'tournament_id': tournamentId,
        'match_number': matchNumber,
        'bracket_type': 'LB-B',
        'bracket_group': 'B',
        'stage_round': 1,
        'display_order': displayOrder,
        'winner_advances_to': advancement['winner'],
        'loser_advances_to': advancement['loser'],
        'player1_id': null,
        'player2_id': null,
        'status': 'pending',
      });
      matchNumber++;
    }

    // Group B - LB-B Round 2 (1 match): 23201 [QUALIFIER]
    {
      final advancement = advancementMap[matchNumber]!;
      allMatches.add({
        'tournament_id': tournamentId,
        'match_number': matchNumber,
        'bracket_type': 'LB-B',
        'bracket_group': 'B',
        'stage_round': 2,
        'display_order': 23201,
        'winner_advances_to': advancement['winner'],
        'loser_advances_to': advancement['loser'],
        'player1_id': null,
        'player2_id': null,
        'status': 'pending',
      });
      matchNumber++;
    }

    // ========================================
    // CROSS-BRACKET FINALS (7 matches)
    // ========================================

    // Cross Semi-Finals (4 matches): 31101-31104
    final semiDisplayOrders = [31101, 31102, 31103, 31104];
    for (var i = 0; i < 4; i++) {
      final advancement = advancementMap[matchNumber]!;

      allMatches.add({
        'tournament_id': tournamentId,
        'match_number': matchNumber,
        'bracket_type': 'CROSS',
        'bracket_group': null,
        'stage_round': 1,
        'display_order': semiDisplayOrders[i],
        'winner_advances_to': advancement['winner'],
        'loser_advances_to': advancement['loser'],
        'player1_id': null,
        'player2_id': null,
        'status': 'pending',
      });
      matchNumber++;
    }

    // Cross Finals (2 matches): 32101-32102
    for (var i = 0; i < 2; i++) {
      final advancement = advancementMap[matchNumber]!;
      final displayOrder = 32101 + i;

      allMatches.add({
        'tournament_id': tournamentId,
        'match_number': matchNumber,
        'bracket_type': 'CROSS',
        'bracket_group': null,
        'stage_round': 2,
        'display_order': displayOrder,
        'winner_advances_to': advancement['winner'],
        'loser_advances_to': advancement['loser'],
        'player1_id': null,
        'player2_id': null,
        'status': 'pending',
      });
      matchNumber++;
    }

    // Grand Final (1 match): 33101
    {
      final advancement = advancementMap[matchNumber]!;
      allMatches.add({
        'tournament_id': tournamentId,
        'match_number': matchNumber,
        'bracket_type': 'GF',
        'bracket_group': null,
        'stage_round': 1,
        'display_order': 33101,
        'winner_advances_to': advancement['winner'],
        'loser_advances_to': advancement['loser'],
        'player1_id': null,
        'player2_id': null,
        'status': 'pending',
      });
    }

    return allMatches;
  }

  /// Calculate advancement mapping for all 55 matches
  /// Returns display_order values for winner_advances_to and loser_advances_to
  Map<int, Map<String, int?>> _calculateAdvancementMap() {
    final map = <int, Map<String, int?>>{};

    // ========================================
    // GROUP A ADVANCEMENT (M1-M26)
    // ========================================

    // Group A - WB R1 (M1-M8): winner to WB R2, loser to LB-A R1
    map[1] = {'winner': 11201, 'loser': 12101}; // M1 → M9, M17
    map[2] = {'winner': 11201, 'loser': 12101}; // M2 → M9, M17
    map[3] = {'winner': 11202, 'loser': 12102}; // M3 → M10, M18
    map[4] = {'winner': 11202, 'loser': 12102}; // M4 → M10, M18
    map[5] = {'winner': 11203, 'loser': 12103}; // M5 → M11, M19
    map[6] = {'winner': 11203, 'loser': 12103}; // M6 → M11, M19
    map[7] = {'winner': 11204, 'loser': 12104}; // M7 → M12, M20
    map[8] = {'winner': 11204, 'loser': 12104}; // M8 → M12, M20

    // Group A - WB R2 (M9-M12): winner to WB R3, loser to LB-B R1
    map[9] = {'winner': 11301, 'loser': 13101};  // M9 → M13, M21
    map[10] = {'winner': 11301, 'loser': 13101}; // M10 → M13, M21
    map[11] = {'winner': 11302, 'loser': 13102}; // M11 → M14, M22
    map[12] = {'winner': 11302, 'loser': 13102}; // M12 → M14, M22

    // Group A - WB R3 (M13-M14): winner to Cross SF, NO LOSER ADVANCEMENT
    map[13] = {'winner': 31101, 'loser': null}; // M13 → Cross SF1, no loser
    map[14] = {'winner': 31102, 'loser': null}; // M14 → Cross SF2, no loser

    // Group A - LB-A R1 (M17-M20): winner to LB-A R2
    map[17] = {'winner': 12201, 'loser': null}; // M17 → M23
    map[18] = {'winner': 12201, 'loser': null}; // M18 → M23
    map[19] = {'winner': 12202, 'loser': null}; // M19 → M24
    map[20] = {'winner': 12202, 'loser': null}; // M20 → M24

    // Group A - LB-A R2 (M23-M24): winner to LB-A R3
    map[23] = {'winner': 12301, 'loser': null}; // M23 → M25
    map[24] = {'winner': 12301, 'loser': null}; // M24 → M25

    // Group A - LB-A R3 (M25): winner to Cross SF2 or SF4
    map[25] = {'winner': 31102, 'loser': null}; // M25 → Cross SF2

    // Group A - LB-B R1 (M21-M22): winner to LB-B R2
    map[21] = {'winner': 13201, 'loser': null}; // M21 → M26
    map[22] = {'winner': 13201, 'loser': null}; // M22 → M26

    // Group A - LB-B R2 (M26): winner to Cross SF1
    map[26] = {'winner': 31101, 'loser': null}; // M26 → Cross SF1

    // ========================================
    // GROUP B ADVANCEMENT (M27-M52)
    // ========================================

    // Group B - WB R1 (M27-M34): winner to WB R2, loser to LB-A R1
    map[27] = {'winner': 21201, 'loser': 22101}; // M27 → M35, M43
    map[28] = {'winner': 21201, 'loser': 22101}; // M28 → M35, M43
    map[29] = {'winner': 21202, 'loser': 22102}; // M29 → M36, M44
    map[30] = {'winner': 21202, 'loser': 22102}; // M30 → M36, M44
    map[31] = {'winner': 21203, 'loser': 22103}; // M31 → M37, M45
    map[32] = {'winner': 21203, 'loser': 22103}; // M32 → M37, M45
    map[33] = {'winner': 21204, 'loser': 22104}; // M33 → M38, M46
    map[34] = {'winner': 21204, 'loser': 22104}; // M34 → M38, M46

    // Group B - WB R2 (M35-M38): winner to WB R3, loser to LB-B R1
    map[35] = {'winner': 21301, 'loser': 23101}; // M35 → M39, M47
    map[36] = {'winner': 21301, 'loser': 23101}; // M36 → M39, M47
    map[37] = {'winner': 21302, 'loser': 23102}; // M37 → M40, M48
    map[38] = {'winner': 21302, 'loser': 23102}; // M38 → M40, M48

    // Group B - WB R3 (M39-M40): winner to Cross SF, NO LOSER ADVANCEMENT
    map[39] = {'winner': 31103, 'loser': null}; // M39 → Cross SF3, no loser
    map[40] = {'winner': 31104, 'loser': null}; // M40 → Cross SF4, no loser

    // Group B - LB-A R1 (M43-M46): winner to LB-A R2
    map[43] = {'winner': 22201, 'loser': null}; // M43 → M49
    map[44] = {'winner': 22201, 'loser': null}; // M44 → M49
    map[45] = {'winner': 22202, 'loser': null}; // M45 → M50
    map[46] = {'winner': 22202, 'loser': null}; // M46 → M50

    // Group B - LB-A R2 (M49-M50): winner to LB-A R3
    map[49] = {'winner': 22301, 'loser': null}; // M49 → M51
    map[50] = {'winner': 22301, 'loser': null}; // M50 → M51

    // Group B - LB-A R3 (M51): winner to Cross SF4
    map[51] = {'winner': 31104, 'loser': null}; // M51 → Cross SF4

    // Group B - LB-B R1 (M47-M48): winner to LB-B R2
    map[47] = {'winner': 23201, 'loser': null}; // M47 → M52
    map[48] = {'winner': 23201, 'loser': null}; // M48 → M52

    // Group B - LB-B R2 (M52): winner to Cross SF3
    map[52] = {'winner': 31103, 'loser': null}; // M52 → Cross SF3

    // ========================================
    // CROSS-BRACKET FINALS ADVANCEMENT (M53-M59)
    // ========================================

    // Cross Semi-Finals (M53-M56): winner to Finals
    map[53] = {'winner': 32101, 'loser': null}; // M53 → M57 (Final 1)
    map[54] = {'winner': 32101, 'loser': null}; // M54 → M57 (Final 1)
    map[55] = {'winner': 32102, 'loser': null}; // M55 → M58 (Final 2)
    map[56] = {'winner': 32102, 'loser': null}; // M56 → M58 (Final 2)

    // Cross Finals (M57-M58): winner to Grand Final
    map[57] = {'winner': 33101, 'loser': null}; // M57 → M59 (GF)
    map[58] = {'winner': 33101, 'loser': null}; // M58 → M59 (GF)

    // Grand Final (M59): winner is champion, no advancement
    map[59] = {'winner': null, 'loser': null};

    return map;
  }
}
