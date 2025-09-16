import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

const String supabaseUrl = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
const String serviceRoleKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo';

/// First create the exec_sql function that we need
Future<bool> createExecSqlFunction() async {
  print('🔧 Creating exec_sql function first...\n');
  
  try {
    // Use the /rest/v1/ endpoint to create a function via SQL
    final createFunctionSql = '''
    CREATE OR REPLACE FUNCTION exec_sql(query text)
    RETURNS json
    LANGUAGE plpgsql
    SECURITY DEFINER
    AS \$\$
    DECLARE
        result json;
    BEGIN
        EXECUTE query;
        result := '{"success": true}';
        RETURN result;
    EXCEPTION
        WHEN OTHERS THEN
            result := json_build_object('success', false, 'error', SQLERRM);
            RETURN result;
    END;
    \$\$;
    ''';
    
    // Try to create the function by inserting into pg_proc (won't work due to security)
    // Let's try a different approach - use the database's SQL execution
    
    print('ℹ️ The exec_sql function needs to be created manually in Supabase dashboard.');
    print('Please follow these steps:\n');
    
    print('1. Go to: https://supabase.com/dashboard/project/mogjjvscxjwvhtpkrlqr/sql/new');
    print('2. Paste this SQL and click RUN:\n');
    
    print('='*60);
    print(createFunctionSql);
    print('='*60);
    
    print('\n3. After running the SQL, press Enter to continue...');
    
    // Wait for user input
    stdin.readLineSync();
    
    return true;
  } catch (e) {
    print('❌ Error: $e');
    return false;
  }
}

/// Test if exec_sql function exists
Future<bool> testExecSqlFunction() async {
  print('\n🧪 Testing exec_sql function...');
  
  try {
    final response = await http.post(
      Uri.parse('$supabaseUrl/rest/v1/rpc/exec_sql'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serviceRoleKey',
        'apikey': serviceRoleKey,
      },
      body: jsonEncode({'query': 'SELECT 1 as test'}),
    );

    print('📡 Test response: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      print('✅ exec_sql function is working!');
      return true;
    } else {
      print('❌ exec_sql function not available: ${response.body}');
      return false;
    }
  } catch (e) {
    print('❌ Test failed: $e');
    return false;
  }
}

/// Execute SQL using the exec_sql function
Future<Map<String, dynamic>> executeSql(String sql) async {
  try {
    final response = await http.post(
      Uri.parse('$supabaseUrl/rest/v1/rpc/exec_sql'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serviceRoleKey',
        'apikey': serviceRoleKey,
      },
      body: jsonEncode({'query': sql}),
    );

    if (response.statusCode == 200) {
      return {'success': true, 'data': response.body};
    } else {
      return {'success': false, 'error': 'HTTP ${response.statusCode}: ${response.body}'};
    }
  } catch (e) {
    return {'success': false, 'error': e.toString()};
  }
}

