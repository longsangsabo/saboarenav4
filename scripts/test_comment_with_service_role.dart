import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer';

void main() async {
  try {
    // Initialize Supabase with service role key for admin access
    await Supabase.initialize(
      url: 'https://mogjjvscxjwvhtpkrlqr.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo',
    );
    
    final supabase = Supabase.instance.client;
    
    print('🔍 === CHECKING COMMENT SYSTEM WITH SERVICE ROLE ===');
    
    // 1. Check if comments exist
    print('\n1. Checking existing comments...');
    final existingComments = await supabase
        .from('post_comments')
        .select('id, user_id, post_id, content, created_at')
        .order('created_at', ascending: false)
        .limit(10);
    
    print('📝 Found ${existingComments.length} comments:');
    for (var comment in existingComments) {
      print('   - ${comment['content']} (post: ${comment['post_id']})');
    }
    
    // 2. Check specific post comments
    const testPostId = '1526eb1e-07bd-4c80-bcf3-b104fc5879f8';
    print('\n2. Checking comments for test post: $testPostId');
    
    final postComments = await supabase
        .from('post_comments')
        .select('*, user:users(*)')
        .eq('post_id', testPostId)
        .order('created_at', ascending: false);
        
    print('📝 Found ${postComments.length} comments for this post:');
    for (var comment in postComments) {
      print('   - "${comment['content']}" by ${comment['user']?['full_name'] ?? 'Unknown'}');
    }
    
    // 3. Test RPC function
    print('\n3. Testing get_post_comments RPC function...');
    try {
      final rpcResult = await supabase.rpc('get_post_comments', params: {
        'post_id': testPostId,
        'limit_count': 10,
        'offset_count': 0,
      });
      print('✅ RPC result: $rpcResult');
    } catch (rpcError) {
      print('❌ RPC failed: $rpcError');
    }
    
    // 4. Check users table
    print('\n4. Checking users for comment creation...');
    final users = await supabase
        .from('users')
        .select('id, full_name, email')
        .limit(5);
    
    print('👥 Available users:');
    for (var user in users) {
      print('   - ${user['full_name']} (${user['id']})');
    }
    
    // 5. Test comment creation with service role
    if (users.isNotEmpty) {
      print('\n5. Testing comment creation...');
      final testUserId = users.first['id'];
      
      try {
        final newComment = await supabase
            .from('post_comments')
            .insert({
              'user_id': testUserId,
              'post_id': testPostId,
              'content': 'Test comment from service role - ${DateTime.now().millisecondsSinceEpoch}',
            })
            .select('*, user:users(*)')
            .single();
            
        print('✅ Comment created successfully: ${newComment['content']}');
        
        // 6. Verify comment was saved
        print('\n6. Verifying comment was saved...');
        final verifyComments = await supabase
            .from('post_comments')
            .select('*, user:users(*)')
            .eq('post_id', testPostId)
            .order('created_at', ascending: false)
            .limit(1);
            
        if (verifyComments.isNotEmpty) {
          print('✅ Latest comment verified: ${verifyComments.first['content']}');
        } else {
          print('❌ No comments found after creation');
        }
        
      } catch (createError) {
        print('❌ Comment creation failed: $createError');
      }
    }
    
    print('\n🎯 === COMMENT SYSTEM CHECK COMPLETE ===');
    
  } catch (e) {
    print('❌ Script failed: $e');
  }
}