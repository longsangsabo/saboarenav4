import 'dart:io';
import 'dart:math';
import 'package:supabase/supabase.dart';

Future<void> main() async {
  print('🎮 CREATING SPA CHALLENGE TEST DATA...\n');

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
    
    print('👤 SETTING UP SPA POINTS FOR USERS...');
    
    // First, let's manually set SPA points if the columns exist
    try {
      // Try to update longsang063 SPA points
      await supabase
          .from('users')
          .update({
            'spa_points': 2500, // Give longsang063 good starting balance
            'spa_points_won': 1500,
            'spa_points_lost': 500,
            'challenge_win_streak': 3,
          })
          .eq('id', longsangId);
      
      print('   ✅ Set longsang063 SPA points: 2500 (won: 1500, lost: 500, streak: 3)');
    } catch (e) {
      print('   ⚠️ SPA columns may not exist yet: $e');
      print('   💡 Please run spa_system_migration.sql in Supabase first!');
    }
    
    // Get other users for challenges
    final otherUsers = await supabase
        .from('users')
        .select('id, email, display_name')
        .neq('email', 'longsang063@gmail.com')
        .limit(5);
    
    print('\n🎯 CREATING OPPONENT CHALLENGE SCENARIOS...');
    
    // Create different types of matches for longsang063
    final challengeScenarios = [
      {
        'type': 'spa_challenge',
        'opponent': otherUsers[0],
        'stakes': 500,
        'message': 'Thách đấu 500 SPA - bạn dám không? 8-ball race to 5!',
        'status': 'pending',
        'description': 'High stakes challenge'
      },
      {
        'type': 'friendly',
        'opponent': otherUsers[1], 
        'stakes': 0,
        'message': 'Chơi giao lưu cho vui thôi bạn!',
        'status': 'completed',
        'description': 'Friendly casual match'
      },
      {
        'type': 'spa_challenge',
        'opponent': otherUsers[2],
        'stakes': 1000,
        'message': '1000 SPA stakes! Cao thủ mới dám nhận 🔥',
        'status': 'completed',
        'description': 'High stakes completed'
      },
      {
        'type': 'challenge',
        'opponent': otherUsers[3],
        'stakes': 0,
        'message': 'Thách đấu rank - không cược!',
        'status': 'pending',
        'description': 'Ranking challenge'
      }
    ];
    
    print('   Creating ${challengeScenarios.length} challenge scenarios...');
    
    for (int i = 0; i < challengeScenarios.length; i++) {
      final scenario = challengeScenarios[i];
      final opponent = scenario['opponent'] as Map<String, dynamic>;
      
      try {
        // Create match with new opponent features
        final matchData = {
          'player1_id': longsangId,
          'player2_id': opponent['id'],
          'match_type': scenario['type'],
          'invitation_type': 'challenge_sent',
          'stakes_type': scenario['stakes'] as int > 0 ? 'spa_points' : 'none',
          'spa_stakes_amount': scenario['stakes'],
          'challenger_id': longsangId,
          'challenge_message': scenario['message'],
          'match_conditions': {'format': '8ball', 'race_to': 5},
          'is_public_challenge': random.nextBool(),
          'status': scenario['status'],
          'created_at': DateTime.now().subtract(Duration(days: random.nextInt(7))).toIso8601String(),
        };
        
        // Add completion data for completed matches
        if (scenario['status'] == 'completed') {
          final longsangWins = random.nextBool();
          matchData.addAll({
            'player1_score': longsangWins ? 5 : random.nextInt(4) + 1,
            'player2_score': longsangWins ? random.nextInt(4) + 1 : 5,
            'accepted_at': DateTime.now().subtract(Duration(days: random.nextInt(5))).toIso8601String(),
            'response_message': 'Challenge accepted! Game on!',
            'spa_payout_processed': scenario['stakes'] as int > 0,
          });
        } else {
          // Pending challenges expire in future
          matchData['expires_at'] = DateTime.now().add(Duration(hours: 24)).toIso8601String();
        }
        
        final newMatch = await supabase
            .from('matches')
            .insert(matchData)
            .select()
            .single();
        
        print('   ✅ Created ${scenario['type']} vs ${opponent['display_name']} (${scenario['stakes']} SPA)');
        
        // Create SPA transaction if it was a completed stakes match
        if (scenario['status'] == 'completed' && scenario['stakes'] as int > 0) {
          try {
            final transactionData = {
              'user_id': longsangId,
              'match_id': newMatch['id'],
              'transaction_type': 'challenge_win', // Assume longsang063 won
              'amount': scenario['stakes'],
              'balance_before': 2000,
              'balance_after': 2000 + (scenario['stakes'] as int),
              'description': 'Won SPA challenge vs ${opponent['display_name']}',
            };
            
            await supabase
                .from('spa_transactions')
                .insert(transactionData);
            
            print('     💎 Added SPA transaction: +${scenario['stakes']} points');
          } catch (e) {
            print('     ⚠️ SPA transaction error: $e');
          }
        }
        
      } catch (e) {
        print('   ❌ Error creating ${scenario['type']}: $e');
      }
    }
    
    print('\n🏆 CREATING PUBLIC CHALLENGES...');
    
    // Create some public challenges that others can join
    final publicChallenges = [
      {
        'stakes': 250,
        'message': '250 SPA quick match - ai dám?',
        'format': '9ball'
      },
      {
        'stakes': 750,
        'message': 'High stakes 750 SPA - 8ball masters only!',
        'format': '8ball'
      }
    ];
    
    for (final challenge in publicChallenges) {
      try {
        final challengeData = {
          'player1_id': longsangId,
          'match_type': 'spa_challenge',
          'invitation_type': 'public_room',
          'stakes_type': 'spa_points',
          'spa_stakes_amount': challenge['stakes'],
          'challenger_id': longsangId,
          'challenge_message': challenge['message'],
          'match_conditions': {'format': challenge['format'], 'race_to': 7},
          'is_public_challenge': true,
          'status': 'pending',
          'expires_at': DateTime.now().add(Duration(hours: 48)).toIso8601String(),
        };
        
        await supabase
            .from('matches')
            .insert(challengeData);
        
        print('   ✅ Created public challenge: ${challenge['stakes']} SPA (${challenge['format']})');
      } catch (e) {
        print('   ❌ Public challenge error: $e');
      }
    }
    
    print('\n📊 SUMMARY FOR OPPONENT TAB TESTING:');
    print('═══════════════════════════════════════');
    
    try {
      final totalChallenges = await supabase
          .from('matches')
          .select('count')
          .or('challenger_id.eq.$longsangId,player1_id.eq.$longsangId,player2_id.eq.$longsangId')
          .count();
      
      print('✅ longsang063@gmail.com challenge data:');
      print('   • Total challenges: ${totalChallenges.count}');
      print('   • SPA balance: 2500 points');
      print('   • Win streak: 3');
      print('   • Various match types: spa_challenge, friendly, challenge');
      print('   • Pending & completed matches');
      print('   • Public challenges available');
      
    } catch (e) {
      print('⚠️ Summary error: $e');
    }
    
    print('\n🎮 OPPONENT TAB FEATURES READY TO TEST:');
    print('   📨 Send/receive challenges');
    print('   💎 SPA stakes betting');
    print('   🤝 Friendly matches');
    print('   🌍 Public challenge rooms');
    print('   📊 SPA balance & transactions');
    print('   🏆 Win streaks & statistics');
    
    print('\n💡 NEXT: Run the spa_system_migration.sql in Supabase');
    print('   to enable all opponent features!');
    
  } catch (e) {
    print('❌ ERROR: $e');
    exit(1);
  }

  exit(0);
}