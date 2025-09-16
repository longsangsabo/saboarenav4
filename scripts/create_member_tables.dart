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
  await supabase.rpc('exec_sql', params: {
    'sql': '''
      CREATE TABLE IF NOT EXISTS club_memberships (
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
      
      CREATE INDEX IF NOT EXISTS idx_club_memberships_club_id ON club_memberships(club_id);
      CREATE INDEX IF NOT EXISTS idx_club_memberships_user_id ON club_memberships(user_id);
      CREATE INDEX IF NOT EXISTS idx_club_memberships_status ON club_memberships(status);
      CREATE INDEX IF NOT EXISTS idx_club_memberships_membership_type ON club_memberships(membership_type);
      CREATE INDEX IF NOT EXISTS idx_club_memberships_membership_id ON club_memberships(membership_id);
    '''
  });

  // 2. Membership requests table
  print('📝 Creating membership_requests table...');
  await supabase.rpc('exec_sql', params: {
    'sql': '''
      CREATE TABLE IF NOT EXISTS membership_requests (
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
      
      CREATE INDEX IF NOT EXISTS idx_membership_requests_club_id ON membership_requests(club_id);
      CREATE INDEX IF NOT EXISTS idx_membership_requests_requested_by ON membership_requests(requested_by);
      CREATE INDEX IF NOT EXISTS idx_membership_requests_status ON membership_requests(status);
      CREATE INDEX IF NOT EXISTS idx_membership_requests_created_at ON membership_requests(created_at);
    '''
  });

  // 3. Chat rooms table
  print('📝 Creating chat_rooms table...');
  await supabase.rpc('exec_sql', params: {
    'sql': '''
      CREATE TABLE IF NOT EXISTS chat_rooms (
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
      
      CREATE INDEX IF NOT EXISTS idx_chat_rooms_club_id ON chat_rooms(club_id);
      CREATE INDEX IF NOT EXISTS idx_chat_rooms_type ON chat_rooms(type);
      CREATE INDEX IF NOT EXISTS idx_chat_rooms_is_private ON chat_rooms(is_private);
    '''
  });

  // 4. Chat room members table
  print('📝 Creating chat_room_members table...');
  await supabase.rpc('exec_sql', params: {
    'sql': '''
      CREATE TABLE IF NOT EXISTS chat_room_members (
        id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
        room_id UUID REFERENCES chat_rooms(id) ON DELETE CASCADE,
        user_id UUID REFERENCES user_profiles(id) ON DELETE CASCADE,
        role VARCHAR(20) DEFAULT 'member' CHECK (role IN ('member', 'moderator', 'admin')),
        joined_at TIMESTAMPTZ DEFAULT NOW(),
        last_read_at TIMESTAMPTZ DEFAULT NOW(),
        is_muted BOOLEAN DEFAULT FALSE,
        UNIQUE(room_id, user_id)
      );
      
      CREATE INDEX IF NOT EXISTS idx_chat_room_members_room_id ON chat_room_members(room_id);
      CREATE INDEX IF NOT EXISTS idx_chat_room_members_user_id ON chat_room_members(user_id);
    '''
  });

  // 5. Chat messages table
  print('📝 Creating chat_messages table...');
  await supabase.rpc('exec_sql', params: {
    'sql': '''
      CREATE TABLE IF NOT EXISTS chat_messages (
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
      
      CREATE INDEX IF NOT EXISTS idx_chat_messages_room_id ON chat_messages(room_id);
      CREATE INDEX IF NOT EXISTS idx_chat_messages_sender_id ON chat_messages(sender_id);
      CREATE INDEX IF NOT EXISTS idx_chat_messages_created_at ON chat_messages(created_at);
      CREATE INDEX IF NOT EXISTS idx_chat_messages_reply_to_id ON chat_messages(reply_to_id);
    '''
  });

  // 6. Announcements table
  print('📝 Creating announcements table...');
  await supabase.rpc('exec_sql', params: {
    'sql': '''
      CREATE TABLE IF NOT EXISTS announcements (
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
      
      CREATE INDEX IF NOT EXISTS idx_announcements_club_id ON announcements(club_id);
      CREATE INDEX IF NOT EXISTS idx_announcements_priority ON announcements(priority);
      CREATE INDEX IF NOT EXISTS idx_announcements_type ON announcements(type);
      CREATE INDEX IF NOT EXISTS idx_announcements_is_published ON announcements(is_published);
      CREATE INDEX IF NOT EXISTS idx_announcements_publish_at ON announcements(publish_at);
    '''
  });

  // 7. Announcement reads table
  print('📝 Creating announcement_reads table...');
  await supabase.rpc('exec_sql', params: {
    'sql': '''
      CREATE TABLE IF NOT EXISTS announcement_reads (
        id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
        announcement_id UUID REFERENCES announcements(id) ON DELETE CASCADE,
        user_id UUID REFERENCES user_profiles(id) ON DELETE CASCADE,
        read_at TIMESTAMPTZ DEFAULT NOW(),
        UNIQUE(announcement_id, user_id)
      );
      
      CREATE INDEX IF NOT EXISTS idx_announcement_reads_announcement_id ON announcement_reads(announcement_id);
      CREATE INDEX IF NOT EXISTS idx_announcement_reads_user_id ON announcement_reads(user_id);
    '''
  });

  // 8. Notifications table
  print('📝 Creating notifications table...');
  await supabase.rpc('exec_sql', params: {
    'sql': '''
      CREATE TABLE IF NOT EXISTS notifications (
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
      
      CREATE INDEX IF NOT EXISTS idx_notifications_recipient_id ON notifications(recipient_id);
      CREATE INDEX IF NOT EXISTS idx_notifications_club_id ON notifications(club_id);
      CREATE INDEX IF NOT EXISTS idx_notifications_type ON notifications(type);
      CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON notifications(is_read);
      CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON notifications(created_at);
      CREATE INDEX IF NOT EXISTS idx_notifications_priority ON notifications(priority);
    '''
  });

  // 9. Member activities table
  print('📝 Creating member_activities table...');
  await supabase.rpc('exec_sql', params: {
    'sql': '''
      CREATE TABLE IF NOT EXISTS member_activities (
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
      
      CREATE INDEX IF NOT EXISTS idx_member_activities_club_id ON member_activities(club_id);
      CREATE INDEX IF NOT EXISTS idx_member_activities_user_id ON member_activities(user_id);
      CREATE INDEX IF NOT EXISTS idx_member_activities_action ON member_activities(action);
      CREATE INDEX IF NOT EXISTS idx_member_activities_created_at ON member_activities(created_at);
      CREATE INDEX IF NOT EXISTS idx_member_activities_target ON member_activities(target_type, target_id);
    '''
  });

  // 10. Member statistics table
  print('📝 Creating member_statistics table...');
  await supabase.rpc('exec_sql', params: {
    'sql': '''
      CREATE TABLE IF NOT EXISTS member_statistics (
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
      
      CREATE INDEX IF NOT EXISTS idx_member_statistics_club_id ON member_statistics(club_id);
      CREATE INDEX IF NOT EXISTS idx_member_statistics_user_id ON member_statistics(user_id);
      CREATE INDEX IF NOT EXISTS idx_member_statistics_elo_rating ON member_statistics(elo_rating);
      CREATE INDEX IF NOT EXISTS idx_member_statistics_rank_position ON member_statistics(rank_position);
    '''
  });

  // Create utility functions
  print('📝 Creating utility functions...');
  await createUtilityFunctions(supabase);
  
  // Create triggers
  print('📝 Creating triggers...');
  await createTriggers(supabase);
  
  // Create RLS policies
  print('🔐 Creating Row Level Security policies...');
  await createRLSPolicies(supabase);
  
  print('✨ Member management schema created successfully!');
}

