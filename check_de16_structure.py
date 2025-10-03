import requests
import json

# Supabase config
SUPABASE_URL = "https://mogjjvscxjwvhtpkrlqr.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ"

headers = {
    'apikey': SUPABASE_KEY,
    'Authorization': f'Bearer {SUPABASE_KEY}'
}

# Find latest tournament with double_elimination
print("🔍 Finding latest Double Elimination tournament...")
tournaments = requests.get(
    f"{SUPABASE_URL}/rest/v1/tournaments?bracket_format=eq.double_elimination&order=created_at.desc&limit=1",
    headers=headers
).json()

if not tournaments:
    print("❌ No double elimination tournament found!")
    exit()

tournament = tournaments[0]
tournament_id = tournament['id']
print(f"✅ Found tournament: {tournament['title']}")
print(f"   ID: {tournament_id}")
print(f"   Format: {tournament['bracket_format']}")

# Get all matches
print(f"\n📋 Getting all matches...")
matches = requests.get(
    f"{SUPABASE_URL}/rest/v1/matches?tournament_id=eq.{tournament_id}&order=match_number.asc",
    headers=headers
).json()

print(f"✅ Found {len(matches)} matches\n")

# Group by round
rounds = {}
for match in matches:
    round_num = match['round_number']
    if round_num not in rounds:
        rounds[round_num] = []
    rounds[round_num].append(match)

# Analyze structure
print("=" * 80)
print("TOURNAMENT STRUCTURE ANALYSIS")
print("=" * 80)

for round_num in sorted(rounds.keys()):
    round_matches = rounds[round_num]
    print(f"\n📍 ROUND {round_num}: {len(round_matches)} matches")
    print("-" * 80)
    
    for match in round_matches:
        match_num = match['match_number']
        p1 = match.get('player1_id', 'NULL')[:8] if match.get('player1_id') else 'NULL'
        p2 = match.get('player2_id', 'NULL')[:8] if match.get('player2_id') else 'NULL'
        winner_to = match.get('winner_advances_to') or 'NULL'
        loser_to = match.get('loser_advances_to') or 'NULL'
        
        winner_str = str(winner_to) if winner_to != 'NULL' else 'NULL'
        loser_str = str(loser_to) if loser_to != 'NULL' else 'NULL'
        
        print(f"  Match {match_num:2d}: [{p1}] vs [{p2}] → Winner:{winner_str:>4}, Loser:{loser_str:>4}")

# Check loser bracket structure
print("\n" + "=" * 80)
print("LOSER BRACKET ANALYSIS")
print("=" * 80)

loser_bracket_matches = [m for m in matches if m['match_number'] >= 16 and m['match_number'] <= 30]
print(f"\nLoser Bracket should have matches 16-30 (15 matches)")
print(f"Found: {len(loser_bracket_matches)} matches")

if loser_bracket_matches:
    print("\nLoser Bracket Matches:")
    for match in loser_bracket_matches:
        match_num = match['match_number']
        round_num = match['round_number']
        p1 = match.get('player1_id', 'NULL')[:8] if match.get('player1_id') else 'NULL'
        p2 = match.get('player2_id', 'NULL')[:8] if match.get('player2_id') else 'NULL'
        loser_to = match.get('loser_advances_to', 'NULL')
        
        status = "✅ Has Players" if p1 != 'NULL' or p2 != 'NULL' else "❌ EMPTY"
        print(f"  Match {match_num:2d} (R{round_num}): [{p1}] vs [{p2}] - {status}")

# Check which WB matches feed into LB
print("\n" + "=" * 80)
print("WINNER BRACKET → LOSER BRACKET CONNECTIONS")
print("=" * 80)

wb_matches = [m for m in matches if m['match_number'] <= 15]
print("\nWinner Bracket matches that should send losers to Loser Bracket:")

for match in wb_matches:
    match_num = match['match_number']
    loser_to = match.get('loser_advances_to')
    
    if loser_to:
        print(f"  ✅ Match {match_num:2d} → Loser goes to Match {loser_to}")
    else:
        # Grand Final has no loser_advances_to
        if match_num == 31:
            print(f"  ⚪ Match {match_num:2d} (Grand Final) - No loser advancement (correct)")
        else:
            print(f"  ❌ Match {match_num:2d} → NO loser_advances_to!")

print("\n" + "=" * 80)
