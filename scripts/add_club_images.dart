import 'dart:io';
import 'package:supabase/supabase.dart';

Future<void> main() async {
  print('🖼️ BỔ SUNG HÌNH ẢNH & LOGO CHO CLUBS...\n');

  const supabaseUrl = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
  const serviceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo';

  try {
    final supabase = SupabaseClient(supabaseUrl, serviceKey);
    print('✅ Kết nối Supabase thành công!\n');

    // 1. Lấy danh sách clubs hiện tại
    print('📋 1. LẤY DANH SÁCH CLUBS:');
    print('===========================');
    
    final clubs = await supabase
        .from('clubs')
        .select('id, name, profile_image_url, cover_image_url')
        .order('name');
    
    print('   Tìm thấy ${clubs.length} clubs cần cập nhật hình ảnh\n');
    
    // 2. Tạo URLs hình ảnh chất lượng cao
    final clubImages = {
      'Golden Billiards Club': {
        'profile_image_url': 'https://images.unsplash.com/photo-1594736797933-d0601ba2fe65?w=400&h=400&fit=crop&crop=center', // Billiards balls
        'cover_image_url': 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800&h=400&fit=crop&crop=center', // Luxury billiards room
        'description': 'Câu lạc bộ bi-a cao cấp với không gian sang trọng và thiết bị chuyên nghiệp'
      },
      'SABO Arena Central': {
        'profile_image_url': 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=400&h=400&fit=crop&crop=center', // Modern pool hall
        'cover_image_url': 'https://images.unsplash.com/photo-1574631806042-182f10c4a017?w=800&h=400&fit=crop&crop=center', // Professional tournament setup
        'description': 'Arena bi-a hiện đại với hệ thống thi đấu chuyên nghiệp và không gian rộng rãi'
      }
    };

    // 3. Cập nhật hình ảnh cho từng club
    print('🖼️ 2. CẬP NHẬT HÌNH ẢNH CLUBS:');
    print('================================');
    
    int updated = 0;
    
    for (final club in clubs) {
      final clubName = club['name'];
      final clubId = club['id'];
      
      if (clubImages.containsKey(clubName)) {
        final images = clubImages[clubName]!;
        
        try {
          await supabase
              .from('clubs')
              .update({
                'profile_image_url': images['profile_image_url'],
                'cover_image_url': images['cover_image_url'],
                'description': images['description'],
                'updated_at': DateTime.now().toIso8601String(),
              })
              .eq('id', clubId);
          
          print('   ✅ $clubName: Đã cập nhật hình ảnh');
          print('      📷 Profile: ${images['profile_image_url']?.substring(0, 50)}...');
          print('      🖼️  Cover: ${images['cover_image_url']?.substring(0, 50)}...');
          updated++;
          
        } catch (e) {
          print('   ❌ $clubName: Lỗi cập nhật - $e');
        }
      } else {
        print('   ⚠️  $clubName: Không có hình ảnh được định nghĩa');
      }
      print('');
    }
    
    // 4. Thêm thông tin bổ sung cho clubs
    print('📝 3. BỔ SUNG THÔNG TIN CLUBS:');
    print('===============================');
    
    final additionalInfo = {
      'Golden Billiards Club': {
        'website_url': 'https://goldenbilliards.vn',
        'phone': '+84 28 3822 1234',
        'email': 'info@goldenbilliards.vn',
        'opening_hours': '09:00 - 23:00',
        'price_per_hour': 80000,
        'amenities': ['WiFi miễn phí', 'Đồ uống', 'Máy lạnh', 'Âm thanh chất lượng cao', 'Bãi đậu xe'],
        'established_year': 2018,
        'rating': 4.5,
        'total_reviews': 127,
        'latitude': 10.7756,
        'longitude': 106.7019
      },
      'SABO Arena Central': {
        'website_url': 'https://saboarena.vn',
        'phone': '+84 28 3944 5678',
        'email': 'contact@saboarena.vn', 
        'opening_hours': '08:00 - 24:00',
        'price_per_hour': 100000,
        'amenities': ['Tournament setup', 'Live streaming', 'VIP rooms', 'Restaurant', 'Pro shop', 'Coaching'],
        'established_year': 2020,
        'rating': 4.8,
        'total_reviews': 89,
        'latitude': 10.7829,
        'longitude': 106.6956
      }
    };
    
    for (final club in clubs) {
      final clubName = club['name'];
      final clubId = club['id'];
      
      if (additionalInfo.containsKey(clubName)) {
        final info = additionalInfo[clubName]!;
        
        try {
          await supabase
              .from('clubs')
              .update(info)
              .eq('id', clubId);
          
          print('   ✅ $clubName: Đã cập nhật thông tin chi tiết');
          print('      📞 Phone: ${info['phone']}');
          print('      🌐 Website: ${info['website_url']}');
          print('      ⭐ Rating: ${info['rating']}/5 (${info['total_reviews']} reviews)');
          
        } catch (e) {
          print('   ❌ $clubName: Lỗi cập nhật thông tin - $e');
        }
      }
      print('');
    }

    // 5. Kiểm tra kết quả
    print('🔍 4. KIỂM TRA KỐT QUẢ:');
    print('========================');
    
    final updatedClubs = await supabase
        .from('clubs')
        .select('name, profile_image_url, cover_image_url, description, rating, phone, website_url')
        .order('name');
    
    for (final club in updatedClubs) {
      print('   🏢 ${club['name']}:');
      print('      📷 Profile image: ${club['profile_image_url'] != null ? "✅ Có" : "❌ Chưa có"}');
      print('      🖼️  Cover image: ${club['cover_image_url'] != null ? "✅ Có" : "❌ Chưa có"}'); 
      print('      📝 Description: ${club['description'] != null ? "✅ Có" : "❌ Chưa có"}');
      print('      ⭐ Rating: ${club['rating'] ?? "N/A"}');
      print('      📞 Phone: ${club['phone'] ?? "N/A"}');
      print('      🌐 Website: ${club['website_url'] ?? "N/A"}');
      print('');
    }

    // 6. Tổng kết
    print('📊 5. TỔNG KẾT:');
    print('================');
    print('   ✅ Clubs đã cập nhật hình ảnh: $updated/${clubs.length}');
    print('   🖼️  Profile images: Sử dụng Unsplash chất lượng cao');
    print('   🖼️  Cover images: Hình nền chuyên nghiệp');
    print('   📝 Thông tin bổ sung: Phone, website, rating, amenities');
    print('   📍 Location data: Latitude/longitude cho map integration');
    
    print('\n🎉 HOÀN TẤT CẬP NHẬT HÌNH ẢNH & THÔNG TIN CLUBS!');
    print('   Clubs giờ đã có đầy đủ visual content cho UI testing');

  } catch (e) {
    print('❌ LỖI: $e');
    exit(1);
  }

  exit(0);
}