import 'dart:io';
import 'package:supabase/supabase.dart';

Future<void> main() async {
  print('🔍 PHÂN TÍCH CHI TIẾT MATCHES VỚI THÔNG TIN LIÊN QUAN...\n');

  const supabaseUrl = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
  const anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ';

  try {
    final supabase = SupabaseClient(supabaseUrl, anonKey);
    
    // 1. Lấy matches với thông tin player và tournament
    print('🏓 MATCHES VỚI THÔNG TIN CHI TIẾT:\n');
    
    final matchesWithDetails = await supabase.from('matches').select('''
      id,
      round_number,
      match_number,
      player1_score,
      player2_score,
      status,
      scheduled_time,
      start_time,
      end_time,
      winner_id,
      tournaments!inner (
        id,
        title,
        start_date,
        status
      ),
      player1:users!matches_player1_id_fkey (
        id,
        display_name,
        skill_level,
        ranking_points
      ),
      player2:users!matches_player2_id_fkey (
        id,
        display_name,
        skill_level,
        ranking_points
      )
    ''');
    
    for (int i = 0; i < matchesWithDetails.length; i++) {
      final match = matchesWithDetails[i];
      final tournament = match['tournaments'];
      final player1 = match['player1'];
      final player2 = match['player2'];
      
      print('🥇 MATCH ${i + 1}:');
      print('   🏆 Tournament: ${tournament['title']}');
      print('   📅 Tournament Date: ${tournament['start_date']}');
      print('   🎯 Tournament Status: ${tournament['status']}');
      print('');
      print('   👤 Player 1: ${player1['display_name']}');
      print('      - Skill Level: ${player1['skill_level']}');
      print('      - Ranking Points: ${player1['ranking_points']}');
      print('');
      print('   👤 Player 2: ${player2['display_name']}');
      print('      - Skill Level: ${player2['skill_level']}');
      print('      - Ranking Points: ${player2['ranking_points']}');
      print('');
      print('   🏓 Match Info:');
      print('      - Round: ${match['round_number']}, Match: ${match['match_number']}');
      print('      - Score: ${match['player1_score']} - ${match['player2_score']}');
      print('      - Status: ${match['status']}');
      print('      - Scheduled: ${match['scheduled_time']}');
      
      if (match['winner_id'] != null) {
        final winnerId = match['winner_id'];
        final winnerName = winnerId == player1['id'] 
            ? player1['display_name'] 
            : player2['display_name'];
        print('      - Winner: $winnerName');
      } else {
        print('      - Winner: Chưa có');
      }
      
      print('   ─────────────────────────────────────');
    }
    
    // 2. Kiểm tra tournament participants
    print('\n👥 TOURNAMENT PARTICIPANTS:');
    final participants = await supabase.from('tournament_participants').select('''
      tournament_id,
      payment_status,
      registered_at,
      users!inner (
        id,
        display_name,
        skill_level
      )
    ''');
    
    for (final participant in participants) {
      final user = participant['users'];
      print('   - ${user['display_name']} (${user['skill_level']}) - ${participant['payment_status']}');
    }
    
    // 3. Suggestions for match management
    print('\n💡 MATCH MANAGEMENT SUGGESTIONS:');
    print('   🔄 Start a match: UPDATE matches SET status = \'in_progress\', start_time = NOW() WHERE id = \'match_id\'');
    print('   🏁 Complete a match: UPDATE matches SET status = \'completed\', end_time = NOW(), winner_id = \'player_id\', player1_score = X, player2_score = Y WHERE id = \'match_id\'');
    print('   📊 Get match statistics: SELECT status, COUNT(*) FROM matches GROUP BY status;');
    
  } catch (e) {
    print('❌ ERROR: $e');
    print('Details: ${e.toString()}');
    exit(1);
  }

  exit(0);
}