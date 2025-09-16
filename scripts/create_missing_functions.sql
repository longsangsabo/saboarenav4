-- Create missing database functions for SABO Arena
-- Run this in Supabase Dashboard > SQL Editor

-- 1. Function to count auth users
CREATE OR REPLACE FUNCTION public.get_auth_users_count()
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN (SELECT COUNT(*) FROM auth.users);
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
END;
$$;

-- 2. Function to get sample auth users
CREATE OR REPLACE FUNCTION public.get_auth_users_sample()
RETURNS TABLE(id UUID, email TEXT, created_at TIMESTAMPTZ) 
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY 
    SELECT au.id, au.email, au.created_at 
    FROM auth.users au 
    ORDER BY au.created_at DESC
    LIMIT 3;
EXCEPTION
    WHEN OTHERS THEN
        RETURN;
END;
$$;

-- 3. Function to get user ranking (already exists but improved version)
CREATE OR REPLACE FUNCTION public.get_user_ranking(user_uuid UUID)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    user_rank INTEGER;
BEGIN
    -- Count how many users have higher ranking points
    SELECT COUNT(*) + 1 INTO user_rank
    FROM public.users
    WHERE ranking_points > (
        SELECT COALESCE(ranking_points, 0)
        FROM public.users 
        WHERE id = user_uuid
    ) AND is_active = true;
    
    RETURN COALESCE(user_rank, 0);
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
END;
$$;

-- 4. Function to get nearby players (enhanced with PostGIS)
CREATE OR REPLACE FUNCTION public.get_nearby_players(
    center_lat DECIMAL,
    center_lng DECIMAL,
    radius_km INTEGER DEFAULT 10
)
RETURNS TABLE (
    user_id UUID,
    username TEXT,
    display_name TEXT,
    avatar_url TEXT,
    skill_level TEXT,
    ranking_points INTEGER,
    distance_km DECIMAL,
    is_online BOOLEAN
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        u.id,
        u.username,
        u.display_name,
        u.avatar_url,
        u.skill_level,
        u.ranking_points,
        -- Simple distance calculation (not accurate for production)
        ROUND(
            (111.111 * SQRT(
                POW(CAST(u.latitude AS DECIMAL) - center_lat, 2) + 
                POW(CAST(u.longitude AS DECIMAL) - center_lng, 2)
            ))::DECIMAL, 2
        ) AS distance_km,
        (u.last_seen > NOW() - INTERVAL '15 minutes') AS is_online
    FROM public.users u
    WHERE 
        u.latitude IS NOT NULL 
        AND u.longitude IS NOT NULL
        AND u.is_active = true
        AND (111.111 * SQRT(
            POW(CAST(u.latitude AS DECIMAL) - center_lat, 2) + 
            POW(CAST(u.longitude AS DECIMAL) - center_lng, 2)
        )) <= radius_km
    ORDER BY distance_km, u.ranking_points DESC
    LIMIT 20;
EXCEPTION
    WHEN OTHERS THEN
        RETURN;
END;
$$;

-- 5. Function to update tournament participant count
CREATE OR REPLACE FUNCTION public.update_tournament_participant_count()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE public.tournaments 
        SET current_participants = current_participants + 1 
        WHERE id = NEW.tournament_id;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE public.tournaments 
        SET current_participants = GREATEST(current_participants - 1, 0)
        WHERE id = OLD.tournament_id;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$;

-- Create trigger for tournament participant count
DROP TRIGGER IF EXISTS tournament_participant_count_trigger ON public.tournament_participants;
CREATE TRIGGER tournament_participant_count_trigger
    AFTER INSERT OR DELETE ON public.tournament_participants
    FOR EACH ROW EXECUTE FUNCTION public.update_tournament_participant_count();

-- 6. Function to calculate win rate
CREATE OR REPLACE FUNCTION public.calculate_win_rate(user_uuid UUID)
RETURNS DECIMAL
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    total_games INTEGER;
    wins INTEGER;
BEGIN
    SELECT total_wins, (total_wins + total_losses) 
    INTO wins, total_games
    FROM public.users 
    WHERE id = user_uuid;
    
    IF total_games = 0 OR total_games IS NULL THEN
        RETURN 0.00;
    END IF;
    
    RETURN ROUND((wins::DECIMAL / total_games) * 100, 2);
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0.00;
END;
$$;

-- 7. Function to get user feed (posts from followed users)
CREATE OR REPLACE FUNCTION public.get_user_feed(user_uuid UUID, page_limit INTEGER DEFAULT 20, page_offset INTEGER DEFAULT 0)
RETURNS TABLE (
    post_id UUID,
    user_id UUID,
    author_name TEXT,
    author_avatar TEXT,
    content TEXT,
    image_urls TEXT[],
    hashtags TEXT[],
    like_count INTEGER,
    comment_count INTEGER,
    tournament_id UUID,
    club_id UUID,
    created_at TIMESTAMPTZ,
    is_liked BOOLEAN
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT
        p.id,
        p.user_id,
        u.display_name,
        u.avatar_url,
        p.content,
        p.image_urls,
        p.hashtags,
        p.like_count,
        p.comment_count,
        p.tournament_id,
        p.club_id,
        p.created_at,
        EXISTS(
            SELECT 1 FROM public.post_interactions pi 
            WHERE pi.post_id = p.id 
            AND pi.user_id = user_uuid 
            AND pi.interaction_type = 'like'
        ) AS is_liked
    FROM public.posts p
    JOIN public.users u ON p.user_id = u.id
    WHERE 
        p.is_public = true
        AND (
            p.user_id = user_uuid  -- Own posts
            OR p.user_id IN (      -- Posts from followed users
                SELECT following_id 
                FROM public.user_follows 
                WHERE follower_id = user_uuid
            )
        )
    ORDER BY p.created_at DESC
    LIMIT page_limit OFFSET page_offset;
EXCEPTION
    WHEN OTHERS THEN
        RETURN;
END;
$$;

-- Grant execute permissions
GRANT EXECUTE ON FUNCTION public.get_auth_users_count() TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_auth_users_sample() TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_user_ranking(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_nearby_players(DECIMAL, DECIMAL, INTEGER) TO authenticated;
GRANT EXECUTE ON FUNCTION public.calculate_win_rate(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_user_feed(UUID, INTEGER, INTEGER) TO authenticated;

-- Test the functions
SELECT 'Functions created successfully!' as status;
SELECT public.get_auth_users_count() as auth_users_count;
SELECT COUNT(*) as public_users_count FROM public.users;