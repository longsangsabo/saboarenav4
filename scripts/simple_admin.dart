import 'dart:convert';
import 'package:http/http.dart' as http;

/// Simple admin script using HTTP requests to manage Supabase auth
class SimpleSupabaseAdmin {
  static const String supabaseUrl = "https://mogjjvscxjwvhtpkrlqr.supabase.co";
  static const String serviceRoleKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo";

  /// Create user via Supabase Admin API
  static Future<bool> createUser({
    required String email,
    required String password,
  }) async {
    try {
      print('🏗️ Creating user: $email');

      final response = await http.post(
        Uri.parse('$supabaseUrl/auth/v1/admin/users'),
        headers: {
          'Authorization': 'Bearer $serviceRoleKey',
          'Content-Type': 'application/json',
          'apikey': serviceRoleKey,
        },
        body: jsonEncode({
          'email': email,
          'password': password,
          'email_confirm': true,
          'user_metadata': {
            'name': 'Long Sang',
          },
        }),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('✅ User created successfully!');
        print('   ID: ${data['id']}');
        print('   Email: ${data['email']}');
        return true;
      } else {
        print('❌ Failed to create user: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error creating user: $e');
      return false;
    }
  }

  /// List users via Supabase Admin API  
  static Future<void> listUsers() async {
    try {
      print('📋 Listing users...');

      final response = await http.get(
        Uri.parse('$supabaseUrl/auth/v1/admin/users'),
        headers: {
          'Authorization': 'Bearer $serviceRoleKey',
          'apikey': serviceRoleKey,
        },
      );

      print('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final users = data['users'] as List;
        
        print('👥 Total users: ${users.length}');
        for (var user in users) {
          print('  - ${user['email']} (${user['id']})');
          print('    Created: ${user['created_at']}');
          print('    Confirmed: ${user['email_confirmed_at'] != null}');
        }
      } else {
        print('❌ Failed to list users: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Error listing users: $e');
    }
  }
}

void main() async {
  print('🚀 Starting Supabase Admin Operations...');

  // Create the test user
  final created = await SimpleSupabaseAdmin.createUser(
    email: 'longsangsabo@gmail.com',
    password: 'password123',
  );

  if (created) {
    print('\n✅ User creation completed!');
    print('🧪 Test login credentials:');
    print('   Email: longsangsabo@gmail.com');
    print('   Password: password123');
    
    print('\n📋 Current users:');
    await SimpleSupabaseAdmin.listUsers();
  }

  print('\n🎯 Next steps:');
  print('1. Try logging in with the credentials above');
  print('2. Check if the profile screen shows real data');
}