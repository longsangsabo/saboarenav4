import 'dart:io';
import 'package:supabase/supabase.dart';

Future<void> main() async {
  print('👥 TĂNG CƯỜNG SOCIAL INTERACTIONS CHO longsang063@gmail.com...\n');

  const supabaseUrl = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
  const serviceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo';

  try {
    final supabase = SupabaseClient(supabaseUrl, serviceKey);
    
    // 1. Lấy target user
    final targetUser = await supabase
        .from('users')
        .select('id, display_name, email')
        .eq('email', 'longsang063@gmail.com')
        .single();
    
    final userId = targetUser['id'];
    print('🎯 Target User: ${targetUser['display_name']} (${targetUser['email']})');
    
    // 2. Lấy tất cả users khác
    final allOtherUsers = await supabase
        .from('users')
        .select('id, display_name')
        .neq('id', userId);
    
    print('👤 Found ${allOtherUsers.length} other users for interactions\n');
    
    // 3. Tạo thêm follows - longsang063 follow thêm users
    print('🔄 1. TẠO THÊM FOLLOWS:');
    
    // Kiểm tra follows hiện tại
    final currentFollowing = await supabase
        .from('user_follows')
        .select('following_id')
        .eq('follower_id', userId);
    
    final alreadyFollowing = currentFollowing.map((f) => f['following_id']).toSet();
    final usersToFollow = allOtherUsers.where((user) => !alreadyFollowing.contains(user['id'])).take(3).toList();
    
    if (usersToFollow.isNotEmpty) {
      final newFollows = usersToFollow.map((user) => {
        'follower_id': userId,
        'following_id': user['id']
      }).toList();
      
      await supabase.from('user_follows').insert(newFollows);
      
      print('   ✅ longsang063 now follows:');
      for (var user in usersToFollow) {
        print('      - ${user['display_name']}');
      }
    } else {
      print('   ℹ️  Already following all available users');
    }
    
    print('\n👥 2. TẠO MUTUAL FOLLOWS (Others follow back):');
    
    // Tạo mutual follows - other users follow longsang063 back
    final currentFollowers = await supabase
        .from('user_follows')
        .select('follower_id')
        .eq('following_id', userId);
    
    final alreadyFollowers = currentFollowers.map((f) => f['follower_id']).toSet();
    final usersToFollowBack = allOtherUsers.where((user) => !alreadyFollowers.contains(user['id'])).take(4).toList();
    
    if (usersToFollowBack.isNotEmpty) {
      final followBackList = usersToFollowBack.map((user) => {
        'follower_id': user['id'],
        'following_id': userId
      }).toList();
      
      await supabase.from('user_follows').insert(followBackList);
      
      print('   ✅ These users now follow longsang063:');
      for (var user in usersToFollowBack) {
        print('      - ${user['display_name']}');
      }
    } else {
      print('   ℹ️  All users already following back');
    }
    
    print('\n💬 3. TẠO COMMENTS CHO POSTS CỦA LONGSANG063:');
    
    // Lấy posts của longsang063
    final userPosts = await supabase
        .from('posts')
        .select('id, content')
        .eq('user_id', userId);
    
    // Tạo thêm comments cho mỗi post
    for (var post in userPosts) {
      final postContent = '${post['content'].toString().substring(0, 30)}...';
      print('   📝 Adding comments to: "$postContent"');
      
      final newComments = [
        {
          'post_id': post['id'],
          'user_id': allOtherUsers[0]['id'],
          'content': 'Awesome post! Really inspiring 🔥',
        },
        {
          'post_id': post['id'],
          'user_id': allOtherUsers[1]['id'],
          'content': 'Thanks for sharing this! 👏',
        },
        {
          'post_id': post['id'],
          'user_id': allOtherUsers[2]['id'],
          'content': 'Can\'t wait to see you play! 🎱',
        }
      ];
      
      await supabase.from('comments').insert(newComments);
      
      // Update comment count
      await supabase
          .from('posts')
          .update({'comment_count': 6}) // 3 old + 3 new
          .eq('id', post['id']);
      
      print('      ✅ Added 3 new comments');
    }
    
    print('\n📝 4. TẠO POSTS MENTION LONGSANG063:');
    
    final mentionPosts = [
      {
        'user_id': allOtherUsers[0]['id'],
        'content': 'Had an amazing practice session with @${targetUser['display_name']} today! This guy is getting really good 🎯🎱',
        'hashtags': ['billiards', 'practice', 'skills', 'longsang063'],
        'like_count': 8,
        'comment_count': 3,
        'is_public': true
      },
      {
        'user_id': allOtherUsers[1]['id'],
        'content': '@${targetUser['display_name']} just joined our club! Welcome to the family 🏠🎱 Looking forward to some great matches!',
        'hashtags': ['welcome', 'newmember', 'billiards', 'club'],
        'like_count': 12,
        'comment_count': 5,
        'is_public': true
      },
      {
        'user_id': allOtherUsers[2]['id'],
        'content': 'Shoutout to @${targetUser['display_name']} for the tournament tips! Really helped improve my game 🙏💪',
        'hashtags': ['thanks', 'improvement', 'tournament', 'tips'],
        'like_count': 6,
        'comment_count': 2,
        'is_public': true
      }
    ];
    
    await supabase.from('posts').insert(mentionPosts);
    print('   ✅ Created ${mentionPosts.length} posts mentioning longsang063');
    
    print('\n🎉 5. TỔNG KẾT SOCIAL INTERACTIONS:');
    
    // Get updated stats
    final finalStats = await Future.wait([
      supabase.from('user_follows').select('count').eq('follower_id', userId).count(),
      supabase.from('user_follows').select('count').eq('following_id', userId).count(),
      supabase.from('posts').select('count').eq('user_id', userId).count(),
      supabase.from('comments').select('count').eq('user_id', userId).count(),
    ]);
    
    print('   📊 Updated Stats for ${targetUser['display_name']}:');
    print('      👤 Following: ${finalStats[0].count} users');
    print('      👥 Followers: ${finalStats[1].count} users');
    print('      📝 Own Posts: ${finalStats[2].count}');
    print('      💬 Comments Made: ${finalStats[3].count}');
    print('      🔥 Mentioned in: ${mentionPosts.length} new posts');
    print('      💯 Total Comments Received: ${userPosts.length * 6} on own posts');
    
    print('\n🚀 SOCIAL INTERACTIONS ENHANCED SUCCESSFULLY!');
    print('   ✅ More follows & followers');
    print('   ✅ Increased engagement on posts');
    print('   ✅ Social mentions from community');
    print('   ✅ Active social presence established');
    
  } catch (e) {
    print('❌ ERROR: $e');
    print('Details: ${e.toString()}');
    exit(1);
  }

  exit(0);
}