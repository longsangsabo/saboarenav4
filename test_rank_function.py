#!/usr/bin/env python3
"""
Test script để kết nối Supabase và test function get_pending_rank_change_requests()
"""
import os
import json
from supabase import create_client, Client

def load_config():
    """Load Supabase config từ env.json"""
    if os.path.exists('env.json'):
        with open('env.json', 'r') as f:
            config = json.load(f)
            return config.get('SUPABASE_URL'), config.get('SUPABASE_SERVICE_ROLE_KEY')
    return None, None

def test_connection():
    """Test kết nối với Supabase"""
    print("🔌 Đang kết nối với Supabase...")
    
    # Load config
    url, key = load_config()
    if not url or not key:
        print("❌ Không tìm thấy config trong env.json!")
        return None
    
    try:
        # Tạo client
        supabase = create_client(url, key)
        print("✅ Kết nối thành công!")
        print(f"📡 URL: {url}")
        print(f"🔑 Key: {key[:20]}...")
        return supabase
    except Exception as e:
        print(f"❌ Lỗi kết nối: {e}")
        return None

def test_rank_function(supabase):
    """Test function get_pending_rank_change_requests()"""
    print("\n🧪 Testing function get_pending_rank_change_requests()...")
    print("=" * 60)
    
    try:
        # Gọi function
        result = supabase.rpc('get_pending_rank_change_requests').execute()
        
        print(f"✅ Function thực thi thành công!")
        print(f"📊 Số lượng requests: {len(result.data)}")
        
        if result.data:
            print("\n📋 Chi tiết các requests:")
            for i, req in enumerate(result.data, 1):
                print(f"\n{i}. Request ID: {req.get('id', 'N/A')}")
                print(f"   👤 User: {req.get('user_name', 'Unknown')}")
                print(f"   📧 Email: {req.get('user_email', 'N/A')}")
                print(f"   🏆 Club ID: {req.get('club_id', 'N/A')}")
                print(f"   📅 Requested: {req.get('requested_at', 'N/A')}")
                print(f"   📝 Status: {req.get('status', 'N/A')}")
        else:
            print("⚠️ Không có request nào được tìm thấy")
            
    except Exception as e:
        print(f"❌ Lỗi khi gọi function: {e}")
        print(f"📋 Chi tiết lỗi: {str(e)}")

def check_rank_requests_table(supabase):
    """Kiểm tra dữ liệu trong bảng rank_requests"""
    print("\n🔍 Kiểm tra bảng rank_requests...")
    print("=" * 60)
    
    try:
        # Query trực tiếp bảng rank_requests
        result = supabase.table('rank_requests').select('*').execute()
        
        print(f"📊 Tổng số records trong rank_requests: {len(result.data)}")
        
        if result.data:
            print("\n📋 Dữ liệu trong bảng:")
            for i, req in enumerate(result.data, 1):
                print(f"\n{i}. ID: {req.get('id', 'N/A')}")
                print(f"   User ID: {req.get('user_id', 'N/A')}")
                print(f"   Club ID: {req.get('club_id', 'N/A')}")
                print(f"   Status: {req.get('status', 'N/A')}")
                print(f"   Requested At: {req.get('requested_at', 'N/A')}")
        else:
            print("⚠️ Bảng rank_requests trống!")
            
    except Exception as e:
        print(f"❌ Lỗi khi query bảng: {e}")

def main():
    """Main function"""
    print("🎱 SABO Arena - Test Rank Function")
    print("=" * 60)
    
    # Test connection
    supabase = test_connection()
    if not supabase:
        return
    
    # Test bảng rank_requests trực tiếp
    check_rank_requests_table(supabase)
    
    # Test function
    test_rank_function(supabase)
    
    print("\n" + "=" * 60)
    print("✅ Test hoàn thành!")

if __name__ == "__main__":
    main()