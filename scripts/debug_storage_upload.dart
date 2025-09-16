import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://mogjjvscxjwvhtpkrlqr.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ',
  );

  final supabase = Supabase.instance.client;

  print('🔍 Debug Storage Upload Issues');
  print('================================');

  // 1. Check authentication
  print('\n1. Authentication Check:');
  final user = supabase.auth.currentUser;
  if (user != null) {
    print('✅ User authenticated: ${user.id}');
    print('   Email: ${user.email}');
    print('   Role: ${user.role}');
  } else {
    print('❌ No authenticated user - this is the problem!');
    print('   Need to login first in the app');
    return;
  }

  // 2. Check if user exists in database
  print('\n2. Database User Check:');
  try {
    final userResponse = await supabase
        .from('users')
        .select('id, email, username, avatar_url')
        .eq('id', user.id)
        .single();
    
    print('✅ User found in database:');
    print('   ID: ${userResponse['id']}');
    print('   Email: ${userResponse['email']}');
    print('   Username: ${userResponse['username']}');
    print('   Avatar URL: ${userResponse['avatar_url']}');
  } catch (e) {
    print('❌ Error fetching user from database: $e');
    print('   This might be the RLS policy issue');
  }

  // 3. Test Storage bucket access
  print('\n3. Storage Bucket Access Test:');
  try {
    final buckets = await supabase.storage.listBuckets();
    print('✅ Available buckets:');
    for (final bucket in buckets) {
      print('   - ${bucket.name} (public: ${bucket.public})');
    }
    
    // Check user-images bucket specifically
    final userImagesBucket = buckets.firstWhere(
      (b) => b.name == 'user-images',
      orElse: () => throw Exception('user-images bucket not found'),
    );
    print('✅ user-images bucket found: public=${userImagesBucket.public}');
  } catch (e) {
    print('❌ Error accessing storage buckets: $e');
  }

  // 4. Test direct user update (simulating what StorageService does)
  print('\n4. Direct User Update Test:');
  try {
    final testUrl = 'https://example.com/test-avatar.png';
    await supabase
        .from('users')
        .update({
          'avatar_url': testUrl,
          'updated_at': DateTime.now().toIso8601String()
        })
        .eq('id', user.id);
    
    print('✅ User update successful');
    
    // Revert the test change
    await supabase
        .from('users')
        .update({
          'avatar_url': null,
          'updated_at': DateTime.now().toIso8601String()
        })
        .eq('id', user.id);
    print('✅ Test change reverted');
  } catch (e) {
    print('❌ Error updating user: $e');
    print('   This confirms the RLS policy issue');
  }

  // 5. Check RLS policies
  print('\n5. RLS Policy Analysis:');
  print('   Current RLS policy for users table:');
  print('   - UPDATE: auth.uid() = id');
  print('   - Your auth.uid(): ${user.id}');
  
  // 6. Suggest solutions
  print('\n6. Potential Solutions:');
  print('   A) Verify authentication state is properly maintained');
  print('   B) Check if user record exists in users table');
  print('   C) Temporarily disable RLS for testing');
  print('   D) Add debug logging to see auth context');
  
  print('\n🔍 Debug complete!');
}