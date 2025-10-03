from supabase import create_client, Client
import json

# Load credentials from env.json
with open('env.json', 'r') as f:
    env = json.load(f)

url: str = env.get("SUPABASE_URL")
key: str = env.get("SUPABASE_ANON_KEY")
client: Client = create_client(url, key)

TOURNAMENT_ID = '7f0b185e-8d53-4c4b-94da-88d8beb1e62d'  # haha1

print("🔍 KIỂM TRA USER ADVANCEMENT CHI TIẾT")
print("=" * 80)

# Get all users for reference
users_result = client.table('users').select('id, full_name').execute()
profiles = {p['id']: p['full_name'] for p in users_result.data}

# Get all matches ordered by bracket and round
matches = client.table('matches').select('*').eq('tournament_id', TOURNAMENT_ID).order('match_number').execute()

print(f"\n📊 Tổng số matches: {len(matches.data)}")

# Group matches by bracket_type and stage_round
from collections import defaultdict
brackets = defaultdict(lambda: defaultdict(list))

for match in matches.data:
    bracket_group = match.get('bracket_group') or 'CROSS/GF'
    bracket_type = match.get('bracket_type', 'Unknown')
    stage_round = match.get('stage_round', 0)
    brackets[bracket_group][f"{bracket_type}-R{stage_round}"].append(match)

# Check advancement logic for each completed match
print("\n" + "=" * 80)
print("🎯 KIỂM TRA ADVANCEMENT CHI TIẾT")
print("=" * 80)

errors_found = []

for bracket_group in sorted(brackets.keys()):
    print(f"\n{'='*80}")
    print(f"📁 GROUP: {bracket_group}")
    print(f"{'='*80}")
    
    for bracket_round in sorted(brackets[bracket_group].keys()):
        matches_in_round = brackets[bracket_group][bracket_round]
        
        print(f"\n🔸 {bracket_round} ({len(matches_in_round)} matches)")
        print("-" * 80)
        
        for match in matches_in_round:
            match_num = match['match_number']
            display_order = match['display_order']
            status = match['status']
            
            p1_id = match.get('player1_id')
            p2_id = match.get('player2_id')
            winner_id = match.get('winner_id')
            
            p1_name = profiles.get(p1_id, 'TBD') if p1_id else 'TBD'
            p2_name = profiles.get(p2_id, 'TBD') if p2_id else 'TBD'
            winner_name = profiles.get(winner_id, 'None') if winner_id else 'None'
            
            print(f"\n  Match #{match_num} (Display: {display_order}) - Status: {status}")
            print(f"    P1: {p1_name[:20]:<20} | P2: {p2_name[:20]:<20}")
            print(f"    Winner: {winner_name[:20]:<20}")
            
            if status == 'completed' and winner_id:
                # Check winner advancement
                winner_advances = match.get('winner_advances_to')
                loser_advances = match.get('loser_advances_to')
                
                # Determine loser_id
                if winner_id == p1_id:
                    loser_id = p2_id
                elif winner_id == p2_id:
                    loser_id = p1_id
                else:
                    loser_id = None
                    errors_found.append(f"❌ M{match_num}: Winner ID không khớp với P1 hoặc P2!")
                
                loser_name = profiles.get(loser_id, 'None') if loser_id else 'None'
                
                print(f"    Loser: {loser_name[:20]:<20}")
                print(f"    Winner advances to: {winner_advances or 'NULL (Elimination)'}")
                print(f"    Loser advances to: {loser_advances or 'NULL (Elimination)'}")
                
                # Check if winner actually advanced
                if winner_advances:
                    target_match = client.table('matches').select('*').eq('tournament_id', TOURNAMENT_ID).eq('display_order', winner_advances).execute()
                    
                    if target_match.data:
                        target = target_match.data[0]
                        target_p1 = target.get('player1_id')
                        target_p2 = target.get('player2_id')
                        
                        if winner_id in [target_p1, target_p2]:
                            print(f"    ✅ Winner đã advance đúng vào M{target['match_number']}")
                        else:
                            error_msg = f"❌ M{match_num}: Winner {winner_name} KHÔNG có trong target match M{target['match_number']}!"
                            print(f"    {error_msg}")
                            errors_found.append(error_msg)
                            
                            # Show who is in target match instead
                            target_p1_name = profiles.get(target_p1, 'TBD') if target_p1 else 'TBD'
                            target_p2_name = profiles.get(target_p2, 'TBD') if target_p2 else 'TBD'
                            print(f"      Target match có: {target_p1_name} vs {target_p2_name}")
                    else:
                        error_msg = f"❌ M{match_num}: Target match {winner_advances} KHÔNG TỒN TẠI!"
                        print(f"    {error_msg}")
                        errors_found.append(error_msg)
                
                # Check if loser actually advanced
                if loser_advances and loser_id:
                    target_match = client.table('matches').select('*').eq('tournament_id', TOURNAMENT_ID).eq('display_order', loser_advances).execute()
                    
                    if target_match.data:
                        target = target_match.data[0]
                        target_p1 = target.get('player1_id')
                        target_p2 = target.get('player2_id')
                        
                        if loser_id in [target_p1, target_p2]:
                            print(f"    ✅ Loser đã advance đúng vào M{target['match_number']}")
                        else:
                            error_msg = f"❌ M{match_num}: Loser {loser_name} KHÔNG có trong target match M{target['match_number']}!"
                            print(f"    {error_msg}")
                            errors_found.append(error_msg)
                            
                            # Show who is in target match instead
                            target_p1_name = profiles.get(target_p1, 'TBD') if target_p1 else 'TBD'
                            target_p2_name = profiles.get(target_p2, 'TBD') if target_p2 else 'TBD'
                            print(f"      Target match có: {target_p1_name} vs {target_p2_name}")
                    else:
                        error_msg = f"❌ M{match_num}: Target match {loser_advances} KHÔNG TỒN TẠI!"
                        print(f"    {error_msg}")
                        errors_found.append(error_msg)

print("\n" + "=" * 80)
print("📋 TÓM TẮT")
print("=" * 80)

if errors_found:
    print(f"\n❌ Tìm thấy {len(errors_found)} LỖI:")
    for i, error in enumerate(errors_found, 1):
        print(f"  {i}. {error}")
else:
    print("\n✅ KHÔNG CÓ LỖI! Tất cả advancement đều đúng!")

print("\n" + "=" * 80)
