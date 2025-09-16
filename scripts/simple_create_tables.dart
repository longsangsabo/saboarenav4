import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

// Supabase configuration
const String supabaseUrl = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
const String serviceRoleKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo';

/// Execute SQL directly through Supabase REST API
Future<Map<String, dynamic>> executeDirectSQL(String sql) async {
  try {
    print('🔄 Executing SQL...');
    
    // Use the REST API to execute SQL
    final response = await http.post(
      Uri.parse('$supabaseUrl/rest/v1/rpc/exec_sql'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serviceRoleKey',
        'apikey': serviceRoleKey,
      },
      body: jsonEncode({'query': sql}),
    );

    print('📡 Response status: ${response.statusCode}');
    print('📋 Response body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return {'success': true, 'data': response.body};
    } else {
      return {'success': false, 'error': 'HTTP ${response.statusCode}: ${response.body}'};
    }
  } catch (e) {
    return {'success': false, 'error': 'Exception: $e'};
  }
}

/// Create tables using direct table creation endpoint
Future<Map<String, dynamic>> createTable(String tableName, Map<String, dynamic> tableSchema) async {
  try {
    print('🔄 Creating table: $tableName...');
    
    final response = await http.post(
      Uri.parse('$supabaseUrl/rest/v1/$tableName'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serviceRoleKey',
        'apikey': serviceRoleKey,
        'Prefer': 'return=minimal',
      },
      body: jsonEncode(tableSchema),
    );

    print('📡 Response status: ${response.statusCode}');
    
    if (response.statusCode == 201 || response.statusCode == 200) {
      return {'success': true};
    } else {
      return {'success': false, 'error': 'HTTP ${response.statusCode}: ${response.body}'};
    }
  } catch (e) {
    return {'success': false, 'error': 'Exception: $e'};
  }
}

/// Test Supabase connection and check existing tables
Future<void> testConnection() async {
  print('🔗 Testing Supabase connection...\n');
  
  try {
    // Test basic connection by querying existing tables
    final response = await http.get(
      Uri.parse('$supabaseUrl/rest/v1/clubs?select=id&limit=1'),
      headers: {
        'Authorization': 'Bearer $serviceRoleKey',
        'apikey': serviceRoleKey,
      },
    );

    print('📡 Connection test response: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      print('✅ Supabase connection successful!');
      print('📋 Response: ${response.body}');
      
      // Check if clubs table exists and has data
      final data = jsonDecode(response.body);
      if (data is List) {
        print('🏢 Found ${data.length} clubs in database');
      }
    } else {
      print('❌ Connection failed: ${response.statusCode}');
      print('📋 Error: ${response.body}');
    }
  } catch (e) {
    print('❌ Connection error: $e');
  }
  
  print('\n' + '='*50 + '\n');
}

/// Execute raw SQL using a simple approach
Future<void> createMemberTablesSimple() async {
  print('🚀 Starting Simple Member Tables Creation...\n');
  
  // Test connection first
  await testConnection();
  
  // List of table creation SQLs - simplified approach
  final Map<String, String> tables = {
    'user_profiles': '''
    CREATE TABLE IF NOT EXISTS public.user_profiles (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        user_id UUID,
        email VARCHAR(255),
        display_name VARCHAR(100),
        avatar_url TEXT,
        phone VARCHAR(20),
        created_at TIMESTAMPTZ DEFAULT NOW()
    );
    ''',
    
    'club_memberships': '''
    CREATE TABLE IF NOT EXISTS public.club_memberships (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        club_id UUID,
        user_id UUID,
        membership_id VARCHAR(50) UNIQUE,
        membership_type VARCHAR(20) DEFAULT 'regular',
        status VARCHAR(20) DEFAULT 'active',
        role VARCHAR(20) DEFAULT 'member',
        joined_at TIMESTAMPTZ DEFAULT NOW(),
        created_at TIMESTAMPTZ DEFAULT NOW()
    );
    ''',
    
    'membership_requests': '''
    CREATE TABLE IF NOT EXISTS public.membership_requests (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        club_id UUID,
        user_id UUID,
        membership_type VARCHAR(20) DEFAULT 'regular',
        status VARCHAR(20) DEFAULT 'pending',
        message TEXT,
        created_at TIMESTAMPTZ DEFAULT NOW()
    );
    ''',
    
    'notifications': '''
    CREATE TABLE IF NOT EXISTS public.notifications (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        user_id UUID,
        club_id UUID,
        type VARCHAR(50) NOT NULL,
        title VARCHAR(255) NOT NULL,
        message TEXT NOT NULL,
        is_read BOOLEAN DEFAULT false,
        created_at TIMESTAMPTZ DEFAULT NOW()
    );
    ''',
    
    'member_activities': '''
    CREATE TABLE IF NOT EXISTS public.member_activities (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        club_id UUID,
        user_id UUID,
        action VARCHAR(100) NOT NULL,
        description TEXT,
        created_at TIMESTAMPTZ DEFAULT NOW()
    );
    '''
  };

  print('📊 Creating ${tables.length} member management tables...\n');
  
  int successCount = 0;
  
  for (final entry in tables.entries) {
    final tableName = entry.key;
    final sql = entry.value;
    
    print('📝 Creating table: $tableName');
    
    try {
      // Try to create table using direct SQL execution
      final result = await executeDirectSQL(sql);
      
      if (result['success']) {
        print('   ✅ Table $tableName created successfully');
        successCount++;
      } else {
        print('   ❌ Failed to create $tableName: ${result['error']}');
        
        // Try alternative approach - check if table exists
        await checkTableExists(tableName);
      }
    } catch (e) {
      print('   ❌ Exception creating $tableName: $e');
    }
    
    print('');
    await Future.delayed(Duration(milliseconds: 500));
  }

  print('🎉 Table Creation Summary:');
  print('✅ Success: $successCount/${tables.length} tables');
  
  if (successCount > 0) {
    print('\n🎯 Member Management System tables are ready!');
  } else {
    print('\n⚠️ No tables were created. Checking existing tables...');
    await checkAllTables();
  }
}

/// Check if a table exists
Future<void> checkTableExists(String tableName) async {
  try {
    final response = await http.get(
      Uri.parse('$supabaseUrl/rest/v1/$tableName?select=id&limit=1'),
      headers: {
        'Authorization': 'Bearer $serviceRoleKey',
        'apikey': serviceRoleKey,
      },
    );

    if (response.statusCode == 200) {
      print('   ℹ️ Table $tableName already exists');
    } else {
      print('   ⚠️ Table $tableName does not exist (${response.statusCode})');
    }
  } catch (e) {
    print('   ❓ Could not check table $tableName: $e');
  }
}

/// Check all tables
Future<void> checkAllTables() async {
  final tables = [
    'user_profiles',
    'clubs',
    'club_memberships', 
    'membership_requests',
    'notifications',
    'member_activities'
  ];
  
  print('\n🔍 Checking existing tables:');
  
  for (final table in tables) {
    await checkTableExists(table);
  }
}

void main() async {
  try {
    await createMemberTablesSimple();
  } catch (e) {
    print('\n❌ Fatal error: $e');
  }
}