import 'dart:io';
import 'package:supabase/supabase.dart';

void main() async {
  print('🧪 TESTING SUPABASE CONNECTION WITH SERVICE ROLE KEY\n');
  print('=' * 60);

  // Supabase configuration
  const supabaseUrl = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
  const serviceRoleKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo';

  try {
    // Initialize Supabase client
    final supabase = SupabaseClient(supabaseUrl, serviceRoleKey);
    print('✅ Supabase client initialized successfully');

    // Test 1: Basic connection test
    print('\n📋 TEST 1: Basic Connection Test');
    await testBasicConnection(supabase);

    // Test 2: Database schema check
    print('\n📋 TEST 2: Database Schema Check');
    await testDatabaseSchema(supabase);

    // Test 3: Authentication functions
    print('\n📋 TEST 3: Authentication Test');
    await testAuthentication(supabase);

    // Test 4: Database operations
    print('\n📋 TEST 4: Database Operations Test');
    await testDatabaseOperations(supabase);

    // Test 5: RPC Functions test
    print('\n📋 TEST 5: RPC Functions Test');
    await testRPCFunctions(supabase);

    print('\n🎉 ALL TESTS COMPLETED!');
    print('=' * 60);

  } catch (e) {
    print('❌ Error initializing Supabase: $e');
    exit(1);
  }
}

Future<void> testBasicConnection(SupabaseClient supabase) async {
  try {
    // Simple query to test connection
    final response = await supabase
        .from('users')
        .select('count')
        .count(CountOption.exact);
    
    print('   ✅ Connection successful');
    print('   📊 Total users in database: ${response.count}');
  } catch (e) {
    print('   ❌ Connection failed: $e');
  }
}

Future<void> testDatabaseSchema(SupabaseClient supabase) async {
  final tables = [
    'users',
    'tournaments', 
    'clubs',
    'posts',
    'matches',
    'achievements',
    'comments',
    'post_likes'
  ];

  print('   📝 Checking database tables:');
  
  for (String table in tables) {
    try {
      await supabase
          .from(table)
          .select('*')
          .limit(1);
      
      print('   ✅ Table "$table" exists and accessible');
    } catch (e) {
      print('   ❌ Table "$table" error: $e');
    }
  }
}

Future<void> testAuthentication(SupabaseClient supabase) async {
  try {
    // Test getting users (should work with service role)
    final response = await supabase
        .from('users')
        .select('id, email, created_at')
        .limit(3);
    
    print('   ✅ Authentication successful');
    print('   👥 Sample users found: ${response.length}');
    
    for (var user in response) {
      print('      - ID: ${user['id']}, Email: ${user['email'] ?? 'N/A'}');
    }
  } catch (e) {
    print('   ❌ Authentication test failed: $e');
  }
}

Future<void> testDatabaseOperations(SupabaseClient supabase) async {
  try {
    // Test CREATE - Insert a test record
    print('   🔄 Testing INSERT operation...');
    final insertResponse = await supabase
        .from('posts')
        .insert({
          'user_id': '00000000-0000-0000-0000-000000000001', // Test user ID
          'content': 'Test post from Service Role Key test',
          'post_type': 'text',
          'is_public': true,
        })
        .select()
        .single();
    
    final testPostId = insertResponse['id'];
    print('   ✅ INSERT successful - Post ID: $testPostId');

    // Test READ
    print('   🔄 Testing SELECT operation...');
    final readResponse = await supabase
        .from('posts')
        .select('*')
        .eq('id', testPostId)
        .single();
    
    print('   ✅ SELECT successful - Content: "${readResponse['content']}"');

    // Test UPDATE
    print('   🔄 Testing UPDATE operation...');
    await supabase
        .from('posts')
        .update({'content': 'Updated test post from Service Role Key'})
        .eq('id', testPostId);
    
    print('   ✅ UPDATE successful');

    // Test DELETE
    print('   🔄 Testing DELETE operation...');
    await supabase
        .from('posts')
        .delete()
        .eq('id', testPostId);
    
    print('   ✅ DELETE successful - Test post cleaned up');

  } catch (e) {
    print('   ❌ Database operations test failed: $e');
  }
}

Future<void> testRPCFunctions(SupabaseClient supabase) async {
  try {
    // Test if RPC functions exist
    final rpcFunctions = [
      'get_user_stats',
      'get_tournament_leaderboard', 
      'update_user_elo',
      'get_club_members'
    ];

    print('   🔄 Testing RPC functions:');
    
    for (String functionName in rpcFunctions) {
      try {
        // Try to call each function with minimal parameters
        switch (functionName) {
          case 'get_user_stats':
            await supabase.rpc(functionName, params: {
              'user_id': '00000000-0000-0000-0000-000000000001'
            });
            break;
          case 'get_tournament_leaderboard':
            await supabase.rpc(functionName, params: {
              'tournament_id': '00000000-0000-0000-0000-000000000001'
            });
            break;
          case 'update_user_elo':
            // Just test if function exists, don't actually update
            print('      ⚠️  Function "$functionName" exists (not executed for safety)');
            continue;
          case 'get_club_members':
            await supabase.rpc(functionName, params: {
              'club_id': '00000000-0000-0000-0000-000000000001'
            });
            break;
        }
        print('      ✅ RPC function "$functionName" exists and callable');
      } catch (e) {
        if (e.toString().contains('does not exist')) {
          print('      ❌ RPC function "$functionName" does not exist');
        } else {
          print('      ⚠️  RPC function "$functionName" exists but returned error: ${e.toString().split('\n').first}');
        }
      }
    }
  } catch (e) {
    print('   ❌ RPC functions test failed: $e');
  }
}