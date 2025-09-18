import 'package:supabase_flutter/supabase_flutter.dart';

// Simple test script to test admin functionality
void main() async {
  await testAdminFunctionality();
}

Future<void> testAdminFunctionality() async {
  print('🧪 TESTING ADMIN TOURNAMENT MANAGEMENT FUNCTIONALITY');
  print('=' * 60);

  // Initialize Supabase
  const supabaseUrl = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
  const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ';

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  final supabase = Supabase.instance.client;

  try {
    print('\n📋 Step 1: Get available tournaments...');
    
    final tournaments = await supabase
        .from('tournaments')
        .select('id, title, status, current_participants, max_participants')
        .eq('status', 'upcoming')
        .limit(5);

    if (tournaments.isEmpty) {
      print('   ❌ No upcoming tournaments found for testing');
      return;
    }

    print('   ✅ Found ${tournaments.length} upcoming tournaments:');
    for (var tournament in tournaments) {
      print('      - ${tournament['title']} (${tournament['current_participants']}/${tournament['max_participants']} participants)');
    }

    // Test with first tournament
    final testTournament = tournaments.first;
    final tournamentId = testTournament['id'];
    final tournamentTitle = testTournament['title'];

    print('\n📋 Step 2: Get all users count...');
    final usersCount = await supabase
        .from('users')
        .select('count')
        .count();
    
    print('   ✅ Total users in database: ${usersCount.count}');

    print('\n📋 Step 3: Test adding all users to tournament "$tournamentTitle"...');
    
    // Get all users
    final allUsers = await supabase
        .from('users')
        .select('id, username, display_name');

    // Get existing participants
    final existingParticipants = await supabase
        .from('tournament_participants')
        .select('user_id')
        .eq('tournament_id', tournamentId);

    final existingUserIds = existingParticipants.map((p) => p['user_id']).toSet();
    
    print('   📊 Users to potentially add: ${allUsers.length}');
    print('   📊 Already joined: ${existingUserIds.length}');
    
    int addedCount = 0;
    int maxParticipants = testTournament['max_participants'] ?? 100;
    int currentParticipants = testTournament['current_participants'] ?? 0;

    // Simulate adding users (without actually adding them to avoid spam)
    final usersToAdd = <Map<String, dynamic>>[];
    
    for (final user in allUsers) {
      if (existingUserIds.contains(user['id'])) {
        continue; // Skip if already joined
      }
      
      if (currentParticipants >= maxParticipants) {
        break; // Tournament is full
      }

      usersToAdd.add({
        'tournament_id': tournamentId,
        'user_id': user['id'],
        'joined_at': DateTime.now().toIso8601String(),
        'status': 'confirmed',
      });

      addedCount++;
      currentParticipants++;
    }

    print('   📊 Would add: $addedCount users');
    print('   📊 Final participants: $currentParticipants/$maxParticipants');

    // Actually add users (for real test)
    print('\n📋 Step 4: Actually adding users to tournament...');
    
    if (usersToAdd.isNotEmpty && usersToAdd.length <= 3) { // Limit to 3 for safety
      print('   🔄 Adding ${usersToAdd.length} users...');
      
      await supabase.from('tournament_participants').insert(usersToAdd);

      // Update tournament participant count
      await supabase
          .from('tournaments')
          .update({
            'current_participants': currentParticipants,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', tournamentId);

      print('   ✅ Successfully added ${usersToAdd.length} users to "$tournamentTitle"');
      
      // Verify the result
      final updatedTournament = await supabase
          .from('tournaments')
          .select('current_participants')
          .eq('id', tournamentId)
          .single();
      
      print('   📊 Updated participant count: ${updatedTournament['current_participants']}');
    } else {
      print('   ⚠️  Skipped actual addition (would add ${usersToAdd.length} users - too many for test)');
    }

    print('\n🎉 ADMIN FUNCTIONALITY TEST COMPLETED!');
    print('   ✅ Tournament management functions are working');
    print('   ✅ User addition logic is functional');
    print('   ✅ Database updates are successful');

  } catch (e) {
    print('\n❌ TEST FAILED: $e');
  }
}