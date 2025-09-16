import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  print('🧪 Testing Comment System...\n');

  // Initialize Supabase
  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
  );

  final supabase = Supabase.instance.client;

  try {
    // Test 1: Check if post_comments table exists
    print('1. Checking post_comments table...');
    try {
      final result = await supabase
          .from('post_comments')
          .select('id')
          .limit(1);
      print('✅ post_comments table exists');
    } catch (e) {
      print('❌ post_comments table missing: $e');
      return;
    }

    // Test 2: Check RPC functions exist
    print('\n2. Testing RPC functions...');
    
    // Test create_comment RPC
    try {
      final result = await supabase.rpc('create_comment', params: {
        'post_id': 'test-post-id',
        'content': 'test comment',
      });
      if (result != null) {
        print('✅ create_comment RPC exists');
      }
    } catch (e) {
      print('❌ create_comment RPC missing or failed: $e');
    }

    // Test get_post_comments RPC
    try {
      final result = await supabase.rpc('get_post_comments', params: {
        'post_id': 'test-post-id',
        'limit_count': 10,
        'offset_count': 0,
      });
      if (result != null) {
        print('✅ get_post_comments RPC exists');
      }
    } catch (e) {
      print('❌ get_post_comments RPC missing or failed: $e');
    }

    // Test delete_comment RPC
    try {
      final result = await supabase.rpc('delete_comment', params: {
        'comment_id': 'test-comment-id',
      });
      if (result != null) {
        print('✅ delete_comment RPC exists');
      }
    } catch (e) {
      print('❌ delete_comment RPC missing or failed: $e');
    }

    // Test 3: Check table structure
    print('\n3. Checking table structure...');
    try {
      final result = await supabase
          .from('post_comments')
          .select('id, post_id, user_id, content, created_at, updated_at')
          .limit(1);
      print('✅ Table has correct columns');
    } catch (e) {
      print('❌ Table structure issue: $e');
    }

    // Test 4: Check if posts table exists (for foreign key)
    print('\n4. Checking posts table...');
    try {
      final result = await supabase
          .from('posts')
          .select('id')
          .limit(1);
      print('✅ posts table exists');
    } catch (e) {
      print('❌ posts table missing: $e');
    }

    // Test 5: Check users table (for foreign key)
    print('\n5. Checking users table...');
    try {
      final result = await supabase
          .from('users')
          .select('id')
          .limit(1);
      print('✅ users table exists');
    } catch (e) {
      print('❌ users table missing: $e');
    }

    // Test 6: Check authentication
    print('\n6. Checking authentication...');
    final user = supabase.auth.currentUser;
    if (user != null) {
      print('✅ User authenticated: ${user.email}');
    } else {
      print('❌ No authenticated user');
    }

    print('\n🎉 Comment system test completed!');

  } catch (e) {
    print('❌ Test failed with error: $e');
  }

  exit(0);
}