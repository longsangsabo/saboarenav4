import requests
import json
import uuid

# Supabase configuration
SUPABASE_URL = "https://mogjjvscxjwvhtpkrlqr.supabase.co"
SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ"

def create_simple_qr_user():
    """Create user with simple bio containing just the QR code"""
    
    headers = {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': f'Bearer {SUPABASE_ANON_KEY}',
        'Content-Type': 'application/json',
        'Prefer': 'return=representation'
    }
    
    print("🚀 SABO Arena - Simple QR User")
    print("=" * 30)
    
    # Create user with QR code as username/bio
    test_user = {
        "id": "qr-simple-test-123",
        "email": "qrsimple@saboarena.com",
        "full_name": "QR Simple Test",
        "username": "SABO123456",  # Use QR code as username
        "role": "player",
        "skill_level": "intermediate",
        "rank": "Intermediate",
        "elo_rating": 1500,
        "spa_points": 200,
        "is_verified": True,
        "is_active": True,
        "bio": "SABO123456"  # Also store as bio
    }
    
    print(f"👤 Creating user with username: {test_user['username']}")
    
    try:
        response = requests.post(
            f"{SUPABASE_URL}/rest/v1/users",
            headers=headers,
            json=test_user
        )
        
        if response.status_code in [200, 201]:
            print("✅ QR user created successfully!")
            return True
        elif response.status_code == 409:
            print("⚠️ User already exists")
            return True
        else:
            print(f"❌ Failed: {response.status_code} - {response.text}")
            return False
            
    except Exception as e:
        print(f"💥 Exception: {e}")
        return False

def test_qr_by_username():
    """Test QR lookup by username"""
    
    headers = {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': f'Bearer {SUPABASE_ANON_KEY}',
        'Content-Type': 'application/json'
    }
    
    print("\n🔍 Testing QR by Username...")
    print("=" * 28)
    
    try:
        response = requests.get(
            f"{SUPABASE_URL}/rest/v1/users?username=eq.SABO123456&select=id,full_name,username,skill_level,elo_rating",
            headers=headers
        )
        
        if response.status_code == 200:
            data = response.json()
            if data:
                user = data[0]
                print("🎉 QR LOOKUP SUCCESS!")
                print(f"   👤 User: {user.get('full_name', 'N/A')}")
                print(f"   🔤 Username: {user.get('username', 'N/A')}")
                print(f"   🏆 ELO: {user.get('elo_rating', 'N/A')}")
                print(f"   🏆 Skill: {user.get('skill_level', 'N/A')}")
                return user
            else:
                print("❌ User not found")
                return None
        else:
            print(f"❌ API Error: {response.status_code}")
            return None
            
    except Exception as e:
        print(f"💥 Exception: {e}")
        return None

def test_qr_by_bio():
    """Test QR lookup by bio (exact match)"""
    
    headers = {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': f'Bearer {SUPABASE_ANON_KEY}',
        'Content-Type': 'application/json'
    }
    
    print("\n🔍 Testing QR by Bio...")
    print("=" * 22)
    
    try:
        response = requests.get(
            f"{SUPABASE_URL}/rest/v1/users?bio=eq.SABO123456&select=id,full_name,bio,skill_level",
            headers=headers
        )
        
        if response.status_code == 200:
            data = response.json()
            if data:
                user = data[0]
                print("✅ Bio lookup success!")
                print(f"   👤 User: {user.get('full_name', 'N/A')}")
                print(f"   📝 Bio: {user.get('bio', 'N/A')}")
                return user
            else:
                print("❌ User not found via bio")
                return None
        else:
            print(f"❌ API Error: {response.status_code}")
            return None
            
    except Exception as e:
        print(f"💥 Exception: {e}")
        return None

