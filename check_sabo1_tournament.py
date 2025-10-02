"""
Check sabo1 tournament status and fix advancement issues
"""
import os
import sys

# Add the project root to Python path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

try:
    from supabase import create_client, Client
except ImportError:
    print("Installing supabase...")
    os.system("pip install supabase")
    from supabase import create_client, Client

def main():
    # Initialize Supabase client
    url = "https://mogjjvscxjwvhtpkrlqr.supabase.co"
    # Use anon key instead of service role
    key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ"
    
    supabase: Client = create_client(url, key)
    
    print("🔍 Checking sabo1 tournament...")
    
    # 1. Check tournament info - search by title containing 'sabo'
    try:
        tournament_result = supabase.table('tournaments').select('*').ilike('title', '%sabo%').execute()
        if tournament_result.data:
            print(f"✅ Found {len(tournament_result.data)} tournaments with 'sabo' in title:")
            tournament = None
            for t in tournament_result.data:
                print(f"   - ID: {t.get('id')}")
                print(f"     Title: {t.get('title')}")
                print(f"     Format: {t.get('format')}")
                print(f"     Status: {t.get('status')}")
                if 'sabo1' in t.get('title', '').lower():
                    tournament = t
                    tournament_id = t.get('id')
                    print(f"     ⭐ This looks like sabo1!")
                print()
            
            if not tournament:
                print("No tournament with 'sabo1' in title found")
                return
        else:
            print("❌ No tournaments with 'sabo' found")
            return
    except Exception as e:
        print(f"❌ Error fetching tournament: {e}")
        return
    
    # 2. Check matches
    try:
        matches_result = supabase.table('matches').select('*').eq('tournament_id', tournament_id).order('round_number').order('match_number').execute()
        matches = matches_result.data
        
        print(f"\n📊 Found {len(matches)} matches:")
        
        round_groups = {}
        for match in matches:
            round_num = match.get('round_number', 'Unknown')
            if round_num not in round_groups:
                round_groups[round_num] = []
            round_groups[round_num].append(match)
        
        for round_num in sorted(round_groups.keys()):
            round_matches = round_groups[round_num]
            print(f"\n🔄 Round {round_num}:")
            
            for match in round_matches:
                match_id = match.get('id', 'Unknown')
                match_num = match.get('match_number', 'Unknown')
                player1_id = match.get('player1_id')
                player2_id = match.get('player2_id')
                winner_id = match.get('winner_id')
                status = match.get('status', 'pending')
                
                # Get player usernames
                player1_name = "TBD"
                player2_name = "TBD"
                winner_name = "No winner"
                
                if player1_id:
                    try:
                        p1_result = supabase.table('user_profiles').select('username').eq('id', player1_id).execute()
                        if p1_result.data:
                            player1_name = p1_result.data[0]['username']
                    except:
                        player1_name = f"User({player1_id[:8]})"
                
                if player2_id:
                    try:
                        p2_result = supabase.table('user_profiles').select('username').eq('id', player2_id).execute()
                        if p2_result.data:
                            player2_name = p2_result.data[0]['username']
                    except:
                        player2_name = f"User({player2_id[:8]})"
                
                if winner_id:
                    try:
                        w_result = supabase.table('user_profiles').select('username').eq('id', winner_id).execute()
                        if w_result.data:
                            winner_name = w_result.data[0]['username']
                    except:
                        winner_name = f"Winner({winner_id[:8]})"
                
                print(f"   M{match_num}: {player1_name} vs {player2_name} | Winner: {winner_name} | Status: {status}")
        
        # 3. Analyze the issue
        print(f"\n🔍 Analysis:")
        
        round_1_matches = round_groups.get(1, [])
        round_2_matches = round_groups.get(2, [])
        
        print(f"   Round 1: {len(round_1_matches)} matches")
        completed_r1 = [m for m in round_1_matches if m.get('status') == 'completed' and m.get('winner_id')]
        print(f"   Round 1 completed: {len(completed_r1)}/{len(round_1_matches)}")
        
        print(f"   Round 2: {len(round_2_matches)} matches") 
        r2_with_players = [m for m in round_2_matches if m.get('player1_id') or m.get('player2_id')]
        print(f"   Round 2 with players: {len(r2_with_players)}/{len(round_2_matches)}")
        
        if len(completed_r1) > 0 and len(r2_with_players) == 0:
            print("\n⚠️ ISSUE FOUND: Round 1 has completed matches but Round 2 players not advanced!")
            print("   This suggests the advancement logic is not working properly.")
            
            print("\n🔧 Potential fixes:")
            print("   1. Check if tournament format is correctly set to 'single_elimination'")
            print("   2. Manually advance winners using match progression service")
            print("   3. Check if updateMatchResult function was called properly")
        
        elif len(completed_r1) == 0:
            print("\n⚠️ ISSUE: No Round 1 matches are completed yet")
            print("   Players need to finish Round 1 matches first")
        
        else:
            print("\n✅ Tournament progression looks normal")
            
    except Exception as e:
        print(f"❌ Error fetching matches: {e}")

if __name__ == "__main__":
    main()