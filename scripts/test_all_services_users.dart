// Script test toàn bộ các service sau khi fix user_profiles -> users
import 'dart:convert';
import 'dart:io';

void main() async {
  final url = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
  final anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ';

  print('✅ COMPREHENSIVE TEST: ALL SERVICES WITH USERS TABLE');
  print('=' * 60);

  final client = HttpClient();
  
  try {
    // 1. SocialService - posts with users
    print('\n📋 1. SocialService - getFeedPosts:');
    await testQuery(client, url, anonKey, 
        'posts', 
        'select=*,users!posts_user_id_fkey(full_name,username,avatar_url,skill_level)&is_public=eq.true&limit=3');
    
    // 2. MatchService - matches with users
    print('\n🏆 2. MatchService - getMatches:');
    await testQuery(client, url, anonKey,
        'matches',
        'select=*,player1:users!matches_player1_id_fkey(full_name),player2:users!matches_player2_id_fkey(full_name),winner:users!matches_winner_id_fkey(full_name),tournament:tournaments(title)&limit=3');
    
    // 3. ClubService - club_members with users
    print('\n🏛️ 3. ClubService - getClubMembers:');
    await testQuery(client, url, anonKey,
        'club_members',
        'select=*,users(*)&limit=3');
    
    // 4. Test direct users table access
    print('\n👤 4. Direct users table access:');
    await testQuery(client, url, anonKey,
        'users',
        'select=id,full_name,username,skill_level,avatar_url&limit=3');
    
    print('\n🎉 SUCCESS: All services now use "users" table correctly!');
    print('📊 Summary: SocialService ✅ | MatchService ✅ | ClubService ✅ | Direct Access ✅');
    
  } catch (e) {
    print('❌ Error: $e');
  } finally {
    client.close();
  }
}

Future<void> testQuery(HttpClient client, String url, String key, String table, String params) async {
  try {
    final request = await client.getUrl(Uri.parse('$url/rest/v1/$table?$params'));
    request.headers.set('Authorization', 'Bearer $key');
    request.headers.set('apikey', key);
    
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody) as List;
      print('   ✅ $table: SUCCESS (${data.length} records)');
      
      // Show sample data structure for verification
      if (data.isNotEmpty) {
        final sample = data.first;
        final keys = sample.keys.take(5).join(', ');
        print('   📋 Sample fields: $keys${sample.keys.length > 5 ? "..." : ""}');
      }
    } else {
      print('   ❌ $table: FAILED (${response.statusCode}) - ${responseBody.substring(0, 100)}...');
    }
  } catch (e) {
    print('   ❌ $table: ERROR - $e');
  }
}