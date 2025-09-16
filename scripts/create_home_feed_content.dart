import 'dart:io';
import 'dart:math';
import 'package:supabase/supabase.dart';

Future<void> main() async {
  print('🏠 CREATING RICH HOME FEED CONTENT...\n');

  const supabaseUrl = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
  const serviceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo';

  try {
    final supabase = SupabaseClient(supabaseUrl, serviceKey);
    final random = Random();
    
    // Get all users for diverse content
    final allUsers = await supabase
        .from('users')
        .select('id, email, display_name')
        .limit(10);
    
    final longsang = allUsers.firstWhere((u) => u['email'] == 'longsang063@gmail.com');
    final otherUsers = allUsers.where((u) => u['email'] != 'longsang063@gmail.com').toList();
    
    print('👥 Creating home feed content for ${allUsers.length} users...\n');
    
    // Diverse post content types
    final postTypes = [
      {
        'type': 'achievement',
        'templates': [
          '🏆 Vừa unlock achievement "{achievement}" sau {days} ngày cố gắng! #sabo #achievement',
          '🎉 Yes! Đã đạt được "{achievement}" - feeling proud! 💪',
          '⭐ New achievement unlocked: "{achievement}" - ai cũng chúc mừng tôi nhé! 🎊',
        ]
      },
      {
        'type': 'match_result',
        'templates': [
          '🎱 Vừa thắng match {score} - opponent chơi tốt lắm! GG! #billiards #win',
          '💪 Victory! {score} trong trận đấu hôm nay. Feeling good! 🔥',
          '🏆 Another win {score}! Practice makes perfect 🎯 #sabo #victory',
          '😅 Thua {score} hôm nay nhưng learned a lot. Next time! 💪',
        ]
      },
      {
        'type': 'social',
        'templates': [
          '🌟 Chơi billiards thật tuyệt! Ai muốn thách đấu không? 😎',
          '🎱 Sunday practice session - improving my 8-ball game! 💪',
          '🔥 SABO Arena community thật amazing! Love playing here ❤️',
          '😊 Just finished great matches với friends. Billiards is life! 🎯',
          '🎉 Weekend tournament coming up! Who else is joining? 🏆',
        ]
      },
      {
        'type': 'challenge',
        'templates': [
          '⚔️ Looking for worthy opponents! 500 SPA stakes - ai dám? 🔥',
          '🎯 Challenge open: 8-ball race to 7. Stakes: 1000 SPA! 💎',
          '🏆 High stakes match tonight - 2000 SPA on the line! Brave enough?',
          '🤝 Friendly matches welcome! No stakes, just fun billiards 😊',
        ]
      },
      {
        'type': 'tutorial',
        'templates': [
          '💡 Pro tip: Master your break shot for better game control! 🎱',
          '🎯 Bridge technique is key - practice makes perfect! 💪',
          '📚 Studying 9-ball strategies. Knowledge is power! 🧠',
          '⚡ Speed control on shots = more consistent results! 🎱',
        ]
      }
    ];
    
    print('📝 Creating diverse posts...');
    
    int postsCreated = 0;
    
    // Create posts for different users
    for (int i = 0; i < 15; i++) {
      final user = i == 0 ? longsang : otherUsers[random.nextInt(otherUsers.length)];
      final postType = postTypes[random.nextInt(postTypes.length)];
      final templates = postType['templates'] as List<String>;
      final template = templates[random.nextInt(templates.length)];
      
      // Customize template based on type
      String content = template;
      if (postType['type'] == 'achievement') {
        final achievements = ['First Win', 'Win Streak Master', 'Tournament Champion', 'SPA Millionaire'];
        content = content.replaceAll('{achievement}', achievements[random.nextInt(achievements.length)]);
        content = content.replaceAll('{days}', '${random.nextInt(30) + 1}');
      } else if (postType['type'] == 'match_result') {
        final scores = ['7-3', '7-5', '7-2', '7-6', '5-7', '3-7', '8-6', '9-4'];
        content = content.replaceAll('{score}', scores[random.nextInt(scores.length)]);
      }
      
      try {
        final postData = {
          'user_id': user['id'],
          'content': content,
          'created_at': DateTime.now().subtract(Duration(
            hours: random.nextInt(72),
            minutes: random.nextInt(60)
          )).toIso8601String(),
        };
        
        final newPost = await supabase
            .from('posts')
            .insert(postData)
            .select()
            .single();
        
        postsCreated++;
        print('   ✅ ${user['display_name']}: ${postType['type']}');
        
        // Add some immediate comments to make it engaging
        if (random.nextDouble() < 0.7) { // 70% chance of getting comments
          final commentCount = random.nextInt(4) + 1;
          
          for (int j = 0; j < commentCount; j++) {
            final commenter = otherUsers[random.nextInt(otherUsers.length)];
            
            final commentTemplates = [
              'Chúc mừng bạn! 🎉',
              'Tuyệt vời! Keep it up! 💪',
              'Impressive! 👏',
              'GG bro! 🔥',
              'Nice one! 😊',
              'Awesome achievement! ⭐',
              'Thách đấu không? 😎',
              'Respect! 🙌',
              'Amazing play! 🎱',
              'Well done! 👍'
            ];
            
            try {
              await supabase
                  .from('comments')
                  .insert({
                    'post_id': newPost['id'],
                    'user_id': commenter['id'],
                    'content': commentTemplates[random.nextInt(commentTemplates.length)],
                    'created_at': DateTime.now().subtract(Duration(
                      minutes: random.nextInt(60)
                    )).toIso8601String(),
                  });
            } catch (e) {
              // Comment might fail, that's ok
            }
          }
        }
        
      } catch (e) {
        print('   ❌ Error creating post: $e');
      }
    }
    
    print('\n🎯 Creating longsang063 specific content...');
    
    // Create some specific posts for longsang063 to ensure good home feed
    final longsangPosts = [
      {
        'content': '🔥 Vừa thắng SPA challenge 1000 points! Opponent chơi rất hay nhưng hôm nay luck is on my side! 💎 #sabo #victory',
        'type': 'victory'
      },
      {
        'content': '🎱 Practice session hôm nay focus vào bank shots. Getting better every day! 💪 #improvement #billiards',
        'type': 'practice'
      },
      {
        'content': '🏆 Looking forward to weekend tournament! Training hard để defend title 👑 #tournament #ready',
        'type': 'tournament'
      },
      {
        'content': '😊 SABO Arena community thật tuyệt! Met so many great players here. Billiards brings people together ❤️',
        'type': 'community'
      }
    ];
    
    for (final post in longsangPosts) {
      try {
        final newPost = await supabase
            .from('posts')
            .insert({
              'user_id': longsang['id'],
              'content': post['content'],
              'created_at': DateTime.now().subtract(Duration(
                hours: random.nextInt(24),
                minutes: random.nextInt(60)
              )).toIso8601String(),
            })
            .select()
            .single();
        
        postsCreated++;
        print('   ✅ longsang063: ${post['type']}');
        
        // Add engaging comments to longsang's posts
        final commenters = otherUsers.take(3).toList();
        for (final commenter in commenters) {
          final responses = [
            'Chúc mừng anh! 🎉',
            'Thật impressive! 💪',  
            'Thách đấu lần sau nhé! 😎',
            'GG! Well played! 🔥',
            'Awesome! 👏'
          ];
          
          try {
            await supabase
                .from('comments')
                .insert({
                  'post_id': newPost['id'],
                  'user_id': commenter['id'],
                  'content': responses[random.nextInt(responses.length)],
                  'created_at': DateTime.now().subtract(Duration(
                    minutes: random.nextInt(30)
                  )).toIso8601String(),
                });
          } catch (e) {
            // Comment creation might fail
          }
        }
        
      } catch (e) {
        print('   ❌ Error creating longsang post: $e');
      }
    }
    
    print('\n📊 HOME FEED SUMMARY:');
    print('═══════════════════════');
    
    // Get final stats
    final totalPosts = await supabase
        .from('posts')
        .select('count')
        .count();
    
    final totalComments = await supabase
        .from('comments')
        .select('count')
        .count();
    
    final longsangPosts_count = await supabase
        .from('posts')
        .select('count')
        .eq('user_id', longsang['id'])
        .count();
    
    print('📱 HOME TAB CONTENT:');
    print('   📝 Total posts: ${totalPosts.count}');
    print('   💬 Total comments: ${totalComments.count}');
    print('   👤 longsang063 posts: ${longsangPosts_count.count}');
    print('   🎯 Posts created this session: $postsCreated');
    
    print('\n🎮 HOME FEED FEATURES:');
    print('   ✅ Achievement celebrations');
    print('   ✅ Match result sharing');
    print('   ✅ Social interactions');
    print('   ✅ Challenge invitations');
    print('   ✅ Pro tips & tutorials');
    print('   ✅ Community engagement');
    print('   ✅ Active comment threads');
    
    print('\n🏠 HOME TAB READY FOR TESTING!');
    print('   longsang063@gmail.com will see rich social feed');
    print('   với diverse content và active community!');
    
  } catch (e) {
    print('❌ ERROR: $e');
    exit(1);
  }

  exit(0);
}