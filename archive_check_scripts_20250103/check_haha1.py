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

# Get tournament by title "haha1"
print("🔍 Searching for 'haha1' tournament...")
response = requests.get(
    f"{SUPABASE_URL}/rest/v1/tournaments?title=eq.haha1&select=*",
    headers=headers
)

if response.status_code == 200:
    tournaments = response.json()
    if not tournaments:
        print("❌ Tournament 'haha1' not found")
        exit(1)
    
    tournament = tournaments[0]
    tournament_id = tournament['id']
    
    print(f"\n✅ Tournament ID: {tournament_id}")
    print(f"   Title: {tournament.get('title')}")
    print(f"   Game Format: {tournament.get('game_format')}")
    print(f"   Bracket Format: {tournament.get('bracket_format')}")
    print(f"   Max Participants: {tournament.get('max_participants')}")
    print(f"   Current Participants: {tournament.get('current_participants')}")
    
    # Get matches
    print(f"\n🔍 Getting matches for tournament...")
    response = requests.get(
        f"{SUPABASE_URL}/rest/v1/matches?tournament_id=eq.{tournament_id}&select=*&order=match_number.asc",
        headers=headers
    )
    
    if response.status_code == 200:
        matches = response.json()
        print(f"✅ Found {len(matches)} matches\n")
        
        # Organize by round
        rounds = {}
        for match in matches:
            round_num = match.get('round_number', 'NULL')
            if round_num not in rounds:
                rounds[round_num] = []
            rounds[round_num].append(match)
        
        # Print by round
        for round_num in sorted(rounds.keys(), key=lambda x: x if x != 'NULL' else 0):
            matches_in_round = rounds[round_num]
            print(f"\n{'='*60}")
            print(f"ROUND {round_num} - {len(matches_in_round)} matches")
            print(f"{'='*60}")
            print(f"Match# | Winner→ | P1? | P2? | Status")
            print(f"-------|---------|-----|-----|--------")
            
            for match in matches_in_round:
                match_num = match.get('match_number', '?')
                winner_to = match.get('winner_advances_to')
                p1 = '✓' if match.get('player1_id') else '✗'
                p2 = '✓' if match.get('player2_id') else '✗'
                status = match.get('status', 'pending')
                
                winner_to_str = str(winner_to) if winner_to else 'NULL'
                
                print(f"{str(match_num):6} | {winner_to_str:7} | {p1:3} | {p2:3} | {status}")
        
        # Analysis
        print(f"\n{'='*60}")
        print("ANALYSIS")
        print(f"{'='*60}")
        
        # Count matches with players
        matches_with_both = sum(1 for m in matches if m.get('player1_id') and m.get('player2_id'))
        matches_with_one = sum(1 for m in matches if (m.get('player1_id') or m.get('player2_id')) and not (m.get('player1_id') and m.get('player2_id')))
        matches_empty = sum(1 for m in matches if not m.get('player1_id') and not m.get('player2_id'))
        
        print(f"Matches with both players: {matches_with_both}")
        print(f"Matches with one player:  {matches_with_one}")
        print(f"Matches empty:            {matches_empty}")
        
        # Check winner_advances_to
        matches_with_advancement = sum(1 for m in matches if m.get('winner_advances_to') is not None)
        matches_without_advancement = sum(1 for m in matches if m.get('winner_advances_to') is None)
        
        print(f"\nMatches with winner_advances_to: {matches_with_advancement}")
        print(f"Matches without (final):         {matches_without_advancement}")
        
    else:
        print(f"❌ Error getting matches: {response.status_code}")
        print(response.text)
else:
    print(f"❌ Error: {response.status_code}")
    print(response.text)
