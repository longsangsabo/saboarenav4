from supabase import create_client
import json

with open('env.json', 'r') as f:
    env = json.load(f)

client = create_client(env['SUPABASE_URL'], env['SUPABASE_ANON_KEY'])

TOURNAMENT_ID = '7f0b185e-8d53-4c4b-94da-88d8beb1e62d'

print("🚨 KIỂM TRA MATCH M20 - DUPLICATE USER ISSUE")
print("=" * 80)

# Get M20 details
m20 = client.table('matches').select('*').eq('tournament_id', TOURNAMENT_ID).eq('match_number', 20).single().execute()

print("\n📋 Match #20 Details:")
print(f"  Display Order: {m20.data['display_order']}")
print(f"  Bracket: {m20.data['bracket_type']} R{m20.data['stage_round']}")
print(f"  Player 1 ID: {m20.data['player1_id']}")
print(f"  Player 2 ID: {m20.data['player2_id']}")
print(f"  Status: {m20.data['status']}")

# Get user names
users_result = client.table('users').select('id, full_name').execute()
users = {u['id']: u['full_name'] for u in users_result.data}

p1_name = users.get(m20.data['player1_id'], 'Unknown')
p2_name = users.get(m20.data['player2_id'], 'Unknown')

print(f"\n👥 Players:")
print(f"  Player 1: {p1_name}")
print(f"  Player 2: {p2_name}")

if m20.data['player1_id'] == m20.data['player2_id']:
    print("\n❌ LỖI NGHIÊM TRỌNG: Cùng user ở cả 2 slots!")
else:
    print("\n✅ OK: 2 users khác nhau")

# Check source matches
print("\n" + "=" * 80)
print("🔍 TRACING SOURCE MATCHES (WHO SHOULD BE IN M20?)")
print("=" * 80)

# M20 (12202) should get:
# - Loser from M14 (WB R3) via loser_advances_to = 12202
# - Winner from M17 or M18 (LB-A R1) via winner_advances_to = 12202

# Check M14 (WB R3)
m14 = client.table('matches').select('*').eq('tournament_id', TOURNAMENT_ID).eq('match_number', 14).single().execute()
m14_winner = m14.data['winner_id']
m14_p1 = m14.data['player1_id']
m14_p2 = m14.data['player2_id']
m14_loser = m14_p1 if m14_winner == m14_p2 else m14_p2

print(f"\n📍 M14 (WB R3 Group A) - Display: {m14.data['display_order']}")
print(f"  P1: {users.get(m14_p1, 'Unknown')}")
print(f"  P2: {users.get(m14_p2, 'Unknown')}")
print(f"  Winner: {users.get(m14_winner, 'Unknown')}")
print(f"  Loser: {users.get(m14_loser, 'Unknown')} ← Should go to M20!")
print(f"  loser_advances_to: {m14.data['loser_advances_to']}")

# Check M17, M18 (LB-A R1)
m17 = client.table('matches').select('*').eq('tournament_id', TOURNAMENT_ID).eq('match_number', 17).single().execute()
m18 = client.table('matches').select('*').eq('tournament_id', TOURNAMENT_ID).eq('match_number', 18).single().execute()

print(f"\n📍 M17 (LB-A R1 Group A) - Display: {m17.data['display_order']}")
print(f"  Winner: {users.get(m17.data['winner_id'], 'Unknown')}")
print(f"  winner_advances_to: {m17.data['winner_advances_to']}")
if m17.data['winner_advances_to'] == 12202:
    print(f"  ✅ Should go to M20!")

print(f"\n📍 M18 (LB-A R1 Group A) - Display: {m18.data['display_order']}")
print(f"  Winner: {users.get(m18.data['winner_id'], 'Unknown')}")
print(f"  winner_advances_to: {m18.data['winner_advances_to']}")
if m18.data['winner_advances_to'] == 12202:
    print(f"  ✅ Should go to M20!")

print("\n" + "=" * 80)
print("📊 EXPECTED vs ACTUAL")
print("=" * 80)

print(f"\nEXPECTED M20 players:")
print(f"  Slot 1: {users.get(m14_loser, 'Unknown')} (from M14 loser)")
print(f"  Slot 2: {users.get(m17.data['winner_id'], 'Unknown')} or {users.get(m18.data['winner_id'], 'Unknown')} (from M17/M18 winner)")

print(f"\nACTUAL M20 players:")
print(f"  Slot 1: {p1_name} (ID: {m20.data['player1_id']})")
print(f"  Slot 2: {p2_name} (ID: {m20.data['player2_id']})")

print("\n" + "=" * 80)
