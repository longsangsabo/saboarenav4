-- Admin function: Add all users to a tournament for testing purposes
-- This function allows admin to quickly populate a tournament with all existing users

CREATE OR REPLACE FUNCTION public.add_all_users_to_tournament(
    tournament_id UUID,
    admin_user_id UUID DEFAULT NULL
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    tournament_record RECORD;
    user_record RECORD;
    added_count INTEGER := 0;
    already_joined_count INTEGER := 0;
    max_participants INTEGER;
    current_participants INTEGER;
    result json;
BEGIN
    -- Check if tournament exists
    SELECT * INTO tournament_record 
    FROM tournaments 
    WHERE id = tournament_id;
    
    IF NOT FOUND THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Tournament not found',
            'tournament_id', tournament_id
        );
    END IF;
    
    -- Get current participant count and max allowed
    max_participants := tournament_record.max_participants;
    current_participants := tournament_record.current_participants;
    
    -- Check if tournament is still accepting participants
    IF tournament_record.status != 'upcoming' THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Tournament is not in upcoming status',
            'status', tournament_record.status
        );
    END IF;
    
    -- Loop through all users and add them to tournament
    FOR user_record IN 
        SELECT id, username, display_name 
        FROM users 
        WHERE id != COALESCE(admin_user_id, '00000000-0000-0000-0000-000000000000'::UUID)
        ORDER BY created_at ASC
    LOOP
        -- Check if user is already in tournament
        IF EXISTS (
            SELECT 1 FROM tournament_participants 
            WHERE tournament_id = add_all_users_to_tournament.tournament_id 
            AND user_id = user_record.id
        ) THEN
            already_joined_count := already_joined_count + 1;
            CONTINUE;
        END IF;
        
        -- Check if tournament is full
        IF current_participants >= max_participants THEN
            EXIT; -- Stop adding more users
        END IF;
        
        -- Add user to tournament
        INSERT INTO tournament_participants (
            tournament_id,
            user_id,
            joined_at,
            status
        ) VALUES (
            add_all_users_to_tournament.tournament_id,
            user_record.id,
            NOW(),
            'confirmed'
        );
        
        added_count := added_count + 1;
        current_participants := current_participants + 1;
    END LOOP;
    
    -- Update tournament participant count
    UPDATE tournaments 
    SET 
        current_participants = current_participants,
        updated_at = NOW()
    WHERE id = tournament_id;
    
    -- Build result
    result := json_build_object(
        'success', true,
        'tournament_id', tournament_id,
        'tournament_title', tournament_record.title,
        'users_added', added_count,
        'already_joined', already_joined_count,
        'total_participants', current_participants,
        'max_participants', max_participants,
        'is_full', current_participants >= max_participants
    );
    
    RETURN result;
    
EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'error', SQLERRM,
            'code', SQLSTATE
        );
END;
$$;

-- Grant execute permission to authenticated users (admin check will be done in app layer)
GRANT EXECUTE ON FUNCTION public.add_all_users_to_tournament(UUID, UUID) TO authenticated;

-- Create a complementary function to remove all users from tournament (for testing cleanup)
CREATE OR REPLACE FUNCTION public.remove_all_users_from_tournament(
    tournament_id UUID,
    admin_user_id UUID DEFAULT NULL
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    tournament_record RECORD;
    removed_count INTEGER := 0;
    result json;
BEGIN
    -- Check if tournament exists
    SELECT * INTO tournament_record 
    FROM tournaments 
    WHERE id = tournament_id;
    
    IF NOT FOUND THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Tournament not found'
        );
    END IF;
    
    -- Remove all participants except admin (if specified)
    DELETE FROM tournament_participants 
    WHERE tournament_id = remove_all_users_from_tournament.tournament_id
    AND user_id != COALESCE(admin_user_id, '00000000-0000-0000-0000-000000000000'::UUID);
    
    GET DIAGNOSTICS removed_count = ROW_COUNT;
    
    -- Update tournament participant count
    UPDATE tournaments 
    SET 
        current_participants = (
            SELECT COUNT(*) 
            FROM tournament_participants 
            WHERE tournament_id = remove_all_users_from_tournament.tournament_id
        ),
        updated_at = NOW()
    WHERE id = tournament_id;
    
    result := json_build_object(
        'success', true,
        'tournament_id', tournament_id,
        'tournament_title', tournament_record.title,
        'users_removed', removed_count
    );
    
    RETURN result;
    
EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'error', SQLERRM,
            'code', SQLSTATE
        );
END;
$$;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION public.remove_all_users_from_tournament(UUID, UUID) TO authenticated;