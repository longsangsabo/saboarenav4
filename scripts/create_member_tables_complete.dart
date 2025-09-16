import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

// Supabase configuration
const String supabaseUrl = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
const String serviceRoleKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo';

/// Execute SQL query using Supabase REST API
Future<Map<String, dynamic>> execSql(String sql) async {
  try {
    final response = await http.post(
      Uri.parse('$supabaseUrl/rest/v1/rpc/exec_sql'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serviceRoleKey',
        'apikey': serviceRoleKey,
      },
      body: jsonEncode({
        'sql': sql,
      }),
    );

    print('📡 SQL Execution Response: ${response.statusCode}');
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      print('✅ SQL executed successfully');
      return {'success': true, 'data': response.body};
    } else {
      print('❌ SQL execution failed: ${response.statusCode}');
      print('Response: ${response.body}');
      return {'success': false, 'error': response.body};
    }
  } catch (e) {
    print('❌ Error executing SQL: $e');
    return {'success': false, 'error': e.toString()};
  }
}

/// Execute SQL using direct query approach
Future<Map<String, dynamic>> execQuery(String sql) async {
  try {
    // Try to execute as a direct query
    final response = await http.post(
      Uri.parse('$supabaseUrl/rest/v1/query'),
      headers: {
        'Content-Type': 'text/plain',
        'Authorization': 'Bearer $serviceRoleKey',
        'apikey': serviceRoleKey,
      },
      body: sql,
    );

    print('📡 Query Execution Response: ${response.statusCode}');
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      print('✅ Query executed successfully');
      return {'success': true, 'data': response.body};
    } else {
      print('❌ Query execution failed: ${response.statusCode}');
      print('Response: ${response.body}');
      return {'success': false, 'error': response.body};
    }
  } catch (e) {
    print('❌ Error executing query: $e');
    return {'success': false, 'error': e.toString()};
  }
}

/// Create the exec_sql function if it doesn't exist
Future<void> createExecSqlFunction() async {
  print('🔧 Creating exec_sql function...');
  
  const String createFunctionSql = '''
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
''';

  final result = await execQuery(createFunctionSql);
  if (result['success']) {
    print('✅ exec_sql function created successfully');
  } else {
    print('❌ Failed to create exec_sql function: ${result['error']}');
  }
}

