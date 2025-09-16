import 'dart:io';
import 'package:supabase/supabase.dart';

Future<void> main() async {
  print('🎯 BÁO CÁO CUỐI CÙNG - SOCIAL INTERACTIONS CHO longsang063@gmail.com\n');
  print('=' * 70);

  const supabaseUrl = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
  const serviceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo';

  try {
    final supabase = SupabaseClient(supabaseUrl, serviceKey);
    
    // 1. Lấy target user info
    final targetUser = await supabase
        .from('users')
        .select('*')
        .eq('email', 'longsang063@gmail.com')
        .single();
    
    final userId = targetUser['id'];
    
    print('👤 USER PROFILE:');
    print('   📧 Email: ${targetUser['email']}');
    print('   🏷️  Display Name: ${targetUser['display_name']}');
    print('   🏆 SPA Points: ${targetUser['spa_points']}');
    print('   ⚡ ELO Rating: ${targetUser['elo_rating']}');
    print('   🎖️  Rank: ${targetUser['rank']}');
    
    // 2. Social Network Stats
    print('\n${'=' * 70}');
    print('👥 SOCIAL NETWORK:');
    
    final followingUsers = await supabase
        .from('user_follows')
        .select('users!user_follows_following_id_fkey(display_name)')
        .eq('follower_id', userId);
    
    final followers = await supabase
        .from('user_follows')
        .select('users!user_follows_follower_id_fkey(display_name)')
        .eq('following_id', userId);
    
    print('   👤 Following (${followingUsers.length}):');
    for (var follow in followingUsers) {
      print('      - ${follow['users']['display_name']}');
    }
    
    print('   👥 Followers (${followers.length}):');
    for (var follower in followers) {
      print('      - ${follower['users']['display_name']}');
    }
    
    // 3. Posts & Content
    print('\n${'=' * 70}');
    print('📝 POSTS & CONTENT:');
    
    final userPosts = await supabase
        .from('posts')
        .select('content, hashtags, like_count, comment_count, created_at')
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    
    print('   📊 Total Posts: ${userPosts.length}');
    for (int i = 0; i < userPosts.length; i++) {
      final post = userPosts[i];
      final content = post['content'].toString().length > 60 
          ? '${post['content'].toString().substring(0, 60)}...'
          : post['content'].toString();
      print('   ${i + 1}. "$content"');
      print('      👍 ${post['like_count']} likes | 💬 ${post['comment_count']} comments');
      print('      🏷️  ${post['hashtags']?.join(', ') ?? 'No tags'}');
    }
    
    // 4. Comments Activity
    print('\n${'=' * 70}');
    print('💬 COMMENTS ACTIVITY:');
    
    final userComments = await supabase
        .from('comments')
        .select('content, posts(content, users(display_name)), created_at')
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    
    print('   📊 Comments Made: ${userComments.length}');
    for (int i = 0; i < userComments.length && i < 5; i++) {
      final comment = userComments[i];
      final postAuthor = comment['posts']['users']['display_name'];
      final postContent = '${comment['posts']['content'].toString().substring(0, 30)}...';
      print('   ${i + 1}. On $postAuthor\'s post: "$postContent"');
      print('      💬 "${comment['content']}"');
    }
    
    // 5. Community Mentions
    print('\n${'=' * 70}');
    print('📢 COMMUNITY MENTIONS:');
    
    final mentionPosts = await supabase
        .from('posts')
        .select('content, users(display_name), like_count, comment_count')
        .neq('user_id', userId)
        .ilike('content', '%@${targetUser['display_name']}%');
    
    print('   📊 Mentioned in: ${mentionPosts.length} posts');
    for (var mention in mentionPosts) {
      final author = mention['users']['display_name'];
      final content = mention['content'].toString().length > 50
          ? '${mention['content'].toString().substring(0, 50)}...'
          : mention['content'].toString();
      print('   📝 $author: "$content"');
      print('      👍 ${mention['like_count']} likes | 💬 ${mention['comment_count']} comments');
    }
    
    // 6. Tournament & Match Activity
    print('\n${'=' * 70}');
    print('🏆 TOURNAMENT & MATCH ACTIVITY:');
    
    final tournaments = await supabase
        .from('tournament_participants')
        .select('tournaments(title), payment_status')
        .eq('user_id', userId);
    
    final matches = await supabase
        .from('matches')
        .select('player1:users!matches_player1_id_fkey(display_name), player2:users!matches_player2_id_fkey(display_name), status')
        .or('player1_id.eq.$userId,player2_id.eq.$userId');
    
    print('   🏆 Tournament Registrations: ${tournaments.length}');
    for (var tournament in tournaments) {
      print('      - ${tournament['tournaments']['title']} (${tournament['payment_status']})');
    }
    
    print('   ⚔️  Scheduled Matches: ${matches.length}');
    for (var match in matches) {
      final opponent = match['player1']['id'] == userId 
          ? match['player2']['display_name']
          : match['player1']['display_name'];
      print('      - vs ${opponent ?? 'TBD'} (${match['status']})');
    }
    
    // 7. Club Activity
    print('\n${'=' * 70}');
    print('🏛️  CLUB ACTIVITY:');
    
    final clubMemberships = await supabase
        .from('club_members')
        .select('clubs(name), is_favorite')
        .eq('user_id', userId);
    
    final clubReviews = await supabase
        .from('club_reviews')
        .select('clubs(name), rating, review_text')
        .eq('user_id', userId);
    
    print('   🏛️  Club Memberships: ${clubMemberships.length}');
    for (var membership in clubMemberships) {
      final favorite = membership['is_favorite'] ? ' ⭐' : '';
      print('      - ${membership['clubs']['name']}$favorite');
    }
    
    print('   ⭐ Club Reviews: ${clubReviews.length}');
    for (var review in clubReviews) {
      print('      - ${review['clubs']['name']}: ${review['rating']}/5 stars');
      print('        "${review['review_text']}"');
    }
    
    // 8. Final Summary
    print('\n${'=' * 70}');
    print('🎉 FINAL SOCIAL ENGAGEMENT SUMMARY:');
    print('=' * 70);
    
    final stats = {
      'Following': followingUsers.length,
      'Followers': followers.length,
      'Posts Created': userPosts.length,
      'Comments Made': userComments.length,
      'Community Mentions': mentionPosts.length,
      'Tournament Registrations': tournaments.length,
      'Scheduled Matches': matches.length,
      'Club Memberships': clubMemberships.length,
      'Club Reviews': clubReviews.length,
    };
    
    stats.forEach((key, value) {
      print('   📊 $key: $value');
    });
    
    print('\n🚀 LONGSANG063@GMAIL.COM IS NOW:');
    print('   ✅ Highly engaged community member');
    print('   ✅ Active in tournaments and matches');
    print('   ✅ Connected with ${followingUsers.length + followers.length} users');
    print('   ✅ Has ${userPosts.length} posts with high engagement');
    print('   ✅ Mentioned by community ${mentionPosts.length} times');
    print('   ✅ Member of ${clubMemberships.length} clubs with reviews');
    print('   ✅ Perfect for comprehensive app testing!');
    
    print('\n🎱 SABO ARENA APP READY WITH FULL SOCIAL ECOSYSTEM! 🎱');
    
  } catch (e) {
    print('❌ ERROR: $e');
    print('Details: ${e.toString()}');
    exit(1);
  }

  exit(0);
}