Future<void> createUtilityFunctions(SupabaseClient supabase) async {
  // Generate membership ID function
  await supabase.rpc('exec_sql', params: {
    'sql': '''
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
    '''
  });

  // Update member statistics function
  await supabase.rpc('exec_sql', params: {
    'sql': '''
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
    '''
  });

  // Get club analytics function
  await supabase.rpc('exec_sql', params: {
    'sql': '''
      CREATE OR REPLACE FUNCTION get_club_member_analytics(p_club_id UUID)
      RETURNS JSON AS \$\$
      DECLARE
        result JSON;
      BEGIN
        SELECT json_build_object(
          'total_members', (
            SELECT COUNT(*) FROM club_memberships 
            WHERE club_id = p_club_id AND status = 'active'
          ),
          'membership_types', (
            SELECT json_object_agg(membership_type, count) 
            FROM (
              SELECT membership_type, COUNT(*) as count
              FROM club_memberships 
              WHERE club_id = p_club_id AND status = 'active'
              GROUP BY membership_type
            ) t
          ),
          'pending_requests', (
            SELECT COUNT(*) FROM membership_requests 
            WHERE club_id = p_club_id AND status = 'pending'
          ),
          'recent_activities', (
            SELECT COUNT(*) FROM member_activities 
            WHERE club_id = p_club_id AND created_at >= NOW() - INTERVAL '7 days'
          ),
          'unread_notifications', (
            SELECT COUNT(*) FROM notifications 
            WHERE club_id = p_club_id AND is_read = false
          )
        ) INTO result;
        
        RETURN result;
      END;
      \$\$ LANGUAGE plpgsql;
    '''
  });
}

