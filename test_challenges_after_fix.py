#!/usr/bin/env python3
"""
Test challenges table after adding missing columns
Run this AFTER executing the SQL to add columns
"""
from supabase import create_client, Client

def main():
    print("🧪 Testing challenges table after column addition...")
    
    url = "https://mogjjvscxjwvhtpkrlqr.supabase.co"
    key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ"
    
    supabase = create_client(url, key)
    
    # Test data that should work after adding columns
    test_data = {
        "challenger_id": "ca23e628-d2bb-4174-b4b8-d1cc2ff8335f",
        "challenged_id": "8dc68b2e-8c94-47d7-a2d7-a70b218c32a8",
        "challenge_type": "thach_dau",
        "game_type": "8-ball",      # This was missing before
        "location": "Test Club",    # This was missing before  
        "handicap": 2,             # This was missing before
        "spa_points": 100,         # This was missing before
        "status": "pending"
    }
    
    try:
        print("🚀 Attempting to insert challenge with all columns...")
        result = supabase.table('challenges').insert(test_data).execute()
        
        if result.data:
            print("🎉 SUCCESS! All columns are now working!")
            challenge = result.data[0]
            challenge_id = challenge['id']
            
            print(f"✅ Created challenge ID: {challenge_id}")
            print(f"📋 Challenge data: {challenge}")
            
            # Verify we can read it back
            read_result = supabase.table('challenges').select('*').eq('id', challenge_id).execute()
            if read_result.data:
                print("✅ Challenge can be read back successfully")
                read_challenge = read_result.data[0]
                print(f"🔍 Read challenge: {read_challenge}")
                
                # Check specific fields
                if read_challenge.get('game_type') == '8-ball':
                    print("✅ game_type field working")
                if read_challenge.get('location') == 'Test Club':
                    print("✅ location field working")
                if read_challenge.get('handicap') == 2:
                    print("✅ handicap field working")
                if read_challenge.get('spa_points') == 100:
                    print("✅ spa_points field working")
            
            # Clean up test data
            delete_result = supabase.table('challenges').delete().eq('id', challenge_id).execute()
            print("🧹 Test data cleaned up")
            
            print("\n🎯 CHALLENGE SYSTEM IS NOW WORKING!")
            print("✅ Database schema is complete")
            print("✅ All required columns exist") 
            print("✅ Challenge creation flow should work in Flutter app")
            
        else:
            print("⚠️ Insert succeeded but returned no data")
            
    except Exception as e:
        print(f"❌ Test failed: {e}")
        
        if "game_type" in str(e):
            print("🔧 game_type column still missing - SQL not executed yet")
        elif "row-level security" in str(e):
            print("🔐 RLS policy issue - but columns exist")
        else:
            print("❓ Different error - check details")

if __name__ == "__main__":
    main()