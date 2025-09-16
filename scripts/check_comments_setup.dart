import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  try {
    print('🔍 Checking comments database setup...');
    
    // Initialize Supabase
    await Supabase.initialize(
      url: 'https://mogjjvscxjwvhtpkrlqr.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ',
    );
    
    final supabase = Supabase.instance.client;
    
    print('📡 Testing connection...');
    
    // Test if post_comments table exists
    try {
      print('🔍 Checking post_comments table...');
      final result = await supabase.from('post_comments').select('id').limit(1);
      print('✅ post_comments table exists');
      print('💾 Current comments: ${result.length}');
    } catch (e) {
      print('❌ post_comments table not found: $e');
      print('📋 Need to run SQL migration first!');
      return;
    }
    
    // Test create_comment RPC function
    try {
      print('🔍 Testing create_comment function...');
      // This should fail with authentication error, which means function exists
      await supabase.rpc('create_comment', params: {
        'post_id': '12345678-1234-1234-1234-123456789012',
        'content': 'Test comment'
      });
    } catch (e) {
      if (e.toString().contains('User not authenticated')) {
        print('✅ create_comment RPC function exists (auth check working)');
      } else if (e.toString().contains('function') && e.toString().contains('does not exist')) {
        print('❌ create_comment RPC function missing');
      } else {
        print('⚠️  create_comment function exists but error: $e');
      }
    }
    
    // Check posts table for comments_count column
    try {
      print('🔍 Checking posts table structure...');
      final posts = await supabase.from('posts').select('id, comments_count').limit(1);
      print('✅ posts.comments_count column exists');
      if (posts.isNotEmpty) {
        print('📊 Sample post comments_count: ${posts.first['comments_count']}');
      }
    } catch (e) {
      if (e.toString().contains('comments_count')) {
        print('❌ Need to add comments_count column to posts table');
        print('📋 Run: ALTER TABLE posts ADD COLUMN comments_count INTEGER DEFAULT 0;');
      } else {
        print('⚠️  Posts table check error: $e');
      }
    }
    
    print('\n🎯 Summary:');
    print('1. If post_comments table missing → Run create_comments_table.sql');
    print('2. If RPC functions missing → Run the RPC part of the SQL');
    print('3. If comments_count missing → Add column to posts table');
    
  } catch (e) {
    print('❌ Connection failed: $e');
  }
}