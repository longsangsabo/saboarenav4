import requests
import json

# Supabase Configuration
SUPABASE_URL = "https://mogjjvscxjwvhtpkrlqr.supabase.co"
SERVICE_ROLE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo"

headers = {
    "apikey": SERVICE_ROLE_KEY,
    "Authorization": f"Bearer {SERVICE_ROLE_KEY}",
    "Content-Type": "application/json"
}

# Get haha1 tournament
print("🔍 Getting haha1 tournament details...")
response = requests.get(
    f"{SUPABASE_URL}/rest/v1/tournaments?title=eq.haha1&select=*",
    headers=headers
)

if response.status_code == 200:
    tournaments = response.json()
    if tournaments:
        tournament = tournaments[0]
        print("\n✅ Tournament 'haha1' fields:")
        print(json.dumps(tournament, indent=2))
        
        print("\n🔍 Key fields:")
        print(f"  - Has 'format' field: {'format' in tournament}")
        print(f"  - Has 'game_format' field: {'game_format' in tournament}")
        print(f"  - Has 'bracket_format' field: {'bracket_format' in tournament}")
        
        if 'format' in tournament:
            print(f"  - format value: {tournament['format']}")
        else:
            print(f"  - format value: FIELD DOES NOT EXIST")
            
        if 'game_format' in tournament:
            print(f"  - game_format value: {tournament['game_format']}")
            
        if 'bracket_format' in tournament:
            print(f"  - bracket_format value: {tournament['bracket_format']}")
    else:
        print("❌ Tournament not found")
else:
    print(f"❌ Error: {response.status_code}")
    print(response.text)
