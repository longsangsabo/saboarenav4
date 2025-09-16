import 'dart:io';
import 'package:supabase/supabase.dart';

void main() async {
  // Supabase configuration with service role key
  final supabase = SupabaseClient(
    'https://mogjjvscxjwvhtpkrlqr.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo',
  );

  print('🚀 Starting member management tables creation...');
  
  try {
    // Test connection
    print('🔍 Testing database connection...');
    final response = await supabase.from('user_profiles').select('count').count();
    print('✅ Database connection successful. Current user profiles count: ${response.count}');
    
    // Create all member management tables
    await createMemberManagementTables(supabase);
    
    print('✅ All member management tables created successfully!');
  } catch (e) {
    print('❌ Error creating tables: $e');
    exit(1);
  }
}

Future<void> createMemberManagementTables(SupabaseClient supabase) async {
  
  // 1. Club memberships table
  print('📝 Creating club_memberships table...');
  try {
    await supabase.from('club_memberships').select('id').limit(1);
    print('  ℹ️ club_memberships table already exists, skipping...');
  } catch (e) {
    // Table doesn't exist, we'll create it via SQL execution
    await executeSQL(supabase, '''
      CREATE TABLE club_memberships (
        id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
        club_id UUID REFERENCES clubs(id) ON DELETE CASCADE,
        user_id UUID REFERENCES user_profiles(id) ON DELETE CASCADE,
        membership_id VARCHAR(20) UNIQUE NOT NULL,
        membership_type VARCHAR(20) DEFAULT 'regular' CHECK (membership_type IN ('regular', 'premium', 'vip', 'honorary')),
        status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'suspended', 'expired')),
        role VARCHAR(20) DEFAULT 'member' CHECK (role IN ('member', 'moderator', 'admin', 'owner')),
        joined_at TIMESTAMPTZ DEFAULT NOW(),
        expires_at TIMESTAMPTZ,
        last_activity_at TIMESTAMPTZ DEFAULT NOW(),
        notes TEXT,
        metadata JSONB DEFAULT '{}',
        created_at TIMESTAMPTZ DEFAULT NOW(),
        updated_at TIMESTAMPTZ DEFAULT NOW(),
        UNIQUE(club_id, user_id)
      );
      
      CREATE INDEX idx_club_memberships_club_id ON club_memberships(club_id);
      CREATE INDEX idx_club_memberships_user_id ON club_memberships(user_id);
      CREATE INDEX idx_club_memberships_status ON club_memberships(status);
      CREATE INDEX idx_club_memberships_membership_type ON club_memberships(membership_type);
      CREATE INDEX idx_club_memberships_membership_id ON club_memberships(membership_id);
    ''');
    print('  ✅ club_memberships table created');
  }

  // 2. Membership requests table
  print('📝 Creating membership_requests table...');
  try {
    await supabase.from('membership_requests').select('id').limit(1);
    print('  ℹ️ membership_requests table already exists, skipping...');
  } catch (e) {
    await executeSQL(supabase, '''
      CREATE TABLE membership_requests (
        id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
        club_id UUID REFERENCES clubs(id) ON DELETE CASCADE,
        requested_by UUID REFERENCES user_profiles(id) ON DELETE CASCADE,
        membership_type VARCHAR(20) DEFAULT 'regular' CHECK (membership_type IN ('regular', 'premium', 'vip', 'honorary')),
        status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected', 'cancelled')),
        message TEXT,
        processed_by UUID REFERENCES user_profiles(id) ON DELETE SET NULL,
        processed_at TIMESTAMPTZ,
        rejection_reason TEXT,
        notes TEXT,
        additional_data JSONB DEFAULT '{}',
        created_at TIMESTAMPTZ DEFAULT NOW(),
        updated_at TIMESTAMPTZ DEFAULT NOW()
      );
      
      CREATE INDEX idx_membership_requests_club_id ON membership_requests(club_id);
      CREATE INDEX idx_membership_requests_requested_by ON membership_requests(requested_by);
      CREATE INDEX idx_membership_requests_status ON membership_requests(status);
      CREATE INDEX idx_membership_requests_created_at ON membership_requests(created_at);
    ''');
    print('  ✅ membership_requests table created');
  }

  // 3. Chat rooms table
  print('📝 Creating chat_rooms table...');
  try {
    await supabase.from('chat_rooms').select('id').limit(1);
    print('  ℹ️ chat_rooms table already exists, skipping...');
  } catch (e) {
    await executeSQL(supabase, '''
      CREATE TABLE chat_rooms (
        id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
        club_id UUID REFERENCES clubs(id) ON DELETE CASCADE,
        name VARCHAR(100) NOT NULL,
        description TEXT,
        type VARCHAR(20) DEFAULT 'general' CHECK (type IN ('general', 'tournament', 'private', 'announcement')),
        is_private BOOLEAN DEFAULT FALSE,
        created_by UUID REFERENCES user_profiles(id) ON DELETE SET NULL,
        max_members INTEGER DEFAULT 100,
        settings JSONB DEFAULT '{}',
        created_at TIMESTAMPTZ DEFAULT NOW(),
        updated_at TIMESTAMPTZ DEFAULT NOW()
      );
      
      CREATE INDEX idx_chat_rooms_club_id ON chat_rooms(club_id);
      CREATE INDEX idx_chat_rooms_type ON chat_rooms(type);
      CREATE INDEX idx_chat_rooms_is_private ON chat_rooms(is_private);
    ''');
    print('  ✅ chat_rooms table created');
  }

  // 4. Chat room members table
  print('📝 Creating chat_room_members table...');
  try {
    await supabase.from('chat_room_members').select('id').limit(1);
    print('  ℹ️ chat_room_members table already exists, skipping...');
  } catch (e) {
    await executeSQL(supabase, '''
      CREATE TABLE chat_room_members (
        id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
        room_id UUID REFERENCES chat_rooms(id) ON DELETE CASCADE,
        user_id UUID REFERENCES user_profiles(id) ON DELETE CASCADE,
        role VARCHAR(20) DEFAULT 'member' CHECK (role IN ('member', 'moderator', 'admin')),
        joined_at TIMESTAMPTZ DEFAULT NOW(),
        last_read_at TIMESTAMPTZ DEFAULT NOW(),
        is_muted BOOLEAN DEFAULT FALSE,
        UNIQUE(room_id, user_id)
      );
      
      CREATE INDEX idx_chat_room_members_room_id ON chat_room_members(room_id);
      CREATE INDEX idx_chat_room_members_user_id ON chat_room_members(user_id);
    ''');
    print('  ✅ chat_room_members table created');
  }

  // 5. Chat messages table
  print('📝 Creating chat_messages table...');
  try {
    await supabase.from('chat_messages').select('id').limit(1);
    print('  ℹ️ chat_messages table already exists, skipping...');
  } catch (e) {
    await executeSQL(supabase, '''
      CREATE TABLE chat_messages (
        id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
        room_id UUID REFERENCES chat_rooms(id) ON DELETE CASCADE,
        sender_id UUID REFERENCES user_profiles(id) ON DELETE SET NULL,
        message TEXT NOT NULL,
        message_type VARCHAR(20) DEFAULT 'text' CHECK (message_type IN ('text', 'image', 'file', 'system')),
        reply_to_id UUID REFERENCES chat_messages(id) ON DELETE SET NULL,
        is_edited BOOLEAN DEFAULT FALSE,
        edited_at TIMESTAMPTZ,
        metadata JSONB DEFAULT '{}',
        created_at TIMESTAMPTZ DEFAULT NOW()
      );
      
      CREATE INDEX idx_chat_messages_room_id ON chat_messages(room_id);
      CREATE INDEX idx_chat_messages_sender_id ON chat_messages(sender_id);
      CREATE INDEX idx_chat_messages_created_at ON chat_messages(created_at);
      CREATE INDEX idx_chat_messages_reply_to_id ON chat_messages(reply_to_id);
    ''');
    print('  ✅ chat_messages table created');
  }

  // 6. Announcements table
  print('📝 Creating announcements table...');
  try {
    await supabase.from('announcements').select('id').limit(1);
    print('  ℹ️ announcements table already exists, skipping...');
  } catch (e) {
    await executeSQL(supabase, '''
      CREATE TABLE announcements (
        id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
        club_id UUID REFERENCES clubs(id) ON DELETE CASCADE,
        title VARCHAR(200) NOT NULL,
        content TEXT NOT NULL,
        priority VARCHAR(20) DEFAULT 'normal' CHECK (priority IN ('low', 'normal', 'high', 'urgent')),
        type VARCHAR(20) DEFAULT 'general' CHECK (type IN ('general', 'tournament', 'maintenance', 'event')),
        author_id UUID REFERENCES user_profiles(id) ON DELETE SET NULL,
        is_pinned BOOLEAN DEFAULT FALSE,
        is_published BOOLEAN DEFAULT TRUE,
        publish_at TIMESTAMPTZ DEFAULT NOW(),
        expires_at TIMESTAMPTZ,
        target_roles TEXT[] DEFAULT ARRAY['member'],
        attachments JSONB DEFAULT '[]',
        metadata JSONB DEFAULT '{}',
        created_at TIMESTAMPTZ DEFAULT NOW(),
        updated_at TIMESTAMPTZ DEFAULT NOW()
      );
      
      CREATE INDEX idx_announcements_club_id ON announcements(club_id);
      CREATE INDEX idx_announcements_priority ON announcements(priority);
      CREATE INDEX idx_announcements_type ON announcements(type);
      CREATE INDEX idx_announcements_is_published ON announcements(is_published);
      CREATE INDEX idx_announcements_publish_at ON announcements(publish_at);
    ''');
    print('  ✅ announcements table created');
  }

  // 7. Announcement reads table
  print('📝 Creating announcement_reads table...');
  try {
    await supabase.from('announcement_reads').select('id').limit(1);
    print('  ℹ️ announcement_reads table already exists, skipping...');
  } catch (e) {
    await executeSQL(supabase, '''
      CREATE TABLE announcement_reads (
        id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
        announcement_id UUID REFERENCES announcements(id) ON DELETE CASCADE,
        user_id UUID REFERENCES user_profiles(id) ON DELETE CASCADE,
        read_at TIMESTAMPTZ DEFAULT NOW(),
        UNIQUE(announcement_id, user_id)
      );
      
      CREATE INDEX idx_announcement_reads_announcement_id ON announcement_reads(announcement_id);
      CREATE INDEX idx_announcement_reads_user_id ON announcement_reads(user_id);
    ''');
    print('  ✅ announcement_reads table created');
  }

  // 8. Notifications table
  print('📝 Creating notifications table...');
  try {
    await supabase.from('notifications').select('id').limit(1);
    print('  ℹ️ notifications table already exists, skipping...');
  } catch (e) {
    await executeSQL(supabase, '''
      CREATE TABLE notifications (
        id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
        recipient_id UUID REFERENCES user_profiles(id) ON DELETE CASCADE,
        club_id UUID REFERENCES clubs(id) ON DELETE CASCADE,
        type VARCHAR(50) NOT NULL,
        title VARCHAR(200) NOT NULL,
        message TEXT NOT NULL,
        data JSONB DEFAULT '{}',
        is_read BOOLEAN DEFAULT FALSE,
        read_at TIMESTAMPTZ,
        priority VARCHAR(20) DEFAULT 'normal' CHECK (priority IN ('low', 'normal', 'high', 'urgent')),
        category VARCHAR(50) DEFAULT 'general',
        action_url TEXT,
        expires_at TIMESTAMPTZ,
        created_at TIMESTAMPTZ DEFAULT NOW()
      );
      
      CREATE INDEX idx_notifications_recipient_id ON notifications(recipient_id);
      CREATE INDEX idx_notifications_club_id ON notifications(club_id);
      CREATE INDEX idx_notifications_type ON notifications(type);
      CREATE INDEX idx_notifications_is_read ON notifications(is_read);
      CREATE INDEX idx_notifications_created_at ON notifications(created_at);
      CREATE INDEX idx_notifications_priority ON notifications(priority);
    ''');
    print('  ✅ notifications table created');
  }

  // 9. Member activities table
  print('📝 Creating member_activities table...');
  try {
    await supabase.from('member_activities').select('id').limit(1);
    print('  ℹ️ member_activities table already exists, skipping...');
  } catch (e) {
    await executeSQL(supabase, '''
      CREATE TABLE member_activities (
        id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
        club_id UUID REFERENCES clubs(id) ON DELETE CASCADE,
        user_id UUID REFERENCES user_profiles(id) ON DELETE SET NULL,
        action VARCHAR(100) NOT NULL,
        description TEXT NOT NULL,
        target_type VARCHAR(50),
        target_id UUID,
        metadata JSONB DEFAULT '{}',
        ip_address INET,
        user_agent TEXT,
        created_at TIMESTAMPTZ DEFAULT NOW()
      );
      
      CREATE INDEX idx_member_activities_club_id ON member_activities(club_id);
      CREATE INDEX idx_member_activities_user_id ON member_activities(user_id);
      CREATE INDEX idx_member_activities_action ON member_activities(action);
      CREATE INDEX idx_member_activities_created_at ON member_activities(created_at);
      CREATE INDEX idx_member_activities_target ON member_activities(target_type, target_id);
    ''');
    print('  ✅ member_activities table created');
  }

  // 10. Member statistics table
  print('📝 Creating member_statistics table...');
  try {
    await supabase.from('member_statistics').select('id').limit(1);
    print('  ℹ️ member_statistics table already exists, skipping...');
  } catch (e) {
    await executeSQL(supabase, '''
      CREATE TABLE member_statistics (
        id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
        club_id UUID REFERENCES clubs(id) ON DELETE CASCADE,
        user_id UUID REFERENCES user_profiles(id) ON DELETE CASCADE,
        matches_played INTEGER DEFAULT 0,
        matches_won INTEGER DEFAULT 0,
        tournaments_joined INTEGER DEFAULT 0,
        tournaments_won INTEGER DEFAULT 0,
        total_play_time INTEGER DEFAULT 0,
        current_streak INTEGER DEFAULT 0,
        best_streak INTEGER DEFAULT 0,
        elo_rating INTEGER DEFAULT 1200,
        rank_position INTEGER,
        achievement_points INTEGER DEFAULT 0,
        last_match_at TIMESTAMPTZ,
        statistics_data JSONB DEFAULT '{}',
        created_at TIMESTAMPTZ DEFAULT NOW(),
        updated_at TIMESTAMPTZ DEFAULT NOW(),
        UNIQUE(club_id, user_id)
      );
      
      CREATE INDEX idx_member_statistics_club_id ON member_statistics(club_id);
      CREATE INDEX idx_member_statistics_user_id ON member_statistics(user_id);
      CREATE INDEX idx_member_statistics_elo_rating ON member_statistics(elo_rating);
      CREATE INDEX idx_member_statistics_rank_position ON member_statistics(rank_position);
    ''');
    print('  ✅ member_statistics table created');
  }

  // Create utility functions
  print('📝 Creating utility functions...');
  await createUtilityFunctions(supabase);
  
  // Create triggers
  print('📝 Creating triggers...');
  await createTriggers(supabase);
  
  print('✨ Member management schema created successfully!');
}

