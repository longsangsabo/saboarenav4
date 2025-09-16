-- Fix function conflicts by dropping and recreating
-- Run this in Supabase Dashboard > SQL Editor

-- 1. Drop existing functions first
DROP FUNCTION IF EXISTS public.get_user_ranking(uuid);
DROP FUNCTION IF EXISTS public.get_auth_users_count();
DROP FUNCTION IF EXISTS public.get_auth_users_sample();

-- 2. Create get_auth_users_count function
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

-- 3. Create get_auth_users_sample function
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

-- 4. Create get_user_ranking function with correct parameter name
CREATE OR REPLACE FUNCTION public.get_user_ranking(user_uuid UUID)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    user_rank INTEGER;
BEGIN
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

-- 5. Grant permissions
GRANT EXECUTE ON FUNCTION public.get_auth_users_count() TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_auth_users_sample() TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_user_ranking(UUID) TO authenticated;

-- 6. Test the functions
SELECT 'Functions created successfully!' as status;
SELECT public.get_auth_users_count() as auth_users_count;
SELECT COUNT(*) as public_users_count FROM public.users;