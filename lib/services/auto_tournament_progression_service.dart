import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'tournament_completion_service.dart';

/// 🎯 SABO Arena Auto Tournament Progression Service
/// Handles automatic tournament progression when matches are completed
/// NO MORE MANUAL FIXES NEEDED!
class AutoTournamentProgressionService {
  static final AutoTournamentProgressionService _instance = AutoTournamentProgressionService._internal();
  factory AutoTournamentProgressionService() => _instance;
  AutoTournamentProgressionService._internal();

  static AutoTournamentProgressionService get instance => _instance;
  
  final SupabaseClient _supabase = Supabase.instance.client;
  final TournamentCompletionService _completionService = TournamentCompletionService.instance;
  RealtimeChannel? _matchSubscription;
  
  bool _isEnabled = true;
  
  /// Enable/disable auto progression
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
    debugPrint('🎯 Auto Tournament Progression: ${enabled ? 'ENABLED' : 'DISABLED'}');
  }
  
  /// Initialize auto progression monitoring
  void initialize() async {
    debugPrint('🚀 Initializing Auto Tournament Progression Service...');
    _setupRealtimeListening();
    
    // Process any existing completed matches that weren't handled
    await _processExistingCompletedMatches();
  }
  
  /// Process existing completed matches on startup
  Future<void> _processExistingCompletedMatches() async {
    try {
      debugPrint('🔍 Scanning for completed matches needing progression...');
      
      // Find all completed matches with winners that might need processing
      final completedMatches = await _supabase
          .from('matches')
          .select('id, tournament_id, round_number, match_number, winner_id, winner_advances_to, loser_advances_to')
          .eq('status', 'completed')
          .not('winner_id', 'is', null);
      
      if (completedMatches.isEmpty) {
        debugPrint('  ℹ️ No completed matches found');
        return;
      }
      
      debugPrint('  Found ${completedMatches.length} completed matches');
      
      // Group by tournament to avoid duplicate processing
      final Map<String, List<dynamic>> matchesByTournament = {};
      for (final match in completedMatches) {
        final tournamentId = match['tournament_id'] as String;
        matchesByTournament.putIfAbsent(tournamentId, () => []).add(match);
      }
      
      // Process each tournament's completed matches
      int processedCount = 0;
      for (final entry in matchesByTournament.entries) {
        final tournamentId = entry.key;
        final matches = entry.value;
        
        for (final match in matches) {
          // Check if advancement is needed (has advancement targets with empty slots)
          final needsProcessing = await _checkIfAdvancementNeeded(
            tournamentId: tournamentId,
            winnerAdvancesTo: match['winner_advances_to'],
            loserAdvancesTo: match['loser_advances_to'],
          );
          
          if (needsProcessing) {
            await _processMatchCompletion(
              tournamentId: tournamentId,
              roundNumber: match['round_number'] ?? 1,
              matchNumber: match['match_number'],
              winnerId: match['winner_id'],
            );
            processedCount++;
            
            // Small delay to avoid overwhelming the system
            await Future.delayed(Duration(milliseconds: 100));
          }
        }
      }
      
      if (processedCount > 0) {
        debugPrint('✅ Processed $processedCount matches needing progression');
      } else {
        debugPrint('  ℹ️ All completed matches already processed');
      }
      
    } catch (e) {
      debugPrint('❌ Error processing existing completed matches: $e');
    }
  }
  
  /// Check if a match needs advancement processing
  Future<bool> _checkIfAdvancementNeeded({
    required String tournamentId,
    required int? winnerAdvancesTo,
    required int? loserAdvancesTo,
  }) async {
    try {
      // If no advancement targets, no processing needed
      if (winnerAdvancesTo == null && loserAdvancesTo == null) {
        return false;
      }
      
      // Check if target matches have empty slots
      final List<int> targetDisplayOrders = [];
      if (winnerAdvancesTo != null) targetDisplayOrders.add(winnerAdvancesTo);
      if (loserAdvancesTo != null) targetDisplayOrders.add(loserAdvancesTo);
      
      if (targetDisplayOrders.isEmpty) return false;
      
      final targetMatches = await _supabase
          .from('matches')
          .select('display_order, player1_id, player2_id')
          .eq('tournament_id', tournamentId)
          .inFilter('display_order', targetDisplayOrders);
      
      // Check if any target match has empty slots
      for (final match in targetMatches) {
        if (match['player1_id'] == null || match['player2_id'] == null) {
          return true; // Found empty slot, needs processing
        }
      }
      
      return false; // All target matches already populated
      
    } catch (e) {
      debugPrint('❌ Error checking advancement need: $e');
      return false;
    }
  }
  
  /// Setup realtime listening for match updates
  void _setupRealtimeListening() {
    try {
      _matchSubscription = _supabase
          .channel('matches_progression')
          .onPostgresChanges(
            event: PostgresChangeEvent.update,
            schema: 'public',
            table: 'matches',
            callback: (payload) {
              if (_isEnabled) {
                _handleMatchUpdate(payload.newRecord);
              }
            },
          )
          .subscribe();
          
      debugPrint('✅ Auto progression realtime listener setup complete');
    } catch (e) {
      debugPrint('❌ Error setting up realtime listening: $e');
    }
  }
  
  /// Handle match update from realtime
  void _handleMatchUpdate(Map<String, dynamic> matchData) async {
    try {
      final status = matchData['status'];
      final winnerId = matchData['winner_id'];
      final tournamentId = matchData['tournament_id'];
      final roundNumber = matchData['round_number'];
      final matchNumber = matchData['match_number'];
      
      // Only process completed matches with winners
      if (status == 'completed' && winnerId != null) {
        debugPrint('🎯 Match M$matchNumber completed, processing advancement...');
        
        await _processMatchCompletion(
          tournamentId: tournamentId,
          roundNumber: roundNumber,
          matchNumber: matchNumber,
          winnerId: winnerId,
        );
      }
    } catch (e) {
      debugPrint('❌ Error handling match update: $e');
    }
  }
  
  /// Process match completion and advance winners
  /// UNIVERSAL APPROACH: Uses advancement fields instead of format detection
  Future<void> _processMatchCompletion({
    required String tournamentId,
    required int roundNumber,
    required int matchNumber,
    required String winnerId,
  }) async {
    try {
      debugPrint('🎯 Processing tournament advancement for Match $matchNumber...');
      
      // UNIVERSAL APPROACH: Check if match has loser_advances_to field
      // If yes: Double Elimination
      // If no: Single Elimination
      final matchInfo = await _supabase
          .from('matches')
          .select('loser_advances_to')
          .eq('tournament_id', tournamentId)
          .eq('match_number', matchNumber)
          .maybeSingle();
      
      if (matchInfo == null) {
        debugPrint('⚠️ Match not found');
        return;
      }
      
      final hasLoserAdvancement = matchInfo['loser_advances_to'] != null;
      
      if (hasLoserAdvancement) {
        // Double Elimination (includes SABO DE32, SABO DE16, standard DE)
        debugPrint('  Format: Double Elimination (detected via loser_advances_to)');
        await _processDoubleEliminationAdvancement(
          tournamentId: tournamentId,
          roundNumber: roundNumber,
          matchNumber: matchNumber,
        );
      } else {
        // Single Elimination
        debugPrint('  Format: Single Elimination');
        await _processSingleEliminationAdvancement(
          tournamentId: tournamentId,
          roundNumber: roundNumber,
          matchNumber: matchNumber,
        );
      }
      
      // 🏆 CHECK FOR TOURNAMENT COMPLETION AFTER ADVANCEMENT
      await _checkForAutoCompletion(tournamentId);
      
    } catch (e) {
      debugPrint('❌ Error processing match completion: $e');
    }
  }
  
  /// Check if tournament should be auto-completed
  Future<void> _checkForAutoCompletion(String tournamentId) async {
    try {
      debugPrint('🏁 Checking if tournament should be completed...');
      
      // Use completion service to check and auto-complete if ready
      final wasCompleted = await _completionService.checkAndAutoCompleteTournament(tournamentId);
      
      if (wasCompleted) {
        debugPrint('🎉 Tournament auto-completed by progression service!');
      } else {
        debugPrint('⏳ Tournament not ready for completion yet');
      }
      
    } catch (e) {
      debugPrint('❌ Error checking tournament completion: $e');
    }
  }
  
  /// Process single elimination advancement
  /// UPDATED: Uses winner_advances_to field for routing (works for all brackets)
  Future<void> _processSingleEliminationAdvancement({
    required String tournamentId,
    required int roundNumber,
    required int matchNumber,
  }) async {
    try {
      debugPrint('🎯 Processing Single Elimination advancement for Match $matchNumber...');
      
      // Get the completed match details with advancement info
      final completedMatch = await _supabase
          .from('matches')
          .select('id, display_order, winner_id, player1_id, player2_id, winner_advances_to, bracket_type, bracket_group')
          .eq('tournament_id', tournamentId)
          .eq('match_number', matchNumber)
          .eq('status', 'completed')
          .maybeSingle();
      
      if (completedMatch == null) {
        debugPrint('⚠️ Completed match not found or not ready');
        return;
      }
      
      final winnerId = completedMatch['winner_id'];
      final winnerAdvancesTo = completedMatch['winner_advances_to'];
      
      if (winnerAdvancesTo == null) {
        debugPrint('  ℹ️ No winner advancement (final match or eliminated)');
        return;
      }
      
      debugPrint('  Winner: $winnerId → Display Order: $winnerAdvancesTo');
      
      // Process winner advancement using display_order routing
      await _advancePlayerToMatch(
        tournamentId: tournamentId,
        playerId: winnerId,
        targetDisplayOrder: winnerAdvancesTo,
        sourceMatchNumber: matchNumber,
        isWinner: true,
      );
      
      debugPrint('✅ Single Elimination advancement complete for Match $matchNumber');
      
    } catch (e) {
      debugPrint('❌ Error in single elimination advancement: $e');
    }
  }
  

  
  /// Process double elimination advancement - UNIVERSAL IMPLEMENTATION
  /// Works with ANY DE format that uses winner_advances_to/loser_advances_to fields
  Future<void> _processDoubleEliminationAdvancement({
    required String tournamentId,
    required int roundNumber,
    required int matchNumber,
  }) async {
    try {
      debugPrint('🎯 Processing Double Elimination advancement for Match $matchNumber...');
      
      // Get the completed match details with advancement info
      final completedMatch = await _supabase
          .from('matches')
          .select('id, display_order, winner_id, player1_id, player2_id, winner_advances_to, loser_advances_to, bracket_type, bracket_group')
          .eq('tournament_id', tournamentId)
          .eq('match_number', matchNumber)
          .eq('status', 'completed')
          .maybeSingle();
      
      if (completedMatch == null) {
        debugPrint('⚠️ Completed match not found or not ready');
        return;
      }
      
      final winnerId = completedMatch['winner_id'];
      final player1Id = completedMatch['player1_id'];
      final player2Id = completedMatch['player2_id'];
      final loserId = winnerId == player1Id ? player2Id : player1Id;
      final winnerAdvancesTo = completedMatch['winner_advances_to'];
      final loserAdvancesTo = completedMatch['loser_advances_to'];
      
      debugPrint('  Winner: $winnerId → Display Order: $winnerAdvancesTo');
      debugPrint('  Loser: $loserId → Display Order: $loserAdvancesTo');
      
      // Process winner advancement
      if (winnerAdvancesTo != null) {
        await _advancePlayerToMatch(
          tournamentId: tournamentId,
          playerId: winnerId,
          targetDisplayOrder: winnerAdvancesTo,
          sourceMatchNumber: matchNumber,
          isWinner: true,
        );
      } else {
        debugPrint('  ℹ️ No winner advancement (final match)');
      }
      
      // Process loser advancement (for Double Elimination)
      if (loserAdvancesTo != null) {
        await _advancePlayerToMatch(
          tournamentId: tournamentId,
          playerId: loserId,
          targetDisplayOrder: loserAdvancesTo,
          sourceMatchNumber: matchNumber,
          isWinner: false,
        );
      } else {
        debugPrint('  ℹ️ No loser advancement (loser eliminated)');
      }
      
      debugPrint('✅ Double Elimination advancement complete for Match $matchNumber');
      
    } catch (e) {
      debugPrint('❌ Error in double elimination advancement: $e');
    }
  }
  
  /// Advance a player to the next match based on display_order
  Future<void> _advancePlayerToMatch({
    required String tournamentId,
    required String playerId,
    required int targetDisplayOrder,
    required int sourceMatchNumber,
    required bool isWinner,
  }) async {
    try {
      // Find the target match by display_order
      final targetMatch = await _supabase
          .from('matches')
          .select('id, match_number, player1_id, player2_id, status, bracket_type, bracket_group, stage_round')
          .eq('tournament_id', tournamentId)
          .eq('display_order', targetDisplayOrder)
          .maybeSingle();
      
      if (targetMatch == null) {
        debugPrint('⚠️ Target match with display_order $targetDisplayOrder not found');
        return;
      }
      
      final targetMatchNumber = targetMatch['match_number'];
      final currentPlayer1 = targetMatch['player1_id'];
      final currentPlayer2 = targetMatch['player2_id'];
      
      // 🚨 CRITICAL: Check for duplicate player (prevent same user in both slots)
      if (playerId == currentPlayer1) {
        debugPrint('⚠️ Player already in match M$targetMatchNumber as player1, skipping duplicate advancement');
        return;
      }
      if (playerId == currentPlayer2) {
        debugPrint('⚠️ Player already in match M$targetMatchNumber as player2, skipping duplicate advancement');
        return;
      }
      
      // Determine which slot to fill (player1 or player2)
      String? updateField;
      if (currentPlayer1 == null) {
        updateField = 'player1_id';
      } else if (currentPlayer2 == null) {
        updateField = 'player2_id';
      } else {
        debugPrint('⚠️ Target match M$targetMatchNumber already has both players');
        return;
      }
      
      // Update the target match
      await _supabase
          .from('matches')
          .update({updateField: playerId})
          .eq('tournament_id', tournamentId)
          .eq('display_order', targetDisplayOrder);
      
      final roleStr = isWinner ? '🏆 Winner' : '💔 Loser';
      debugPrint('  ✅ $roleStr advanced: M$sourceMatchNumber → M$targetMatchNumber ($updateField)');
      
      // Check if both players are now populated and update status
      final updatedMatch = await _supabase
          .from('matches')
          .select('player1_id, player2_id')
          .eq('tournament_id', tournamentId)
          .eq('display_order', targetDisplayOrder)
          .maybeSingle();
      
      if (updatedMatch != null && 
          updatedMatch['player1_id'] != null && 
          updatedMatch['player2_id'] != null) {
        // Both players ready - set status to pending
        await _supabase
            .from('matches')
            .update({'status': 'pending'})
            .eq('tournament_id', tournamentId)
            .eq('display_order', targetDisplayOrder);
        
        debugPrint('  🎮 Match M$targetMatchNumber ready to play (both players populated)');
      }
      
    } catch (e) {
      debugPrint('❌ Error advancing player to match: $e');
    }
  }
  

  
  /// Manual trigger for tournament progression (emergency use)
  Future<bool> manualProgressTournament(String tournamentId) async {
    try {
      debugPrint('🔧 Manual tournament progression triggered...');
      
      // Find all completed matches without proper advancement
      final response = await _supabase
          .from('matches')
          .select('*')
          .eq('tournament_id', tournamentId)
          .eq('status', 'completed')
          .not('winner_id', 'is', null);
          
      final completedMatches = response as List;
      
      // Process each completed match
      for (final match in completedMatches) {
        await _processMatchCompletion(
          tournamentId: tournamentId,
          roundNumber: match['round_number'],
          matchNumber: match['match_number'],
          winnerId: match['winner_id'],
        );
      }
      
      debugPrint('✅ Manual progression completed');
      return true;
      
    } catch (e) {
      debugPrint('❌ Error in manual progression: $e');
      return false;
    }
  }
  
  /// 🛡️ VALIDATION: Check match data integrity before processing
  /// Returns null if valid, error message if invalid
  Future<String?> _validateMatchBeforeAdvancement({
    required String tournamentId,
    required int matchNumber,
  }) async {
    try {
      final match = await _supabase
          .from('matches')
          .select('*')
          .eq('tournament_id', tournamentId)
          .eq('match_number', matchNumber)
          .maybeSingle();
      
      if (match == null) return 'Match not found';
      
      // Check 1: Duplicate players
      if (match['player1_id'] != null && 
          match['player2_id'] != null && 
          match['player1_id'] == match['player2_id']) {
        return '❌ DUPLICATE PLAYER: Same user in both slots (M$matchNumber)';
      }
      
      // Check 2: Completed match must have winner
      if (match['status'] == 'completed' && match['winner_id'] == null) {
        return '❌ INVALID COMPLETION: Completed match has no winner (M$matchNumber)';
      }
      
      // Check 3: Winner must be one of the players
      if (match['winner_id'] != null) {
        if (match['winner_id'] != match['player1_id'] && 
            match['winner_id'] != match['player2_id']) {
          return '❌ INVALID WINNER: Winner is not one of the players (M$matchNumber)';
        }
      }
      
      // Check 4: Pending match must have both players
      if (match['status'] == 'pending' && 
          (match['player1_id'] == null || match['player2_id'] == null)) {
        return '⚠️ INVALID STATUS: Pending match missing players (M$matchNumber)';
      }
      
      // Check 5: Advancement targets exist
      if (match['winner_advances_to'] != null) {
        final targetExists = await _supabase
            .from('matches')
            .select('id')
            .eq('tournament_id', tournamentId)
            .eq('display_order', match['winner_advances_to'])
            .maybeSingle();
        
        if (targetExists == null) {
          return '⚠️ INVALID ADVANCEMENT: winner_advances_to target does not exist (M$matchNumber → ${match['winner_advances_to']})';
        }
      }
      
      if (match['loser_advances_to'] != null) {
        final targetExists = await _supabase
            .from('matches')
            .select('id')
            .eq('tournament_id', tournamentId)
            .eq('display_order', match['loser_advances_to'])
            .maybeSingle();
        
        if (targetExists == null) {
          return '⚠️ INVALID ADVANCEMENT: loser_advances_to target does not exist (M$matchNumber → ${match['loser_advances_to']})';
        }
      }
      
      return null; // All checks passed
      
    } catch (e) {
      return 'Validation error: $e';
    }
  }
  
  /// 🛡️ RUN FULL TOURNAMENT VALIDATION
  /// Call this before starting tournament to catch structural issues
  Future<List<String>> validateTournamentStructure(String tournamentId) async {
    debugPrint('🔍 Validating tournament structure...');
    final List<String> errors = [];
    
    try {
      final matches = await _supabase
          .from('matches')
          .select('*')
          .eq('tournament_id', tournamentId)
          .order('match_number');
      
      for (final match in matches) {
        final error = await _validateMatchBeforeAdvancement(
          tournamentId: tournamentId,
          matchNumber: match['match_number'],
        );
        
        if (error != null) {
          errors.add(error);
        }
      }
      
      if (errors.isEmpty) {
        debugPrint('✅ Tournament structure is valid!');
      } else {
        debugPrint('❌ Found ${errors.length} validation errors:');
        for (final error in errors) {
          debugPrint('  $error');
        }
      }
      
    } catch (e) {
      errors.add('Validation failed: $e');
    }
    
    return errors;
  }

  /// Dispose resources
  void dispose() {
    _matchSubscription?.unsubscribe();
    debugPrint('🛑 Auto Tournament Progression Service disposed');
  }
}