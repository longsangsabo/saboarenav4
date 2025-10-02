#!/usr/bin/env python3
"""
Script to check if notifications are sent to users after tournament completion
"""

import os
from supabase import create_client, Client
from datetime import datetime, timedelta
import json

# Supabase credentials
SUPABASE_URL = "https://mogjjvscxjwvhtpkrlqr.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo"

def main():
    print("🔔 Checking Tournament Completion Notifications...")
    
    # Initialize Supabase client
    supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
    
    # Tournament sabo1 
    tournament_id = "a55163bd-c60b-42b1-840d-8719363096f5"
    
    try:
        # 1. Check if notifications table exists and its structure
        print("\n📋 Checking notifications table structure...")
        check_notifications_table(supabase)
        
        # 2. Check for tournament completion notifications
        print(f"\n🔍 Checking notifications for tournament: {tournament_id}")
        check_tournament_notifications(supabase, tournament_id)
        
        # 3. Check for participant notifications
        print(f"\n👥 Checking notifications for tournament participants...")
        check_participant_notifications(supabase, tournament_id)
        
        # 4. Check notification service integration
        print(f"\n🛠️ Checking notification service integration...")
        check_notification_service_integration()
        
    except Exception as e:
        print(f"❌ Error checking notifications: {str(e)}")

def check_notifications_table(supabase):
    """Check notifications table structure"""
    try:
        # Get a sample notification to see structure
        result = supabase.table('notifications').select('*').limit(1).execute()
        
        if result.data:
            print("✅ Notifications table exists")
            print("📊 Available columns:", list(result.data[0].keys()))
        else:
            print("⚠️ Notifications table exists but is empty")
            
        # Get total notification count
        count_result = supabase.table('notifications').select('id', count='exact').execute()
        print(f"📊 Total notifications in system: {count_result.count}")
        
    except Exception as e:
        print(f"❌ Error checking notifications table: {e}")

def check_tournament_notifications(supabase, tournament_id):
    """Check for tournament-specific notifications"""
    try:
        # Look for notifications related to this tournament
        tournament_notifications = supabase.table('notifications').select('*').ilike('message', f'%{tournament_id}%').execute()
        
        print(f"📊 Tournament-specific notifications: {len(tournament_notifications.data)}")
        
        if tournament_notifications.data:
            for notif in tournament_notifications.data:
                print(f"   - {notif['type']}: {notif['message'][:100]}...")
        
        # Look for completion-related notifications
        completion_keywords = ['completed', 'champion', 'winner', 'tournament ended', 'giải đấu']
        
        for keyword in completion_keywords:
            result = supabase.table('notifications').select('*').ilike('message', f'%{keyword}%').execute()
            if result.data:
                print(f"📧 Found {len(result.data)} notifications containing '{keyword}'")
                for notif in result.data[:3]:  # Show first 3
                    print(f"   - To: {notif['user_id'][:8]}... | {notif['type']}: {notif['message'][:80]}...")
        
    except Exception as e:
        print(f"❌ Error checking tournament notifications: {e}")

def check_participant_notifications(supabase, tournament_id):
    """Check notifications for tournament participants"""
    try:
        # Get tournament participants
        participants = supabase.table('tournament_participants').select('user_id').eq('tournament_id', tournament_id).execute()
        
        print(f"👥 Checking notifications for {len(participants.data)} participants...")
        
        # Check recent notifications for each participant
        recent_notifications = 0
        tournament_completion_time = datetime.now() - timedelta(hours=24)  # Last 24 hours
        
        for participant in participants.data:
            user_id = participant['user_id']
            
            # Get recent notifications for this user
            user_notifications = supabase.table('notifications').select('*').eq('user_id', user_id).gte('created_at', tournament_completion_time.isoformat()).execute()
            
            if user_notifications.data:
                recent_notifications += len(user_notifications.data)
                user_info = supabase.table('users').select('username').eq('id', user_id).single().execute()
                username = user_info.data['username'] if user_info.data else 'Unknown'
                
                print(f"   📧 {username}: {len(user_notifications.data)} recent notifications")
                for notif in user_notifications.data[:2]:  # Show first 2
                    print(f"      - {notif['type']}: {notif['message'][:60]}...")
        
        print(f"📊 Total recent notifications for participants: {recent_notifications}")
        
        # Check for specific tournament completion notification types
        notification_types = ['tournament_completed', 'tournament_winner', 'reward_received', 'elo_updated']
        
        for notif_type in notification_types:
            type_notifications = supabase.table('notifications').select('*').eq('type', notif_type).execute()
            if type_notifications.data:
                print(f"🏆 Found {len(type_notifications.data)} '{notif_type}' notifications")
        
    except Exception as e:
        print(f"❌ Error checking participant notifications: {e}")

def check_notification_service_integration():
    """Check if notification service is integrated in tournament completion"""
    print("🔧 Checking Flutter notification service integration...")
    
    # Check if NotificationService is imported and used in tournament completion
    notification_service_files = [
        'lib/services/notification_service.dart',
        'lib/services/tournament_completion_service.dart',
        'lib/services/auto_tournament_progression_service.dart'
    ]
    
    for file_path in notification_service_files:
        print(f"📁 Checking {file_path}...")
        try:
            # This would normally read the file, but we'll note what to check
            print(f"   ⚠️ Manual check needed: Does {file_path} send tournament completion notifications?")
        except:
            print(f"   ❌ File not accessible: {file_path}")
    
    # Recommendations
    print(f"\n💡 RECOMMENDATIONS:")
    print(f"   1. Add tournament completion notifications to TournamentCompletionService")
    print(f"   2. Send notifications for:")
    print(f"      - Tournament completed (to all participants)")
    print(f"      - Champion announcement (to all participants)")
    print(f"      - Individual rewards received (to each participant)")
    print(f"      - ELO/SPA updates (to each participant)")
    print(f"   3. Use NotificationService.sendNotification() in auto-completion flow")

if __name__ == "__main__":
    main()