/// Create all member management tables
Future<void> createMemberTables() async {
  print('\n🚀 Creating Member Management Tables...\n');

  final List<Map<String, String>> tables = [
    {
      'name': 'Enable UUID Extension',
      'sql': 'CREATE EXTENSION IF NOT EXISTS "uuid-ossp";'
    },
    {
      'name': 'user_profiles table',
      'sql': '''
      CREATE TABLE IF NOT EXISTS public.user_profiles (
          id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
          user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
          email VARCHAR(255) UNIQUE,
          display_name VARCHAR(100),
          avatar_url TEXT,
          phone VARCHAR(20),
          date_of_birth DATE,
          gender VARCHAR(10),
          location TEXT,
          bio TEXT,
          created_at TIMESTAMPTZ DEFAULT NOW(),
          updated_at TIMESTAMPTZ DEFAULT NOW()
      );
      '''
    },
    {
      'name': 'club_memberships table',
      'sql': '''
      CREATE TABLE IF NOT EXISTS public.club_memberships (
          id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
          club_id UUID REFERENCES public.clubs(id) ON DELETE CASCADE,
          user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
          membership_id VARCHAR(50) UNIQUE NOT NULL,
          membership_type VARCHAR(20) DEFAULT 'regular',
          status VARCHAR(20) DEFAULT 'active',
          role VARCHAR(20) DEFAULT 'member',
          joined_at TIMESTAMPTZ DEFAULT NOW(),
          expires_at TIMESTAMPTZ,
          notes TEXT,
          created_by UUID REFERENCES auth.users(id),
          created_at TIMESTAMPTZ DEFAULT NOW(),
          updated_at TIMESTAMPTZ DEFAULT NOW(),
          UNIQUE(club_id, user_id)
      );
      '''
    },
    {
      'name': 'membership_requests table',
      'sql': '''
      CREATE TABLE IF NOT EXISTS public.membership_requests (
          id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
          club_id UUID REFERENCES public.clubs(id) ON DELETE CASCADE,
          user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
          membership_type VARCHAR(20) DEFAULT 'regular',
          status VARCHAR(20) DEFAULT 'pending',
          message TEXT,
          processed_by UUID REFERENCES auth.users(id),
          processed_at TIMESTAMPTZ,
          rejection_reason TEXT,
          notes TEXT,
          additional_data JSONB,
          created_at TIMESTAMPTZ DEFAULT NOW(),
          updated_at TIMESTAMPTZ DEFAULT NOW()
      );
      '''
    },
    {
      'name': 'chat_rooms table',
      'sql': '''
      CREATE TABLE IF NOT EXISTS public.chat_rooms (
          id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
          club_id UUID REFERENCES public.clubs(id) ON DELETE CASCADE,
          name VARCHAR(255) NOT NULL,
          description TEXT,
          type VARCHAR(20) DEFAULT 'general',
          is_private BOOLEAN DEFAULT false,
          created_by UUID REFERENCES auth.users(id),
          created_at TIMESTAMPTZ DEFAULT NOW(),
          updated_at TIMESTAMPTZ DEFAULT NOW()
      );
      '''
    },
    {
      'name': 'chat_room_members table',
      'sql': '''
      CREATE TABLE IF NOT EXISTS public.chat_room_members (
          id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
          room_id UUID REFERENCES public.chat_rooms(id) ON DELETE CASCADE,
          user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
          joined_at TIMESTAMPTZ DEFAULT NOW(),
          role VARCHAR(20) DEFAULT 'member',
          UNIQUE(room_id, user_id)
      );
      '''
    },
    {
      'name': 'chat_messages table',
      'sql': '''
      CREATE TABLE IF NOT EXISTS public.chat_messages (
          id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
          room_id UUID REFERENCES public.chat_rooms(id) ON DELETE CASCADE,
          sender_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
          message TEXT NOT NULL,
          message_type VARCHAR(20) DEFAULT 'text',
          attachments JSONB,
          reply_to UUID REFERENCES public.chat_messages(id),
          edited_at TIMESTAMPTZ,
          is_deleted BOOLEAN DEFAULT false,
          created_at TIMESTAMPTZ DEFAULT NOW()
      );
      '''
    },
    {
      'name': 'announcements table',
      'sql': '''
      CREATE TABLE IF NOT EXISTS public.announcements (
          id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
          club_id UUID REFERENCES public.clubs(id) ON DELETE CASCADE,
          title VARCHAR(255) NOT NULL,
          content TEXT NOT NULL,
          priority VARCHAR(20) DEFAULT 'normal',
          type VARCHAR(20) DEFAULT 'general',
          is_pinned BOOLEAN DEFAULT false,
          expires_at TIMESTAMPTZ,
          target_roles TEXT[] DEFAULT ARRAY['member'],
          attachments JSONB,
          created_by UUID REFERENCES auth.users(id),
          created_at TIMESTAMPTZ DEFAULT NOW(),
          updated_at TIMESTAMPTZ DEFAULT NOW()
      );
      '''
    },
    {
      'name': 'announcement_reads table',
      'sql': '''
      CREATE TABLE IF NOT EXISTS public.announcement_reads (
          id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
          announcement_id UUID REFERENCES public.announcements(id) ON DELETE CASCADE,
          user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
          read_at TIMESTAMPTZ DEFAULT NOW(),
          UNIQUE(announcement_id, user_id)
      );
      '''
    },
    {
      'name': 'notifications table',
      'sql': '''
      CREATE TABLE IF NOT EXISTS public.notifications (
          id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
          user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
          club_id UUID REFERENCES public.clubs(id) ON DELETE CASCADE,
          type VARCHAR(50) NOT NULL,
          title VARCHAR(255) NOT NULL,
          message TEXT NOT NULL,
          data JSONB,
          is_read BOOLEAN DEFAULT false,
          read_at TIMESTAMPTZ,
          priority VARCHAR(20) DEFAULT 'normal',
          created_at TIMESTAMPTZ DEFAULT NOW()
      );
      '''
    },
    {
      'name': 'member_activities table',
      'sql': '''
      CREATE TABLE IF NOT EXISTS public.member_activities (
          id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
          club_id UUID REFERENCES public.clubs(id) ON DELETE CASCADE,
          user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
          action VARCHAR(100) NOT NULL,
          description TEXT,
          metadata JSONB,
          ip_address INET,
          user_agent TEXT,
          created_at TIMESTAMPTZ DEFAULT NOW()
      );
      '''
    },
    {
      'name': 'member_statistics table',
      'sql': '''
      CREATE TABLE IF NOT EXISTS public.member_statistics (
          id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
          club_id UUID REFERENCES public.clubs(id) ON DELETE CASCADE,
          user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
          matches_played INTEGER DEFAULT 0,
          matches_won INTEGER DEFAULT 0,
          matches_lost INTEGER DEFAULT 0,
          tournaments_joined INTEGER DEFAULT 0,
          tournaments_won INTEGER DEFAULT 0,
          total_score INTEGER DEFAULT 0,
          average_score DECIMAL(5,2) DEFAULT 0.00,
          last_activity_at TIMESTAMPTZ,
          updated_at TIMESTAMPTZ DEFAULT NOW(),
          UNIQUE(club_id, user_id)
      );
      '''
    },
    {
      'name': 'Create indexes',
      'sql': '''
      CREATE INDEX IF NOT EXISTS idx_club_memberships_club_id ON public.club_memberships(club_id);
      CREATE INDEX IF NOT EXISTS idx_club_memberships_user_id ON public.club_memberships(user_id);
      CREATE INDEX IF NOT EXISTS idx_club_memberships_status ON public.club_memberships(status);
      CREATE INDEX IF NOT EXISTS idx_membership_requests_club_id ON public.membership_requests(club_id);
      CREATE INDEX IF NOT EXISTS idx_membership_requests_status ON public.membership_requests(status);
      CREATE INDEX IF NOT EXISTS idx_chat_messages_room_id ON public.chat_messages(room_id);
      CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON public.notifications(user_id);
      CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON public.notifications(is_read);
      '''
    },
  ];

  int successCount = 0;
  int totalCount = tables.length;

  for (int i = 0; i < tables.length; i++) {
    final table = tables[i];
    print('📝 ${i + 1}/$totalCount: Creating ${table['name']}...');
    
    final result = await executeSql(table['sql']!);
    
    if (result['success']) {
      print('   ✅ Success');
      successCount++;
    } else {
      print('   ❌ Failed: ${result['error']}');
    }
    
    await Future.delayed(Duration(milliseconds: 200));
  }

  print('\n🎉 Table Creation Complete!');
  print('📊 Success: $successCount/$totalCount tables created');
  
  if (successCount > 0) {
    print('\n✅ Member Management System Ready!');
    print('🎯 Created tables for comprehensive member management');
  }
}

void main() async {
  try {
    // Step 1: Check if exec_sql function exists
    bool functionExists = await testExecSqlFunction();
    
    if (!functionExists) {
      // Step 2: Guide user to create the function
      await createExecSqlFunction();
      
      // Step 3: Test again
      functionExists = await testExecSqlFunction();
    }
    
    if (functionExists) {
      // Step 4: Create all tables
      await createMemberTables();
    } else {
      print('\n❌ Cannot proceed without exec_sql function.');
      print('Please create it manually in Supabase dashboard first.');
    }
    
  } catch (e) {
    print('\n❌ Fatal error: $e');
  }
}