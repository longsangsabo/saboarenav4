#!/usr/bin/env python3
"""Direct hardcore advancement test - bypass UI completely"""

import os
from supabase import create_client
import json

# Supabase configuration
SUPABASE_URL = "https://mogjjvscxjwvhtpkrlqr.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ"

def create_hardcore_matches_directly():
    """Create hardcore advancement matches directly in database"""
    try:
        supabase = create_client(SUPABASE_URL, SUPABASE_KEY)
        
        # Find sabo1 tournament
        tournaments = supabase.table('tournaments').select('*').eq('title', 'sabo1').execute()
        if not tournaments.data:
            print("❌ Tournament sabo1 not found")
            return
            
        tournament_id = tournaments.data[0]['id']
        print(f"🎯 Found tournament sabo1: {tournament_id}")
        
        # Delete existing matches
        supabase.table('matches').delete().eq('tournament_id', tournament_id).execute()
        print("🗑️ Cleared existing matches")
        
        # Get participants
        participants_response = supabase.table('tournament_participants').select('user_id').eq('tournament_id', tournament_id).execute()
        participant_ids = [p['user_id'] for p in participants_response.data]
        
        if len(participant_ids) < 16:
            print(f"❌ Need 16 participants, found {len(participant_ids)}")
            return
            
        print(f"👥 Found {len(participant_ids)} participants")
        
        # Create hardcore advancement matches manually
        matches_to_create = []
        
        # Round 1: 8 matches with real players
        for i in range(8):
            matches_to_create.append({
                'tournament_id': tournament_id,
                'round': 1,
                'match_number': i + 1,
                'player1_id': participant_ids[i * 2],
                'player2_id': participant_ids[i * 2 + 1],
                'status': 'pending',
                'created_at': '2025-10-02T12:00:00Z'
            })
        
        # Round 2: 4 matches with winner references
        for i in range(4):
            matches_to_create.append({
                'tournament_id': tournament_id,
                'round': 2,
                'match_number': i + 9,  # M9, M10, M11, M12
                'player1_id': f'WINNER_FROM_R1M{i * 2 + 1}',  # M1, M3, M5, M7
                'player2_id': f'WINNER_FROM_R1M{i * 2 + 2}',  # M2, M4, M6, M8
                'status': 'pending',
                'created_at': '2025-10-02T12:00:00Z'
            })
        
        # Round 3: 2 matches with winner references
        for i in range(2):
            matches_to_create.append({
                'tournament_id': tournament_id,
                'round': 3,
                'match_number': i + 13,  # M13, M14
                'player1_id': f'WINNER_FROM_R2M{i * 2 + 9}',   # M9, M11
                'player2_id': f'WINNER_FROM_R2M{i * 2 + 10}',  # M10, M12
                'status': 'pending',
                'created_at': '2025-10-02T12:00:00Z'
            })
        
        # Round 4: 1 final match
        matches_to_create.append({
            'tournament_id': tournament_id,
            'round': 4,
            'match_number': 15,  # M15
            'player1_id': 'WINNER_FROM_R3M13',
            'player2_id': 'WINNER_FROM_R3M14',
            'status': 'pending',
            'created_at': '2025-10-02T12:00:00Z'
        })
        
        # Insert all matches
        result = supabase.table('matches').insert(matches_to_create).execute()
        
        print(f"✅ Created {len(matches_to_create)} hardcore advancement matches")
        print("📊 Structure:")
        print("  Round 1: 8 matches with real players")
        print("  Round 2: 4 matches with WINNER_FROM_R1Mx")
        print("  Round 3: 2 matches with WINNER_FROM_R2Mx")
        print("  Round 4: 1 match with WINNER_FROM_R3Mx")
        
        return True
        
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

if __name__ == "__main__":
    create_hardcore_matches_directly()