  /// 🎯 SIMPLE DIRECT WINNER ADVANCEMENT (with Double Elimination support)
  /// Triggered immediately when user clicks "Lưu" with match result
  Future<void> _advanceWinnerDirectly(String completedMatchId, String winnerId, Map<String, dynamic> completedMatch) async {
    try {
      debugPrint('🚀 ADVANCING PLAYERS from match $completedMatchId');
      
      final currentMatchNumber = completedMatch['match_number'] ?? 1;
      final winnerAdvancesTo = completedMatch['winner_advances_to'];
      final loserAdvancesTo = completedMatch['loser_advances_to'];
      
      debugPrint('📍 Current Match Number: $currentMatchNumber');
      debugPrint('🎯 Winner Advances To Match: $winnerAdvancesTo');
      debugPrint('🎯 Loser Advances To Match: $loserAdvancesTo');
      
      // Get loser ID (the player who didn't win)
      final player1Id = completedMatch['player1_id'];
      final player2Id = completedMatch['player2_id'];
      final loserId = (winnerId == player1Id) ? player2Id : player1Id;
      
      // ADVANCE WINNER
      if (winnerAdvancesTo != null) {
        await _advancePlayerToMatch(
          playerId: winnerId,
          targetMatchNumber: winnerAdvancesTo,
          currentMatchNumber: currentMatchNumber,
          role: 'WINNER',
        );
      } else {
        debugPrint('🏆 NO NEXT MATCH FOR WINNER - THIS IS THE FINAL! Champion: $winnerId');
      }
      
      // ADVANCE LOSER (for Double Elimination)
      if (loserAdvancesTo != null && loserId != null) {
        await _advancePlayerToMatch(
          playerId: loserId,
          targetMatchNumber: loserAdvancesTo,
          currentMatchNumber: currentMatchNumber,
          role: 'LOSER',
        );
      }
      
      // Refresh the matches display to show the update
      await _refreshMatches();
      
    } catch (e) {
      debugPrint('❌ Error advancing players: $e');
    }
  }

  /// Helper function to advance a player to target match
  Future<void> _advancePlayerToMatch({
    required String playerId,
    required int targetMatchNumber,
    required int currentMatchNumber,
    required String role,
  }) async {
    try {
      debugPrint('🎯 Advancing $role: $playerId from match $currentMatchNumber → match $targetMatchNumber');
      
      // Find the target match by match_number
      final targetMatches = await Supabase.instance.client
          .from('matches')
          .select('*')
          .eq('tournament_id', widget.tournamentId)
          .eq('match_number', targetMatchNumber);
      
      if (targetMatches.isEmpty) {
        debugPrint('⚠️ Target match $targetMatchNumber not found!');
        return;
      }
      
      final targetMatch = targetMatches.first;
      debugPrint('📋 Target match found: ${targetMatch['id']}');
      
      // Determine which slot (player1_id or player2_id) to place player
      // Even match numbers go to player2_id, odd go to player1_id
      final isEvenCurrentMatch = currentMatchNumber % 2 == 0;
      final playerSlot = isEvenCurrentMatch ? 'player2_id' : 'player1_id';
      
      debugPrint('🎪 Assigning $role to $playerSlot (Current match $currentMatchNumber is ${isEvenCurrentMatch ? 'even' : 'odd'})');
      
      // Update the target match with the player
      await Supabase.instance.client
          .from('matches')
          .update({playerSlot: playerId})
          .eq('id', targetMatch['id']);
      
      debugPrint('✅ $role ADVANCED SUCCESSFULLY! $playerId → Match $targetMatchNumber (Round ${targetMatch['round_number']})');
      
    } catch (e) {
      debugPrint('❌ Error advancing $role: $e');
    }
  }
