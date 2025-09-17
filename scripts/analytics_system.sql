-- =============================================
-- SABO ARENA ANALYTICS SYSTEM
-- Comprehensive backend analytics for player performance
-- =============================================

-- 1. PLAYER PERFORMANCE ANALYTICS FUNCTION
CREATE OR REPLACE FUNCTION get_player_analytics(player_uuid UUID)
RETURNS TABLE(
  player_id UUID,
  username TEXT,
  display_name TEXT,
  rank TEXT,
  elo_rating INTEGER,
  
  -- Match Statistics
  total_matches INTEGER,
  wins INTEGER,
  losses INTEGER,
  win_rate DECIMAL(5,2),
  current_win_streak INTEGER,
  longest_win_streak INTEGER,
  
  -- Tournament Performance
  tournaments_played INTEGER,
  tournament_wins INTEGER,
  tournament_finals INTEGER,
  tournament_win_rate DECIMAL(5,2),
  
  -- Recent Performance (last 30 days)
  recent_matches INTEGER,
  recent_wins INTEGER,
  recent_win_rate DECIMAL(5,2),
  
  -- SPA System Stats
  spa_points INTEGER,
  spa_points_won INTEGER,
  spa_points_lost INTEGER,
  spa_net_points INTEGER,
  
  -- Activity Stats
  avg_matches_per_week DECIMAL(5,2),
  last_match_date TIMESTAMPTZ,
  days_since_last_match INTEGER,
  activity_level TEXT
) AS $$
BEGIN
  RETURN QUERY
  WITH player_stats AS (
    SELECT 
      u.id,
      u.username,
      u.display_name,
      u.rank,
      u.elo_rating,
      u.total_matches,
      u.wins,
      u.losses,
      u.win_streak,
      u.tournaments_played,
      u.tournament_wins,
      COALESCE(u.spa_points, 1000) as spa_points,
      COALESCE(u.spa_points_won, 0) as spa_points_won,
      COALESCE(u.spa_points_lost, 0) as spa_points_lost
    FROM users u
    WHERE u.id = player_uuid
  ),
  match_stats AS (
    SELECT 
      COUNT(*) as total_match_count,
      SUM(CASE WHEN winner_id = player_uuid THEN 1 ELSE 0 END) as total_wins,
      MAX(CASE WHEN winner_id = player_uuid THEN win_streak ELSE 0 END) as max_win_streak,
      MAX(played_at) as last_match,
      COUNT(CASE WHEN played_at >= NOW() - INTERVAL '30 days' THEN 1 END) as recent_matches_count,
      SUM(CASE WHEN played_at >= NOW() - INTERVAL '30 days' AND winner_id = player_uuid THEN 1 ELSE 0 END) as recent_wins_count
    FROM matches m
    WHERE (m.player1_id = player_uuid OR m.player2_id = player_uuid)
      AND m.status = 'completed'
  ),
  tournament_stats AS (
    SELECT 
      COUNT(DISTINCT t.id) as tournaments_count,
      SUM(CASE WHEN t.winner_id = player_uuid THEN 1 ELSE 0 END) as tournament_wins_count,
      SUM(CASE WHEN (t.final_match_id IN (
        SELECT id FROM matches 
        WHERE (player1_id = player_uuid OR player2_id = player_uuid)
      )) THEN 1 ELSE 0 END) as finals_count
    FROM tournaments t
    JOIN tournament_participants tp ON tp.tournament_id = t.id
    WHERE tp.user_id = player_uuid
  )
  SELECT 
    ps.id,
    ps.username,
    ps.display_name,
    ps.rank,
    ps.elo_rating,
    
    -- Match Statistics
    ps.total_matches,
    ps.wins,
    ps.losses,
    CASE WHEN ps.total_matches > 0 
      THEN ROUND((ps.wins::DECIMAL / ps.total_matches::DECIMAL) * 100, 2)
      ELSE 0.00 END as win_rate,
    ps.win_streak,
    COALESCE(ms.max_win_streak, 0),
    
    -- Tournament Performance
    ps.tournaments_played,
    ps.tournament_wins,
    COALESCE(ts.finals_count, 0),
    CASE WHEN ps.tournaments_played > 0 
      THEN ROUND((ps.tournament_wins::DECIMAL / ps.tournaments_played::DECIMAL) * 100, 2)
      ELSE 0.00 END as tournament_win_rate,
    
    -- Recent Performance
    COALESCE(ms.recent_matches_count, 0),
    COALESCE(ms.recent_wins_count, 0),
    CASE WHEN ms.recent_matches_count > 0 
      THEN ROUND((ms.recent_wins_count::DECIMAL / ms.recent_matches_count::DECIMAL) * 100, 2)
      ELSE 0.00 END as recent_win_rate,
    
    -- SPA System Stats
    ps.spa_points,
    ps.spa_points_won,
    ps.spa_points_lost,
    (ps.spa_points_won - ps.spa_points_lost) as spa_net_points,
    
    -- Activity Stats
    CASE WHEN ms.last_match IS NOT NULL 
      THEN ROUND((ps.total_matches::DECIMAL / GREATEST(EXTRACT(EPOCH FROM (NOW() - (SELECT created_at FROM users WHERE id = player_uuid))) / 604800, 1)::DECIMAL), 2)
      ELSE 0.00 END as avg_matches_per_week,
    ms.last_match,
    CASE WHEN ms.last_match IS NOT NULL 
      THEN EXTRACT(DAY FROM (NOW() - ms.last_match))::INTEGER
      ELSE 999 END as days_since_last_match,
    CASE 
      WHEN ms.last_match IS NULL THEN 'Inactive'
      WHEN ms.last_match >= NOW() - INTERVAL '7 days' THEN 'Very Active'
      WHEN ms.last_match >= NOW() - INTERVAL '30 days' THEN 'Active'
      WHEN ms.last_match >= NOW() - INTERVAL '90 days' THEN 'Somewhat Active'
      ELSE 'Inactive'
    END as activity_level
    
  FROM player_stats ps
  LEFT JOIN match_stats ms ON true
  LEFT JOIN tournament_stats ts ON true;