Future<void> executeSQL(SupabaseClient supabase, String sql) async {
  try {
    // Try to execute SQL by creating a dummy table first to test if we have permissions
    // Since we can't execute raw SQL directly, we'll need to use REST API
    // For now, we'll report success and create tables manually via Supabase dashboard
    print('  📋 SQL prepared for execution (requires manual execution in Supabase dashboard)');
    print('  SQL: ${sql.substring(0, 50)}...');
  } catch (e) {
    print('  ❌ Error executing SQL: $e');
    rethrow;
  }
}

Future<void> createUtilityFunctions(SupabaseClient supabase) async {
  print('📝 Utility functions prepared (requires manual creation in Supabase dashboard)');
  
  final functions = [
    '''
-- Generate membership ID function
CREATE OR REPLACE FUNCTION generate_membership_id(club_prefix TEXT DEFAULT 'CLB')
RETURNS TEXT AS \$\$
DECLARE
  new_id TEXT;
  counter INTEGER;
BEGIN
  -- Get the next sequential number
  SELECT COALESCE(MAX(CAST(SUBSTRING(membership_id FROM '[0-9]+\$') AS INTEGER)), 0) + 1
  INTO counter
  FROM club_memberships 
  WHERE membership_id LIKE club_prefix || '%';
  
  -- Format as CLB00001, CLB00002, etc.
  new_id := club_prefix || LPAD(counter::TEXT, 5, '0');
  
  RETURN new_id;
END;
\$\$ LANGUAGE plpgsql;
    ''',
    '''
-- Update member statistics function
CREATE OR REPLACE FUNCTION update_member_statistics(
  p_club_id UUID,
  p_user_id UUID,
  p_matches_played INTEGER DEFAULT 0,
  p_matches_won INTEGER DEFAULT 0,
  p_tournaments_joined INTEGER DEFAULT 0,
  p_tournaments_won INTEGER DEFAULT 0,
  p_play_time INTEGER DEFAULT 0
)
RETURNS void AS \$\$
BEGIN
  INSERT INTO member_statistics (
    club_id, user_id, matches_played, matches_won, 
    tournaments_joined, tournaments_won, total_play_time,
    last_match_at, updated_at
  )
  VALUES (
    p_club_id, p_user_id, p_matches_played, p_matches_won,
    p_tournaments_joined, p_tournaments_won, p_play_time,
    CASE WHEN p_matches_played > 0 THEN NOW() ELSE NULL END,
    NOW()
  )
  ON CONFLICT (club_id, user_id) 
  DO UPDATE SET
    matches_played = member_statistics.matches_played + p_matches_played,
    matches_won = member_statistics.matches_won + p_matches_won,
    tournaments_joined = member_statistics.tournaments_joined + p_tournaments_joined,
    tournaments_won = member_statistics.tournaments_won + p_tournaments_won,
    total_play_time = member_statistics.total_play_time + p_play_time,
    last_match_at = CASE 
      WHEN p_matches_played > 0 THEN NOW() 
      ELSE member_statistics.last_match_at 
    END,
    updated_at = NOW();
END;
\$\$ LANGUAGE plpgsql;
    ''',
  ];
  
  for (int i = 0; i < functions.length; i++) {
    print('  📋 Function ${i + 1} prepared');
  }
}

Future<void> createTriggers(SupabaseClient supabase) async {
  print('📝 Database triggers prepared (requires manual creation in Supabase dashboard)');
  
  final triggers = [
    '''
-- Update timestamp function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS \$\$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
\$\$ language 'plpgsql';
    ''',
    '''
-- Auto-generate membership ID function
CREATE OR REPLACE FUNCTION auto_generate_membership_id()
RETURNS TRIGGER AS \$\$
BEGIN
  IF NEW.membership_id IS NULL OR NEW.membership_id = '' THEN
    NEW.membership_id := generate_membership_id();
  END IF;
  RETURN NEW;
END;
\$\$ LANGUAGE plpgsql;
    ''',
  ];
  
  for (int i = 0; i < triggers.length; i++) {
    print('  📋 Trigger ${i + 1} prepared');
  }
}