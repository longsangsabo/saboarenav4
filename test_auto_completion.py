#!/usr/bin/env python3
"""
Script to test auto tournament completion system
"""

import os
from supabase import create_client, Client
from datetime import datetime
import json

# Supabase credentials
SUPABASE_URL = "https://mogjjvscxjwvhtpkrlqr.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo"

def main():
    print("🧪 Testing Auto Tournament Completion System...")
    
    # Initialize Supabase client
    supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
    
    try:
        # 1. Tạo tournament test với status 'active'
        test_tournament = create_test_tournament(supabase)
        tournament_id = test_tournament['id']
        
        print(f"✅ Created test tournament: {tournament_id}")
        print(f"   Title: {test_tournament['title']}")
        print(f"   Status: {test_tournament['status']}")
        
        # 2. Tạo matches giả lập đã hoàn thành
        create_completed_matches(supabase, tournament_id)
        
        # 3. Kiểm tra hệ thống auto-completion trong Flutter app
        print("\n🔍 Now test in Flutter app:")
        print("1. Navigate to tournament management")
        print("2. Enter a match score to trigger auto-progression")  
        print("3. Check if tournament status automatically changes to 'completed'")
        
        # 4. Kiểm tra trạng thái hiện tại
        check_tournament_status(supabase, tournament_id)
        
        print(f"\n✅ Test tournament created: {tournament_id}")
        print("🚀 Auto-completion system is ready for testing!")
        
    except Exception as e:
        print(f"❌ Error in test: {str(e)}")

def create_test_tournament(supabase):
    """Tạo tournament test"""
    tournament_data = {
        'title': f'Auto-Completion Test {datetime.now().strftime("%H:%M:%S")}',
        'description': 'Tournament to test automatic completion system',
        'club_id': '6d984e0e-601e-4fd3-9659-7077295ac3bf',  # Use sabo1's club
        'bracket_format': 'single_elimination',
        'game_format': '8-ball',
        'max_participants': 4,
        'current_participants': 4,
        'entry_fee': 0,
        'prize_pool': 0,
        'registration_deadline': '2025-12-31T23:59:59Z',
        'start_date': '2025-01-01T10:00:00Z',
        'status': 'upcoming',  # Will change to completed when all matches done
        'is_public': False,
        'skill_level_required': 'beginner',
    }
    
    result = supabase.table('tournaments').insert(tournament_data).execute()
    return result.data[0]

def create_completed_matches(supabase, tournament_id):
    """Tạo matches đã hoàn thành để test auto-completion"""
    
    # Lấy một số user IDs để làm participants
    users_response = supabase.table('users').select('id').limit(4).execute()
    user_ids = [user['id'] for user in users_response.data]
    
    if len(user_ids) < 4:
        print("⚠️ Not enough users for test matches")
        return
    
    # Tạo 2 matches cho semifinal (Round 1)
    matches = [
        {
            'tournament_id': tournament_id,
            'round_number': 1,
            'match_number': 1,

            'player1_id': user_ids[0],
            'player2_id': user_ids[1],
            'player1_score': 2,
            'player2_score': 1,
            'winner_id': user_ids[0],  # Player 1 wins
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
            'winner_id': user_ids[2],  # Player 3 wins
            'status': 'completed',
        },
        # Final match - will be completed manually to trigger auto-completion
        {
            'tournament_id': tournament_id,
            'round_number': 2,
            'match_number': 3,

            'player1_id': user_ids[0],  # Winner of R1M1
            'player2_id': user_ids[2],  # Winner of R1M2
            'player1_score': 0,  # Will be updated manually
            'player2_score': 0,  # Will be updated manually
            'winner_id': None,   # Will be set when match completed
            'status': 'pending', # This will trigger auto-completion when completed
        },
    ]
    
    for match in matches:
        supabase.table('matches').insert(match).execute()
    
    print(f"✅ Created {len(matches)} test matches")
    print("   - 2 completed matches (semifinals)")
    print("   - 1 pending final match (for testing)")

def check_tournament_status(supabase, tournament_id):
    """Kiểm tra trạng thái tournament"""
    tournament = supabase.table('tournaments').select('*').eq('id', tournament_id).single().execute()
    
    print(f"\n📊 Tournament Status:")
    print(f"   ID: {tournament_id}")
    print(f"   Title: {tournament.data['title']}")
    print(f"   Status: {tournament.data['status']}")
    
    # Kiểm tra matches
    matches = supabase.table('matches').select('*').eq('tournament_id', tournament_id).execute()
    completed_matches = [m for m in matches.data if m['status'] == 'completed']
    
    print(f"   Matches: {len(completed_matches)}/{len(matches.data)} completed")
    
    if len(completed_matches) == len(matches.data):
        print("   🎯 All matches completed - should auto-complete!")
    else:
        print("   ⏳ Tournament not ready for completion")

if __name__ == "__main__":
    main()