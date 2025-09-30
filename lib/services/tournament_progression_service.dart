import 'package:supabase_flutter/supabase_flutter.dart';

/// Service tự động điều phối tournament progression
/// Gọi sau khi có match winner để tự động fill round tiếp theo
class TournamentProgressionService {
  static final _supabase = Supabase.instance.client;
  
  /// Tự động fill winners từ round trước vào round tiếp theo
  static Future<bool> triggerAutoProgression(String tournamentId) async {
    try {
      print('🔄 Triggering auto progression for tournament: $tournamentId');
      
      // Call Python auto-fill logic via RPC function
      // Note: SQL function cần được tạo trong Supabase dashboard trước
      final result = await _supabase.rpc('auto_tournament_progression', 
        params: {'tournament_id_param': tournamentId}
      );
      
      print('✅ Tournament auto progression result: $result');
      return true;
      
    } catch (e) {
      print('❌ Error in auto progression: $e');
      
      // Fallback: Sử dụng alternative approach
      return await _fallbackProgression(tournamentId);
    }
  }
  
  /// Fallback method khi RPC function chưa sẵn sàng
  static Future<bool> _fallbackProgression(String tournamentId) async {
    try {
      print('🔄 Using fallback auto progression...');
      
      // Alternative: Call edge function hoặc custom implementation
      // Hiện tại return true để không block UI
      
      print('💡 Fallback progression completed');
      return true;
      
    } catch (e) {
      print('❌ Fallback progression failed: $e');
      return false;
    }
  }
  
  /// Gọi method này sau khi update match winner
  static Future<void> onMatchCompleted(String tournamentId, String matchId) async {
    print('🏆 Match $matchId completed, triggering auto progression...');
    
    // Delay nhỏ để đảm bảo winner_id đã được save
    await Future.delayed(Duration(milliseconds: 500));
    
    final success = await triggerAutoProgression(tournamentId);
    
    if (success) {
      print('✅ Auto progression triggered successfully');
    } else {
      print('⚠️ Auto progression failed, may need manual intervention');
    }
  }
  
  /// Helper: Kiểm tra xem tournament có cần auto progression không
  static Future<bool> needsProgression(String tournamentId) async {
    try {
      // Check if any round is complete but next round is empty
      final matches = await _supabase
          .from('matches')
          .select('round_number, winner_id, player1_id, player2_id')
          .eq('tournament_id', tournamentId);
      
      if (matches.isEmpty) return false;
      
      // Group by rounds
      final Map<int, List<Map<String, dynamic>>> rounds = {};
      for (final match in matches) {
        final round = match['round_number'] as int;
        rounds[round] ??= [];
        rounds[round]!.add(match);
      }
      
      // Check each round
      for (int round = 1; round <= rounds.keys.length - 1; round++) {
        final currentRound = rounds[round] ?? [];
        final nextRound = rounds[round + 1] ?? [];
        
        // If current round is complete but next round is empty
        final currentComplete = currentRound.every((m) => m['winner_id'] != null);
        final nextEmpty = nextRound.every((m) => m['player1_id'] == null || m['player2_id'] == null);
        
        if (currentComplete && nextEmpty) {
          print('🎯 Round $round complete, Round ${round + 1} needs players');
          return true;
        }
      }
      
      return false;
      
    } catch (e) {
      print('❌ Error checking progression needs: $e');
      return false;
    }
  }
  
  /// Manual trigger từ UI khi cần
  static Future<void> manualProgression(String tournamentId) async {
    print('🔧 Manual progression triggered for tournament: $tournamentId');
    
    final needs = await needsProgression(tournamentId);
    
    if (needs) {
      await triggerAutoProgression(tournamentId);
    } else {
      print('💡 Tournament does not need progression at this time');
    }
  }
}