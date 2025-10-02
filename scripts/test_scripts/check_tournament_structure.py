#!/usr/bin/env python3
import os
from supabase import create_client, Client

# Supabase configuration
url = "https://mogjjvscxjwvhtpkrlqr.supabase.co"
key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ"

def check_tournament_structure():
    """Check tournament table structure"""
    try:
        supabase: Client = create_client(url, key)
        
        # Get all tournaments to see structure
        tournaments = supabase.table('tournaments').select('*').limit(5).execute()
        
        print("🔍 Tournament table structure:")
        if tournaments.data:
            for tournament in tournaments.data:
                print(f"Tournament: {tournament}")
                break
        else:
            print("No tournaments found")
            
        return tournaments.data
        
    except Exception as e:
        print(f"❌ Error checking structure: {e}")
        return None

if __name__ == "__main__":
    check_tournament_structure()