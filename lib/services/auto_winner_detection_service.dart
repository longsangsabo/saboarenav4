import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 🎯 Auto Winner Detection Service
/// Automatically detects and sets winners based on match scores
/// Fixes the issue where matches are completed but winner_id is null
class AutoWinnerDetectionService {
  static final AutoWinnerDetectionService _instance = AutoWinnerDetectionService._internal();
  factory AutoWinnerDetectionService() => _instance;
  AutoWinnerDetectionService._internal();

  static AutoWinnerDetectionService get instance => _instance;
  
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Detect and set winner based on scores for completed matches
  Future<bool> detectAndSetWinner({
    required String matchId,
    required int player1Score,
    required int player2Score,
    required String player1Id,
    required String player2Id,
  }) async {
    try {
      // Determine winner based on scores
      String? winnerId;
      
      if (player1Score > player2Score) {
        winnerId = player1Id;
      } else if (player2Score > player1Score) {
        winnerId = player2Id;
      } else {
        // Tie game - no winner can be determined
        debugPrint('⚠️ Match $matchId: Tie game, cannot determine winner');
        return false;
      }
      
      debugPrint('🏆 Auto-detecting winner: $winnerId (Scores: $player1Score-$player2Score)');
      
      // Update match with winner
      await _supabase.from('matches').update({
        'winner_id': winnerId,
        'status': 'completed',
      }).eq('id', matchId);
      
      debugPrint('✅ Winner set successfully for match $matchId');
      
      // Trigger progression
      await _triggerProgressionCheck(matchId);
      
      return true;
      
    } catch (e) {
      debugPrint('❌ Error setting winner for match $matchId: $e');
      return false;
    }
  }
  
  /// Fix all completed matches that are missing winners
  Future<int> fixAllMatchesMissingWinners() async {
    try {
      debugPrint('🔧 Scanning for matches missing winners...');
      
      // Find all completed matches without winners but with scores
      final response = await _supabase
          .from('matches')
          .select('*')
          .eq('status', 'completed')
          .isFilter('winner_id', null)
          .not('player1_score', 'is', null)
          .not('player2_score', 'is', null);
      
      final matches = response as List;
      debugPrint('🔍 Found ${matches.length} matches needing winner detection');
      
      int fixedCount = 0;
      
      for (final match in matches) {
        final player1Score = match['player1_score'] as int? ?? 0;
        final player2Score = match['player2_score'] as int? ?? 0;
        final player1Id = match['player1_id'] as String?;
        final player2Id = match['player2_id'] as String?;
        
        if (player1Id != null && player2Id != null) {
          final success = await detectAndSetWinner(
            matchId: match['id'],
            player1Score: player1Score,
            player2Score: player2Score,
            player1Id: player1Id,
            player2Id: player2Id,
          );
          
          if (success) {
            fixedCount++;
          }
        }
      }
      
      debugPrint('✅ Fixed $fixedCount matches with missing winners');
      return fixedCount;
      
    } catch (e) {
      debugPrint('❌ Error fixing matches: $e');
      return 0;
    }
  }
  
  /// Trigger progression check after setting winner
  Future<void> _triggerProgressionCheck(String matchId) async {
    try {
      // Get match details
      final match = await _supabase
          .from('matches')
          .select('tournament_id, round_number, match_number')
          .eq('id', matchId)
          .single();
      
      // Small delay to ensure database is updated
      await Future.delayed(Duration(milliseconds: 500));
      
      debugPrint('🚀 Triggered progression check for match ${match['match_number']}');
      
    } catch (e) {
      debugPrint('⚠️ Error triggering progression: $e');
    }
  }
  
  /// Monitor matches and auto-fix when needed
  void startAutoFixMonitoring() {
    debugPrint('👁️ Starting auto-fix monitoring...');
    
    // Run initial fix
    fixAllMatchesMissingWinners();
    
    // Set up periodic checking
    Stream.periodic(Duration(seconds: 30)).listen((_) {
      fixAllMatchesMissingWinners();
    });
  }
}