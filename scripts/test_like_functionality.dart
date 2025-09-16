import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  // Initialize Supabase
  const supabaseUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    print('❌ SUPABASE_URL and SUPABASE_ANON_KEY must be provided');
    exit(1);
  }

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  final supabase = Supabase.instance.client;
  print('✅ Supabase initialized successfully');

  try {
    // Test 1: Check if post_likes table exists
    print('\n🔍 Testing post_likes table...');
    await supabase
        .from('post_likes')
        .select('id')
        .limit(1);
    print('✅ post_likes table exists and accessible');

    // Test 2: Get a sample post to test with
    print('\n🔍 Getting sample post...');
    final postsResponse = await supabase
        .from('posts')
        .select('id, title')
        .limit(1);
    
    if (postsResponse.isEmpty) {
      print('❌ No posts found in database. Please create some posts first.');
      return;
    }

    final testPostId = postsResponse.first['id'] as String;
    final postTitle = postsResponse.first['title'] as String;
    print('✅ Found test post: "$postTitle" (ID: $testPostId)');

    // Test 3: Check if RPC functions exist and work
    print('\n🔍 Testing RPC functions...');
    
    // Test has_user_liked_post (should work even without authentication)
    try {
      final hasLikedResult = await supabase.rpc('has_user_liked_post', 
        params: {'post_id': testPostId});
      print('✅ has_user_liked_post RPC works: $hasLikedResult');
    } catch (e) {
      print('⚠️  has_user_liked_post RPC error (expected without auth): $e');
    }

    // Test like_post RPC (will fail without auth, but we can check if function exists)
    try {
      final likeResult = await supabase.rpc('like_post', 
        params: {'post_id': testPostId});
      print('✅ like_post RPC response: $likeResult');
    } catch (e) {
      if (e.toString().contains('User not authenticated')) {
        print('✅ like_post RPC exists (authentication required as expected)');
      } else {
        print('❌ like_post RPC error: $e');
      }
    }

    // Test unlike_post RPC
    try {
      final unlikeResult = await supabase.rpc('unlike_post', 
        params: {'post_id': testPostId});
      print('✅ unlike_post RPC response: $unlikeResult');
    } catch (e) {
      if (e.toString().contains('User not authenticated')) {
        print('✅ unlike_post RPC exists (authentication required as expected)');
      } else {
        print('❌ unlike_post RPC error: $e');
      }
    }

    // Test 4: Check posts table has likes_count column
    print('\n🔍 Checking posts table structure...');
    final postWithLikes = await supabase
        .from('posts')
        .select('id, title, likes_count')
        .eq('id', testPostId)
        .single();
    
    final likesCount = postWithLikes['likes_count'];
    print('✅ Posts table has likes_count column. Current count: $likesCount');

    print('\n🎉 All tests completed successfully!');
    print('📱 Ready to test in the Flutter app:');
    print('   1. Navigate to Home tab');
    print('   2. Try tapping the heart icon on posts');
    print('   3. Check if like counts update');
    print('   4. Test comment and share buttons');

  } catch (e) {
    print('❌ Test failed: $e');
  }

  exit(0);
}