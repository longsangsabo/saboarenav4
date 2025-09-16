import 'dart:io';
import 'package:supabase/supabase.dart';

Future<void> main() async {
  print('🔍 PHÂN TÍCH DATA GAPS VÀ ĐỀ XUẤT BỔ SUNG...\n');

  const supabaseUrl = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
  const serviceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo';

  try {
    final supabase = SupabaseClient(supabaseUrl, serviceKey);
    
    print('📊 CURRENT DATA ANALYSIS:');
    print('=' * 50);
    
    // Kiểm tra data hiện tại
    final currentData = await Future.wait([
      supabase.from('users').select('count').count(),
      supabase.from('tournaments').select('count').count(),
      supabase.from('matches').select('count').count(),
      supabase.from('posts').select('count').count(),
      supabase.from('comments').select('count').count(),
      supabase.from('clubs').select('count').count(),
      supabase.from('club_members').select('count').count(),
      supabase.from('achievements').select('count').count(),
    ]);
    
    print('   👥 Users: ${currentData[0].count}');
    print('   🏆 Tournaments: ${currentData[1].count}');
    print('   ⚔️  Matches: ${currentData[2].count}');
    print('   📝 Posts: ${currentData[3].count}');
    print('   💬 Comments: ${currentData[4].count}');
    print('   🏛️  Clubs: ${currentData[5].count}');
    print('   👨‍👩‍👧‍👦 Club Members: ${currentData[6].count}');
    print('   🏅 Achievements: ${currentData[7].count}');
    
    print('\n🎯 MISSING DATA ANALYSIS:');
    print('=' * 50);
    
    // 1. Match History - cần completed matches
    final completedMatches = await supabase
        .from('matches')
        .select('count')
        .eq('status', 'completed')
        .count();
    
    print('   ⚔️  Completed Matches: ${completedMatches.count}/${currentData[2].count}');
    if (completedMatches.count == 0) {
      print('      ❌ THIẾU: Match history với results');
    }
    
    // 2. Tournament leaderboards
    final tournamentWithParticipants = await supabase
        .from('tournaments')
        .select('current_participants, max_participants');
    
    print('   🏆 Tournament Status:');
    for (var tournament in tournamentWithParticipants) {
      final participation = '${tournament['current_participants']}/${tournament['max_participants']}';
      print('      - Participants: $participation');
    }
    
    // 3. User variety (skill levels, locations)
    final userRanks = await supabase
        .from('users')
        .select('rank');
    
    final rankDistribution = <String, int>{};
    for (var user in userRanks) {
      final rank = user['rank'] ?? 'E';
      rankDistribution[rank] = (rankDistribution[rank] ?? 0) + 1;
    }
    
    print('   🎖️  Rank Distribution: $rankDistribution');
    if (rankDistribution.keys.length < 3) {
      print('      ❌ THIẾU: User diversity (different skill levels)');
    }
    
    print('\n💡 RECOMMENDATIONS:');
    print('=' * 50);
    
    final recommendations = <String>[];
    
    if (completedMatches.count == 0) {
      recommendations.add('1. 🏁 MATCH RESULTS: Tạo completed matches với winners/losers');
      recommendations.add('   - Update user win/loss records');
      recommendations.add('   - Create match history timeline');
      recommendations.add('   - Generate leaderboards');
    }
    
    if (currentData[0].count < 10) {
      recommendations.add('2. 👥 MORE USERS: Tạo thêm users với variety');
      recommendations.add('   - Different skill levels (A, B, C, D ranks)');
      recommendations.add('   - Different locations for "find opponents"');
      recommendations.add('   - Varied play styles and preferences');
    }
    
    if (currentData[1].count < 5) {
      recommendations.add('3. 🏆 MORE TOURNAMENTS: Tạo tournament variety');
      recommendations.add('   - Different formats (8-Ball, 9-Ball, 10-Ball)');
      recommendations.add('   - Various skill levels (beginner to professional)');
      recommendations.add('   - Different prize pools and entry fees');
    }
    
    recommendations.add('4. 📊 REALISTIC STATISTICS: Cập nhật user stats');
    recommendations.add('   - Win/loss ratios based on completed matches');
    recommendations.add('   - ELO ratings that reflect actual performance');
    recommendations.add('   - Tournament placement history');
    
    recommendations.add('5. 🎮 LIVE TOURNAMENT: Tạo ongoing tournament');
    recommendations.add('   - Current matches in progress');
    recommendations.add('   - Live leaderboard updates');
    recommendations.add('   - Bracket progression');
    
    recommendations.add('6. 🌟 ADVANCED FEATURES: Optional enhancements');
    recommendations.add('   - User preferences & settings');
    recommendations.add('   - Match scheduling system');
    recommendations.add('   - Tournament brackets visualization');
    recommendations.add('   - Push notification scenarios');
    
    print('📋 PRIORITY ORDER:');
    print('   🔥 HIGH: Match Results & User Stats');
    print('   🔵 MEDIUM: More Users & Tournaments');
    print('   ⚪ LOW: Advanced Features');
    
    print('\n🎯 NEXT STEPS SUGGESTION:');
    print('   1. Tạo completed matches với realistic results');
    print('   2. Update user win/loss statistics');
    print('   3. Tạo thêm 3-5 users với different ranks');
    print('   4. Tạo 1-2 tournaments nữa với different formats');
    print('   5. Test app với comprehensive data');
    
    for (var rec in recommendations) {
      print('   $rec');
    }
    
  } catch (e) {
    print('❌ ERROR: $e');
    exit(1);
  }

  exit(0);
}