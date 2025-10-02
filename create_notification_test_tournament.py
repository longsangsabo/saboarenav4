#!/usr/bin/env python3
"""
Script to create a complete tournament test with participants for notification testing
"""

import os
from supabase import create_client, Client
from datetime import datetime, timedelta

# Supabase credentials
SUPABASE_URL = "https://mogjjvscxjwvhtpkrlqr.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo"

def main():
    print("🧪 Creating Complete Tournament Test with Notifications...")
    
    supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
    
    try:
        # 1. Create tournament
        tournament = create_tournament_with_participants(supabase)
        tournament_id = tournament['id']
        
        print(f"✅ Created tournament: {tournament['title']}")
        print(f"   ID: {tournament_id}")
        print(f"   Status: {tournament['status']}")
        
        # 2. Show participants 
        participants = supabase.table('tournament_participants').select('user_id, users!inner(username)').eq('tournament_id', tournament_id).execute().data
        print(f"\n👥 Tournament Participants ({len(participants)}):")
        for p in participants:
            print(f"   - {p['users']['username']} ({p['user_id'][:8]}...)")
        
        # 3. Create matches ready to complete
        create_test_matches(supabase, tournament_id, participants)
        
        print(f"\n🎯 READY FOR NOTIFICATION TESTING!")
        print(f"📱 In Flutter app:")
        print(f"   1. Navigate to Tournament Management")
        print(f"   2. Find tournament: '{tournament['title']}'")  
        print(f"   3. Complete the final match by entering score")
        print(f"   4. Check notifications tab for tournament completion messages")
        
        print(f"\n📊 What should happen:")
        print(f"   1. Tournament auto-completes")
        print(f"   2. Rewards applied (ELO/SPA)")
        print(f"   3. Notifications sent to all {len(participants)} participants:")
        print(f"      - Tournament completion notification")
        print(f"      - Champion announcement")
        print(f"      - Individual reward notifications")
        
        print(f"\n🔔 You can verify by checking notifications for users:")
        for p in participants:
            print(f"   - {p['users']['username']}")
        
    except Exception as e:
        print(f"❌ Error: {e}")

def create_tournament_with_participants(supabase):
    """Create tournament with real participants"""
    
    # Get some existing users
    users = supabase.table('users').select('id, username').limit(4).execute().data
    
    if len(users) < 4:
        raise Exception("Need at least 4 users in database")
    
    # Create tournament
    tournament_data = {
        'title': f'Notification Test {datetime.now().strftime("%H:%M")}',
        'description': 'Tournament để test notification system',
        'club_id': '6d984e0e-601e-4fd3-9659-7077295ac3bf',  # Use sabo1's club
        'bracket_format': 'single_elimination',
        'game_format': '8-ball',
        'max_participants': 4,
        'current_participants': 4,
        'entry_fee': 0,
        'prize_pool': 0,
        'registration_deadline': '2025-12-31T23:59:59Z',
        'start_date': '2025-01-01T10:00:00Z',
        'status': 'upcoming',
        'is_public': False,
        'skill_level_required': 'beginner',
    }
    
    tournament = supabase.table('tournaments').insert(tournament_data).execute().data[0]
    
    # Add participants
    for user in users:
        supabase.table('tournament_participants').insert({
            'tournament_id': tournament['id'],
            'user_id': user['id'],
            'registered_at': datetime.now().isoformat(),
            'payment_status': 'completed'
        }).execute()
    
    print(f"✅ Added {len(users)} participants to tournament")
    
    return tournament

def create_test_matches(supabase, tournament_id, participants):
    """Create test matches with most completed, leaving final for testing"""
    
    user_ids = [p['user_id'] for p in participants]
    
    # Semi-finals (completed)
    matches = [
        {
            'tournament_id': tournament_id,
            'round_number': 1,
            'match_number': 1,
            'player1_id': user_ids[0],
            'player2_id': user_ids[1],
            'player1_score': 2,
            'player2_score': 1,
            'winner_id': user_ids[0],  # User 0 wins
            'status': 'completed',
        },
        {
            'tournament_id': tournament_id,
            'round_number': 1,
            'match_number': 2,
            'player1_id': user_ids[2],
            'player2_id': user_ids[3],
            'player1_score': 2,
            'player2_score': 0,
            'winner_id': user_ids[2],  # User 2 wins
            'status': 'completed',
        },
        # Final (pending - to trigger notifications when completed)
        {
            'tournament_id': tournament_id,
            'round_number': 2, 
            'match_number': 3,
            'player1_id': user_ids[0],  # Winner of match 1
            'player2_id': user_ids[2],  # Winner of match 2
            'player1_score': 0,
            'player2_score': 0,
            'winner_id': None,
            'status': 'pending',  # This will trigger notifications when completed
        },
    ]
    
    for match in matches:
        supabase.table('matches').insert(match).execute()
    
    print(f"✅ Created {len(matches)} matches (2 completed, 1 pending final)")

if __name__ == "__main__":
    main()