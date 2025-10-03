#!/usr/bin/env python3
"""
Fix advancement map for tournament f787eb67-8752-4cc8-ae7b-8b8bd65c7d62
Add winner_advances_to and loser_advances_to to all 31 matches
"""

from supabase import create_client

# Supabase credentials
SUPABASE_URL = "https://mogjjvscxjwvhtpkrlqr.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ"

TOURNAMENT_ID = "f787eb67-8752-4cc8-ae7b-8b8bd65c7d62"

# Advancement map from HardcodedDoubleEliminationService
ADVANCEMENT_MAP = {
    # Winner Bracket Round 1 (Matches 1-8)
    1: {'winner': 9, 'loser': 16},
    2: {'winner': 9, 'loser': 16},
    3: {'winner': 10, 'loser': 17},
    4: {'winner': 10, 'loser': 17},
    5: {'winner': 11, 'loser': 18},
    6: {'winner': 11, 'loser': 18},
    7: {'winner': 12, 'loser': 19},
    8: {'winner': 12, 'loser': 19},
    
    # Winner Bracket Round 2 (Matches 9-12)
    9: {'winner': 13, 'loser': 24},
    10: {'winner': 13, 'loser': 25},
    11: {'winner': 14, 'loser': 26},
    12: {'winner': 14, 'loser': 27},
    
    # Winner Bracket Round 3 (Matches 13-14)
    13: {'winner': 15, 'loser': 28},
    14: {'winner': 15, 'loser': 29},
    
    # Winner Bracket Final (Match 15)
    15: {'winner': 31, 'loser': 30},
    
    # Loser Bracket Round 1 (Matches 16-23)
    16: {'winner': 24, 'loser': None},
    17: {'winner': 24, 'loser': None},
    18: {'winner': 25, 'loser': None},
    19: {'winner': 25, 'loser': None},
    20: {'winner': 26, 'loser': None},
    21: {'winner': 26, 'loser': None},
    22: {'winner': 27, 'loser': None},
    23: {'winner': 27, 'loser': None},
    
    # Loser Bracket Round 2 (Matches 24-27)
    24: {'winner': 28, 'loser': None},
    25: {'winner': 28, 'loser': None},
    26: {'winner': 29, 'loser': None},
    27: {'winner': 29, 'loser': None},
    
    # Loser Bracket Round 3 (Matches 28-29)
    28: {'winner': 30, 'loser': None},
    29: {'winner': 30, 'loser': None},
    
    # Loser Bracket Round 4/Final (Match 30)
    30: {'winner': 31, 'loser': None},
    
    # Grand Final (Match 31)
    31: {'winner': None, 'loser': None},
}

def main():
    print(f"\n🔧 FIXING ADVANCEMENT MAP FOR TOURNAMENT: {TOURNAMENT_ID}\n")
    
    # Initialize Supabase client
    supabase = create_client(SUPABASE_URL, SUPABASE_KEY)
    
    # Get all matches for tournament
    print("📊 Fetching matches...")
    response = supabase.table('matches').select('*').eq('tournament_id', TOURNAMENT_ID).execute()
    matches = response.data
    
    print(f"✅ Found {len(matches)} matches\n")
    
    if len(matches) != 31:
        print(f"❌ ERROR: Expected 31 matches, found {len(matches)}")
        return
    
    # Update each match
    updated_count = 0
    for match in matches:
        match_number = match['match_number']
        match_id = match['id']
        
        if match_number not in ADVANCEMENT_MAP:
            print(f"⚠️  Match {match_number}: No advancement map found")
            continue
        
        advancement = ADVANCEMENT_MAP[match_number]
        winner_to = advancement['winner']
        loser_to = advancement['loser']
        
        # Update database
        try:
            supabase.table('matches').update({
                'winner_advances_to': winner_to,
                'loser_advances_to': loser_to,
            }).eq('id', match_id).execute()
            
            updated_count += 1
            
            # Format display
            winner_str = f"M{winner_to}" if winner_to else "null"
            loser_str = f"M{loser_to}" if loser_to else "null"
            
            print(f"✅ M{match_number:2d}: W→{winner_str:4s}  L→{loser_str:4s}")
            
        except Exception as e:
            print(f"❌ M{match_number}: Error - {e}")
    
    print(f"\n🎉 COMPLETED! Updated {updated_count}/31 matches")
    print(f"\n📋 NEXT STEPS:")
    print(f"   1. Refresh app (press 'r' in Flutter terminal)")
    print(f"   2. Complete Match 1 (WB R1)")
    print(f"   3. Check Match 16 (LB R1) - Loser should appear!")
    print(f"\n")

if __name__ == "__main__":
    main()
