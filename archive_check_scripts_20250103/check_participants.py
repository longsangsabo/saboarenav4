import os
from supabase import create_client, Client

url = "https://mogjjvscxjwvhtpkrlqr.supabase.co"
key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ"

supabase: Client = create_client(url, key)

tournament_id = 'f787eb67-8752-4cc8-ae7b-8b8bd65c7d62'

# Check participants
participants = supabase.table('tournament_participants').select('*').eq('tournament_id', tournament_id).execute()

print(f"📊 Tournament participants: {len(participants.data)}")
if participants.data:
    print("\n✅ Participants found:")
    for p in participants.data[:5]:
        print(f"   - User: {p.get('user_id')}")
else:
    print("\n❌ NO PARTICIPANTS FOUND!")
    print("\n💡 This is why UI shows fallback tabs (VÒNG 1-4) instead of dynamic DE16 tabs!")
    print("   When _totalParticipants = 0, _getAvailableRounds() returns []")
    print("   Then code falls back to hardcoded VÒNG 1-4")

# Get players from matches instead
matches = supabase.table('matches').select('player1_id, player2_id').eq('tournament_id', tournament_id).execute()

player_ids = set()
for match in matches.data:
    if match.get('player1_id'):
        player_ids.add(match['player1_id'])
    if match.get('player2_id'):
        player_ids.add(match['player2_id'])

print(f"\n📊 Unique players in matches: {len(player_ids)}")
print(f"   Player IDs: {list(player_ids)[:3]}...")
