import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  try {
    print('🚀 Setting up comments database...');
    
    // Initialize Supabase
    await Supabase.initialize(
      url: 'https://mogjjvscxjwvhtpkrlqr.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ',
    );
    
    final supabase = Supabase.instance.client;
    
    // Test basic connection first
    print('📡 Testing connection...');
    final testResult = await supabase.from('users').select('id').limit(1);
    print('✅ Connection successful');
    
    // Check if post_comments table exists
    print('🔍 Checking if post_comments table exists...');
    try {
      await supabase.from('post_comments').select('id').limit(1);
      print('✅ post_comments table already exists');
    } catch (e) {
      print('ℹ️  post_comments table does not exist, need to create it manually in Supabase Dashboard');
      print('📋 Please run the SQL from create_comments_table.sql in your Supabase SQL Editor');
    }
    
    // Test if comments_count column exists in posts table
    print('🔍 Checking posts table structure...');
    try {
      final postsResult = await supabase.from('posts').select('comments_count').limit(1);
      print('✅ posts.comments_count column exists');
    } catch (e) {
      print('ℹ️  Need to add comments_count column to posts table');
      print('📋 Run: ALTER TABLE posts ADD COLUMN comments_count INTEGER DEFAULT 0;');
    }
    
    print('🎉 Database check completed!');
    print('📝 Manual steps needed:');
    print('   1. Copy content from create_comments_table.sql');
    print('   2. Paste and run in Supabase SQL Editor');
    print('   3. Add comments_count column to posts table if needed');
    
  } catch (e) {
    print('❌ Database setup failed: $e');
  }
}