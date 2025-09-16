import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  try {
    print('🔍 Checking comments with service role...');
    
    // Initialize Supabase with service role key
    const supabaseUrl = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
    const serviceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.Xdx0cK6QJyJq_7kV9FDmcVQ2aVyYJlhN8ZvJXCv8Gmc';
    
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: serviceKey, // Using service key instead of anon key
    );

    final supabase = Supabase.instance.client;
    
    print('\n📊 === DATABASE ANALYSIS ===');
    
    // 1. Check total comments
    final totalCommentsResponse = await supabase
        .from('post_comments')
        .select('*');
    
    print('📝 Total comments in database: ${totalCommentsResponse.length}');
    
    // 2. Show recent comments
    final recentComments = await supabase
        .from('post_comments')
        .select('id, content, post_id, user_id, created_at, users!inner(full_name)')
        .order('created_at', ascending: false)
        .limit(10);
    
    print('\n🕒 Recent comments:');
    for (var comment in recentComments) {
      print('  - "${comment['content']}" by ${comment['users']['full_name']} at ${comment['created_at']}');
      print('    Post ID: ${comment['post_id']}');
    }
    
    // 3. Check specific post comments
    const testPostId = '1526eb1e-07bd-4c80-bcf3-b104fc5879f8';
    final postComments = await supabase
        .from('post_comments')
        .select('id, content, user_id, created_at, users!inner(full_name)')
        .eq('post_id', testPostId)
        .order('created_at', ascending: false);
    
    print('\n🎯 Comments for test post ($testPostId):');
    if (postComments.isEmpty) {
      print('  ❌ No comments found for this post');
    } else {
      for (var comment in postComments) {
        print('  - "${comment['content']}" by ${comment['users']['full_name']}');
      }
    }
    
    // 4. Test RPC function
    print('\n🔧 Testing get_post_comments RPC function:');
    try {
      final rpcResult = await supabase.rpc('get_post_comments', params: {
        'p_post_id': testPostId,
        'p_limit': 10,
        'p_offset': 0,
      });
      
      print('  ✅ RPC function returned: ${rpcResult.length} comments');
      for (var comment in rpcResult) {
        print('  - RPC: "${comment['content']}" by ${comment['author_name']}');
      }
    } catch (e) {
      print('  ❌ RPC function error: $e');
    }
    
    // 5. Test direct query (what our app should use)
    print('\n🔍 Testing direct query (app method):');
    try {
      final directQuery = await supabase
          .from('post_comments')
          .select('''
            id,
            content,
            created_at,
            updated_at,
            users!inner (
              id,
              full_name,
              avatar_url
            )
          ''')
          .eq('post_id', testPostId)
          .order('created_at', ascending: false)
          .limit(10);
      
      print('  ✅ Direct query returned: ${directQuery.length} comments');
      for (var comment in directQuery) {
        print('  - Direct: "${comment['content']}" by ${comment['users']['full_name']}');
      }
    } catch (e) {
      print('  ❌ Direct query error: $e');
    }
    
    // 6. Check RLS policies
    print('\n🔐 Checking RLS policies:');
    try {
      // This will show us if RLS is blocking our queries
      await supabase.rpc('check_table_policies', params: {
        'table_name': 'post_comments'
      });
      print('  ✅ RLS policies check successful');
    } catch (e) {
      print('  ⚠️  Could not check RLS policies: $e');
    }
    
    // 7. Show all posts to understand the test data
    print('\n📚 Available posts:');
    final posts = await supabase
        .from('posts')
        .select('id, title, created_at')
        .order('created_at', ascending: false)
        .limit(5);
    
    for (var post in posts) {
      print('  - ${post['title']} (${post['id']})');
    }
    
    print('\n✅ Analysis complete!');
    
  } catch (e, stackTrace) {
    print('❌ Error during analysis: $e');
    print('Stack trace: $stackTrace');
  }
  
  exit(0);
}