import 'dart:io';
import 'package:supabase/supabase.dart';

Future<void> main() async {
  print('💬 TẠO SOCIAL INTERACTIONS CHO APP...\n');

  const supabaseUrl = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
  const serviceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo';

  try {
    final supabase = SupabaseClient(supabaseUrl, serviceKey);
    
    // 1. Lấy user info
    final targetUser = await supabase
        .from('users')
        .select('id, display_name')
        .eq('email', 'longsang063@gmail.com')
        .single();
    
    final userId = targetUser['id'];
    print('🎯 Target User: ${targetUser['display_name']}');
    
    // 2. Lấy posts của user
    final userPosts = await supabase
        .from('posts')
        .select('id, content')
        .eq('user_id', userId);
    
    print('📝 Found ${userPosts.length} posts to add interactions');
    
    // 3. Lấy other users để tạo interactions
    final otherUsers = await supabase
        .from('users')
        .select('id, display_name')
        .neq('id', userId);
    
    print('👥 Found ${otherUsers.length} other users for interactions\n');
    
    int totalLikes = 0;
    int totalComments = 0;
    
    // 4. Tạo likes và comments cho từng post
    for (var post in userPosts) {
      print('💝 Adding interactions to post: "${post['content'].toString().substring(0, 50)}..."');
      
      // Randomly select users to like this post
      final usersWhoLike = otherUsers.take(2 + (post['content'].toString().length % 3)).toList();
      
      // Create likes
      final likesToCreate = usersWhoLike.map((user) => {
        'post_id': post['id'],
        'user_id': user['id']
      }).toList();
      
      await supabase.from('post_likes').insert(likesToCreate);
      totalLikes += likesToCreate.length;
      
      // Create comments
      final commentsToCreate = [
        {
          'post_id': post['id'],
          'user_id': otherUsers[0]['id'],
          'content': 'Nice! Looking forward to playing against you! 🎱',
        },
        {
          'post_id': post['id'],
          'user_id': otherUsers[1]['id'],
          'content': 'Good luck in the tournament bro! 💪',
        },
        if (usersWhoLike.length > 2) {
          'post_id': post['id'],
          'user_id': otherUsers[2]['id'],
          'content': 'That club has amazing tables! 👍',
        }
      ];
      
      await supabase.from('comments').insert(commentsToCreate);
      totalComments += commentsToCreate.length;
      
      print('   ✅ Added ${likesToCreate.length} likes and ${commentsToCreate.length} comments');
    }
    
    // 5. Tạo mutual follows (other users follow back)
    print('\n🤝 CREATING MUTUAL FOLLOWS:');
    final currentFollowing = await supabase
        .from('user_follows')
        .select('following_id')
        .eq('follower_id', userId);
    
    final mutualFollowsToCreate = currentFollowing.map((follow) => {
      'follower_id': follow['following_id'],
      'following_id': userId
    }).toList();
    
    await supabase.from('user_follows').insert(mutualFollowsToCreate);
    print('   ✅ Created ${mutualFollowsToCreate.length} mutual follows');
    
    // 6. Tạo một số posts từ other users mention longsang063
    print('\n📢 CREATING POSTS MENTIONING USER:');
    final mentionPostsToCreate = [
      {
        'user_id': otherUsers[0]['id'],
        'content': 'Just played a great match with @${targetUser['display_name']}! Really impressed with your skills 🎯',
        'post_type': 'text',
        'hashtags': ['billiards', 'goodgame', 'respect'],
        'like_count': 3,
        'comment_count': 1,
        'is_public': true
      },
      {
        'user_id': otherUsers[1]['id'],
        'content': 'See you at Winter Championship @${targetUser['display_name']}! May the best player win 🏆',
        'post_type': 'text',
        'hashtags': ['tournament', 'winterchampionship', 'competition'],
        'like_count': 5,
        'comment_count': 2,
        'is_public': true
      }
    ];
    
    final mentionPosts = await supabase
        .from('posts')
        .insert(mentionPostsToCreate)
        .select();
    
    print('   ✅ Created ${mentionPosts.length} posts mentioning user');
    
    // 7. Tạo notifications cho user
    print('\n🔔 CREATING NOTIFICATIONS:');
    final notificationsToCreate = [
      {
        'user_id': userId,
        'type': 'like',
        'title': 'New likes on your post',
        'message': '${otherUsers[0]['display_name']} and ${totalLikes - 1} others liked your post',
        'is_read': false
      },
      {
        'user_id': userId,
        'type': 'comment',
        'title': 'New comment on your post', 
        'message': '${otherUsers[1]['display_name']}: "Good luck in the tournament bro! 💪"',
        'is_read': false
      },
      {
        'user_id': userId,
        'type': 'follow',
        'title': 'New followers',
        'message': '${otherUsers[2]['display_name']} started following you',
        'is_read': false
      },
      {
        'user_id': userId,
        'type': 'mention',
        'title': 'You were mentioned in a post',
        'message': '${otherUsers[0]['display_name']} mentioned you in their post',
        'is_read': false
      },
      {
        'user_id': userId,
        'type': 'tournament',
        'title': 'Tournament reminder',
        'message': 'Winter Championship 2024 starts in 3 days. Good luck!',
        'is_read': false
      }
    ];
    
    await supabase.from('notifications').insert(notificationsToCreate);
    print('   ✅ Created ${notificationsToCreate.length} notifications');
    
    // 8. Final comprehensive summary
    print('\n🎉 SOCIAL INTERACTIONS SUMMARY:');
    
    final finalStats = await Future.wait([
      supabase.from('post_likes').select('*').eq('post_id', userPosts[0]['id']).count(CountOption.exact),
      supabase.from('comments').select('*').eq('post_id', userPosts[0]['id']).count(CountOption.exact),
      supabase.from('user_follows').select('*').eq('following_id', userId).count(CountOption.exact),
      supabase.from('notifications').select('*').eq('user_id', userId).count(CountOption.exact),
    ]);
    
    print('   📊 ${targetUser['display_name']} SOCIAL STATS:');
    print('      💝 Total Post Likes: $totalLikes');
    print('      💬 Total Post Comments: $totalComments');
    print('      👥 Followers: ${finalStats[2].count}');
    print('      🔔 Notifications: ${finalStats[3].count}');
    
    print('\n🚀 APP READY FOR SOCIAL FEATURES TESTING!');
    print('   ✅ Posts with likes & comments');
    print('   ✅ Mutual following relationships');
    print('   ✅ Social mentions & interactions');
    print('   ✅ Rich notification history');
    print('   ✅ Complete social ecosystem');
    
  } catch (e) {
    print('❌ ERROR: $e');
    print('Details: ${e.toString()}');
    exit(1);
  }

  exit(0);
}