def create_multiple_simple_qr_users():
    """Create multiple users with QR codes as usernames"""
    
    headers = {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': f'Bearer {SUPABASE_ANON_KEY}',
        'Content-Type': 'application/json',
        'Prefer': 'return=representation'
    }
    
    print("\n🧪 Creating Multiple QR Users...")
    print("=" * 32)
    
    qr_users = [
        {
            "id": "qr-user-111111",
            "email": "qr111@saboarena.com",
            "full_name": "Nguyễn Văn A",
            "username": "SABO111111",
            "role": "player",
            "skill_level": "beginner",
            "rank": "Beginner", 
            "elo_rating": 1200,
            "spa_points": 100,
            "is_verified": True,
            "is_active": True,
            "bio": "SABO111111"
        },
        {
            "id": "qr-user-222222",
            "email": "qr222@saboarena.com", 
            "full_name": "Trần Thị B",
            "username": "SABO222222",
            "role": "player",
            "skill_level": "advanced",
            "rank": "Advanced",
            "elo_rating": 1800,
            "spa_points": 500,
            "is_verified": True,
            "is_active": True,
            "bio": "SABO222222"
        }
    ]
    
    created = 0
    
    for user in qr_users:
        print(f"\n👤 Creating: {user['full_name']} ({user['username']})")
        
        try:
            response = requests.post(
                f"{SUPABASE_URL}/rest/v1/users",
                headers=headers,
                json=user
            )
            
            if response.status_code in [200, 201]:
                print(f"   ✅ Created!")
                created += 1
            elif response.status_code == 409:
                print(f"   ⚠️ Already exists")
                created += 1
            else:
                print(f"   ❌ Failed: {response.status_code}")
                
        except Exception as e:
            print(f"   💥 Exception: {e}")
    
    return created

def test_all_qr_usernames():
    """Test all QR codes by username lookup"""
    
    headers = {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': f'Bearer {SUPABASE_ANON_KEY}',
        'Content-Type': 'application/json'
    }
    
    print("\n🎯 Testing All QR Codes (Username)...")
    print("=" * 35)
    
    test_codes = ["SABO123456", "SABO111111", "SABO222222"]
    working_codes = []
    
    for code in test_codes:
        print(f"\n🔍 Testing: {code}")
        
        try:
            response = requests.get(
                f"{SUPABASE_URL}/rest/v1/users?username=eq.{code}&select=full_name,username,skill_level,elo_rating",
                headers=headers
            )
            
            if response.status_code == 200:
                data = response.json()
                if data:
                    user = data[0]
                    print(f"   ✅ {user.get('full_name', 'N/A')} - ELO: {user.get('elo_rating', 'N/A')}")
                    working_codes.append(code)
                else:
                    print(f"   ❌ Not found")
            else:
                print(f"   ⚠️ API Error: {response.status_code}")
                
        except Exception as e:
            print(f"   💥 Error: {e}")
    
    return working_codes

if __name__ == "__main__":
    print("🚀 SABO Arena - Simple QR System")
    print("Using username field for QR codes")
    print("=" * 40)
    
    # Create first QR user
    success = create_simple_qr_user()
    
    if success:
        # Test username lookup
        user1 = test_qr_by_username()
        
        # Test bio lookup
        user2 = test_qr_by_bio()
    
    # Create multiple QR users
    created_count = create_multiple_simple_qr_users()
    
    # Test all QR codes
    working_codes = test_all_qr_usernames()
    
    print(f"\n" + "=" * 40)
    print("🎯 Simple QR System Complete!")
    print(f"✅ Created: {created_count + 1}/3 users")
    print(f"✅ Working QR Codes: {len(working_codes)}")
    
    if working_codes:
        print(f"\n🔍 Ready for Flutter testing:")
        for code in working_codes:
            print(f"   • {code}")
        
        print(f"\n📱 QR codes work via username lookup!")
        print(f"🚀 Ready to launch Chrome app!")
    else:
        print(f"\n❌ No working QR codes")
    
    print("=" * 40)