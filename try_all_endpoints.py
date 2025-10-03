import requests

# Supabase connection
SUPABASE_URL = "https://mogjjvscxjwvhtpkrlqr.supabase.co"
SERVICE_ROLE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo"

print("🔧 Executing ALTER TABLE via Supabase REST API...")
print(f"🌐 URL: {SUPABASE_URL}")

# Try using psql-style endpoint
headers = {
    "apikey": SERVICE_ROLE_KEY,
    "Authorization": f"Bearer {SERVICE_ROLE_KEY}",
    "Content-Type": "application/json",
}

# Method 1: Try query endpoint
sql = "ALTER TABLE matches ALTER COLUMN round_number DROP NOT NULL"

endpoints_to_try = [
    "/rest/v1/rpc/query",
    "/rest/v1/rpc/exec_sql", 
    "/database/v1/query",
    "/pg/v1/query",
]

for endpoint in endpoints_to_try:
    print(f"\n🔄 Trying endpoint: {endpoint}")
    url = f"{SUPABASE_URL}{endpoint}"
    
    try:
        response = requests.post(
            url,
            headers=headers,
            json={"query": sql},
            timeout=10
        )
        
        print(f"   Status: {response.status_code}")
        
        if response.status_code in [200, 201, 204]:
            print(f"   ✅ SUCCESS!")
            print(f"   Response: {response.text[:200]}")
            break
        else:
            print(f"   ❌ Failed: {response.text[:150]}")
            
    except requests.exceptions.Timeout:
        print(f"   ⏱️  Timeout")
    except Exception as e:
        print(f"   ❌ Error: {e}")

print("\n" + "="*70)
print("⚠️  REST API doesn't support raw SQL execution")
print("="*70)
print("\n📝 You need to run this SQL manually in Supabase SQL Editor:")
print("\n" + "─"*70)
print("ALTER TABLE matches ALTER COLUMN round_number DROP NOT NULL;")
print("─"*70)
print("\n📍 Steps:")
print("1. Go to: https://supabase.com/dashboard/project/mogjjvscxjwvhtpkrlqr/sql")
print("2. Click 'New Query'")
print("3. Paste the SQL above")
print("4. Click 'Run' or press Ctrl+Enter")
print("\n✅ Once done, restart the Flutter app and test!")
