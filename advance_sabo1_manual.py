"""
Manually advance sabo1 tournament winners to Round 2
"""
import os
import sys

try:
    from supabase import create_client, Client
except ImportError:
    print("Installing supabase...")
    os.system("pip install supabase")
    from supabase import create_client, Client

def main():
    # Initialize Supabase client
    url = "https://mogjjvscxjwvhtpkrlqr.supabase.co"
    key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ"
    
    supabase: Client = create_client(url, key)
    
    print("🚀 Manually advancing sabo1 tournament to Round 2...")
    
    # Find sabo1 tournament
    tournament_result = supabase.table('tournaments').select('*').ilike('title', '%sabo1%').execute()
    tournament = tournament_result.data[0]
    tournament_id = tournament['id']
    
    # Get Round 1 matches with winners
    matches_result = supabase.table('matches').select('*').eq('tournament_id', tournament_id).eq('round_number', 1).order('match_number').execute()
    round1_matches = matches_result.data
    
    print(f"✅ Found {len(round1_matches)} Round 1 matches")
    
    # Extract winners in order
    winners = []
    for match in round1_matches:
        if match['winner_id']:
            winners.append({
                'match_number': match['match_number'],
                'winner_id': match['winner_id']
            })
    
    print(f"🏆 Found {len(winners)} winners:")
    for winner in winners:
        print(f"   M{winner['match_number']}: {winner['winner_id'][:8]}")
    
    # Advance pairs to Round 2
    print(f"\n🔄 Advancing to Round 2...")
    
    # Single elimination pairing: M1 winner vs M2 winner → M9, M3 vs M4 → M10, etc.
    for i in range(0, len(winners), 2):
        if i + 1 < len(winners):
            winner1 = winners[i]
            winner2 = winners[i + 1]
            
            round2_match_number = 9 + (i // 2)  # M9, M10, M11, M12
            
            print(f"   M{winner1['match_number']} winner vs M{winner2['match_number']} winner → M{round2_match_number}")
            
            try:
                # Update Round 2 match
                update_result = supabase.table('matches').update({
                    'player1_id': winner1['winner_id'],
                    'player2_id': winner2['winner_id'],
                    'status': 'pending'
                }).eq('tournament_id', tournament_id).eq('round_number', 2).eq('match_number', round2_match_number).execute()
                
                print(f"     ✅ Updated M{round2_match_number}")
                
            except Exception as e:
                print(f"     ❌ Error updating M{round2_match_number}: {e}")
    
    print(f"\n🎉 Tournament advancement completed!")
    print(f"   Check the app - Round 2 should now show the winners from Round 1")

if __name__ == "__main__":
    main()