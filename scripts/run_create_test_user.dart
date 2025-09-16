// Script để chạy SQL tạo test user
import 'dart:io';
import 'dart:convert';

void main() async {
  print('🗃️  Running SQL script to create test user...');
  
  // Đọc SQL script
  final sqlFile = File('scripts/create_test_user.sql');
  if (!await sqlFile.exists()) {
    print('❌ SQL file not found: scripts/create_test_user.sql');
    return;
  }
  
  final sqlContent = await sqlFile.readAsString();
  
  // Supabase connection parameters
  final url = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
  final serviceRoleKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo';
  
  final client = HttpClient();
  
  try {
    print('📡 Connecting to Supabase REST API...');
    
    final request = await client.postUrl(Uri.parse('$url/rest/v1/rpc/exec_sql'));
    request.headers.set('Authorization', 'Bearer $serviceRoleKey');
    request.headers.set('apikey', serviceRoleKey);
    request.headers.set('Content-Type', 'application/json');
    
    // Prepare SQL execution
    final body = jsonEncode({
      'sql': sqlContent
    });
    
    request.write(body);
    
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    if (response.statusCode == 200) {
      print('✅ Test user created successfully!');
      print('📊 Response: $responseBody');
    } else {
      print('❌ Failed to create test user: ${response.statusCode}');
      print('📋 Response: $responseBody');
      
      // Try alternative approach using direct table insert
      await _createTestUserDirect(url, serviceRoleKey);
    }
    
  } catch (e) {
    print('❌ Error executing SQL: $e');
    
    // Try alternative approach
    await _createTestUserDirect(url, serviceRoleKey);
  } finally {
    client.close();
  }
}

Future<void> _createTestUserDirect(String url, String serviceRoleKey) async {
  print('\n🔄 Trying direct table insert...');
  
  final client = HttpClient();
  
  try {
    final testUser = {
      'id': '00000000-0000-0000-0000-000000000001',
      'email': 'test@sabo.app',
      'username': 'testuser',
      'display_name': 'Test User',
      'bio': 'Test user for development - Avatar upload testing',
      'rank': 'C',
      'elo_rating': 1200,
      'spa_points': 0,
      'favorite_game': '8-Ball',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
    
    final request = await client.postUrl(Uri.parse('$url/rest/v1/users'));
    request.headers.set('Authorization', 'Bearer $serviceRoleKey');
    request.headers.set('apikey', serviceRoleKey);
    request.headers.set('Content-Type', 'application/json');
    request.headers.set('Prefer', 'return=representation');
    
    request.write(jsonEncode(testUser));
    
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    if (response.statusCode == 201 || response.statusCode == 200) {
      print('✅ Test user created via direct insert!');
    } else {
      print('❌ Direct insert also failed: ${response.statusCode}');
      print('📋 Response: $responseBody');
    }
    
  } catch (e) {
    print('❌ Error with direct insert: $e');
  } finally {
    client.close();
  }
}