import 'dart:convert';
import 'dart:io';

void main() async {
  const supabaseUrl = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
  const anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ';

  final client = HttpClient();
  
  print('🧪 Testing Like System');
  print('=' * 50);
  
  try {
    // 1. Check post_interactions table structure
    print('\n1. Checking post_interactions table...');
    await checkPostInteractionsTable(client, supabaseUrl, anonKey);
    
    // 2. Check existing likes
    print('\n2. Checking existing likes...');
    await checkExistingLikes(client, supabaseUrl, anonKey);
    
    // 3. Test like creation
    print('\n3. Testing like creation...');
    await testLikeCreation(client, supabaseUrl, anonKey);
    
    // 4. Test like removal
    print('\n4. Testing like removal...');
    await testLikeRemoval(client, supabaseUrl, anonKey);
    
    // 5. Check post like counts
    print('\n5. Checking post like counts...');
    await checkPostLikeCounts(client, supabaseUrl, anonKey);
    
  } catch (e) {
    print('❌ Error: $e');
  } finally {
    client.close();
  }
}

Future<void> checkPostInteractionsTable(HttpClient client, String url, String key) async {
  try {
    final request = await client.getUrl(Uri.parse('$url/rest/v1/post_interactions?limit=1'));
    request.headers.set('Authorization', 'Bearer $key');
    request.headers.set('apikey', key);
    
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody) as List;
      print('✅ post_interactions table exists');
      
      if (data.isNotEmpty) {
        print('   Sample columns: ${data.first.keys.toList()}');
        print('   Sample data: ${data.first}');
      } else {
        print('   Table is empty');
      }
    } else {
      print('❌ post_interactions table issue: ${response.statusCode} - $responseBody');
    }
  } catch (e) {
    print('❌ Error checking post_interactions: $e');
  }
}

Future<void> checkExistingLikes(HttpClient client, String url, String key) async {
  try {
    final request = await client.getUrl(Uri.parse('$url/rest/v1/post_interactions?interaction_type=eq.like&limit=10'));
    request.headers.set('Authorization', 'Bearer $key');
    request.headers.set('apikey', key);
    
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody) as List;
      print('✅ Found ${data.length} existing likes');
      
      for (var like in data) {
        print('   - Post: ${like['post_id']}, User: ${like['user_id']}');
      }
    } else {
      print('❌ Error checking likes: ${response.statusCode} - $responseBody');
    }
  } catch (e) {
    print('❌ Error: $e');
  }
}

Future<void> testLikeCreation(HttpClient client, String url, String key) async {
  try {
    // Get first user and post
    final usersRequest = await client.getUrl(Uri.parse('$url/rest/v1/users?limit=1'));
    usersRequest.headers.set('Authorization', 'Bearer $key');
    usersRequest.headers.set('apikey', key);
    
    final usersResponse = await usersRequest.close();
    final usersBody = await usersResponse.transform(utf8.decoder).join();
    final users = jsonDecode(usersBody) as List;
    
    final postsRequest = await client.getUrl(Uri.parse('$url/rest/v1/posts?limit=1'));
    postsRequest.headers.set('Authorization', 'Bearer $key');
    postsRequest.headers.set('apikey', key);
    
    final postsResponse = await postsRequest.close();
    final postsBody = await postsResponse.transform(utf8.decoder).join();
    final posts = jsonDecode(postsBody) as List;
    
    if (users.isNotEmpty && posts.isNotEmpty) {
      final userId = users.first['id'];
      final postId = posts.first['id'];
      
      print('🧪 Creating like: User $userId -> Post $postId');
      
      // Create like
      final likeRequest = await client.postUrl(Uri.parse('$url/rest/v1/post_interactions'));
      likeRequest.headers.set('Authorization', 'Bearer $key');
      likeRequest.headers.set('apikey', key);
      likeRequest.headers.set('Content-Type', 'application/json');
      
      final likeData = {
        'post_id': postId,
        'user_id': userId,
        'interaction_type': 'like',
      };
      
      likeRequest.write(jsonEncode(likeData));
      
      final likeResponse = await likeRequest.close();
      final likeResponseBody = await likeResponse.transform(utf8.decoder).join();
      
      if (likeResponse.statusCode == 201) {
        print('✅ Like created successfully');
        final responseData = jsonDecode(likeResponseBody);
        print('   Like ID: ${responseData.first['id']}');
      } else {
        print('❌ Like creation failed: ${likeResponse.statusCode} - $likeResponseBody');
      }
    } else {
      print('❌ No users or posts found for testing');
    }
  } catch (e) {
    print('❌ Error creating like: $e');
  }
}

Future<void> testLikeRemoval(HttpClient client, String url, String key) async {
  try {
    // Get first like
    final request = await client.getUrl(Uri.parse('$url/rest/v1/post_interactions?interaction_type=eq.like&limit=1'));
    request.headers.set('Authorization', 'Bearer $key');
    request.headers.set('apikey', key);
    
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody) as List;
      
      if (data.isNotEmpty) {
        final likeId = data.first['id'];
        print('🧪 Removing like: $likeId');
        
        // Delete like
        final deleteRequest = await client.deleteUrl(Uri.parse('$url/rest/v1/post_interactions?id=eq.$likeId'));
        deleteRequest.headers.set('Authorization', 'Bearer $key');
        deleteRequest.headers.set('apikey', key);
        
        final deleteResponse = await deleteRequest.close();
        
        if (deleteResponse.statusCode == 204) {
          print('✅ Like removed successfully');
        } else {
          final deleteBody = await deleteResponse.transform(utf8.decoder).join();
          print('❌ Like removal failed: ${deleteResponse.statusCode} - $deleteBody');
        }
      } else {
        print('⚠️ No likes found to remove');
      }
    }
  } catch (e) {
    print('❌ Error removing like: $e');
  }
}

Future<void> checkPostLikeCounts(HttpClient client, String url, String key) async {
  try {
    final request = await client.getUrl(Uri.parse('$url/rest/v1/posts?select=id,content,like_count&limit=5'));
    request.headers.set('Authorization', 'Bearer $key');
    request.headers.set('apikey', key);
    
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody) as List;
      print('✅ Post like counts:');
      
      for (var post in data) {
        final content = post['content']?.toString().substring(0, 50) ?? 'No content';
        print('   - "${content}..." -> ${post['like_count']} likes');
      }
    } else {
      print('❌ Error checking post counts: ${response.statusCode} - $responseBody');
    }
  } catch (e) {
    print('❌ Error: $e');
  }
}