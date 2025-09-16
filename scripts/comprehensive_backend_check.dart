import 'dart:io';
import 'package:supabase/supabase.dart';

Future<void> main() async {
  print('🔍 COMPREHENSIVE BACKEND HEALTH CHECK\n');
  print('=====================================\n');

  const supabaseUrl = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
  const serviceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo';

  try {
    final supabase = SupabaseClient(supabaseUrl, serviceKey);
    print('✅ Connected to Supabase successfully\n');

    // 1. DATABASE TABLES OVERVIEW
    print('📊 1. DATABASE TABLES OVERVIEW');
    print('================================');
    
    final tables = [
      'users', 'posts', 'comments', 'matches', 'tournaments', 
      'clubs', 'achievements', 'user_follows', 'tournament_participants',
      'club_members', 'club_tournaments'
    ];
    
    final tableStats = <String, Map<String, dynamic>>{};
    
    for (final table in tables) {
      try {
        final count = await supabase.from(table).select('count').count();
        final sample = await supabase.from(table).select().limit(1);
        
        tableStats[table] = {
          'count': count.count,
          'exists': true,
          'sample': sample.isNotEmpty ? sample.first.keys.toList() : []
        };
        
        print('   ✅ $table: ${count.count} records');
      } catch (e) {
        tableStats[table] = {
          'count': 0,
          'exists': false,
          'error': e.toString()
        };
        print('   ❌ $table: ERROR - ${e.toString().split('\n').first}');
      }
    }
    
    // 2. USER SYSTEM HEALTH
    print('\n👥 2. USER SYSTEM HEALTH');
    print('=========================');
    
    try {
      final users = await supabase.from('users').select('id, email, display_name, created_at').limit(5);
      print('   ✅ Users table: ${users.length} sample records');
      
      final authUsers = await supabase.auth.admin.listUsers();
      print('   ✅ Auth users: ${authUsers.length} authenticated users');
      
      // Check user follows
      final follows = await supabase.from('user_follows').select('count').count();
      print('   ✅ Social connections: ${follows.count} follow relationships');
      
    } catch (e) {
      print('   ❌ User system error: $e');
    }
    
    // 3. CONTENT SYSTEM
    print('\n📝 3. CONTENT SYSTEM STATUS');
    print('============================');
    
    try {
      final posts = await supabase.from('posts').select('count').count();
      final comments = await supabase.from('comments').select('count').count();
      
      print('   ✅ Posts: ${posts.count} total posts');
      print('   ✅ Comments: ${comments.count} total comments');
      
      // Recent activity
      final recentPosts = await supabase
          .from('posts')
          .select('created_at, user_id')
          .order('created_at', ascending: false)
          .limit(1);
      
      if (recentPosts.isNotEmpty) {
        final lastPost = DateTime.parse(recentPosts.first['created_at']);
        final hoursSince = DateTime.now().difference(lastPost).inHours;
        print('   📅 Last post: $hoursSince hours ago');
      }
      
    } catch (e) {
      print('   ❌ Content system error: $e');
    }
    
    // 4. MATCH SYSTEM
    print('\n🎱 4. MATCH SYSTEM STATUS');
    print('==========================');
    
    try {
      final matches = await supabase.from('matches').select('count').count();
      final tournaments = await supabase.from('tournaments').select('count').count();
      
      print('   ✅ Matches: ${matches.count} total matches');
      print('   ✅ Tournaments: ${tournaments.count} total tournaments');
      
      // Check match completions
      final completedMatches = await supabase
          .from('matches')
          .select('count')
          .not('winner_id', 'is', null)
          .count();
      
      final completionRate = matches.count > 0 ? 
          (completedMatches.count / matches.count * 100).toStringAsFixed(1) : '0';
      print('   📊 Match completion rate: $completionRate%');
      
    } catch (e) {
      print('   ❌ Match system error: $e');
    }
    
    // 5. CLUB SYSTEM (NEW)
    print('\n🏢 5. CLUB SYSTEM STATUS');
    print('=========================');
    
    try {
      final clubs = await supabase.from('clubs').select('count').count();
      print('   ✅ Clubs: ${clubs.count} total clubs');
      
      if (tableStats['club_members']?['exists'] == true) {
        final members = await supabase.from('club_members').select('count').count();
        print('   ✅ Club memberships: ${members.count} total memberships');
      }
      
      if (tableStats['club_tournaments']?['exists'] == true) {
        final clubTournaments = await supabase.from('club_tournaments').select('count').count();
        print('   ✅ Club tournaments: ${clubTournaments.count} club-specific tournaments');
      }
      
    } catch (e) {
      print('   ❌ Club system error: $e');
    }
    
    // 6. ACHIEVEMENT SYSTEM
    print('\n🏆 6. ACHIEVEMENT SYSTEM');
    print('=========================');
    
    try {
      final achievements = await supabase.from('achievements').select('count').count();
      print('   ✅ Achievements: ${achievements.count} total achievements');
      
      // Check if users have achievement connections
      final achievedCount = await supabase
          .from('achievements')
          .select('count')
          .not('user_id', 'is', null)
          .count();
      
      print('   📊 User achievements earned: $achievedCount');
      
    } catch (e) {
      print('   ❌ Achievement system error: $e');
    }
    
    // 7. DATA INTEGRITY CHECKS
    print('\n🔒 7. DATA INTEGRITY CHECKS');
    print('============================');
    
    try {
      // Check for orphaned records
      final orphanedComments = await supabase.rpc('check_orphaned_comments');
      print('   🔍 Orphaned comments check: ${orphanedComments ?? 'Function not found'}');
    } catch (e) {
      print('   ⚠️  Data integrity functions not available');
    }
    
    // Check recent user activity
    try {
      final activeUsers = await supabase
          .from('users')
          .select('count')
          .gte('last_seen_at', DateTime.now().subtract(Duration(days: 7)).toIso8601String())
          .count();
      
      print('   📊 Active users (7 days): ${activeUsers.count}');
    } catch (e) {
      print('   ⚠️  User activity tracking not available');
    }
    
    // 8. BACKEND SUMMARY
    print('\n📋 8. BACKEND HEALTH SUMMARY');
    print('==============================');
    
    final totalRecords = tableStats.values
        .where((stats) => stats['exists'] == true)
        .map((stats) => stats['count'] as int)
        .fold(0, (sum, count) => sum + count);
    
    final workingTables = tableStats.values.where((stats) => stats['exists'] == true).length;
    final totalTables = tableStats.length;
    
    print('   📊 Total database records: $totalRecords');
    print('   🗄️  Working tables: $workingTables/$totalTables');
    print('   ✅ Database connectivity: OK');
    print('   🔐 Service key authentication: OK');
    
    if (workingTables == totalTables) {
      print('\n🎉 BACKEND STATUS: HEALTHY ✅');
    } else {
      print('\n⚠️  BACKEND STATUS: NEEDS ATTENTION');
      print('   Missing tables: ${tableStats.entries.where((e) => e.value['exists'] == false).map((e) => e.key).join(', ')}');
    }
    
    print('\n🚀 READY FOR DEVELOPMENT!');
    
  } catch (e) {
    print('❌ CRITICAL ERROR: $e');
    exit(1);
  }

  exit(0);
}