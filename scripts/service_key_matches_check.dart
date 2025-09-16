import 'dart:io';
import 'package:supabase/supabase.dart';

Future<void> main() async {
  print('🔐 KIỂM TRA MATCHES VỚI SERVICE KEY...\n');

  const supabaseUrl = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
  // Service role key from env.json (if available)
  const serviceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.0OKSUHlSX5FKnGJWFrGMh3A7rrMQHnKPPdcRwFT6t4s';

  try {
    print('🚀 Connecting with SERVICE ROLE KEY...');
    final supabase = SupabaseClient(supabaseUrl, serviceKey);
    
    // 1. Test connection với service key
    print('📡 Testing service key connection...');
    
    // 2. Truy cập auth.users (chỉ service key mới có quyền)
    print('\n🔍 1. KIỂM TRA AUTH.USERS (Service Key Only):');
    try {
      final authUsers = await supabase.rpc('get_auth_users_count');
      print('   ✅ Auth users count: $authUsers');
      
      final authSample = await supabase.rpc('get_auth_users_sample');
      print('   ✅ Auth users sample: ${authSample.length} records');
      if (authSample.isNotEmpty) {
        for (var user in authSample) {
          print('      - ${user['email']} (created: ${user['created_at']})');
        }
      }
    } catch (e) {
      print('   ❌ Auth users access failed: $e');
    }
    
    // 3. Truy cập matches với full permissions
    print('\n🏓 2. KIỂM TRA MATCHES VỚI SERVICE KEY:');
    final matches = await supabase.from('matches').select('*');
    print('   ✅ Total matches: ${matches.length}');
    
    // 4. Raw SQL queries (chỉ service key mới có thể)
    print('\n🔧 3. RAW SQL QUERIES:');
    try {
      // Query để xem structure của matches table
      final tableInfo = await supabase.rpc('exec_sql', params: {
        'sql': '''
          SELECT column_name, data_type, is_nullable 
          FROM information_schema.columns 
          WHERE table_name = 'matches' AND table_schema = 'public'
          ORDER BY ordinal_position;
        '''
      });
      print('   ✅ Matches table structure:');
      for (var col in tableInfo) {
        print('      - ${col['column_name']}: ${col['data_type']} (nullable: ${col['is_nullable']})');
      }
    } catch (e) {
      print('   ❌ Raw SQL failed: $e');
    }
    
    // 5. Advanced queries với service key
    print('\n📊 4. ADVANCED MATCH ANALYTICS:');
    try {
      final matchStats = await supabase.rpc('exec_sql', params: {
        'sql': '''
          SELECT 
            status,
            COUNT(*) as count,
            AVG(player1_score + player2_score) as avg_total_score
          FROM matches 
          GROUP BY status;
        '''
      });
      print('   ✅ Match statistics:');
      for (var stat in matchStats) {
        print('      - Status: ${stat['status']}, Count: ${stat['count']}, Avg Score: ${stat['avg_total_score']}');
      }
    } catch (e) {
      print('   ❌ Advanced analytics failed: $e');
    }
    
    // 6. Check all tables accessible với service key
    print('\n🗂️  5. ALL TABLES WITH SERVICE KEY:');
    try {
      final tables = await supabase.rpc('exec_sql', params: {
        'sql': '''
          SELECT schemaname, tablename, tableowner 
          FROM pg_tables 
          WHERE schemaname IN ('public', 'auth') 
          ORDER BY schemaname, tablename;
        '''
      });
      print('   ✅ Accessible tables:');
      for (var table in tables) {
        print('      - ${table['schemaname']}.${table['tablename']} (owner: ${table['tableowner']})');
      }
    } catch (e) {
      print('   ❌ Tables listing failed: $e');
    }
    
    print('\n🎉 SERVICE KEY ACCESS SUCCESSFUL!');
    
  } catch (e) {
    print('❌ SERVICE KEY ERROR: $e');
    
    // Fallback to anon key
    print('\n🔄 Falling back to ANON KEY...');
    const anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ';
    
    try {
      final anonSupabase = SupabaseClient(supabaseUrl, anonKey);
      final matches = await anonSupabase.from('matches').select('*');
      print('   ✅ ANON KEY - Matches count: ${matches.length}');
      
      for (var match in matches) {
        print('   📋 Match: ${match['id']}');
        print('      - Players: ${match['player1_id']} vs ${match['player2_id']}');
        print('      - Status: ${match['status']}');
        print('      - Score: ${match['player1_score']} - ${match['player2_score']}');
      }
      
    } catch (anonError) {
      print('   ❌ ANON KEY also failed: $anonError');
    }
  }

  exit(0);
}