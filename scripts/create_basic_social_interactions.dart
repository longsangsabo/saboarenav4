import 'dart:io';
import 'package:supabase/supabase.dart';

Future<void> main() async {
  print('💬 TẠO BASIC SOCIAL INTERACTIONS CHO APP...\n');

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
    
    int totalComments = 0;
    
    // 4. Tạo comments cho từng post (skip likes vì table không có)
    for (var post in userPosts) {
      print('💬 Adding comments to post: "${post['content'].toString().substring(0, 50)}..."');
      
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
        {
          'post_id': post['id'],
          'user_id': otherUsers[2]['id'],
          'content': 'That club has amazing tables! 👍',
        }
      ];
      
      await supabase.from('comments').insert(commentsToCreate);
      totalComments += commentsToCreate.length;
      
      print('   ✅ Added ${commentsToCreate.length} comments');
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
    
    // 7. Update post comment counts manually
    print('\n📊 UPDATING POST COMMENT COUNTS:');
    for (var post in userPosts) {
      await supabase
          .from('posts')
          .update({'comment_count': 3})
          .eq('id', post['id']);
    }
    print('   ✅ Updated comment counts for all posts');
    
    // 8. Final summary với available data
    print('\n🎉 BASIC SOCIAL INTERACTIONS SUMMARY:');
    
    final followers = await supabase.from('user_follows').select('*').eq('following_id', userId).count(CountOption.exact);
    final following = await supabase.from('user_follows').select('*').eq('follower_id', userId).count(CountOption.exact);
    final totalPosts = await supabase.from('posts').select('*').eq('user_id', userId).count(CountOption.exact);
    
    print('   📊 ${targetUser['display_name']} SOCIAL STATS:');
    print('      📝 Own Posts: ${totalPosts.count}');
    print('      💬 Total Comments Received: $totalComments');
    print('      👥 Followers: ${followers.count}');
    print('      👤 Following: ${following.count}');
    print('      📢 Mentioned in: ${mentionPosts.length} posts');
    
    print('\n🚀 BASIC SOCIAL FEATURES READY!');
    print('   ✅ Posts with comments');
    print('   ✅ Mutual following relationships');
    print('   ✅ Social mentions');
    print('   ✅ Foundation for social features');
    
  } catch (e) {
    print('❌ ERROR: $e');
    print('Details: ${e.toString()}');
    exit(1);
  }

  exit(0);
}