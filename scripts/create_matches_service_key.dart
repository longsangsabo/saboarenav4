import 'dart:io';
import 'package:supabase/supabase.dart';

Future<void> main() async {
  print('🚀 TẠO MATCHES VỚI SERVICE ROLE KEY...\n');

  const supabaseUrl = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
  const serviceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo';

  try {
    final supabase = SupabaseClient(supabaseUrl, serviceKey);
    
    // 1. Kiểm tra service key connection
    print('🔐 1. KIỂM TRA SERVICE KEY CONNECTION:');
    final authUsersCount = await supabase.rpc('get_auth_users_count');
    print('   ✅ Service key working! Auth users: $authUsersCount');
    
    // 2. Tìm user longsang063@gmail.com
    print('\n🔍 2. TÌM USER longsang063@gmail.com:');
    final targetUser = await supabase
        .from('users')
        .select('*')
        .eq('email', 'longsang063@gmail.com')
        .maybeSingle();
    
    if (targetUser == null) {
      print('❌ User longsang063@gmail.com không tồn tại!');
      
      // Hiển thị users hiện có
      final allUsers = await supabase.from('users').select('id, email, display_name');
      print('\n📋 Users hiện có:');
      for (var user in allUsers) {
        print('   - ${user['display_name']} (${user['email']})');
      }
      exit(1);
    }
    
    print('   ✅ User found: ${targetUser['display_name']} (${targetUser['email']})');
    final targetUserId = targetUser['id'];
    
    // 3. Lấy opponents
    print('\n👥 3. LẤY DANH SÁCH OPPONENTS:');
    final opponents = await supabase
        .from('users')
        .select('id, display_name, email')
        .neq('id', targetUserId)
        .limit(3);
    
    print('   ✅ Found ${opponents.length} opponents:');
    for (var opponent in opponents) {
      print('      - ${opponent['display_name']} (${opponent['email']})');
    }
    
    // 4. Lấy tournaments
    print('\n🏆 4. LẤY TOURNAMENTS:');
    final tournaments = await supabase
        .from('tournaments')
        .select('id, title, status')
        .limit(2);
    
    print('   ✅ Tournaments:');
    for (var tournament in tournaments) {
      print('      - ${tournament['title']} (${tournament['status']})');
    }
    
    // 5. Tạo matches với SERVICE ROLE KEY
    print('\n🏓 5. TẠO MATCHES:');
    final matchesToCreate = <Map<String, dynamic>>[];
    
    for (int i = 0; i < opponents.length; i++) {
      final opponent = opponents[i];
      final tournament = tournaments[i % tournaments.length];
      
      final match = {
        'tournament_id': tournament['id'],
        'player1_id': targetUserId,
        'player2_id': opponent['id'],
        'round_number': 1,
        'match_number': 10 + i, // Start from match 10
        'player1_score': 0,
        'player2_score': 0,
        'status': 'pending',
        'scheduled_time': DateTime.now().add(Duration(days: i + 1)).toIso8601String(),
        'notes': 'Match created for longsang063@gmail.com vs ${opponent['display_name']}'
      };
      
      matchesToCreate.add(match);
      print('   📋 Preparing Match ${i + 1}: ${targetUser['display_name']} vs ${opponent['display_name']}');
    }
    
    // 6. INSERT với service key (bypass RLS)
    print('\n💾 6. INSERTING TO DATABASE:');
    final insertedMatches = await supabase
        .from('matches')
        .insert(matchesToCreate)
        .select();
    
    print('   ✅ Successfully created ${insertedMatches.length} matches!');
    
    // 7. Verify results
    print('\n🎉 7. MATCHES CREATED:');
    for (int i = 0; i < insertedMatches.length; i++) {
      final match = insertedMatches[i];
      print('   ✅ Match ${i + 1}:');
      print('      - ID: ${match['id']}');
      print('      - Match Number: ${match['match_number']}');
      print('      - Status: ${match['status']}');
      print('      - Scheduled: ${match['scheduled_time']}');
      print('      - Notes: ${match['notes']}');
    }
    
    // 8. Get detailed match info with JOINs
    print('\n📊 8. CHI TIẾT MATCHES VỪA TẠO:');
    final detailedMatches = await supabase.from('matches').select('''
      id, match_number, status, scheduled_time,
      tournaments (title),
      player1:users!matches_player1_id_fkey (display_name, email),
      player2:users!matches_player2_id_fkey (display_name, email)
    ''').eq('player1_id', targetUserId).order('created_at', ascending: false).limit(3);
    
    for (int i = 0; i < detailedMatches.length; i++) {
      final match = detailedMatches[i];
      print('   🏓 Match ${i + 1}:');
      print('      - Tournament: ${match['tournaments']['title']}');
      print('      - Player 1: ${match['player1']['display_name']} (${match['player1']['email']})');
      print('      - Player 2: ${match['player2']['display_name']} (${match['player2']['email']})');
      print('      - Status: ${match['status']}');
      print('      - Scheduled: ${match['scheduled_time']}');
    }
    
    // 9. Final count
    final totalMatchesForUser = await supabase.from('matches').select('*').or('player1_id.eq.$targetUserId,player2_id.eq.$targetUserId').count(CountOption.exact);
    
    print('\n📈 TỔNG KẾT:');
    print('   ✅ User: ${targetUser['display_name']} (${targetUser['email']})');
    print('   ✅ Total matches for this user: ${totalMatchesForUser.count}');
    print('   ✅ Matches just created: ${insertedMatches.length}');
    
    print('\n🎯 TẠO MATCHES THÀNH CÔNG!');
    
  } catch (e) {
    print('❌ ERROR: $e');
    print('Details: ${e.toString()}');
    exit(1);
  }

  exit(0);
}