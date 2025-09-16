import 'dart:io';
import 'package:supabase/supabase.dart';

Future<void> main() async {
  print('🔍 PHÂN TÍCH TOÀN DIỆN BẢNG MATCHES...\n');

  const supabaseUrl = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
  const anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ';

  try {
    final supabase = SupabaseClient(supabaseUrl, anonKey);
    
    print('📊 1. TỔNG QUAN MATCHES:');
    
    // Raw matches data
    final allMatches = await supabase.from('matches').select('*').order('created_at', ascending: false);
    print('   ✅ Tổng số matches: ${allMatches.length}');
    
    // Detailed analysis
    for (int i = 0; i < allMatches.length; i++) {
      final match = allMatches[i];
      print('\n📋 MATCH ${i + 1} - FULL DETAILS:');
      print('   🆔 ID: ${match['id']}');
      print('   🏆 Tournament ID: ${match['tournament_id']}');
      print('   👤 Player 1 ID: ${match['player1_id']}');
      print('   👤 Player 2 ID: ${match['player2_id']}');
      print('   🏆 Winner ID: ${match['winner_id'] ?? 'NULL'}');
      print('   🎯 Round: ${match['round_number']}, Match: ${match['match_number']}');
      print('   📊 Score: ${match['player1_score']} - ${match['player2_score']}');
      print('   📈 Status: ${match['status']}');
      print('   ⏰ Scheduled: ${match['scheduled_time']}');
      print('   ▶️  Started: ${match['start_time'] ?? 'NULL'}');
      print('   ⏹️  Ended: ${match['end_time'] ?? 'NULL'}');
      print('   📝 Notes: ${match['notes'] ?? 'NULL'}');
      print('   📅 Created: ${match['created_at']}');
      print('   🔄 Updated: ${match['updated_at']}');
    }
    
    // 2. JOIN với related tables
    print('\n\n🔗 2. MATCHES VỚI THÔNG TIN LIÊN QUAN:');
    
    final matchesWithRelations = await supabase.from('matches').select('''
      *,
      tournaments (
        id,
        title,
        start_date,
        status,
        entry_fee,
        prize_pool,
        clubs (
          id,
          name,
          address
        )
      ),
      player1:users!matches_player1_id_fkey (
        id,
        display_name,
        email,
        skill_level,
        ranking_points,
        total_wins,
        total_losses
      ),
      player2:users!matches_player2_id_fkey (
        id,
        display_name,
        email,
        skill_level,
        ranking_points,
        total_wins,
        total_losses
      )
    ''');
    
    for (final match in matchesWithRelations) {
      print('\n🏆 TOURNAMENT INFO:');
      final tournament = match['tournaments'];
      final club = tournament['clubs'];
      print('   - Name: ${tournament['title']}');
      print('   - Start: ${tournament['start_date']}');
      print('   - Status: ${tournament['status']}');
      print('   - Entry Fee: ${tournament['entry_fee']}');
      print('   - Prize Pool: ${tournament['prize_pool']}');
      print('   - Club: ${club['name']} (${club['address']})');
      
      print('\n👥 PLAYERS COMPARISON:');
      final player1 = match['player1'];
      final player2 = match['player2'];
      
      print('   Player 1: ${player1['display_name']}');
      print('   - Email: ${player1['email']}');
      print('   - Skill: ${player1['skill_level']}');
      print('   - Ranking Points: ${player1['ranking_points']}');
      print('   - W/L Record: ${player1['total_wins']}/${player1['total_losses']}');
      
      print('   Player 2: ${player2['display_name']}');
      print('   - Email: ${player2['email']}');
      print('   - Skill: ${player2['skill_level']}');
      print('   - Ranking Points: ${player2['ranking_points']}');
      print('   - W/L Record: ${player2['total_wins']}/${player2['total_losses']}');
    }
    
    // 3. Statistics
    print('\n\n📈 3. MATCH STATISTICS:');
    
    final statusCounts = <String, int>{};
    final roundCounts = <int, int>{};
    
    for (final match in allMatches) {
      final status = match['status'] as String;
      final round = match['round_number'] as int;
      
      statusCounts[status] = (statusCounts[status] ?? 0) + 1;
      roundCounts[round] = (roundCounts[round] ?? 0) + 1;
    }
    
    print('   Status Distribution:');
    statusCounts.forEach((status, count) {
      print('   - $status: $count matches');
    });
    
    print('   Round Distribution:');
    roundCounts.forEach((round, count) {
      print('   - Round $round: $count matches');
    });
    
    // 4. Upcoming matches
    print('\n📅 4. UPCOMING MATCHES:');
    final upcomingMatches = allMatches.where((m) => 
      m['status'] == 'pending' && m['scheduled_time'] != null).toList();
    
    if (upcomingMatches.isNotEmpty) {
      for (final match in upcomingMatches) {
        print('   - Match ${match['match_number']} scheduled for ${match['scheduled_time']}');
      }
    } else {
      print('   - No scheduled matches found');
    }
    
    print('\n✅ PHÂN TÍCH HOÀN TẤT!');
    
  } catch (e) {
    print('❌ ERROR: $e');
    exit(1);
  }

  exit(0);
}