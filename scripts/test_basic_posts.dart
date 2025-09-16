import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  try {
    print('🔧 Initializing Supabase...');
    
    await Supabase.initialize(
      url: 'https://mogjjvscxjwvhtpkrlqr.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ',
    );
    
    print('✅ Supabase initialized');
    
    // Test basic posts query
    final posts = await Supabase.instance.client
        .from('posts')
        .select('''
          id, content, created_at, like_count, comment_count,
          users!posts_user_id_fkey (display_name, username)
        ''')
        .order('created_at', ascending: false)
        .limit(5);
    
    print('📱 Found ${posts.length} posts:');
    for (var post in posts) {
      final user = post['users'] as Map<String, dynamic>?;
      final userName = user?['display_name'] ?? user?['username'] ?? 'Unknown';
      final content = post['content']?.toString().substring(0, 50) ?? '';
      print('   📝 $userName: "$content..."');
      print('      👍 ${post['like_count']} likes, 💬 ${post['comment_count']} comments');
    }
    
    print('\n🎉 Posts query test successful!');
    
  } catch (e, stackTrace) {
    print('❌ Error: $e');
    print('Stack trace: $stackTrace');
  }
}