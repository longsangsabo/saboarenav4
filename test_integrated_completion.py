#!/usr/bin/env python3
"""
Script to test the integrated auto-completion system with rewards
"""

import os
from supabase import create_client, Client
import time

# Supabase credentials
SUPABASE_URL = "https://mogjjvscxjwvhtpkrlqr.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo"

def main():
    print("🧪 Testing Integrated Tournament Auto-Completion with Rewards...")
    
    # Test tournament ID
    tournament_id = "27bfcc67-1da0-4082-9e10-4a578fa4f3e0"
    
    supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
    
    try:
        # 1. Check current state
        print("📊 BEFORE AUTO-COMPLETION:")
        print_tournament_state(supabase, tournament_id)
        
        # 2. Simulate the auto-completion trigger by completing any remaining matches
        # The Flutter app will trigger this automatically via auto-progression service
        print("\n🎯 Ready for Flutter app testing!")
        print("In the Flutter app:")
        print("1. Navigate to Tournament Management")
        print("2. Find 'Auto-Completion Test' tournament")
        print("3. Complete any pending matches")
        print("4. Watch for automatic completion with rewards!")
        
        # 3. For now, let's manually trigger completion to test the system
        print("\n🔧 Manually testing tournament completion system...")
        
        # Check if tournament is ready for completion
        matches = supabase.table('matches').select('*').eq('tournament_id', tournament_id).execute().data
        completed_matches = [m for m in matches if m['status'] == 'completed']
        
        print(f"Matches status: {len(completed_matches)}/{len(matches)} completed")
        
        if len(completed_matches) == len(matches) and len(matches) > 0:
            print("✅ All matches completed - triggering auto-completion...")
            
            # This would normally be triggered by the Flutter app
            # but we can test the database logic here
            
            # Update tournament to completed
            supabase.table('tournaments').update({
                'status': 'completed'
            }).eq('id', tournament_id).execute()
            
            print("✅ Tournament marked as completed!")
            
            # The Flutter app auto-completion service would apply rewards here
            print("💰 Rewards would be applied by Flutter auto-completion service")
            
        else:
            print(f"⏳ Tournament not ready - {len(matches) - len(completed_matches)} matches pending")
        
    except Exception as e:
        print(f"❌ Error: {e}")

def print_tournament_state(supabase, tournament_id):
    """Print current tournament state"""
    try:
        # Tournament info
        tournament = supabase.table('tournaments').select('*').eq('id', tournament_id).single().execute().data
        print(f"   Tournament: {tournament['title']}")
        print(f"   Status: {tournament['status']}")
        
        # Participants
        participants = supabase.table('tournament_participants').select('user_id, users!inner(username, elo_rating, spa_points)').eq('tournament_id', tournament_id).execute().data
        
        print(f"   Participants: {len(participants)}")
        for p in participants:
            user = p['users']
            print(f"     - {user['username']}: ELO {user['elo_rating']}, SPA {user['spa_points']}")
        
        # Matches
        matches = supabase.table('matches').select('*').eq('tournament_id', tournament_id).execute().data
        completed = [m for m in matches if m['status'] == 'completed']
        print(f"   Matches: {len(completed)}/{len(matches)} completed")
        
    except Exception as e:
        print(f"   Error getting state: {e}")

if __name__ == "__main__":
    main()