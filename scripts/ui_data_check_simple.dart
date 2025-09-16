import 'dart:io';
import 'package:supabase/supabase.dart';

Future<void> main() async {
  print('🎮 LONGSANG063 UI DATA COVERAGE CHECK...\n');

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
    
    print('👤 USER PROFILE SCREEN:');
    print('   ✅ Email: ${user['email']}');
    print('   ✅ Name: ${user['display_name']}');
    print('   ✅ Location: ${user['location']}');
    print('   ${user['avatar_url'] != null ? '✅' : '⚠️'} Avatar: ${user['avatar_url'] != null ? 'SET' : 'DEFAULT'}');
    print('   ${user['bio'] != null ? '✅' : '❌'} Bio: ${user['bio'] ?? 'MISSING - Need personal bio'}');
    print('   ✅ Stats: ${user['wins']}W-${user['losses']}L, ELO: ${user['elo_rating']}');
    
    print('\n🏆 MATCHES SCREEN:');
    final matches = await supabase
        .from('matches')
        .select('*')
        .or('player1_id.eq.$userId,player2_id.eq.$userId')
        .order('created_at', ascending: false);
    
    print('   ${matches.isNotEmpty ? '✅' : '❌'} Total matches: ${matches.length}');
    if (matches.isNotEmpty) {
      print('   ✅ Recent matches for scrolling test:');
      for (var match in matches.take(3)) {
        final score = '${match['player1_score'] ?? '?'}-${match['player2_score'] ?? '?'}';
        print('      • ${match['status']} match: $score');
      }
    } else {
      print('   ❌ MISSING: Need more match history for UI testing');
    }
    
    print('\n🤝 SOCIAL SCREENS:');
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
        .select('*')
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    
    print('   ✅ Followers: ${followers.count}');
    print('   ✅ Following: ${following.count}');
    print('   ✅ Posts: ${posts.length}');
    
    print('\n🏆 TOURNAMENT SCREEN:');
    final tournamentParticipations = await supabase
        .from('tournament_participants')
        .select('*')
        .eq('user_id', userId);
    
    print('   ${tournamentParticipations.isNotEmpty ? '✅' : '❌'} Participations: ${tournamentParticipations.length}');
    if (tournamentParticipations.isEmpty) {
      print('   ❌ MISSING: Not joined any tournaments');
    }
    
    print('\n🏛️ CLUB SCREEN:');
    final clubMemberships = await supabase
        .from('club_members')
        .select('*')
        .eq('user_id', userId);
    
    print('   ${clubMemberships.isNotEmpty ? '✅' : '❌'} Memberships: ${clubMemberships.length}');
    if (clubMemberships.isEmpty) {
      print('   ❌ MISSING: Not member of any clubs');
    }
    
    print('\n🏅 ACHIEVEMENT SCREEN:');
    final achievements = await supabase
        .from('user_achievements')
        .select('*')
        .eq('user_id', userId);
    
    print('   ${achievements.isNotEmpty ? '✅' : '❌'} Unlocked: ${achievements.length}');
    if (achievements.isEmpty) {
      print('   ❌ MISSING: No achievements unlocked');
    }
    
    print('\n📊 UI TESTING READINESS:');
    final readyScreens = [];
    final missingScreens = [];
    
    if (user['bio'] != null) {
      readyScreens.add('Profile (complete)');
    } else {
      missingScreens.add('Profile (missing bio)');
    }
    
    if (matches.isNotEmpty) {
      readyScreens.add('Matches');
    } else {
      missingScreens.add('Matches');
    }
    
    if (followers.count > 0 && posts.isNotEmpty) {
      readyScreens.add('Social');
    } else {
      missingScreens.add('Social');
    }
    
    if (tournamentParticipations.isNotEmpty) {
      readyScreens.add('Tournaments');
    } else {
      missingScreens.add('Tournaments');
    }
    
    if (clubMemberships.isNotEmpty) {
      readyScreens.add('Clubs');
    } else {
      missingScreens.add('Clubs');
    }
    
    if (achievements.isNotEmpty) {
      readyScreens.add('Achievements');
    } else {
      missingScreens.add('Achievements');
    }
    
    print('\n✅ READY FOR TESTING: ${readyScreens.join(', ')}');
    print('❌ NEED DATA FOR: ${missingScreens.join(', ')}');
    
    print('\n🎯 PRIORITY FIXES FOR COMPLETE UI TESTING:');
    if (user['bio'] == null) print('   1. Add user bio & profile details');
    if (tournamentParticipations.isEmpty) print('   2. Join tournaments');
    if (clubMemberships.isEmpty) print('   3. Join clubs');  
    if (achievements.isEmpty) print('   4. Unlock achievements');
    if (matches.length < 5) print('   5. Add more match history');
    
  } catch (e) {
    print('❌ ERROR: $e');
    exit(1);
  }

  exit(0);
}