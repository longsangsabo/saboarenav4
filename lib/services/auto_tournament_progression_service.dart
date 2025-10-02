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
  void initialize() {
    debugPrint('🚀 Initializing Auto Tournament Progression Service...');
    _setupRealtimeListening();
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
  Future<void> _processMatchCompletion({
    required String tournamentId,
    required int roundNumber,
    required int matchNumber,
    required String winnerId,
  }) async {
    try {
      // Get tournament format
      final tournament = await _supabase
          .from('tournaments')
          .select('format, tournament_type')
          .eq('id', tournamentId)
          .single();
          
      final format = tournament['format'] ?? tournament['tournament_type'] ?? 'single_elimination';
      
      debugPrint('🎯 Processing $format tournament advancement...');
      
      // Handle different tournament formats
      switch (format) {
        case 'single_elimination':
          await _processSingleEliminationAdvancement(
            tournamentId: tournamentId,
            roundNumber: roundNumber,
            matchNumber: matchNumber,
          );
          break;
          
        case 'double_elimination':
        case 'sabo_double_elimination':
          await _processDoubleEliminationAdvancement(
            tournamentId: tournamentId,
            roundNumber: roundNumber,
            matchNumber: matchNumber,
          );
          break;
          
        default:
          debugPrint('⚠️ Unsupported tournament format: $format');
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
  Future<void> _processSingleEliminationAdvancement({
    required String tournamentId,
    required int roundNumber,
    required int matchNumber,
  }) async {
    try {
      // Determine which matches need to be completed before advancing
      List<int> requiredMatches = _getSingleEliminationMatchPair(roundNumber, matchNumber);
      
      if (requiredMatches.isEmpty) {
        debugPrint('⚠️ No advancement needed for this match');
        return;
      }
      
      // Check if both matches in the pair are completed
      final response = await _supabase
          .from('matches')
          .select('match_number, winner_id, status')
          .eq('tournament_id', tournamentId)
          .eq('round_number', roundNumber)
          .inFilter('match_number', requiredMatches)
          .eq('status', 'completed')
          .not('winner_id', 'is', null);
      
      final completedMatches = response as List;
      
      // Only advance if both matches are completed
      if (completedMatches.length == 2) {
        await _advanceSingleEliminationWinners(
          tournamentId: tournamentId,
          roundNumber: roundNumber,
          completedMatches: completedMatches,
        );
      } else {
        debugPrint('⏳ Waiting for pair match to complete before advancing');
      }
    } catch (e) {
      debugPrint('❌ Error in single elimination advancement: $e');
    }
  }
  
  /// Get the pair of matches that must be completed together
  List<int> _getSingleEliminationMatchPair(int roundNumber, int matchNumber) {
    switch (roundNumber) {
      case 1:
        // Round 1: M1,M2 -> M9 | M3,M4 -> M10 | M5,M6 -> M11 | M7,M8 -> M12
        if (matchNumber <= 2) return [1, 2];
        if (matchNumber <= 4) return [3, 4];
        if (matchNumber <= 6) return [5, 6];
        if (matchNumber <= 8) return [7, 8];
        break;
        
      case 2:
        // Round 2: M9,M10 -> M13 | M11,M12 -> M14
        if (matchNumber <= 10) return [9, 10];
        if (matchNumber <= 12) return [11, 12];
        break;
        
      case 3:
        // Round 3: M13,M14 -> M15 (Finals)
        return [13, 14];
        
      default:
        return [];
    }
    return [];
  }
  
  /// Advance single elimination winners to next round
  Future<void> _advanceSingleEliminationWinners({
    required String tournamentId,
    required int roundNumber,
    required List completedMatches,
  }) async {
    try {
      // Calculate next round details
      final nextRound = roundNumber + 1;
      int nextMatchNumber = _calculateNextMatchNumber(roundNumber, completedMatches[0]['match_number']);
      
      // Sort matches by match number
      completedMatches.sort((a, b) => a['match_number'].compareTo(b['match_number']));
      
      final winner1Id = completedMatches[0]['winner_id'];
      final winner2Id = completedMatches[1]['winner_id'];
      
      debugPrint('🚀 Advancing winners to Round $nextRound Match $nextMatchNumber');
      
      // Update next match with winners
      await _supabase.from('matches').update({
        'player1_id': winner1Id,
        'player2_id': winner2Id,
        'status': 'pending',
      }).eq('tournament_id', tournamentId)
        .eq('round_number', nextRound)
        .eq('match_number', nextMatchNumber);
        
      debugPrint('✅ Successfully advanced winners to next round');
      
      // Check if tournament is complete
      await _checkTournamentCompletion(tournamentId);
      
    } catch (e) {
      debugPrint('❌ Error advancing winners: $e');
    }
  }
  
  /// Calculate next match number based on current round and match
  int _calculateNextMatchNumber(int currentRound, int currentMatchNumber) {
    switch (currentRound) {
      case 1:
        // R1 -> R2: M1,M2->M9, M3,M4->M10, M5,M6->M11, M7,M8->M12
        return 8 + ((currentMatchNumber + 1) ~/ 2);
        
      case 2:
        // R2 -> R3: M9,M10->M13, M11,M12->M14
        return 12 + ((currentMatchNumber - 8) ~/ 2);
        
      case 3:
        // R3 -> Finals: M13,M14->M15
        return 15;
        
      default:
        return currentMatchNumber + 10; // Fallback
    }
  }
  
  /// Process double elimination advancement (TODO)
  Future<void> _processDoubleEliminationAdvancement({
    required String tournamentId,
    required int roundNumber,
    required int matchNumber,
  }) async {
    debugPrint('🚧 Double elimination auto-advancement not implemented yet');
  }
  
  /// Check if tournament is complete and update status
  Future<void> _checkTournamentCompletion(String tournamentId) async {
    try {
      // Check if final match is completed
      final finalMatch = await _supabase
          .from('matches')
          .select('status, winner_id')
          .eq('tournament_id', tournamentId)
          .eq('match_number', 15) // Finals
          .maybeSingle();
          
      if (finalMatch != null && 
          finalMatch['status'] == 'completed' && 
          finalMatch['winner_id'] != null) {
        
        // Update tournament status to completed
        await _supabase.from('tournaments').update({
          'status': 'completed',
          'completed_at': DateTime.now().toIso8601String(),
        }).eq('id', tournamentId);
        
        debugPrint('🏆 Tournament completed! Champion determined.');
      }
    } catch (e) {
      debugPrint('❌ Error checking tournament completion: $e');
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
  
  /// Dispose resources
  void dispose() {
    _matchSubscription?.unsubscribe();
    debugPrint('🛑 Auto Tournament Progression Service disposed');
  }
}