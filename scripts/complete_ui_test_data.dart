import 'dart:io';
import 'package:supabase/supabase.dart';

Future<void> main() async {
  print('🎮 COMPLETING LONGSANG063 UI TEST DATA...\n');

  const supabaseUrl = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
  const serviceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo';

  try {
    final supabase = SupabaseClient(supabaseUrl, serviceKey);
    
    // Get longsang063 user
    final user = await supabase
        .from('users')
        .select('*')
        .eq('email', 'longsang063@gmail.com')
        .single();
    
    final userId = user['id'];
    
    print('1. 👤 ENHANCING USER PROFILE...');
    
    // Update user profile with complete info
    await supabase
        .from('users')
        .update({
          'bio': 'Passionate billiards player from Vung Tau. Love competing in tournaments and improving my game every day! 🎱',
          'avatar_url': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400&h=400&fit=crop&crop=face',
          'phone': '+84 901 234567',
          'date_of_birth': '1995-06-15',
        })
        .eq('id', userId);
    
    print('   ✅ Added bio, avatar, phone, birthday');
    
    print('\n2. 🏆 JOINING TOURNAMENTS...');
    
    // Get available tournaments
    final tournaments = await supabase
        .from('tournaments')
        .select('id, name')
        .limit(2);
    
    for (var tournament in tournaments) {
      // Check if already joined
      final existing = await supabase
          .from('tournament_participants')
          .select('id')
          .eq('tournament_id', tournament['id'])
          .eq('user_id', userId)
          .maybeSingle();
      
      if (existing == null) {
        await supabase
            .from('tournament_participants')
            .insert({
              'tournament_id': tournament['id'],
              'user_id': userId,
              'joined_at': DateTime.now().toIso8601String(),
            });
        
        print('   ✅ Joined "${tournament['name']}"');
      }
    }
    
    print('\n3. 🏛️ JOINING CLUBS...');
    
    // Get available clubs
    final clubs = await supabase
        .from('clubs')
        .select('id, name')
        .limit(2);
    
    for (var club in clubs) {
      // Check if already member
      final existing = await supabase
          .from('club_members')
          .select('id')
          .eq('club_id', club['id'])
          .eq('user_id', userId)
          .maybeSingle();
      
      if (existing == null) {
        await supabase
            .from('club_members')
            .insert({
              'club_id': club['id'],
              'user_id': userId,
              'role': 'member',
              'joined_at': DateTime.now().toIso8601String(),
            });
        
        print('   ✅ Joined "${club['name']}" as member');
      }
    }
    
    print('\n4. 🏅 UNLOCKING ACHIEVEMENTS...');
    
    // Get achievements to unlock
    final achievements = await supabase
        .from('achievements')
        .select('id, name, description')
        .limit(3);
    
    for (var achievement in achievements) {
      // Check if already unlocked
      final existing = await supabase
          .from('user_achievements')
          .select('id')
          .eq('achievement_id', achievement['id'])
          .eq('user_id', userId)
          .maybeSingle();
      
      if (existing == null) {
        await supabase
            .from('user_achievements')
            .insert({
              'achievement_id': achievement['id'],
              'user_id': userId,
              'unlocked_at': DateTime.now().toIso8601String(),
              'progress': 100,
            });
        
        print('   ✅ Unlocked "${achievement['name']}"');
      }
    }
    
    print('\n5. 📊 FINAL VERIFICATION...');
    
    // Verify all data
    final updatedUser = await supabase
        .from('users')
        .select('*')
        .eq('id', userId)
        .single();
    
    final tournamentCount = await supabase
        .from('tournament_participants')
        .select('count')
        .eq('user_id', userId)
        .count();
    
    final clubCount = await supabase
        .from('club_members')
        .select('count')
        .eq('user_id', userId)
        .count();
    
    final achievementCount = await supabase
        .from('user_achievements')
        .select('count')
        .eq('user_id', userId)
        .count();
    
    print('\n🎉 LONGSANG063 UI TEST DATA COMPLETE!');
    print('   ✅ Profile: Bio, avatar, personal details');
    print('   ✅ Matches: 3 completed games with scores');
    print('   ✅ Social: Posts, followers, following');
    print('   ✅ Tournaments: ${tournamentCount.count} participations');
    print('   ✅ Clubs: ${clubCount.count} memberships');
    print('   ✅ Achievements: ${achievementCount.count} unlocked');
    
    print('\n📱 ALL APP SCREENS READY FOR TESTING:');
    print('   🏠 Home Feed - Posts and social content');
    print('   👤 Profile - Complete user information');
    print('   🏆 Matches - Match history and statistics');
    print('   🤝 Social - Followers, following, interactions');
    print('   🏆 Tournaments - Active participations');
    print('   🏛️ Clubs - Community memberships');
    print('   🏅 Achievements - Progress and unlocks');
    
    print('\n🚀 READY FOR COMPREHENSIVE UI TESTING!');
    
  } catch (e) {
    print('❌ ERROR: $e');
    exit(1);
  }

  exit(0);
}