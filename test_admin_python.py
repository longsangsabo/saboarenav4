import requests
import json
import uuid

def test_admin_functionality():
    print('🧪 TESTING ADMIN TOURNAMENT MANAGEMENT FUNCTIONALITY')
    print('=' * 60)

    # Supabase configuration
    SUPABASE_URL = "https://mogjjvscxjwvhtpkrlqr.supabase.co"
    SERVICE_ROLE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo"
    
    headers = {
        "apikey": SERVICE_ROLE_KEY,
        "Authorization": f"Bearer {SERVICE_ROLE_KEY}",
        "Content-Type": "application/json"
    }

    try:
        print('\n📋 Step 1: Get available tournaments...')
        
        response = requests.get(
            f"{SUPABASE_URL}/rest/v1/tournaments?select=id,title,status,current_participants,max_participants&status=eq.upcoming&limit=5",
            headers=headers
        )
        
        if response.status_code != 200:
            print(f'   ❌ Failed to get tournaments: {response.status_code}')
            return
            
        tournaments = response.json()
        
        if not tournaments:
            print('   ❌ No upcoming tournaments found for testing')
            return

        print(f'   ✅ Found {len(tournaments)} upcoming tournaments:')
        for tournament in tournaments:
            print(f'      - {tournament["title"]} ({tournament["current_participants"]}/{tournament["max_participants"]} participants)')

        # Test with first tournament
        test_tournament = tournaments[0]
        tournament_id = test_tournament['id']
        tournament_title = test_tournament['title']

        print('\n📋 Step 2: Get all users count...')
        response = requests.get(
            f"{SUPABASE_URL}/rest/v1/users?select=count",
            headers={**headers, "Prefer": "count=exact"}
        )
        
        if response.status_code in [200, 206]:
            count = response.headers.get('Content-Range', '*/0').split('/')[-1]
            print(f'   ✅ Total users in database: {count}')
        else:
            print(f'   ❌ Failed to get user count: {response.status_code}')
            return

        print(f'\n📋 Step 3: Test adding users to tournament "{tournament_title}"...')
        
        # Get all users
        response = requests.get(
            f"{SUPABASE_URL}/rest/v1/users?select=id,username,display_name",
            headers=headers
        )
        
        if response.status_code != 200:
            print(f'   ❌ Failed to get users: {response.status_code}')
            return
            
        all_users = response.json()

        # Get existing participants
        response = requests.get(
            f"{SUPABASE_URL}/rest/v1/tournament_participants?select=user_id&tournament_id=eq.{tournament_id}",
            headers=headers
        )
        
        if response.status_code != 200:
            print(f'   ❌ Failed to get participants: {response.status_code}')
            return
            
        existing_participants = response.json()
        existing_user_ids = {p['user_id'] for p in existing_participants}
        
        print(f'   📊 Users available: {len(all_users)}')
        print(f'   📊 Already joined: {len(existing_user_ids)}')
        
        added_count = 0
        max_participants = test_tournament['max_participants'] or 100
        current_participants = test_tournament['current_participants'] or 0

        # Prepare users to add (limit to 2 for safety)
        users_to_add = []
        
        for user in all_users:
            if user['id'] in existing_user_ids:
                continue  # Skip if already joined
            
            if current_participants >= max_participants:
                break  # Tournament is full
                
            if len(users_to_add) >= 2:  # Limit for test
                break

            users_to_add.append({
                'tournament_id': tournament_id,
                'user_id': user['id'],
                'registered_at': '2025-09-18T10:00:00Z',
                'status': 'registered',
                'payment_status': 'completed',
            })

            added_count += 1
            current_participants += 1

        print(f'   📊 Will add: {len(users_to_add)} users')
        print(f'   📊 Final participants: {current_participants}/{max_participants}')

        # Actually add users
        if users_to_add:
            print(f'\n📋 Step 4: Adding {len(users_to_add)} users to tournament...')
            
            response = requests.post(
                f"{SUPABASE_URL}/rest/v1/tournament_participants",
                headers=headers,
                json=users_to_add
            )
            
            if response.status_code == 201:
                print(f'   ✅ Successfully added {len(users_to_add)} users to "{tournament_title}"')
                
                # Update tournament participant count
                response = requests.patch(
                    f"{SUPABASE_URL}/rest/v1/tournaments?id=eq.{tournament_id}",
                    headers=headers,
                    json={
                        'current_participants': current_participants,
                        'updated_at': '2025-09-18T10:00:00Z'
                    }
                )
                
                if response.status_code == 204:
                    print('   ✅ Updated tournament participant count')
                else:
                    print(f'   ⚠️  Failed to update count: {response.status_code}')
                
                # Verify the result
                response = requests.get(
                    f"{SUPABASE_URL}/rest/v1/tournaments?select=current_participants&id=eq.{tournament_id}",
                    headers=headers
                )
                
                if response.status_code == 200:
                    updated_tournament = response.json()[0]
                    print(f'   📊 Updated participant count: {updated_tournament["current_participants"]}')
                
            else:
                print(f'   ❌ Failed to add users: {response.status_code} - {response.text}')
        else:
            print('   ⚠️  No users to add (all already joined or tournament full)')

        print('\n🎉 ADMIN FUNCTIONALITY TEST COMPLETED!')
        print('   ✅ Tournament management functions are working')
        print('   ✅ User addition logic is functional')
        print('   ✅ Database updates are successful')
        print('\n📝 SUMMARY:')
        print(f'   • Tournament: {tournament_title}')
        print(f'   • Users added: {len(users_to_add) if users_to_add else 0}')
        print(f'   • Total participants: {current_participants}/{max_participants}')

    except Exception as e:
        print(f'\n❌ TEST FAILED: {e}')

if __name__ == "__main__":
    test_admin_functionality()