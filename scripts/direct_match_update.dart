import 'dart:io';
import 'dart:math';
import 'package:supabase/supabase.dart';

Future<void> main() async {
  print('🏁 UPDATE MATCHES DIRECTLY...\n');

  const supabaseUrl = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
  const serviceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo';

  try {
    final supabase = SupabaseClient(supabaseUrl, serviceKey);
    final random = Random();
    
    print('1. Updating first match...');
    
    // Update matches one by one
    final match1Update = {
      'status': 'completed',
      'player1_score': 7,
      'player2_score': 3,
      'winner_id': 'ca23e628-d2bb-4174-b4b8-d1cc2ff8335f', // Nguyen Van Duc wins
    };
    
    await supabase
        .from('matches')
        .update(match1Update)
        .eq('id', '277e68fa-daf7-4f3d-91fd-cd23a06c9603');
    
    print('   ✅ Match 1: 7-3 result');
    
    print('\n2. Updating second match...');
    
    final match2Update = {
      'status': 'completed', 
      'player1_score': 4,
      'player2_score': 9,
      'winner_id': 'ac44398b-faf8-4ce0-9043-581e0443b12b', // Admin SABO wins
    };
    
    await supabase
        .from('matches')
        .update(match2Update)
        .eq('id', 'aff6ecda-9e51-46d2-b0aa-501e6c7a6a30');
    
    print('   ✅ Match 2: 4-9 result');
    
    print('\n3. Get longsang063 matches...');
    
    final longsangUser = await supabase
        .from('users')
        .select('id')
        .eq('email', 'longsang063@gmail.com')
        .single();
    
    final longsangMatches = await supabase
        .from('matches')
        .select('id, player1_id, player2_id')
        .or('player1_id.eq.${longsangUser['id']},player2_id.eq.${longsangUser['id']}');
    
    print('   📊 longsang063 has ${longsangMatches.length} matches');
    
    // Update longsang063 matches
    for (var match in longsangMatches) {
      final isPlayer1 = match['player1_id'] == longsangUser['id'];
      
      // longsang063 wins 70% of time
      final longsangWins = random.nextDouble() < 0.7;
      
      int player1Score, player2Score;
      String winnerId;
      
      if (longsangWins) {
        if (isPlayer1) {
          player1Score = 7;
          player2Score = random.nextInt(6) + 1;
          winnerId = longsangUser['id'];
        } else {
          player1Score = random.nextInt(6) + 1;
          player2Score = 7;
          winnerId = longsangUser['id'];
        }
      } else {
        if (isPlayer1) {
          player1Score = random.nextInt(6) + 1;
          player2Score = 7;
          winnerId = match['player2_id'];
        } else {
          player1Score = 7;
          player2Score = random.nextInt(6) + 1;
          winnerId = match['player1_id'];
        }
      }
      
      await supabase
          .from('matches')
          .update({
            'status': 'completed',
            'player1_score': player1Score,
            'player2_score': player2Score,
            'winner_id': winnerId,
          })
          .eq('id', match['id']);
      
      final result = longsangWins ? 'WON' : 'LOST';
      print('   ⚔️  longsang063 match: $player1Score-$player2Score ($result)');
    }
    
    print('\n4. Update user statistics...');
    
    // Simple stats update for longsang063
    final longsangWins = await supabase
        .from('matches')
        .select('count')
        .eq('winner_id', longsangUser['id'])
        .eq('status', 'completed')
        .count();
    
    final longsangTotal = await supabase
        .from('matches')
        .select('count')
        .or('player1_id.eq.${longsangUser['id']},player2_id.eq.${longsangUser['id']}')
        .eq('status', 'completed')
        .count();
    
    final wins = longsangWins.count;
    final total = longsangTotal.count;
    final losses = total - wins;
    final newElo = (1200 + (wins / total * 300)).round();
    
    await supabase
        .from('users')
        .update({
          'wins': wins,
          'losses': losses,
          'total_matches': total,
          'elo_rating': newElo,
          'win_streak': wins > losses ? 3 : 0,
        })
        .eq('id', longsangUser['id']);
    
    print('   📊 longsang063 updated: ${wins}W-${losses}L, ELO: $newElo');
    
    print('\n🏆 SUCCESS! Match results completed!');
    print('   ✅ All matches have realistic outcomes');  
    print('   ✅ User statistics updated');
    print('   ✅ Ready for app testing!');
    
  } catch (e) {
    print('❌ ERROR: $e');
    exit(1);
  }

  exit(0);
}