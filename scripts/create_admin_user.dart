import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Script to create admin user for Sabo Arena
/// Run this with: dart run scripts/create_admin_user.dart
void main() async {
  // Use project values for this setup script
  const supabaseUrl = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
  const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ';

  try {
    
    print('🚀 Creating admin user for Sabo Arena...\n');

    // Admin credentials - Change these!
    const adminEmail = 'admin@saboarena.com';
    const adminPassword = 'SaboAdmin2024!'; // Strong password
    const adminName = 'System Administrator';

    // Headers for API requests
    final headers = {
      'Content-Type': 'application/json',
      'apikey': supabaseAnonKey,
    };

    // 1. Sign up admin user
    print('1. Creating admin account...');
    
    try {
      final signUpResponse = await http.post(
        Uri.parse('$supabaseUrl/auth/v1/signup'),
        headers: headers,
        body: jsonEncode({
          'email': adminEmail,
          'password': adminPassword,
          'data': {
            'full_name': adminName,
            'role': 'admin',
          }
        }),
      );

      if (signUpResponse.statusCode != 200) {
        final error = jsonDecode(signUpResponse.body);
        if (error['msg']?.contains('already been registered') == true) {
          print('⚠️  Admin user already exists, trying to sign in...');
          
          // Try to sign in
          final signInResponse = await http.post(
            Uri.parse('$supabaseUrl/auth/v1/token?grant_type=password'),
            headers: headers,
            body: jsonEncode({
              'email': adminEmail,
              'password': adminPassword,
            }),
          );

          if (signInResponse.statusCode == 200) {
            final signInData = jsonDecode(signInResponse.body);
            final userId = signInData['user']['id'];
            print('   ✅ Signed in as existing admin: $userId');
            
            // Update user profile
            await _updateUserProfile(supabaseUrl, supabaseAnonKey, userId, adminEmail, adminName);
          } else {
            throw Exception('Failed to sign in as admin: ${signInResponse.body}');
          }
        } else {
          throw Exception('Failed to create admin: ${signUpResponse.body}');
        }
      } else {
        final signUpData = jsonDecode(signUpResponse.body);
        print('   📊 Sign up response: $signUpData');
        
        if (signUpData['user'] != null && signUpData['user']['id'] != null) {
          final userId = signUpData['user']['id'];
          print('   ✅ Admin user created: $userId');
          
          // Update user profile
          await _updateUserProfile(supabaseUrl, supabaseAnonKey, userId, adminEmail, adminName);
        } else {
          // User might be created but need confirmation
          print('   ⚠️  User creation successful but may need email confirmation');
          print('   📧 Check your email and confirm the account if needed');
        }
      }

      print('\n🎉 SUCCESS! Admin account setup completed!');
      print('\n📧 Admin Login Credentials:');
      print('   Email: $adminEmail');
      print('   Password: $adminPassword');
      print('\n🔒 SECURITY NOTE: Please change the admin password after first login!');
      print('\n🚀 You can now login to the app with admin credentials and access:');
      print('   • Admin Dashboard');
      print('   • Club Approval Management');
      print('   • System Statistics');
      print('   • Audit Logs');

    } catch (e) {
      throw Exception('Setup failed: $e');
    }

  } catch (e) {
    print('❌ ERROR: $e');
    exit(1);
  }

  exit(0);
}

Future<void> _updateUserProfile(String supabaseUrl, String apiKey, String userId, String email, String fullName) async {
  print('2. Setting up admin profile...');
  
  final headers = {
    'Content-Type': 'application/json',
    'apikey': apiKey,
    'Prefer': 'return=minimal',
  };

  final userProfile = {
    'id': userId,
    'email': email,
    'display_name': 'Admin',
    'full_name': fullName,
    'role': 'admin',
    'skill_level': 'Expert',
    'is_verified': true,
    'is_active': true,
    'created_at': DateTime.now().toIso8601String(),
    'updated_at': DateTime.now().toIso8601String(),
  };

  final response = await http.post(
    Uri.parse('$supabaseUrl/rest/v1/users'),
    headers: headers,
    body: jsonEncode(userProfile),
  );

  if (response.statusCode == 201 || response.statusCode == 200) {
    print('   ✅ Admin profile created/updated');
  } else {
    print('   ⚠️  Profile update response: ${response.statusCode} - ${response.body}');
  }
}
