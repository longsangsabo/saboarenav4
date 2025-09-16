import 'dart:convert';
import 'dart:i      if (data is List && data.isNotEmpty) {
        print('📊 Existing tables in public schema:');
        print('-' * 40);
        for (var table in data) {
          print('✓ ${table['table_name']}');
        }
        print('-' * 40);
        print('Total tables: ${data.length}');rt 'package:http/http.dart' as http;

void main() async {
  const supabaseUrl = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
  const serviceRoleKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo';

  print('🔍 Checking existing tables in Supabase database...');
  print('=' * 60);

  try {
    // Query to get all tables in public schema
    const query = '''
    SELECT 
      table_name,
      table_type
    FROM information_schema.tables 
    WHERE table_schema = 'public'
    AND table_type = 'BASE TABLE'
    ORDER BY table_name;
    ''';

    final response = await http.post(
      Uri.parse('\$supabaseUrl/rest/v1/rpc/exec_sql'),
      headers: {
        'Authorization': 'Bearer \$serviceRoleKey',
        'Content-Type': 'application/json',
        'apikey': serviceRoleKey,
      },
      body: json.encode({
        'query': query,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List && data.isNotEmpty) {
        print('📊 Existing tables in public schema:');
        print('-'.repeat(40));
        for (var table in data) {
          print('✓ \${table['table_name']}');
        }
        print('-'.repeat(40));
        print('Total tables: \${data.length}');
      } else {
        print('❌ No tables found in public schema');
      }
    } else if (response.statusCode == 404) {
      print('❌ exec_sql function not found. Trying alternative method...');
      await checkTablesAlternative(supabaseUrl, serviceRoleKey);
    } else {
      print('❌ Error: \${response.statusCode}');
      print('Response: \${response.body}');
    }

    // Also check specific tables we're interested in
    await checkSpecificTables(supabaseUrl, serviceRoleKey);

  } catch (e) {
    print('❌ Error checking database: \$e');
  }
}

Future<void> checkTablesAlternative(String supabaseUrl, String serviceRoleKey) async {
  print('🔄 Trying to check tables using REST API...');
  
  // List of tables we expect to exist
  final expectedTables = [
    'clubs',
    'tournaments', 
    'posts',
    'user_profiles',
    'club_memberships',
    'membership_requests',
    'chat_rooms',
    'chat_room_members',
    'chat_messages',
    'announcements',
    'announcement_reads',
    'notifications',
    'member_activities',
    'member_statistics',
  ];

  print('📋 Checking for expected tables:');
  print('-' * 40);

  for (String tableName in expectedTables) {
    try {
      final response = await http.get(
        Uri.parse('\$supabaseUrl/rest/v1/\$tableName?limit=1'),
        headers: {
          'Authorization': 'Bearer \$serviceRoleKey',
          'apikey': serviceRoleKey,
        },
      );

      if (response.statusCode == 200) {
        print('✅ \$tableName - EXISTS');
      } else if (response.statusCode == 404) {
        print('❌ \$tableName - NOT FOUND');
      } else {
        print('⚠️  \$tableName - ERROR (\${response.statusCode})');
      }
    } catch (e) {
      print('❌ \$tableName - ERROR: \$e');
    }
  }
}

Future<void> checkSpecificTables(String supabaseUrl, String serviceRoleKey) async {
  print('\n🎯 Checking member management tables specifically:');
  print('-' * 50);

  final memberTables = [
    'club_memberships',
    'membership_requests', 
    'chat_rooms',
    'chat_room_members',
    'chat_messages',
    'announcements',
    'announcement_reads',
    'notifications',
    'member_activities',
    'member_statistics',
  ];

  int existingCount = 0;
  int totalCount = memberTables.length;

  for (String tableName in memberTables) {
    try {
      final response = await http.get(
        Uri.parse('\$supabaseUrl/rest/v1/\$tableName?limit=1'),
        headers: {
          'Authorization': 'Bearer \$serviceRoleKey',
          'apikey': serviceRoleKey,
        },
      );

      if (response.statusCode == 200) {
        print('✅ \$tableName');
        existingCount++;
      } else {
        print('❌ \$tableName');
      }
    } catch (e) {
      print('❌ \$tableName');
    }
  }

  print('-' * 50);
  print('📈 Member Management Tables Status:');
  print('   Existing: \$existingCount/\$totalCount tables');
  
  if (existingCount == totalCount) {
    print('🎉 All member management tables are ready!');
  } else if (existingCount > 0) {
    print('⚠️  Partial setup - \${totalCount - existingCount} tables missing');
  } else {
    print('🚧 No member management tables found - need to create schema');
  }
}