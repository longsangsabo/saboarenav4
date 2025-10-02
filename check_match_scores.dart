// 🔍 SABO ARENA - Check Match Scores in Database
// Script to verify match scores are properly saved

import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://mogjjvscxjwvhtpkrlqr.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ',
  );

  final supabase = Supabase.instance.client;

  print('🔍 Checking matches for tournament sabo1...\n');

  try {
    // Get tournament ID first
    final tournaments = await supabase
        .from('tournaments')
        .select('id, title')
        .ilike('title', '%sabo1%')
        .limit(5);

    if (tournaments.isEmpty) {
      print('❌ No tournament found with name containing "sabo1"');
      return;
    }

    print('📋 Found tournaments:');
    for (var t in tournaments) {
      print('  - ${t['title']} (${t['id']})');
    }

    final tournamentId = tournaments.first['id'];
    print('\n🎯 Using tournament: ${tournaments.first['title']}\n');

    // Get all matches
    final matches = await supabase
        .from('matches')
        .select('''
          id,
          round_number,
          match_number,
          player1_id,
          player2_id,
          player1_score,
          player2_score,
          winner_id,
          status,
          player1:player1_id(full_name),
          player2:player2_id(full_name)
        ''')
        .eq('tournament_id', tournamentId)
        .order('round_number')
        .order('match_number');

    print('📊 Total matches: ${matches.length}\n');

    // Group by rounds
    Map<int, List<Map<String, dynamic>>> matchesByRound = {};
    for (var match in matches) {
      final round = match['round_number'] as int;
      if (!matchesByRound.containsKey(round)) {
        matchesByRound[round] = [];
      }
      matchesByRound[round]!.add(match);
    }

    // Display matches by round
    for (var round in matchesByRound.keys.toList()..sort()) {
      print('🏁 ROUND $round:');
      print('=' * 80);

      for (var match in matchesByRound[round]!) {
        final matchNum = match['match_number'];
        final p1Name = match['player1']?['full_name'] ?? 'TBD';
        final p2Name = match['player2']?['full_name'] ?? 'TBD';
        final p1Score = match['player1_score'] ?? 0;
        final p2Score = match['player2_score'] ?? 0;
        final status = match['status'];
        final hasWinner = match['winner_id'] != null;

        String scoreDisplay = '$p1Score - $p2Score';
        String statusIcon = status == 'completed' ? '✅' : 
                           status == 'pending' ? '⏳' : '🔄';
        String winnerIcon = hasWinner ? '🏆' : '';

        print('  Match $matchNum: $p1Name vs $p2Name');
        print('    Score: $scoreDisplay $statusIcon $winnerIcon');
        print('    Status: $status');
        
        // Highlight non-zero scores
        if (p1Score > 0 || p2Score > 0) {
          print('    ⚡ HAS SCORES! ⚡');
        }
        print('');
      }
      print('');
    }

    // Summary
    final completedMatches = matches.where((m) => m['status'] == 'completed').length;
    final withScores = matches.where((m) => 
      (m['player1_score'] ?? 0) > 0 || (m['player2_score'] ?? 0) > 0
    ).length;

    print('📈 SUMMARY:');
    print('  Total matches: ${matches.length}');
    print('  Completed: $completedMatches');
    print('  With scores > 0: $withScores');
    
  } catch (e) {
    print('❌ Error: $e');
  }
}