Future<void> createTriggers(SupabaseClient supabase) async {
  // Update timestamp triggers
  await supabase.rpc('exec_sql', params: {
    'sql': '''
      CREATE OR REPLACE FUNCTION update_updated_at_column()
      RETURNS TRIGGER AS \$\$
      BEGIN
        NEW.updated_at = NOW();
        RETURN NEW;
      END;
      \$\$ language 'plpgsql';

      -- Apply to relevant tables
      DROP TRIGGER IF EXISTS update_club_memberships_updated_at ON club_memberships;
      CREATE TRIGGER update_club_memberships_updated_at 
        BEFORE UPDATE ON club_memberships 
        FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

      DROP TRIGGER IF EXISTS update_membership_requests_updated_at ON membership_requests;
      CREATE TRIGGER update_membership_requests_updated_at 
        BEFORE UPDATE ON membership_requests 
        FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

      DROP TRIGGER IF EXISTS update_chat_rooms_updated_at ON chat_rooms;
      CREATE TRIGGER update_chat_rooms_updated_at 
        BEFORE UPDATE ON chat_rooms 
        FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

      DROP TRIGGER IF EXISTS update_announcements_updated_at ON announcements;
      CREATE TRIGGER update_announcements_updated_at 
        BEFORE UPDATE ON announcements 
        FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

      DROP TRIGGER IF EXISTS update_member_statistics_updated_at ON member_statistics;
      CREATE TRIGGER update_member_statistics_updated_at 
        BEFORE UPDATE ON member_statistics 
        FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    '''
  });

  // Auto-generate membership ID trigger
  await supabase.rpc('exec_sql', params: {
    'sql': '''
      CREATE OR REPLACE FUNCTION auto_generate_membership_id()
      RETURNS TRIGGER AS \$\$
      BEGIN
        IF NEW.membership_id IS NULL OR NEW.membership_id = '' THEN
          NEW.membership_id := generate_membership_id();
        END IF;
        RETURN NEW;
      END;
      \$\$ LANGUAGE plpgsql;

      DROP TRIGGER IF EXISTS auto_membership_id ON club_memberships;
      CREATE TRIGGER auto_membership_id
        BEFORE INSERT ON club_memberships
        FOR EACH ROW EXECUTE FUNCTION auto_generate_membership_id();
    '''
  });

  // Activity logging trigger
  await supabase.rpc('exec_sql', params: {
    'sql': '''
      CREATE OR REPLACE FUNCTION log_membership_activity()
      RETURNS TRIGGER AS \$\$
      BEGIN
        IF TG_OP = 'INSERT' THEN
          INSERT INTO member_activities (club_id, user_id, action, description, metadata)
          VALUES (NEW.club_id, NEW.user_id, 'member_joined', 
                  'New member joined the club', 
                  json_build_object('membership_type', NEW.membership_type, 'membership_id', NEW.membership_id));
          RETURN NEW;
        ELSIF TG_OP = 'UPDATE' THEN
          IF OLD.status != NEW.status THEN
            INSERT INTO member_activities (club_id, user_id, action, description, metadata)
            VALUES (NEW.club_id, NEW.user_id, 'member_status_changed', 
                    'Member status changed from ' || OLD.status || ' to ' || NEW.status,
                    json_build_object('old_status', OLD.status, 'new_status', NEW.status));
          END IF;
          RETURN NEW;
        ELSIF TG_OP = 'DELETE' THEN
          INSERT INTO member_activities (club_id, user_id, action, description, metadata)
          VALUES (OLD.club_id, OLD.user_id, 'member_left', 
                  'Member left the club', 
                  json_build_object('membership_id', OLD.membership_id));
          RETURN OLD;
        END IF;
        RETURN NULL;
      END;
      \$\$ LANGUAGE plpgsql;

      DROP TRIGGER IF EXISTS log_membership_changes ON club_memberships;
      CREATE TRIGGER log_membership_changes
        AFTER INSERT OR UPDATE OR DELETE ON club_memberships
        FOR EACH ROW EXECUTE FUNCTION log_membership_activity();
    '''
  });
}

