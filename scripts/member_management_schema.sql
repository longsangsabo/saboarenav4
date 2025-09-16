-- ====================================
-- SABO ARENA - MEMBER MANAGEMENT SYSTEM
-- Database Schema for PHASE 3
-- ====================================

-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ====================================
-- 1. CLUB MEMBERSHIPS TABLE
-- ====================================

-- Enhanced club_memberships table with comprehensive member data
CREATE TABLE IF NOT EXISTS club_memberships (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  club_id UUID NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,
  
  -- Membership Information
  membership_type TEXT NOT NULL DEFAULT 'regular' CHECK (membership_type IN ('regular', 'vip', 'premium')),
  status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'suspended', 'pending')),
  
  -- Dates
  joined_at TIMESTAMPTZ DEFAULT NOW(),
  expires_at TIMESTAMPTZ,
  last_activity_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- Settings
  auto_renewal BOOLEAN DEFAULT false,
  is_public_profile BOOLEAN DEFAULT true,
  allow_messages BOOLEAN DEFAULT true,
  allow_invitations BOOLEAN DEFAULT true,
  
  -- Permissions
  permissions JSONB DEFAULT '{
    "tournaments": true,
    "posts": true,
    "chat": true,
    "invite": false,
    "contact": false
  }',
  
  -- Membership ID for easy reference
  membership_id TEXT UNIQUE,
  
  -- Notes for admins
  admin_notes TEXT,
  
  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- Constraints
  UNIQUE(user_id, club_id)
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_club_memberships_user_id ON club_memberships(user_id);
CREATE INDEX IF NOT EXISTS idx_club_memberships_club_id ON club_memberships(club_id);
CREATE INDEX IF NOT EXISTS idx_club_memberships_status ON club_memberships(status);
CREATE INDEX IF NOT EXISTS idx_club_memberships_membership_type ON club_memberships(membership_type);
CREATE INDEX IF NOT EXISTS idx_club_memberships_joined_at ON club_memberships(joined_at);

-- ====================================
-- 2. MEMBERSHIP REQUESTS TABLE
-- ====================================

