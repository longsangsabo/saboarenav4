import 'dart:io';
import 'dart:math';
import 'package:supabase/supabase.dart';

Future<void> main() async {
  print('🔍 KIỂM TRA SCHEMA & THÊM DATA THÀNH VIÊN...\n');

  const supabaseUrl = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
  const serviceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo';

  try {
    final supabase = SupabaseClient(supabaseUrl, serviceKey);
    print('✅ Kết nối Supabase thành công!\n');

    // 1. Kiểm tra schema của các bảng
    print('🔍 1. KIỂM TRA SCHEMA:');
    print('======================');
    
    // Kiểm tra bảng user_profiles
    try {
      final userSample = await supabase
          .from('user_profiles')
          .select()
          .limit(1);
      print('   ✅ user_profiles: ${userSample.length} records found');
    } catch (e) {
      print('   ❌ user_profiles: $e');
    }

    // Kiểm tra bảng club_members  
    try {
      final memberSample = await supabase
          .from('club_members')
          .select()
          .limit(1);
      print('   ✅ club_members: ${memberSample.length} records found');
    } catch (e) {
      print('   ❌ club_members: $e');
    }

    // Kiểm tra bảng tournaments
    try {
      final tournamentSample = await supabase
          .from('tournaments')
          .select()
          .limit(1);
      print('   ✅ tournaments: ${tournamentSample.length} records found');
    } catch (e) {
      print('   ❌ tournaments: $e');
    }

    // Kiểm tra bảng achievements
    try {
      final achievementSample = await supabase
          .from('achievements')
          .select()
          .limit(1);
      print('   ✅ achievements: ${achievementSample.length} records found');
    } catch (e) {
      print('   ❌ achievements: $e');
    }
    
    print('');

    // 2. Lấy danh sách clubs
    final clubs = await supabase
        .from('clubs')
        .select('id, name');
    
    print('📋 2. CLUBS HIỆN TẠI:');
    print('======================');
    for (final club in clubs) {
      print('   🏢 ${club['name']} (ID: ${club['id']})');
    }
    print('');

    // 3. Tạo thành viên với UUID thực
    print('👥 3. TẠO THÀNH VIÊN:');
    print('=====================');
    
    final memberTemplates = [
      // Golden Billiards Club Members
      {
        'full_name': 'Nguyễn Văn Minh',
        'avatar_url': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200&h=200&fit=crop&crop=face',
        'bio': 'Cựu vô địch giải bi-a quốc gia, chuyên gia English 8-ball',
        'location': 'Quận 1, TP.HCM',
      },
      {
        'full_name': 'Trần Thị Hương', 
        'avatar_url': 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=200&h=200&fit=crop&crop=face',
        'bio': 'Nữ tuyển thủ xuất sắc, thành tích ấn tượng ở giải 9-ball',
        'location': 'Quận 1, TP.HCM',
      },
      {
        'full_name': 'Lê Hoàng Nam',
        'avatar_url': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=200&fit=crop&crop=face', 
        'bio': 'Đam mê bi-a carom, kỹ thuật tấn công sắc bén',
        'location': 'Quận 1, TP.HCM',
      },
      {
        'full_name': 'Phạm Minh Tuấn',
        'avatar_url': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&h=200&fit=crop&crop=face',
        'bio': 'Chuyên gia snooker với lối chơi tính toán chính xác', 
        'location': 'Quận 1, TP.HCM',
      },
      
      // SABO Arena Central Members  
      {
        'full_name': 'Đặng Việt Anh',
        'avatar_url': 'https://images.unsplash.com/photo-1519345182560-3f2917c472ef?w=200&h=200&fit=crop&crop=face',
        'bio': 'Tổ chức và tham gia nhiều giải đấu chuyên nghiệp',
        'location': 'Quận 3, TP.HCM',
      },
      {
        'full_name': 'Võ Thị Mai',
        'avatar_url': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200&h=200&fit=crop&crop=face',
        'bio': 'Nữ vận động viên speed pool hàng đầu miền Nam',
        'location': 'Quận 3, TP.HCM',
      },
      {
        'full_name': 'Bùi Thanh Long',
        'avatar_url': 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=200&h=200&fit=crop&crop=face',
        'bio': 'Tài năng trẻ với phong cách chơi năng động',
        'location': 'Quận 3, TP.HCM',
      },
      {
        'full_name': 'Hoàng Thị Lan',
        'avatar_url': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200&h=200&fit=crop&crop=face',
        'bio': 'Nghệ sĩ bi-a với những pha trick shot ngoạn mục',
        'location': 'Quận 3, TP.HCM',
      },
    ];

    final random = Random();
    int memberCount = 0;
    List<String> createdUserIds = [];

    for (int i = 0; i < memberTemplates.length; i++) {
      final member = memberTemplates[i];
      
      try {
        // Tạo UUID thủ công
        final userId = 'user_${DateTime.now().millisecondsSinceEpoch}_$i';
        
        await supabase
            .from('user_profiles')
            .insert({
              'id': userId,
              'full_name': member['full_name'],
              'avatar_url': member['avatar_url'],
              'bio': member['bio'], 
              'location': member['location'],
            });
        
        createdUserIds.add(userId);
        print('   ✅ ${member['full_name']}');
        memberCount++;
        
      } catch (e) {
        print('   ❌ ${member['full_name']}: $e');
      }
    }
    
    print('   📊 Tạo thành công: $memberCount/${memberTemplates.length} thành viên\n');

    // 4. Thêm vào club_members
    print('🏢 4. THÊM VÀO CLUBS:');
    print('=====================');
    
    int clubMemberCount = 0;
    
    for (int i = 0; i < clubs.length; i++) {
      final club = clubs[i];
      final clubId = club['id'];
      final clubName = club['name'];
      
      print('   🏢 $clubName:');
      
      // Mỗi club có 4 thành viên
      final startIndex = i * 4;
      for (int j = 0; j < 4 && (startIndex + j) < createdUserIds.length; j++) {
        final userId = createdUserIds[startIndex + j];
        final memberName = memberTemplates[startIndex + j]['full_name'];
        
        try {
          await supabase
              .from('club_members')
              .insert({
                'club_id': clubId,
                'user_id': userId,
                'role': j == 0 ? 'owner' : (j == 1 ? 'admin' : 'member'),
              });
          
          print('      ✅ $memberName - ${j == 0 ? 'Owner' : (j == 1 ? 'Admin' : 'Member')}');
          clubMemberCount++;
          
        } catch (e) {
          print('      ❌ $memberName: $e');
        }
      }
      print('');
    }

    // 5. Tạo tournaments đơn giản  
    print('🏆 5. TẠO TOURNAMENTS:');
    print('======================');
    
    final tournamentTemplates = [
      {
        'name': 'Golden Cup 2025',
        'description': 'Giải bi-a English 8-ball chuyên nghiệp hàng năm với giải thưởng hấp dẫn',
        'image_url': 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=600&h=400&fit=crop',
        'max_participants': 32,
        'entry_fee': 500000,
        'prize_pool': 15000000,
        'start_date': '2025-10-15T09:00:00Z',
        'registration_deadline': '2025-10-10T23:59:59Z',
        'status': 'upcoming'
      },
      {
        'name': 'SABO Pro Series',
        'description': 'Giải đấu chuyên nghiệp với format thi đấu hiện đại và livestream trực tiếp', 
        'image_url': 'https://images.unsplash.com/photo-1574631806042-182f10c4a017?w=600&h=400&fit=crop',
        'max_participants': 64,
        'entry_fee': 1000000,
        'prize_pool': 50000000,
        'start_date': '2025-12-01T10:00:00Z',
        'registration_deadline': '2025-11-25T23:59:59Z',
        'status': 'upcoming'
      }
    ];

    int tournamentCount = 0;
    
    for (int i = 0; i < clubs.length && i < tournamentTemplates.length; i++) {
      final club = clubs[i];
      final tournament = tournamentTemplates[i];
      
      try {
        await supabase
            .from('tournaments')
            .insert({
              'club_id': club['id'],
              'name': tournament['name'],
              'description': tournament['description'],
              'image_url': tournament['image_url'],
              'max_participants': tournament['max_participants'],
              'entry_fee': tournament['entry_fee'],
              'prize_pool': tournament['prize_pool'], 
              'start_date': tournament['start_date'],
              'registration_deadline': tournament['registration_deadline'],
              'status': tournament['status'],
            });
        
        print('   ✅ ${tournament['name']} @ ${club['name']}');
        print('      💰 Prize: ${(tournament['prize_pool'] as int) / 1000000}M VND');
        tournamentCount++;
        
      } catch (e) {
        print('   ❌ ${tournament['name']}: $e');
      }
    }

    // 6. Tổng kết
    print('\n📊 6. TỔNG KẾT:');
    print('================');
    print('   👥 Thành viên được tạo: $memberCount');
    print('   🏢 Club members được thêm: $clubMemberCount');
    print('   🏆 Tournaments được tạo: $tournamentCount');
    
    // Kiểm tra dữ liệu cuối cùng
    final finalCheck = await supabase
        .from('clubs')
        .select('id, name');
    
    for (final club in finalCheck) {
      final members = await supabase
          .from('club_members')
          .select('user_id')
          .eq('club_id', club['id']);
          
      final tournaments = await supabase
          .from('tournaments') 
          .select('name')
          .eq('club_id', club['id']);
      
      print('');
      print('   🏢 ${club['name']}:');
      print('      👥 Members: ${members.length}');
      print('      🏆 Tournaments: ${tournaments.length}');
    }

    print('\n🎉 HOÀN THÀNH THÊM DATA!');
    print('   Database đã có thêm thành viên và giải đấu với hình ảnh đa dạng');

  } catch (e) {
    print('❌ LỖI: $e');
    exit(1);
  }

  exit(0);
}