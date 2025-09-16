import 'dart:io';
import '../lib/services/supabase_service.dart';
import '../lib/services/post_repository.dart';

void main() async {
  try {
    print('🔄 Testing PostRepository.getPosts()...');
    
    // Initialize Supabase
    final supabaseUrl = Platform.environment['SUPABASE_URL'] ?? 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
    final supabaseKey = Platform.environment['SUPABASE_ANON_KEY'] ?? 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ';
    
    await SupabaseService.initialize(supabaseUrl, supabaseKey);
    print('✅ Supabase connected');

    // Test PostRepository
    final postRepository = PostRepository();
    final posts = await postRepository.getPosts(limit: 10);
    
    print('✅ Successfully loaded ${posts.length} posts');
    
    for (int i = 0; i < posts.length && i < 3; i++) {
      final post = posts[i];
      print('   📝 Post ${i + 1}: "${post.content.substring(0, 50)}..."');
      print('      Author: ${post.authorName}');
      print('      Created: ${post.createdAt}');
      print('      Likes: ${post.likeCount}, Comments: ${post.commentCount}');
      print('');
    }
    
    print('🎉 PostRepository test completed successfully!');
    
  } catch (e, stackTrace) {
    print('❌ Error: $e');
    print('Stack trace: $stackTrace');
  }
}