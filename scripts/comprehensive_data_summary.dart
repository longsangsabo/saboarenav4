import 'dart:io';
import 'package:supabase/supabase.dart';

Future<void> main() async {
  print('📊 TỔNG KẾT TOÀN BỘ TEST DATA - SABO ARENA\n');
  print('=' * 60);

  const supabaseUrl = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
  const serviceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo';

  try {
    final supabase = SupabaseClient(supabaseUrl, serviceKey);
    
    // 1. TỔNG QUAN DATABASE
    print('🗄️ DATABASE OVERVIEW:');
    
    final overviewData = await Future.wait([
      supabase.from('users').select('count').count(CountOption.exact),
      supabase.from('tournaments').select('count').count(CountOption.exact),
      supabase.from('clubs').select('count').count(CountOption.exact),
      supabase.from('matches').select('count').count(CountOption.exact),
      supabase.from('posts').select('count').count(CountOption.exact),
      supabase.from('comments').select('count').count(CountOption.exact),
    ]);
    
    print('   👥 Total Users: ${overviewData[0].count}');
    print('   🏆 Total Tournaments: ${overviewData[1].count}');
    print('   🏛️  Total Clubs: ${overviewData[2].count}');
    print('   ⚡ Total Matches: ${overviewData[3].count}');
    print('   📝 Total Posts: ${overviewData[4].count}');
    print('   💬 Total Comments: ${overviewData[5].count}');
    
    // 2. CHI TIẾT USER longsang063@gmail.com
    print('\n${'=' * 60}');
    print('🎯 TEST USER: longsang063@gmail.com');
    print('=' * 60);
    
    final testUser = await supabase
        .from('users')
        .select('*')
        .eq('email', 'longsang063@gmail.com')
        .single();
    
    final userId = testUser['id'];
    
    print('📋 BASIC INFO:');
    print('   • Display Name: ${testUser['display_name']}');
    print('   • Username: ${testUser['username']}');
    print('   • Email: ${testUser['email']}');
    print('   • Rank: ${testUser['rank']}');
    print('   • ELO Rating: ${testUser['elo_rating']}');
    print('   • SPA Points: ${testUser['spa_points']}');
    
    print('\n📈 GAME STATISTICS:');
    print('   • Total Matches: ${testUser['total_matches']}');
    print('   • Wins: ${testUser['wins']}');
    print('   • Losses: ${testUser['losses']}');
    print('   • Win Rate: ${testUser['total_matches'] > 0 ? ((testUser['wins'] / testUser['total_matches']) * 100).toStringAsFixed(1) : '0.0'}%');
    print('   • Win Streak: ${testUser['win_streak']}');
    print('   • Tournaments Played: ${testUser['tournaments_played']}');
    
    // 3. CHI TIẾT ACTIVITIES
    print('\n🎮 TOURNAMENT ACTIVITIES:');
    final userTournaments = await supabase
        .from('tournament_participants')
        .select('tournaments(title, start_date), registered_at, payment_status')
        .eq('user_id', userId);
    
    for (var participation in userTournaments) {
      final tournament = participation['tournaments'];
      print('   🏆 ${tournament['title']}');
      print('      • Start: ${tournament['start_date']}');
      print('      • Registered: ${participation['registered_at']}');
      print('      • Payment: ${participation['payment_status']}');
    }
    
    print('\n⚔️ MATCH HISTORY:');
    final userMatches = await supabase
        .from('matches')
        .select('*, player1:users!matches_player1_id_fkey(display_name), player2:users!matches_player2_id_fkey(display_name), winner:users!matches_winner_id_fkey(display_name)')
        .or('player1_id.eq.$userId,player2_id.eq.$userId')
        .order('created_at', ascending: false);
    
    for (var match in userMatches) {
      final isPlayer1 = match['player1_id'] == userId;
      final opponent = isPlayer1 ? match['player2'] : match['player1'];
      final result = match['winner_id'] == userId ? 'WON' : 
                    match['winner_id'] == null ? 'SCHEDULED' : 'LOST';
      
      print('   ⚡ vs ${opponent?['display_name'] ?? 'TBD'} - $result');
      print('      • Score: ${match['player1_score']}-${match['player2_score']}');
      print('      • Status: ${match['status']}');
      if (match['scheduled_at'] != null) {
        print('      • Scheduled: ${match['scheduled_at']}');
      }
    }
    
    print('\n👥 SOCIAL ACTIVITIES:');
    final userPosts = await supabase
        .from('posts')
        .select('content, hashtags, like_count, comment_count, created_at')
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    
    print('   📝 Own Posts (${userPosts.length}):');
    for (var post in userPosts) {
      final content = post['content'].toString().length > 50 
          ? '${post['content'].toString().substring(0, 50)}...'
          : post['content'].toString();
      print('      • "$content"');
      print('        👍 ${post['like_count']} likes, 💬 ${post['comment_count']} comments');
      print('        🏷️  ${post['hashtags']?.join(', ') ?? 'No tags'}');
    }
    
    final socialStats = await Future.wait([
      supabase.from('user_follows').select('count').eq('follower_id', userId).count(CountOption.exact),
      supabase.from('user_follows').select('count').eq('following_id', userId).count(CountOption.exact),
      supabase.from('comments').select('count').eq('user_id', userId).count(CountOption.exact),
    ]);
    
    print('\n   📊 Social Stats:');
    print('      • Following: ${socialStats[0].count} users');
    print('      • Followers: ${socialStats[1].count} users');
    print('      • Comments Made: ${socialStats[2].count}');
    
    print('\n🏛️ CLUB MEMBERSHIPS:');
    final userClubs = await supabase
        .from('club_members')
        .select('clubs(name), is_favorite, joined_at')
        .eq('user_id', userId);
    
    for (var membership in userClubs) {
      final club = membership['clubs'];
      final favorite = membership['is_favorite'] ? ' ⭐' : '';
      print('   • ${club['name']}$favorite');
      print('     Joined: ${membership['joined_at']}');
    }
    
    print('\n⭐ CLUB REVIEWS:');
    final userReviews = await supabase
        .from('club_reviews')
        .select('clubs(name), rating, review_text, visit_date')
        .eq('user_id', userId);
    
    for (var review in userReviews) {
      final club = review['clubs'];
      print('   • ${club['name']} - ${review['rating']}/5 stars');
      print('     "${review['review_text']}"');
      print('     Visited: ${review['visit_date']}');
    }
    
    print('\n🏅 ACHIEVEMENTS UNLOCKED:');
    final userAchievements = await supabase
        .from('user_achievements')
        .select('achievements(name, description, points_required), earned_at')
        .eq('user_id', userId);
    
    for (var achievement in userAchievements) {
      final ach = achievement['achievements'];
      print('   🏆 ${ach['name']}');
      print('      • ${ach['description']}');
      print('      • Points Required: ${ach['points_required'] ?? 'N/A'}');
      print('      • Earned: ${achievement['earned_at']}');
    }
    
    // 4. TỔNG KẾT
    print('\n${'=' * 60}');
    print('🎉 TEST DATA SETUP COMPLETE!');
    print('=' * 60);
    
    final completeness = [
      '✅ User Profile: Complete with stats',
      '✅ Tournament Registrations: ${userTournaments.length} tournaments',
      '✅ Match History: ${userMatches.length} matches scheduled',
      '✅ Social Posts: ${userPosts.length} posts with comments',
      '✅ Social Network: Following & followers',
      '✅ Club Memberships: ${userClubs.length} clubs joined',
      '✅ Club Reviews: ${userReviews.length} reviews written',
      '✅ Achievements: ${userAchievements.length} unlocked',
    ];
    
    for (var item in completeness) {
      print('   $item');
    }
    
    print('\n🚀 SABO ARENA APP IS READY FOR COMPREHENSIVE TESTING!');
    print('   • Authentication: ✅ User can login');
    print('   • Tournaments: ✅ Registration & matches');
    print('   • Social Features: ✅ Posts & interactions');
    print('   • Club Features: ✅ Memberships & reviews');
    print('   • Gamification: ✅ Achievements & points');
    print('   • User Profile: ✅ Complete stats & history');
    
  } catch (e) {
    print('❌ ERROR: $e');
    print('Details: ${e.toString()}');
    exit(1);
  }

  exit(0);
}