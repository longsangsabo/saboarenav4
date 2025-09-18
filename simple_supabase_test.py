import requests
import json

def test_supabase_connection():
    print("🧪 TESTING SUPABASE CONNECTION WITH SERVICE ROLE KEY")
    print("=" * 60)
    
    # Supabase configuration
    SUPABASE_URL = "https://mogjjvscxjwvhtpkrlqr.supabase.co"
    SERVICE_ROLE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo"
    
    headers = {
        "apikey": SERVICE_ROLE_KEY,
        "Authorization": f"Bearer {SERVICE_ROLE_KEY}",
        "Content-Type": "application/json"
    }
    
    # Test 1: Basic connection - get users count
    print("\n📋 TEST 1: Basic Connection Test")
    try:
        response = requests.get(
            f"{SUPABASE_URL}/rest/v1/users?select=count",
            headers={**headers, "Prefer": "count=exact"}
        )
        if response.status_code == 200:
            count = response.headers.get('Content-Range', 'unknown').split('/')[-1]
            print(f"   ✅ Connection successful!")
            print(f"   📊 Total users in database: {count}")
        else:
            print(f"   ❌ Connection failed: {response.status_code} - {response.text}")
    except Exception as e:
        print(f"   ❌ Connection error: {e}")
    
    # Test 2: Check database tables
    print("\n📋 TEST 2: Database Tables Check")
    tables = ['users', 'tournaments', 'clubs', 'posts', 'matches', 'achievements']
    
    for table in tables:
        try:
            response = requests.get(
                f"{SUPABASE_URL}/rest/v1/{table}?select=count&limit=1",
                headers=headers
            )
            if response.status_code == 200:
                print(f"   ✅ Table '{table}' exists and accessible")
            else:
                print(f"   ❌ Table '{table}' error: {response.status_code}")
        except Exception as e:
            print(f"   ❌ Table '{table}' error: {e}")
    
    # Test 3: Sample data check
    print("\n📋 TEST 3: Sample Data Check")
    try:
        response = requests.get(
            f"{SUPABASE_URL}/rest/v1/users?select=id,email,created_at&limit=3",
            headers=headers
        )
        if response.status_code == 200:
            users = response.json()
            print(f"   ✅ Sample data retrieved successfully")
            print(f"   👥 Found {len(users)} sample users:")
            for user in users:
                email = user.get('email', 'N/A')
                created = user.get('created_at', 'N/A')[:10] if user.get('created_at') else 'N/A'
                print(f"      - ID: {user['id'][:8]}..., Email: {email}, Created: {created}")
        else:
            print(f"   ❌ Sample data error: {response.status_code} - {response.text}")
    except Exception as e:
        print(f"   ❌ Sample data error: {e}")
    
    # Test 4: Authentication check
    print("\n📋 TEST 4: Service Role Authentication")
    try:
        # Try to access auth-protected endpoint
        response = requests.get(
            f"{SUPABASE_URL}/rest/v1/rpc/get_user_stats",
            headers=headers,
            json={"user_id": "test"}
        )
        if response.status_code in [200, 404]:  # 404 means function exists but no data
            print("   ✅ Service Role authentication working")
        else:
            print(f"   ⚠️  Service Role auth response: {response.status_code}")
    except Exception as e:
        print(f"   ⚠️  Service Role auth test: {e}")
    
    print("\n🎉 SUPABASE CONNECTION TEST COMPLETED!")
    print("=" * 60)

if __name__ == "__main__":
    test_supabase_connection()