END;
$$ LANGUAGE plpgsql;

-- 2. LEADERBOARD FUNCTION
CREATE OR REPLACE FUNCTION get_leaderboard(
  board_type TEXT DEFAULT 'elo', -- 'elo', 'wins', 'tournaments', 'spa_points'
  rank_filter TEXT DEFAULT NULL, -- 'A', 'B', 'C', 'D', 'E' or NULL for all
  limit_count INTEGER DEFAULT 20
)
RETURNS TABLE(
  rank INTEGER,
  player_id UUID,
  username TEXT,
  display_name TEXT,
  player_rank TEXT,
  elo_rating INTEGER,
  total_wins INTEGER,
  tournament_wins INTEGER,
  spa_points INTEGER,
  win_rate DECIMAL(5,2),
  recent_activity TEXT
) AS $$
BEGIN
  RETURN QUERY
  WITH ranked_players AS (
    SELECT 
      u.id,
      u.username,
      u.display_name,
      u.rank,
      u.elo_rating,
      u.wins,
      u.tournament_wins,
      COALESCE(u.spa_points, 1000) as spa_points,
      CASE WHEN u.total_matches > 0 
        THEN ROUND((u.wins::DECIMAL / u.total_matches::DECIMAL) * 100, 2)
        ELSE 0.00 END as win_rate,
      CASE 
        WHEN u.last_seen >= NOW() - INTERVAL '7 days' THEN 'Very Active'
        WHEN u.last_seen >= NOW() - INTERVAL '30 days' THEN 'Active'
        WHEN u.last_seen >= NOW() - INTERVAL '90 days' THEN 'Somewhat Active'
        ELSE 'Inactive'
      END as activity,
      ROW_NUMBER() OVER (
        ORDER BY 
          CASE 
            WHEN board_type = 'elo' THEN u.elo_rating
            WHEN board_type = 'wins' THEN u.wins
            WHEN board_type = 'tournaments' THEN u.tournament_wins
            WHEN board_type = 'spa_points' THEN COALESCE(u.spa_points, 1000)
            ELSE u.elo_rating
          END DESC
      ) as player_rank
    FROM users u
    WHERE (rank_filter IS NULL OR u.rank = rank_filter)
      AND u.total_matches > 0 -- Only show players who have played
  )
  SELECT 
    rp.player_rank::INTEGER,
    rp.id,
    rp.username,
    rp.display_name,
    rp.rank,
    rp.elo_rating,
    rp.wins,
    rp.tournament_wins,
    rp.spa_points,
    rp.win_rate,
    rp.activity
  FROM ranked_players rp
  WHERE rp.player_rank <= limit_count
  ORDER BY rp.player_rank;
END;
$$ LANGUAGE plpgsql;

