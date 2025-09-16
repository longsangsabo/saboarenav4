import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  const supabaseUrl = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
  const serviceRoleKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo';

  print('🔍 Checking existing tables in Supabase database...');
  print('=' * 60);

  // List of expected tables 
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

  int existingCount = 0;
  List<String> existingTables = [];
  List<String> missingTables = [];

  for (String tableName in expectedTables) {
    try {
      final response = await http.get(
        Uri.parse('$supabaseUrl/rest/v1/$tableName?limit=1'),
        headers: {
          'Authorization': 'Bearer $serviceRoleKey',
          'apikey': serviceRoleKey,
        },
      );

      if (response.statusCode == 200) {
        print('✅ $tableName - EXISTS');
        existingTables.add(tableName);
        existingCount++;
      } else if (response.statusCode == 404) {
        print('❌ $tableName - NOT FOUND');
        missingTables.add(tableName);
      } else {
        print('⚠️  $tableName - ERROR (${response.statusCode})');
        missingTables.add(tableName);
      }
    } catch (e) {
      print('❌ $tableName - ERROR: $e');
      missingTables.add(tableName);
    }
  }

  print('-' * 60);
  print('📊 DATABASE STATUS SUMMARY');
  print('-' * 60);
  print('Total Expected Tables: ${expectedTables.length}');
  print('Existing Tables: $existingCount');
  print('Missing Tables: ${missingTables.length}');
  
  if (existingTables.isNotEmpty) {
    print('\n✅ EXISTING TABLES:');
    for (String table in existingTables) {
      print('   • $table');
    }
  }

  if (missingTables.isNotEmpty) {
    print('\n❌ MISSING TABLES:');
    for (String table in missingTables) {
      print('   • $table');
    }
  }

  // Check member management tables specifically
  print('\n🎯 MEMBER MANAGEMENT SYSTEM STATUS:');
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

  int memberExistingCount = 0;
  for (String table in memberTables) {
    if (existingTables.contains(table)) {
      memberExistingCount++;
    }
  }

  print('Member Management Tables: $memberExistingCount/${memberTables.length}');
  
  if (memberExistingCount == memberTables.length) {
    print('🎉 All member management tables are ready!');
  } else if (memberExistingCount > 0) {
    print('⚠️  Partial setup - ${memberTables.length - memberExistingCount} tables missing');
    print('💡 You may need to run the SQL schema to complete setup');
  } else {
    print('🚧 No member management tables found');
    print('💡 Run complete_member_schema.sql to create all tables');
  }

  print('\n' + '=' * 60);
  print('Database check completed!');
}