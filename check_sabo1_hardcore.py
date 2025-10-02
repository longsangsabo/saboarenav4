#!/usr/bin/env python3
"""Check specific tournament for hardcore advancement implementation"""

import os
from supabase import create_client
import json

# Supabase configuration
SUPABASE_URL = "https://mogjjvscxjwvhtpkrlqr.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ"

def check_tournament_hardcore(tournament_name):
    try:
        # Initialize Supabase client
        supabase = create_client(SUPABASE_URL, SUPABASE_KEY)
        
        print(f"🔍 Checking tournament '{tournament_name}' for hardcore advancement...")
        
        # Find tournament by title
        tournaments_response = supabase.table("tournaments").select("*").eq("title", tournament_name).execute()
        
        if not tournaments_response.data:
            print(f"❌ Tournament '{tournament_name}' not found")
            return False
            
        tournament = tournaments_response.data[0]
        print(f"✅ Found tournament: {tournament['title']}")
        print(f"📋 Format: {tournament.get('bracket_format', 'N/A')}")
        print(f"👥 Participants: {tournament.get('current_participants', 0)}/{tournament.get('max_participants', 0)}")
        
        # Check bracket data
        if not tournament.get('bracket_data'):
            print("❌ No bracket_data found")
            return False
            
        try:
            bracket_data = json.loads(tournament['bracket_data'])
        except:
            print("❌ Invalid bracket_data JSON")
            return False
            
        print(f"🏗️ Bracket data keys: {list(bracket_data.keys())}")
        
        # Check for hardcore advancement
        if 'hardcoreAdvancement' in bracket_data:
            print("🚀 HAS HARDCORE ADVANCEMENT!")
            hardcore = bracket_data['hardcoreAdvancement']
            print(f"🔧 Advancement rules: {len(hardcore)} matches")
            
            for match_key, advancement in hardcore.items():
                p1_ref = advancement.get('player1_winner_from', 'N/A')
                p2_ref = advancement.get('player2_winner_from', 'N/A')
                print(f"  📊 {match_key}: P1←{p1_ref}, P2←{p2_ref}")
        else:
            print("❌ NO hardcore advancement found")
            
        # Check for complete bracket structure
        if 'allRounds' in bracket_data:
            all_rounds = bracket_data['allRounds']
            print(f"🎯 Complete bracket: {len(all_rounds)} rounds")
            
            for i, round_matches in enumerate(all_rounds):
                print(f"  Round {i+1}: {len(round_matches)} matches")
        else:
            print("❌ No allRounds structure found")
            
        # Check actual matches in database
        matches_response = supabase.table("matches").select("*").eq("tournament_id", tournament['id']).execute()
        matches = matches_response.data
        
        print(f"\n📋 Database matches: {len(matches)}")
        
        # Count winner references
        winner_refs = 0
        rounds_data = {}
        
        for match in matches:
            round_num = match['round']
            if round_num not in rounds_data:
                rounds_data[round_num] = {'total': 0, 'with_players': 0, 'winner_refs': 0}
                
            rounds_data[round_num]['total'] += 1
            
            has_p1 = match['player1_id'] is not None
            has_p2 = match['player2_id'] is not None
            
            if has_p1 and has_p2:
                rounds_data[round_num]['with_players'] += 1
                
            # Check for winner references
            if match['player1_id'] and 'WINNER_FROM_' in str(match['player1_id']):
                winner_refs += 1
                rounds_data[round_num]['winner_refs'] += 1
                print(f"  🔗 R{match['round']}M{match['match_number']}: P1={match['player1_id']}")
                
            if match['player2_id'] and 'WINNER_FROM_' in str(match['player2_id']):
                winner_refs += 1
                rounds_data[round_num]['winner_refs'] += 1
                print(f"  🔗 R{match['round']}M{match['match_number']}: P2={match['player2_id']}")
        
        print(f"\n📊 Round analysis:")
        for round_num in sorted(rounds_data.keys()):
            data = rounds_data[round_num]
            print(f"  Round {round_num}: {data['with_players']}/{data['total']} assigned, {data['winner_refs']} winner refs")
        
        print(f"🎯 Total winner references: {winner_refs}")
        
        return winner_refs > 0
        
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

if __name__ == "__main__":
    check_tournament_hardcore("sabo1")