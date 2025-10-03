"""
Verify M20 fix - Check if duplicate user issue is resolved
"""
import os
from supabase import create_client

# Initialize Supabase
url = "https://mogjjvscxjwvhtpkrlqr.supabase.co"
key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ"
supabase = create_client(url, key)

def verify_m20():
    """Verify M20 has been fixed"""
    print("🔍 KIỂM TRA M20 SAU KHI FIX")
    print("=" * 70)
    
    # Get M20 current state
    m20 = supabase.table('matches').select('*').eq('match_number', 20).single().execute()
    
    print(f"\n📋 Match #20 Details:")
    print(f"  Display Order: {m20.data['display_order']}")
    print(f"  Bracket: {m20.data['bracket_type']} R{m20.data['stage_round']}")
    print(f"  Player 1 ID: {m20.data['player1_id']}")
    print(f"  Player 2 ID: {m20.data['player2_id']}")
    print(f"  Status: {m20.data['status']}")
    
    # Get player names
    if m20.data['player1_id']:
        p1 = supabase.table('users').select('full_name').eq('id', m20.data['player1_id']).single().execute()
        print(f"\n👤 Player 1: {p1.data['full_name']}")
    else:
        print(f"\n👤 Player 1: NULL (chưa có)")
    
    if m20.data['player2_id']:
        p2 = supabase.table('users').select('full_name').eq('id', m20.data['player2_id']).single().execute()
        print(f"👤 Player 2: {p2.data['full_name']}")
    else:
        print(f"👤 Player 2: NULL (chưa có)")
    
    # Check if duplicate exists
    if m20.data['player1_id'] and m20.data['player2_id']:
        if m20.data['player1_id'] == m20.data['player2_id']:
            print(f"\n❌ VẪN CÒN LỖI: Cùng user ở cả 2 slots!")
        else:
            print(f"\n✅ ĐÃ FIX: 2 players khác nhau!")
    elif m20.data['player1_id'] and not m20.data['player2_id']:
        print(f"\n⏳ Đang chờ: Player 2 slot trống (service sẽ tự động fill)")
    elif not m20.data['player1_id'] and m20.data['player2_id']:
        print(f"\n⏳ Đang chờ: Player 1 slot trống (service sẽ tự động fill)")
    else:
        print(f"\n⚠️ Cả 2 slots đều trống!")
    
    # Check source matches
    print(f"\n🔍 Kiểm tra source matches:")
    
    # M14 (WB R3 loser should go to M20)
    m14 = supabase.table('matches').select('match_number, player1_id, player2_id, winner_id, loser_advances_to, status').eq('match_number', 14).single().execute()
    print(f"\n  M14 (WB R3):")
    print(f"    Status: {m14.data['status']}")
    print(f"    loser_advances_to: {m14.data['loser_advances_to']}")
    if m14.data['status'] == 'completed' and m14.data['winner_id']:
        loser_id = m14.data['player2_id'] if m14.data['winner_id'] == m14.data['player1_id'] else m14.data['player1_id']
        loser = supabase.table('users').select('full_name').eq('id', loser_id).single().execute()
        print(f"    Loser: {loser.data['full_name']} → Should go to M20!")
    
    # M17 (LB-A R1 winner should go to M20)
    m17 = supabase.table('matches').select('match_number, winner_id, winner_advances_to, status').eq('match_number', 17).single().execute()
    print(f"\n  M17 (LB-A R1):")
    print(f"    Status: {m17.data['status']}")
    print(f"    winner_advances_to: {m17.data['winner_advances_to']}")
    if m17.data['status'] == 'completed' and m17.data['winner_id']:
        winner = supabase.table('users').select('full_name').eq('id', m17.data['winner_id']).single().execute()
        print(f"    Winner: {winner.data['full_name']} → Should go to M20!")
    
    # M18 (LB-A R1 winner should go to M20)
    m18 = supabase.table('matches').select('match_number, winner_id, winner_advances_to, status').eq('match_number', 18).single().execute()
    print(f"\n  M18 (LB-A R1):")
    print(f"    Status: {m18.data['status']}")
    print(f"    winner_advances_to: {m18.data['winner_advances_to']}")
    if m18.data['status'] == 'completed' and m18.data['winner_id']:
        winner = supabase.table('users').select('full_name').eq('id', m18.data['winner_id']).single().execute()
        print(f"    Winner: {winner.data['full_name']} → Should go to M20!")
    
    print(f"\n" + "=" * 70)

if __name__ == "__main__":
    verify_m20()
