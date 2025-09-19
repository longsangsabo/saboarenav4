#!/usr/bin/env python3
"""
Script to create test tournament data in Supabase database
"""

import os
import json
from datetime import datetime, timedelta
from supabase import create_client, Client

# Supabase configuration
SUPABASE_URL = "https://mogjjvscxjwvhtpkrlqr.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ"

def main():
    try:
        # Initialize Supabase client
        supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
        print("✅ Connected to Supabase")
        
        # First, get a club ID to associate with tournament
        clubs_response = supabase.table('clubs').select('id, name').limit(1).execute()
        if not clubs_response.data:
            print("❌ No clubs found. Please create a club first.")
            return
        
        club_id = clubs_response.data[0]['id']
        club_name = clubs_response.data[0]['name']
        print(f"📍 Using club: {club_name} ({club_id})")
        
        # Calculate dates
        now = datetime.now()
        registration_start = now
        registration_deadline = now + timedelta(days=7)
        tournament_start = now + timedelta(days=10)
        
        # Tournament data - using actual schema column names
        tournament_data = {
            'title': 'Giải Test Registration Flow 2025',
            'description': 'Giải đấu test để kiểm tra flow đăng ký và thanh toán',
            'club_id': club_id,
            'format': '8-ball',  # Changed from tournament_type
            'tournament_type': '8-ball',  # Keep both for compatibility
            'max_participants': 16,
            'current_participants': 0,
            'entry_fee': 100000.0,  # 100k VND as float
            'prize_pool': 1500000.0,  # 1.5M VND as float
            'registration_deadline': registration_deadline.isoformat(),
            'start_date': tournament_start.isoformat(),
            'status': 'upcoming',
            'is_public': True,
            'skill_level_required': 'beginner',  # Add required skill level
            'organizer_id': club_id,  # Set organizer_id (using club_id)
            'has_live_stream': False,
            'cover_image_url': 'https://images.unsplash.com/photo-1574631806042-182f10c4a017?w=600&h=400&fit=crop',
            'created_at': now.isoformat(),
            'updated_at': now.isoformat()
        }
        
        # Insert tournament
        result = supabase.table('tournaments').insert(tournament_data).execute()
        
        if result.data:
            tournament = result.data[0]
            print(f"✅ Tournament created successfully!")
            print(f"   ID: {tournament['id']}")
            print(f"   Title: {tournament['title']}")
            print(f"   Entry Fee: {tournament['entry_fee']:,} VND")
            print(f"   Max Participants: {tournament['max_participants']}")
            print(f"   Registration Deadline: {tournament['registration_deadline']}")
            print(f"   Tournament Start: {tournament['start_date']}")
            print("\n🎯 Ready to test registration flow!")
        else:
            print("❌ Failed to create tournament")
            print("Response:", result)
            
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    main()