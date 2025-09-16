import 'package:supabase_flutter/supabase_flutter.dart';

// Quick test script to verify comment system functionality
void main() async {
  try {
    // Initialize Supabase
    await Supabase.initialize(
      url: 'https://mogjjvscxjwvhtpkrlqr.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ',
    );

    final supabase = Supabase.instance.client;
    
    print('🔍 Testing comment system features...\n');
    
    // Test 1: Check if post_comments table exists
    print('1. Checking post_comments table...');
    try {
      final result = await supabase
          .from('post_comments')
          .select('*')
          .limit(1);
      print('✅ post_comments table exists');
    } catch (e) {
      print('❌ post_comments table missing: $e');
      print('📝 Please run the create_comments_table.sql script in Supabase Dashboard');
      return;
    }
    
    // Test 2: Check if get_post_comment_count function exists
    print('\n2. Checking get_post_comment_count RPC function...');
    try {
      final result = await supabase.rpc('get_post_comment_count', params: {
        'post_id': 'test-post-id'
      });
      print('✅ get_post_comment_count function exists');
    } catch (e) {
      print('❌ get_post_comment_count function missing: $e');
    }
    
    // Test 3: Check if get_post_comments function exists
    print('\n3. Checking get_post_comments RPC function...');
    try {
      final result = await supabase.rpc('get_post_comments', params: {
        'post_id': 'test-post-id'
      });
      print('✅ get_post_comments function exists');
    } catch (e) {
      print('❌ get_post_comments function missing: $e');
    }
    
    // Test 4: Test comment creation (with actual post)
    print('\n4. Testing comment creation...');
    try {
      // Get a real post first
      final posts = await supabase
          .from('posts')
          .select('id')
          .limit(1);
      
      if (posts.isNotEmpty) {
        final postId = posts.first['id'];
        print('📝 Using post ID: $postId');
        
        // Try to create a test comment
        final comment = await supabase
            .from('post_comments')
            .insert({
              'post_id': postId,
              'user_id': '123e4567-e89b-12d3-a456-426614174000', // Mock user ID
              'content': 'Test comment from script',
            })
            .select()
            .single();
        
        print('✅ Comment created successfully: ${comment['id']}');
        
        // Clean up - delete the test comment
        await supabase
            .from('post_comments')
            .delete()
            .eq('id', comment['id']);
        print('🧹 Test comment cleaned up');
        
      } else {
        print('⚠️ No posts found to test comment creation');
      }
    } catch (e) {
      print('❌ Comment creation failed: $e');
    }
    
    print('\n🎉 Comment system test completed!');
    print('📱 You can now test all features in the app:');
    print('   • Create comments with optimistic updates');
    print('   • Edit/delete comments with proper permissions');
    print('   • Pull-to-refresh to reload comments');
    print('   • Real-time comment count updates');
    
  } catch (e) {
    print('❌ Setup error: $e');
  }
}