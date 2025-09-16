import 'dart:io';
import 'dart:math';
import 'package:supabase/supabase.dart';

Future<void> main() async {
  print('🎯 CREATING OPPONENT MATCHES WITH REQUIRED FIELDS...\n');

  const supabaseUrl = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
  const serviceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo';

  try {
    final supabase = SupabaseClient(supabaseUrl, serviceKey);
    final random = Random();
    
    // Get longsang063 user
    final longsangUser = await supabase
        .from('users')
        .select('id, email, display_name')
        .eq('email', 'longsang063@gmail.com')
        .single();
    
    final longsangId = longsangUser['id'];
    
    // Get tournaments to use as context
    final tournaments = await supabase
        .from('tournaments')
        .select('id')
        .limit(1);
    
    final tournamentId = tournaments.isNotEmpty ? tournaments.first['id'] : null;
    
    // Get other users for challenges
    final otherUsers = await supabase
        .from('users')
        .select('id, email, display_name')
        .neq('email', 'longsang063@gmail.com')
        .limit(4);
    
    print('👥 Creating opponent matches for longsang063...');
    
    // Opponent challenge scenarios
    final scenarios = [
      {
        'opponent': otherUsers[0],
        'description': 'SPA Challenge 500 points',
        'status': 'pending',
        'stakes': 500,
        'type': 'spa_challenge'
      },
      {
        'opponent': otherUsers[1],
        'description': 'Friendly Match',
        'status': 'completed',  
        'stakes': 0,
        'type': 'friendly'
      },
      {
        'opponent': otherUsers[2],
        'description': 'High Stakes 1000 SPA',
        'status': 'completed',
        'stakes': 1000,
        'type': 'spa_challenge'
      },
      {
        'opponent': otherUsers[3],
        'description': 'Ranking Challenge',
        'status': 'pending',
        'stakes': 0,
        'type': 'challenge'
      },
    ];
    
    print('   Creating ${scenarios.length} opponent matches...\n');
    
    for (int i = 0; i < scenarios.length; i++) {
      final scenario = scenarios[i];
      final opponent = scenario['opponent'] as Map<String, dynamic>;
      
      try {
        // Create match with all required fields
        final matchData = {
          'tournament_id': tournamentId,
          'player1_id': longsangId,
          'player2_id': opponent['id'],
          'round_number': 1, // Required field
          'match_number': i + 1,
          'scheduled_time': DateTime.now().add(Duration(hours: 24 + i)).toIso8601String(),
          'status': scenario['status'],
          'notes': '${scenario['description']} - ${scenario['stakes']} SPA stakes',
          'created_at': DateTime.now().subtract(Duration(days: i)).toIso8601String(),
        };
        
        // Add scores for completed matches
        if (scenario['status'] == 'completed') {
          final longsangWins = random.nextBool();
          matchData.addAll({
            'player1_score': longsangWins ? 7 : random.nextInt(6) + 1,
            'player2_score': longsangWins ? random.nextInt(6) + 1 : 7,
            'start_time': DateTime.now().subtract(Duration(days: i, hours: 2)).toIso8601String(),
            'end_time': DateTime.now().subtract(Duration(days: i, hours: 1)).toIso8601String(),
          });
        }
        
        final newMatch = await supabase
            .from('matches')
            .insert(matchData)
            .select()
            .single();
        
        print('✅ ${scenario['type']}:');
        print('   vs ${opponent['display_name']}');
        print('   Stakes: ${scenario['stakes']} SPA');
        print('   Status: ${scenario['status']}');
        print('   Match ID: ${newMatch['id']}');
        print('');
        
      } catch (e) {
        print('❌ Error creating ${scenario['type']}: $e\n');
      }
    }
    
    print('🎮 OPPONENT TAB TEST SCENARIOS CREATED!');
    print('═══════════════════════════════════════════');
    
    // Verify matches created
    final longsangMatches = await supabase
        .from('matches')
        .select('id, status, notes')
        .or('player1_id.eq.$longsangId,player2_id.eq.$longsangId')
        .order('created_at', ascending: false)
        .limit(10);
    
    print('\n📊 longsang063@gmail.com matches:');
    for (final match in longsangMatches) {
      final status = match['status'];
      final notes = match['notes'] ?? 'Regular match';
      print('   • $status: $notes');
    }
    
    print('\n🎯 OPPONENT TAB FEATURES READY:');
    print('   📨 Challenge system (simulated in notes)');
    print('   🏆 Match history with opponents');
    print('   💎 SPA stakes concept (in notes)');
    print('   🤝 Different match types');
    print('   ⏳ Pending & completed matches');
    
    print('\n💡 FOR FULL SPA SYSTEM:');
    print('   1. Run SQL migration in Supabase Dashboard');
    print('   2. Re-run create_spa_test_data.dart');
    print('   3. Get full opponent features!');
    
    print('\n🚀 longsang063 CAN TEST OPPONENT TAB NOW!');
    print('   Basic opponent data available for UI testing');
    
  } catch (e) {
    print('❌ ERROR: $e');
    exit(1);
  }

  exit(0);
}