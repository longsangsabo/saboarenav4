#!/usr/bin/env python3
"""
Check if matches table has winner_advances_to and loser_advances_to columns
"""

from supabase import create_client

SUPABASE_URL = "https://mogjjvscxjwvhtpkrlqr.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ"

TOURNAMENT_ID = "f787eb67-8752-4cc8-ae7b-8b8bd65c7d62"

def main():
    print("\n🔍 CHECKING DATABASE SCHEMA...\n")
    
    supabase = create_client(SUPABASE_URL, SUPABASE_KEY)
    
    # Get one match to check columns
    response = supabase.table('matches').select('*').eq('tournament_id', TOURNAMENT_ID).eq('match_number', 6).execute()
    
    if not response.data:
        print("❌ No matches found!")
        return
    
    match = response.data[0]
    
    print("📊 Match 6 columns:")
    for key, value in match.items():
        print(f"   {key}: {value}")
    
    print("\n🔍 Checking advancement columns:")
    if 'winner_advances_to' in match:
        print(f"   ✅ winner_advances_to: {match['winner_advances_to']}")
    else:
        print("   ❌ winner_advances_to: COLUMN DOES NOT EXIST!")
    
    if 'loser_advances_to' in match:
        print(f"   ✅ loser_advances_to: {match['loser_advances_to']}")
    else:
        print("   ❌ loser_advances_to: COLUMN DOES NOT EXIST!")
    
    print("\n")

if __name__ == "__main__":
    main()
