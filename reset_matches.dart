// 🔄 SABO ARENA - Reset Tournament Matches
// Script to reset or delete matches for a tournament

import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

void main() async {
  print('🔄 SABO ARENA - Reset Tournament Matches\n');
  
  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://mogjjvscxjwvhtpkrlqr.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ',
  );

  final supabase = Supabase.instance.client;

  try {
    // Find tournament
    print('🔍 Searching for tournament "sabo1"...');
    final tournaments = await supabase
        .from('tournaments')
        .select('id, title')
        .ilike('title', '%sabo1%')
        .limit(5);

    if (tournaments.isEmpty) {
      print('❌ No tournament found with name containing "sabo1"');
      return;
    }

    print('\n📋 Found tournaments:');
    for (int i = 0; i < tournaments.length; i++) {
      print('  ${i + 1}. ${tournaments[i]['title']} (${tournaments[i]['id']})');
    }

    final tournamentId = tournaments.first['id'];
    final tournamentTitle = tournaments.first['title'];
    print('\n🎯 Using tournament: $tournamentTitle');

    // Get current matches
    final matches = await supabase
        .from('matches')
        .select('id, round_number, match_number, player1_score, player2_score, winner_id, status')
        .eq('tournament_id', tournamentId);

    print('📊 Found ${matches.length} matches');

    // Show options
    print('\n🔧 Choose an option:');
    print('  1. Reset scores to 0-0 (keep matches, clear scores & winners)');
    print('  2. Delete ALL matches (to recreate bracket from scratch)');
    print('  3. Cancel');
    
    stdout.write('\nEnter your choice (1-3): ');
    final choice = stdin.readLineSync();

    if (choice == '1') {
      // Option 1: Reset scores
      print('\n⚠️  This will reset ALL ${matches.length} matches to 0-0 and clear winners.');
      stdout.write('Are you sure? (yes/no): ');
      final confirm = stdin.readLineSync()?.toLowerCase();

      if (confirm == 'yes' || confirm == 'y') {
        print('\n🔄 Resetting matches...');
        
        int resetCount = 0;
        for (var match in matches) {
          await supabase
              .from('matches')
              .update({
                'player1_score': 0,
                'player2_score': 0,
                'winner_id': null,
                'status': 'pending',
                'completed_at': null,
                'updated_at': DateTime.now().toIso8601String(),
              })
              .eq('id', match['id']);
          
          resetCount++;
          if (resetCount % 10 == 0) {
            print('  Reset $resetCount/${matches.length} matches...');
          }
        }

        print('\n✅ Successfully reset $resetCount matches!');
        print('   All scores set to 0-0');
        print('   All winners cleared');
        print('   All statuses set to pending');
        
      } else {
        print('\n❌ Reset cancelled');
      }

    } else if (choice == '2') {
      // Option 2: Delete all matches
      print('\n⚠️  WARNING: This will PERMANENTLY DELETE ALL ${matches.length} matches!');
      print('⚠️  You will need to regenerate the bracket.');
      stdout.write('Are you ABSOLUTELY sure? (type "DELETE" to confirm): ');
      final confirm = stdin.readLineSync();

      if (confirm == 'DELETE') {
        print('\n🗑️  Deleting matches...');
        
        await supabase
            .from('matches')
            .delete()
            .eq('tournament_id', tournamentId);

        print('\n✅ Successfully deleted ALL matches!');
        print('   You can now regenerate the bracket from the app.');
        
      } else {
        print('\n❌ Deletion cancelled');
      }

    } else {
      print('\n❌ Operation cancelled');
    }

  } catch (e) {
    print('\n❌ Error: $e');
  }
}
