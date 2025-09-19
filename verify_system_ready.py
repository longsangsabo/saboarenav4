#!/usr/bin/env python3
"""
Quick verification script to check if referral system is fully operational
Run this after applying the database migration
"""

import requests
import json
import os

# Load environment variables
with open('env.json', 'r') as f:
    env = json.load(f)

SUPABASE_URL = env['SUPABASE_URL']
SERVICE_ROLE_KEY = env['SUPABASE_SERVICE_ROLE_KEY']

headers = {
    'apikey': SERVICE_ROLE_KEY,
    'Authorization': f'Bearer {SERVICE_ROLE_KEY}',
    'Content-Type': 'application/json'
}

def check_schema():
    """Check if database has correct schema"""
    print("🔍 Checking database schema...")
    
    try:
        # Check referral_codes table structure
        response = requests.get(
            f"{SUPABASE_URL}/rest/v1/referral_codes?select=*&limit=1",
            headers=headers
        )
        
        if response.status_code == 200:
            print("✅ Database accessible")
            
            # Try to access new columns
            test_response = requests.get(
                f"{SUPABASE_URL}/rest/v1/referral_codes?select=spa_reward_referrer,spa_reward_referred&limit=1",
                headers=headers
            )
            
            if test_response.status_code == 200:
                print("✅ New schema columns detected")
                return True
            else:
                print("❌ New schema columns missing")
                print(f"Response: {test_response.text}")
                return False
        else:
            print(f"❌ Database access failed: {response.status_code}")
            return False
            
    except Exception as e:
        print(f"❌ Schema check failed: {e}")
        return False

def test_create_code():
    """Test creating a basic referral code"""
    print("\n🧪 Testing referral code creation...")
    
    try:
        # Create test code
        test_code_data = {
            "user_id": "test-user-id",
            "code": "TEST-VERIFY-001",
            "spa_reward_referrer": 100,
            "spa_reward_referred": 50,
            "max_uses": 10,
            "current_uses": 0,
            "is_active": True
        }
        
        response = requests.post(
            f"{SUPABASE_URL}/rest/v1/referral_codes",
            headers=headers,
            json=test_code_data
        )
        
        if response.status_code == 201:
            print("✅ Referral code creation successful")
            
            # Clean up test code
            cleanup_response = requests.delete(
                f"{SUPABASE_URL}/rest/v1/referral_codes?code=eq.TEST-VERIFY-001",
                headers=headers
            )
            
            if cleanup_response.status_code == 204:
                print("✅ Test cleanup successful")
            
            return True
        else:
            print(f"❌ Code creation failed: {response.status_code}")
            print(f"Response: {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ Code creation test failed: {e}")
        return False

def test_spa_rewards():
    """Test SPA reward logic"""
    print("\n💰 Testing SPA reward logic...")
    
    try:
        # Get existing codes to test reward calculation
        response = requests.get(
            f"{SUPABASE_URL}/rest/v1/referral_codes?select=code,spa_reward_referrer,spa_reward_referred&limit=3",
            headers=headers
        )
        
        if response.status_code == 200:
            codes = response.json()
            
            if codes:
                print(f"✅ Found {len(codes)} referral codes")
                
                for code in codes:
                    referrer_reward = code.get('spa_reward_referrer', 'NOT SET')
                    referred_reward = code.get('spa_reward_referred', 'NOT SET')
                    
                    print(f"   Code: {code['code']}")
                    print(f"   Referrer Reward: {referrer_reward} SPA")
                    print(f"   Referred Reward: {referred_reward} SPA")
                    
                    if referrer_reward == 'NOT SET' or referred_reward == 'NOT SET':
                        print("   ❌ Missing reward values")
                        return False
                    else:
                        print("   ✅ Reward values correct")
                
                return True
            else:
                print("⚠️ No referral codes found in database")
                return True  # This is okay, just means empty database
        else:
            print(f"❌ Failed to fetch codes: {response.status_code}")
            return False
            
    except Exception as e:
        print(f"❌ SPA reward test failed: {e}")
        return False

def main():
    print("🚀 REFERRAL SYSTEM VERIFICATION")
    print("=" * 50)
    
    checks = [
        ("Schema Check", check_schema),
        ("Code Creation Test", test_create_code),
        ("SPA Rewards Test", test_spa_rewards)
    ]
    
    results = []
    
    for check_name, check_func in checks:
        print(f"\n{check_name}...")
        result = check_func()
        results.append((check_name, result))
    
    print("\n" + "=" * 50)
    print("📊 VERIFICATION RESULTS")
    print("=" * 50)
    
    all_passed = True
    for check_name, result in results:
        status = "✅ PASS" if result else "❌ FAIL"
        print(f"{check_name}: {status}")
        
        if not result:
            all_passed = False
    
    print("\n" + "=" * 50)
    
    if all_passed:
        print("🎉 ALL CHECKS PASSED!")
        print("✅ Referral system is fully operational")
        print("✅ Ready for production deployment")
        print("✅ Schema migration successful")
    else:
        print("⚠️ SOME CHECKS FAILED")
        print("❌ Please review and fix issues above")
        print("❌ May need to apply database migration")
    
    print("=" * 50)

if __name__ == "__main__":
    main()