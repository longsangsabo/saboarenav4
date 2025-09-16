import 'dart:io';
import 'package:supabase/supabase.dart';

Future<void> main() async {
  print('🎯 TESTING SUPABASE AFTER CONFIG UPDATE...\n');

  const supabaseUrl = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
  const anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ';

  try {
    print('📡 Connecting to Supabase...');
    final supabase = SupabaseClient(supabaseUrl, anonKey);
    
    // Test 1: Basic connection và count users
    print('\n1️⃣ Testing basic connection...');
    final usersCount = await supabase.from('users').select('*').count(CountOption.exact);
    print('✅ Users table: ${usersCount.count} records');
    
    // Test 2: Get sample user data
    print('\n2️⃣ Testing user data retrieval...');
    final sampleUsers = await supabase.from('users').select('id, email, display_name, skill_level').limit(3);
    print('✅ Sample users:');
    for (var user in sampleUsers) {
      print('   - ${user['display_name']} (${user['skill_level']})');
    }
    
    // Test 3: Test tournaments table
    print('\n3️⃣ Testing tournaments table...');
    final tournaments = await supabase.from('tournaments').select('id, title').limit(3);
    print('✅ Tournaments: ${tournaments.length} records');
    
    // Test 4: Test clubs table
    print('\n4️⃣ Testing clubs table...');
    final clubs = await supabase.from('clubs').select('id, name').limit(3);
    print('✅ Clubs: ${clubs.length} records');
    
    // Test 5: Test posts table
    print('\n5️⃣ Testing posts table...');
    final posts = await supabase.from('posts').select('id, content').limit(3);
    print('✅ Posts: ${posts.length} records');
    
    print('\n🎉 ALL TESTS PASSED! Database connection is working perfectly!');
    print('\n📋 SUMMARY:');
    print('   ✅ Supabase URL: $supabaseUrl');
    print('   ✅ Authentication: Working');
    print('   ✅ Users table: ${usersCount.count} records');
    print('   ✅ Tournaments: ${tournaments.length} records');
    print('   ✅ Clubs: ${clubs.length} records');
    print('   ✅ Posts: ${posts.length} records');
    
  } catch (e) {
    print('❌ ERROR: $e');
    exit(1);
  }

  print('\n✨ READY FOR APP DEVELOPMENT!');
  exit(0);
}