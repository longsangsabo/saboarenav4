"""
Test Auto Tournament Progression System
Complete a match and see if winners auto-advance
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
    
    print("🧪 Testing Auto Tournament Progression System")
    print("=" * 50)
    
    # Find sabo1 tournament
    tournament_result = supabase.table('tournaments').select('*').ilike('title', '%sabo1%').execute()
    tournament = tournament_result.data[0]
    tournament_id = tournament['id']
    
    print(f"✅ Testing tournament: {tournament['title']}")
    
    # Find a Round 3 match that's pending to complete
    round3_matches = supabase.table('matches').select('*').eq('tournament_id', tournament_id).eq('round_number', 3).eq('status', 'pending').execute()
    
    if not round3_matches.data:
        print("❌ No pending Round 3 matches to test")
        return
    
    test_match = round3_matches.data[0]
    match_id = test_match['id']
    match_number = test_match['match_number']
    player1_id = test_match['player1_id']
    player2_id = test_match['player2_id']
    
    if not player1_id or not player2_id:
        print(f"❌ Match M{match_number} missing players")
        return
    
    # Get player names
    try:
        p1_result = supabase.table('user_profiles').select('username').eq('id', player1_id).execute()
        p2_result = supabase.table('user_profiles').select('username').eq('id', player2_id).execute()
        
        p1_name = p1_result.data[0]['username'] if p1_result.data else f"Player({player1_id[:8]})"
        p2_name = p2_result.data[0]['username'] if p2_result.data else f"Player({player2_id[:8]})"
    except:
        p1_name = f"Player({player1_id[:8]})"
        p2_name = f"Player({player2_id[:8]})"
    
    print(f"\n🎯 Testing Match M{match_number}: {p1_name} vs {p2_name}")
    
    # Randomly choose winner
    winner_id = random.choice([player1_id, player2_id])
    winner_name = p1_name if winner_id == player1_id else p2_name
    
    print(f"🏆 Setting winner: {winner_name}")
    
    # Check Round 4 (Finals) before update
    print("\n📊 Round 4 status BEFORE:")
    finals_before = supabase.table('matches').select('*').eq('tournament_id', tournament_id).eq('round_number', 4).execute()
    for match in finals_before.data:
        p1_status = "✅" if match['player1_id'] else "❌"
        p2_status = "✅" if match['player2_id'] else "❌" 
        print(f"   M{match['match_number']}: Player1 {p1_status} | Player2 {p2_status} | Status: {match['status']}")
    
    # Complete the match (this should trigger auto-advancement)
    print(f"\n🚀 Completing match M{match_number}...")
    
    try:
        update_result = supabase.table('matches').update({
            'status': 'completed',
            'winner_id': winner_id,
            'player1_score': 3 if winner_id == player1_id else 1,
            'player2_score': 1 if winner_id == player1_id else 3,
            'completed_at': 'now()'
        }).eq('id', match_id).execute()
        
        print("✅ Match completed successfully")
        
        # Wait a moment for potential auto-progression
        import time
        print("⏳ Waiting for auto-progression...")
        time.sleep(3)
        
        # Check Round 4 status AFTER
        print("\n📊 Round 4 status AFTER:")
        finals_after = supabase.table('matches').select('*').eq('tournament_id', tournament_id).eq('round_number', 4).execute()
        
        advancement_detected = False
        for match in finals_after.data:
            p1_status = "✅" if match['player1_id'] else "❌"
            p2_status = "✅" if match['player2_id'] else "❌"
            
            # Check if this changed from before
            before_match = next(m for m in finals_before.data if m['match_number'] == match['match_number'])
            if match['player1_id'] != before_match['player1_id'] or match['player2_id'] != before_match['player2_id']:
                advancement_detected = True
                print(f"   M{match['match_number']}: Player1 {p1_status} | Player2 {p2_status} | Status: {match['status']} ⭐ ADVANCED!")
            else:
                print(f"   M{match['match_number']}: Player1 {p1_status} | Player2 {p2_status} | Status: {match['status']}")
        
        # Results
        if advancement_detected:
            print("\n🎉 SUCCESS: Auto-advancement detected!")
            print("   ✅ Winners were automatically advanced to Finals")
            print("   ✅ System is working correctly")
        else:
            print("\n⚠️ No auto-advancement detected")
            print("   This might be expected if:")
            print("   - The other Round 3 match is not completed yet")
            print("   - Database triggers are not installed")
            print("   - Realtime listeners are not working")
            
    except Exception as e:
        print(f"❌ Error completing match: {e}")
    
    print("\n" + "=" * 50)
    print("🏁 Test completed!")

if __name__ == "__main__":
    main()