#!/usr/bin/env python3
"""Add winner reference columns to matches table"""

import os
from supabase import create_client

# Supabase configuration
SUPABASE_URL = "https://mogjjvscxjwvhtpkrlqr.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ"

def add_winner_reference_columns():
    """Try to add winner reference columns using SQL"""
    try:
        supabase = create_client(SUPABASE_URL, SUPABASE_KEY)
        
        # Try to add columns via RPC function (if exists)
        try:
            result = supabase.rpc('add_winner_references').execute()
            print("✅ Added winner reference columns via RPC")
            return True
        except:
            print("❌ RPC method failed, trying direct SQL...")
            
        # Check current schema by attempting insert with new fields
        try:
            test_insert = {
                'tournament_id': '00000000-0000-0000-0000-000000000000',
                'round_number': 1,
                'match_number': 1,
                'status': 'pending',
                'player1_winner_from': 'test',
                'player2_winner_from': 'test'
            }
            
            supabase.table('matches').insert(test_insert).execute()
            print("✅ Winner reference columns already exist!")
            
            # Clean up test
            supabase.table('matches').delete().eq('tournament_id', '00000000-0000-0000-0000-000000000000').execute()
            return True
            
        except Exception as e:
            error_msg = str(e)
            if 'column' in error_msg and 'does not exist' in error_msg:
                print(f"❌ Winner reference columns don't exist: {error_msg}")
                print("🔧 Need to add columns manually in database:")
                print("   ALTER TABLE matches ADD COLUMN player1_winner_from TEXT;")
                print("   ALTER TABLE matches ADD COLUMN player2_winner_from TEXT;")
                return False
            else:
                print(f"❌ Other error: {error_msg}")
                return False
                
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

if __name__ == "__main__":
    add_winner_reference_columns()