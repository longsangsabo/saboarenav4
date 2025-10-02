#!/usr/bin/env python3
"""
Script to check if user stats, ELO, and rewards are updated after tournament completion
"""

import os
from supabase import create_client, Client
from datetime import datetime
import json

# Supabase credentials
SUPABASE_URL = "https://mogjjvscxjwvhtpkrlqr.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo"

def main():
    print("🔍 Checking tournament completion rewards and stats updates...")
    
    # Initialize Supabase client
    supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
    
    # Tournament sabo1 đã completed
    tournament_id = "a55163bd-c60b-42b1-840d-8719363096f5"
    
    try:
        # 1. Lấy thông tin tournament
        tournament = supabase.table('tournaments').select('*').eq('id', tournament_id).single().execute().data
        print(f"🏆 Tournament: {tournament['title']}")
        print(f"   Status: {tournament['status']}")
        print(f"   Winner: {tournament.get('winner_id', 'Not set')}")
        
        if tournament['status'] != 'completed':
            print("⚠️ Tournament not completed yet!")
            return
        
        # 2. Lấy tất cả participants và matches
        participants_response = supabase.table('tournament_participants').select('''
            user_id,
            users!inner(username, full_name, elo_rating, spa_points, 
                        total_matches, wins, tournament_wins, tournaments_played, total_wins, total_losses)
        ''').eq('tournament_id', tournament_id).execute()
        
        participants = participants_response.data
        
        # 3. Lấy matches để tính performance
        matches_response = supabase.table('matches').select('*').eq('tournament_id', tournament_id).execute()
        matches = matches_response.data
        
        print(f"\n📊 Found {len(participants)} participants, {len(matches)} matches")
        
        # 4. Phân tích từng participant
        print("\n" + "="*80)
        print("USER STATS ANALYSIS AFTER TOURNAMENT COMPLETION")
        print("="*80)
        
        for i, participant in enumerate(participants, 1):
            user = participant['users']
            user_id = participant['user_id']
            
            # Tính performance trong tournament
            user_matches = [m for m in matches if m['player1_id'] == user_id or m['player2_id'] == user_id]
            wins = len([m for m in user_matches if m['winner_id'] == user_id])
            losses = len([m for m in user_matches if m['winner_id'] and m['winner_id'] != user_id])
            
            # Determine position (rough estimate)
            position = "Unknown"
            if user_id == tournament.get('winner_id'):
                position = "🥇 Champion"
            elif wins >= len(user_matches) - 1:  # Lost only final
                position = "🥈 Runner-up"
            elif wins > 0:
                position = f"Top {min(8, len(participants)//2)}"
            else:
                position = "Early elimination"
            
            print(f"\n{i:2d}. {user['full_name'] or user['username']}")
            print(f"    Position: {position}")
            print(f"    Tournament Performance: {wins}W-{losses}L")
            print(f"    Current ELO: {user['elo_rating']}")
            print(f"    Current SPA Points: {user['spa_points']}")
            print(f"    Total Matches Played: {user['total_matches']}")
            print(f"    Total Matches Won: {user['total_wins']}")
            print(f"    Tournament Wins: {user['tournament_wins']}")
            print(f"    Tournaments Played: {user['tournaments_played']}")
        
        # 5. Kiểm tra xem có tournament completion records không
        print(f"\n" + "="*80)
        print("TOURNAMENT COMPLETION REWARDS CHECK")
        print("="*80)
        
        # Kiểm tra bảng tournament_results nếu có
        try:
            results_response = supabase.table('tournament_results').select('*').eq('tournament_id', tournament_id).execute()
            if results_response.data:
                print(f"✅ Found {len(results_response.data)} tournament result records")
                for result in results_response.data[:3]:  # Show top 3
                    print(f"   - User: {result.get('user_id', 'Unknown')[:8]}...")
                    print(f"     Position: {result.get('final_position', 'Unknown')}")
                    print(f"     ELO Change: {result.get('elo_change', 'Unknown')}")
                    print(f"     SPA Reward: {result.get('spa_reward', 'Unknown')}")
            else:
                print("⚠️ No tournament_results records found")
        except Exception as e:
            print(f"⚠️ tournament_results table not accessible: {e}")
        
        # 6. Kiểm tra user_stats hoặc transaction logs
        try:
            # Kiểm tra recent transactions around tournament completion time
            completion_time = tournament.get('updated_at', tournament.get('created_at'))
            print(f"\n🔍 Checking for reward transactions around: {completion_time}")
            
            # This would need actual transaction/reward tables to check
            print("⚠️ Need to implement reward transaction tracking")
            
        except Exception as e:
            print(f"⚠️ Error checking reward transactions: {e}")
        
        # 7. Recommendations
        print(f"\n" + "="*80)
        print("ANALYSIS & RECOMMENDATIONS")
        print("="*80)
        
        champion_id = tournament.get('winner_id')
        if champion_id:
            champion = next((p for p in participants if p['user_id'] == champion_id), None)
            if champion:
                print(f"🏆 Champion: {champion['users']['full_name'] or champion['users']['username']}")
                print(f"   Current ELO: {champion['users']['elo_rating']}")
                print(f"   Current SPA: {champion['users']['spa_points']}")
        
        print(f"\n📋 What should happen after tournament completion:")
        print(f"   1. ✅ Tournament status updated to 'completed'")
        print(f"   2. ❓ ELO ratings updated based on performance")
        print(f"   3. ❓ SPA points rewards distributed")
        print(f"   4. ❓ User stats (matches_won, tournaments_won) updated")
        print(f"   5. ❓ Tournament result records created")
        
        print(f"\n🔧 NEXT STEPS:")
        print(f"   - Implement automatic ELO/SPA updates in tournament completion")
        print(f"   - Add tournament_results table for tracking")
        print(f"   - Update user statistics after tournament finish")
        
    except Exception as e:
        print(f"❌ Error checking tournament completion: {str(e)}")

if __name__ == "__main__":
    main()