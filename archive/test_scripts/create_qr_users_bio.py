import requests
import json
import uuid

# Supabase configuration
SUPABASE_URL = "https://mogjjvscxjwvhtpkrlqr.supabase.co"
SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ"

def create_qr_test_user():
    """Create a new user with QR data to test the system without schema changes"""
    
    headers = {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': f'Bearer {SUPABASE_ANON_KEY}',
        'Content-Type': 'application/json',
        'Prefer': 'return=representation'
    }
    
    print("🚀 SABO Arena - QR Test User Creation")
    print("Creating user with existing schema")
    print("=" * 40)
    
    # Create user with all existing columns
    test_user = {
        "id": str(uuid.uuid4()),
        "email": "qrtest@saboarena.com",
        "full_name": "QR Test User",
        "username": "qr_test_001",
        "role": "player",
        "skill_level": "intermediate",
        "rank": "Intermediate",
        "elo_rating": 1500,
        "spa_points": 200,
        "is_verified": True,
        "is_active": True,
        "bio": "QR:SABO123456"  # Store QR code in bio field temporarily
    }
    
    print(f"👤 Creating user: {test_user['full_name']}")
    print(f"🔢 QR Code stored in bio: SABO123456")
    
    try:
        response = requests.post(
            f"{SUPABASE_URL}/rest/v1/users",
            headers=headers,
            json=test_user
        )
        
        if response.status_code in [200, 201]:
            print("✅ QR test user created successfully!")
            created_user = response.json()
            if created_user:
                user_data = created_user[0] if isinstance(created_user, list) else created_user
                print(f"   ID: {user_data.get('id', 'N/A')}")
                print(f"   Email: {user_data.get('email', 'N/A')}")
                return user_data
        elif response.status_code == 409:
            print("⚠️ User already exists, that's OK!")
            return {"status": "exists"}
        else:
            print(f"❌ Failed to create user: {response.status_code}")
            print(f"   Error: {response.text}")
            return None
            
    except Exception as e:
        print(f"💥 Exception: {e}")
        return None

def test_qr_lookup_bio():
    """Test QR lookup using bio field"""
    
    headers = {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': f'Bearer {SUPABASE_ANON_KEY}',
        'Content-Type': 'application/json'
    }
    
    print("\n🔍 Testing QR Lookup via Bio Field...")
    print("=" * 35)
    
    try:
        # Search for user with QR code in bio
        response = requests.get(
            f"{SUPABASE_URL}/rest/v1/users?bio=cs.QR:SABO123456&select=id,full_name,email,bio,skill_level,elo_rating",
            headers=headers
        )
        
        if response.status_code == 200:
            data = response.json()
            if data:
                user = data[0]
                print("🎉 QR LOOKUP SUCCESS!")
                print(f"   👤 User: {user.get('full_name', 'N/A')}")
                print(f"   📧 Email: {user.get('email', 'N/A')}")
                print(f"   🏆 ELO: {user.get('elo_rating', 'N/A')}")
                print(f"   🏆 Skill: {user.get('skill_level', 'N/A')}")
                print(f"   📝 Bio: {user.get('bio', 'N/A')}")
                return user
            else:
                print("❌ No user found with QR code in bio")
                return None
        else:
            print(f"❌ API Error: {response.status_code}")
            print(f"   Details: {response.text}")
            return None
            
    except Exception as e:
        print(f"💥 Exception: {e}")
        return None

def test_qr_lookup_contains():
    """Test QR lookup using contains search"""
    
    headers = {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': f'Bearer {SUPABASE_ANON_KEY}',
        'Content-Type': 'application/json'
    }
    
    print("\n🔍 Testing QR Lookup via Contains...")
    print("=" * 32)
    
    try:
        # Search for user with SABO123456 anywhere in bio
        response = requests.get(
            f"{SUPABASE_URL}/rest/v1/users?bio=like.*SABO123456*&select=id,full_name,email,bio,skill_level",
            headers=headers
        )
        
        if response.status_code == 200:
            data = response.json()
            if data:
                user = data[0]
                print("🎉 QR LOOKUP SUCCESS (Contains)!")
                print(f"   👤 User: {user.get('full_name', 'N/A')}")
                print(f"   📧 Email: {user.get('email', 'N/A')}")
                print(f"   🏆 Skill: {user.get('skill_level', 'N/A')}")
                return user
            else:
                print("❌ No user found with contains search")
                return None
        else:
            print(f"❌ API Error: {response.status_code}")
            return None
            
    except Exception as e:
        print(f"💥 Exception: {e}")
        return None