/// Main function to create all member management tables
void main() async {
  print('🚀 Starting Member Management Database Setup...\n');

  // First, try to create the exec_sql function
  await createExecSqlFunction();
  
  print('\n📊 Creating Member Management Tables...\n');

  // List of all SQL statements to execute
  final List<String> sqlStatements = [
    // 1. Create user_profiles table if not exists
    '''
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
    ''',

    // 2. Create clubs table if not exists
    '''
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
    ''',

    // 3. Club memberships table
    '''
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
    ''',

    // 4. Membership requests table
    '''
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
    ''',

    // 5. Chat rooms table
    '''
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
    ''',

    // 6. Chat room members table
    '''
    CREATE TABLE IF NOT EXISTS public.chat_room_members (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        room_id UUID REFERENCES public.chat_rooms(id) ON DELETE CASCADE,
        user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
        joined_at TIMESTAMPTZ DEFAULT NOW(),
        role VARCHAR(20) DEFAULT 'member',
        UNIQUE(room_id, user_id)
    );
    ''',

    // 7. Chat messages table
    '''
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
    ''',

    // 8. Announcements table
    '''
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
    ''',

    // 9. Announcement reads table
    '''
    CREATE TABLE IF NOT EXISTS public.announcement_reads (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        announcement_id UUID REFERENCES public.announcements(id) ON DELETE CASCADE,
        user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
        read_at TIMESTAMPTZ DEFAULT NOW(),
        UNIQUE(announcement_id, user_id)
    );
    ''',

    // 10. Notifications table
    '''
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
    ''',

    // 11. Member activities table
    '''
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
    ''',

    // 12. Member statistics table
    '''
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
    ''',

    // 13. Create indexes for performance
    '''
    CREATE INDEX IF NOT EXISTS idx_club_memberships_club_id ON public.club_memberships(club_id);
    CREATE INDEX IF NOT EXISTS idx_club_memberships_user_id ON public.club_memberships(user_id);
    CREATE INDEX IF NOT EXISTS idx_club_memberships_status ON public.club_memberships(status);
    CREATE INDEX IF NOT EXISTS idx_membership_requests_club_id ON public.membership_requests(club_id);
    CREATE INDEX IF NOT EXISTS idx_membership_requests_status ON public.membership_requests(status);
    CREATE INDEX IF NOT EXISTS idx_chat_messages_room_id ON public.chat_messages(room_id);
    CREATE INDEX IF NOT EXISTS idx_chat_messages_created_at ON public.chat_messages(created_at);
    CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON public.notifications(user_id);
    CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON public.notifications(is_read);
    CREATE INDEX IF NOT EXISTS idx_member_activities_club_id ON public.member_activities(club_id);
    CREATE INDEX IF NOT EXISTS idx_member_activities_user_id ON public.member_activities(user_id);
    ''',

    // 14. Create RLS policies
    '''
    -- Enable RLS on all tables
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
    ''',

    // 15. Club membership policies
    '''
    CREATE POLICY "club_membership_select" ON public.club_memberships
    FOR SELECT USING (
        club_id IN (
            SELECT id FROM public.clubs 
            WHERE owner_id = auth.uid()
        ) OR user_id = auth.uid()
    );
    
    CREATE POLICY "club_membership_insert" ON public.club_memberships
    FOR INSERT WITH CHECK (
        club_id IN (
            SELECT id FROM public.clubs 
            WHERE owner_id = auth.uid()
        )
    );
    
    CREATE POLICY "club_membership_update" ON public.club_memberships
    FOR UPDATE USING (
        club_id IN (
            SELECT id FROM public.clubs 
            WHERE owner_id = auth.uid()
        )
    );
    
    CREATE POLICY "club_membership_delete" ON public.club_memberships
    FOR DELETE USING (
        club_id IN (
            SELECT id FROM public.clubs 
            WHERE owner_id = auth.uid()
        )
    );
    ''',

    // 16. Membership request policies
    '''
    CREATE POLICY "membership_request_select" ON public.membership_requests
    FOR SELECT USING (
        club_id IN (
            SELECT id FROM public.clubs 
            WHERE owner_id = auth.uid()
        ) OR user_id = auth.uid()
    );
    
    CREATE POLICY "membership_request_insert" ON public.membership_requests
    FOR INSERT WITH CHECK (user_id = auth.uid());
    
    CREATE POLICY "membership_request_update" ON public.membership_requests
    FOR UPDATE USING (
        club_id IN (
            SELECT id FROM public.clubs 
            WHERE owner_id = auth.uid()
        )
    );
    ''',

    // 17. Notification policies
    '''
    CREATE POLICY "notification_select" ON public.notifications
    FOR SELECT USING (user_id = auth.uid());
    
    CREATE POLICY "notification_update" ON public.notifications
    FOR UPDATE USING (user_id = auth.uid());
    ''',

    // 18. Chat room policies
    '''
    CREATE POLICY "chat_room_select" ON public.chat_rooms
    FOR SELECT USING (
        club_id IN (
            SELECT club_id FROM public.club_memberships 
            WHERE user_id = auth.uid() AND status = 'active'
        )
    );
    ''',

    // 19. Chat message policies
    '''
    CREATE POLICY "chat_message_select" ON public.chat_messages
    FOR SELECT USING (
        room_id IN (
            SELECT cr.id FROM public.chat_rooms cr
            JOIN public.chat_room_members crm ON cr.id = crm.room_id
            WHERE crm.user_id = auth.uid()
        )
    );
    
    CREATE POLICY "chat_message_insert" ON public.chat_messages
    FOR INSERT WITH CHECK (
        sender_id = auth.uid() AND
        room_id IN (
            SELECT cr.id FROM public.chat_rooms cr
            JOIN public.chat_room_members crm ON cr.id = crm.room_id
            WHERE crm.user_id = auth.uid()
        )
    );
    ''',

    // 20. Create utility functions
    '''
    -- Function to generate membership ID
    CREATE OR REPLACE FUNCTION generate_membership_id()
    RETURNS TEXT AS \$\$
    BEGIN
        RETURN 'MEM' || TO_CHAR(NOW(), 'YYYYMMDD') || LPAD(EXTRACT(epoch FROM NOW())::text, 6, '0');
    END;
    \$\$ LANGUAGE plpgsql;
    ''',

    // 21. Create triggers for automatic membership ID
    '''
    CREATE OR REPLACE FUNCTION set_membership_id()
    RETURNS TRIGGER AS \$\$
    BEGIN
        IF NEW.membership_id IS NULL OR NEW.membership_id = '' THEN
            NEW.membership_id := generate_membership_id();
        END IF;
        RETURN NEW;
    END;
    \$\$ LANGUAGE plpgsql;
    
    DROP TRIGGER IF EXISTS trigger_set_membership_id ON public.club_memberships;
    CREATE TRIGGER trigger_set_membership_id
        BEFORE INSERT ON public.club_memberships
        FOR EACH ROW
        EXECUTE FUNCTION set_membership_id();
    ''',

    // 22. Create triggers for updated_at
    '''
    CREATE OR REPLACE FUNCTION update_updated_at_column()
    RETURNS TRIGGER AS \$\$
    BEGIN
        NEW.updated_at = NOW();
        RETURN NEW;
    END;
    \$\$ LANGUAGE plpgsql;
    
    DROP TRIGGER IF EXISTS trigger_update_club_memberships_updated_at ON public.club_memberships;
    CREATE TRIGGER trigger_update_club_memberships_updated_at
        BEFORE UPDATE ON public.club_memberships
        FOR EACH ROW
        EXECUTE FUNCTION update_updated_at_column();
    
    DROP TRIGGER IF EXISTS trigger_update_membership_requests_updated_at ON public.membership_requests;
    CREATE TRIGGER trigger_update_membership_requests_updated_at
        BEFORE UPDATE ON public.membership_requests
        FOR EACH ROW
        EXECUTE FUNCTION update_updated_at_column();
        
    DROP TRIGGER IF EXISTS trigger_update_announcements_updated_at ON public.announcements;
    CREATE TRIGGER trigger_update_announcements_updated_at
        BEFORE UPDATE ON public.announcements
        FOR EACH ROW
        EXECUTE FUNCTION update_updated_at_column();
    ''',

    // 23. Insert sample chat room for each club
    '''
    INSERT INTO public.chat_rooms (club_id, name, description, type, created_by)
    SELECT 
        c.id,
        'General Discussion',
        'General chat room for all club members',
        'general',
        c.owner_id
    FROM public.clubs c
    WHERE NOT EXISTS (
        SELECT 1 FROM public.chat_rooms cr 
        WHERE cr.club_id = c.id AND cr.type = 'general'
    );
    ''',
  ];

  // Execute each SQL statement
  int successCount = 0;
  int totalCount = sqlStatements.length;

  for (int i = 0; i < sqlStatements.length; i++) {
    final sql = sqlStatements[i];
    print('📝 Executing statement ${i + 1}/$totalCount...');
    
    final result = await execQuery(sql);
    
    if (result['success']) {
      print('✅ Statement ${i + 1} executed successfully');
      successCount++;
    } else {
      print('❌ Statement ${i + 1} failed: ${result['error']}');
    }
    
    // Small delay between executions
    await Future.delayed(Duration(milliseconds: 100));
  }

  print('\n🎉 Database Setup Complete!');
  print('📊 Summary: $successCount/$totalCount statements executed successfully');
  
  if (successCount == totalCount) {
    print('✅ All member management tables created successfully!');
  } else {
    print('⚠️ Some operations failed. Please check the logs above.');
  }
  
  print('\n🔍 Created Tables:');
  print('• user_profiles (if not exists)');
  print('• clubs (if not exists)');
  print('• club_memberships');
  print('• membership_requests');
  print('• chat_rooms');
  print('• chat_room_members');
  print('• chat_messages');
  print('• announcements');
  print('• announcement_reads');
  print('• notifications');
  print('• member_activities');
  print('• member_statistics');
  print('\n🔒 Security:');
  print('• Row Level Security enabled');
  print('• Policies created for data protection');
  print('\n⚡ Performance:');
  print('• Indexes created for optimal queries');
  print('• Triggers for auto-generated fields');
  print('\n🎯 Ready for Member Management System!');
}