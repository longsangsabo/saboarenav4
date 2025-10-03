"""
Fix M20 duplicate user issue - clear player2_id slot
"""
import os
from supabase import create_client

# Initialize Supabase
url = "https://mogjjvscxjwvhtpkrlqr.supabase.co"
key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.kj12qAZbnHmL8MDI3z2TaLDxgDx6KvqJbSw6YwXWCf4"
supabase = create_client(url, key)

def fix_m20():
    """Clear M20 player2_id to allow service to fill it correctly"""
    print("🔧 Fixing M20 duplicate user issue...")
    print("=" * 70)
    
    # Get M20 current state
    m20 = supabase.table('matches').select('*').eq('match_number', 20).single().execute()
    
    print(f"\n📋 M20 BEFORE Fix:")
    print(f"  Player 1 ID: {m20.data['player1_id']}")
    print(f"  Player 2 ID: {m20.data['player2_id']}")
    print(f"  Status: {m20.data['status']}")
    
    # Check if it's actually duplicate
    if m20.data['player1_id'] == m20.data['player2_id']:
        print(f"\n❌ CONFIRMED: Both slots have same user!")
        
        # Clear player2_id slot
        result = supabase.table('matches').update({
            'player2_id': None,
            'status': 'waiting'
        }).eq('match_number', 20).execute()
        
        print(f"\n✅ FIXED: Cleared player2_id slot")
        print(f"  Player 1 ID: {result.data[0]['player1_id']} (Cao Hải - kept)")
        print(f"  Player 2 ID: {result.data[0]['player2_id']} (cleared - waiting for LB-A R1 winner)")
        print(f"  Status: {result.data[0]['status']}")
        
        # Check which LB-A R1 match should fill it
        print(f"\n🔍 Checking source matches:")
        
        # M17
        m17 = supabase.table('matches').select('match_number, winner_id, winner_advances_to').eq('match_number', 17).single().execute()
        print(f"\n  M17: winner_advances_to = {m17.data['winner_advances_to']}")
        if m17.data['winner_advances_to'] == 12202:
            winner = supabase.table('users').select('name').eq('id', m17.data['winner_id']).single().execute()
            print(f"    ✅ Winner: {winner.data['name']} should go to M20!")
        
        # M18
        m18 = supabase.table('matches').select('match_number, winner_id, winner_advances_to').eq('match_number', 18).single().execute()
        print(f"\n  M18: winner_advances_to = {m18.data['winner_advances_to']}")
        if m18.data['winner_advances_to'] == 12202:
            winner = supabase.table('users').select('name').eq('id', m18.data['winner_id']).single().execute()
            print(f"    ✅ Winner: {winner.data['name']} should go to M20!")
        
        print(f"\n💡 Service will auto-fill player2_id when it detects M17/M18 completed!")
        
    else:
        print(f"\n✅ No duplicate found!")

if __name__ == "__main__":
    fix_m20()
