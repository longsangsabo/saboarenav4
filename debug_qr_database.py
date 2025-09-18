import requests
import json

# Supabase configuration
SUPABASE_URL = "https://mogjjvscxjwvhtpkrlqr.supabase.co"
SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ"

def check_all_users():
    """Check all users in database"""
    
    headers = {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': f'Bearer {SUPABASE_ANON_KEY}',
        'Content-Type': 'application/json'
    }
    
    print("🔍 Checking All Users in Database")
    print("=" * 35)
    
    try:
        response = requests.get(
            f"{SUPABASE_URL}/rest/v1/users?select=id,full_name,username,email,bio&limit=10",
            headers=headers
        )
        
        if response.status_code == 200:
            users = response.json()
            print(f"📊 Found {len(users)} users:")
            
            for i, user in enumerate(users, 1):
                print(f"\n{i}. {user.get('full_name', 'N/A')}")
                print(f"   📧 Email: {user.get('email', 'N/A')}")
                print(f"   👤 Username: {user.get('username', 'N/A')}")
                print(f"   📝 Bio: {user.get('bio', 'N/A')}")
                print(f"   🆔 ID: {user.get('id', 'N/A')}")
                
                # Check if this looks like a QR user
                username = user.get('username', '')
                bio = user.get('bio', '')
                if 'SABO' in username or 'SABO' in bio:
                    print(f"   🎯 POTENTIAL QR USER!")
            
            return users
        else:
            print(f"❌ Error: {response.status_code} - {response.text}")
            return []
            
    except Exception as e:
        print(f"💥 Exception: {e}")
        return []

def check_specific_qr_codes():
    """Check specific QR codes"""
    
    headers = {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': f'Bearer {SUPABASE_ANON_KEY}',
        'Content-Type': 'application/json'
    }
    
    print(f"\n🎯 Checking Specific QR Codes")
    print("=" * 28)
    
    qr_codes = ["SABO123456", "SABO111111", "SABO222222"]
    
    for code in qr_codes:
        print(f"\n🔍 Checking: {code}")
        
        # Check username
        try:
            response = requests.get(
                f"{SUPABASE_URL}/rest/v1/users?username=eq.{code}&select=id,full_name,username,bio",
                headers=headers
            )
            
            if response.status_code == 200:
                data = response.json()
                if data:
                    user = data[0]
                    print(f"   ✅ Found via username!")
                    print(f"      👤 Name: {user.get('full_name', 'N/A')}")
                    print(f"      👤 Username: {user.get('username', 'N/A')}")
                    print(f"      📝 Bio: {user.get('bio', 'N/A')}")
                else:
                    print(f"   ❌ Not found via username")
            else:
                print(f"   ⚠️ Username error: {response.status_code}")
                
        except Exception as e:
            print(f"   💥 Username exception: {e}")
        
        # Check bio
        try:
            response = requests.get(
                f"{SUPABASE_URL}/rest/v1/users?bio=eq.{code}&select=id,full_name,username,bio",
                headers=headers
            )
            
            if response.status_code == 200:
                data = response.json()
                if data:
                    user = data[0]
                    print(f"   ✅ Found via bio!")
                    print(f"      👤 Name: {user.get('full_name', 'N/A')}")
                    print(f"      📝 Bio: {user.get('bio', 'N/A')}")
                else:
                    print(f"   ❌ Not found via bio")
            else:
                print(f"   ⚠️ Bio error: {response.status_code}")
                
        except Exception as e:
            print(f"   💥 Bio exception: {e}")

def try_creating_simple_qr_user():
    """Try creating one simple QR user for testing"""
    
    headers = {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': f'Bearer {SUPABASE_ANON_KEY}',
        'Content-Type': 'application/json',
        'Prefer': 'return=representation'
    }
    
    print(f"\n🧪 Creating Simple QR User")
    print("=" * 25)
    
    import uuid
    
    simple_user = {
        "id": str(uuid.uuid4()),
        "email": "simple.qr@test.com",
        "full_name": "Simple QR Test",
        "username": "SABO999999",
        "role": "player",
        "skill_level": "beginner",
        "is_verified": False,
        "is_active": True,
        "bio": "SABO999999"
    }
    
    print(f"👤 Creating: {simple_user['full_name']}")
    print(f"   Username: {simple_user['username']}")
    print(f"   Bio: {simple_user['bio']}")
    
    try:
        response = requests.post(
            f"{SUPABASE_URL}/rest/v1/users",
            headers=headers,
            json=simple_user
        )
        
        if response.status_code in [200, 201]:
            print(f"   ✅ Created successfully!")
            created_user = response.json()
            print(f"   Created user: {created_user}")
            return True
        elif response.status_code == 409:
            print(f"   ⚠️ User already exists")
            return True
        else:
            print(f"   ❌ Failed: {response.status_code}")
            print(f"   Error: {response.text}")
            return False
            
    except Exception as e:
        print(f"   💥 Exception: {e}")
        return False

def test_simple_qr_lookup():
    """Test the simple QR user lookup"""
    
    headers = {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': f'Bearer {SUPABASE_ANON_KEY}',
        'Content-Type': 'application/json'
    }
    
    print(f"\n✅ Testing Simple QR Lookup")
    print("=" * 26)
    
    code = "SABO999999"
    print(f"🔍 Testing: {code}")
    
    try:
        response = requests.get(
            f"{SUPABASE_URL}/rest/v1/users?username=eq.{code}",
            headers=headers
        )
        
        if response.status_code == 200:
            data = response.json()
            if data:
                user = data[0]
                print(f"🎉 SUCCESS! Found QR user:")
                print(f"   👤 Name: {user.get('full_name', 'N/A')}")
                print(f"   👤 Username: {user.get('username', 'N/A')}")
                print(f"   📧 Email: {user.get('email', 'N/A')}")
                print(f"   📝 Bio: {user.get('bio', 'N/A')}")
                return True
            else:
                print(f"❌ User not found")
                return False
        else:
            print(f"❌ API Error: {response.status_code}")
            return False
            
    except Exception as e:
        print(f"💥 Exception: {e}")
        return False

if __name__ == "__main__":
    print("🔍 SABO Arena - Database QR Check")
    print("=" * 35)
    
    # Check all users
    users = check_all_users()
    
    # Check specific QR codes
    check_specific_qr_codes()
    
    # Try creating a simple QR user
    created = try_creating_simple_qr_user()
    
    if created:
        # Test the lookup
        success = test_simple_qr_lookup()
        
        if success:
            print(f"\n🎉 QR SYSTEM WORKING!")
            print(f"✅ Database connection OK")
            print(f"✅ User creation OK") 
            print(f"✅ QR lookup OK")
            print(f"\n🚀 Ready to launch Flutter app!")
        else:
            print(f"\n❌ QR lookup failed")
    else:
        print(f"\n❌ Failed to create QR user")
    
    print("=" * 35)