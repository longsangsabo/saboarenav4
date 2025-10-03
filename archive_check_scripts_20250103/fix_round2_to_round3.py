"""
Fix Round 2 winners and advance to Round 3
"""
import os
import sys
import random

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
    
    print("🔧 Fixing Round 2 winners and advancing to Round 3...")
    
    # Find sabo1 tournament
    tournament_result = supabase.table('tournaments').select('*').ilike('title', '%sabo1%').execute()
    tournament = tournament_result.data[0]
    tournament_id = tournament['id']
    
    # Get Round 2 matches that are completed but have no winner
    matches_result = supabase.table('matches').select('*').eq('tournament_id', tournament_id).eq('round_number', 2).eq('status', 'completed').is_('winner_id', 'null').execute()
    
    completed_matches = matches_result.data
    print(f"🔍 Found {len(completed_matches)} completed Round 2 matches without winners")
    
    if completed_matches:
        print("\n🎲 Setting random winners for Round 2 matches...")
        
        winners = []
        
        for match in completed_matches:
            match_id = match['id']
            match_number = match['match_number']
            player1_id = match['player1_id']
            player2_id = match['player2_id']
            
            if not player1_id or not player2_id:
                print(f"⚠️ M{match_number}: Missing players, skipping")
                continue
            
            # Randomly choose winner
            winner_id = random.choice([player1_id, player2_id])
            
            # Get player names for display
            try:
                p1_result = supabase.table('user_profiles').select('username').eq('id', player1_id).execute()
                p2_result = supabase.table('user_profiles').select('username').eq('id', player2_id).execute()
                w_result = supabase.table('user_profiles').select('username').eq('id', winner_id).execute()
                
                p1_name = p1_result.data[0]['username'] if p1_result.data else f"User({player1_id[:8]})"
                p2_name = p2_result.data[0]['username'] if p2_result.data else f"User({player2_id[:8]})"
                w_name = w_result.data[0]['username'] if w_result.data else f"Winner({winner_id[:8]})"
                
            except:
                p1_name = f"User({player1_id[:8]})"
                p2_name = f"User({player2_id[:8]})"
                w_name = f"Winner({winner_id[:8]})"
            
            print(f"   M{match_number}: {p1_name} vs {p2_name} → Winner: {w_name}")
            
            # Update match with winner
            try:
                update_result = supabase.table('matches').update({
                    'winner_id': winner_id,
                    'player1_score': 3 if winner_id == player1_id else 1,
                    'player2_score': 1 if winner_id == player1_id else 3,
                }).eq('id', match_id).execute()
                
                winners.append({
                    'match_id': match_id,
                    'match_number': match_number,
                    'winner_id': winner_id,
                    'winner_name': w_name
                })
                
            except Exception as e:
                print(f"❌ Error updating M{match_number}: {e}")
        
        print(f"\n✅ Updated {len(winners)} Round 2 matches with winners")
        
        # Now advance winners to Round 3
        print("\n🚀 Advancing winners to Round 3...")
        
        # Sort winners by match number to ensure correct pairing
        winners.sort(key=lambda x: x['match_number'])
        
        # For single elimination: M9,M10 winners → M13, M11,M12 winners → M14
        for i in range(0, len(winners), 2):
            if i + 1 < len(winners):
                winner1 = winners[i]
                winner2 = winners[i + 1]
                
                # Calculate next round match number
                next_match_number = 13 + (i // 2)  # M13, M14
                
                print(f"   Advancing {winner1['winner_name']} and {winner2['winner_name']} to Round 3 Match {next_match_number}")
                
                try:
                    # Update the Round 3 match with both winners
                    update_result = supabase.table('matches').update({
                        'player1_id': winner1['winner_id'],
                        'player2_id': winner2['winner_id'],
                        'status': 'pending'
                    }).eq('tournament_id', tournament_id).eq('round_number', 3).eq('match_number', next_match_number).execute()
                    
                    print(f"     ✅ Updated M{next_match_number}")
                    
                except Exception as e:
                    print(f"     ❌ Error updating M{next_match_number}: {e}")
    
    else:
        print("✅ Round 2 matches already have winners, checking Round 3...")
        
        # Get Round 2 winners and advance them to Round 3
        round2_matches = supabase.table('matches').select('*').eq('tournament_id', tournament_id).eq('round_number', 2).order('match_number').execute()
        
        winners = []
        for match in round2_matches.data:
            if match['winner_id']:
                try:
                    w_result = supabase.table('user_profiles').select('username').eq('id', match['winner_id']).execute()
                    w_name = w_result.data[0]['username'] if w_result.data else f"Winner({match['winner_id'][:8]})"
                except:
                    w_name = f"Winner({match['winner_id'][:8]})"
                
                winners.append({
                    'match_number': match['match_number'],
                    'winner_id': match['winner_id'],
                    'winner_name': w_name
                })
        
        print(f"🏆 Found {len(winners)} Round 2 winners to advance")
        
        # Advance to Round 3
        for i in range(0, len(winners), 2):
            if i + 1 < len(winners):
                winner1 = winners[i]
                winner2 = winners[i + 1]
                
                next_match_number = 13 + (i // 2)
                
                print(f"   Advancing {winner1['winner_name']} and {winner2['winner_name']} to Round 3 Match {next_match_number}")
                
                try:
                    update_result = supabase.table('matches').update({
                        'player1_id': winner1['winner_id'],
                        'player2_id': winner2['winner_id'],
                        'status': 'pending'
                    }).eq('tournament_id', tournament_id).eq('round_number', 3).eq('match_number', next_match_number).execute()
                    
                    print(f"     ✅ Updated M{next_match_number}")
                    
                except Exception as e:
                    print(f"     ❌ Error updating M{next_match_number}: {e}")
    
    print(f"\n🎉 Tournament fix completed!")
    print(f"   Round 2 matches now have winners")
    print(f"   Winners have been advanced to Round 3")

if __name__ == "__main__":
    main()