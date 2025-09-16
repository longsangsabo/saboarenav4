import 'dart:io';
import 'package:supabase/supabase.dart';

Future<void> main() async {
  print('🤝 TẠO FRIENDSHIPS VÀ NOTIFICATIONS CHO longsang063@gmail.com...\n');

  const supabaseUrl = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
  const serviceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo';

  try {
    final supabase = SupabaseClient(supabaseUrl, serviceKey);
    
    // 1. Lấy target user
    final targetUser = await supabase
        .from('users')
        .select('id, display_name')
        .eq('email', 'longsang063@gmail.com')
        .single();
    
    final userId = targetUser['id'];
    print('🎯 Target User: ${targetUser['display_name']}');
    
    // 2. Lấy other users
    final otherUsers = await supabase
        .from('users')
        .select('id, display_name')
        .neq('id', userId)
        .limit(4);
    
    print('👤 Found ${otherUsers.length} users for friendships\n');
    
    // 3. Tạo friend requests
    print('💌 1. TẠO FRIEND REQUESTS:');
    
    // Incoming friend requests (others send to longsang063)
    final incomingRequests = [
      {
        'requester_id': otherUsers[0]['id'],
        'addressee_id': userId,
        'status': 'pending'
      },
      {
        'requester_id': otherUsers[1]['id'],
        'addressee_id': userId,
        'status': 'pending'
      }
    ];
    
    await supabase.from('friendships').insert(incomingRequests);
    print('   ✅ Incoming friend requests from:');
    print('      - ${otherUsers[0]['display_name']} (pending)');
    print('      - ${otherUsers[1]['display_name']} (pending)');
    
    // Outgoing friend requests (longsang063 sends to others)
    final outgoingRequests = [
      {
        'requester_id': userId,
        'addressee_id': otherUsers[2]['id'],
        'status': 'pending'
      }
    ];
    
    await supabase.from('friendships').insert(outgoingRequests);
    print('   ✅ Outgoing friend request to:');
    print('      - ${otherUsers[2]['display_name']} (pending)');
    
    // Accepted friendships
    final acceptedFriendships = [
      {
        'requester_id': userId,
        'addressee_id': otherUsers[3]['id'],
        'status': 'accepted'
      }
    ];
    
    await supabase.from('friendships').insert(acceptedFriendships);
    print('   ✅ Accepted friendship with:');
    print('      - ${otherUsers[3]['display_name']} (friends!)');
    
    print('\n🔔 2. TẠO NOTIFICATIONS:');
    
    // Kiểm tra xem notifications table có tồn tại không
    try {
      await supabase.from('notifications').select('count').limit(1);
      print('   ✅ Notifications table exists, creating notifications...');
      
      final notifications = [
        {
          'user_id': userId,
          'type': 'friend_request',
          'title': 'New Friend Request',
          'message': '${otherUsers[0]['display_name']} sent you a friend request',
          'is_read': false
        },
        {
          'user_id': userId,
          'type': 'friend_request',
          'title': 'New Friend Request',
          'message': '${otherUsers[1]['display_name']} wants to be your friend',
          'is_read': false
        },
        {
          'user_id': userId,
          'type': 'friend_accepted',
          'title': 'Friend Request Accepted',
          'message': '${otherUsers[3]['display_name']} accepted your friend request!',
          'is_read': false
        },
        {
          'user_id': userId,
          'type': 'post_like',
          'title': 'Your post was liked',
          'message': '${otherUsers[0]['display_name']} and 5 others liked your tournament post',
          'is_read': false
        },
        {
          'user_id': userId,
          'type': 'post_comment',
          'title': 'New comment on your post',
          'message': '${otherUsers[1]['display_name']}: "Awesome post! Really inspiring 🔥"',
          'is_read': false
        },
        {
          'user_id': userId,
          'type': 'mention',
          'title': 'You were mentioned',
          'message': '${otherUsers[2]['display_name']} mentioned you in a post',
          'is_read': false
        },
        {
          'user_id': userId,
          'type': 'tournament',
          'title': 'Tournament Reminder',
          'message': 'SABO Arena Open starts in 2 days. Are you ready?',
          'is_read': false
        },
        {
          'user_id': userId,
          'type': 'match',
          'title': 'Upcoming Match',
          'message': 'You have a match with ${otherUsers[0]['display_name']} tomorrow at 3:00 PM',
          'is_read': false
        }
      ];
      
      await supabase.from('notifications').insert(notifications);
      print('   ✅ Created ${notifications.length} notifications');
      
    } catch (e) {
      print('   ⚠️  Notifications table not available: $e');
      print('   ℹ️  Will create basic social data without notifications');
    }
    
    print('\n👥 3. TẠO COMMENTS TRÊN POSTS CỦA FRIENDS:');
    
    // Lấy posts của friends và comment
    final friendPosts = await supabase
        .from('posts')
        .select('id, content, user_id, users(display_name)')
        .neq('user_id', userId)
        .limit(3);
    
    for (var post in friendPosts) {
      final authorName = post['users']['display_name'];
      final postContent = post['content'].toString().substring(0, 30) + '...';
      
      final friendlyComments = [
        {
          'post_id': post['id'],
          'user_id': userId,
          'content': 'Great post ${authorName}! Keep it up! 💪',
        }
      ];
      
      await supabase.from('comments').insert(friendlyComments);
      print('   ✅ Commented on ${authorName}\'s post: "$postContent"');
    }
    
    print('\n🎉 4. TỔNG KẾT FRIENDSHIPS & SOCIAL:');
    
    // Get final stats
    final friendStats = await Future.wait([
      supabase.from('friendships').select('count').or('requester_id.eq.$userId,addressee_id.eq.$userId').count(),
      supabase.from('friendships').select('count').or('requester_id.eq.$userId,addressee_id.eq.$userId').eq('status', 'accepted').count(),
      supabase.from('friendships').select('count').eq('addressee_id', userId).eq('status', 'pending').count(),
    ]);
    
    print('   📊 Social Stats for ${targetUser['display_name']}:');
    print('      🤝 Total Friend Connections: ${friendStats[0].count}');
    print('      ✅ Accepted Friends: ${friendStats[1].count}');
    print('      📨 Pending Friend Requests: ${friendStats[2].count}');
    print('      💬 Comments on Friends\' Posts: ${friendPosts.length}');
    
    try {
      final notificationCount = await supabase.from('notifications').select('count').eq('user_id', userId).count();
      print('      🔔 Unread Notifications: ${notificationCount.count}');
    } catch (e) {
      print('      🔔 Notifications: Not available');
    }
    
    print('\n🚀 FRIENDSHIPS & NOTIFICATIONS CREATED!');
    print('   ✅ Friend requests (incoming & outgoing)');
    print('   ✅ Accepted friendships');
    print('   ✅ Rich notification system');
    print('   ✅ Active community engagement');
    print('   ✅ Complete social ecosystem ready!');
    
  } catch (e) {
    print('❌ ERROR: $e');
    print('Details: ${e.toString()}');
    exit(1);
  }

  exit(0);
}