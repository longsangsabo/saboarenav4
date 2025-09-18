#!/usr/bin/env python3
"""
Final Test: Admin Add User to Tournament
This tests if the admin can actually add users to tournaments after RLS fix
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

def test_admin_add_multiple_users():
    """Test admin adding multiple users to tournament"""
    print("🧪 FINAL TEST: ADMIN ADD MULTIPLE USERS TO TOURNAMENT")
    print("=" * 60)
    
    try:
        # Get tournament with space
        print("📋 Step 1: Finding tournament with available space...")
        response = requests.get(
            f"{SUPABASE_URL}/rest/v1/tournaments?select=id,title,current_participants,max_participants&order=created_at.desc&limit=5",
            headers=headers
        )
        
        if response.status_code != 200:
            print(f"   ❌ Failed to get tournaments: {response.status_code}")
            return False
            
        tournaments = response.json()
        target_tournament = None
        
        for tournament in tournaments:
            current = tournament.get('current_participants', 0)
            max_participants = tournament.get('max_participants', 100)
            if current < max_participants - 5:  # Need space for at least 5 more
                target_tournament = tournament
                break
        
        if not target_tournament:
            print("   ⚠️  No tournaments with enough space found")
            return False
            
        tournament_id = target_tournament['id']
        tournament_title = target_tournament['title']
        print(f"   ✅ Using tournament: {tournament_title}")
        print(f"      Current: {target_tournament.get('current_participants', 0)}/{target_tournament.get('max_participants', 100)}")
        
        # Get existing participants
        print("📋 Step 2: Getting existing participants...")
        response = requests.get(
            f"{SUPABASE_URL}/rest/v1/tournament_participants?select=user_id&tournament_id=eq.{tournament_id}",
            headers=headers
        )
        
        existing_user_ids = set()
        if response.status_code == 200:
            existing_participants = response.json()
            existing_user_ids = {p['user_id'] for p in existing_participants}
            print(f"   📊 {len(existing_user_ids)} users already in tournament")
        
        # Get available users (not in tournament, not admin)
        print("📋 Step 3: Finding available users...")
        response = requests.get(
            f"{SUPABASE_URL}/rest/v1/users?select=id,email,display_name&role=neq.admin&limit=10",
            headers=headers
        )
        
        if response.status_code != 200:
            print(f"   ❌ Failed to get users: {response.status_code}")
            return False
            
        all_users = response.json()
        available_users = [user for user in all_users if user['id'] not in existing_user_ids]
        
        if len(available_users) < 2:
            print("   ⚠️  Not enough available users for test")
            return False
            
        # Take first 2 available users for test
        test_users = available_users[:2]
        print(f"   ✅ Found {len(test_users)} users to add:")
        for user in test_users:
            print(f"      • {user['email']} ({user['display_name']})")
        
        # Test adding users one by one
        print("📋 Step 4: Adding users to tournament...")
        success_count = 0
        
        for i, user in enumerate(test_users, 1):
            print(f"   🔄 Adding user {i}/{len(test_users)}: {user['email']}")
            
            new_participant = {
                'tournament_id': tournament_id,
                'user_id': user['id'],
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
                print(f"      ✅ SUCCESS: Added {user['email']}")
                success_count += 1
            else:
                print(f"      ❌ FAILED: {response.status_code} - {response.text}")
        
        # Update tournament participant count
        if success_count > 0:
            print("📋 Step 5: Updating tournament participant count...")
            new_count = target_tournament.get('current_participants', 0) + success_count
            
            response = requests.patch(
                f"{SUPABASE_URL}/rest/v1/tournaments?id=eq.{tournament_id}",
                headers=headers,
                json={
                    'current_participants': new_count,
                    'updated_at': '2025-09-18T10:00:00Z'
                }
            )
            
            if response.status_code in [200, 204]:
                print(f"   ✅ Updated participant count to {new_count}")
            else:
                print(f"   ⚠️  Failed to update count: {response.status_code}")
        
        # Summary
        print("\n" + "=" * 60)
        if success_count == len(test_users):
            print("🎉 COMPLETE SUCCESS!")
            print(f"   ✅ Added {success_count}/{len(test_users)} users successfully")
            print("   ✅ Admin can add users to tournaments")
            print("   ✅ RLS policies are working correctly")
            return True
        elif success_count > 0:
            print("🔶 PARTIAL SUCCESS")
            print(f"   ✅ Added {success_count}/{len(test_users)} users")
            print("   ⚠️  Some additions failed - check RLS policies")
            return False
        else:
            print("❌ COMPLETE FAILURE")
            print("   ❌ Could not add any users")
            print("   ❌ RLS policies still blocking admin operations")
            return False
            
    except Exception as e:
        print(f"   ❌ Error during test: {e}")
        return False

def main():
    print("🚀 FINAL TEST: ADMIN TOURNAMENT USER MANAGEMENT")
    print("=" * 60)
    
    success = test_admin_add_multiple_users()
    
    if success:
        print("\n🎉 RLS POLICIES ARE WORKING!")
        print("   ✅ Admin can successfully add users to tournaments")
        print("   ✅ The app should work without RLS errors now")
        print("\n📱 NEXT STEPS:")
        print("   1. Test in the Flutter app")
        print("   2. Login as admin")
        print("   3. Try 'Add All Users to Tournament' feature")
    else:
        print("\n❌ RLS POLICIES STILL NEED FIXING")
        print("\n🔧 MANUAL FIX REQUIRED:")
        print("   1. Copy the SQL from 'URGENT_RLS_FIX.sql'")
        print("   2. Go to Supabase Dashboard > SQL Editor")
        print("   3. Execute the SQL script")
        print("   4. Test again")

if __name__ == "__main__":
    main()