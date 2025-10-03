import requests
import json

# Supabase Configuration
SUPABASE_URL = "https://mogjjvscxjwvhtpkrlqr.supabase.co"
SERVICE_ROLE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo"

headers = {
    "apikey": SERVICE_ROLE_KEY,
    "Authorization": f"Bearer {SERVICE_ROLE_KEY}",
    "Content-Type": "application/json",
    "Prefer": "return=minimal"
}

# Get haha1 tournament
print("🔍 Getting haha1 tournament...")
response = requests.get(
    f"{SUPABASE_URL}/rest/v1/tournaments?title=eq.haha1&select=id",
    headers=headers
)

if response.status_code == 200:
    tournaments = response.json()
    if not tournaments:
        print("❌ Tournament 'haha1' not found")
        exit(1)
    
    tournament_id = tournaments[0]['id']
    print(f"✅ Found tournament: {tournament_id}")
    
    # Delete all matches for this tournament
    print(f"\n🗑️ Deleting all matches for tournament haha1...")
    response = requests.delete(
        f"{SUPABASE_URL}/rest/v1/matches?tournament_id=eq.{tournament_id}",
        headers=headers
    )
    
    if response.status_code == 204 or response.status_code == 200:
        print("✅ All matches deleted successfully!")
        print("\n🎯 Now you can:")
        print("   1. Go to the app")
        print("   2. Navigate to tournament 'haha1'")
        print("   3. Click 'Tạo bảng' button")
        print("   4. Check if Round 2 gets populated with winners!")
    else:
        print(f"❌ Error deleting matches: {response.status_code}")
        print(response.text)
else:
    print(f"❌ Error: {response.status_code}")
    print(response.text)
