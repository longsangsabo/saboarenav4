import os
from supabase import create_client, Client

url = "https://mogjjvscxjwvhtpkrlqr.supabase.co"
key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ"

supabase: Client = create_client(url, key)

# Get tournament named "sabo1"
tournaments = supabase.table('tournaments').select('*').ilike('title', '%sabo1%').execute()

if not tournaments.data:
    print("❌ Tournament 'sabo1' not found!")
    exit()

tournament = tournaments.data[0]
tournament_id = tournament['id']
print(f"✅ Found tournament '{tournament.get('title')}': {tournament_id}")
print(f"   Format: {tournament.get('format')}")
print(f"   Participants: {tournament.get('max_participants')}")

# Get ALL matches for this tournament
matches = supabase.table('matches').select('id, match_number, round_number, bracket_format').eq('tournament_id', tournament_id).order('round_number').order('match_number').execute()

print(f"\n📋 Total matches: {len(matches.data)}")

# Group by round_number
from collections import defaultdict
rounds = defaultdict(list)
for match in matches.data:
    rounds[match['round_number']].append(match)

print("\n🔍 Rounds breakdown:")
for round_num in sorted(rounds.keys()):
    matches_in_round = rounds[round_num]
    print(f"   Round {round_num}: {len(matches_in_round)} matches")
    print(f"      Match numbers: {[m['match_number'] for m in matches_in_round]}")
    print(f"      Bracket format: {matches_in_round[0].get('bracket_format', 'N/A')}")

# Check if this is a proper DE16 (should have 31 matches)
if len(matches.data) == 31:
    print("\n✅ This is a complete DE16 tournament (31 matches)")
    
    # Check for loser bracket rounds (101-104)
    has_loser_bracket = any(r >= 100 and r < 200 for r in rounds.keys())
    if has_loser_bracket:
        print("✅ Has loser bracket rounds (101-104)")
    else:
        print("❌ MISSING loser bracket rounds! Only has winner bracket.")
else:
    print(f"\n⚠️ Expected 31 matches for DE16, found {len(matches.data)}")
