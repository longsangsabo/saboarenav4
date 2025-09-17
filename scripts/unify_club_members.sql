-- Unify club member system - Use only club_members table

-- 1. First, migrate any data from club_memberships to club_members (if any)
INSERT INTO public.club_members (club_id, user_id, role, joined_at, status)
SELECT 
  club_id,
  user_id,
  CASE 
    WHEN membership_type = 'premium' THEN 'admin'
    WHEN membership_type = 'vip' THEN 'admin'
    ELSE 'member'
  END as role,
  joined_at,
  status
FROM public.club_memberships
WHERE NOT EXISTS (
  SELECT 1 FROM public.club_members cm 
  WHERE cm.club_id = club_memberships.club_id 
  AND cm.user_id = club_memberships.user_id
);

-- 2. Drop the club_memberships table
DROP TABLE IF EXISTS public.club_memberships CASCADE;

-- 3. Also drop related tables that depend on club_memberships
DROP TABLE IF EXISTS public.member_activities CASCADE;
DROP TABLE IF EXISTS public.member_statistics CASCADE;
DROP TABLE IF EXISTS public.membership_requests CASCADE;

-- 4. Fix club_members RLS policy
DROP POLICY IF EXISTS "users_manage_own_club_memberships" ON public.club_members;
DROP POLICY IF EXISTS "public_club_members_read" ON public.club_members;

-- Create comprehensive policy for club_members
CREATE POLICY "club_members_comprehensive_access"
ON public.club_members
FOR ALL
TO authenticated
USING (
  -- Users can see members of clubs they belong to
  club_id IN (
    SELECT club_id 
    FROM public.club_members 
    WHERE user_id = auth.uid()
  )
  OR
  -- Club owners can see all members of their clubs
  club_id IN (
    SELECT id 
    FROM public.clubs 
    WHERE owner_id = auth.uid()
  )
  OR
  -- Anyone can see members of public approved clubs (for discovery)
  club_id IN (
    SELECT id 
    FROM public.clubs 
    WHERE approval_status = 'approved'
    AND is_active = true
  )
)
WITH CHECK (
  -- Only allow users to manage their own membership or club owners to manage their club
  user_id = auth.uid()
  OR
  club_id IN (
    SELECT id 
    FROM public.clubs 
    WHERE owner_id = auth.uid()
  )
);

-- 5. Ensure proper indexes
CREATE INDEX IF NOT EXISTS idx_club_members_club_user ON public.club_members(club_id, user_id);
CREATE INDEX IF NOT EXISTS idx_club_members_user_role ON public.club_members(user_id, role);

-- 6. Add some test data for longsang's club
DO $$
DECLARE 
  longsang_club_id UUID;
  longsang_user_id UUID;
BEGIN
  -- Get longsang's club and user ID
  SELECT id INTO longsang_club_id FROM public.clubs WHERE owner_id = (
    SELECT id FROM public.users WHERE username = 'longsang063' OR email LIKE '%longsang%' LIMIT 1
  ) LIMIT 1;
  
  SELECT id INTO longsang_user_id FROM public.users WHERE username = 'longsang063' OR email LIKE '%longsang%' LIMIT 1;
  
  -- Add longsang as owner of his club if not exists
  IF longsang_club_id IS NOT NULL AND longsang_user_id IS NOT NULL THEN
    INSERT INTO public.club_members (club_id, user_id, role, joined_at, status)
    VALUES (longsang_club_id, longsang_user_id, 'owner', NOW(), 'active')
    ON CONFLICT (club_id, user_id) DO UPDATE SET role = 'owner', status = 'active';
    
    -- Add a few sample members
    INSERT INTO public.club_members (club_id, user_id, role, joined_at, status)
    SELECT 
      longsang_club_id,
      u.id,
      'member',
      NOW() - (random() * interval '30 days'),
      'active'
    FROM public.users u 
    WHERE u.id != longsang_user_id 
    LIMIT 3
    ON CONFLICT (club_id, user_id) DO NOTHING;
  END IF;
END $$;