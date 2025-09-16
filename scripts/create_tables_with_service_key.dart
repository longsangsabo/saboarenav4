import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

// Supabase configuration with service role key
const String supabaseUrl = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
const String serviceRoleKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo';

/// Execute SQL using Supabase service role key
Future<Map<String, dynamic>> executeSql(String sql) async {
  try {
    // First try to create exec_sql function if it doesn't exist
    final response = await http.post(
      Uri.parse('$supabaseUrl/rest/v1/rpc/exec_sql'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serviceRoleKey',
        'apikey': serviceRoleKey,
        'Prefer': 'return=minimal',
      },
      body: jsonEncode({'sql': sql}),
    );

    if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
      return {'success': true, 'data': response.body};
    } else if (response.statusCode == 404) {
      // Function doesn't exist, try to create it first
      await createExecSqlFunction();
      // Then retry the original SQL
      return await executeSql(sql);
    } else {
      return {'success': false, 'error': 'HTTP ${response.statusCode}: ${response.body}'};
    }
  } catch (e) {
    return {'success': false, 'error': e.toString()};
  }
}

/// Create the exec_sql function using direct table creation
Future<bool> createExecSqlFunction() async {
  print('🔧 Creating exec_sql function...');
  
  try {
    // Try to execute SQL directly without function first
    final response = await http.post(
      Uri.parse('$supabaseUrl/rest/v1/rpc/exec'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serviceRoleKey',
        'apikey': serviceRoleKey,
      },
      body: jsonEncode({
        'sql': '''
        CREATE OR REPLACE FUNCTION exec_sql(sql_text text)
        RETURNS json
        LANGUAGE plpgsql
        SECURITY DEFINER
        AS \$\$
        DECLARE
            result json;
        BEGIN
            EXECUTE sql_text;
            result := '{"success": true}';
            RETURN result;
        EXCEPTION
            WHEN OTHERS THEN
                result := json_build_object('success', false, 'error', SQLERRM);
                RETURN result;
        END;
        \$\$;
        '''
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('✅ exec_sql function created successfully');
      return true;
    } else {
      print('❌ Failed to create exec_sql function: ${response.statusCode} - ${response.body}');
      return false;
    }
  } catch (e) {
    print('❌ Error creating exec_sql function: $e');
    return false;
  }
}

/// Execute SQL statements one by one with service role key
Future<void> createMemberTables() async {
  print('🚀 Starting Member Management Database Setup with Service Role Key...\n');

  // SQL statements to create all tables
  final List<Map<String, String>> sqlStatements = [
    {
      'name': 'Enable UUID Extension',
      'sql': 'CREATE EXTENSION IF NOT EXISTS "uuid-ossp";'
    },
    {
      'name': 'Create user_profiles table',
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
      'name': 'Create clubs table',
      'sql': '''
      CREATE TABLE IF NOT EXISTS public.clubs (
          id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
          owner_id UUID REFERENCES auth.users(id),
          name VARCHAR(255) NOT NULL,
          description TEXT,
          address TEXT,
          phone VARCHAR(20),
          email VARCHAR(255),
          cover_image_url TEXT,
          profile_image_url TEXT,
          total_tables INTEGER DEFAULT 0,
          price_per_hour DECIMAL(10,2),
          is_verified BOOLEAN DEFAULT false,
          is_active BOOLEAN DEFAULT true,
          approval_status VARCHAR(20) DEFAULT 'pending',
          created_at TIMESTAMPTZ DEFAULT NOW(),
          updated_at TIMESTAMPTZ DEFAULT NOW()
      );
      '''
    },
    {
      'name': 'Create club_memberships table',
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
      'name': 'Create membership_requests table',
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
      'name': 'Create chat_rooms table',
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
      'name': 'Create chat_room_members table',
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
      'name': 'Create chat_messages table',
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
      'name': 'Create announcements table',
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
      'name': 'Create announcement_reads table',
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
      'name': 'Create notifications table',
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
      'name': 'Create member_activities table',
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
      'name': 'Create member_statistics table',
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
    {
      'name': 'Enable RLS',
      'sql': '''
      ALTER TABLE public.club_memberships ENABLE ROW LEVEL SECURITY;
      ALTER TABLE public.membership_requests ENABLE ROW LEVEL SECURITY;
      ALTER TABLE public.chat_rooms ENABLE ROW LEVEL SECURITY;
      ALTER TABLE public.chat_room_members ENABLE ROW LEVEL SECURITY;
      ALTER TABLE public.chat_messages ENABLE ROW LEVEL SECURITY;
      ALTER TABLE public.announcements ENABLE ROW LEVEL SECURITY;
      ALTER TABLE public.announcement_reads ENABLE ROW LEVEL SECURITY;
      ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
      ALTER TABLE public.member_activities ENABLE ROW LEVEL SECURITY;
      ALTER TABLE public.member_statistics ENABLE ROW LEVEL SECURITY;
      '''
    },
    {
      'name': 'Create utility functions',
      'sql': '''
      CREATE OR REPLACE FUNCTION generate_membership_id()
      RETURNS TEXT AS \$\$
      BEGIN
          RETURN 'MEM' || TO_CHAR(NOW(), 'YYYYMMDD') || LPAD(FLOOR(RANDOM() * 999999)::text, 6, '0');
      END;
      \$\$ LANGUAGE plpgsql;

      CREATE OR REPLACE FUNCTION set_membership_id()
      RETURNS TRIGGER AS \$\$
      BEGIN
          IF NEW.membership_id IS NULL OR NEW.membership_id = '' THEN
              NEW.membership_id := generate_membership_id();
          END IF;
          RETURN NEW;
      END;
      \$\$ LANGUAGE plpgsql;

      CREATE OR REPLACE FUNCTION update_updated_at_column()
      RETURNS TRIGGER AS \$\$
      BEGIN
          NEW.updated_at = NOW();
          RETURN NEW;
      END;
      \$\$ LANGUAGE plpgsql;
      '''
    },
    {
      'name': 'Create triggers',
      'sql': '''
      DROP TRIGGER IF EXISTS trigger_set_membership_id ON public.club_memberships;
      CREATE TRIGGER trigger_set_membership_id
          BEFORE INSERT ON public.club_memberships
          FOR EACH ROW
          EXECUTE FUNCTION set_membership_id();

      DROP TRIGGER IF EXISTS trigger_update_club_memberships_updated_at ON public.club_memberships;
      CREATE TRIGGER trigger_update_club_memberships_updated_at
          BEFORE UPDATE ON public.club_memberships
          FOR EACH ROW
          EXECUTE FUNCTION update_updated_at_column();
      '''
    },
    {
      'name': 'Create RLS policies',
      'sql': '''
      DROP POLICY IF EXISTS "club_membership_select" ON public.club_memberships;
      CREATE POLICY "club_membership_select" ON public.club_memberships
      FOR SELECT USING (
          club_id IN (
              SELECT id FROM public.clubs 
              WHERE owner_id = auth.uid()
          ) OR user_id = auth.uid()
      );

      DROP POLICY IF EXISTS "notification_select" ON public.notifications;
      CREATE POLICY "notification_select" ON public.notifications
      FOR SELECT USING (user_id = auth.uid());
      '''
    },
  ];

  // First, try to create the exec_sql function
  print('🔧 Setting up exec_sql function...');
  await createExecSqlFunction();
  
  print('\n📊 Creating Member Management Tables...\n');

  int successCount = 0;
  int totalCount = sqlStatements.length;

  for (int i = 0; i < sqlStatements.length; i++) {
    final statement = sqlStatements[i];
    print('📝 ${i + 1}/$totalCount: ${statement['name']}...');
    
    final result = await executeSql(statement['sql']!);
    
    if (result['success']) {
      print('   ✅ Success');
      successCount++;
    } else {
      print('   ❌ Failed: ${result['error']}');
    }
    
    // Small delay between executions
    await Future.delayed(Duration(milliseconds: 200));
  }

  print('\n🎉 Database Setup Complete!');
  print('📊 Summary: $successCount/$totalCount operations successful');
  
  if (successCount == totalCount) {
    print('\n✅ ALL MEMBER MANAGEMENT TABLES CREATED SUCCESSFULLY!');
    print('🔍 Created Tables:');
    print('  • user_profiles');
    print('  • clubs'); 
    print('  • club_memberships');
    print('  • membership_requests');
    print('  • chat_rooms');
    print('  • chat_room_members');
    print('  • chat_messages');
    print('  • announcements');
    print('  • announcement_reads');
    print('  • notifications');
    print('  • member_activities');
    print('  • member_statistics');
    print('\n🔒 Security Features:');
    print('  • Row Level Security enabled');
    print('  • Access policies configured');
    print('\n⚡ Performance Features:');
    print('  • Database indexes created');
    print('  • Automatic triggers setup');
    print('\n🎯 Member Management System Ready!');
  } else {
    print('\n⚠️ Some operations failed. Check logs above.');
  }
}

void main() async {
  try {
    await createMemberTables();
  } catch (e) {
    print('\n❌ Fatal error: $e');
  }
}