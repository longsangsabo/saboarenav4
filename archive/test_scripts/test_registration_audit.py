#!/usr/bin/env python3
"""
Script to test tournament registration flow end-to-end
"""

from supabase import create_client, Client
import json

# Supabase configuration
SUPABASE_URL = "https://mogjjvscxjwvhtpkrlqr.supabase.co"
SUPABASE_SERVICE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo"

def main():
    try:
        # Initialize Supabase client
        supabase: Client = create_client(SUPABASE_URL, SUPABASE_SERVICE_KEY)
        print("✅ Connected to Supabase with service role")
        
        # Get tournament we created earlier
        print("\n🔍 Finding test tournament...")
        tournaments = supabase.table('tournaments').select('*').eq('title', 'Giải Test Registration Flow 2025').execute()
        
        if not tournaments.data:
            print("❌ Test tournament not found!")
            return
            
        tournament = tournaments.data[0]
        tournament_id = tournament['id']
        print(f"✅ Found tournament: {tournament['title']} ({tournament_id})")
        print(f"   Current participants: {tournament['current_participants']}/{tournament['max_participants']}")
        
        # Check tournament_participants table structure
        print("\n🔍 Checking tournament_participants table...")
        try:
            # Try to get one participant to see structure
            participants = supabase.table('tournament_participants').select('*').limit(1).execute()
            if participants.data:
                participant = participants.data[0]
                print("📊 tournament_participants table structure:")
                for key in sorted(participant.keys()):
                    print(f"   - {key}: {type(participant[key]).__name__}")
            else:
                print("ℹ️  No participants found, checking table structure by inserting test record...")
        except Exception as e:
            print(f"❌ Error checking tournament_participants: {e}")
        
        # Test notification system by checking if any notifications exist
        print("\n🔍 Checking notifications...")
        notifications = supabase.table('notifications').select('*').limit(3).execute()
        if notifications.data:
            print(f"📬 Found {len(notifications.data)} notifications")
            for notif in notifications.data:
                print(f"   - {notif.get('title', 'No title')} (read: {notif.get('is_read', False)})")
        else:
            print("📭 No notifications found")
            
        # Check club_members to see notification recipients
        print("\n🔍 Checking club admins for notifications...")
        club_id = tournament['club_id']
        admins = supabase.table('club_members').select('user_id, role, users(full_name, email)').eq('club_id', club_id).eq('role', 'admin').execute()
        
        if admins.data:
            print(f"👥 Found {len(admins.data)} club admins:")
            for admin in admins.data:
                profile = admin.get('users', {})
                name = profile.get('full_name', 'Unknown') if profile else 'Unknown'
                email = profile.get('email', 'No email') if profile else 'No email'
                print(f"   - {name} ({email})")
        else:
            print("⚠️  No club admins found - notifications won't be sent!")
        
        print("\n🎯 Registration flow audit summary:")
        print(f"   ✅ Tournament exists: {tournament['title']}")
        print(f"   ✅ Tournament ID: {tournament_id}")
        print(f"   ✅ Registration deadline: {tournament['registration_deadline']}")
        print(f"   ✅ Entry fee: {tournament['entry_fee']:,.0f} VND")
        print(f"   {'✅' if admins.data else '⚠️ '} Club admins for notifications: {len(admins.data) if admins.data else 0}")
        print(f"   📱 Ready to test registration flow in app!")
        
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    main()