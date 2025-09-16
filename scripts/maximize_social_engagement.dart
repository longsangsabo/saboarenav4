import 'dart:io';
import 'package:supabase/supabase.dart';

Future<void> main() async {
  print('🎭 TẠO THÊM TƯƠNG TÁC SOCIAL CHO longsang063@gmail.com...\n');

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
        .neq('id', userId);
    
    print('👤 Found ${otherUsers.length} other users\n');
    
    // 3. Tạo posts từ longsang063 comment trên posts của others
    print('💬 1. COMMENT TRÊN POSTS CỦA COMMUNITY:');
    
    final otherPosts = await supabase
        .from('posts')
        .select('id, content, user_id, users(display_name)')
        .neq('user_id', userId)
        .limit(4);
    
    int commentCount = 0;
    for (var post in otherPosts) {
      final authorName = post['users']['display_name'];
      final postContent = post['content'].toString().length > 40 
          ? '${post['content'].toString().substring(0, 40)}...'
          : post['content'].toString();
      
      final supportiveComments = [
        'Amazing skills! Keep it up! 🔥',
        'This is so inspiring! Thanks for sharing 👏',
        'Great technique! I learned a lot from this 📚',
        'Can\'t wait to try this myself! 💪',
        'You\'re getting really good at this! 🎯'
      ];
      
      final randomComment = supportiveComments[commentCount % supportiveComments.length];
      
      await supabase.from('comments').insert([{
        'post_id': post['id'],
        'user_id': userId,
        'content': randomComment,
      }]);
      
      print('   ✅ Commented on $authorName\'s post: "$postContent"');
      print('      💬 "$randomComment"');
      commentCount++;
    }
    
    // 4. Tạo posts từ longsang063 với community engagement
    print('\n📝 2. TẠO ENGAGING POSTS:');
    
    final engagingPosts = [
      {
        'user_id': userId,
        'content': 'Just finished an amazing practice session! Who else is working on their 9-ball game? Tips welcome! 🎱💯',
        'hashtags': ['practice', '9ball', 'tips', 'improvement', 'billiards'],
        'like_count': 15,
        'comment_count': 8,
        'is_public': true
      },
      {
        'user_id': userId,
        'content': 'Shoutout to the SABO Arena community! You guys are awesome 🙌 Love the competitive but friendly atmosphere here!',
        'hashtags': ['community', 'saboarena', 'grateful', 'friendship', 'billiards'],
        'like_count': 22,
        'comment_count': 12,
        'is_public': true
      },
      {
        'user_id': userId,
        'content': 'Anyone up for a friendly match this weekend? Looking to practice before the big tournament! 🏆⚡',
        'hashtags': ['friendlymatch', 'weekend', 'tournament', 'practice', 'challenge'],
        'like_count': 18,
        'comment_count': 15,
        'is_public': true
      }
    ];
    
    await supabase.from('posts').insert(engagingPosts);
    print('   ✅ Created ${engagingPosts.length} engaging posts');
    
    // 5. Tạo responses từ community trên posts mới
    print('\n🗣️  3. TẠO COMMUNITY RESPONSES:');
    
    final newPosts = await supabase
        .from('posts')
        .select('id, content')
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(3);
    
    for (var post in newPosts) {
      final responses = [
        {
          'post_id': post['id'],
          'user_id': otherUsers[0]['id'],
          'content': 'Count me in! I\'m always down for a good match 🎯',
        },
        {
          'post_id': post['id'],
          'user_id': otherUsers[1]['id'],
          'content': 'You\'re improving so fast! Keep up the great work 💪',
        },
        {
          'post_id': post['id'],
          'user_id': otherUsers[2]['id'],
          'content': 'This community is the best! Thanks for being part of it 🤝',
        }
      ];
      
      await supabase.from('comments').insert(responses);
      print('   ✅ Added 3 community responses to latest post');
    }
    
    // 6. Update user activity để realistic hơn
    print('\n📊 4. CẬP NHẬT USER ENGAGEMENT:');
    
    await supabase
        .from('users')
        .update({
          'spa_points': 650, // Tăng từ 450
          'elo_rating': 1250, // Tăng từ 1200
        })
        .eq('id', userId);
    
    print('   ✅ Updated user stats:');
    print('      🏆 SPA Points: 450 → 650 (+200)');
    print('      ⚡ ELO Rating: 1200 → 1250 (+50)');
    
    // 7. Final summary
    print('\n🎉 5. TỔNG KẾT SOCIAL ENGAGEMENT:');
    
    final finalStats = await Future.wait([
      supabase.from('user_follows').select('count').eq('follower_id', userId).count(),
      supabase.from('user_follows').select('count').eq('following_id', userId).count(),
      supabase.from('posts').select('count').eq('user_id', userId).count(),
      supabase.from('comments').select('count').eq('user_id', userId).count(),
    ]);
    
    print('   📊 Enhanced Social Stats:');
    print('      👤 Following: ${finalStats[0].count} users');
    print('      👥 Followers: ${finalStats[1].count} users');
    print('      📝 Total Posts: ${finalStats[2].count}');
    print('      💬 Comments Made: ${finalStats[3].count}');
    print('      🎯 Community Engagement: High');
    print('      🔥 Social Activity: Very Active');
    
    print('\n🚀 SOCIAL INTERACTIONS MAXIMIZED!');
    print('   ✅ Active community participation');
    print('   ✅ Engaging content creation');
    print('   ✅ Supportive community member');
    print('   ✅ High social engagement score');
    print('   ✅ Perfect for app testing!');
    
  } catch (e) {
    print('❌ ERROR: $e');
    print('Details: ${e.toString()}');
    exit(1);
  }

  exit(0);
}