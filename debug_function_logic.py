#!/usr/bin/env python3
"""
Debug logic function get_pending_rank_change_requests
"""
import os
import json
from supabase import create_client, Client

def debug_function_logic():
    """Debug step by step function logic"""
    print("🔍 DEBUG Function Logic Step by Step...")
    print("=" * 60)
    
    url, anon_key, service_key = load_config()
    
    # Test với authenticated user
    supabase_auth = create_client(url, anon_key)
    
    try:
        # Sign in
        auth_response = supabase_auth.auth.sign_in_with_password({
            "email": "longsang063@gmail.com",
            "password": "123456"
        })
        
        user_id = auth_response.user.id
        print(f"✅ Authenticated as: {user_id}")
        
        # Debug function bằng cách gọi manual logic
        supabase_service = create_client(url, service_key)
        
        print("\n1. Checking user info...")
        user_info = supabase_service.table('users').select('*').eq('id', user_id).execute()
        if user_info.data:
            user = user_info.data[0]
            print(f"   Role: {user.get('role', 'user')}")
            is_admin = user.get('role') == 'admin'
            print(f"   Is Admin: {is_admin}")
        
        print("\n2. Finding user's club...")
        # Check club membership
        memberships = supabase_service.table('club_members').select('club_id, status').eq('user_id', user_id).eq('status', 'active').execute()
        print(f"   Active memberships: {len(memberships.data)}")
        
        user_club_id = None
        if memberships.data:
            user_club_id = memberships.data[0]['club_id']
            print(f"   First club ID: {user_club_id}")
        
        # Check club ownership
        owned_clubs = supabase_service.table('clubs').select('id').eq('owner_id', user_id).execute()
        print(f"   Owned clubs: {len(owned_clubs.data)}")
        if owned_clubs.data:
            owned_club_id = owned_clubs.data[0]['id']
            print(f"   Owned club ID: {owned_club_id}")
            if not user_club_id:
                user_club_id = owned_club_id
        
        print(f"\n3. Final user_club_id: {user_club_id}")
        
        print("\n4. Checking rank_requests with filters...")
        if user_club_id:
            # Mimic function logic
            requests = supabase_service.table('rank_requests').select('''
                *,
                users!rank_requests_user_id_fkey (
                    display_name,
                    full_name,
                    email,
                    avatar_url
                )
            ''').eq('status', 'pending').eq('club_id', user_club_id).execute()
            
            print(f"   Found {len(requests.data)} requests for club {user_club_id}")
            for req in requests.data:
                print(f"     - Request ID: {req['id']}")
                print(f"       User: {req['users']['display_name']}")
                print(f"       Club: {req['club_id']}")
                print(f"       Status: {req['status']}")
        else:
            print("   ❌ No user_club_id found!")
            
        print("\n5. Testing function call với authenticated user...")
        try:
            result = supabase_auth.rpc('get_pending_rank_change_requests').execute()
            print(f"   Function returned: {len(result.data)} requests")
            if result.data:
                for req in result.data:
                    print(f"     - {req.get('user_name')}: {req.get('id')}")
        except Exception as e:
            print(f"   Function error: {e}")
            
    except Exception as e:
        print(f"❌ Debug error: {e}")

def load_config():
    """Load Supabase config từ env.json"""
    if os.path.exists('env.json'):
        with open('env.json', 'r') as f:
            config = json.load(f)
            return config.get('SUPABASE_URL'), config.get('SUPABASE_ANON_KEY'), config.get('SUPABASE_SERVICE_ROLE_KEY')
    return None, None, None

def main():
    debug_function_logic()

if __name__ == "__main__":
    main()