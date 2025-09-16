import 'dart:io';
import 'package:supabase/supabase.dart';

Future<void> main() async {
  print('📊 TẠO THÊM DATA TEST CHO longsang063@gmail.com...\n');

  const supabaseUrl = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
  const serviceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo';

  try {
    final supabase = SupabaseClient(supabaseUrl, serviceKey);
    
    // 1. Lấy user info
    final targetUser = await supabase
        .from('users')
        .select('id, display_name, email')
        .eq('email', 'longsang063@gmail.com')
        .single();
    
    final userId = targetUser['id'];
    print('🔍 User: ${targetUser['display_name']} (${targetUser['email']})');
    
    // 2. Tạo social posts
    print('\n📝 1. TẠO SOCIAL POSTS:');
    final postsToCreate = [
      {
        'user_id': userId,
        'content': 'Vừa đăng ký Winter Championship 2024! Ai cũng tham gia thì tag mình nhé 🎱',
        'post_type': 'text',
        'hashtags': ['billiards', 'tournament', 'winterchampionship'],
        'like_count': 5,
        'comment_count': 2,
        'is_public': true
      },
      {
        'user_id': userId,
        'content': 'Practice session tại Golden Billiards Club hôm nay. Cảm giác bàn cơ ở đây rất smooth! 💪',
        'post_type': 'text',
        'hashtags': ['practice', 'billiards', 'goldenbilliards'],
        'like_count': 8,
        'comment_count': 3,
        'is_public': true
      },
      {
        'user_id': userId,
        'content': 'SABO Arena Open đang mở đăng ký! Entry fee chỉ 200k, prize pool 2 triệu. Worth it! 🏆',
        'post_type': 'text',
        'hashtags': ['saboarena', 'tournament', 'billiards', 'competition'],
        'like_count': 12,
        'comment_count': 5,
        'is_public': true
      }
    ];
    
    final insertedPosts = await supabase
        .from('posts')
        .insert(postsToCreate)
        .select();
    
    print('   ✅ Created ${insertedPosts.length} social posts');
    
    // 3. Tạo follows (follow một số users khác)
    print('\n👥 2. TẠO USER FOLLOWS:');
    final otherUsers = await supabase
        .from('users')
        .select('id, display_name')
        .neq('id', userId)
        .limit(3);
    
    final followsToCreate = otherUsers.map((user) => {
      'follower_id': userId,
      'following_id': user['id']
    }).toList();
    
    final insertedFollows = await supabase
        .from('user_follows')
        .insert(followsToCreate)
        .select();
    
    print('   ✅ Now following ${insertedFollows.length} users:');
    for (var user in otherUsers) {
      print('      - ${user['display_name']}');
    }
    
    // 4. Tạo club memberships
    print('\n🏛️  3. THAM GIA CLUBS:');
    final clubs = await supabase
        .from('clubs')
        .select('id, name');
    
    final membershipsToCreate = clubs.map((club) => {
      'club_id': club['id'],
      'user_id': userId,
      'is_favorite': clubs.indexOf(club) == 0 // First club is favorite
    }).toList();
    
    final insertedMemberships = await supabase
        .from('club_members')
        .insert(membershipsToCreate)
        .select();
    
    print('   ✅ Joined ${insertedMemberships.length} clubs:');
    for (var club in clubs) {
      final isFavorite = clubs.indexOf(club) == 0 ? ' ⭐' : '';
      print('      - ${club['name']}$isFavorite');
    }
    
    // 5. Tạo club reviews
    print('\n⭐ 4. TẠO CLUB REVIEWS:');
    final reviewsToCreate = [
      {
        'club_id': clubs[0]['id'],
        'user_id': userId,
        'rating': 5,
        'review_text': 'Excellent club! Professional tables and friendly staff. Highly recommended for serious players.',
        'visit_date': DateTime.now().subtract(Duration(days: 7)).toIso8601String().split('T')[0]
      },
      {
        'club_id': clubs[1]['id'],
        'user_id': userId,
        'rating': 4,
        'review_text': 'Great venue for tournaments. Good facilities and atmosphere.',
        'visit_date': DateTime.now().subtract(Duration(days: 3)).toIso8601String().split('T')[0]
      }
    ];
    
    final insertedReviews = await supabase
        .from('club_reviews')
        .insert(reviewsToCreate)
        .select();
    
    print('   ✅ Created ${insertedReviews.length} club reviews');
    
    // 6. Tạo achievements
    print('\n🏅 5. UNLOCK ACHIEVEMENTS:');
    final achievements = await supabase
        .from('achievements')
        .select('id, name, description')
        .limit(3);
    
    final userAchievementsToCreate = achievements.map((achievement) => {
      'user_id': userId,
      'achievement_id': achievement['id'],
      'earned_at': DateTime.now().subtract(Duration(days: achievements.indexOf(achievement))).toIso8601String()
    }).toList();
    
    final insertedAchievements = await supabase
        .from('user_achievements')
        .insert(userAchievementsToCreate)
        .select();
    
    print('   ✅ Unlocked ${insertedAchievements.length} achievements:');
    for (var achievement in achievements) {
      print('      - ${achievement['name']}: ${achievement['description']}');
    }
    
    // 7. Update user stats để realistic hơn
    print('\n📈 6. CẬP NHẬT USER STATS:');
    await supabase
        .from('users')
        .update({
          'total_wins': 8,
          'total_losses': 3,
          'total_tournaments': 2,
          'ranking_points': 150,
          'spa_points': 450
        })
        .eq('id', userId);
    
    print('   ✅ Updated user statistics:');
    print('      - Win/Loss: 8/3 (72.7% win rate)');
    print('      - Tournaments: 2');
    print('      - Ranking Points: 150');
    print('      - SPA Points: 450');
    
    // 8. Comprehensive summary
    print('\n🎯 7. TỔNG KẾT DATA TEST:');
    
    // Get all data for summary
    final userMatches = await supabase.from('matches').select('*').or('player1_id.eq.$userId,player2_id.eq.$userId').count(CountOption.exact);
    final userPosts = await supabase.from('posts').select('*').eq('user_id', userId).count(CountOption.exact);
    final userFollows = await supabase.from('user_follows').select('*').eq('follower_id', userId).count(CountOption.exact);
    final userTournaments = await supabase.from('tournament_participants').select('*').eq('user_id', userId).count(CountOption.exact);
    final userClubs = await supabase.from('club_members').select('*').eq('user_id', userId).count(CountOption.exact);
    final userReviews = await supabase.from('club_reviews').select('*').eq('user_id', userId).count(CountOption.exact);
    final userAchievements = await supabase.from('user_achievements').select('*').eq('user_id', userId).count(CountOption.exact);
    
    print('   📊 ${targetUser['display_name']} TEST DATA:');
    print('      ✅ Matches: ${userMatches.count}');
    print('      ✅ Tournament Registrations: ${userTournaments.count}');
    print('      ✅ Social Posts: ${userPosts.count}');
    print('      ✅ Following Users: ${userFollows.count}');
    print('      ✅ Club Memberships: ${userClubs.count}');
    print('      ✅ Club Reviews: ${userReviews.count}');
    print('      ✅ Achievements: ${userAchievements.count}');
    print('      ✅ Win Rate: 72.7%');
    print('      ✅ Ranking Points: 150');
    
    print('\n🚀 COMPLETE TEST DATA CREATED!');
    print('   User longsang063@gmail.com is now ready for comprehensive app testing!');
    
  } catch (e) {
    print('❌ ERROR: $e');
    print('Details: ${e.toString()}');
    exit(1);
  }

  exit(0);
}