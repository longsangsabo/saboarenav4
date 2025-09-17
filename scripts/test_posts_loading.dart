import 'package:sabo_arena/services/supabase_service.dart';
import 'package:sabo_arena/services/post_repository.dart';

void main() async {
  try {
    print('🔄 Testing PostRepository.getPosts()...');
    
    // Initialize Supabase
    await SupabaseService.initialize();
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