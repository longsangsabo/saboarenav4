// Script để kiểm tra database schema thực tế với service_role key
import 'dart:convert';
import 'dart:io';

void main() async {
  final url = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
  final serviceRoleKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo';

  print('🔍 CHECKING ACTUAL DATABASE SCHEMA');
  print('=' * 50);

  final client = HttpClient();
  
  try {
    // 1. Check tables structure
    print('\n📋 1. Checking all tables:');
    await checkTables(client, url, serviceRoleKey);
    
    // 2. Check posts table specifically
    print('\n📝 2. Checking posts table structure:');
    await checkPostsTable(client, url, serviceRoleKey);
    
    // 3. Check users table structure  
    print('\n👤 3. Checking users table structure:');
    await checkUsersTable(client, url, serviceRoleKey);
    
    // 4. Check foreign key relationships
    print('\n🔗 4. Checking foreign key relationships:');
    await checkForeignKeys(client, url, serviceRoleKey);
    
  } catch (e) {
    print('❌ Error: $e');
  } finally {
    client.close();
  }
}

Future<void> checkTables(HttpClient client, String url, String key) async {
  try {
    final request = await client.getUrl(Uri.parse('$url/rest/v1/'));
    request.headers.set('Authorization', 'Bearer $key');
    request.headers.set('apikey', key);
    
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    if (response.statusCode == 200) {
      // Parse OpenAPI spec to get table info
      final spec = jsonDecode(responseBody);
      final paths = spec['paths'] as Map<String, dynamic>?;
      
      if (paths != null) {
        final tables = paths.keys
            .where((path) => path.startsWith('/') && !path.contains('{'))
            .map((path) => path.substring(1))
            .toList();
        
        print('✅ Available tables:');
        for (final table in tables) {
          print('   - $table');
        }
      }
    } else {
      print('❌ Failed to get tables: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Error checking tables: $e');
  }
}

Future<void> checkPostsTable(HttpClient client, String url, String key) async {
  try {
    // Try to get posts with limit 0 to see structure
    final request = await client.getUrl(Uri.parse('$url/rest/v1/posts?limit=1'));
    request.headers.set('Authorization', 'Bearer $key');
    request.headers.set('apikey', key);
    request.headers.set('Prefer', 'count=exact');
    
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody) as List;
      print('✅ Posts table exists, count: ${response.headers['content-range']?.first ?? 'unknown'}');
      
      if (data.isNotEmpty) {
        print('   Sample columns: ${data.first.keys.toList()}');
      }
    } else {
      print('❌ Posts table issue: ${response.statusCode} - $responseBody');
    }
  } catch (e) {
    print('❌ Error checking posts: $e');
  }
}

Future<void> checkUsersTable(HttpClient client, String url, String key) async {
  try {
    // Check if users table exists
    final request = await client.getUrl(Uri.parse('$url/rest/v1/users?limit=1'));
    request.headers.set('Authorization', 'Bearer $key');
    request.headers.set('apikey', key);
    request.headers.set('Prefer', 'count=exact');
    
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody) as List;
      print('✅ Users table exists, count: ${response.headers['content-range']?.first ?? 'unknown'}');
      
      if (data.isNotEmpty) {
        print('   Sample columns: ${data.first.keys.toList()}');
      }
    } else {
      print('❌ Users table issue: ${response.statusCode} - $responseBody');
      
      // Check if user_profiles exists instead
      await checkUserProfilesTable(client, url, key);
    }
  } catch (e) {
    print('❌ Error checking users: $e');
  }
}

Future<void> checkUserProfilesTable(HttpClient client, String url, String key) async {
  try {
    final request = await client.getUrl(Uri.parse('$url/rest/v1/user_profiles?limit=1'));
    request.headers.set('Authorization', 'Bearer $key');
    request.headers.set('apikey', key);
    
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody) as List;
      print('✅ user_profiles table EXISTS instead!');
      
      if (data.isNotEmpty) {
        print('   Columns: ${data.first.keys.toList()}');
      }
    } else {
      print('❌ user_profiles also not found: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Error checking user_profiles: $e');
  }
}

Future<void> checkForeignKeys(HttpClient client, String url, String key) async {
  try {
    // Try posts with users join
    print('\n🔗 Testing posts -> users relationship:');
    final usersRequest = await client.getUrl(Uri.parse('$url/rest/v1/posts?select=*,users!posts_user_id_fkey(*)&limit=1'));
    usersRequest.headers.set('Authorization', 'Bearer $key');
    usersRequest.headers.set('apikey', key);
    
    final usersResponse = await usersRequest.close();
    final usersBody = await usersResponse.transform(utf8.decoder).join();
    
    if (usersResponse.statusCode == 200) {
      print('✅ posts -> users relationship works!');
    } else {
      print('❌ posts -> users failed: ${usersResponse.statusCode} - $usersBody');
      
      // Try with user_profiles
      print('\n🔗 Testing posts -> user_profiles relationship:');
      final profilesRequest = await client.getUrl(Uri.parse('$url/rest/v1/posts?select=*,user_profiles!posts_user_id_fkey(*)&limit=1'));
      profilesRequest.headers.set('Authorization', 'Bearer $key');
      profilesRequest.headers.set('apikey', key);
      
      final profilesResponse = await profilesRequest.close();
      final profilesBody = await profilesResponse.transform(utf8.decoder).join();
      
      if (profilesResponse.statusCode == 200) {
        print('✅ posts -> user_profiles relationship works!');
      } else {
        print('❌ posts -> user_profiles failed: ${profilesResponse.statusCode} - $profilesBody');
      }
    }
  } catch (e) {
    print('❌ Error checking foreign keys: $e');
  }
}