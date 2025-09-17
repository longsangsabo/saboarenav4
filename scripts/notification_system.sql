-- =============================================
-- SABO ARENA NOTIFICATION & REAL-TIME SYSTEM
-- Advanced backend features for notifications and real-time updates
-- =============================================

-- 1. NOTIFICATIONS TABLE
CREATE TABLE IF NOT EXISTS notifications (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  type VARCHAR(50) NOT NULL, -- 'match_invite', 'tournament_invite', 'challenge', 'match_result', 'system'
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  data JSONB DEFAULT '{}', -- Additional data like match_id, tournament_id, etc.
  
  -- State
  is_read BOOLEAN DEFAULT false,
  is_dismissed BOOLEAN DEFAULT false,
  
  -- Actions
  action_type VARCHAR(50), -- 'accept_challenge', 'view_match', 'join_tournament', 'none'
  action_data JSONB DEFAULT '{}',
  
  -- Timing
  expires_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  read_at TIMESTAMPTZ,
  
  -- Priority
  priority INTEGER DEFAULT 1 -- 1=low, 2=medium, 3=high, 4=urgent
);

-- 2. USER PREFERENCES TABLE  
CREATE TABLE IF NOT EXISTS user_preferences (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE UNIQUE,
  
  -- Notification Settings
  email_notifications BOOLEAN DEFAULT true,
  push_notifications BOOLEAN DEFAULT true,
  sms_notifications BOOLEAN DEFAULT false,
  
  -- Notification Types
  notify_match_invites BOOLEAN DEFAULT true,
  notify_tournament_invites BOOLEAN DEFAULT true,
  notify_challenges BOOLEAN DEFAULT true,
  notify_match_results BOOLEAN DEFAULT true,
  notify_spa_transactions BOOLEAN DEFAULT true,
  notify_rank_changes BOOLEAN DEFAULT true,
  notify_club_updates BOOLEAN DEFAULT false,
  notify_system_updates BOOLEAN DEFAULT true,
  
  -- Privacy Settings
  show_online_status BOOLEAN DEFAULT true,
  allow_challenges BOOLEAN DEFAULT true,
  allow_friend_requests BOOLEAN DEFAULT true,
  show_location BOOLEAN DEFAULT false,
  show_stats_publicly BOOLEAN DEFAULT true,
  
  -- Game Preferences
  preferred_game_types TEXT[] DEFAULT ARRAY['8-ball', '9-ball'],
  max_challenge_distance INTEGER DEFAULT 50, -- km
  auto_accept_friends BOOLEAN DEFAULT false,
  
  -- UI Preferences
  theme VARCHAR(20) DEFAULT 'system', -- 'light', 'dark', 'system'
  language VARCHAR(10) DEFAULT 'vi',
  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. ACTIVITY LOG TABLE
CREATE TABLE IF NOT EXISTS activity_log (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  activity_type VARCHAR(50) NOT NULL,
  description TEXT NOT NULL,
  metadata JSONB DEFAULT '{}',
  ip_address INET,
  user_agent TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. FUNCTION: CREATE NOTIFICATION
CREATE OR REPLACE FUNCTION create_notification(
  target_user_id UUID,
  notification_type VARCHAR(50),
  notification_title TEXT,
  notification_message TEXT,
  notification_data JSONB DEFAULT '{}',
  notification_priority INTEGER DEFAULT 1,
  action_type VARCHAR(50) DEFAULT 'none',
  action_data JSONB DEFAULT '{}',
  expires_in_hours INTEGER DEFAULT 168 -- 7 days default
)
RETURNS UUID AS $$
DECLARE
  notification_id UUID;
BEGIN
  INSERT INTO notifications (
    user_id, type, title, message, data, priority, 
    action_type, action_data, expires_at
  ) VALUES (
    target_user_id, notification_type, notification_title, 
    notification_message, notification_data, notification_priority,
    action_type, action_data, 
    NOW() + (expires_in_hours || ' hours')::INTERVAL
  ) RETURNING id INTO notification_id;
  
  RETURN notification_id;
END;
$$ LANGUAGE plpgsql;

-- 5. FUNCTION: GET USER NOTIFICATIONS
CREATE OR REPLACE FUNCTION get_user_notifications(
  target_user_id UUID,
  include_read BOOLEAN DEFAULT false,
  limit_count INTEGER DEFAULT 20
)
RETURNS TABLE(
  id UUID,
  type VARCHAR(50),
  title TEXT,
  message TEXT,
  data JSONB,
  priority INTEGER,
  action_type VARCHAR(50),
  action_data JSONB,
  is_read BOOLEAN,
  is_dismissed BOOLEAN,
  created_at TIMESTAMPTZ,
  expires_at TIMESTAMPTZ,
  is_expired BOOLEAN
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    n.id,
    n.type,
    n.title,
    n.message,
    n.data,
    n.priority,
    n.action_type,
    n.action_data,
    n.is_read,
    n.is_dismissed,
    n.created_at,
    n.expires_at,
    (n.expires_at < NOW()) as is_expired
  FROM notifications n
  WHERE n.user_id = target_user_id
    AND NOT n.is_dismissed
    AND (include_read OR NOT n.is_read)
    AND (n.expires_at IS NULL OR n.expires_at > NOW())
  ORDER BY n.priority DESC, n.created_at DESC
  LIMIT limit_count;
END;
$$ LANGUAGE plpgsql;

-- 6. FUNCTION: MARK NOTIFICATIONS AS READ
CREATE OR REPLACE FUNCTION mark_notifications_read(
  target_user_id UUID,
  notification_ids UUID[] DEFAULT NULL -- If NULL, mark all as read
)
RETURNS INTEGER AS $$
DECLARE
  affected_count INTEGER;
BEGIN
  IF notification_ids IS NULL THEN
    UPDATE notifications 
    SET is_read = true, read_at = NOW()
    WHERE user_id = target_user_id AND NOT is_read;
  ELSE
    UPDATE notifications 
    SET is_read = true, read_at = NOW()
    WHERE user_id = target_user_id 
      AND id = ANY(notification_ids) 
      AND NOT is_read;
  END IF;
  
  GET DIAGNOSTICS affected_count = ROW_COUNT;
  RETURN affected_count;
END;
$$ LANGUAGE plpgsql;

-- 7. FUNCTION: AUTO-NOTIFY ON CHALLENGE CREATION
CREATE OR REPLACE FUNCTION notify_challenge_created()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM create_notification(
    NEW.challenged_id,
    'challenge',
    'Thách đấu mới!',
    (SELECT display_name FROM users WHERE id = NEW.challenger_id) || ' đã thách đấu bạn!',
    jsonb_build_object(
      'challenge_id', NEW.id,
      'challenger_id', NEW.challenger_id,
      'challenge_type', NEW.challenge_type,
      'stakes_amount', NEW.stakes_amount
    ),
    CASE WHEN NEW.challenge_type = 'thach_dau' THEN 3 ELSE 2 END,
    'accept_challenge',
    jsonb_build_object('challenge_id', NEW.id),
    72 -- 3 days to respond
  );
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 8. FUNCTION: AUTO-NOTIFY ON MATCH COMPLETION
CREATE OR REPLACE FUNCTION notify_match_completed()
RETURNS TRIGGER AS $$
DECLARE
  winner_name TEXT;
  loser_id UUID;
BEGIN
  IF NEW.status = 'completed' AND OLD.status != 'completed' THEN
    SELECT display_name INTO winner_name FROM users WHERE id = NEW.winner_id;
    
    loser_id := CASE WHEN NEW.player1_id = NEW.winner_id THEN NEW.player2_id ELSE NEW.player1_id END;
    
    -- Notify winner
    PERFORM create_notification(
      NEW.winner_id,
      'match_result',
      'Chiến thắng!',
      'Bạn đã thắng trận đấu với tỷ số ' || 
        CASE WHEN NEW.player1_id = NEW.winner_id THEN NEW.player1_score || '-' || NEW.player2_score 
        ELSE NEW.player2_score || '-' || NEW.player1_score END,
      jsonb_build_object(
        'match_id', NEW.id,
        'result', 'won',
        'opponent_id', loser_id,
        'spa_change', COALESCE(NEW.spa_stakes_amount, 0)
      ),
      2,
      'view_match',
      jsonb_build_object('match_id', NEW.id)
    );
    
    -- Notify loser
    PERFORM create_notification(
      loser_id,
      'match_result',
      'Kết thúc trận đấu',
      'Trận đấu với ' || winner_name || ' đã kết thúc với tỷ số ' || 
        CASE WHEN NEW.player1_id = loser_id THEN NEW.player1_score || '-' || NEW.player2_score 
        ELSE NEW.player2_score || '-' || NEW.player1_score END,
      jsonb_build_object(
        'match_id', NEW.id,
        'result', 'lost',
        'opponent_id', NEW.winner_id,
        'spa_change', -COALESCE(NEW.spa_stakes_amount, 0)
      ),
      2,
      'view_match',
      jsonb_build_object('match_id', NEW.id)
    );
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 9. FUNCTION: GET ONLINE USERS NEARBY
CREATE OR REPLACE FUNCTION get_nearby_online_users(
  user_id UUID,
  radius_km INTEGER DEFAULT 50,
  limit_count INTEGER DEFAULT 20
)
RETURNS TABLE(
  id UUID,
  username TEXT,
  display_name TEXT,
  rank TEXT,
  elo_rating INTEGER,
  distance_km DECIMAL(8,2),
  is_available_for_challenges BOOLEAN,
  last_seen TIMESTAMPTZ,
  preferred_game_types TEXT[]
) AS $$
DECLARE
  user_lat DECIMAL(10,8);
  user_lng DECIMAL(11,8);
BEGIN
  -- Get current user's location
  SELECT latitude, longitude INTO user_lat, user_lng 
  FROM users WHERE users.id = user_id;
  
  IF user_lat IS NULL OR user_lng IS NULL THEN
    RAISE EXCEPTION 'User location not set';
  END IF;
  
  RETURN QUERY
  SELECT 
    u.id,
    u.username,
    u.display_name,
    u.rank,
    u.elo_rating,
    ROUND(
      6371 * acos(
        cos(radians(user_lat)) * cos(radians(u.latitude)) * 
        cos(radians(u.longitude) - radians(user_lng)) + 
        sin(radians(user_lat)) * sin(radians(u.latitude))
      ), 2
    ) as distance_km,
    COALESCE(u.is_available_for_challenges, true),
    u.last_seen,
    COALESCE(up.preferred_game_types, ARRAY['8-ball']::TEXT[])
  FROM users u
  LEFT JOIN user_preferences up ON up.user_id = u.id
  WHERE u.id != user_id
    AND u.latitude IS NOT NULL 
    AND u.longitude IS NOT NULL
    AND u.is_online = true
    AND u.last_seen >= NOW() - INTERVAL '1 hour'
    AND (
      6371 * acos(
        cos(radians(user_lat)) * cos(radians(u.latitude)) * 
        cos(radians(u.longitude) - radians(user_lng)) + 
        sin(radians(user_lat)) * sin(radians(u.latitude))
      )
    ) <= radius_km
  ORDER BY distance_km ASC
  LIMIT limit_count;
END;
$$ LANGUAGE plpgsql;

-- 10. FUNCTION: LOG USER ACTIVITY
CREATE OR REPLACE FUNCTION log_user_activity(
  user_id UUID,
  activity VARCHAR(50),
  description TEXT,
  metadata JSONB DEFAULT '{}',
  ip_addr INET DEFAULT NULL,
  user_agent_string TEXT DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
  log_id UUID;
BEGIN
  INSERT INTO activity_log (
    user_id, activity_type, description, metadata, ip_address, user_agent
  ) VALUES (
    user_id, activity, description, metadata, ip_addr, user_agent_string
  ) RETURNING id INTO log_id;
  
  RETURN log_id;
END;
$$ LANGUAGE plpgsql;

-- 11. FUNCTION: CLEANUP OLD DATA
CREATE OR REPLACE FUNCTION cleanup_old_data()
RETURNS TEXT AS $$
DECLARE
  deleted_notifications INTEGER;
  deleted_activities INTEGER;
BEGIN
  -- Delete expired notifications
  DELETE FROM notifications 
  WHERE expires_at < NOW() - INTERVAL '7 days';
  GET DIAGNOSTICS deleted_notifications = ROW_COUNT;
  
  -- Delete old activity logs (keep 3 months)
  DELETE FROM activity_log 
  WHERE created_at < NOW() - INTERVAL '3 months';
  GET DIAGNOSTICS deleted_activities = ROW_COUNT;
  
  RETURN 'Deleted ' || deleted_notifications || ' notifications and ' || 
         deleted_activities || ' activity logs';
END;
$$ LANGUAGE plpgsql;

-- CREATE TRIGGERS
CREATE TRIGGER trigger_notify_challenge_created
  AFTER INSERT ON challenges
  FOR EACH ROW
  EXECUTE FUNCTION notify_challenge_created();

CREATE TRIGGER trigger_notify_match_completed
  AFTER UPDATE ON matches
  FOR EACH ROW
  EXECUTE FUNCTION notify_match_completed();

-- CREATE INDEXES FOR PERFORMANCE
CREATE INDEX IF NOT EXISTS idx_notifications_user_unread ON notifications(user_id, is_read, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notifications_expires ON notifications(expires_at) WHERE expires_at IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_activity_log_user_time ON activity_log(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_users_location ON users(latitude, longitude) WHERE latitude IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_users_online ON users(is_online, last_seen DESC) WHERE is_online = true;

-- ENABLE RLS AND PERMISSIONS
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE activity_log ENABLE ROW LEVEL SECURITY;

-- RLS POLICIES
CREATE POLICY "Users can only see their own notifications" ON notifications
  FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can only manage their own preferences" ON user_preferences
  FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can only see their own activity log" ON activity_log
  FOR ALL USING (auth.uid() = user_id);

-- GRANT PERMISSIONS
GRANT EXECUTE ON FUNCTION create_notification(UUID, VARCHAR(50), TEXT, TEXT, JSONB, INTEGER, VARCHAR(50), JSONB, INTEGER) TO authenticated;
GRANT EXECUTE ON FUNCTION get_user_notifications(UUID, BOOLEAN, INTEGER) TO authenticated;
GRANT EXECUTE ON FUNCTION mark_notifications_read(UUID, UUID[]) TO authenticated;
GRANT EXECUTE ON FUNCTION get_nearby_online_users(UUID, INTEGER, INTEGER) TO authenticated;
GRANT EXECUTE ON FUNCTION log_user_activity(UUID, VARCHAR(50), TEXT, JSONB, INET, TEXT) TO authenticated;

-- GRANT TABLE ACCESS
GRANT ALL ON notifications TO authenticated;
GRANT ALL ON user_preferences TO authenticated;
GRANT ALL ON activity_log TO authenticated;

-- =============================================
-- USAGE EXAMPLES:
-- =============================================

-- Create a notification
-- SELECT create_notification(
--   'user-uuid', 'challenge', 'New Challenge!', 
--   'Someone challenged you to a match!',
--   '{"challenge_id": "challenge-uuid"}', 3
-- );

-- Get user notifications  
-- SELECT * FROM get_user_notifications('user-uuid', false, 10);

-- Mark notifications as read
-- SELECT mark_notifications_read('user-uuid', ARRAY['notification-uuid-1', 'notification-uuid-2']);

-- Find nearby online users
-- SELECT * FROM get_nearby_online_users('user-uuid', 25, 10);

-- Log user activity
-- SELECT log_user_activity('user-uuid', 'login', 'User logged in', '{"device": "mobile"}');

-- Cleanup old data (run periodically)
-- SELECT cleanup_old_data();