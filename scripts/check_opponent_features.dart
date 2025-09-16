import 'dart:io';
import 'package:supabase/supabase.dart';

Future<void> main() async {
  print('🥊 KIỂM TRA DATABASE CHO TAB "ĐỐI THỦ"...\n');

  const supabaseUrl = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
  const serviceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo';

  try {
    final supabase = SupabaseClient(supabaseUrl, serviceKey);
    
    print('📊 CURRENT DATABASE TABLES:');
    
    // Check existing tables relevant to "Đối thủ" features
    try {
      final matches = await supabase
          .from('matches')
          .select('id, status, match_type')
          .limit(1);
      print('   ✅ matches table: Có (${matches.length > 0 ? 'có data' : 'empty'})');
    } catch (e) {
      print('   ❌ matches table: Error - $e');
    }
    
    // Check for challenge-related tables
    try {
      final challenges = await supabase
          .from('challenges')
          .select('count')
          .count();
      print('   ✅ challenges table: Có (${challenges.count} records)');
    } catch (e) {
      print('   ❌ challenges table: Không tồn tại');
    }
    
    try {
      final friendlyMatches = await supabase
          .from('friendly_matches')
          .select('count')
          .count();
      print('   ✅ friendly_matches table: Có (${friendlyMatches.count} records)');
    } catch (e) {
      print('   ❌ friendly_matches table: Không tồn tại');
    }
    
    try {
      final bets = await supabase
          .from('bets')
          .select('count')
          .count();
      print('   ✅ bets table: Có (${bets.count} records)');
    } catch (e) {
      print('   ❌ bets table: Không tồn tại');
    }
    
    try {
      final matchInvitations = await supabase
          .from('match_invitations')
          .select('count')
          .count();
      print('   ✅ match_invitations table: Có (${matchInvitations.count} records)');
    } catch (e) {
      print('   ❌ match_invitations table: Không tồn tại');
    }
    
    print('\n🥊 FEATURES CẦN CHO TAB "ĐỐI THỦ":');
    
    print('\n1. 🎯 TRẬN ĐẤU GIAO LƯU:');
    print('   • Mời bạn bè đấu thân thiện');
    print('   • Quick match với người lạ');
    print('   • Custom rules và điều kiện');
    print('   • History các trận giao lưu');
    
    print('\n2. ⚔️ TRẬN THÁCH ĐẤU:');
    print('   • Challenge specific players');
    print('   • Accept/decline challenges');
    print('   • Challenge với điều kiện đặc biệt');
    print('   • Ranking challenges');
    
    print('\n3. 💰 TRẬN ĐẤU CÓ CƯỢC:');
    print('   • Bet matches với tiền thật/virtual');
    print('   • Stake negotiations');
    print('   • Escrow system');
    print('   • Betting history & winnings');
    
    print('\n4. 🎮 MATCH FINDER:');
    print('   • Tìm đối thủ cùng level');
    print('   • Location-based matching');
    print('   • Skill-based matching');
    print('   • Time-based availability');
    
    print('\n📋 CẦN TẠO TABLES:');
    print('   📊 challenges - Thách đấu system');
    print('   🤝 friendly_matches - Giao lưu');
    print('   💰 match_bets - Cược đặt');
    print('   📨 match_invitations - Lời mời');
    print('   🔍 match_finder_requests - Tìm đối thủ');
    print('   ⭐ player_preferences - Preferences');
    
    print('\n🚀 IMPLEMENTATION PLAN:');
    print('   1. Design database schema cho features');
    print('   2. Create tables với relationships');
    print('   3. Add sample data cho testing');
    print('   4. Test UI workflows');
    
    print('\n💡 BẠN MUỐN BẮT ĐẦU VỚI FEATURE NÀO?');
    print('   A) 🎯 Friendly matches (giao lưu)');
    print('   B) ⚔️ Challenge system (thách đấu)'); 
    print('   C) 💰 Betting matches (có cược)');
    print('   D) 🔍 Match finder (tìm đối thủ)');
    print('   E) 📱 All features (complete system)');
    
  } catch (e) {
    print('❌ ERROR: $e');
    exit(1);
  }

  exit(0);
}