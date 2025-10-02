#!/usr/bin/env python3
"""Test hardcore advancement by creating new tournament and checking bracket structure"""

import os
from supabase import create_client
import json

# Supabase configuration
SUPABASE_URL = "https://mogjjvscxjwvhtpkrlqr.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ"

def test_hardcore_advancement():
    try:
        # Initialize Supabase client
        supabase = create_client(SUPABASE_URL, SUPABASE_KEY)
        
        print("🔍 Looking for tournaments with hardcore advancement...")
        
        # Get tournaments - using title instead of name
        tournaments_response = supabase.table("tournaments").select("*").execute()
        tournaments = tournaments_response.data
        
        for tournament in tournaments:
            if not tournament.get('bracket_data'):
                continue
                
            bracket_data = json.loads(tournament['bracket_data'])
            
            # Check if it has hardcore advancement structure
            if 'hardcoreAdvancement' in bracket_data:
                print(f"\n🚀 Found hardcore advancement tournament: {tournament['title']}")
                print(f"📋 Format: {tournament.get('bracket_format', 'N/A')}")
                
                hardcore = bracket_data['hardcoreAdvancement']
                print(f"🔧 Hardcore advancement rules: {len(hardcore)} matches")
                
                # Show advancement structure
                for match_key, advancement in hardcore.items():
                    p1_ref = advancement.get('player1_winner_from', 'N/A')
                    p2_ref = advancement.get('player2_winner_from', 'N/A')
                    print(f"  📊 {match_key}: P1←{p1_ref}, P2←{p2_ref}")
                
                # Check actual matches
                matches_response = supabase.table("matches").select("*").eq("tournament_id", tournament['id']).execute()
                matches = matches_response.data
                
                print(f"\n📋 Actual matches: {len(matches)}")
                
                # Analyze winner references in matches
                winner_refs = 0
                for match in matches:
                    if match['player1_id'] and 'WINNER_FROM_' in str(match['player1_id']):
                        winner_refs += 1
                        print(f"  🔗 Match R{match['round']}M{match['match_number']}: P1={match['player1_id']}")
                    if match['player2_id'] and 'WINNER_FROM_' in str(match['player2_id']):
                        winner_refs += 1
                        print(f"  🔗 Match R{match['round']}M{match['match_number']}: P2={match['player2_id']}")
                
                print(f"🎯 Total winner references in matches: {winner_refs}")
                return True
        
        print("❌ No tournaments with hardcore advancement found")
        return False
        
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

if __name__ == "__main__":
    test_hardcore_advancement()