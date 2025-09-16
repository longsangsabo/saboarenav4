import 'dart:io';
import 'package:supabase/supabase.dart';

Future<void> main() async {
  print('🎮 CHECKING LONGSANG063 UI TEST DATA...\n');

  const supabaseUrl = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
  const serviceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo';

  try {
    final supabase = SupabaseClient(supabaseUrl, serviceKey);
    
    // Get longsang063 user data
    final user = await supabase
        .from('users')
        .select('*')
        .eq('email', 'longsang063@gmail.com')
        .single();
    
    final userId = user['id'];
    
    print('👤 USER PROFILE DATA:');
    print('   ✅ Basic info: ${user['email']} (${user['display_name']})');
    print('   ✅ Avatar: ${user['avatar_url'] != null ? 'YES' : 'NO'}');
    print('   ✅ Stats: ${user['wins']}W-${user['losses']}L, ELO: ${user['elo_rating']}');
    print('   ✅ Location: ${user['location'] ?? 'Not set'}');
    print('   ✅ Bio: ${user['bio'] ?? 'Not set'}');
    
    print('\n🏆 MATCHES DATA:');
    final matches = await supabase
        .from('matches')
        .select('*, tournament:tournaments(name)')
        .or('player1_id.eq.$userId,player2_id.eq.$userId')
        .order('created_at', ascending: false);
    
    print('   ✅ Total matches: ${matches.length}');
    print('   ✅ Recent matches for UI testing:');
    for (var match in matches.take(3)) {
      final status = match['status'];
      final score = '${match['player1_score'] ?? 0}-${match['player2_score'] ?? 0}';
      final tournament = match['tournament'] != null ? ' (${match['tournament']['name']})' : '';
      print('      • Match $status: $score$tournament');
    }
    
    print('\n🤝 SOCIAL DATA:');
    final followers = await supabase
        .from('user_follows') 
        .select('count')
        .eq('followed_id', userId)
        .count();
    
    final following = await supabase
        .from('user_follows')
        .select('count') 
        .eq('follower_id', userId)
        .count();
    
    final posts = await supabase
        .from('posts')
        .select('*, comments(count)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    
    print('   ✅ Followers: ${followers.count}');
    print('   ✅ Following: ${following.count}');
    print('   ✅ Posts: ${posts.length}');
    if (posts.isNotEmpty) {
      print('      • Latest post: "${posts.first['content']?.toString().substring(0, 30) ?? ''}..."');
    }
    
    print('\n🏆 TOURNAMENT DATA:');
    final tournamentParticipations = await supabase
        .from('tournament_participants')
        .select('*, tournament:tournaments(name, status)')
        .eq('user_id', userId);
    
    print('   ✅ Tournament participations: ${tournamentParticipations.length}');
    for (var participation in tournamentParticipations) {
      final tournament = participation['tournament'];
      print('      • ${tournament['name']} (${tournament['status']})');
    }
    
    print('\n🏛️ CLUB DATA:');
    final clubMemberships = await supabase
        .from('club_members')
        .select('*, club:clubs(name)')
        .eq('user_id', userId);
    
    print('   ✅ Club memberships: ${clubMemberships.length}');
    for (var membership in clubMemberships) {
      final club = membership['club'];
      print('      • ${club['name']} (${membership['role']})');
    }
    
    print('\n🏅 ACHIEVEMENT DATA:');
    final achievements = await supabase
        .from('user_achievements')
        .select('*, achievement:achievements(name, description)')
        .eq('user_id', userId);
    
    print('   ✅ Unlocked achievements: ${achievements.length}');
    for (var userAchievement in achievements) {
      final achievement = userAchievement['achievement'];
      print('      • ${achievement['name']}: ${achievement['description']}');
    }
    
    print('\n📊 UI SCREEN COVERAGE ANALYSIS:');
    print('   🏠 Home Screen: ${posts.isNotEmpty ? '✅ GOOD' : '❌ NEED POSTS'}');
    print('   👤 Profile Screen: ${user['bio'] != null ? '✅ GOOD' : '⚠️ BASIC'}');
    print('   🏆 Matches Screen: ${matches.isNotEmpty ? '✅ GOOD' : '❌ NO MATCHES'}');
    print('   🤝 Social Screen: ${followers.count > 0 ? '✅ GOOD' : '❌ NO FOLLOWERS'}');
    print('   🏆 Tournament Screen: ${tournamentParticipations.isNotEmpty ? '✅ GOOD' : '❌ NOT JOINED'}');
    print('   🏛️ Club Screen: ${clubMemberships.isNotEmpty ? '✅ GOOD' : '❌ NOT MEMBER'}');
    print('   🏅 Achievement Screen: ${achievements.isNotEmpty ? '✅ GOOD' : '❌ NO ACHIEVEMENTS'}');
    
    print('\n🎯 MISSING DATA FOR UI TESTING:');
    if (user['bio'] == null) print('   • User bio and detailed profile info');
    if (tournamentParticipations.isEmpty) print('   • Tournament participation');
    if (clubMemberships.isEmpty) print('   • Club membership');
    if (achievements.isEmpty) print('   • Unlocked achievements');
    if (matches.length < 5) print('   • More match history for scrolling');
    
  } catch (e) {
    print('❌ ERROR: $e');
    exit(1);
  }

  exit(0);
}