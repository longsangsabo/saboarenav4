#!/usr/bin/env python3
"""
Script to complete the final match and test auto-completion
"""

import os
from supabase import create_client, Client
from datetime import datetime

# Supabase credentials
SUPABASE_URL = "https://mogjjvscxjwvhtpkrlqr.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo"

def main():
    print("🏆 Testing Auto-Completion by finishing final match...")
    
    # Initialize Supabase client
    supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
    
    # Tournament ID từ test trước
    tournament_id = "27bfcc67-1da0-4082-9e10-4a578fa4f3e0"
    
    try:
        # 1. Tìm match pending (trận cuối)
        matches_response = supabase.table('matches').select('*').eq('tournament_id', tournament_id).eq('status', 'pending').execute()
        
        if not matches_response.data:
            print("❌ No pending matches found!")
            return
            
        final_match = matches_response.data[0]
        print(f"🎯 Found final match: {final_match['id']}")
        print(f"   Round {final_match['round_number']}, Match {final_match['match_number']}")
        print(f"   Player 1: {final_match['player1_id'][:8]}...")
        print(f"   Player 2: {final_match['player2_id'][:8]}...")
        
        # 2. Hoàn thành match với kết quả
        print("\n🎯 Completing final match...")
        
        # Player 1 wins 3-1
        update_data = {
            'player1_score': 3,
            'player2_score': 1,
            'winner_id': final_match['player1_id'],
            'status': 'completed',
            'end_time': datetime.now().isoformat(),
        }
        
        result = supabase.table('matches').update(update_data).eq('id', final_match['id']).execute()
        
        if result.data:
            print("✅ Final match completed!")
            print(f"   Score: 3-1")
            print(f"   Winner: {final_match['player1_id'][:8]}...")
            
            # 3. Đợi một chút rồi kiểm tra tournament status
            print("\n⏳ Waiting for auto-completion system...")
            import time
            time.sleep(2)
            
            # 4. Kiểm tra tournament status
            tournament_response = supabase.table('tournaments').select('*').eq('id', tournament_id).single().execute()
            tournament = tournament_response.data
            
            print(f"\n📊 Tournament Status After Match Completion:")
            print(f"   Status: {tournament['status']}")
            
            if tournament['status'] == 'completed':
                print("🎉 SUCCESS! Tournament auto-completed!")
                print(f"   Winner ID: {tournament.get('winner_id', 'Not set')}")
            else:
                print("⚠️ Tournament not auto-completed yet")
                print("   The auto-completion system should trigger in the Flutter app")
                
        else:
            print("❌ Failed to complete match")
            
    except Exception as e:
        print(f"❌ Error: {str(e)}")

if __name__ == "__main__":
    main()