Future<void> createRLSPolicies(SupabaseClient supabase) async {
  // Enable RLS on all tables
  await supabase.rpc('exec_sql', params: {
    'sql': '''
      ALTER TABLE club_memberships ENABLE ROW LEVEL SECURITY;
      ALTER TABLE membership_requests ENABLE ROW LEVEL SECURITY;
      ALTER TABLE chat_rooms ENABLE ROW LEVEL SECURITY;
      ALTER TABLE chat_room_members ENABLE ROW LEVEL SECURITY;
      ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;
      ALTER TABLE announcements ENABLE ROW LEVEL SECURITY;
      ALTER TABLE announcement_reads ENABLE ROW LEVEL SECURITY;
      ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
      ALTER TABLE member_activities ENABLE ROW LEVEL SECURITY;
      ALTER TABLE member_statistics ENABLE ROW LEVEL SECURITY;
    '''
  });

  // Club memberships policies
  await supabase.rpc('exec_sql', params: {
    'sql': '''
      -- Club members can view other club members
      CREATE POLICY "Club members can view memberships" ON club_memberships
        FOR SELECT USING (
          club_id IN (
            SELECT club_id FROM club_memberships 
            WHERE user_id = auth.uid() AND status = 'active'
          )
        );

      -- Club admins can manage memberships
      CREATE POLICY "Club admins can manage memberships" ON club_memberships
        FOR ALL USING (
          club_id IN (
            SELECT club_id FROM club_memberships 
            WHERE user_id = auth.uid() AND role IN ('admin', 'owner') AND status = 'active'
          )
        );

      -- Users can view their own membership
      CREATE POLICY "Users can view own membership" ON club_memberships
        FOR SELECT USING (user_id = auth.uid());
    '''
  });

  // Membership requests policies
  await supabase.rpc('exec_sql', params: {
    'sql': '''
      -- Users can create membership requests
      CREATE POLICY "Users can create requests" ON membership_requests
        FOR INSERT WITH CHECK (requested_by = auth.uid());

      -- Users can view their own requests
      CREATE POLICY "Users can view own requests" ON membership_requests
        FOR SELECT USING (requested_by = auth.uid());

      -- Club admins can manage requests
      CREATE POLICY "Club admins can manage requests" ON membership_requests
        FOR ALL USING (
          club_id IN (
            SELECT club_id FROM club_memberships 
            WHERE user_id = auth.uid() AND role IN ('admin', 'owner') AND status = 'active'
          )
        );
    '''
  });

  // Chat rooms policies
  await supabase.rpc('exec_sql', params: {
    'sql': '''
      -- Club members can view chat rooms
      CREATE POLICY "Club members can view chat rooms" ON chat_rooms
        FOR SELECT USING (
          club_id IN (
            SELECT club_id FROM club_memberships 
            WHERE user_id = auth.uid() AND status = 'active'
          )
        );

      -- Club admins can manage chat rooms
      CREATE POLICY "Club admins can manage chat rooms" ON chat_rooms
        FOR ALL USING (
          club_id IN (
            SELECT club_id FROM club_memberships 
            WHERE user_id = auth.uid() AND role IN ('admin', 'owner') AND status = 'active'
          )
        );
    '''
  });

  // Chat messages policies
  await supabase.rpc('exec_sql', params: {
    'sql': '''
      -- Room members can view messages
      CREATE POLICY "Room members can view messages" ON chat_messages
        FOR SELECT USING (
          room_id IN (
            SELECT room_id FROM chat_room_members WHERE user_id = auth.uid()
          )
        );

      -- Room members can send messages
      CREATE POLICY "Room members can send messages" ON chat_messages
        FOR INSERT WITH CHECK (
          sender_id = auth.uid() AND
          room_id IN (
            SELECT room_id FROM chat_room_members WHERE user_id = auth.uid()
          )
        );

      -- Users can edit their own messages
      CREATE POLICY "Users can edit own messages" ON chat_messages
        FOR UPDATE USING (sender_id = auth.uid());
    '''
  });

  // Notifications policies
  await supabase.rpc('exec_sql', params: {
    'sql': '''
      -- Users can view their own notifications
      CREATE POLICY "Users can view own notifications" ON notifications
        FOR SELECT USING (recipient_id = auth.uid());

      -- Users can update their own notifications (mark as read)
      CREATE POLICY "Users can update own notifications" ON notifications
        FOR UPDATE USING (recipient_id = auth.uid());

      -- Club admins can create notifications
      CREATE POLICY "Club admins can create notifications" ON notifications
        FOR INSERT WITH CHECK (
          club_id IN (
            SELECT club_id FROM club_memberships 
            WHERE user_id = auth.uid() AND role IN ('admin', 'owner') AND status = 'active'
          )
        );
    '''
  });

  // Member activities policies (read-only for members, full access for admins)
  await supabase.rpc('exec_sql', params: {
    'sql': '''
      -- Club members can view activities
      CREATE POLICY "Club members can view activities" ON member_activities
        FOR SELECT USING (
          club_id IN (
            SELECT club_id FROM club_memberships 
            WHERE user_id = auth.uid() AND status = 'active'
          )
        );

      -- System can insert activities (no direct user access needed for INSERT)
    '''
  });

  // Member statistics policies
  await supabase.rpc('exec_sql', params: {
    'sql': '''
      -- Club members can view statistics
      CREATE POLICY "Club members can view statistics" ON member_statistics
        FOR SELECT USING (
          club_id IN (
            SELECT club_id FROM club_memberships 
            WHERE user_id = auth.uid() AND status = 'active'
          )
        );

      -- Users can view their own statistics
      CREATE POLICY "Users can view own statistics" ON member_statistics
        FOR SELECT USING (user_id = auth.uid());
    '''
  });

  print('🔐 Row Level Security policies created successfully!');
}