-- =============================================
-- MEMBER MANAGEMENT SYSTEM SCHEMA
-- Copy và paste vào Supabase SQL Editor
-- =============================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =============================================
-- 1. USER PROFILES TABLE
-- =============================================
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

-- =============================================
-- 2. CLUB MEMBERSHIPS TABLE
-- =============================================
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

-- =============================================
-- 3. MEMBERSHIP REQUESTS TABLE
-- =============================================
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

-- =============================================
-- 4. CHAT ROOMS TABLE
-- =============================================
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

-- =============================================
-- 5. CHAT ROOM MEMBERS TABLE
-- =============================================
CREATE TABLE IF NOT EXISTS public.chat_room_members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    room_id UUID REFERENCES public.chat_rooms(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    joined_at TIMESTAMPTZ DEFAULT NOW(),
    role VARCHAR(20) DEFAULT 'member',
    UNIQUE(room_id, user_id)
);

-- =============================================
-- 6. CHAT MESSAGES TABLE
-- =============================================
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

-- =============================================
-- 7. ANNOUNCEMENTS TABLE
-- =============================================
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

-- =============================================
-- 8. ANNOUNCEMENT READS TABLE
-- =============================================
CREATE TABLE IF NOT EXISTS public.announcement_reads (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    announcement_id UUID REFERENCES public.announcements(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    read_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(announcement_id, user_id)
);

-- =============================================
-- 9. NOTIFICATIONS TABLE
-- =============================================
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

-- =============================================
-- 10. MEMBER ACTIVITIES TABLE
-- =============================================
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

-- =============================================
-- 11. MEMBER STATISTICS TABLE
-- =============================================
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

-- =============================================
-- 12. CREATE INDEXES FOR PERFORMANCE
-- =============================================
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

-- =============================================
-- 13. ENABLE ROW LEVEL SECURITY
-- =============================================
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

-- =============================================
-- 14. CREATE UTILITY FUNCTIONS
-- =============================================

-- Function to generate membership ID
CREATE OR REPLACE FUNCTION generate_membership_id()
RETURNS TEXT AS $$
BEGIN
    RETURN 'MEM' || TO_CHAR(NOW(), 'YYYYMMDD') || LPAD(FLOOR(RANDOM() * 999999)::text, 6, '0');
END;
$$ LANGUAGE plpgsql;

-- Function to set membership ID automatically
CREATE OR REPLACE FUNCTION set_membership_id()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.membership_id IS NULL OR NEW.membership_id = '' THEN
        NEW.membership_id := generate_membership_id();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to update updated_at column
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- =============================================
-- 15. CREATE TRIGGERS
-- =============================================

-- Trigger to auto-generate membership ID
DROP TRIGGER IF EXISTS trigger_set_membership_id ON public.club_memberships;
CREATE TRIGGER trigger_set_membership_id
    BEFORE INSERT ON public.club_memberships
    FOR EACH ROW
    EXECUTE FUNCTION set_membership_id();

-- Triggers to auto-update updated_at timestamps
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

-- =============================================
-- 16. CREATE RLS POLICIES
-- =============================================

-- Club membership policies
DROP POLICY IF EXISTS "club_membership_select" ON public.club_memberships;
CREATE POLICY "club_membership_select" ON public.club_memberships
FOR SELECT USING (
    club_id IN (
        SELECT id FROM public.clubs 
        WHERE owner_id = auth.uid()
    ) OR user_id = auth.uid()
);

DROP POLICY IF EXISTS "club_membership_insert" ON public.club_memberships;
CREATE POLICY "club_membership_insert" ON public.club_memberships
FOR INSERT WITH CHECK (
    club_id IN (
        SELECT id FROM public.clubs 
        WHERE owner_id = auth.uid()
    )
);

DROP POLICY IF EXISTS "club_membership_update" ON public.club_memberships;
CREATE POLICY "club_membership_update" ON public.club_memberships
FOR UPDATE USING (
    club_id IN (
        SELECT id FROM public.clubs 
        WHERE owner_id = auth.uid()
    )
);

-- Membership request policies
DROP POLICY IF EXISTS "membership_request_select" ON public.membership_requests;
CREATE POLICY "membership_request_select" ON public.membership_requests
FOR SELECT USING (
    club_id IN (
        SELECT id FROM public.clubs 
        WHERE owner_id = auth.uid()
    ) OR user_id = auth.uid()
);

DROP POLICY IF EXISTS "membership_request_insert" ON public.membership_requests;
CREATE POLICY "membership_request_insert" ON public.membership_requests
FOR INSERT WITH CHECK (user_id = auth.uid());

-- Notification policies
DROP POLICY IF EXISTS "notification_select" ON public.notifications;
CREATE POLICY "notification_select" ON public.notifications
FOR SELECT USING (user_id = auth.uid());

DROP POLICY IF EXISTS "notification_update" ON public.notifications;
CREATE POLICY "notification_update" ON public.notifications
FOR UPDATE USING (user_id = auth.uid());

-- =============================================
-- 17. INSERT SAMPLE DATA
-- =============================================

-- Create general chat room for each club
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

-- =============================================
-- 18. CREATE EXEC_SQL FUNCTION (OPTIONAL)
-- =============================================
CREATE OR REPLACE FUNCTION exec_sql(query text)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
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
$$;

-- =============================================
-- SETUP COMPLETE!
-- =============================================