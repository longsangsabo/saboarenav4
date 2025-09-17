-- Fix club_members RLS policy to allow club members to see other members

-- Drop existing restrictive policy
DROP POLICY IF EXISTS "users_manage_own_club_memberships" ON public.club_members;

-- Create new policy that allows:
-- 1. Users to see members of clubs they belong to
-- 2. Users to manage their own membership
CREATE POLICY "club_members_access"
ON public.club_members
FOR ALL
TO authenticated
USING (
  -- User can see members of clubs they belong to
  club_id IN (
    SELECT club_id 
    FROM public.club_members 
    WHERE user_id = auth.uid()
  )
  OR
  -- User can manage their own membership
  user_id = auth.uid()
  OR
  -- Club owners can see all members of their clubs
  club_id IN (
    SELECT id 
    FROM public.clubs 
    WHERE owner_id = auth.uid()
  )
)
WITH CHECK (
  -- Only allow users to insert/update their own membership or club owners
  user_id = auth.uid()
  OR
  club_id IN (
    SELECT id 
    FROM public.clubs 
    WHERE owner_id = auth.uid()
  )
);

-- Also create a read-only policy for public club information
CREATE POLICY "public_club_members_read"
ON public.club_members
FOR SELECT
TO authenticated
USING (
  -- Anyone can see basic member info for public clubs
  club_id IN (
    SELECT id 
    FROM public.clubs 
    WHERE is_public = true 
    AND approval_status = 'approved'
    AND is_active = true
  )
);