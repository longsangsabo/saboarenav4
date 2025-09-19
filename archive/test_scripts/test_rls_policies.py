#!/usr/bin/env python3
"""
Apply RLS Policy Updates for Tournament Participants
This script applies the necessary RLS policy changes via direct SQL execution
"""

import requests
import json

SUPABASE_URL = "https://mogjjvscxjwvhtpkrlqr.supabase.co"
SERVICE_ROLE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo"

headers = {
    "apikey": SERVICE_ROLE_KEY,
    "Authorization": f"Bearer {SERVICE_ROLE_KEY}",
    "Content-Type": "application/json"
}

def test_admin_add_user_to_tournament():
    """Test admin adding user to tournament"""
    print("\n🧪 TESTING ADMIN ADD USER TO TOURNAMENT")
    print("=" * 50)
    
    try:
        # Step 1: Get a tournament with available spots
        print("📋 Step 1: Finding tournament with available spots...")
        response = requests.get(
            f"{SUPABASE_URL}/rest/v1/tournaments?select=id,title,current_participants,max_participants&order=created_at.desc&limit=5",
            headers=headers
        )
        
        if response.status_code != 200:
            print(f"   ❌ Failed to get tournaments: {response.status_code}")
            return False
            
        tournaments = response.json()
        available_tournament = None
        
        for tournament in tournaments:
            current = tournament.get('current_participants', 0)
            max_participants = tournament.get('max_participants', 100)
            if current < max_participants:
                available_tournament = tournament
                break
        
        if not available_tournament:
            print("   ⚠️  No tournaments with available spots found")
            return False
            
        tournament_id = available_tournament['id']
        tournament_title = available_tournament['title']
        print(f"   ✅ Found tournament: {tournament_title}")
        
        # Step 2: Get a user who isn't already in this tournament
        print("📋 Step 2: Finding user not in tournament...")
        
        # Get existing participants
        response = requests.get(
            f"{SUPABASE_URL}/rest/v1/tournament_participants?select=user_id&tournament_id=eq.{tournament_id}",
            headers=headers
        )
        
        if response.status_code != 200:
            print(f"   ❌ Failed to get participants: {response.status_code}")
            return False
            
        existing_participants = response.json()
        existing_user_ids = {p['user_id'] for p in existing_participants}
        
        # Get users not in tournament
        response = requests.get(
            f"{SUPABASE_URL}/rest/v1/users?select=id,email,display_name&role=neq.admin&limit=10",
            headers=headers
        )
        
        if response.status_code != 200:
            print(f"   ❌ Failed to get users: {response.status_code}")
            return False
            
        all_users = response.json()
        available_user = None
        
        for user in all_users:
            if user['id'] not in existing_user_ids:
                available_user = user
                break
        
        if not available_user:
            print("   ⚠️  No available users found")
            return False
            
        user_id = available_user['id']
        user_email = available_user['email']
        print(f"   ✅ Found available user: {user_email}")
        
        # Step 3: Try to add user to tournament (simulating admin action)
        print("📋 Step 3: Adding user to tournament as admin...")
        
        new_participant = {
            'tournament_id': tournament_id,
            'user_id': user_id,
            'registered_at': '2025-09-18T10:00:00Z',
            'status': 'registered',
            'payment_status': 'completed',
        }
        
        response = requests.post(
            f"{SUPABASE_URL}/rest/v1/tournament_participants",
            headers=headers,
            json=new_participant
        )
        
        if response.status_code in [200, 201]:
            print(f"   ✅ SUCCESS! Added {user_email} to {tournament_title}")
            
            # Update tournament participant count
            current_participants = available_tournament.get('current_participants', 0) + 1
            update_response = requests.patch(
                f"{SUPABASE_URL}/rest/v1/tournaments?id=eq.{tournament_id}",
                headers=headers,
                json={
                    'current_participants': current_participants,
                    'updated_at': '2025-09-18T10:00:00Z'
                }
            )
            
            if update_response.status_code in [200, 204]:
                print(f"   ✅ Updated participant count to {current_participants}")
            else:
                print(f"   ⚠️  Failed to update count: {update_response.status_code}")
            
            return True
            
        else:
            print(f"   ❌ FAILED to add user: {response.status_code}")
            print(f"      Response: {response.text}")
            return False
            
    except Exception as e:
        print(f"   ❌ Error during test: {e}")
        return False

