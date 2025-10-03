from supabase import create_client
import json

with open('env.json', 'r') as f:
    env = json.load(f)

client = create_client(env['SUPABASE_URL'], env['SUPABASE_ANON_KEY'])

TOURNAMENT_ID = '7f0b185e-8d53-4c4b-94da-88d8beb1e62d'

print("CHECK LB-A R1 ADVANCEMENT TARGETS")
print("=" * 80)

result = client.table('matches').select('*').eq('tournament_id', TOURNAMENT_ID).in_('match_number', [15,16,17,18,22,23]).execute()

for m in result.data:
    print(f"\nMatch #{m['match_number']} (Display: {m['display_order']})")
    print(f"  Bracket: {m['bracket_type']} R{m['stage_round']}")
    print(f"  Status: {m['status']}")
    print(f"  Winner advances to: {m['winner_advances_to']}")
    print(f"  Loser advances to: {m['loser_advances_to']}")

print("\n" + "=" * 80)
print("CHECK TARGET MATCHES (M19, M20, M24)")
print("=" * 80)

target_result = client.table('matches').select('*').eq('tournament_id', TOURNAMENT_ID).in_('match_number', [19,20,24]).execute()

users_result = client.table('users').select('id, full_name').execute()
users = {u['id']: u['full_name'] for u in users_result.data}

for m in target_result.data:
    p1_name = users.get(m['player1_id'], 'TBD') if m['player1_id'] else 'TBD'
    p2_name = users.get(m['player2_id'], 'TBD') if m['player2_id'] else 'TBD'
    
    print(f"\nMatch #{m['match_number']} (Display: {m['display_order']})")
    print(f"  Bracket: {m['bracket_type']} R{m['stage_round']}")
    print(f"  Player 1: {p1_name}")
    print(f"  Player 2: {p2_name}")
    print(f"  Status: {m['status']}")

print("\n" + "=" * 80)
print("EXPECTED vs ACTUAL")
print("=" * 80)

print("\nEXPECTED:")
print("  M15 winner + M16 winner -> M19 (12201)")
print("  M17 winner + M18 winner -> M20 (12202)")
print("  M22 winner + M23 winner -> M24 (13201)")

print("\nACTUAL:")
print("  M19 has: Dao Giang (from M13 loser) + TBD")
print("  M20 has: Cao Hai (from M14 loser) + TBD")
print("  M24 has: TBD + TBD")

print("\nPROBLEM:")
print("  LB-A R1 winners (M15,M16,M17,M18) NOT advanced!")
print("  LB-B R1 winners (M22,M23) NOT advanced!")
