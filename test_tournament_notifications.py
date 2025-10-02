#!/usr/bin/env python3
"""
Script to test tournament completion notifications
"""

import os
from supabase import create_client, Client
from datetime import datetime, timedelta
import time

# Supabase credentials
SUPABASE_URL = "https://mogjjvscxjwvhtpkrlqr.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo"

def main():
    print("🔔 Testing Tournament Completion Notifications...")
    
    supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
    
    # Test với tournament có sẵn
    test_tournament_id = "27bfcc67-1da0-4082-9e10-4a578fa4f3e0"  # Tournament test trước đó
    
    try:
        # 1. Kiểm tra trạng thái tournament
        tournament = supabase.table('tournaments').select('*').eq('id', test_tournament_id).single().execute().data
        print(f"🏆 Tournament: {tournament['title']}")
        print(f"   Status: {tournament['status']}")
        
        # 2. Kiểm tra notifications trước khi test
        print(f"\n📊 BEFORE NOTIFICATIONS:")
        check_notifications_before = count_recent_notifications(supabase)
        print(f"   Total recent notifications: {check_notifications_before}")
        
        # 3. Nếu tournament chưa completed, complete nó để test notifications
        if tournament['status'] != 'completed':
            print(f"\n🎯 Completing tournament to test notifications...")
            
            # Đảm bảo tất cả matches completed
            matches = supabase.table('matches').select('*').eq('tournament_id', test_tournament_id).execute().data
            completed_matches = [m for m in matches if m['status'] == 'completed']
            
            print(f"   Matches: {len(completed_matches)}/{len(matches)} completed")
            
            if len(completed_matches) == len(matches):
                # Mark tournament as completed (this should trigger notifications in Flutter)
                supabase.table('tournaments').update({
                    'status': 'completed'
                }).eq('id', test_tournament_id).execute()
                
                print(f"✅ Tournament marked as completed!")
                print(f"🔔 Notifications should be sent by Flutter auto-completion service...")
                
        # 4. Đợi một chút để Flutter service xử lý (nếu app đang chạy)
        print(f"\n⏳ Waiting for Flutter app to process notifications...")
        time.sleep(5)
        
        # 5. Kiểm tra notifications sau
        print(f"\n📊 AFTER COMPLETION:")
        check_notifications_after = count_recent_notifications(supabase)
        print(f"   Total recent notifications: {check_notifications_after}")
        
        new_notifications = check_notifications_after - check_notifications_before
        if new_notifications > 0:
            print(f"🎉 SUCCESS: {new_notifications} new notifications created!")
            show_recent_notifications(supabase, limit=new_notifications)
        else:
            print(f"⚠️ No new notifications found")
            print(f"   This means either:")
            print(f"   1. Flutter app is not running to trigger auto-completion")
            print(f"   2. Notification service is not integrated yet")
            print(f"   3. Tournament was already completed before")
        
        # 6. Kiểm tra notification details cho participants
        print(f"\n👥 Checking participant notifications...")
        check_participant_notifications(supabase, test_tournament_id)
        
    except Exception as e:
        print(f"❌ Error testing notifications: {e}")

def count_recent_notifications(supabase):
    """Count notifications from last hour"""
    one_hour_ago = datetime.now() - timedelta(hours=1)
    result = supabase.table('notifications').select('id', count='exact').gte('created_at', one_hour_ago.isoformat()).execute()
    return result.count or 0

def show_recent_notifications(supabase, limit=10):
    """Show recent notifications"""
    one_hour_ago = datetime.now() - timedelta(hours=1)
    notifications = supabase.table('notifications').select('*').gte('created_at', one_hour_ago.isoformat()).order('created_at', ascending=False).limit(limit).execute().data
    
    for notif in notifications:
        print(f"   📧 {notif['type']}: {notif['title']}")
        print(f"      To: {notif['user_id'][:8]}... | {notif['message'][:80]}...")
        print(f"      Time: {notif['created_at']}")

def check_participant_notifications(supabase, tournament_id):
    """Check if participants got notifications"""
    try:
        # Get participants
        participants = supabase.table('tournament_participants').select('user_id').eq('tournament_id', tournament_id).execute().data
        
        if not participants:
            print(f"   ⚠️ No participants found for tournament")
            return
            
        print(f"   Checking {len(participants)} participants...")
        
        one_hour_ago = datetime.now() - timedelta(hours=1)
        
        notifications_found = 0
        for participant in participants:
            user_id = participant['user_id']
            
            # Check recent notifications for this user
            user_notifications = supabase.table('notifications').select('*').eq('user_id', user_id).gte('created_at', one_hour_ago.isoformat()).execute().data
            
            if user_notifications:
                notifications_found += len(user_notifications)
                print(f"   📧 User {user_id[:8]}...: {len(user_notifications)} recent notifications")
        
        if notifications_found == 0:
            print(f"   ⚠️ No recent notifications found for any participant")
        else:
            print(f"   ✅ Found {notifications_found} total notifications for participants")
            
    except Exception as e:
        print(f"   ❌ Error checking participant notifications: {e}")

if __name__ == "__main__":
    main()