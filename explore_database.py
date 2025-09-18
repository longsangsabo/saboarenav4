import requests
import json

# Supabase configuration
SUPABASE_URL = "https://mogjjvscxjwvhtpkrlqr.supabase.co"
SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ"

def explore_database():
    """Explore database structure"""
    
    headers = {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': f'Bearer {SUPABASE_ANON_KEY}',
        'Content-Type': 'application/json'
    }
    
    print("🔍 Exploring Database Structure...")
    print("=" * 50)
    
    # Try to get user_preferences table data to understand schema
    print("\n📋 Checking user_preferences table...")
    try:
        response = requests.get(
            f"{SUPABASE_URL}/rest/v1/user_preferences?limit=1",
            headers=headers
        )
        
        if response.status_code == 200:
            data = response.json()
            if data:
                print("✅ Table exists! Sample row:")
                user = data[0]
                print(f"   Available columns: {list(user.keys())}")
                print(f"   Sample data: {json.dumps(user, indent=2)}")
            else:
                print("⚠️ Table exists but empty")
        else:
            print(f"❌ Error {response.status_code}: {response.text}")
            
    except Exception as e:
        print(f"💥 Exception: {e}")
    
    # Check what tables exist
    print("\n📋 Checking available tables...")
    common_table_names = [
        'users', 'user_profiles', 'user_preferences', 'profiles',
        'accounts', 'players', 'members'
    ]
    
    for table_name in common_table_names:
        try:
            response = requests.get(
                f"{SUPABASE_URL}/rest/v1/{table_name}?limit=1",
                headers=headers
            )
            
            if response.status_code == 200:
                data = response.json()
                print(f"✅ Table '{table_name}' exists - {len(data)} rows found")
                if data:
                    print(f"   Columns: {list(data[0].keys())}")
            elif response.status_code == 404:
                print(f"❌ Table '{table_name}' not found")
            else:
                print(f"⚠️ Table '{table_name}' - Status {response.status_code}")
                
        except Exception as e:
            print(f"💥 Error checking table '{table_name}': {e}")
    
    print("=" * 50)

def try_insert_simple_qr_user():
    """Try to insert a very simple user with QR code"""
    
    headers = {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': f'Bearer {SUPABASE_ANON_KEY}',
        'Content-Type': 'application/json',
        'Prefer': 'return=representation'
    }
    
    print("🧪 Trying Simple QR User Insert...")
    print("=" * 50)
    
    # Very minimal user data
    simple_user = {
        "id": "qr-test-user",
        "user_code": "SABO999999",
        "qr_data": "SABO999999"
    }
    
    try:
        response = requests.post(
            f"{SUPABASE_URL}/rest/v1/user_preferences",
            headers=headers,
            json=simple_user
        )
        
        if response.status_code in [200, 201]:
            print("✅ Simple user created successfully!")
            print(f"   Response: {response.json()}")
        else:
            print(f"❌ Insert failed {response.status_code}: {response.text}")
            
    except Exception as e:
        print(f"💥 Exception: {e}")
    
    print("=" * 50)

def test_simple_qr_lookup():
    """Test QR lookup with simple data"""
    
    headers = {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': f'Bearer {SUPABASE_ANON_KEY}',
        'Content-Type': 'application/json'
    }
    
    print("🔍 Testing Simple QR Lookup...")
    print("=" * 50)
    
    test_code = "SABO999999"
    
    try:
        response = requests.get(
            f"{SUPABASE_URL}/rest/v1/user_preferences?user_code=eq.{test_code}",
            headers=headers
        )
        
        if response.status_code == 200:
            data = response.json()
            if data:
                print(f"✅ Found user with QR code {test_code}!")
                print(f"   Data: {json.dumps(data[0], indent=2)}")
            else:
                print(f"⚠️ No user found with QR code {test_code}")
        else:
            print(f"❌ API Error {response.status_code}: {response.text}")
            
    except Exception as e:
        print(f"💥 Exception: {e}")
    
    print("=" * 50)

if __name__ == "__main__":
    explore_database()
    try_insert_simple_qr_user()
    test_simple_qr_lookup()
    
    print("🎯 Database exploration complete!")
    print("Now we know the exact table schema to work with.")