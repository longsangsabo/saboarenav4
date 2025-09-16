import 'dart:io';
import 'dart:math';
import 'package:supabase/supabase.dart';

Future<void> main() async {
  print('🏁 TẠO REALISTIC MATCH RESULTS...\n');

  const supabaseUrl = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
  const serviceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo';

  try {
    final supabase = SupabaseClient(supabaseUrl, serviceKey);
    final random = Random();
    
    print('1. Lấy pending matches...');
    final pendingMatches = await supabase
        .from('matches')
        .select('*')
        .eq('status', 'pending');
    
    print('   ✅ Found ${pendingMatches.length} pending matches\n');
    
    // 2. Complete matches với realistic scores
    print('2. Completing matches với realistic outcomes:');
    
    for (var match in pendingMatches) {
      // Get player names separately
      final player1 = await supabase.from('users').select('display_name').eq('id', match['player1_id']).single();
      final player2 = await supabase.from('users').select('display_name').eq('id', match['player2_id']).single();
      
      final player1Name = player1['display_name'];
      final player2Name = player2['display_name'];
      
      // Random realistic billiards scores (race to 5, 7, or 9)
      final raceLength = [5, 7, 9][random.nextInt(3)];
      int player1Score, player2Score;
      String winnerId;
      
      // 70% chance longsang063 wins (he's practicing!)
      final longsangId = await supabase
          .from('users')
          .select('id')
          .eq('email', 'longsang063@gmail.com')
          .single();
      
      final isLongsangPlaying = match['player1_id'] == longsangId['id'] || 
                               match['player2_id'] == longsangId['id'];
      
      if (isLongsangPlaying && random.nextDouble() < 0.7) {
        // longsang063 wins
        winnerId = longsangId['id'];
        if (match['player1_id'] == longsangId['id']) {
          player1Score = raceLength;
          player2Score = random.nextInt(raceLength - 1);
        } else {
          player2Score = raceLength;
          player1Score = random.nextInt(raceLength - 1);
        }
      } else {
        // Random winner
        final player1Wins = random.nextBool();
        if (player1Wins) {
          winnerId = match['player1_id'];
          player1Score = raceLength;
          player2Score = random.nextInt(raceLength - 1);
        } else {
          winnerId = match['player2_id'];  
          player2Score = raceLength;
          player1Score = random.nextInt(raceLength - 1);
        }
      }
      
      // Update match
      await supabase
          .from('matches')
          .update({
            'status': 'completed',
            'player1_score': player1Score,
            'player2_score': player2Score,
            'winner_id': winnerId,
            'end_time': DateTime.now().subtract(Duration(days: random.nextInt(7))).toIso8601String(),
            'start_time': DateTime.now().subtract(Duration(days: random.nextInt(7) + 1)).toIso8601String(),
          })
          .eq('id', match['id']);
      
      final winnerName = winnerId == match['player1_id'] ? player1Name : player2Name;
      print('   ⚔️  $player1Name vs $player2Name: $player1Score-$player2Score');
      print('      🏆 Winner: $winnerName');
    }
    
    print('\n3. Updating user statistics...');
    
    // 3. Update user win/loss statistics
    final allUsers = await supabase.from('users').select('id, display_name');
    
    for (var user in allUsers) {
      final userId = user['id'];
      
      // Count wins
      final wins = await supabase
          .from('matches')
          .select('count')
          .eq('winner_id', userId)
          .eq('status', 'completed')
          .count();
      
      // Count total matches played
      final totalMatches = await supabase
          .from('matches')
          .select('count')
          .or('player1_id.eq.$userId,player2_id.eq.$userId')
          .eq('status', 'completed')
          .count();
      
      final losses = totalMatches.count - wins.count;
      
      // Calculate new ELO rating based on performance
      final winRate = totalMatches.count > 0 ? wins.count / totalMatches.count : 0;
      final newElo = (1200 + (winRate * 400) + random.nextInt(100) - 50).round();
      
      // Update user stats
      await supabase
          .from('users')
          .update({
            'wins': wins.count,
            'losses': losses,
            'total_matches': totalMatches.count,
            'win_streak': wins.count > losses ? random.nextInt(3) + 1 : 0,
            'elo_rating': newElo,
          })
          .eq('id', userId);
      
      if (totalMatches.count > 0) {
        final winPercentage = (winRate * 100).toStringAsFixed(1);
        print('   📊 ${user['display_name']}: ${wins.count}W-${losses}L ($winPercentage%) - ELO: $newElo');
      }
    }
    
    print('\n4. Creating match history timeline...');
    
    // 4. Tạo thêm một số completed matches trong quá khứ
    final users = await supabase.from('users').select('id, display_name').limit(5);
    
    for (int i = 0; i < 3; i++) {
      final player1 = users[random.nextInt(users.length)];
      final player2 = users[random.nextInt(users.length)];
      
      if (player1['id'] == player2['id']) continue;
      
      final raceLength = [5, 7][random.nextInt(2)];
      final player1Wins = random.nextBool();
      
      final historicalMatch = {
        'player1_id': player1['id'],
        'player2_id': player2['id'],
        'player1_score': player1Wins ? raceLength : random.nextInt(raceLength),
        'player2_score': player1Wins ? random.nextInt(raceLength) : raceLength,
        'winner_id': player1Wins ? player1['id'] : player2['id'],
        'status': 'completed',
        'start_time': DateTime.now().subtract(Duration(days: 10 + i)).toIso8601String(),
        'end_time': DateTime.now().subtract(Duration(days: 9 + i)).toIso8601String(),
        'created_at': DateTime.now().subtract(Duration(days: 10 + i)).toIso8601String(),
      };
      
      await supabase.from('matches').insert([historicalMatch]);
      
      final winnerName = player1Wins ? player1['display_name'] : player2['display_name'];
      print('   📜 Historical: ${player1['display_name']} vs ${player2['display_name']} → $winnerName wins');
    }
    
    print('\n5. Final statistics summary...');
    
    final finalStats = await Future.wait([
      supabase.from('matches').select('count').eq('status', 'completed').count(),
      supabase.from('matches').select('count').eq('status', 'pending').count(),
    ]);
    
    // Get longsang063 final stats
    final longsangStats = await supabase
        .from('users')
        .select('wins, losses, total_matches, elo_rating, win_streak')
        .eq('email', 'longsang063@gmail.com')
        .single();
    
    print('   📊 MATCH RESULTS SUMMARY:');
    print('      ⚔️  Completed Matches: ${finalStats[0].count}');
    print('      📅 Pending Matches: ${finalStats[1].count}');
    print('      🎯 longsang063 Stats:');
    print('         • Record: ${longsangStats['wins']}W-${longsangStats['losses']}L');
    print('         • Win Rate: ${longsangStats['total_matches'] > 0 ? ((longsangStats['wins'] / longsangStats['total_matches']) * 100).toStringAsFixed(1) : '0.0'}%');
    print('         • ELO Rating: ${longsangStats['elo_rating']}');
    print('         • Win Streak: ${longsangStats['win_streak']}');
    
    print('\n🏆 MATCH RESULTS COMPLETED SUCCESSFULLY!');
    print('   ✅ All pending matches resolved');
    print('   ✅ Realistic user statistics updated');
    print('   ✅ Match history timeline created');
    print('   ✅ ELO ratings calculated');
    print('   ✅ App ready for match-based features!');
    
  } catch (e) {
    print('❌ ERROR: $e');
    print('Details: ${e.toString()}');
    exit(1);
  }

  exit(0);
}