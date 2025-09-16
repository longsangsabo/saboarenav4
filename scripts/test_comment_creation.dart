import 'dart:convert';
import 'dart:io';

void main() async {
  try {
    print('🧪 Testing comment creation directly...');
    
    const supabaseUrl = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
    const anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ';
    
    final client = HttpClient();
    
    // 1. Get first available user
    print('👤 Getting first user...');
    var request = await client.getUrl(Uri.parse('$supabaseUrl/rest/v1/users?select=id,full_name&limit=1'));
    request.headers.set('apikey', anonKey);
    request.headers.set('Authorization', 'Bearer $anonKey');
    
    var response = await request.close();
    var responseBody = await response.transform(utf8.decoder).join();
    
    if (response.statusCode != 200) {
      print('❌ Failed to get users: ${response.statusCode} - $responseBody');
      return;
    }
    
    var users = jsonDecode(responseBody) as List;
    if (users.isEmpty) {
      print('❌ No users found');
      return;
    }
    
    var userId = users[0]['id'];
    var userName = users[0]['full_name'];
    print('✅ Using user: $userName ($userId)');
    
    // 2. Get first available post
    print('📝 Getting first post...');
    request = await client.getUrl(Uri.parse('$supabaseUrl/rest/v1/posts?select=id,content&limit=1'));
    request.headers.set('apikey', anonKey);
    request.headers.set('Authorization', 'Bearer $anonKey');
    
    response = await request.close();
    responseBody = await response.transform(utf8.decoder).join();
    
    if (response.statusCode != 200) {
      print('❌ Failed to get posts: ${response.statusCode} - $responseBody');
      return;
    }
    
    var posts = jsonDecode(responseBody) as List;
    if (posts.isEmpty) {
      print('❌ No posts found');
      return;
    }
    
    var postId = posts[0]['id'];
    var postContent = posts[0]['content'];
    print('✅ Using post: ${postContent.toString().substring(0, 50)}... ($postId)');
    
    // 3. Try to create comment
    print('💬 Creating test comment...');
    request = await client.postUrl(Uri.parse('$supabaseUrl/rest/v1/post_comments'));
    request.headers.set('apikey', anonKey);
    request.headers.set('Authorization', 'Bearer $anonKey');
    request.headers.set('Content-Type', 'application/json');
    request.headers.set('Prefer', 'return=representation');
    
    var commentData = {
      'user_id': userId,
      'post_id': postId,
      'content': 'Test comment from script - ${DateTime.now().toIso8601String()}',
    };
    
    request.write(jsonEncode(commentData));
    response = await request.close();
    responseBody = await response.transform(utf8.decoder).join();
    
    print('🔍 Comment creation response: ${response.statusCode}');
    print('📄 Response body: $responseBody');
    
    if (response.statusCode == 201) {
      print('✅ Comment created successfully!');
      var createdComment = jsonDecode(responseBody);
      print('🎉 Created comment ID: ${createdComment[0]['id']}');
    } else {
      print('❌ Failed to create comment: ${response.statusCode}');
    }
    
    // 4. Check if comment exists now
    print('\n🔄 Checking comments after creation...');
    request = await client.getUrl(Uri.parse('$supabaseUrl/rest/v1/post_comments?select=*'));
    request.headers.set('apikey', anonKey);
    request.headers.set('Authorization', 'Bearer $anonKey');
    
    response = await request.close();
    responseBody = await response.transform(utf8.decoder).join();
    
    if (response.statusCode == 200) {
      var comments = jsonDecode(responseBody) as List;
      print('📊 Total comments now: ${comments.length}');
      
      if (comments.isNotEmpty) {
        print('🕒 Recent comments:');
        for (var comment in comments.take(3)) {
          print('   - "${comment['content']}" (${comment['created_at']})');
        }
      }
    }
    
    client.close();
    
  } catch (e, stackTrace) {
    print('❌ Error: $e');
    print('Stack trace: $stackTrace');
  }
}