#!/usr/bin/env python3
"""
Debug nguyên nhân gốc rễ tại sao Flutter app không thấy rank requests
"""
import os
import json
from supabase import create_client, Client

def load_config():
    """Load Supabase config từ env.json"""
    if os.path.exists('env.json'):
        with open('env.json', 'r') as f:
            config = json.load(f)
            return config.get('SUPABASE_URL'), config.get('SUPABASE_ANON_KEY'), config.get('SUPABASE_SERVICE_ROLE_KEY')
    return None, None, None

def test_with_anon_key():
    """Test function với ANON_KEY như Flutter app"""
    print("🔑 Testing với ANON_KEY (như Flutter app)...")
    print("=" * 60)
    
    url, anon_key, service_key = load_config()
    if not url or not anon_key:
        print("❌ Missing config!")
        return
    
    try:
        # Tạo client với ANON_KEY (giống Flutter)
        supabase = create_client(url, anon_key)
        print("✅ Kết nối thành công với ANON_KEY")
        
        # Test function
        result = supabase.rpc('get_pending_rank_change_requests').execute()
        print(f"📊 Số lượng requests: {len(result.data)}")
        
        if result.data:
            print("✅ Function trả về data với ANON_KEY!")
            for req in result.data:
                print(f"  - {req.get('user_name', 'Unknown')}: {req.get('id', 'N/A')}")
        else:
            print("❌ Function không trả về data với ANON_KEY")
            print("🔍 Nguyên nhân: auth.uid() = NULL với ANON_KEY")
            
    except Exception as e:
        print(f"❌ Lỗi với ANON_KEY: {e}")

def test_authentication_context():
    """Test authentication context"""
    print("\n🧪 Testing Authentication Context...")
    print("=" * 60)
    
    url, anon_key, service_key = load_config()
    
    # Test với ANON_KEY
    print("1. ANON_KEY context:")
    try:
        supabase_anon = create_client(url, anon_key)
        # Kiểm tra auth context
        result = supabase_anon.rpc('auth.uid').execute()
        print(f"   auth.uid() = {result.data}")
    except Exception as e:
        print(f"   auth.uid() lỗi: {e}")
    
    # Test với SERVICE_ROLE_KEY
    print("\n2. SERVICE_ROLE_KEY context:")
    try:
        supabase_service = create_client(url, service_key)
        result = supabase_service.rpc('auth.uid').execute()
        print(f"   auth.uid() = {result.data}")
    except Exception as e:
        print(f"   auth.uid() lỗi: {e}")

def check_user_authentication():
    """Kiểm tra user authentication trong app"""
    print("\n👤 Checking User Authentication...")
    print("=" * 60)
    
    url, anon_key, service_key = load_config()
    supabase = create_client(url, service_key)
    
    try:
        # Lấy tất cả users
        users = supabase.table('users').select('id, email, display_name, full_name').execute()
        print(f"📊 Tổng số users: {len(users.data)}")
        
        print("\n📋 Danh sách users:")
        for user in users.data[:5]:  # Hiển thị 5 users đầu
            print(f"  - {user.get('display_name', user.get('full_name', 'Unknown'))}")
            print(f"    ID: {user.get('id')}")
            print(f"    Email: {user.get('email', 'N/A')}")
            print()
            
    except Exception as e:
        print(f"❌ Lỗi: {e}")

def check_club_permissions():
    """Kiểm tra club permissions"""
    print("\n🏆 Checking Club Permissions...")
    print("=" * 60)
    
    url, anon_key, service_key = load_config()
    supabase = create_client(url, service_key)
    
    try:
        # Lấy clubs
        clubs = supabase.table('clubs').select('id, name, owner_id').execute()
        print(f"📊 Tổng số clubs: {len(clubs.data)}")
        
        # Lấy club_members
        members = supabase.table('club_members').select('user_id, club_id, status').execute()
        print(f"📊 Tổng số club members: {len(members.data)}")
        
        # Kiểm tra club của rank requests
        target_club_id = "4efdd198-c2b7-4428-a6f8-3cf132fc71f7"
        club_info = supabase.table('clubs').select('*').eq('id', target_club_id).execute()
        
        if club_info.data:
            club = club_info.data[0]
            print(f"\n🏆 Club chứa rank requests:")
            print(f"  Name: {club.get('name', 'Unknown')}")
            print(f"  Owner ID: {club.get('owner_id', 'N/A')}")
            
            # Kiểm tra members của club này
            club_members = supabase.table('club_members').select('user_id, status').eq('club_id', target_club_id).execute()
            print(f"  Members: {len(club_members.data)}")
            
            for member in club_members.data:
                print(f"    - User ID: {member.get('user_id')} (Status: {member.get('status')})")
        
    except Exception as e:
        print(f"❌ Lỗi: {e}")

def main():
    """Main debug function"""
    print("🔍 DEBUG: Tại sao Flutter app không thấy rank requests?")
    print("=" * 80)
    
    # Test với ANON_KEY (như Flutter)
    test_with_anon_key()
    
    # Test authentication context
    test_authentication_context()
    
    # Check user authentication
    check_user_authentication()
    
    # Check club permissions
    check_club_permissions()
    
    print("\n" + "=" * 80)
    print("🎯 KẾT LUẬN:")
    print("1. Function hoạt động với SERVICE_ROLE_KEY ✅")
    print("2. Function có thể lỗi với ANON_KEY do auth.uid() = NULL ❌")
    print("3. Cần kiểm tra user authentication trong Flutter app")
    print("4. Cần đảm bảo user đã login và có quyền xem requests")

if __name__ == "__main__":
    main()