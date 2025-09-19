#!/usr/bin/env python3
import requests
import json
from datetime import datetime, timedelta

def main():
    print("🧪 Testing challenges table with sample data...")
    
    # Supabase config
    url = "https://mogjjvscxjwvhtpkrlqr.supabase.co"
    anon_key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ"
    
    headers = {
        "apikey": anon_key,
        "Authorization": f"Bearer {anon_key}",
        "Content-Type": "application/json",
        "Prefer": "return=representation"
    }
    
    try:
        # Create a test challenge with game_type
        print("📝 Creating test challenge to verify schema...")
        
        test_challenge = {
            "challenger_id": "ca23e628-d2bb-4174-b4b8-d1cc2ff8335f",  # From logs
            "challenged_id": "8dc68b2e-8c94-47d7-a2d7-a70b218c32a8",  # From logs
            "challenge_type": "thach_dau",
            "game_type": "8-ball",
            "scheduled_time": (datetime.now() + timedelta(hours=1)).isoformat(),
            "location": "SABO Billiards",
            "handicap": 0,
            "spa_points": 0,
            "message": "Test challenge to verify schema",
            "status": "pending",
            "expires_at": (datetime.now() + timedelta(days=7)).isoformat()
        }
        
        print("🚀 Inserting test challenge...")
        response = requests.post(
            f"{url}/rest/v1/challenges",
            headers=headers,
            json=test_challenge
        )
        
        if response.status_code in [200, 201]:
            print("✅ SUCCESS: Test challenge created!")
            result = response.json()
            if isinstance(result, list) and len(result) > 0:
                challenge = result[0]
                print("📋 Created challenge:")
                print(f"  - ID: {challenge.get('id')}")
                print(f"  - Game Type: {challenge.get('game_type')}")
                print(f"  - Location: {challenge.get('location')}")
                print(f"  - Status: {challenge.get('status')}")
                print("")
                print("🎉 GAME_TYPE COLUMN IS WORKING!")
                print("💡 The schema cache should now be refreshed")
                
                # Clean up - delete the test challenge
                print("🧹 Cleaning up test data...")
                delete_response = requests.delete(
                    f"{url}/rest/v1/challenges?id=eq.{challenge.get('id')}",
                    headers=headers
                )
                if delete_response.status_code == 204:
                    print("✅ Test challenge deleted")
                
        else:
            print(f"❌ Insert failed: {response.status_code}")
            print(f"Response: {response.text}")
            
            # Try to parse error for specific column issues
            if "game_type" in response.text.lower():
                print("🔧 FOUND THE ISSUE: game_type column problem!")
                print("📋 Need to add the column to existing table")
            
    except Exception as error:
        print(f"❌ Error: {error}")

if __name__ == "__main__":
    main()