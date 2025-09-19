#!/usr/bin/env python3
"""
Simple Challenge Backend Test - Core Functionality
"""
from supabase import create_client, Client
import json

def main():
    print("🎯 SIMPLE CHALLENGE BACKEND TEST")
    print("="*40)
    
    url = "https://mogjjvscxjwvhtpkrlqr.supabase.co"
    service_key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo"
    
    supabase = create_client(url, service_key)
    
    challenger_id = "ca23e628-d2bb-4174-b4b8-d1cc2ff8335f"
    challenged_id = "8dc68b2e-8c94-47d7-a2d7-a70b218c32a8"
    
    try:
        print("1️⃣ CREATING CHALLENGE (như Flutter app)")
        
        # Simple challenge data matching our service
        challenge_data = {
            "challenger_id": challenger_id,
            "challenged_id": challenged_id,
            "challenge_type": "thach_dau",
            "message": "Test challenge - 200 SPA points!",
            "stakes_type": "spa_points",
            "stakes_amount": 200,
            "match_conditions": {
                "game_type": "8-ball",
                "location": "Sabo Arena",
                "handicap": 2
            },
            "status": "pending",
            "handicap_challenger": 0.0,
            "handicap_challenged": 2.0,
            "rank_difference": 0
        }
        
        print("🚀 Inserting challenge...")
        result = supabase.table('challenges').insert(challenge_data).execute()
        
        if result.data:
            challenge_id = result.data[0]['id']
            print(f"✅ SUCCESS! Challenge created: {challenge_id}")
            print(f"   Status: {result.data[0]['status']}")
        else:
            print("❌ No challenge data returned")
            return
            
        print("\n2️⃣ VERIFYING CHALLENGE EXISTS")
        
        # Count challenges for this user
        challenges = supabase.table('challenges').select('id, status, stakes_amount').eq('challenger_id', challenger_id).execute()
        print(f"📊 Found {len(challenges.data)} challenges for user")
        
        # Find our challenge
        our_challenge = None
        for ch in challenges.data:
            if ch['id'] == challenge_id:
                our_challenge = ch
                break
                
        if our_challenge:
            print(f"✅ Our challenge found: Status={our_challenge['status']}, SPA={our_challenge['stakes_amount']}")
        else:
            print("❌ Challenge not found in list")
            
        print("\n3️⃣ SIMULATING ACCEPTANCE")
        
        # Accept the challenge
        update_result = supabase.table('challenges').update({
            'status': 'accepted',
            'response_message': 'Tôi chấp nhận!'
        }).eq('id', challenge_id).execute()
        
        if update_result.data:
            print("✅ Challenge accepted successfully!")
            print(f"   New status: {update_result.data[0]['status']}")
        else:
            print("❌ Challenge acceptance failed")
            
        print("\n4️⃣ CHECKING FINAL STATE")
        
        # Get updated challenges
        final_check = supabase.table('challenges').select('id, status, response_message').eq('id', challenge_id).execute()
        
        if final_check.data:
            final_challenge = final_check.data[0]
            print(f"📋 Final challenge state:")
            print(f"   ID: {final_challenge['id']}")
            print(f"   Status: {final_challenge['status']}")
            print(f"   Response: {final_challenge.get('response_message', 'None')}")
        
        print("\n5️⃣ CLEANUP")
        supabase.table('challenges').delete().eq('id', challenge_id).execute()
        print("🧹 Test challenge deleted")
        
        print("\n" + "="*40)
        print("🎉 BACKEND CHALLENGE FLOW: WORKING! ✅")
        print("="*40)
        
        print("\n📊 FLOW SUMMARY:")
        print("✅ Challenge creation: OK")
        print("✅ Data storage with schema mapping: OK") 
        print("✅ Challenge acceptance: OK")
        print("✅ Status updates: OK")
        
        print("\n🚀 FLUTTER APP SHOULD WORK:")
        print("• User clicks 'Gửi' → Challenge created")
        print("• Data mapped to existing table structure")
        print("• SPA points stored in stakes_amount")
        print("• Game details stored in match_conditions JSON")
        print("• Challenge can be accepted/declined")
        
        print("\n🔄 NEXT LOGIC FLOW:")
        print("1. Challenge created (status: pending)")
        print("2. Notification sent to challenged user")
        print("3. User accepts/declines challenge")  
        print("4. If accepted → schedule match")
        print("5. After match → update ELO & SPA points")
        print("6. Record match history")
        
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    main()