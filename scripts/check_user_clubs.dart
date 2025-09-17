import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://mogjjvscxjwvhtpkrlqr.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ',
  );

  final supabase = Supabase.instance.client;

  try {
    print('🔍 Checking all clubs...');
    
    // Get all clubs
    final clubsResponse = await supabase
        .from('clubs')
        .select('*');
    
    print('📊 Found ${clubsResponse.length} clubs:');
    for (var club in clubsResponse) {
      print('  - ${club['name']} (ID: ${club['id']})');
      print('    Owner ID: ${club['owner_id']}');
      print('    Status: ${club['approval_status']}');
      print('');
    }

    // Get all profiles
    print('🔍 Checking all profiles...');
    final profilesResponse = await supabase
        .from('profiles')
        .select('*');
    
    print('📊 Found ${profilesResponse.length} profiles:');
    for (var profile in profilesResponse) {
      print('  - ${profile['full_name']} (ID: ${profile['id']})');
      print('    Email: ${profile['email']}');
      print('    Role: ${profile['role']}');
      print('');
    }

    // Check specific user (longsang)
    print('🔍 Checking longsang user specifically...');
    final longsangProfile = await supabase
        .from('profiles')
        .select('*')
        .eq('email', 'longsang062003@gmail.com')
        .maybeSingle();
    
    if (longsangProfile != null) {
      print('✅ Found longsang profile:');
      print('  ID: ${longsangProfile['id']}');
      print('  Role: ${longsangProfile['role']}');
      
      // Find clubs owned by longsang
      final ownedClubs = await supabase
          .from('clubs')
          .select('*')
          .eq('owner_id', longsangProfile['id']);
      
      print('  Owned clubs: ${ownedClubs.length}');
      for (var club in ownedClubs) {
        print('    - ${club['name']} (${club['id']})');
      }
    } else {
      print('❌ longsang profile not found');
    }

  } catch (e) {
    print('❌ Error: $e');
  }

  exit(0);
}