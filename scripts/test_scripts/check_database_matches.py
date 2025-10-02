#!/usr/bin/env python3
"""Check database matches for tournament sabo1"""

import os
from supabase import create_client
import json

# Supabase configuration
SUPABASE_URL = "https://mogjjvscxjwvhtpkrlqr.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ"

def check_database_matches():
    try:
        # Initialize Supabase client
        supabase = create_client(SUPABASE_URL, SUPABASE_KEY)
        
        print("🔍 Checking database matches for sabo1...")
        
        # Find tournament sabo1
        tournaments_response = supabase.table("tournaments").select("*").eq("title", "sabo1").execute()
        
        if not tournaments_response.data:
            print("❌ Tournament sabo1 not found")
            return
            
        tournament = tournaments_response.data[0]
        tournament_id = tournament['id']
        
        print(f"✅ Found tournament: {tournament['title']} (ID: {tournament_id})")
        
        # Get all matches
        matches_response = supabase.table("matches").select("*").eq("tournament_id", tournament_id).order("round").order("match_number").execute()
        matches = matches_response.data
        
        print(f"📋 Total matches in database: {len(matches)}")
        
        # Analyze by rounds
        rounds_data = {}
        winner_refs = 0
        
        for match in matches:
            round_num = match['round']
            if round_num not in rounds_data:
                rounds_data[round_num] = []
                
            rounds_data[round_num].append(match)
            
            # Check for winner references
            if match['player1_id'] and 'WINNER_FROM_' in str(match['player1_id']):
                winner_refs += 1
            if match['player2_id'] and 'WINNER_FROM_' in str(match['player2_id']):
                winner_refs += 1
        
        print(f"\n📊 Matches by rounds:")
        for round_num in sorted(rounds_data.keys()):
            round_matches = rounds_data[round_num]
            assigned = 0
            winner_ref_count = 0
            
            print(f"\n🎯 Round {round_num}: {len(round_matches)} matches")
            
            for match in round_matches:
                has_p1 = match['player1_id'] is not None
                has_p2 = match['player2_id'] is not None
                
                p1_display = match['player1_id'] if has_p1 else "NULL"
                p2_display = match['player2_id'] if has_p2 else "NULL"
                
                if has_p1 and has_p2:
                    assigned += 1
                    
                # Check winner references
                if match['player1_id'] and 'WINNER_FROM_' in str(match['player1_id']):
                    winner_ref_count += 1
                if match['player2_id'] and 'WINNER_FROM_' in str(match['player2_id']):
                    winner_ref_count += 1
                
                print(f"  M{match['match_number']}: {p1_display} vs {p2_display}")
            
            print(f"  ✅ {assigned}/{len(round_matches)} fully assigned, {winner_ref_count} winner references")
        
        print(f"\n🎯 Summary:")
        print(f"  Total matches: {len(matches)}")
        print(f"  Total winner references: {winner_refs}")
        print(f"  Hardcore advancement: {'YES' if winner_refs > 0 else 'NO'}")
        
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    check_database_matches()