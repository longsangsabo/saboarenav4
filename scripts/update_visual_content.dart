import 'dart:io';
import 'dart:math';
import 'package:supabase/supabase.dart';

Future<void> main() async {
  print('👥🖼️ CẬP NHẬT HÌNH ẢNH CHO USERS HIỆN TẠI...\n');

  const supabaseUrl = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
  const serviceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo';

  try {
    final supabase = SupabaseClient(supabaseUrl, serviceKey);
    print('✅ Kết nối Supabase thành công!\n');

    // 1. Lấy users hiện tại
    print('👥 1. USERS HIỆN TẠI:');
    print('=====================');
    
    final users = await supabase
        .from('users')
        .select('id, full_name, username, avatar_url, bio');
    
    for (final user in users) {
      print('   👤 ${user['full_name'] ?? user['username']} - Avatar: ${user['avatar_url'] != null ? '✅' : '❌'}');
    }
    print('   📊 Tổng: ${users.length} users\n');

    // 2. Avatar templates chất lượng cao
    final avatarTemplates = [
      'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200&h=200&fit=crop&crop=face',  // Professional man
      'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=200&h=200&fit=crop&crop=face',  // Professional woman
      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=200&fit=crop&crop=face',  // Young man
      'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&h=200&fit=crop&crop=face',  // Mature man
      'https://images.unsplash.com/photo-1519345182560-3f2917c472ef?w=200&h=200&fit=crop&crop=face',  // Confident man
      'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200&h=200&fit=crop&crop=face',  // Happy woman
      'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=200&h=200&fit=crop&crop=face',  // Casual man
    ];

    // 3. Bio templates cho từng user
    final bioTemplates = [
      'Đam mê bi-a và luôn tìm kiếm những thử thách mới! 🎱',
      'Chuyên gia 8-ball với 5 năm kinh nghiệm thi đấu 🏆', 
      'Yêu thích snooker và trick shots sáng tạo ✨',
      'Player năng động, sẵn sàng giao lưu cùng mọi người 🔥',
      'Tournament enthusiast - Let\'s play! 🎯',
      'Speed pool specialist với passion không giới hạn ⚡',
      'Billiards lover, always improving my game 💪',
    ];

    // 4. Cập nhật hình ảnh cho users hiện tại
    print('🖼️ 2. CẬP NHẬT AVATARS:');
    print('========================');
    
    int updatedCount = 0;
    final random = Random();
    
    for (int i = 0; i < users.length; i++) {
      final user = users[i];
      final userId = user['id'];
      final userName = user['full_name'] ?? user['username'] ?? 'User $i';
      
      // Chọn avatar và bio ngẫu nhiên
      final avatarUrl = avatarTemplates[i % avatarTemplates.length];
      final bio = bioTemplates[i % bioTemplates.length];
      
      try {
        await supabase
            .from('users')
            .update({
              'avatar_url': avatarUrl,
              'bio': bio,
              'skill_level': ['beginner', 'intermediate', 'advanced', 'pro'][random.nextInt(4)],
              'total_matches': 10 + random.nextInt(100),
              'wins': 5 + random.nextInt(50),
              'losses': random.nextInt(20),
              'ranking_points': 1000 + random.nextInt(2000),
              'is_verified': random.nextBool(),
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', userId);
        
        print('   ✅ $userName: Avatar & bio updated');
        updatedCount++;
        
      } catch (e) {
        print('   ❌ $userName: $e');
      }
    }
    
    print('   📊 Cập nhật: $updatedCount/${users.length} users\n');

    // 5. Cập nhật posts với hình ảnh
    print('📝 3. CẬP NHẬT POSTS:');
    print('=====================');
    
    final posts = await supabase
        .from('posts')
        .select('id, content, image_url')
        .isFilter('image_url', null)
        .limit(10);
    
    final postImages = [
      'https://images.unsplash.com/photo-1594736797933-d0601ba2fe65?w=500&h=300&fit=crop',  // Billiard balls
      'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=500&h=300&fit=crop',  // Pool table
      'https://images.unsplash.com/photo-1574631806042-182f10c4a017?w=500&h=300&fit=crop',  // Tournament
      'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=500&h=300&fit=crop',  // Modern pool hall
      'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=500&h=300&fit=crop',   // Pool cue
    ];
    
    int postUpdatedCount = 0;
    
    for (int i = 0; i < posts.length; i++) {
      final post = posts[i];
      final imageUrl = postImages[i % postImages.length];
      
      try {
        await supabase
            .from('posts')
            .update({
              'image_url': imageUrl,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', post['id']);
        
        print('   ✅ Post ${i + 1}: Đã thêm hình ảnh');
        postUpdatedCount++;
        
      } catch (e) {
        print('   ❌ Post ${i + 1}: $e');
      }
    }
    
    print('   📊 Posts updated: $postUpdatedCount/${posts.length}\n');

    // 6. Cập nhật tournaments với nhiều hình ảnh hơn
    print('🏆 4. TOURNAMENT GALLERIES:');
    print('===========================');
    
    final tournaments = await supabase
        .from('tournaments')
        .select('id, title, description, cover_image_url');
    
    final tournamentDescriptions = [
      'Giải đấu bi-a chuyên nghiệp thu hút các cao thủ từ khắp nơi. Với format thi đấu hiện đại và giải thưởng hấp dẫn, đây là cơ hội để thể hiện kỹ năng và giao lưu với cộng đồng bi-a. 🏆✨',
      'Tournament quy mô lớn với sự tham gia của nhiều CLB uy tín. Không chỉ là nơi tranh tài, đây còn là dịp để học hỏi kinh nghiệm từ các player giàu kinh nghiệm và mở rộng network. 🎱🔥'
    ];
    
    for (int i = 0; i < tournaments.length; i++) {
      final tournament = tournaments[i];
      
      try {
        await supabase
            .from('tournaments')
            .update({
              'description': tournamentDescriptions[i % tournamentDescriptions.length],
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', tournament['id']);
        
        print('   ✅ ${tournament['title']}: Enhanced description');
        
      } catch (e) {
        print('   ❌ ${tournament['title']}: $e');
      }
    }

    // 7. Tạo achievements mới
    print('\n🏅 5. TẠO ACHIEVEMENTS:');
    print('======================');
    
    final achievementTemplates = [
      {
        'title': 'First Victory',
        'description': 'Giành chiến thắng đầu tiên',
        'icon': '🏆',
        'points': 100,
        'category': 'milestone'
      },
      {
        'title': 'Combo Master', 
        'description': 'Thực hiện combo 5 bóng liên tiếp',
        'icon': '🎯',
        'points': 200,
        'category': 'skill'
      },
      {
        'title': 'Tournament Rookie',
        'description': 'Tham gia tournament đầu tiên',
        'icon': '🌟',
        'points': 150,
        'category': 'tournament'
      },
      {
        'title': 'Social Butterfly',
        'description': 'Kết bạn với 10 người chơi',
        'icon': '👥',
        'points': 250,
        'category': 'social'
      },
    ];
    
    int achievementCount = 0;
    
    for (final achievement in achievementTemplates) {
      try {
        await supabase
            .from('achievements')
            .insert({
              'title': achievement['title'],
              'description': achievement['description'],
              'icon': achievement['icon'],
              'points': achievement['points'],
              'category': achievement['category'],
            });
        
        print('   ✅ ${achievement['title']} ${achievement['icon']} - ${achievement['points']} pts');
        achievementCount++;
        
      } catch (e) {
        print('   ❌ ${achievement['title']}: $e');
      }
    }

    // 8. Kiểm tra kết quả cuối cùng
    print('\n🔍 6. KIỂM TRA KẾT QUẢ:');
    print('========================');
    
    final updatedUsers = await supabase
        .from('users')
        .select('id, full_name, username, avatar_url, bio, skill_level');
    
    int usersWithAvatars = 0;
    int usersWithBios = 0;
    
    for (final user in updatedUsers) {
      if (user['avatar_url'] != null) usersWithAvatars++;
      if (user['bio'] != null && user['bio'].toString().isNotEmpty) usersWithBios++;
      
      print('   👤 ${user['full_name'] ?? user['username']}:');
      print('      📷 Avatar: ${user['avatar_url'] != null ? '✅' : '❌'}');
      print('      📝 Bio: ${user['bio'] != null && user['bio'].toString().isNotEmpty ? '✅' : '❌'}');
      print('      ⭐ Skill: ${user['skill_level'] ?? 'N/A'}');
      print('');
    }

    // 9. Tổng kết
    print('📊 7. TỔNG KẾT CUỐI CÙNG:');
    print('==========================');
    print('   👥 Users có avatars: $usersWithAvatars/${updatedUsers.length}');
    print('   📝 Users có bios: $usersWithBios/${updatedUsers.length}');
    print('   📝 Posts có hình ảnh: $postUpdatedCount');
    print('   🏆 Tournaments enhanced: ${tournaments.length}');
    print('   🏅 Achievements mới: $achievementCount');
    
    print('\n🎉 HOÀN TẤT CẬP NHẬT VISUAL CONTENT!');
    print('   ✅ Users có avatars đa dạng và bios hấp dẫn');
    print('   ✅ Posts có hình ảnh chất lượng cao từ Unsplash');
    print('   ✅ Tournaments có descriptions chi tiết');
    print('   ✅ Achievement system hoàn chỉnh');
    print('   ✅ Tab "đối thủ" giờ sẽ hiển thị đẹp mắt với đầy đủ visual content! 🔥');

  } catch (e) {
    print('❌ LỖI: $e');
    exit(1);
  }

  exit(0);
}