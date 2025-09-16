import 'dart:io';
import 'package:supabase/supabase.dart';

Future<void> main() async {
  print('🏢 KIỂM TRA SỐ LƯỢNG CLUBS TRONG DATABASE...\n');

  const supabaseUrl = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
  const serviceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo';

  try {
    final supabase = SupabaseClient(supabaseUrl, serviceKey);
    print('✅ Kết nối Supabase thành công!\n');

    // 1. Đếm tổng số clubs
    print('📊 1. THỐNG KÊ CLUBS:');
    print('====================');
    
    final totalClubs = await supabase
        .from('clubs')
        .select('count')
        .count();
    
    print('   📍 Tổng số clubs: ${totalClubs.count}');

    // 2. Lấy thông tin chi tiết các clubs
    if (totalClubs.count > 0) {
      print('\n🏢 2. CHI TIẾT CÁC CLUBS:');
      print('=========================');
      
      final clubs = await supabase
          .from('clubs')
          .select('id, name, address, owner_id, is_active, total_tables, created_at')
          .order('created_at', ascending: false);
      
      for (int i = 0; i < clubs.length; i++) {
        final club = clubs[i];
        print('   🏪 Club ${i + 1}: ${club['name']}');
        print('      📍 Địa chỉ: ${club['address'] ?? 'Chưa cập nhật'}');
        print('      👤 Owner ID: ${club['owner_id']}');
        print('      🎱 Số bàn: ${club['total_tables'] ?? 'N/A'}');
        print('      ✅ Hoạt động: ${club['is_active'] ?? false ? 'Có' : 'Không'}');
        print('      📅 Tạo lúc: ${club['created_at']}');
        print('');
      }

      // 3. Thống kê thêm
      print('📈 3. THỐNG KÊ BỔ SUNG:');
      print('=======================');
      
      final activeClubs = await supabase
          .from('clubs')
          .select('count')
          .eq('is_active', true)
          .count();
      
      print('   ✅ Clubs đang hoạt động: ${activeClubs.count}');
      
      final inactiveClubs = totalClubs.count - activeClubs.count;
      print('   ❌ Clubs không hoạt động: $inactiveClubs');
      
      // Kiểm tra club members
      try {
        final totalMembers = await supabase
            .from('club_members')
            .select('count')
            .count();
        
        print('   👥 Tổng số thành viên clubs: ${totalMembers.count}');
        
        if (totalMembers.count > 0 && activeClubs.count > 0) {
          final avgMembers = (totalMembers.count / activeClubs.count).toStringAsFixed(1);
          print('   📊 Trung bình thành viên/club: $avgMembers người');
        }
      } catch (e) {
        print('   ⚠️  Không thể truy cập bảng club_members');
      }
    } else {
      print('\n⚠️  KHÔNG CÓ CLUBS NÀO TRONG DATABASE!');
      print('   Cần tạo clubs để test tính năng đối thủ.');
    }

    // 4. Kiểm tra cấu trúc bảng clubs
    print('\n🔍 4. KIỂM TRA CẤU TRÚC BẢNG:');
    print('==============================');
    
    if (totalClubs.count > 0) {
      final sampleClub = await supabase
          .from('clubs')
          .select()
          .limit(1)
          .single();
      
      final columns = sampleClub.keys.toList()..sort();
      print('   📋 Các cột trong bảng clubs:');
      for (final column in columns) {
        print('      - $column');
      }
    }

    print('\n✅ HOÀN TẤT KIỂM TRA CLUBS DATABASE!');

  } catch (e) {
    print('❌ LỖI: $e');
    exit(1);
  }

  exit(0);
}