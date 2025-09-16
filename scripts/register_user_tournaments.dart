import 'dart:io';
import 'package:supabase/supabase.dart';

Future<void> main() async {
  print('🏆 ĐĂNG KÝ longsang063@gmail.com VÀO TOURNAMENTS...\n');

  const supabaseUrl = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
  const serviceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo';

  try {
    final supabase = SupabaseClient(supabaseUrl, serviceKey);
    
    // 1. Lấy user longsang063@gmail.com
    print('🔍 1. TÌM USER:');
    final targetUser = await supabase
        .from('users')
        .select('id, display_name, email, skill_level')
        .eq('email', 'longsang063@gmail.com')
        .single();
    
    print('   ✅ User: ${targetUser['display_name']} (${targetUser['email']})');
    final userId = targetUser['id'];
    
    // 2. Lấy tất cả tournaments
    print('\n🏆 2. LẤY DANH SÁCH TOURNAMENTS:');
    final tournaments = await supabase
        .from('tournaments')
        .select('id, title, status, entry_fee, max_participants, current_participants');
    
    print('   ✅ Available tournaments:');
    for (var tournament in tournaments) {
      print('      - ${tournament['title']} (${tournament['status']})');
      print('        Entry: ${tournament['entry_fee']} VND, Participants: ${tournament['current_participants']}/${tournament['max_participants']}');
    }
    
    // 3. Kiểm tra đã đăng ký chưa
    print('\n📋 3. KIỂM TRA ĐĂNG KÝ HIỆN TẠI:');
    final existingParticipations = await supabase
        .from('tournament_participants')
        .select('tournament_id, payment_status, registered_at')
        .eq('user_id', userId);
    
    final registeredTournamentIds = existingParticipations.map((p) => p['tournament_id']).toSet();
    
    print('   📊 User đã đăng ký: ${existingParticipations.length} tournaments');
    for (var participation in existingParticipations) {
      print('      - Tournament: ${participation['tournament_id']}');
      print('        Payment: ${participation['payment_status']}');
      print('        Registered: ${participation['registered_at']}');
    }
    
    // 4. Đăng ký vào các tournaments chưa tham gia
    print('\n➕ 4. ĐĂNG KÝ VÀO TOURNAMENTS MỚI:');
    final participationsToCreate = <Map<String, dynamic>>[];
    
    for (var tournament in tournaments) {
      final tournamentId = tournament['id'];
      
      if (!registeredTournamentIds.contains(tournamentId)) {
        final participation = {
          'tournament_id': tournamentId,
          'user_id': userId,
          'payment_status': 'completed', // Set as paid for testing
          'registered_at': DateTime.now().toIso8601String(),
          'notes': 'Registered for testing data - longsang063@gmail.com'
        };
        
        participationsToCreate.add(participation);
        print('   📝 Preparing registration for: ${tournament['title']}');
      } else {
        print('   ⚠️  Already registered for: ${tournament['title']}');
      }
    }
    
    // 5. Insert tournament participants
    if (participationsToCreate.isNotEmpty) {
      print('\n💾 5. LƯU ĐĂNG KÝ VÀO DATABASE:');
      final insertedParticipations = await supabase
          .from('tournament_participants')
          .insert(participationsToCreate)
          .select();
      
      print('   ✅ Successfully registered for ${insertedParticipations.length} tournaments!');
      
      for (int i = 0; i < insertedParticipations.length; i++) {
        final participation = insertedParticipations[i];
        print('   📋 Registration ${i + 1}:');
        print('      - ID: ${participation['id']}');
        print('      - Tournament: ${participation['tournament_id']}');
        print('      - Payment: ${participation['payment_status']}');
        print('      - Registered: ${participation['registered_at']}');
      }
    } else {
      print('\n⚠️  User đã đăng ký tất cả tournaments có sẵn!');
    }
    
    // 6. Update tournament participant counts
    print('\n🔄 6. CẬP NHẬT SỐ LƯỢNG PARTICIPANTS:');
    for (var tournament in tournaments) {
      final participantCount = await supabase
          .from('tournament_participants')
          .select('id')
          .eq('tournament_id', tournament['id'])
          .count(CountOption.exact);
      
      await supabase
          .from('tournaments')
          .update({'current_participants': participantCount.count})
          .eq('id', tournament['id']);
      
      print('   📊 ${tournament['title']}: ${participantCount.count} participants');
    }
    
    // 7. Lấy thông tin chi tiết sau khi đăng ký
    print('\n📊 7. THÔNG TIN CHI TIẾT SAU ĐĂNG KÝ:');
    final detailedParticipations = await supabase
        .from('tournament_participants')
        .select('''
          id, payment_status, registered_at, notes,
          tournaments (
            id, title, status, start_date, entry_fee, prize_pool,
            clubs (name, address)
          )
        ''')
        .eq('user_id', userId)
        .order('registered_at', ascending: false);
    
    print('   🏆 ${targetUser['display_name']} đã đăng ký ${detailedParticipations.length} tournaments:');
    
    for (int i = 0; i < detailedParticipations.length; i++) {
      final participation = detailedParticipations[i];
      final tournament = participation['tournaments'];
      final club = tournament['clubs'];
      
      print('\n   📋 Tournament ${i + 1}:');
      print('      - Name: ${tournament['title']}');
      print('      - Status: ${tournament['status']}');
      print('      - Start Date: ${tournament['start_date']}');
      print('      - Entry Fee: ${tournament['entry_fee']} VND');
      print('      - Prize Pool: ${tournament['prize_pool']} VND');
      print('      - Venue: ${club['name']} (${club['address']})');
      print('      - Payment Status: ${participation['payment_status']}');
      print('      - Registered: ${participation['registered_at']}');
    }
    
    // 8. Tổng kết
    print('\n🎯 8. TỔNG KẾT:');
    final totalMatches = await supabase
        .from('matches')
        .select('id')
        .or('player1_id.eq.$userId,player2_id.eq.$userId')
        .count(CountOption.exact);
    
    final totalTournaments = detailedParticipations.length;
    
    print('   ✅ User: ${targetUser['display_name']} (${targetUser['email']})');
    print('   ✅ Skill Level: ${targetUser['skill_level']}');
    print('   ✅ Registered Tournaments: $totalTournaments');
    print('   ✅ Total Matches: ${totalMatches.count}');
    print('   ✅ Ready for comprehensive testing!');
    
    print('\n🚀 ĐĂNG KÝ TOURNAMENTS HOÀN TẤT!');
    
  } catch (e) {
    print('❌ ERROR: $e');
    print('Details: ${e.toString()}');
    exit(1);
  }

  exit(0);
}