import requests
import json

# Supabase credentials
SUPABASE_URL = "https://mogjjvscxjwvhtpkrlqr.supabase.co"
SERVICE_ROLE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo"

headers = {
    "apikey": SERVICE_ROLE_KEY,
    "Authorization": f"Bearer {SERVICE_ROLE_KEY}",
    "Content-Type": "application/json"
}

print("🔍 Getting all tournaments to find column names...")
# First get all columns
response = requests.get(
    f"{SUPABASE_URL}/rest/v1/tournaments?limit=1",
    headers=headers
)

if response.status_code == 200:
    tournaments = response.json()
    if tournaments:
        print(f"✅ Column names: {list(tournaments[0].keys())}")
        
        # Now find sabo1 tournament
        print("\n🔍 Searching for sabo1 tournament...")
        for key in tournaments[0].keys():
            if 'name' in key.lower():
                print(f"   Found name column: {key}")
                response = requests.get(
                    f"{SUPABASE_URL}/rest/v1/tournaments?{key}=eq.sabo1&select=*",
                    headers=headers
                )
                if response.status_code == 200:
                    results = response.json()
                    if results:
                        print(f"✅ Tournament found:")
                        print(f"   {json.dumps(results[0], indent=2)}")
                        tournament_id = results[0]['id']
                        break
    else:
        print("❌ No tournaments found")
        exit(1)
else:
    print(f"❌ Error: {response.status_code} - {response.text}")
    exit(1)

print("\n🔍 Checking matches with winner_advances_to...")
# Get matches with winner_advances_to (use title column)
response = requests.get(
    f"{SUPABASE_URL}/rest/v1/tournaments?title=eq.sabo1&select=id,title,game_format,bracket_format",
    headers=headers
)

if response.status_code == 200:
    tournaments = response.json()
    if tournaments:
        tournament_id = tournaments[0]['id']
        print(f"✅ Tournament ID: {tournament_id}")
        print(f"   Title: {tournaments[0]['title']}")
        print(f"   Game Format: {tournaments[0]['game_format']}")
        print(f"   Bracket Format: {tournaments[0]['bracket_format']}")
        
        # Get matches
        response = requests.get(
            f"{SUPABASE_URL}/rest/v1/matches?tournament_id=eq.{tournament_id}&select=match_number,round,winner_advances_to,player1_id,player2_id&order=round.asc,match_number.asc&limit=15",
            headers=headers
        )
        
        if response.status_code == 200:
            matches = response.json()
            print(f"✅ Found {len(matches)} matches:")
            print("\nMatch# | Round          | Winner→ | P1? | P2?")
            print("-------|----------------|---------|-----|----")
            for m in matches:
                winner_to = m.get('winner_advances_to') or 'NULL'
                p1 = '✓' if m.get('player1_id') else '✗'
                p2 = '✓' if m.get('player2_id') else '✗'
                match_num = str(m.get('match_number') or 'NULL')
                round_val = str(m.get('round') or 'NULL')
                print(f"{match_num:6} | {round_val:14} | {str(winner_to):7} | {p1:3} | {p2:3}")
        else:
            print(f"❌ Error getting matches: {response.status_code}")
else:
    print(f"❌ Error: {response.status_code}")
