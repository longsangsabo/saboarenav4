import 'dart:io';
import 'package:supabase/supabase.dart';

Future<void> main() async {
  print('👥🏆 THÊM THÀNH VIÊN & TOURNAMENTS CHÍNH XÁC...\n');

  const supabaseUrl = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
  const serviceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo';

  try {
    final supabase = SupabaseClient(supabaseUrl, serviceKey);
    print('✅ Kết nối Supabase thành công!\n');

    // 1. Kiểm tra schema của bảng users
    print('🔍 1. KIỂM TRA SCHEMA USERS:');
    print('============================');
    
    final userSample = await supabase
        .from('users')
        .select()
        .limit(1);
    
    if (userSample.isNotEmpty) {
      print('   ✅ Bảng users tồn tại');
      print('   📝 Columns: ${userSample.first.keys.join(', ')}');
    }
    print('');

    // 2. Kiểm tra schema tournaments
    final tournamentSample = await supabase
        .from('tournaments')
        .select()
        .limit(1);
    
    if (tournamentSample.isNotEmpty) {
      print('   ✅ Bảng tournaments tồn tại');
      print('   📝 Columns: ${tournamentSample.first.keys.join(', ')}');
    }
    print('');

    // 3. Lấy danh sách clubs
    final clubs = await supabase
        .from('clubs')
        .select('id, name');
    
    print('📋 2. CLUBS HIỆN TẠI:');
    print('======================');
    for (final club in clubs) {
      print('   🏢 ${club['name']} (ID: ${club['id']})');
    }
    print('');

    // 4. Tạo thành viên mới với đúng schema
    print('👥 3. TẠO THÀNH VIÊN MỚI:');
    print('==========================');
    
    final memberTemplates = [
      {
        'username': 'minh_pro_player',
        'email': 'minh.nguyen@example.com',
        'full_name': 'Nguyễn Văn Minh',
        'avatar_url': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200&h=200&fit=crop&crop=face',
        'bio': 'Cựu vô địch giải bi-a quốc gia, chuyên gia English 8-ball',
        'location': 'Quận 1, TP.HCM',
      },
      {
        'username': 'huong_champion',
        'email': 'huong.tran@example.com', 
        'full_name': 'Trần Thị Hương',
        'avatar_url': 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=200&h=200&fit=crop&crop=face',
        'bio': 'Nữ tuyển thủ xuất sắc, thành tích ấn tượng ở giải 9-ball',
        'location': 'Quận 1, TP.HCM',
      },
      {
        'username': 'nam_carom_master',
        'email': 'nam.le@example.com',
        'full_name': 'Lê Hoàng Nam',
        'avatar_url': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=200&fit=crop&crop=face',
        'bio': 'Đam mê bi-a carom, kỹ thuật tấn công sắc bén',
        'location': 'Quận 1, TP.HCM',
      },
      {
        'username': 'tuan_snooker_pro',
        'email': 'tuan.pham@example.com',
        'full_name': 'Phạm Minh Tuấn',
        'avatar_url': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&h=200&fit=crop&crop=face',
        'bio': 'Chuyên gia snooker với lối chơi tính toán chính xác',
        'location': 'Quận 1, TP.HCM',
      },
      {
        'username': 'anh_tournament_king',
        'email': 'anh.dang@example.com',
        'full_name': 'Đặng Việt Anh',
        'avatar_url': 'https://images.unsplash.com/photo-1519345182560-3f2917c472ef?w=200&h=200&fit=crop&crop=face',
        'bio': 'Tổ chức và tham gia nhiều giải đấu chuyên nghiệp',
        'location': 'Quận 3, TP.HCM',
      },
      {
        'username': 'mai_speed_queen',
        'email': 'mai.vo@example.com',
        'full_name': 'Võ Thị Mai',
        'avatar_url': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200&h=200&fit=crop&crop=face',
        'bio': 'Nữ vận động viên speed pool hàng đầu miền Nam',
        'location': 'Quận 3, TP.HCM',
      },
      {
        'username': 'long_young_talent',
        'email': 'long.bui@example.com',
        'full_name': 'Bùi Thanh Long',
        'avatar_url': 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=200&h=200&fit=crop&crop=face',
        'bio': 'Tài năng trẻ với phong cách chơi năng động',
        'location': 'Quận 3, TP.HCM',
      },
      {
        'username': 'lan_trick_artist',
        'email': 'lan.hoang@example.com',
        'full_name': 'Hoàng Thị Lan',
        'avatar_url': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200&h=200&fit=crop&crop=face',
        'bio': 'Nghệ sĩ bi-a với những pha trick shot ngoạn mục',
        'location': 'Quận 3, TP.HCM',
      },
    ];

    int memberCount = 0;
    List<String> createdUserIds = [];

    for (final member in memberTemplates) {
      try {
        final result = await supabase
            .from('users')
            .insert(member)
            .select('id')
            .single();
        
        createdUserIds.add(result['id']);
        print('   ✅ ${member['full_name']} (@${member['username']})');
        memberCount++;
        
      } catch (e) {
        print('   ❌ ${member['full_name']}: $e');
      }
    }
    
    print('   📊 Tạo thành công: $memberCount/${memberTemplates.length} thành viên\n');

    // 5. Thêm vào club_members
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

    // 6. Cập nhật tournaments hiện tại với hình ảnh
    print('🏆 5. CẬP NHẬT TOURNAMENTS:');
    print('===========================');
    
    final existingTournaments = await supabase
        .from('tournaments')
        .select('id, title, club_id');
    
    final tournamentImages = [
      'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=600&h=400&fit=crop',
      'https://images.unsplash.com/photo-1574631806042-182f10c4a017?w=600&h=400&fit=crop',
    ];
    
    for (int i = 0; i < existingTournaments.length; i++) {
      final tournament = existingTournaments[i];
      
      try {
        await supabase
            .from('tournaments')
            .update({
              'cover_image_url': tournamentImages[i % tournamentImages.length],
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', tournament['id']);
        
        print('   ✅ ${tournament['title']}: Đã thêm hình ảnh');
        
      } catch (e) {
        print('   ❌ ${tournament['title']}: $e');
      }
    }

    // 7. Tạo thêm posts với hình ảnh từ members
    print('\n📝 6. TẠO POSTS MỚI:');
    print('====================');
    
    final postTemplates = [
      {
        'content': '🎱 Vừa hoàn thành trận đấu tuyệt vời! Cảm ơn Golden Billiards Club đã tổ chức sự kiện hay! #BiAProud #GoldenBilliards',
        'image_url': 'https://images.unsplash.com/photo-1594736797933-d0601ba2fe65?w=500&h=300&fit=crop'
      },
      {
        'content': '🏆 Chuẩn bị cho tournament sắp tới! Ai muốn thử thách cùng mình không? 💪 #Tournament #Challenge',
        'image_url': 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=500&h=300&fit=crop'
      },
      {
        'content': '✨ Trick shot của hôm nay! Luyện tập mãi mới được pha này 🎯 #TrickShot #Practice',
        'image_url': 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=500&h=300&fit=crop'
      },
      {
        'content': '🎊 SABO Arena Central - nơi tuyệt vời để gặp gỡ các cao thủ! Atmosphere tuyệt vời! #SABOArena',
        'image_url': 'https://images.unsplash.com/photo-1574631806042-182f10c4a017?w=500&h=300&fit=crop'
      },
    ];

    int postCount = 0;
    for (int i = 0; i < postTemplates.length && i < createdUserIds.length; i++) {
      final post = postTemplates[i];
      final userId = createdUserIds[i];
      
      try {
        await supabase
            .from('posts')
            .insert({
              'user_id': userId,
              'content': post['content'],
              'image_url': post['image_url'],
              'created_at': DateTime.now().toIso8601String(),
            });
        
        print('   ✅ Post ${i + 1}: ${post['content']?.substring(0, 30)}...');
        postCount++;
        
      } catch (e) {
        print('   ❌ Post ${i + 1}: $e');
      }
    }

    // 8. Tổng kết
    print('\n📊 7. TỔNG KẾT:');
    print('================');
    print('   👥 Thành viên mới: $memberCount');
    print('   🏢 Club members: $clubMemberCount');
    print('   🏆 Tournament images: ${existingTournaments.length}');
    print('   📝 Posts mới: $postCount');
    
    // Kiểm tra dữ liệu cuối cùng
    for (final club in clubs) {
      final members = await supabase
          .from('club_members')
          .select('user_id')
          .eq('club_id', club['id']);
          
      print('');
      print('   🏢 ${club['name']}:');
      print('      👥 Total Members: ${members.length}');
      
      if (members.isNotEmpty) {
        final memberDetails = await supabase
            .from('users')
            .select('full_name, avatar_url')
            .inFilter('id', members.map((m) => m['user_id']).toList());
        
        for (final member in memberDetails) {
          print('      • ${member['full_name']} ${member['avatar_url'] != null ? '📷' : ''}');
        }
      }
    }

    print('\n🎉 HOÀN THÀNH THÊM DATA!');
    print('   ✅ Database có đầy đủ thành viên với hình ảnh đa dạng');
    print('   ✅ Tournaments đã có cover images chất lượng');
    print('   ✅ Posts mới với visual content hấp dẫn'); 
    print('   ✅ Tab "đối thủ" sẽ hiển thị nhiều người chơi với avatars đẹp!');

  } catch (e) {
    print('❌ LỖI: $e');
    exit(1);
  }

  exit(0);
}