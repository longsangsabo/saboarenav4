from supabase import create_client

client = create_client(
    'https://mogjjvscxjwvhtpkrlqr.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ'
)

print("🔍 Checking Group A WB R3 matches...")
print("="*80)

result = client.table('matches').select(
    'match_number, display_order, status, winner_id, player1_id, player2_id, winner_advances_to, loser_advances_to'
).eq('tournament_id', '7f0b185e-8d53-4c4b-94da-88d8beb1e62d'
).eq('bracket_group', 'A'
).eq('bracket_type', 'WB'
).eq('stage_round', 3
).order('match_number').execute()

for m in result.data:
    status_icon = "✅" if m['status'] == 'completed' else "⏳"
    has_winner = "✅ Has winner" if m['winner_id'] else "❌ No winner"
    loser_target = f"→ {m['loser_advances_to']}" if m['loser_advances_to'] else "No advancement"
    
    print(f"{status_icon} Match #{m['match_number']} (Display: {m['display_order']})")
    print(f"   Status: {m['status']}")
    print(f"   Winner: {has_winner}")
    print(f"   Loser advances to: {loser_target}")
    print(f"   P1: {m['player1_id'][:8] if m['player1_id'] else 'None'}...")
    print(f"   P2: {m['player2_id'][:8] if m['player2_id'] else 'None'}...")
    print()

# Now check the target LB-A R2 matches
print("\n🔍 Checking Group A LB-A R2 target matches...")
print("="*80)

lb_result = client.table('matches').select(
    'match_number, display_order, status, player1_id, player2_id'
).eq('tournament_id', '7f0b185e-8d53-4c4b-94da-88d8beb1e62d'
).eq('bracket_group', 'A'
).eq('bracket_type', 'LB-A'
).eq('stage_round', 2
).order('match_number').execute()

for m in lb_result.data:
    p1_status = "✅" if m['player1_id'] else "❌ Empty"
    p2_status = "✅" if m['player2_id'] else "❌ Empty"
    
    print(f"Match #{m['match_number']} (Display: {m['display_order']})")
    print(f"   P1: {p1_status}")
    print(f"   P2: {p2_status}")
    print(f"   Status: {m['status']}")
    print()