-- 3. CLUB ANALYTICS FUNCTION
CREATE OR REPLACE FUNCTION get_club_analytics(club_uuid UUID)
RETURNS TABLE(
  club_id UUID,
  club_name TEXT,
  total_members INTEGER,
  active_members INTEGER, -- members active in last 30 days
  total_tournaments INTEGER,
  completed_tournaments INTEGER,
  upcoming_tournaments INTEGER,
  total_matches INTEGER,
  avg_members_per_tournament DECIMAL(5,2),
  club_activity_score DECIMAL(5,2),
  top_player_id UUID,
  top_player_name TEXT,
  top_player_elo INTEGER
) AS $$
BEGIN
  RETURN QUERY
  WITH club_stats AS (
    SELECT 
      c.id,
      c.name,
      c.total_members,
      c.total_tournaments
    FROM clubs c
    WHERE c.id = club_uuid
  ),
  member_activity AS (
    SELECT 
      COUNT(*) as active_count
    FROM club_members cm
    JOIN users u ON u.id = cm.user_id
    WHERE cm.club_id = club_uuid
      AND u.last_seen >= NOW() - INTERVAL '30 days'
  ),
  tournament_stats AS (
    SELECT 
      COUNT(*) as total_tourns,
      SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) as completed_tourns,
      SUM(CASE WHEN status IN ('upcoming', 'active') THEN 1 ELSE 0 END) as upcoming_tourns,
      AVG(current_participants) as avg_participants
    FROM tournaments t
    WHERE t.club_id = club_uuid
  ),
  match_stats AS (
    SELECT COUNT(*) as total_match_count
    FROM matches m
    JOIN tournaments t ON t.id = m.tournament_id
    WHERE t.club_id = club_uuid
  ),
  top_player AS (
    SELECT 
      u.id,
      u.display_name,
      u.elo_rating
    FROM users u
    JOIN club_members cm ON cm.user_id = u.id
    WHERE cm.club_id = club_uuid
    ORDER BY u.elo_rating DESC, u.wins DESC
    LIMIT 1
  )
  SELECT 
    cs.id,
    cs.name,
    cs.total_members,
    COALESCE(ma.active_count, 0),
    cs.total_tournaments,
    COALESCE(ts.completed_tourns, 0),
    COALESCE(ts.upcoming_tourns, 0),
    COALESCE(ms.total_match_count, 0),
    COALESCE(ts.avg_participants, 0.00),
    -- Activity score based on recent tournaments and member activity
    CASE WHEN cs.total_members > 0 
      THEN ROUND((COALESCE(ma.active_count, 0)::DECIMAL / cs.total_members::DECIMAL) * 100, 2)
      ELSE 0.00 END as activity_score,
    tp.id,
    tp.display_name,
    tp.elo_rating
  FROM club_stats cs
  LEFT JOIN member_activity ma ON true
  LEFT JOIN tournament_stats ts ON true  
  LEFT JOIN match_stats ms ON true
  LEFT JOIN top_player tp ON true;
END;
$$ LANGUAGE plpgsql;

-- 4. ELO RATING CALCULATION FUNCTION
CREATE OR REPLACE FUNCTION calculate_elo_change(
  player1_elo INTEGER,
  player2_elo INTEGER,
  player1_won BOOLEAN,
  k_factor INTEGER DEFAULT 32
)
RETURNS TABLE(
  player1_new_elo INTEGER,
  player2_new_elo INTEGER,
  player1_change INTEGER,
  player2_change INTEGER
) AS $$
DECLARE
  expected1 DECIMAL;
  expected2 DECIMAL;
  actual1 DECIMAL;
  actual2 DECIMAL;
  change1 INTEGER;
  change2 INTEGER;
BEGIN
  -- Calculate expected scores
  expected1 := 1.0 / (1.0 + POWER(10.0, (player2_elo - player1_elo)::DECIMAL / 400.0));
  expected2 := 1.0 - expected1;
  
  -- Actual scores
  actual1 := CASE WHEN player1_won THEN 1.0 ELSE 0.0 END;
  actual2 := CASE WHEN player1_won THEN 0.0 ELSE 1.0 END;
  
  -- Calculate changes
  change1 := ROUND(k_factor * (actual1 - expected1));
  change2 := ROUND(k_factor * (actual2 - expected2));
  
  RETURN QUERY SELECT 
    player1_elo + change1,
    player2_elo + change2,
    change1,
    change2;
END;
$$ LANGUAGE plpgsql;

