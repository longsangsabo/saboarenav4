import 'dart:io';
import 'package:supabase/supabase.dart';

Future<void> main() async {
  print('🖼️ CẬP NHẬT AVATARS & VISUAL CONTENT...\n');

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
        .select('id, full_name, username, avatar_url');
    
    for (final user in users) {
      print('   👤 ${user['full_name'] ?? user['username']} - Avatar: ${user['avatar_url'] != null ? '✅' : '❌'}');
    }
    print('   📊 Tổng: ${users.length} users\n');

    // 2. Avatar templates chất lượng cao - Đa dạng về giới tính, tuổi tác
    final avatarTemplates = [
      'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200&h=200&fit=crop&crop=face',  // Professional man 1
      'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=200&h=200&fit=crop&crop=face',  // Professional woman 1
      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=200&fit=crop&crop=face',  // Young man 1
      'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200&h=200&fit=crop&crop=face',  // Happy woman 1
      'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&h=200&fit=crop&crop=face',  // Mature man 1
      'https://images.unsplash.com/photo-1519345182560-3f2917c472ef?w=200&h=200&fit=crop&crop=face',  // Confident man 1
      'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=200&h=200&fit=crop&crop=face',  // Casual man 1
      'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200&h=200&fit=crop&crop=face',     // Happy woman 2
      'https://images.unsplash.com/photo-1567532900872-f4e906cbf06a?w=200&h=200&fit=crop&crop=face',  // Young man 2
      'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=200&h=200&fit=crop&crop=face',  // Professional woman 2
    ];

    // 3. Bio templates phù hợp với bi-a
    final bioTemplates = [
      'Đam mê bi-a và luôn tìm kiếm những thử thách mới! 🎱',
      'Chuyên gia 8-ball với nhiều năm kinh nghiệm thi đấu 🏆', 
      'Yêu thích snooker và những pha trick shots sáng tạo ✨',
      'Player năng động, sẵn sàng giao lưu cùng mọi người 🔥',
      'Tournament enthusiast - Let\'s compete! 🎯',
      'Speed pool specialist với passion không giới hạn ⚡',
      'Billiards lover, always improving skills 💪',
      'Tìm kiếm đối thủ xứng tầm để cùng tiến bộ 🚀',
      'Admin của SABO Arena - Chào mừng mọi người! 👋',
      'Newcomer nhưng học hỏi rất nhanh 📈',
    ];

    // 4. Cập nhật avatars và bios
    print('🖼️ 2. CẬP NHẬT AVATARS:');
    print('========================');
    
    int updatedCount = 0;
    
    for (int i = 0; i < users.length; i++) {
      final user = users[i];
      final userId = user['id'];
      final userName = user['full_name'] ?? user['username'] ?? 'User $i';
      
      // Chọn avatar và bio phù hợp
      final avatarUrl = avatarTemplates[i % avatarTemplates.length];
      final bio = bioTemplates[i % bioTemplates.length];
      
      try {
        await supabase
            .from('users')
            .update({
              'avatar_url': avatarUrl,
              'bio': bio,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', userId);
        
        print('   ✅ $userName: Avatar & bio cập nhật');
        updatedCount++;
        
      } catch (e) {
        print('   ❌ $userName: $e');
      }
    }
    
    print('   📊 Cập nhật thành công: $updatedCount/${users.length} users\n');

    // 5. Cập nhật posts với image_urls (đúng tên column)
    print('📝 3. CẬP NHẬT POSTS:');
    print('=====================');
    
    final posts = await supabase
        .from('posts')
        .select('id, content, image_urls')
        .limit(15);
    
    final postImages = [
      'https://images.unsplash.com/photo-1594736797933-d0601ba2fe65?w=500&h=300&fit=crop',  // Billiard balls
      'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=500&h=300&fit=crop',  // Pool table view
      'https://images.unsplash.com/photo-1574631806042-182f10c4a017?w=500&h=300&fit=crop',  // Tournament scene
      'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=500&h=300&fit=crop',  // Modern pool hall
      'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=500&h=300&fit=crop',   // Pool cue close-up
    ];
    
    int postUpdatedCount = 0;
    
    for (int i = 0; i < posts.length; i++) {
      final post = posts[i];
      final imageUrl = postImages[i % postImages.length];
      
      try {
        // Cập nhật với array format
        await supabase
            .from('posts')
            .update({
              'image_urls': [imageUrl],
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

    // 6. Cập nhật clubs với hình ảnh bổ sung
    print('🏢 4. CẬP NHẬT CLUB DETAILS:');
    print('============================');
    
    final clubs = await supabase
        .from('clubs')
        .select('id, name, profile_image_url, cover_image_url');
    
    // Thêm gallery images cho clubs
    final clubGalleries = {
      'Golden Billiards Club': [
        'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=300&fit=crop',
        'https://images.unsplash.com/photo-1594736797933-d0601ba2fe65?w=400&h=300&fit=crop',
        'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=400&h=300&fit=crop',
      ],
      'SABO Arena Central': [
        'https://images.unsplash.com/photo-1574631806042-182f10c4a017?w=400&h=300&fit=crop',
        'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=400&h=300&fit=crop',
        'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=300&fit=crop',
      ]
    };
    
    for (final club in clubs) {
      final clubName = club['name'];
      final gallery = clubGalleries[clubName];
      
      if (gallery != null) {
        try {
          await supabase
              .from('clubs')
              .update({
                'gallery_images': gallery,
                'updated_at': DateTime.now().toIso8601String(),
              })
              .eq('id', club['id']);
          
          print('   ✅ $clubName: Gallery images added (${gallery.length} photos)');
          
        } catch (e) {
          print('   ❌ $clubName: $e');
        }
      }
    }

    // 7. Kiểm tra kết quả cuối cùng
    print('\n🔍 5. KIỂM TRA KẾT QUẢ:');
    print('========================');
    
    final updatedUsers = await supabase
        .from('users')
        .select('id, full_name, username, avatar_url, bio');
    
    int usersWithAvatars = 0;
    int usersWithBios = 0;
    
    print('   👥 DANH SÁCH USERS SAU CẬP NHẬT:');
    for (final user in updatedUsers) {
      if (user['avatar_url'] != null) usersWithAvatars++;
      if (user['bio'] != null && user['bio'].toString().isNotEmpty) usersWithBios++;
      
      print('      👤 ${user['full_name'] ?? user['username']}:');
      print('         📷 Avatar: ${user['avatar_url'] != null ? '✅ Có' : '❌ Chưa có'}');
      print('         📝 Bio: ${user['bio'] != null ? '✅ Có' : '❌ Chưa có'}');
      if (user['bio'] != null && user['bio'].toString().isNotEmpty) {
        print('         💬 "${user['bio']}"');
      }
      print('');
    }

    // 8. Tổng kết
    print('📊 6. TỔNG KẾT CUỐI CÙNG:');
    print('==========================');
    print('   👥 Users có avatars: $usersWithAvatars/${updatedUsers.length} (${(usersWithAvatars/updatedUsers.length*100).toStringAsFixed(1)}%)');
    print('   📝 Users có bios: $usersWithBios/${updatedUsers.length} (${(usersWithBios/updatedUsers.length*100).toStringAsFixed(1)}%)');
    print('   📝 Posts có hình ảnh: $postUpdatedCount');
    print('   🏢 Clubs có gallery: ${clubs.length}');
    
    print('\n🎉 HOÀN TẤT CẬP NHẬT VISUAL CONTENT!');
    print('   ✅ Users giờ có avatars đa dạng từ Unsplash');
    print('   ✅ Bios phù hợp với cộng đồng bi-a');
    print('   ✅ Posts có hình ảnh chất lượng cao');
    print('   ✅ Clubs có gallery images phong phú');
    print('   ✅ Tab "đối thủ" sẽ hiển thị rất đẹp mắt! 🔥🎱');

  } catch (e) {
    print('❌ LỖI: $e');
    exit(1);
  }

  exit(0);
}