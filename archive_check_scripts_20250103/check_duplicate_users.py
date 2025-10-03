from supabase import create_client
import json

with open('env.json', 'r') as f:
    env = json.load(f)

client = create_client(env['SUPABASE_URL'], env['SUPABASE_ANON_KEY'])

TOURNAMENT_ID = '7f0b185e-8d53-4c4b-94da-88d8beb1e62d'

print("🔍 KIỂM TRA USER BỊ DUPLICATE TRONG NHIỀU TRẬN")
print("=" * 80)

# Get all users for names
users_result = client.table('users').select('id, full_name').execute()
users = {u['id']: u['full_name'] for u in users_result.data}

# Get all matches with player info
matches = client.table('matches').select('*').eq('tournament_id', TOURNAMENT_ID).order('match_number').execute()

print(f"\n📊 Tổng số matches: {len(matches.data)}")

# Find matches with only 1 player (partial)
partial_matches = []
for match in matches.data:
    p1 = match.get('player1_id')
    p2 = match.get('player2_id')
    
    # Only 1 player present
    if (p1 and not p2) or (p2 and not p1):
        partial_matches.append(match)

print(f"\n⚠️ Matches có 1 player (chờ player 2): {len(partial_matches)}")

# Build user -> matches mapping
user_matches = {}
for match in partial_matches:
    match_num = match['match_number']
    display_order = match['display_order']
    bracket = f"{match.get('bracket_group', 'CROSS')}/{match.get('bracket_type', '?')}/R{match.get('stage_round', '?')}"
    status = match['status']
    
    p1 = match.get('player1_id')
    p2 = match.get('player2_id')
    
    if p1:
        user_matches.setdefault(p1, []).append({
            'match_num': match_num,
            'display_order': display_order,
            'bracket': bracket,
            'status': status,
            'slot': 'P1'
        })
    
    if p2:
        user_matches.setdefault(p2, []).append({
            'match_num': match_num,
            'display_order': display_order,
            'bracket': bracket,
            'status': status,
            'slot': 'P2'
        })

# Find users in multiple partial matches
print("\n" + "=" * 80)
print("🚨 USERS XUẤT HIỆN TRONG NHIỀU TRẬN (CHƯA ĐỦ 2 NGƯỜI)")
print("=" * 80)

duplicates_found = False
for user_id, match_list in user_matches.items():
    if len(match_list) > 1:
        duplicates_found = True
        user_name = users.get(user_id, 'Unknown')
        
        print(f"\n❌ USER: {user_name} (ID: {user_id[:8]}...)")
        print(f"   Xuất hiện trong {len(match_list)} trận:")
        
        for i, match_info in enumerate(match_list, 1):
            print(f"   {i}. Match #{match_info['match_num']} (Display: {match_info['display_order']})")
            print(f"      Bracket: {match_info['bracket']}")
            print(f"      Slot: {match_info['slot']}")
            print(f"      Status: {match_info['status']}")

if not duplicates_found:
    print("\n✅ KHÔNG CÓ USER NÀO BỊ DUPLICATE!")
    print("   Mỗi user chỉ xuất hiện trong 1 trận chờ player 2")

# Show summary of partial matches
print("\n" + "=" * 80)
print("📋 CHI TIẾT CÁC TRẬN ĐANG CHỜ PLAYER 2")
print("=" * 80)

for match in partial_matches:
    match_num = match['match_number']
    display_order = match['display_order']
    bracket = f"{match.get('bracket_group', 'CROSS')}/{match.get('bracket_type', '?')}/R{match.get('stage_round', '?')}"
    
    p1 = match.get('player1_id')
    p2 = match.get('player2_id')
    
    p1_name = users.get(p1, 'TBD') if p1 else 'TBD'
    p2_name = users.get(p2, 'TBD') if p2 else 'TBD'
    
    print(f"\n  M{match_num} (Display: {display_order}) - {bracket}")
    print(f"    P1: {p1_name[:30]:<30} | P2: {p2_name[:30]:<30}")

print("\n" + "=" * 80)
