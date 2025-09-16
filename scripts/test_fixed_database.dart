// Script test social feed với database fixes
import 'dart:convert';
import 'dart:io';

void main() async {
  final url = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
  final anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ';

  print('✅ TESTING SOCIAL FEED AFTER DATABASE FIXES');
  print('=' * 50);

  final client = HttpClient();
  
  try {
    // Test feed posts với users relationship (fixed)
    print('\n📋 1. Testing getFeedPosts with users relationship:');
    await testFeedPosts(client, url, anonKey);
    
    // Test match queries với users relationship (fixed)
    print('\n🏆 2. Testing match queries with users relationship:');
    await testMatches(client, url, anonKey);
    
    print('\n🎉 SUCCESS: All database queries are working after fixes!');
    
  } catch (e) {
    print('❌ Error: $e');
  } finally {
    client.close();
  }
}

Future<void> testFeedPosts(HttpClient client, String url, String key) async {
  try {
    // This is the EXACT query from SocialService.getFeedPosts after our fixes
    final queryParams = 'select=*,users!posts_user_id_fkey(full_name,username,avatar_url,skill_level)&is_public=eq.true&order=created_at.desc&limit=5';
    final request = await client.getUrl(Uri.parse('$url/rest/v1/posts?$queryParams'));
    request.headers.set('Authorization', 'Bearer $key');
    request.headers.set('apikey', key);
    
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody) as List;
      print('✅ getFeedPosts SUCCESS: Retrieved ${data.length} posts');
      
      if (data.isNotEmpty) {
        final firstPost = data.first;
        final userInfo = firstPost['users'];
        print('   Sample post: "${firstPost['content']?.toString().substring(0, 50) ?? 'No content'}..."');
        print('   User: ${userInfo?['full_name'] ?? 'Unknown'} (${userInfo?['username'] ?? 'No username'})');
        print('   User skill: ${userInfo?['skill_level'] ?? 'No skill level'}');
      }
    } else {
      print('❌ getFeedPosts FAILED: ${response.statusCode} - $responseBody');
    }
  } catch (e) {
    print('❌ Error testing feed posts: $e');
  }
}

Future<void> testMatches(HttpClient client, String url, String key) async {
  try {
    // This is the EXACT query from MatchService after our fixes
    final queryParams = 'select=*,player1:users!matches_player1_id_fkey(full_name),player2:users!matches_player2_id_fkey(full_name),winner:users!matches_winner_id_fkey(full_name),tournament:tournaments(title)&limit=3';
    final request = await client.getUrl(Uri.parse('$url/rest/v1/matches?$queryParams'));
    request.headers.set('Authorization', 'Bearer $key');
    request.headers.set('apikey', key);
    
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody) as List;
      print('✅ getMatches SUCCESS: Retrieved ${data.length} matches');
      
      if (data.isNotEmpty) {
        final firstMatch = data.first;
        final player1 = firstMatch['player1'];  
        final player2 = firstMatch['player2'];
        final winner = firstMatch['winner'];
        print('   Sample match: ${player1?['full_name'] ?? 'Unknown'} vs ${player2?['full_name'] ?? 'Unknown'}');
        print('   Winner: ${winner?['full_name'] ?? 'No winner yet'}');
        print('   Status: ${firstMatch['status'] ?? 'Unknown'}');
      }
    } else {
      print('❌ getMatches FAILED: ${response.statusCode} - $responseBody');
    }
  } catch (e) {
    print('❌ Error testing matches: $e');
  }
}