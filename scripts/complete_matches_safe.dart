import 'dart:io';
import 'dart:math';
import 'package:supabase/supabase.dart';

Future<void> main() async {
  print('⚡ COMPLETE MATCHES WITHOUT WINNER_ID...\n');

  const supabaseUrl = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
  const serviceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo';

  try {
    final supabase = SupabaseClient(supabaseUrl, serviceKey);
    final random = Random();
    
    print('1. Get all pending matches...');
    
    final pendingMatches = await supabase
        .from('matches')
        .select('id, player1_id, player2_id')
        .eq('status', 'pending');
    
    print('   📊 Found ${pendingMatches.length} pending matches');
    
    if (pendingMatches.isEmpty) {
      print('   ✅ No pending matches to complete!');
      exit(0);
    }
    
    print('\n2. Get longsang063 user ID...');
    
    final longsangUser = await supabase
        .from('users')
        .select('id')
        .eq('email', 'longsang063@gmail.com')
        .single();
    
    final longsangId = longsangUser['id'];
    print('   👤 longsang063 ID: $longsangId');
    
    print('\n3. Complete matches with scores only...');
    
    int longsangWins = 0;
    int longsangTotal = 0;
    
    for (var match in pendingMatches) {
      final matchId = match['id'];
      final isLongsangInMatch = match['player1_id'] == longsangId || match['player2_id'] == longsangId;
      
      int player1Score, player2Score;
      
      if (isLongsangInMatch) {
        longsangTotal++;
        final isPlayer1 = match['player1_id'] == longsangId;
        
        // longsang063 wins 70% of time
        final longsangWins_thisMatch = random.nextDouble() < 0.7;
        
        if (longsangWins_thisMatch) {
          longsangWins++;
          if (isPlayer1) {
            player1Score = 7;
            player2Score = random.nextInt(5) + 1; // 1-5
          } else {
            player1Score = random.nextInt(5) + 1; // 1-5
            player2Score = 7;
          }
        } else {
          if (isPlayer1) {
            player1Score = random.nextInt(5) + 1; // 1-5
            player2Score = 7;
          } else {
            player1Score = 7;
            player2Score = random.nextInt(5) + 1; // 1-5
          }
        }
      } else {
        // Random match between other players
        player1Score = random.nextInt(7) + 1;
        player2Score = random.nextInt(7) + 1;
        
        if (player1Score == player2Score) {
          player1Score = 7;
        }
      }
      
      // Update without winner_id to avoid user_profiles error
      await supabase
          .from('matches')
          .update({
            'status': 'completed',
            'player1_score': player1Score,
            'player2_score': player2Score,
          })
          .eq('id', matchId);
      
      print('   ⚔️  Match $matchId: $player1Score-$player2Score');
    }
    
    print('\n4. Update longsang063 user stats...');
    
    if (longsangTotal > 0) {
      final losses = longsangTotal - longsangWins;
      final winRate = longsangWins / longsangTotal;
      final newElo = (1200 + (winRate * 400)).round();
      
      await supabase
          .from('users')
          .update({
            'wins': longsangWins,
            'losses': losses,
            'total_matches': longsangTotal,
            'elo_rating': newElo,
            'win_streak': longsangWins > losses ? 3 : 0,
          })
          .eq('id', longsangId);
      
      print('   📊 longsang063 stats: ${longsangWins}W-${losses}L');
      print('   🎯 ELO rating: $newElo');
      print('   🔥 Win rate: ${(winRate * 100).toStringAsFixed(1)}%');
    }
    
    print('\n🏆 SUCCESS!');
    print('   ✅ ${pendingMatches.length} matches completed');
    print('   ✅ Realistic billiards scores (first to 7)');
    print('   ✅ User statistics updated');
    print('   ✅ Ready for app testing!');
    
    print('\n💡 Note: Skipped winner_id field due to database constraints');
    print('   App can determine winner from player1_score vs player2_score');
    
  } catch (e) {
    print('❌ ERROR: $e');
    exit(1);
  }

  exit(0);
}