def create_multiple_qr_users():
    """Create multiple QR test users"""
    
    headers = {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': f'Bearer {SUPABASE_ANON_KEY}',
        'Content-Type': 'application/json',
        'Prefer': 'return=representation'
    }
    
    print("\n🧪 Creating Multiple QR Test Users...")
    print("=" * 35)
    
    qr_users = [
        {
            "id": str(uuid.uuid4()),
            "email": "qr1@saboarena.com",
            "full_name": "Nguyễn QR Demo",
            "username": "qr_demo_1",
            "role": "player",
            "skill_level": "intermediate",
            "rank": "Intermediate", 
            "elo_rating": 1450,
            "spa_points": 250,
            "is_verified": True,
            "is_active": True,
            "bio": "QR:SABO111111"
        },
        {
            "id": str(uuid.uuid4()),
            "email": "qr2@saboarena.com", 
            "full_name": "Trần QR Test",
            "username": "qr_demo_2",
            "role": "player",
            "skill_level": "beginner",
            "rank": "Beginner",
            "elo_rating": 1200,
            "spa_points": 100,
            "is_verified": False,
            "is_active": True,
            "bio": "QR:SABO222222"
        }
    ]
    
    created_count = 0
    
    for user in qr_users:
        qr_code = user['bio'].replace('QR:', '')
        print(f"\n👤 Creating: {user['full_name']} ({qr_code})")
        
        try:
            response = requests.post(
                f"{SUPABASE_URL}/rest/v1/users",
                headers=headers,
                json=user
            )
            
            if response.status_code in [200, 201]:
                print(f"   ✅ Created successfully!")
                created_count += 1
            elif response.status_code == 409:
                print(f"   ⚠️ Already exists")
                created_count += 1
            else:
                print(f"   ❌ Failed: {response.status_code}")
                
        except Exception as e:
            print(f"   💥 Exception: {e}")
    
    print(f"\n📊 Summary: {created_count}/2 QR users ready")
    return created_count

def test_all_qr_codes():
    """Test all QR codes"""
    
    headers = {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': f'Bearer {SUPABASE_ANON_KEY}',
        'Content-Type': 'application/json'
    }
    
    print("\n🎯 Testing All QR Codes...")
    print("=" * 25)
    
    test_codes = ["SABO123456", "SABO111111", "SABO222222"]
    working_codes = []
    
    for code in test_codes:
        print(f"\n🔍 Testing: {code}")
        
        try:
            response = requests.get(
                f"{SUPABASE_URL}/rest/v1/users?bio=like.*{code}*&select=full_name,bio,skill_level",
                headers=headers
            )
            
            if response.status_code == 200:
                data = response.json()
                if data:
                    user = data[0]
                    print(f"   ✅ {user.get('full_name', 'N/A')} - {user.get('skill_level', 'N/A')}")
                    working_codes.append(code)
                else:
                    print(f"   ❌ Not found")
            else:
                print(f"   ⚠️ API Error: {response.status_code}")
                
        except Exception as e:
            print(f"   💥 Error: {e}")
    
    return working_codes

if __name__ == "__main__":
    print("🚀 SABO Arena - QR System (Bio Method)")
    print("Using existing schema with bio field")
    print("=" * 45)
    
    # Create first QR test user
    user1 = create_qr_test_user()
    
    if user1:
        # Test the lookup
        found_user = test_qr_lookup_bio()
        
        if not found_user:
            # Try contains method
            found_user = test_qr_lookup_contains()
    
    # Create multiple users
    create_multiple_qr_users()
    
    # Test all codes
    working_codes = test_all_qr_codes()
    
    print(f"\n" + "=" * 45)
    print("🎯 QR System Setup Complete!")
    print(f"✅ Working QR Codes: {len(working_codes)}")
    
    if working_codes:
        print(f"\n🔍 Ready for Flutter app testing:")
        for code in working_codes:
            print(f"   • {code}")
        
        print(f"\n📱 Launch Chrome app and test QR scanning!")
    else:
        print(f"\n❌ No working QR codes found")
    
    print("=" * 45)