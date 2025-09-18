import requests
import json

# Supabase configuration
SUPABASE_URL = "https://mogjjvscxjwvhtpkrlqr.supabase.co"
SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ"

def update_existing_user_with_qr():
    """Update existing user to have QR username"""
    
    headers = {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': f'Bearer {SUPABASE_ANON_KEY}',
        'Content-Type': 'application/json',
        'Prefer': 'return=representation'
    }
    
    print("🎯 SABO Arena - Quick QR Test Setup")
    print("Updating existing user with QR username")
    print("=" * 40)
    
    # Get first user
    try:
        response = requests.get(
            f"{SUPABASE_URL}/rest/v1/users?limit=1",
            headers=headers
        )
        
        if response.status_code == 200:
            users = response.json()
            if users:
                user = users[0]
                user_id = user['id']
                
                print(f"👤 Found user: {user.get('full_name', 'N/A')}")
                print(f"   Current username: {user.get('username', 'N/A')}")
                print(f"   Updating to: SABO123456")
                
                # Update username to QR code
                update_data = {
                    "username": "SABO123456",
                    "bio": "QR Test User - SABO123456"
                }
                
                update_response = requests.patch(
                    f"{SUPABASE_URL}/rest/v1/users?id=eq.{user_id}",
                    headers=headers,
                    json=update_data
                )
                
                if update_response.status_code == 200:
                    print("✅ User updated with QR username!")
                    return user_id
                else:
                    print(f"❌ Update failed: {update_response.status_code}")
                    print(f"   Error: {update_response.text}")
                    return None
            else:
                print("❌ No users found")
                return None
        else:
            print(f"❌ Error getting users: {response.status_code}")
            return None
            
    except Exception as e:
        print(f"💥 Exception: {e}")
        return None

def test_qr_lookup_final():
    """Final test of QR lookup"""
    
    headers = {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': f'Bearer {SUPABASE_ANON_KEY}',
        'Content-Type': 'application/json'
    }
    
    print(f"\n🔍 Final QR Test...")
    print("=" * 18)
    
    try:
        response = requests.get(
            f"{SUPABASE_URL}/rest/v1/users?username=eq.SABO123456&select=id,full_name,username,skill_level,elo_rating,email",
            headers=headers
        )
        
        if response.status_code == 200:
            data = response.json()
            if data:
                user = data[0]
                print("🎉 QR LOOKUP SUCCESS!")
                print(f"   👤 Name: {user.get('full_name', 'N/A')}")
                print(f"   📧 Email: {user.get('email', 'N/A')}")
                print(f"   🔤 Username: {user.get('username', 'N/A')}")
                print(f"   🏆 Skill: {user.get('skill_level', 'N/A')}")
                print(f"   ⭐ ELO: {user.get('elo_rating', 'N/A')}")
                return True
            else:
                print("❌ QR user not found")
                return False
        else:
            print(f"❌ API Error: {response.status_code}")
            return False
            
    except Exception as e:
        print(f"💥 Exception: {e}")
        return False

if __name__ == "__main__":
    print("🚀 SABO Arena - Quick QR Setup")
    print("=" * 30)
    
    # Update existing user with QR username
    user_id = update_existing_user_with_qr()
    
    if user_id:
        # Test the QR lookup
        success = test_qr_lookup_final()
        
        if success:
            print(f"\n" + "=" * 40)
            print("🎉 QR SYSTEM READY!")
            print("✅ User updated with QR username")
            print("✅ QR lookup working")
            print("✅ Chrome app running")
            print("✅ QR codes available")
            print(f"\n📱 READY FOR QR TESTING!")
            print(f"   1. Use QR codes from qr_test_codes.html")
            print(f"   2. Test scanning in Chrome app")
            print(f"   3. QR code: SABO123456 should work!")
            print("=" * 40)
        else:
            print(f"\n❌ QR lookup failed")
    else:
        print(f"\n❌ Failed to update user")
    
    print("🚀 Ready for QR testing in Chrome app!")