import 'dart:io';
import 'dart:math';
import 'package:supabase/supabase.dart';

Future<void> main() async {
  print('👥🏆 THÊM THÀNH VIÊN & GIẢI ĐẤU CHO CLUBS...\n');

  const supabaseUrl = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
  const serviceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo';

  try {
    final supabase = SupabaseClient(supabaseUrl, serviceKey);
    print('✅ Kết nối Supabase thành công!\n');

    // 1. Lấy danh sách clubs
    print('📋 1. LẤY DANH SÁCH CLUBS:');
    print('===========================');
    
    final clubs = await supabase
        .from('clubs')
        .select('id, name')
        .order('name');
    
    print('   Tìm thấy ${clubs.length} clubs\n');
    
    // 2. Tạo dữ liệu thành viên đa dạng
    print('👥 2. TẠO THÀNH VIÊN ĐA DẠNG:');
    print('==============================');
    
    final memberTemplates = [
      // Golden Billiards Club Members (Professional Style)
      {
        'name': 'Nguyễn Văn Minh',
        'avatar': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200&h=200&fit=crop&crop=face',
        'skill_level': 'Pro',
        'years_experience': 8,
        'specialty': 'English 8-ball',
        'bio': 'Cựu vô địch giải bi-a quốc gia, chuyên gia English 8-ball'
      },
      {
        'name': 'Trần Thị Hương',
        'avatar': 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=200&h=200&fit=crop&crop=face',
        'skill_level': 'Advanced',
        'years_experience': 5,
        'specialty': '9-ball',
        'bio': 'Nữ tuyển thủ xuất sắc, thành tích ấn tượng ở giải 9-ball'
      },
      {
        'name': 'Lê Hoàng Nam',
        'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=200&fit=crop&crop=face',
        'skill_level': 'Intermediate',
        'years_experience': 3,
        'specialty': 'Carom',
        'bio': 'Đam mê bi-a carom, kỹ thuật tấn công sắc bén'
      },
      {
        'name': 'Phạm Minh Tuấn',
        'avatar': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&h=200&fit=crop&crop=face',
        'skill_level': 'Advanced',
        'years_experience': 6,
        'specialty': 'Snooker',
        'bio': 'Chuyên gia snooker với lối chơi tính toán chính xác'
      },
      
      // SABO Arena Central Members (Modern Style)
      {
        'name': 'Đặng Việt Anh',
        'avatar': 'https://images.unsplash.com/photo-1519345182560-3f2917c472ef?w=200&h=200&fit=crop&crop=face',
        'skill_level': 'Pro',
        'years_experience': 10,
        'specialty': 'Tournament',
        'bio': 'Tổ chức và tham gia nhiều giải đấu chuyên nghiệp'
      },
      {
        'name': 'Võ Thị Mai',
        'avatar': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200&h=200&fit=crop&crop=face',
        'skill_level': 'Advanced',
        'years_experience': 4,
        'specialty': 'Speed Pool',
        'bio': 'Nữ vận động viên speed pool hàng đầu miền Nam'
      },
      {
        'name': 'Bùi Thanh Long',
        'avatar': 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=200&h=200&fit=crop&crop=face',
        'skill_level': 'Intermediate',
        'years_experience': 2,
        'specialty': '8-ball',
        'bio': 'Tài năng trẻ với phong cách chơi năng động'
      },
      {
        'name': 'Hoàng Thị Lan',
        'avatar': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200&h=200&fit=crop&crop=face',
        'skill_level': 'Advanced',
        'years_experience': 7,
        'specialty': 'Trick Shot',
        'bio': 'Nghệ sĩ bi-a với những pha trick shot ngoạn mục'
      },
    ];

    // 3. Thêm thành viên vào clubs
    int memberCount = 0;
    final random = Random();
    
    for (int i = 0; i < clubs.length; i++) {
      final club = clubs[i];
      final clubId = club['id'];
      final clubName = club['name'];
      
      print('   🏢 $clubName:');
      
      // Mỗi club có 4 thành viên
      final startIndex = i * 4;
      for (int j = 0; j < 4; j++) {
        final member = memberTemplates[startIndex + j];
        
        try {
          // Tạo user profile trước
          final userId = supabase.rpc('generate_uuid').single;
          
          await supabase
              .from('user_profiles')
              .insert({
                'id': userId,
                'full_name': member['name'],
                'avatar_url': member['avatar'],
                'bio': member['bio'],
                'skill_level': member['skill_level'],
                'years_experience': member['years_experience'],
                'specialty': member['specialty'],
                'location': clubName.contains('Golden') ? 'Quận 1, TP.HCM' : 'Quận 3, TP.HCM',
                'phone': '+84 ${90 + random.nextInt(9)}${random.nextInt(10)}${random.nextInt(10)}${random.nextInt(10)}${random.nextInt(10)}${random.nextInt(10)}${random.nextInt(10)}${random.nextInt(10)}',
                'rating': 4.0 + random.nextDouble() * 1.0,
                'total_matches': 50 + random.nextInt(200),
                'wins': 30 + random.nextInt(100),
                'created_at': DateTime.now().toIso8601String(),
              });
          
          // Thêm vào club_members
          await supabase
              .from('club_members')
              .insert({
                'club_id': clubId,
                'user_id': userId,
                'role': j == 0 ? 'owner' : (j == 1 ? 'admin' : 'member'),
                'joined_at': DateTime.now().subtract(Duration(days: random.nextInt(365))).toIso8601String(),
              });
          
          print('      ✅ ${member['name']} - ${member['skill_level']} (${member['specialty']})');
          memberCount++;
          
        } catch (e) {
          print('      ❌ ${member['name']}: Lỗi - $e');
        }
      }
      print('');
    }

    // 4. Tạo tournaments đa dạng
    print('🏆 3. TẠO GIẢI ĐẤU ĐA DẠNG:');
    print('============================');
    
    final tournamentTemplates = [
      // Golden Billiards Club Tournaments
      {
        'name': 'Golden Cup 2025',
        'description': 'Giải bi-a English 8-ball chuyên nghiệp hàng năm với giải thưởng hấp dẫn',
        'image_url': 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=600&h=400&fit=crop',
        'game_type': 'English 8-ball',
        'max_participants': 32,
        'entry_fee': 500000,
        'prize_pool': 15000000,
        'start_date': '2025-10-15',
        'registration_deadline': '2025-10-10',
        'status': 'upcoming'
      },
      {
        'name': 'Ladies Night Championship',
        'description': 'Giải đấu dành riêng cho nữ vận động viên bi-a với nhiều hoạt động hấp dẫn',
        'image_url': 'https://images.unsplash.com/photo-1594736797933-d0601ba2fe65?w=600&h=400&fit=crop',
        'game_type': '9-ball',
        'max_participants': 16,
        'entry_fee': 300000,
        'prize_pool': 8000000,
        'start_date': '2025-11-20',
        'registration_deadline': '2025-11-15',
        'status': 'upcoming'
      },
      
      // SABO Arena Central Tournaments
      {
        'name': 'SABO Pro Series',
        'description': 'Giải đấu chuyên nghiệp với format thi đấu hiện đại và livestream trực tiếp',
        'image_url': 'https://images.unsplash.com/photo-1574631806042-182f10c4a017?w=600&h=400&fit=crop',
        'game_type': 'Tournament Mix',
        'max_participants': 64,
        'entry_fee': 1000000,
        'prize_pool': 50000000,
        'start_date': '2025-12-01',
        'registration_deadline': '2025-11-25',
        'status': 'upcoming'
      },
      {
        'name': 'Speed Pool Challenge',
        'description': 'Thử thách tốc độ với format speed pool đầy kịch tính và hứng khởi',
        'image_url': 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=600&h=400&fit=crop',
        'game_type': 'Speed Pool',
        'max_participants': 24,
        'entry_fee': 200000,
        'prize_pool': 5000000,
        'start_date': '2025-09-30',
        'registration_deadline': '2025-09-25',
        'status': 'registration_open'
      }
    ];

    int tournamentCount = 0;
    
    for (int i = 0; i < clubs.length; i++) {
      final club = clubs[i];
      final clubId = club['id'];
      final clubName = club['name'];
      
      print('   🏢 $clubName:');
      
      // Mỗi club có 2 tournament
      final startIndex = i * 2;
      for (int j = 0; j < 2; j++) {
        final tournament = tournamentTemplates[startIndex + j];
        
        try {
          await supabase
              .from('tournaments')
              .insert({
                'club_id': clubId,
                'name': tournament['name'],
                'description': tournament['description'],
                'image_url': tournament['image_url'],
                'game_type': tournament['game_type'],
                'max_participants': tournament['max_participants'],
                'entry_fee': tournament['entry_fee'],
                'prize_pool': tournament['prize_pool'],
                'start_date': tournament['start_date'],
                'registration_deadline': tournament['registration_deadline'],
                'status': tournament['status'],
                'created_at': DateTime.now().toIso8601String(),
              });
          
          print('      ✅ ${tournament['name']} - ${tournament['game_type']}');
          print('         💰 Prize: ${(tournament['prize_pool'] as int) / 1000000}M VND');
          tournamentCount++;
          
        } catch (e) {
          print('      ❌ ${tournament['name']}: Lỗi - $e');
        }
      }
      print('');
    }

    // 5. Thêm achievements đa dạng
    print('🏅 4. TẠO ACHIEVEMENTS:');
    print('========================');
    
    final achievementTemplates = [
      {
        'name': 'First Win',
        'description': 'Giành chiến thắng đầu tiên',
        'icon_url': 'https://images.unsplash.com/photo-1591154669695-5f2a8d20c089?w=100&h=100&fit=crop',
        'category': 'milestone',
        'points': 100
      },
      {
        'name': 'Tournament Champion',
        'description': 'Vô địch một giải đấu',
        'icon_url': 'https://images.unsplash.com/photo-1588702547919-26089e690ecc?w=100&h=100&fit=crop',
        'category': 'tournament',
        'points': 500
      },
      {
        'name': 'Perfect Game',
        'description': 'Thực hiện pha bóng hoàn hảo',
        'icon_url': 'https://images.unsplash.com/photo-1594736797933-d0601ba2fe65?w=100&h=100&fit=crop',
        'category': 'skill',
        'points': 200
      },
      {
        'name': 'Club MVP',
        'description': 'Thành viên xuất sắc nhất club',
        'icon_url': 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=100&h=100&fit=crop',
        'category': 'social',
        'points': 300
      },
    ];

    int achievementCount = 0;
    for (final achievement in achievementTemplates) {
      try {
        await supabase
            .from('achievements')
            .insert({
              'name': achievement['name'],
              'description': achievement['description'],
              'icon_url': achievement['icon_url'],
              'category': achievement['category'],
              'points': achievement['points'],
              'created_at': DateTime.now().toIso8601String(),
            });
        
        print('   ✅ ${achievement['name']} - ${achievement['points']} points');
        achievementCount++;
        
      } catch (e) {
        print('   ❌ ${achievement['name']}: Lỗi - $e');
      }
    }

    // 6. Kiểm tra kết quả cuối cùng
    print('\n🔍 5. KIỂM TRA KẾT QUẢ:');
    print('========================');
    
    final finalClubs = await supabase
        .from('clubs')
        .select('id, name, (club_members(count))')
        .order('name');
    
    final finalTournaments = await supabase
        .from('tournaments')
        .select('name, club_id, game_type, status')
        .order('name');
    
    final finalMembers = await supabase
        .from('user_profiles')
        .select('full_name, skill_level, specialty')
        .order('full_name');

    print('   📊 TỔNG KẾT DATA:');
    print('   👥 Thành viên: $memberCount users');
    print('   🏆 Giải đấu: $tournamentCount tournaments');  
    print('   🏅 Achievements: $achievementCount achievements');
    print('');
    
    for (final club in finalClubs) {
      print('   🏢 ${club['name']}:');
      final clubTournaments = finalTournaments.where((t) => t['club_id'] == club['id']).toList();
      print('      👥 Members: ${club['club_members'][0]['count'] ?? 0}');
      print('      🏆 Tournaments: ${clubTournaments.length}');
      for (final tournament in clubTournaments) {
        print('         • ${tournament['name']} (${tournament['game_type']}) - ${tournament['status']}');
      }
      print('');
    }

    print('🎉 HOÀN TẤT THÊM DATA THÀNH VIÊN & GIẢI ĐẤU!');
    print('   Clubs giờ đã có đầy đủ members và tournaments với hình ảnh đa dạng');
    print('   Tab "đối thủ" sẽ có nhiều người chơi để match và tham gia giải đấu!');

  } catch (e) {
    print('❌ LỖI: $e');
    exit(1);
  }

  exit(0);
}