CREATE TABLE IF NOT EXISTS membership_requests (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  club_id UUID NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,
  
  -- Request Information
  message TEXT,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  
  -- Processing Information
  processed_by UUID REFERENCES auth.users(id),
  processed_at TIMESTAMPTZ,
  reject_reason TEXT,
  admin_notes TEXT,
  
  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- Constraints
  UNIQUE(user_id, club_id, status) DEFERRABLE INITIALLY DEFERRED
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_membership_requests_user_id ON membership_requests(user_id);
CREATE INDEX IF NOT EXISTS idx_membership_requests_club_id ON membership_requests(club_id);
CREATE INDEX IF NOT EXISTS idx_membership_requests_status ON membership_requests(status);
CREATE INDEX IF NOT EXISTS idx_membership_requests_created_at ON membership_requests(created_at);

-- ====================================
-- 3. CHAT ROOMS TABLE
-- ====================================

CREATE TABLE IF NOT EXISTS chat_rooms (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  club_id UUID NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,
  
  -- Room Information
  name VARCHAR(255) NOT NULL,
  description TEXT,
  type TEXT NOT NULL DEFAULT 'general' CHECK (type IN ('general', 'tournament', 'private', 'announcement')),
  
  -- Settings
  is_active BOOLEAN DEFAULT true,
  is_public BOOLEAN DEFAULT true,
  max_members INTEGER DEFAULT 100,
  
  -- Moderation
  created_by UUID NOT NULL REFERENCES auth.users(id),
  moderators UUID[] DEFAULT '{}',
  
  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_chat_rooms_club_id ON chat_rooms(club_id);
CREATE INDEX IF NOT EXISTS idx_chat_rooms_type ON chat_rooms(type);
CREATE INDEX IF NOT EXISTS idx_chat_rooms_is_active ON chat_rooms(is_active);

-- ====================================
-- 4. CHAT ROOM MEMBERS TABLE
-- ====================================

CREATE TABLE IF NOT EXISTS chat_room_members (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  room_id UUID NOT NULL REFERENCES chat_rooms(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  
  -- Member Information
  role TEXT NOT NULL DEFAULT 'member' CHECK (role IN ('member', 'moderator', 'admin')),
  joined_at TIMESTAMPTZ DEFAULT NOW(),
  last_read_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- Settings
  notifications_enabled BOOLEAN DEFAULT true,
  
  -- Constraints
  UNIQUE(room_id, user_id)
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_chat_room_members_room_id ON chat_room_members(room_id);
CREATE INDEX IF NOT EXISTS idx_chat_room_members_user_id ON chat_room_members(user_id);

-- ====================================
-- 5. CHAT MESSAGES TABLE
-- ====================================

CREATE TABLE IF NOT EXISTS chat_messages (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  room_id UUID NOT NULL REFERENCES chat_rooms(id) ON DELETE CASCADE,
  sender_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  
  -- Message Content
  content TEXT NOT NULL,
  message_type TEXT NOT NULL DEFAULT 'text' CHECK (message_type IN ('text', 'image', 'file', 'system')),
  
  -- Attachments
  attachments JSONB DEFAULT '[]',
  
  -- Message Status
  is_edited BOOLEAN DEFAULT false,
  edited_at TIMESTAMPTZ,
  is_deleted BOOLEAN DEFAULT false,
  deleted_at TIMESTAMPTZ,
  
  -- Reply Information
  reply_to UUID REFERENCES chat_messages(id),
  
  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_chat_messages_room_id ON chat_messages(room_id);
CREATE INDEX IF NOT EXISTS idx_chat_messages_sender_id ON chat_messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_chat_messages_created_at ON chat_messages(created_at);

-- ====================================
-- 6. ANNOUNCEMENTS TABLE
-- ====================================

CREATE TABLE IF NOT EXISTS announcements (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  club_id UUID NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,
  
  -- Announcement Content
  title VARCHAR(500) NOT NULL,
  content TEXT NOT NULL,
  
  -- Priority and Categorization
  priority TEXT NOT NULL DEFAULT 'normal' CHECK (priority IN ('low', 'normal', 'high', 'urgent')),
  tags TEXT[] DEFAULT '{}',
  
  -- Publishing
  author_id UUID NOT NULL REFERENCES auth.users(id),
  is_published BOOLEAN DEFAULT false,
  published_at TIMESTAMPTZ,
  
  -- Visibility
  target_audience JSONB DEFAULT '{"all": true}', -- Can target specific groups
  
  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_announcements_club_id ON announcements(club_id);
CREATE INDEX IF NOT EXISTS idx_announcements_author_id ON announcements(author_id);
CREATE INDEX IF NOT EXISTS idx_announcements_priority ON announcements(priority);
CREATE INDEX IF NOT EXISTS idx_announcements_published_at ON announcements(published_at);

-- ====================================
-- 7. ANNOUNCEMENT READS TABLE
-- ====================================

CREATE TABLE IF NOT EXISTS announcement_reads (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  announcement_id UUID NOT NULL REFERENCES announcements(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  
  -- Read Information
  read_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- Constraints
  UNIQUE(announcement_id, user_id)
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_announcement_reads_announcement_id ON announcement_reads(announcement_id);
CREATE INDEX IF NOT EXISTS idx_announcement_reads_user_id ON announcement_reads(user_id);

-- ====================================
-- 8. NOTIFICATIONS TABLE
-- ====================================

CREATE TABLE IF NOT EXISTS notifications (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  
  -- Notification Content
  title VARCHAR(500) NOT NULL,
  content TEXT NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('message', 'tournament', 'system', 'achievement', 'announcement')),
  
  -- Status
  is_read BOOLEAN DEFAULT false,
  read_at TIMESTAMPTZ,
  
  -- Action Data
  action_data JSONB DEFAULT '{}', -- Store related IDs and actions
  
  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_type ON notifications(type);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON notifications(is_read);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON notifications(created_at);

-- ====================================
-- 9. MEMBER ACTIVITIES TABLE
-- ====================================

CREATE TABLE IF NOT EXISTS member_activities (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  club_id UUID NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,
  
  -- Activity Information
  activity_type TEXT NOT NULL CHECK (activity_type IN (
    'joined', 'left', 'post_created', 'comment_created', 'match_played', 
    'tournament_joined', 'tournament_won', 'achievement_earned', 'message_sent'
  )),
  
  -- Activity Details
  title TEXT NOT NULL,
  description TEXT,
  
  -- Related Data
  related_data JSONB DEFAULT '{}', -- Store related IDs and metadata
  
  -- Points and Scoring
  points INTEGER DEFAULT 0,
  
  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_member_activities_user_id ON member_activities(user_id);
CREATE INDEX IF NOT EXISTS idx_member_activities_club_id ON member_activities(club_id);
CREATE INDEX IF NOT EXISTS idx_member_activities_type ON member_activities(activity_type);
CREATE INDEX IF NOT EXISTS idx_member_activities_created_at ON member_activities(created_at);

-- ====================================
-- 10. MEMBER STATISTICS TABLE
-- ====================================

CREATE TABLE IF NOT EXISTS member_statistics (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  club_id UUID NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,
  
  -- Engagement Stats
  posts_count INTEGER DEFAULT 0,
  comments_count INTEGER DEFAULT 0,
  likes_given INTEGER DEFAULT 0,
  likes_received INTEGER DEFAULT 0,
  
  -- Tournament Stats
  tournaments_joined INTEGER DEFAULT 0,
  tournaments_won INTEGER DEFAULT 0,
  tournaments_podium INTEGER DEFAULT 0, -- Top 3 finishes
  
  -- Match Stats
  matches_played INTEGER DEFAULT 0,
  matches_won INTEGER DEFAULT 0,
  matches_drawn INTEGER DEFAULT 0,
  current_streak INTEGER DEFAULT 0,
  best_streak INTEGER DEFAULT 0,
  
  -- Social Stats
  messages_sent INTEGER DEFAULT 0,
  social_score DECIMAL(5,2) DEFAULT 0.0, -- Calculated engagement score
  
  -- Activity Stats
  login_streak INTEGER DEFAULT 0,
  last_login TIMESTAMPTZ,
  total_points INTEGER DEFAULT 0,
  
  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- Constraints
  UNIQUE(user_id, club_id)
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_member_statistics_user_id ON member_statistics(user_id);
CREATE INDEX IF NOT EXISTS idx_member_statistics_club_id ON member_statistics(club_id);
CREATE INDEX IF NOT EXISTS idx_member_statistics_social_score ON member_statistics(social_score);
CREATE INDEX IF NOT EXISTS idx_member_statistics_total_points ON member_statistics(total_points);

-- ====================================
-- 11. TRIGGERS FOR AUTOMATIC UPDATES
-- ====================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at
CREATE TRIGGER update_club_memberships_updated_at BEFORE UPDATE ON club_memberships FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_membership_requests_updated_at BEFORE UPDATE ON membership_requests FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_chat_rooms_updated_at BEFORE UPDATE ON chat_rooms FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_chat_messages_updated_at BEFORE UPDATE ON chat_messages FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_announcements_updated_at BEFORE UPDATE ON announcements FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_notifications_updated_at BEFORE UPDATE ON notifications FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_member_statistics_updated_at BEFORE UPDATE ON member_statistics FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ====================================
-- 12. FUNCTIONS FOR MEMBER MANAGEMENT
-- ====================================

-- Function to generate unique membership ID
CREATE OR REPLACE FUNCTION generate_membership_id(club_id_param UUID)
RETURNS TEXT AS $$
DECLARE
  club_code TEXT;
  sequence_num INTEGER;
  membership_id TEXT;
BEGIN
  -- Get club code (first 3 characters of club name, uppercase)
  SELECT UPPER(LEFT(REPLACE(name, ' ', ''), 3)) INTO club_code
  FROM clubs WHERE id = club_id_param;
  
  -- Get next sequence number for this club
  SELECT COALESCE(MAX(CAST(SUBSTRING(membership_id FROM '[0-9]+$') AS INTEGER)), 0) + 1
  INTO sequence_num
  FROM club_memberships 
  WHERE club_id = club_id_param AND membership_id IS NOT NULL;
  
  -- Generate membership ID
  membership_id := club_code || LPAD(sequence_num::TEXT, 4, '0');
  
  RETURN membership_id;
END;
$$ LANGUAGE plpgsql;

-- Function to auto-generate membership ID on insert
CREATE OR REPLACE FUNCTION set_membership_id()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.membership_id IS NULL THEN
    NEW.membership_id := generate_membership_id(NEW.club_id);
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for auto-generating membership ID
CREATE TRIGGER set_membership_id_trigger 
  BEFORE INSERT ON club_memberships 
  FOR EACH ROW EXECUTE FUNCTION set_membership_id();

-- Function to update member statistics on activity
CREATE OR REPLACE FUNCTION update_member_stats_on_activity()
RETURNS TRIGGER AS $$
BEGIN
  -- Update or create member statistics
  INSERT INTO member_statistics (user_id, club_id, total_points, updated_at)
  VALUES (NEW.user_id, NEW.club_id, NEW.points, NOW())
  ON CONFLICT (user_id, club_id) 
  DO UPDATE SET 
    total_points = member_statistics.total_points + NEW.points,
    updated_at = NOW();
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for updating member statistics
CREATE TRIGGER update_stats_on_activity_trigger 
  AFTER INSERT ON member_activities 
  FOR EACH ROW EXECUTE FUNCTION update_member_stats_on_activity();

-- ====================================
-- 13. ROW LEVEL SECURITY POLICIES
-- ====================================

-- Enable RLS on all tables
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

-- Club Memberships Policies
CREATE POLICY "Users can view their own memberships" ON club_memberships
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Club admins can manage memberships" ON club_memberships
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM club_admins 
      WHERE club_id = club_memberships.club_id 
      AND user_id = auth.uid()
      AND role IN ('admin', 'owner')
    )
  );

-- Membership Requests Policies
CREATE POLICY "Users can view their own requests" ON membership_requests
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create membership requests" ON membership_requests
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Club admins can manage requests" ON membership_requests
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM club_admins 
      WHERE club_id = membership_requests.club_id 
      AND user_id = auth.uid()
      AND role IN ('admin', 'owner')
    )
  );

-- Chat Rooms Policies
CREATE POLICY "Club members can view chat rooms" ON chat_rooms
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM club_memberships 
      WHERE club_id = chat_rooms.club_id 
      AND user_id = auth.uid()
      AND status = 'active'
    )
  );

-- Chat Messages Policies
CREATE POLICY "Room members can view messages" ON chat_messages
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM chat_room_members 
      WHERE room_id = chat_messages.room_id 
      AND user_id = auth.uid()
    )
  );

CREATE POLICY "Room members can send messages" ON chat_messages
  FOR INSERT WITH CHECK (
    auth.uid() = sender_id AND
    EXISTS (
      SELECT 1 FROM chat_room_members 
      WHERE room_id = chat_messages.room_id 
      AND user_id = auth.uid()
    )
  );

-- Notifications Policies
CREATE POLICY "Users can view their own notifications" ON notifications
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own notifications" ON notifications
  FOR UPDATE USING (auth.uid() = user_id);

-- ====================================
-- 14. SAMPLE DATA INSERTION
-- ====================================

-- Insert sample membership data (only if tables are empty)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM club_memberships LIMIT 1) THEN
    -- This will be populated by the application
    NULL;
  END IF;
END $$;

-- ====================================
-- 15. PERFORMANCE OPTIMIZATION
-- ====================================

-- Create composite indexes for common queries
CREATE INDEX IF NOT EXISTS idx_club_memberships_club_status ON club_memberships(club_id, status);
CREATE INDEX IF NOT EXISTS idx_member_activities_user_club_date ON member_activities(user_id, club_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_chat_messages_room_date ON chat_messages(room_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notifications_user_unread ON notifications(user_id, is_read, created_at DESC);

-- ====================================
-- SCHEMA COMPLETION
-- ====================================

-- Log successful completion
SELECT 'Member Management System database schema created successfully!' as status;