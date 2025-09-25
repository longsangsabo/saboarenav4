#!/usr/bin/env python3
"""
Debug chi tiết authentication context của Flutter app
"""
import os
import json
from supabase import create_client, Client

def test_with_actual_user_auth():
    """Test với user authentication thực tế"""
    print("🔐 Testing với User Authentication...")
    print("=" * 60)
    
    url, anon_key, service_key = load_config()
    supabase = create_client(url, anon_key)
    
    try:
        # Test sign in với user thực
        print("1. Testing sign in...")
        auth_response = supabase.auth.sign_in_with_password({
            "email": "longsang063@gmail.com",  # User từ test results
            "password": "123456"  # Default test password
        })
        
        if auth_response.user:
            print(f"✅ Signed in as: {auth_response.user.email}")
            print(f"   User ID: {auth_response.user.id}")
            
            # Test function với authenticated user
            print("\n2. Testing function với authenticated user...")
            result = supabase.rpc('get_pending_rank_change_requests').execute()
            
            print(f"📊 Function result: {len(result.data)} requests")
            if result.data:
                for req in result.data:
                    print(f"  - {req.get('user_name')}: {req.get('id')}")
            else:
                print("❌ No requests returned with authenticated user")
                
        else:
            print("❌ Sign in failed")
            
    except Exception as e:
        print(f"❌ Auth test error: {e}")
        
        # Test function without auth (như lúc nãy)
        print("\n3. Testing function without auth...")
        try:
            result = supabase.rpc('get_pending_rank_change_requests').execute()
            print(f"📊 No-auth result: {len(result.data)} requests")
        except Exception as e2:
            print(f"❌ No-auth error: {e2}")

def check_user_club_permissions():
    """Kiểm tra permissions chi tiết"""
    print("\n🏆 Checking User Club Permissions...")
    print("=" * 60)
    
    url, anon_key, service_key = load_config()
    supabase = create_client(url, service_key)
    
    # Lấy thông tin users từ rank_requests
    target_users = [
        "8dc68b2e-8c94-47d7-a2d7-a70b218c32a8",  # MinhHồ_8029
        "ca23e628-d2bb-4174-b4b8-d1cc2ff8335f"   # HOÀNG NAM
    ]
    
    for user_id in target_users:
        print(f"\n👤 User: {user_id}")
        
        # User info
        user_info = supabase.table('users').select('display_name, email, role').eq('id', user_id).execute()
        if user_info.data:
            user = user_info.data[0]
            print(f"   Name: {user.get('display_name')}")
            print(f"   Email: {user.get('email')}")
            print(f"   Role: {user.get('role', 'user')}")
        
        # Club memberships
        memberships = supabase.table('club_members').select('club_id, status').eq('user_id', user_id).execute()
        print(f"   Club memberships: {len(memberships.data)}")
        for membership in memberships.data:
            print(f"     - Club: {membership.get('club_id')} (Status: {membership.get('status')})")
        
        # Club ownership
        owned_clubs = supabase.table('clubs').select('id, name').eq('owner_id', user_id).execute()
        print(f"   Owned clubs: {len(owned_clubs.data)}")
        for club in owned_clubs.data:
            print(f"     - {club.get('name')} ({club.get('id')})")

def load_config():
    """Load Supabase config từ env.json"""
    if os.path.exists('env.json'):
        with open('env.json', 'r') as f:
            config = json.load(f)
            return config.get('SUPABASE_URL'), config.get('SUPABASE_ANON_KEY'), config.get('SUPABASE_SERVICE_ROLE_KEY')
    return None, None, None

def main():
    """Main debug function"""
    print("🔍 DEBUG: Authentication & Permissions trong Flutter")
    print("=" * 80)
    
    # Test with user authentication
    test_with_actual_user_auth()
    
    # Check detailed permissions
    check_user_club_permissions()
    
    print("\n" + "=" * 80)
    print("🎯 KẾT LUẬN DEBUG:")
    print("1. Cần kiểm tra user có đăng nhập trong Flutter app không")
    print("2. Cần kiểm tra user có quyền xem club requests không")
    print("3. Function chạy khác nhau với/không auth")

if __name__ == "__main__":
    main()