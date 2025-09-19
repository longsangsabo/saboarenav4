#!/usr/bin/env python3
"""
Script to check actual Supabase database schema
"""

import os
import json
from supabase import create_client, Client

# Supabase configuration
SUPABASE_URL = "https://mogjjvscxjwvhtpkrlqr.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ"

def main():
    try:
        # Initialize Supabase client
        supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
        print("✅ Connected to Supabase")
        
        # Check tournaments table schema by querying with limit 0
        print("\n🔍 Checking tournaments table schema...")
        try:
            result = supabase.table('tournaments').select('*').limit(0).execute()
            print("✅ tournaments table exists")
        except Exception as e:
            print(f"❌ Error with tournaments table: {e}")
            
        # Check what columns are available by trying to select all columns from first row
        print("\n🔍 Getting tournament columns...")
        try:
            result = supabase.table('tournaments').select('*').limit(1).execute()
            if result.data:
                tournament = result.data[0]
                print("📊 Available columns in tournaments table:")
                for key in sorted(tournament.keys()):
                    print(f"   - {key}: {type(tournament[key]).__name__}")
            else:
                print("⚠️  No tournaments found, will create one to check structure")
                
        except Exception as e:
            print(f"❌ Error getting tournament data: {e}")
        
        # Check tournament_participants table schema
        print("\n🔍 Checking tournament_participants table schema...")
        try:
            result = supabase.table('tournament_participants').select('*').limit(1).execute()
            if result.data:
                participant = result.data[0]
                print("📊 Available columns in tournament_participants table:")
                for key in sorted(participant.keys()):
                    print(f"   - {key}: {type(participant[key]).__name__}")
            else:
                print("ℹ️  No participants found")
        except Exception as e:
            print(f"❌ Error with tournament_participants table: {e}")
            
        # Check clubs table
        print("\n🔍 Checking clubs table...")
        try:
            result = supabase.table('clubs').select('id, name').limit(3).execute()
            if result.data:
                print(f"📊 Found {len(result.data)} clubs:")
                for club in result.data:
                    print(f"   - {club['name']} ({club['id']})")
            else:
                print("⚠️  No clubs found")
        except Exception as e:
            print(f"❌ Error with clubs table: {e}")
            
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    main()