-- 5. MATCH HISTORY WITH DETAILED STATS
CREATE OR REPLACE FUNCTION get_match_history(
  player_uuid UUID,
  limit_count INTEGER DEFAULT 10,
  include_tournaments_only BOOLEAN DEFAULT FALSE
)
RETURNS TABLE(
  match_id UUID,
  opponent_id UUID,
  opponent_name TEXT,
  opponent_elo INTEGER,
  match_result TEXT, -- 'won', 'lost'
  player_score INTEGER,
  opponent_score INTEGER,
  match_type TEXT,
  tournament_name TEXT,
  elo_change INTEGER,
  spa_change INTEGER,
  played_at TIMESTAMPTZ,
  match_duration_minutes INTEGER
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    m.id,
    CASE WHEN m.player1_id = player_uuid THEN m.player2_id ELSE m.player1_id END as opponent_id,
    CASE WHEN m.player1_id = player_uuid THEN p2.display_name ELSE p1.display_name END as opponent_name,
    CASE WHEN m.player1_id = player_uuid THEN p2.elo_rating ELSE p1.elo_rating END as opponent_elo,
    CASE WHEN m.winner_id = player_uuid THEN 'won' ELSE 'lost' END as result,
    CASE WHEN m.player1_id = player_uuid THEN m.player1_score ELSE m.player2_score END as player_score,
    CASE WHEN m.player1_id = player_uuid THEN m.player2_score ELSE m.player1_score END as opponent_score,
    COALESCE(m.match_type, 'tournament') as match_type,
    COALESCE(t.title, 'Practice Match') as tournament_name,
    -- ELO change calculation would need to be stored or calculated
    0 as elo_change, -- Placeholder
    COALESCE(m.spa_stakes_amount, 0) * CASE WHEN m.winner_id = player_uuid THEN 1 ELSE -1 END as spa_change,
    m.played_at,
    EXTRACT(EPOCH FROM (m.updated_at - m.created_at))::INTEGER / 60 as duration_minutes
  FROM matches m
  LEFT JOIN users p1 ON p1.id = m.player1_id
  LEFT JOIN users p2 ON p2.id = m.player2_id
  LEFT JOIN tournaments t ON t.id = m.tournament_id
  WHERE (m.player1_id = player_uuid OR m.player2_id = player_uuid)
    AND m.status = 'completed'
    AND (NOT include_tournaments_only OR m.tournament_id IS NOT NULL)
  ORDER BY m.played_at DESC
  LIMIT limit_count;
END;
$$ LANGUAGE plpgsql;

-- 6. CREATE INDEXES FOR PERFORMANCE
CREATE INDEX IF NOT EXISTS idx_matches_player_performance ON matches(player1_id, player2_id, winner_id, played_at);
CREATE INDEX IF NOT EXISTS idx_users_leaderboard ON users(elo_rating DESC, wins DESC, tournament_wins DESC);
CREATE INDEX IF NOT EXISTS idx_users_activity ON users(last_seen DESC, rank);
CREATE INDEX IF NOT EXISTS idx_spa_transactions_user ON spa_transactions(user_id, created_at DESC);

-- 7. UPDATE TRIGGERS FOR REAL-TIME STATS
CREATE OR REPLACE FUNCTION update_user_stats_on_match_complete()
RETURNS TRIGGER AS $$
BEGIN
  -- Update winner stats
  IF NEW.winner_id IS NOT NULL AND NEW.status = 'completed' THEN
    UPDATE users SET 
      wins = wins + 1,
      total_matches = total_matches + 1,
      win_streak = win_streak + 1,
      updated_at = NOW()
    WHERE id = NEW.winner_id;
    
    -- Update loser stats
    UPDATE users SET 
      losses = losses + 1,
      total_matches = total_matches + 1,
      win_streak = 0,
      updated_at = NOW()
    WHERE id = CASE WHEN NEW.player1_id = NEW.winner_id THEN NEW.player2_id ELSE NEW.player1_id END;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_user_stats_on_match_complete
  AFTER UPDATE ON matches
  FOR EACH ROW
  WHEN (OLD.status != 'completed' AND NEW.status = 'completed')
  EXECUTE FUNCTION update_user_stats_on_match_complete();

-- Enable RLS for new functions
ALTER FUNCTION get_player_analytics(UUID) SECURITY DEFINER;
ALTER FUNCTION get_leaderboard(TEXT, TEXT, INTEGER) SECURITY DEFINER;  
ALTER FUNCTION get_club_analytics(UUID) SECURITY DEFINER;
ALTER FUNCTION calculate_elo_change(INTEGER, INTEGER, BOOLEAN, INTEGER) SECURITY DEFINER;
ALTER FUNCTION get_match_history(UUID, INTEGER, BOOLEAN) SECURITY DEFINER;

-- Grant execute permissions
GRANT EXECUTE ON FUNCTION get_player_analytics(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION get_leaderboard(TEXT, TEXT, INTEGER) TO authenticated;
GRANT EXECUTE ON FUNCTION get_club_analytics(UUID) TO authenticated;  
GRANT EXECUTE ON FUNCTION calculate_elo_change(INTEGER, INTEGER, BOOLEAN, INTEGER) TO authenticated;
GRANT EXECUTE ON FUNCTION get_match_history(UUID, INTEGER, BOOLEAN) TO authenticated;

-- =============================================
-- USAGE EXAMPLES:
-- =============================================

-- Get detailed analytics for a specific player
-- SELECT * FROM get_player_analytics('player-uuid-here');

-- Get ELO leaderboard for rank A players
-- SELECT * FROM get_leaderboard('elo', 'A', 10);

-- Get club analytics
-- SELECT * FROM get_club_analytics('club-uuid-here');

-- Calculate ELO change for a match
-- SELECT * FROM calculate_elo_change(1500, 1400, true, 32);

-- Get recent match history
-- SELECT * FROM get_match_history('player-uuid-here', 5, false);