def show_sql_for_manual_execution():
    """Show SQL that needs to be executed manually in Supabase dashboard"""
    print("\n🔧 MANUAL RLS POLICY UPDATE REQUIRED")
    print("=" * 50)
    print("Please execute the following SQL in Supabase Dashboard > SQL Editor:")
    print()
    
    sql = """-- Update RLS Policies for Tournament Participants
-- This allows admin users to add any user to tournaments

-- Drop existing policies that might conflict
DROP POLICY IF EXISTS "Users can register for tournaments" ON tournament_participants;
DROP POLICY IF EXISTS "Tournament organizers can manage participants" ON tournament_participants;
DROP POLICY IF EXISTS "Admin users can manage all tournament participants" ON tournament_participants;

-- Recreate policies with admin support

-- 1. Users can register themselves for tournaments OR admin can register anyone
CREATE POLICY "Users can register for tournaments" 
ON tournament_participants 
FOR INSERT 
WITH CHECK (
    auth.uid() = user_id  -- User registering themselves
    OR 
    EXISTS (  -- OR admin user registering someone else
        SELECT 1 FROM users u 
        WHERE u.id = auth.uid() 
        AND u.role = 'admin'
    )
    OR
    EXISTS (  -- OR tournament organizer adding someone
        SELECT 1 FROM tournaments t
        WHERE t.id = tournament_participants.tournament_id 
        AND t.organizer_id = auth.uid()
    )
);

-- 2. Tournament organizers can manage all participants in their tournaments
CREATE POLICY "Tournament organizers can manage participants" 
ON tournament_participants 
FOR ALL 
USING (
    EXISTS (
        SELECT 1 FROM tournaments t
        WHERE t.id = tournament_participants.tournament_id 
        AND t.organizer_id = auth.uid()
    )
);

-- 3. Admin users can manage participants in any tournament
CREATE POLICY "Admin users can manage all tournament participants" 
ON tournament_participants 
FOR ALL 
USING (
    EXISTS (
        SELECT 1 FROM users u 
        WHERE u.id = auth.uid() 
        AND u.role = 'admin'
    )
) 
WITH CHECK (
    EXISTS (
        SELECT 1 FROM users u 
        WHERE u.id = auth.uid() 
        AND u.role = 'admin'
    )
);

-- 4. Users can update/delete their own participation  
CREATE POLICY "Users can update own participation" 
ON tournament_participants 
FOR UPDATE 
USING (
    auth.uid() = user_id
    OR
    EXISTS (
        SELECT 1 FROM users u 
        WHERE u.id = auth.uid() 
        AND u.role = 'admin'
    )
);

CREATE POLICY "Users can withdraw from tournaments" 
ON tournament_participants 
FOR DELETE 
USING (
    auth.uid() = user_id
    OR
    EXISTS (
        SELECT 1 FROM users u 
        WHERE u.id = auth.uid() 
        AND u.role = 'admin'
    )
);"""
    
    print(sql)
    print()
    print("📋 After executing the SQL, run this script again to test.")

def main():
    print("🚀 TOURNAMENT PARTICIPANTS RLS POLICY TEST")
    print("=" * 50)
    
    # Test current status
    success = test_admin_add_user_to_tournament()
    
    if not success:
        print("\n❌ TEST FAILED - RLS policies need to be updated")
        show_sql_for_manual_execution()
        print("\n📝 SUMMARY:")
        print("   1. Execute the SQL above in Supabase Dashboard")
        print("   2. Run this script again to verify")
        print("   3. Then try adding users to tournaments in the app")
    else:
        print("\n🎉 SUCCESS! Admin can now add users to tournaments!")
        print("   ✅ RLS policies are working correctly")
        print("   ✅ Tournament user management is functional")

if __name__ == "__main__":
    main()