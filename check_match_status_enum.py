import requests

# Supabase Configuration
SUPABASE_URL = "https://mogjjvscxjwvhtpkrlqr.supabase.co"
SERVICE_ROLE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo"

headers = {
    "apikey": SERVICE_ROLE_KEY,
    "Authorization": f"Bearer {SERVICE_ROLE_KEY}",
}

# Try to get match_status enum values by checking existing matches
print("🔍 Checking existing match status values in database...")
response = requests.get(
    f"{SUPABASE_URL}/rest/v1/matches?select=status&limit=100",
    headers=headers
)

if response.status_code == 200:
    matches = response.json()
    statuses = set(m['status'] for m in matches if m.get('status'))
    print(f"\n✅ Found status values in database:")
    for status in sorted(statuses):
        print(f"  - {status}")
else:
    print(f"❌ Error: {response.status_code}")
    print(response.text)
