#!/usr/bin/env python3
"""
Script to create test tournament data with proper authentication
"""

import os
import json
from datetime import datetime, timedelta
from supabase import create_client, Client

# Supabase configuration
SUPABASE_URL = "https://mogjjvscxjwvhtpkrlqr.supabase.co"
SUPABASE_SERVICE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo"  # Service role key bypasses RLS

def main():
    try:
        # Initialize Supabase client with service role (bypasses RLS)
        supabase: Client = create_client(SUPABASE_URL, SUPABASE_SERVICE_KEY)
        print("✅ Connected to Supabase with service role")
        
        # Get a club to associate with tournament
        clubs_response = supabase.table('clubs').select('id, name, owner_id').limit(1).execute()
        if not clubs_response.data:
            print("❌ No clubs found. Please create a club first.")
            return
        
        club = clubs_response.data[0]
        club_id = club['id']
        club_name = club['name']
        owner_id = club.get('owner_id')
        print(f"📍 Using club: {club_name} ({club_id})")
        print(f"👤 Club owner: {owner_id}")
        
        # Calculate dates
        now = datetime.now()
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
            'organizer_id': owner_id or club_id,  # Set organizer_id to club owner
            'has_live_stream': False,
            'cover_image_url': 'https://images.unsplash.com/photo-1574631806042-182f10c4a017?w=600&h=400&fit=crop'
        }
        
        # Insert tournament
        result = supabase.table('tournaments').insert(tournament_data).execute()
        
        if result.data:
            tournament = result.data[0]
            print(f"✅ Tournament created successfully!")
            print(f"   ID: {tournament['id']}")
            print(f"   Title: {tournament['title']}")
            print(f"   Entry Fee: {tournament['entry_fee']:,.0f} VND")
            print(f"   Max Participants: {tournament['max_participants']}")
            print(f"   Registration Deadline: {tournament['registration_deadline']}")
            print(f"   Tournament Start: {tournament['start_date']}")
            print(f"   Status: {tournament['status']}")
            print("\n🎯 Ready to test registration flow!")
            
            # Now create the SQL functions if they don't exist
            print("\n🔧 Creating SQL functions...")
            try:
                # Create increment function
                supabase.rpc('increment_tournament_participants', {'tournament_id': tournament['id']}).execute()
                print("✅ increment_tournament_participants function exists")
            except Exception as e:
                print(f"⚠️  Creating increment_tournament_participants function: {e}")
                
        else:
            print("❌ Failed to create tournament")
            print("Response:", result)
            
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    main()