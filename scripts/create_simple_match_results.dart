import 'dart:io';
import 'dart:math';
import 'package:supabase/supabase.dart';

Future<void> main() async {
  print('🏁 TẠO MATCH RESULTS - SIMPLIFIED...\n');

  const supabaseUrl = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
  const serviceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo';

  try {
    final supabase = SupabaseClient(supabaseUrl, serviceKey);
    final random = Random();
    
    // 1. Lấy all pending matches
    print('1. Getting pending matches...');
    final pendingMatches = await supabase
        .from('matches')
        .select('*')
        .eq('status', 'pending');
    
    print('   ✅ Found ${pendingMatches.length} pending matches');
    
    // 2. Get longsang063 user ID
    final longsangUser = await supabase
        .from('users')
        .select('id')
        .eq('email', 'longsang063@gmail.com')
        .single();
    final longsangId = longsangUser['id'];
    
    print('\n2. Completing matches:');
    
    // 3. Complete each match
    for (int i = 0; i < pendingMatches.length; i++) {
      final match = pendingMatches[i];
      
      // Generate realistic billiards scores
      final raceLength = [5, 7, 9][random.nextInt(3)];  // Race to 5, 7, or 9
      
      // 70% chance longsang063 wins if he's playing
      final isLongsangMatch = match['player1_id'] == longsangId || match['player2_id'] == longsangId;
      
      int player1Score, player2Score;
      String winnerId;
      
      if (isLongsangMatch && random.nextDouble() < 0.7) {
        // longsang063 wins
        if (match['player1_id'] == longsangId) {
          player1Score = raceLength;
          player2Score = random.nextInt(raceLength - 1);
          winnerId = match['player1_id'];
        } else {
          player1Score = random.nextInt(raceLength - 1);
          player2Score = raceLength;
          winnerId = match['player2_id'];
        }
      } else {
        // Random winner
        if (random.nextBool()) {
          player1Score = raceLength;
          player2Score = random.nextInt(raceLength - 1);
          winnerId = match['player1_id'];
        } else {
          player1Score = random.nextInt(raceLength - 1);
          player2Score = raceLength;
          winnerId = match['player2_id'];
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
            'start_time': DateTime.now().subtract(Duration(hours: 2 + i)).toIso8601String(),
            'end_time': DateTime.now().subtract(Duration(hours: 1 + i)).toIso8601String(),
          })
          .eq('id', match['id']);
      
      print('   ⚔️  Match ${i + 1}: Score $player1Score-$player2Score ✅');
    }
    
    print('\n3. Updating user statistics...');
    
    // 4. Update all user statistics
    final allUsers = await supabase.from('users').select('id, display_name');
    
    for (var user in allUsers) {
      final userId = user['id'];
      
      // Count wins
      final winsResult = await supabase
          .from('matches')
          .select('count')
          .eq('winner_id', userId)
          .eq('status', 'completed')
          .count();
      
      // Count total matches
      final totalResult = await supabase
          .from('matches')
          .select('count')
          .or('player1_id.eq.$userId,player2_id.eq.$userId')
          .eq('status', 'completed')
          .count();
      
      final wins = winsResult.count;
      final total = totalResult.count;
      final losses = total - wins;
      
      if (total > 0) {
        // Calculate new ELO based on win rate
        final winRate = wins / total;
        final newElo = (1200 + (winRate * 300) + random.nextInt(100) - 50).round();
        
        // Update user
        await supabase
            .from('users')
            .update({
              'wins': wins,
              'losses': losses,
              'total_matches': total,
              'win_streak': wins > losses ? random.nextInt(4) : 0,
              'elo_rating': newElo,
            })
            .eq('id', userId);
        
        final winPercentage = (winRate * 100).toStringAsFixed(1);
        print('   📊 ${user['display_name']}: ${wins}W-${losses}L ($winPercentage%) ELO: $newElo');
      }
    }
    
    print('\n4. Final summary...');
    
    final finalStats = await Future.wait([
      supabase.from('matches').select('count').eq('status', 'completed').count(),
      supabase.from('matches').select('count').eq('status', 'pending').count(),
    ]);
    
    // Get longsang063 final stats
    final longsangFinal = await supabase
        .from('users')
        .select('wins, losses, total_matches, elo_rating')
        .eq('id', longsangId)
        .single();
    
    print('   🏆 MATCH RESULTS COMPLETE:');
    print('      ⚔️  Completed: ${finalStats[0].count}');
    print('      📅 Pending: ${finalStats[1].count}');
    print('      🎯 longsang063: ${longsangFinal['wins']}W-${longsangFinal['losses']}L');
    print('      ⚡ ELO: ${longsangFinal['elo_rating']}');
    
    print('\n🚀 SUCCESS! Match results created with realistic outcomes!');
    
  } catch (e) {
    print('❌ ERROR: $e');
    exit(1);
  }

  exit(0);
}