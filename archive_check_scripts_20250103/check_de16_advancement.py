from supabase import create_client

# Connect to Supabase
client = create_client(
    'https://mogjjvscxjwvhtpkrlqr.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ'
)

# Get matches from tournament
response = client.table('matches').select('*').eq('tournament_id', '9fa6079c-68c1-4ef8-9801-2eb9ccb90435').order('match_number').execute()
matches = response.data

print('\n' + '='*80)
print('DE16 TOURNAMENT STRUCTURE ANALYSIS')
print('='*80)

# Group by round
wb_r1 = [m for m in matches if m['round_number'] == 1]
wb_r2 = [m for m in matches if m['round_number'] == 2]
wb_r3 = [m for m in matches if m['round_number'] == 3]
wb_r4 = [m for m in matches if m['round_number'] == 4]
lb_r1 = [m for m in matches if m['round_number'] == 101]
lb_r2 = [m for m in matches if m['round_number'] == 102]
lb_r3 = [m for m in matches if m['round_number'] == 103]
lb_r4 = [m for m in matches if m['round_number'] == 104]
gf = [m for m in matches if m['round_number'] == 999]

print(f'\n📊 MATCH COUNT BY ROUND:')
print(f'WB R1 (round_number=1):   {len(wb_r1)} matches')
print(f'WB R2 (round_number=2):   {len(wb_r2)} matches')
print(f'WB R3 (round_number=3):   {len(wb_r3)} matches')
print(f'WB R4 (round_number=4):   {len(wb_r4)} matches')
print(f'LB R1 (round_number=101): {len(lb_r1)} matches')
print(f'LB R2 (round_number=102): {len(lb_r2)} matches')
print(f'LB R3 (round_number=103): {len(lb_r3)} matches')
print(f'LB R4 (round_number=104): {len(lb_r4)} matches')
print(f'GF    (round_number=999): {len(gf)} matches')

print(f'\n🎯 LOSER BRACKET R1 (BẢNG THUA A1) - Matches 16-23:')
for m in lb_r1:
    p1 = '✅' if m['player1_id'] else '❌'
    p2 = '✅' if m['player2_id'] else '❌'
    winner = '✅' if m['winner_id'] else '⏳'
    print(f"  M{m['match_number']:2d}: P1={p1} P2={p2} Winner={winner} → W:{m['winner_advances_to']} L:{m['loser_advances_to']}")

print(f'\n🎯 WINNER BRACKET R1 - Check losers going to LB:')
for m in wb_r1:
    winner = '✅' if m['winner_id'] else '⏳'
    status = m['status']
    print(f"  M{m['match_number']:2d}: Status={status:12s} Winner={winner} → W:{m['winner_advances_to']} L:{m['loser_advances_to']}")

print(f'\n🔍 COMPLETED WB R1 MATCHES:')
completed_wb_r1 = [m for m in wb_r1 if m['winner_id']]
print(f"  Total completed: {len(completed_wb_r1)}")
for m in completed_wb_r1:
    loser_id = m['player2_id'] if m['winner_id'] == m['player1_id'] else m['player1_id']
    loser_target = m['loser_advances_to']
    print(f"  M{m['match_number']:2d}: Winner={m['winner_id'][:8]}... Loser={loser_id[:8] if loser_id else 'N/A'}... → Should go to M{loser_target}")
    
    # Check if loser was advanced
    if loser_target and loser_id:
        target_match = next((tm for tm in lb_r1 if tm['match_number'] == loser_target), None)
        if target_match:
            has_loser = loser_id in [target_match['player1_id'], target_match['player2_id']]
            print(f"       Target M{loser_target}: P1={target_match['player1_id'][:8] if target_match['player1_id'] else 'None'} P2={target_match['player2_id'][:8] if target_match['player2_id'] else 'None'} HasLoser={'✅' if has_loser else '❌'}")

print('\n' + '='*80)
