import 'package:supabase_flutter/supabase_flutter.dart';

/// Admin script to manage Supabase users directly using service role key
/// This bypasses normal auth restrictions to create/check users
class SupabaseAdmin {
  static late SupabaseClient _adminClient;
  
  // Service role key has full admin privileges
  static const String _supabaseUrl = "https://mogjjvscxjwvhtpkrlqr.supabase.co";
  static const String _serviceRoleKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.GeCJTY2q2tSmEN7SZ7K8zN_k1ti_0KMaWlLBIrJnQ0A";

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: _supabaseUrl,
      anonKey: _serviceRoleKey, // Use service role as anon key for admin access
    );
    
    _adminClient = SupabaseClient(_supabaseUrl, _serviceRoleKey);
    print('🔑 Admin client initialized with service role');
  }

  /// Check if user exists in auth.users table
  static Future<Map<String, dynamic>?> checkUser(String email) async {
    try {
      print('🔍 Checking user: $email');
      
      // Query auth.users table directly (requires service role)
      final response = await _adminClient
          .from('auth.users')
          .select('*')
          .eq('email', email)
          .maybeSingle();
          
      if (response != null) {
        print('✅ User found: ${response['email']} - ID: ${response['id']}');
        print('   Created: ${response['created_at']}');
        print('   Confirmed: ${response['email_confirmed_at'] != null}');
        return response;
      } else {
        print('❌ User not found: $email');
        return null;
      }
    } catch (e) {
      print('❌ Error checking user: $e');
      return null;
    }
  }

  /// Create user directly using admin API
  static Future<bool> createUser({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      print('🏗️ Creating user: $email');
      
      // Create user using admin auth API
      final response = await _adminClient.auth.admin.createUser(
        AdminUserAttributes(
          email: email,
          password: password,
          emailConfirm: true, // Auto-confirm email
          userMetadata: {
            'name': name ?? 'User',
            'created_by': 'admin_script',
          },
        ),
      );
      
      if (response.user != null) {
        print('✅ User created successfully!');
        print('   ID: ${response.user!.id}');
        print('   Email: ${response.user!.email}');
        print('   Confirmed: ${response.user!.emailConfirmedAt != null}');
        return true;
      } else {
        print('❌ Failed to create user - no user in response');
        return false;
      }
    } catch (e) {
      print('❌ Error creating user: $e');
      return false;
    }
  }

  /// List all users (for debugging)
  static Future<void> listAllUsers() async {
    try {
      print('📋 Listing all users...');
      
      final response = await _adminClient.auth.admin.listUsers();
      
      print('👥 Total users: ${response.length}');
      for (var user in response) {
        print('  - ${user.email} (${user.id})');
        print('    Created: ${user.createdAt}');
        print('    Confirmed: ${user.emailConfirmedAt != null}');
      }
    } catch (e) {
      print('❌ Error listing users: $e');
    }
  }

  /// Reset user password
  static Future<bool> resetUserPassword({
    required String email,
    required String newPassword,
  }) async {
    try {
      print('🔑 Resetting password for: $email');
      
      // First get the user
      final users = await _adminClient.auth.admin.listUsers();
      final user = users.firstWhere(
        (u) => u.email == email,
        orElse: () => throw Exception('User not found'),
      );
      
      // Update password
      await _adminClient.auth.admin.updateUserById(
        user.id,
        attributes: AdminUserAttributes(password: newPassword),
      );
      
      print('✅ Password reset successfully for $email');
      return true;
    } catch (e) {
      print('❌ Error resetting password: $e');
      return false;
    }
  }

  /// Delete user (for cleanup)
  static Future<bool> deleteUser(String email) async {
    try {
      print('🗑️ Deleting user: $email');
      
      // First get the user
      final users = await _adminClient.auth.admin.listUsers();
      final user = users.firstWhere(
        (u) => u.email == email,
        orElse: () => throw Exception('User not found'),
      );
      
      // Delete user
      await _adminClient.auth.admin.deleteUser(user.id);
      
      print('✅ User deleted successfully: $email');
      return true;
    } catch (e) {
      print('❌ Error deleting user: $e');
      return false;
    }
  }
}

/// Main function to run admin operations
void main() async {
  try {
    await SupabaseAdmin.initialize();
    
    // Check if longsangsabo@gmail.com exists
    print('\n=== CHECKING USER ===');
    var user = await SupabaseAdmin.checkUser('longsangsabo@gmail.com');
    
    if (user == null) {
      // Create the user
      print('\n=== CREATING USER ===');
      final created = await SupabaseAdmin.createUser(
        email: 'longsangsabo@gmail.com',
        password: 'password123', // Default password
        name: 'Long Sang',
      );
      
      if (created) {
        print('\n=== VERIFYING CREATION ===');
        await SupabaseAdmin.checkUser('longsangsabo@gmail.com');
      }
    } else {
      print('\n=== USER EXISTS - RESETTING PASSWORD ===');
      await SupabaseAdmin.resetUserPassword(
        email: 'longsangsabo@gmail.com',
        newPassword: 'password123',
      );
    }
    
    // List all users for verification
    print('\n=== ALL USERS ===');
    await SupabaseAdmin.listAllUsers();
    
    print('\n✅ Admin operations completed!');
    print('👤 Test login with:');
    print('   Email: longsangsabo@gmail.com');
    print('   Password: password123');
    
  } catch (e) {
    print('💥 Admin script failed: $e');
  }
}