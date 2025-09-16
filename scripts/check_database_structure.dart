import 'dart:convert';
import 'dart:io';

void main() async {
  try {
    print('🔍 Checking actual database structure...');
    
    const supabaseUrl = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
    const anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ';
    
    final client = HttpClient();
    
    // Check all tables including social features
    final tables = [
      'users', 'profiles', 'user_profiles', 'clubs', 'tournaments', 
      'posts', 'post_comments', 'post_interactions', 'achievements', 'matches', 'user_follows'
    ];
    
    print('\n📊 Database Tables Status:');
    print('=' * 50);
    
    for (final table in tables) {
      try {
        var request = await client.getUrl(Uri.parse('$supabaseUrl/rest/v1/$table?select=*&limit=1'));
        request.headers.set('apikey', anonKey);
        request.headers.set('Authorization', 'Bearer $anonKey');
        
        var response = await request.close();
        var responseBody = await response.transform(utf8.decoder).join();
        
        if (response.statusCode == 200) {
          var data = jsonDecode(responseBody) as List;
          print('✅ $table: EXISTS (${data.length} sample records)');
          if (data.isNotEmpty) {
            print('   Columns: ${data.first.keys.join(', ')}');
          }
        } else {
          print('❌ $table: ERROR ${response.statusCode}');
        }
      } catch (e) {
        print('❌ $table: NOT EXISTS or NO ACCESS');
      }
    }
    
    // Count total records for social features
    print('\n📊 Social Platform Record Counts:');
    
    // Count posts
    var request = await client.getUrl(Uri.parse('$supabaseUrl/rest/v1/posts?select=*'));
    request.headers.set('apikey', anonKey);
    request.headers.set('Authorization', 'Bearer $anonKey');
    var response = await request.close();
    var responseBody = await response.transform(utf8.decoder).join();
    if (response.statusCode == 200) {
      var posts = jsonDecode(responseBody) as List;
      print('   📝 Total posts: ${posts.length}');
    }
    
    // Count comments
    request = await client.getUrl(Uri.parse('$supabaseUrl/rest/v1/post_comments?select=*'));
    request.headers.set('apikey', anonKey);
    request.headers.set('Authorization', 'Bearer $anonKey');
    response = await request.close();
    responseBody = await response.transform(utf8.decoder).join();
    if (response.statusCode == 200) {
      var comments = jsonDecode(responseBody) as List;
      print('   💬 Total comments: ${comments.length}');
      
      // Show some recent comments
      if (comments.isNotEmpty) {
        print('\n🕒 Recent comments:');
        for (var i = 0; i < 3 && i < comments.length; i++) {
          var comment = comments[i];
          print('   - "${comment['content']}" (Post: ${comment['post_id']})');
        }
      }
    }
    
    // Count likes/interactions
    request = await client.getUrl(Uri.parse('$supabaseUrl/rest/v1/post_interactions?select=*'));
    request.headers.set('apikey', anonKey);
    request.headers.set('Authorization', 'Bearer $anonKey');
    response = await request.close();
    responseBody = await response.transform(utf8.decoder).join();
    if (response.statusCode == 200) {
      var likes = jsonDecode(responseBody) as List;
      print('   ❤️  Total likes: ${likes.length}');
    }
    
    // Count users
    request = await client.getUrl(Uri.parse('$supabaseUrl/rest/v1/users?select=*'));
    request.headers.set('apikey', anonKey);
    request.headers.set('Authorization', 'Bearer $anonKey');
    response = await request.close();
    responseBody = await response.transform(utf8.decoder).join();
    if (response.statusCode == 200) {
      var users = jsonDecode(responseBody) as List;
      print('   👤 Total users: ${users.length}');
    }
    
    print('\n✅ Complete social platform structure check finished!');
    client.close();
    
  } catch (e, stackTrace) {
    print('❌ Error during analysis: $e');
    print('Stack trace: $stackTrace');
  }
}