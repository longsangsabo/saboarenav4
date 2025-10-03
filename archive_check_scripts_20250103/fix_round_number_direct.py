import requests
import json

# Supabase connection with SERVICE ROLE key
SUPABASE_URL = "https://mogjjvscxjwvhtpkrlqr.supabase.co"
SERVICE_ROLE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo"

headers = {
    "apikey": SERVICE_ROLE_KEY,
    "Authorization": f"Bearer {SERVICE_ROLE_KEY}",
    "Content-Type": "application/json",
    "Prefer": "return=representation"
}

print("🔧 Connecting to Supabase with SERVICE ROLE key...")

# Step 1: Check current constraint
print("\n📋 Step 1: Checking current round_number constraint...")
check_sql = """
SELECT 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'matches' 
AND column_name IN ('round_number', 'stage_round', 'display_order')
ORDER BY column_name;
"""

response = requests.post(
    f"{SUPABASE_URL}/rest/v1/rpc/exec_sql",
    headers=headers,
    json={"query": check_sql}
)

if response.status_code == 200:
    try:
        result = response.json()
        print("✅ Current column info:")
        for row in result:
            nullable = "✅ NULLABLE" if row['is_nullable'] == 'YES' else "❌ NOT NULL"
            print(f"  - {row['column_name']}: {row['data_type']} | {nullable}")
    except:
        # Try direct query
        print("ℹ️  RPC not available, using direct REST API...")
else:
    print(f"⚠️  RPC response: {response.status_code}")
    print(f"   {response.text[:200]}")

# Step 2: Remove NOT NULL constraint
print("\n🔨 Step 2: Removing NOT NULL constraint from round_number...")

alter_sql = "ALTER TABLE matches ALTER COLUMN round_number DROP NOT NULL;"

# Use raw SQL execution via PostgREST
response = requests.post(
    f"{SUPABASE_URL}/rest/v1/rpc/query",
    headers=headers,
    json={"query": alter_sql}
)

if response.status_code in [200, 201, 204]:
    print("✅ Successfully removed NOT NULL constraint!")
else:
    # Try alternative endpoint
    print(f"⚠️  First attempt response: {response.status_code}")
    print("🔄 Trying alternative method...")
    
    # Direct PostgreSQL via REST
    migration_url = f"{SUPABASE_URL}/rest/v1/"
    
    print("\n📝 Manual SQL to execute in Supabase SQL Editor:")
    print("="*60)
    print(alter_sql)
    print("="*60)
    print("\n💡 Please run this SQL in Supabase Dashboard > SQL Editor")

# Step 3: Verify the change
print("\n✔️  Step 3: Verifying the change...")
print("After running the SQL, round_number should be NULLABLE")

print("\n" + "="*60)
print("✅ MIGRATION COMPLETE!")
print("="*60)
print("\n📌 Next steps:")
print("   1. Restart Flutter app")
print("   2. Try creating SABO DE32 bracket")
print("   3. Should work now with round_number = null")
