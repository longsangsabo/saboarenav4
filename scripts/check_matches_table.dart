import 'dart:io';
import 'package:supabase/supabase.dart';

Future<void> main() async {
  print('🏓 KIỂM TRA BẢNG MATCHES...\n');

  const supabaseUrl = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
  const anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ';

  try {
    final supabase = SupabaseClient(supabaseUrl, anonKey);
    
    // 1. Đếm tổng số matches
    print('📊 1. Tổng số matches:');
    final matchCount = await supabase.from('matches').select('*').count(CountOption.exact);
    print('   Có ${matchCount.count} matches trong database\n');
    
    if (matchCount.count > 0) {
      // 2. Lấy tất cả matches với thông tin chi tiết
      print('📋 2. Chi tiết các matches:');
      final matches = await supabase.from('matches').select('''
        id,
        tournament_id,
        player1_id,
        player2_id,
        winner_id,
        round_number,
        match_number,
        player1_score,
        player2_score,
        status,
        scheduled_time,
        start_time,
        end_time,
        notes,
        created_at
      ''').order('created_at', ascending: false);
      
      for (int i = 0; i < matches.length; i++) {
        final match = matches[i];
        print('   Match ${i + 1}:');
        print('     - ID: ${match['id']}');
        print('     - Tournament ID: ${match['tournament_id']}');
        print('     - Player1 ID: ${match['player1_id']}');
        print('     - Player2 ID: ${match['player2_id']}');
        print('     - Winner ID: ${match['winner_id'] ?? 'Chưa có'}');
        print('     - Round: ${match['round_number']}, Match: ${match['match_number']}');
        print('     - Score: ${match['player1_score']} - ${match['player2_score']}');
        print('     - Status: ${match['status']}');
        print('     - Scheduled: ${match['scheduled_time'] ?? 'Chưa lên lịch'}');
        print('     - Started: ${match['start_time'] ?? 'Chưa bắt đầu'}');
        print('     - Ended: ${match['end_time'] ?? 'Chưa kết thúc'}');
        print('     - Notes: ${match['notes'] ?? 'Không có'}');
        print('     - Created: ${match['created_at']}');
        print('');
      }
      
      // 3. Thống kê matches theo status
      print('📈 3. Thống kê theo trạng thái:');
      final statusStats = <String, int>{};
      for (final match in matches) {
        final status = match['status'] as String;
        statusStats[status] = (statusStats[status] ?? 0) + 1;
      }
      
      statusStats.forEach((status, count) {
        print('   - $status: $count matches');
      });
      
      // 4. Matches theo tournament
      print('\n🏆 4. Matches theo tournament:');
      final tournamentStats = <String, int>{};
      for (final match in matches) {
        final tournamentId = match['tournament_id'] as String?;
        if (tournamentId != null) {
          tournamentStats[tournamentId] = (tournamentStats[tournamentId] ?? 0) + 1;
        }
      }
      
      for (final entry in tournamentStats.entries) {
        print('   - Tournament ${entry.key}: ${entry.value} matches');
      }
      
    } else {
      print('❌ Không có matches nào trong database');
      
      // Gợi ý tạo sample matches
      print('\n💡 Gợi ý: Có thể tạo sample matches bằng cách chạy:');
      print('   INSERT INTO matches (tournament_id, player1_id, player2_id, round_number, match_number, status)');
      print('   VALUES (\'tournament_id_here\', \'player1_id\', \'player2_id\', 1, 1, \'pending\');');
    }
    
  } catch (e) {
    print('❌ ERROR: $e');
    exit(1);
  }

  exit(0);
}