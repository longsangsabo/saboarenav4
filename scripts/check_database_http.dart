import 'dart:convert';
import 'dart:io';

void main() async {
  try {
    print('🔍 Checking comments database directly...');
    
    const supabaseUrl = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
    const serviceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.Xdx0cK6QJyJq_7kV9FDmcVQ2aVyYJlhN8ZvJXCv8Gmc';
    
    final client = HttpClient();
    
    print('\n📊 === DATABASE ANALYSIS ===');
    
    // 1. Check total comments
    print('📝 Checking total comments...');
    var request = await client.getUrl(Uri.parse('$supabaseUrl/rest/v1/post_comments?select=*'));
    request.headers.set('apikey', serviceKey);
    request.headers.set('Authorization', 'Bearer $serviceKey');
    
    var response = await request.close();
    var responseBody = await response.transform(utf8.decoder).join();
    print('   Response: $responseBody');
    
    if (response.statusCode == 200) {
      var comments = jsonDecode(responseBody) as List;
      print('   Total comments: ${comments.length}');
    } else {
      print('   Error: ${response.statusCode} - $responseBody');
      return;
    }
    
    // 2. Show recent comments
    print('\n🕒 Recent comments:');
    request = await client.getUrl(Uri.parse('$supabaseUrl/rest/v1/post_comments?select=*,users(full_name)&order=created_at.desc&limit=10'));
    request.headers.set('apikey', serviceKey);
    request.headers.set('Authorization', 'Bearer $serviceKey');
    
    response = await request.close();
    responseBody = await response.transform(utf8.decoder).join();
    var recentComments = jsonDecode(responseBody) as List;
    
    for (var comment in recentComments) {
      var authorName = comment['users']?['full_name'] ?? 'Unknown';
      print('   - "${comment['content']}" by $authorName at ${comment['created_at']}');
      print('     Post ID: ${comment['post_id']}');
    }
    
    // 3. Check specific post comments
    const testPostId = '1526eb1e-07bd-4c80-bcf3-b104fc5879f8';
    print('\n🎯 Comments for test post ($testPostId):');
    request = await client.getUrl(Uri.parse('$supabaseUrl/rest/v1/post_comments?post_id=eq.$testPostId&select=*,users(full_name)&order=created_at.desc'));
    request.headers.set('apikey', serviceKey);
    request.headers.set('Authorization', 'Bearer $serviceKey');
    
    response = await request.close();
    responseBody = await response.transform(utf8.decoder).join();
    var postComments = jsonDecode(responseBody) as List;
    
    if (postComments.isEmpty) {
      print('   ❌ No comments found for this post');
    } else {
      for (var comment in postComments) {
        var authorName = comment['users']?['full_name'] ?? 'Unknown';
        print('   - "${comment['content']}" by $authorName');
      }
    }
    
    // 4. Test RPC function
    print('\n🔧 Testing get_post_comments RPC function:');
    try {
      request = await client.postUrl(Uri.parse('$supabaseUrl/rest/v1/rpc/get_post_comments'));
      request.headers.set('apikey', serviceKey);
      request.headers.set('Authorization', 'Bearer $serviceKey');
      request.headers.set('Content-Type', 'application/json');
      
      var requestBody = jsonEncode({
        'p_post_id': testPostId,
        'p_limit': 10,
        'p_offset': 0,
      });
      
      request.write(requestBody);
      response = await request.close();
      responseBody = await response.transform(utf8.decoder).join();
      
      if (response.statusCode == 200) {
        var rpcResult = jsonDecode(responseBody) as List;
        print('   ✅ RPC function returned: ${rpcResult.length} comments');
        for (var comment in rpcResult) {
          print('   - RPC: "${comment['content']}" by ${comment['author_name']}');
        }
      } else {
        print('   ❌ RPC function error: ${response.statusCode} - $responseBody');
      }
    } catch (e) {
      print('   ❌ RPC function error: $e');
    }
    
    // 5. Show all posts to understand the test data
    print('\n📚 Available posts:');
    request = await client.getUrl(Uri.parse('$supabaseUrl/rest/v1/posts?select=id,title,created_at&order=created_at.desc&limit=5'));
    request.headers.set('apikey', serviceKey);
    request.headers.set('Authorization', 'Bearer $serviceKey');
    
    response = await request.close();
    responseBody = await response.transform(utf8.decoder).join();
    var posts = jsonDecode(responseBody) as List;
    
    for (var post in posts) {
      print('   - ${post['title']} (${post['id']})');
    }
    
    print('\n✅ Analysis complete!');
    client.close();
    
  } catch (e, stackTrace) {
    print('❌ Error during analysis: $e');
    print('Stack trace: $stackTrace');
  }
}