#!/usr/bin/env python3
"""Check matches table schema"""

import os
from supabase import create_client

# Supabase configuration
SUPABASE_URL = "https://mogjjvscxjwvhtpkrlqr.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ"

def check_matches_schema():
    """Check matches table structure"""
    try:
        supabase = create_client(SUPABASE_URL, SUPABASE_KEY)
        
        # Try to get one match to see structure
        matches = supabase.table('matches').select('*').limit(1).execute()
        
        if matches.data:
            print("📋 Matches table structure:")
            match = matches.data[0]
            for key, value in match.items():
                print(f"  {key}: {type(value).__name__} = {value}")
        else:
            print("No matches found")
            
        # Check what fields exist by trying empty insert
        try:
            result = supabase.table('matches').insert({}).execute()
        except Exception as e:
            error_msg = str(e)
            print(f"\n🔍 Schema info from error: {error_msg}")
            
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    check_matches_schema()