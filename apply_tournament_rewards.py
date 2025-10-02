#!/usr/bin/env python3
"""
Script to implement tournament completion rewards and stats updates
"""

import os
from supabase import create_client, Client
from datetime import datetime
import json

# Supabase credentials
SUPABASE_URL = "https://mogjjvscxjwvhtpkrlqr.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo"

def main():
    print("🏆 Implementing Tournament Completion Rewards System...")
    
    # Initialize Supabase client
    supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
    
    # Tournament sabo1
    tournament_id = "a55163bd-c60b-42b1-840d-8719363096f5"
    
    try:
        # 1. Analyze tournament results
        results = analyze_tournament_results(supabase, tournament_id)
        
        # 2. Calculate rewards
        rewards = calculate_tournament_rewards(results)
        
        # 3. Apply rewards
        apply_tournament_rewards(supabase, rewards)
        
        # 4. Update user stats
        update_user_tournament_stats(supabase, results)
        
        print("✅ Tournament completion rewards implemented!")
        
    except Exception as e:
        print(f"❌ Error: {str(e)}")

def analyze_tournament_results(supabase, tournament_id):
    """Phân tích kết quả tournament và xếp hạng"""
    print("\n📊 Analyzing tournament results...")
    
    # Lấy participants
    participants = supabase.table('tournament_participants').select('user_id').eq('tournament_id', tournament_id).execute().data
    
    # Lấy matches
    matches = supabase.table('matches').select('*').eq('tournament_id', tournament_id).execute().data
    
    # Tính performance cho từng user
    results = []
    for participant in participants:
        user_id = participant['user_id']
        
        # Tính matches cho user này
        user_matches = [m for m in matches if m['player1_id'] == user_id or m['player2_id'] == user_id]
        wins = len([m for m in user_matches if m['winner_id'] == user_id])
        losses = len([m for m in user_matches if m['winner_id'] and m['winner_id'] != user_id])
        
        # Lấy user info
        user_info = supabase.table('users').select('username, full_name, elo_rating, spa_points').eq('id', user_id).single().execute().data
        
        results.append({
            'user_id': user_id,
            'username': user_info['username'],
            'full_name': user_info['full_name'],
            'current_elo': user_info['elo_rating'],
            'current_spa': user_info['spa_points'],
            'wins': wins,
            'losses': losses,
            'matches_played': len(user_matches),
            'win_rate': wins / len(user_matches) if user_matches else 0
        })
    
    # Sắp xếp theo wins, win_rate
    results.sort(key=lambda x: (x['wins'], x['win_rate']), reverse=True)
    
    # Assign positions
    for i, result in enumerate(results):
        result['position'] = i + 1
        
    print(f"✅ Analyzed {len(results)} participants")
    return results

def calculate_tournament_rewards(results):
    """Tính toán rewards dựa trên position"""
    print("\n💰 Calculating tournament rewards...")
    
    rewards = []
    total_participants = len(results)
    
    for result in results:
        position = result['position']
        
        # ELO rewards based on position
        if position == 1:  # Champion
            elo_bonus = 50
            spa_bonus = 200
        elif position == 2:  # Runner-up
            elo_bonus = 30
            spa_bonus = 100
        elif position == 3:  # 3rd place
            elo_bonus = 20
            spa_bonus = 50
        elif position <= 4:  # Top 4
            elo_bonus = 10
            spa_bonus = 25
        elif position <= 8:  # Top 8
            elo_bonus = 5
            spa_bonus = 10
        else:  # Participation
            elo_bonus = 0
            spa_bonus = 5
        
        # Additional bonus for wins
        win_bonus_elo = result['wins'] * 5
        win_bonus_spa = result['wins'] * 10
        
        total_elo_reward = elo_bonus + win_bonus_elo
        total_spa_reward = spa_bonus + win_bonus_spa
        
        rewards.append({
            'user_id': result['user_id'],
            'username': result['username'],
            'position': position,
            'wins': result['wins'],
            'current_elo': result['current_elo'],
            'current_spa': result['current_spa'],
            'elo_reward': total_elo_reward,
            'spa_reward': total_spa_reward,
            'new_elo': result['current_elo'] + total_elo_reward,
            'new_spa': result['current_spa'] + total_spa_reward,
        })
    
    print(f"✅ Calculated rewards for {len(rewards)} participants")
    return rewards

def apply_tournament_rewards(supabase, rewards):
    """Apply rewards to user accounts"""
    print("\n🎁 Applying tournament rewards...")
    
    for reward in rewards:
        try:
            # Update user ELO and SPA
            supabase.table('users').update({
                'elo_rating': reward['new_elo'],
                'spa_points': reward['new_spa']
            }).eq('id', reward['user_id']).execute()
            
            print(f"✅ {reward['username']}: ELO {reward['current_elo']} → {reward['new_elo']} (+{reward['elo_reward']}), SPA {reward['current_spa']} → {reward['new_spa']} (+{reward['spa_reward']})")
            
        except Exception as e:
            print(f"❌ Error updating {reward['username']}: {e}")

def update_user_tournament_stats(supabase, results):
    """Update user tournament statistics"""
    print("\n📈 Updating user tournament statistics...")
    
    for result in results:
        try:
            # Get current stats
            user = supabase.table('users').select('tournaments_played, tournament_wins').eq('id', result['user_id']).single().execute().data
            
            # Update stats
            new_tournaments_played = (user['tournaments_played'] or 0) + 1
            new_tournament_wins = (user['tournament_wins'] or 0) + (1 if result['position'] == 1 else 0)
            
            supabase.table('users').update({
                'tournaments_played': new_tournaments_played,
                'tournament_wins': new_tournament_wins
            }).eq('id', result['user_id']).execute()
            
            print(f"✅ {result['username']}: Tournaments {new_tournaments_played}, Wins {new_tournament_wins}")
            
        except Exception as e:
            print(f"❌ Error updating stats for {result['username']}: {e}")

if __name__ == "__main__":
    main()