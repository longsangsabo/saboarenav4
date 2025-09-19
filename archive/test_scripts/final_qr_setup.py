import requests
import json

# Supabase configuration
SUPABASE_URL = "https://mogjjvscxjwvhtpkrlqr.supabase.co"
SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ"

def add_qr_to_existing_user():
    """Add QR code to existing user in users table"""
    
    headers = {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': f'Bearer {SUPABASE_ANON_KEY}',
        'Content-Type': 'application/json',
        'Prefer': 'return=representation'
    }
    
    print("🎯 Final QR System Setup - Using 'users' table")
    print("=" * 50)
    
    # First, get existing user
    print("📋 Step 1: Getting existing user...")
    try:
        response = requests.get(
            f"{SUPABASE_URL}/rest/v1/users?limit=1",
            headers=headers
        )
        
        if response.status_code == 200:
            users = response.json()
            if users:
                existing_user = users[0]
                user_id = existing_user['id']
                print(f"✅ Found user: {existing_user.get('full_name', 'N/A')} (ID: {user_id})")
                
                # Add QR data to this user
                print(f"📋 Step 2: Adding QR code to user {user_id}...")
                
                qr_update = {
                    "user_code": "SABO123456",
                    "qr_data": "SABO123456"
                }
                
                update_response = requests.patch(
                    f"{SUPABASE_URL}/rest/v1/users?id=eq.{user_id}",
                    headers=headers,
                    json=qr_update
                )
                
                if update_response.status_code == 200:
                    print("✅ QR code added to existing user!")
                else:
                    print(f"❌ Failed to add QR: {update_response.text}")
                    # Might be because columns don't exist yet
                    print("⚠️ QR columns might not exist in users table")
                    return False
                    
            else:
                print("❌ No users found in database")
                return False
        else:
            print(f"❌ Error getting users: {response.text}")
            return False
            
    except Exception as e:
        print(f"💥 Exception: {e}")
        return False
    
    return True

def test_qr_scanning_with_users():
    """Test QR scanning with the users table"""
    
    headers = {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': f'Bearer {SUPABASE_ANON_KEY}',
        'Content-Type': 'application/json'
    }
    
    print("\n🔍 Step 3: Testing QR Code Lookup...")
    print("=" * 30)
    
    test_code = "SABO123456"
    
    try:
        response = requests.get(
            f"{SUPABASE_URL}/rest/v1/users?user_code=eq.{test_code}&select=id,full_name,email,user_code,skill_level,elo_rating",
            headers=headers
        )
        
        if response.status_code == 200:
            data = response.json()
            if data:
                user = data[0]
                print(f"✅ QR SCAN SUCCESS!")
                print(f"   👤 User: {user.get('full_name', 'N/A')}")
                print(f"   📧 Email: {user.get('email', 'N/A')}")
                print(f"   🏆 ELO: {user.get('elo_rating', 'N/A')}")
                print(f"   🔢 QR Code: {user.get('user_code', 'N/A')}")
                return True
            else:
                print(f"❌ No user found with QR code: {test_code}")
                return False
        else:
            print(f"❌ API Error {response.status_code}: {response.text}")
            return False
            
    except Exception as e:
        print(f"💥 Exception: {e}")
        return False

def create_demo_qr_users():
    """Create some demo users specifically for QR testing"""
    
    headers = {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': f'Bearer {SUPABASE_ANON_KEY}',
        'Content-Type': 'application/json',
        'Prefer': 'return=representation'
    }
    
    print("\n🧪 Step 4: Creating Demo QR Users...")
    print("=" * 40)
    
    demo_users = [
        {
            "id": "qr-demo-001",
            "email": "demo1@saboarena.com",
            "full_name": "Nguyễn QR Demo",
            "username": "qr_demo_1",
            "role": "player",
            "skill_level": "intermediate",
            "rank": "Intermediate",
            "elo_rating": 1450,
            "spa_points": 250,
            "is_verified": True,
            "is_active": True,
            "user_code": "SABO111111",
            "qr_data": "SABO111111"
        },
        {
            "id": "qr-demo-002", 
            "email": "demo2@saboarena.com",
            "full_name": "Trần QR Test",
            "username": "qr_demo_2",
            "role": "player", 
            "skill_level": "beginner",
            "rank": "Beginner",
            "elo_rating": 1200,
            "spa_points": 100,
            "is_verified": False,
            "is_active": True,
            "user_code": "SABO222222",
            "qr_data": "SABO222222"
        }
    ]
    
    for user in demo_users:
        print(f"\n👤 Creating: {user['full_name']} ({user['user_code']})")
        
        try:
            response = requests.post(
                f"{SUPABASE_URL}/rest/v1/users",
                headers=headers,
                json=user
            )
            
            if response.status_code in [200, 201]:
                print(f"✅ Demo user created!")
            elif response.status_code == 409:
                print(f"⚠️ User already exists")
            else:
                print(f"❌ Failed: {response.status_code} - {response.text}")
                
        except Exception as e:
            print(f"💥 Exception: {e}")

def final_verification():
    """Final verification of all QR codes"""
    
    headers = {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': f'Bearer {SUPABASE_ANON_KEY}',
        'Content-Type': 'application/json'
    }
    
    print("\n🎯 Final QR System Verification")
    print("=" * 40)
    
    test_codes = ["SABO123456", "SABO111111", "SABO222222"]
    working_codes = []
    
    for code in test_codes:
        print(f"\n🔍 Testing: {code}")
        
        try:
            response = requests.get(
                f"{SUPABASE_URL}/rest/v1/users?user_code=eq.{code}&select=full_name,user_code,skill_level",
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
    
    print(f"\n🎉 QR System Setup Complete!")
    print(f"✅ Working QR Codes: {len(working_codes)}")
    print(f"📱 Ready for Flutter app testing!")
    
    if working_codes:
        print(f"\n🔍 Test these QR codes in Flutter app:")
        for code in working_codes:
            print(f"   • {code}")
    
    return len(working_codes) > 0

if __name__ == "__main__":
    print("🚀 SABO Arena QR System - Final Setup")
    print("Using the correct 'users' table")
    print("=" * 50)
    
    # Try to add QR to existing user first
    success = add_qr_to_existing_user()
    
    if success:
        # Test the QR scanning
        scan_success = test_qr_scanning_with_users()
        
        if scan_success:
            print("\n🎉 SUCCESS! QR system is working!")
    
    # Create additional demo users
    create_demo_qr_users()
    
    # Final verification
    final_verification()
    
    print("\n" + "=" * 50)
    print("🎯 Setup Complete - Ready for QR Testing!")
    print("📱 Open Flutter app and try scanning QR codes!")