import 'dart:convert';
import 'dart:io';

void main() async {
  try {
    print('🔍 Checking actual database structure...');
    
    const supabaseUrl = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
    const anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ';
    
    final client = HttpClient();
    
    // 1. Check posts table structure
    print('\n📋 Checking posts table structure:');
    var request = await client.getUrl(Uri.parse('$supabaseUrl/rest/v1/posts?select=*&limit=1'));
    request.headers.set('apikey', anonKey);
    request.headers.set('Authorization', 'Bearer $anonKey');
    
    var response = await request.close();
    var responseBody = await response.transform(utf8.decoder).join();
    
    if (response.statusCode == 200) {
      var posts = jsonDecode(responseBody) as List;
      if (posts.isNotEmpty) {
        print('   Posts table columns: ${posts[0].keys.toList()}');
      } else {
        print('   No posts found to check structure');
      }
    } else {
      print('   Error: ${response.statusCode} - $responseBody');
    }
    
    // 2. Check post_comments table structure
    print('\n💬 Checking post_comments table structure:');
    request = await client.getUrl(Uri.parse('$supabaseUrl/rest/v1/post_comments?select=*&limit=1'));
    request.headers.set('apikey', anonKey);
    request.headers.set('Authorization', 'Bearer $anonKey');
    
    response = await request.close();
    responseBody = await response.transform(utf8.decoder).join();
    
    if (response.statusCode == 200) {
      var comments = jsonDecode(responseBody) as List;
      if (comments.isNotEmpty) {
        print('   Comments table columns: ${comments[0].keys.toList()}');
      } else {
        print('   No comments found to check structure');
      }
    } else {
      print('   Error: ${response.statusCode} - $responseBody');
    }
    
    // 3. Check users table structure
    print('\n👤 Checking users table structure:');
    request = await client.getUrl(Uri.parse('$supabaseUrl/rest/v1/users?select=*&limit=1'));
    request.headers.set('apikey', anonKey);
    request.headers.set('Authorization', 'Bearer $anonKey');
    
    response = await request.close();
    responseBody = await response.transform(utf8.decoder).join();
    
    if (response.statusCode == 200) {
      var users = jsonDecode(responseBody) as List;
      if (users.isNotEmpty) {
        print('   Users table columns: ${users[0].keys.toList()}');
      } else {
        print('   No users found to check structure');
      }
    } else {
      print('   Error: ${response.statusCode} - $responseBody');
    }
    
    // 4. Count total records
    print('\n📊 Record counts:');
    
    // Count posts
    request = await client.getUrl(Uri.parse('$supabaseUrl/rest/v1/posts?select=*'));
    request.headers.set('apikey', anonKey);
    request.headers.set('Authorization', 'Bearer $anonKey');
    response = await request.close();
    responseBody = await response.transform(utf8.decoder).join();
    if (response.statusCode == 200) {
      var posts = jsonDecode(responseBody) as List;
      print('   Total posts: ${posts.length}');
    }
    
    // Count comments
    request = await client.getUrl(Uri.parse('$supabaseUrl/rest/v1/post_comments?select=*'));
    request.headers.set('apikey', anonKey);
    request.headers.set('Authorization', 'Bearer $anonKey');
    response = await request.close();
    responseBody = await response.transform(utf8.decoder).join();
    if (response.statusCode == 200) {
      var comments = jsonDecode(responseBody) as List;
      print('   Total comments: ${comments.length}');
      
      // Show some recent comments
      if (comments.isNotEmpty) {
        print('\n🕒 Recent comments:');
        for (var i = 0; i < 5 && i < comments.length; i++) {
          var comment = comments[i];
          print('   - "${comment['content']}" (Post: ${comment['post_id']})');
        }
      }
    }
    
    // Count users
    request = await client.getUrl(Uri.parse('$supabaseUrl/rest/v1/users?select=*'));
    request.headers.set('apikey', anonKey);
    request.headers.set('Authorization', 'Bearer $anonKey');
    response = await request.close();
    responseBody = await response.transform(utf8.decoder).join();
    if (response.statusCode == 200) {
      var users = jsonDecode(responseBody) as List;
      print('   Total users: ${users.length}');
    }
    
    print('\n✅ Structure check complete!');
    client.close();
    
  } catch (e, stackTrace) {
    print('❌ Error during analysis: $e');
    print('Stack trace: $stackTrace');
  }
}