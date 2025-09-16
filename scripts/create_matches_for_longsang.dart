import 'dart:io';
import 'package:supabase/supabase.dart';

Future<void> main() async {
  print('🎯 TẠO MATCHES CHO USER longsang063@gmail.com...\n');

  const supabaseUrl = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
  const anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ';

  try {
    final supabase = SupabaseClient(supabaseUrl, anonKey);
    
    // 1. Tìm user longsang063@gmail.com
    print('🔍 1. TÌM USER longsang063@gmail.com:');
    final targetUser = await supabase
        .from('users')
        .select('*')
        .eq('email', 'longsang063@gmail.com')
        .maybeSingle();
    
    if (targetUser == null) {
      print('❌ User longsang063@gmail.com không tồn tại trong database!');
      print('💡 Cần tạo user này trước khi tạo matches');
      
      // Hiển thị các users hiện có
      final existingUsers = await supabase.from('users').select('id, email, display_name').limit(10);
      print('\n📋 Users hiện có:');
      for (var user in existingUsers) {
        print('   - ${user['display_name']} (${user['email']})');
      }
      exit(1);
    }
    
    print('✅ Tìm thấy user: ${targetUser['display_name']} (${targetUser['email']})');
    print('   - Skill Level: ${targetUser['skill_level']}');
    print('   - Ranking Points: ${targetUser['ranking_points']}');
    
    // 2. Lấy danh sách opponents (users khác)
    print('\n👥 2. TÌM OPPONENTS:');
    final opponents = await supabase
        .from('users')
        .select('id, display_name, email, skill_level')
        .neq('id', targetUser['id'])
        .limit(5);
    
    print('✅ Tìm thấy ${opponents.length} potential opponents:');
    for (var opponent in opponents) {
      print('   - ${opponent['display_name']} (${opponent['skill_level']})');
    }
    
    // 3. Lấy tournaments có sẵn
    print('\n🏆 3. TÌM TOURNAMENTS:');
    final tournaments = await supabase
        .from('tournaments')
        .select('id, title, status')
        .limit(3);
    
    print('✅ Tournaments có sẵn:');
    for (var tournament in tournaments) {
      print('   - ${tournament['title']} (${tournament['status']})');
    }
    
    if (tournaments.isEmpty) {
      print('❌ Không có tournaments để tạo matches!');
      exit(1);
    }
    
    // 4. Tạo matches
    print('\n🏓 4. TẠO MATCHES:');
    final matchesToCreate = <Map<String, dynamic>>[];
    
    for (int i = 0; i < opponents.length && i < 3; i++) {
      final opponent = opponents[i];
      final tournament = tournaments[i % tournaments.length];
      
      final match = {
        'tournament_id': tournament['id'],
        'player1_id': targetUser['id'],
        'player2_id': opponent['id'],
        'round_number': 1,
        'match_number': i + 2, // Bắt đầu từ match 2 vì đã có match 1
        'player1_score': 0,
        'player2_score': 0,
        'status': 'pending',
        'scheduled_time': DateTime.now().add(Duration(days: i + 1)).toIso8601String(),
        'notes': 'Match created for longsang063@gmail.com'
      };
      
      matchesToCreate.add(match);
      
      print('   📋 Match ${i + 1}:');
      print('      - Tournament: ${tournament['title']}');
      print('      - ${targetUser['display_name']} vs ${opponent['display_name']}');
      print('      - Scheduled: ${match['scheduled_time']}');
    }
    
    // 5. Insert matches vào database
    print('\n💾 5. LƯU MATCHES VÀO DATABASE:');
    final insertedMatches = await supabase
        .from('matches')
        .insert(matchesToCreate)
        .select();
    
    print('✅ Đã tạo thành công ${insertedMatches.length} matches!');
    
    // 6. Hiển thị kết quả
    print('\n🎉 6. KẾT QUẢ:');
    for (int i = 0; i < insertedMatches.length; i++) {
      final match = insertedMatches[i];
      print('   ✅ Match ${i + 1} created:');
      print('      - ID: ${match['id']}');
      print('      - Status: ${match['status']}');
      print('      - Round: ${match['round_number']}, Match: ${match['match_number']}');
    }
    
    // 7. Verify bằng cách đếm total matches
    final totalMatches = await supabase.from('matches').select('*').count(CountOption.exact);
    print('\n📊 TỔNG KẾT:');
    print('   - Tổng matches trong database: ${totalMatches.count}');
    print('   - Matches mới tạo: ${insertedMatches.length}');
    print('   - User: ${targetUser['display_name']} (${targetUser['email']})');
    
    print('\n🚀 TẠO MATCHES HOÀN TẤT!');
    
  } catch (e) {
    print('❌ ERROR: $e');
    print('Details: ${e.toString()}');
    exit(1);
  }

  exit(0);
}