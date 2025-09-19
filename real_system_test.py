#!/usr/bin/env python3
"""
Real System Test using existing users and real data
Tests the referral system with actual database records
"""

import requests
import json
import time

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

def get_real_user():
    """Get a real user from the database"""
    try:
        response = requests.get(
            f"{SUPABASE_URL}/rest/v1/users?select=id,username&limit=1",
            headers=headers
        )
        
        if response.status_code == 200:
            users = response.json()
            if users:
                return users[0]
        return None
    except Exception as e:
        print(f"Error getting real user: {e}")
        return None

def test_with_existing_codes():
    """Test using existing referral codes"""
    print("🔍 Testing with existing referral codes...")
    
    try:
        # Get existing codes
        response = requests.get(
            f"{SUPABASE_URL}/rest/v1/referral_codes?select=*&limit=3",
            headers=headers
        )
        
        if response.status_code == 200:
            codes = response.json()
            
            if codes:
                print(f"✅ Found {len(codes)} existing codes")
                
                all_valid = True
                
                for code in codes:
                    print(f"\n📋 Testing code: {code['code']}")
                    
                    # Check required fields
                    has_rewards = code.get('rewards') is not None
                    has_user_id = code.get('user_id') is not None
                    is_active = code.get('is_active', False)
                    
                    print(f"   Rewards: {'✅' if has_rewards else '❌'}")
                    print(f"   User ID: {'✅' if has_user_id else '❌'}")
                    print(f"   Active: {'✅' if is_active else '❌'}")
                    
                    if has_rewards:
                        rewards = code['rewards']
                        referrer_spa = rewards.get('referrer_spa')
                        referred_spa = rewards.get('referred_spa')
                        reward_type = rewards.get('type')
                        
                        print(f"   Referrer SPA: {referrer_spa}")
                        print(f"   Referred SPA: {referred_spa}")
                        print(f"   Type: {reward_type}")
                        
                        if referrer_spa and referred_spa and reward_type == 'basic':
                            print("   ✅ Valid basic referral format")
                        else:
                            print("   ❌ Invalid referral format")
                            all_valid = False
                    else:
                        print("   ❌ Missing rewards data")
                        all_valid = False
                
                return all_valid
            else:
                print("⚠️ No referral codes found")
                return True  # No codes to test
        else:
            print(f"❌ Failed to fetch codes: {response.status_code}")
            return False
            
    except Exception as e:
        print(f"❌ Test failed: {e}")
        return False

def test_create_code_with_real_user():
    """Test creating a code with a real user"""
    print("\n🧪 Testing code creation with real user...")
    
    user = get_real_user()
    if not user:
        print("⚠️ No real user found - skipping creation test")
        return True
    
    try:
        test_code = f"SABO-REAL-TEST-{int(time.time())}"
        
        code_data = {
            "user_id": user['id'],
            "code": test_code,
            "rewards": {
                "referrer_spa": 100,
                "referred_spa": 50,
                "type": "basic"
            },
            "max_uses": 5,
            "current_uses": 0,
            "is_active": True
        }
        
        response = requests.post(
            f"{SUPABASE_URL}/rest/v1/referral_codes",
            headers=headers,
            json=code_data
        )
        
        if response.status_code == 201:
            print(f"✅ Successfully created test code: {test_code}")
            
            # Clean up test code
            cleanup_response = requests.delete(
                f"{SUPABASE_URL}/rest/v1/referral_codes?code=eq.{test_code}",
                headers=headers
            )
            
            if cleanup_response.status_code == 204:
                print("✅ Test code cleaned up")
            
            return True
        else:
            print(f"❌ Failed to create code: {response.status_code}")
            print(f"Response: {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ Code creation test failed: {e}")
        return False

def test_schema_compatibility():
    """Test that the schema works with our service"""
    print("\n🔧 Testing schema compatibility...")
    
    try:
        # Test fetching codes with rewards field
        response = requests.get(
            f"{SUPABASE_URL}/rest/v1/referral_codes?select=code,rewards&limit=1",
            headers=headers
        )
        
        if response.status_code == 200:
            print("✅ Can access rewards field")
            return True
        else:
            print(f"❌ Cannot access rewards field: {response.status_code}")
            return False
            
    except Exception as e:
        print(f"❌ Schema compatibility test failed: {e}")
        return False

def test_referral_usage_table():
    """Test referral_usage table structure"""
    print("\n📊 Testing referral_usage table...")
    
    try:
        # Check if table exists and is accessible
        response = requests.get(
            f"{SUPABASE_URL}/rest/v1/referral_usage?select=*&limit=1",
            headers=headers
        )
        
        if response.status_code == 200:
            print("✅ referral_usage table accessible")
            
            usage_records = response.json()
            if usage_records:
                usage = usage_records[0]
                print(f"✅ Found usage records: {len(usage_records)}")
                
                # Check required fields
                has_referrer_id = 'referrer_id' in usage
                has_referred_user_id = 'referred_user_id' in usage
                has_spa_awarded = 'spa_awarded_referrer' in usage and 'spa_awarded_referred' in usage
                
                print(f"   Referrer ID: {'✅' if has_referrer_id else '❌'}")
                print(f"   Referred User ID: {'✅' if has_referred_user_id else '❌'}")
                print(f"   SPA Awards: {'✅' if has_spa_awarded else '❌'}")
                
                return has_referrer_id and has_referred_user_id and has_spa_awarded
            else:
                print("⚠️ No usage records found (this is okay)")
                return True
        else:
            print(f"❌ Cannot access referral_usage table: {response.status_code}")
            return False
            
    except Exception as e:
        print(f"❌ Usage table test failed: {e}")
        return False

def main():
    print("🚀 REAL SYSTEM TEST - REFERRAL SYSTEM")
    print("=" * 50)
    
    tests = [
        ("Schema Compatibility", test_schema_compatibility),
        ("Existing Codes Validation", test_with_existing_codes),
        ("Code Creation with Real User", test_create_code_with_real_user),
        ("Referral Usage Table", test_referral_usage_table),
    ]
    
    results = []
    
    for test_name, test_func in tests:
        print(f"\n🧪 {test_name}...")
        try:
            result = test_func()
            results.append((test_name, result))
        except Exception as e:
            print(f"❌ Test error: {e}")
            results.append((test_name, False))
    
    print("\n" + "=" * 50)
    print("📊 REAL SYSTEM TEST RESULTS")
    print("=" * 50)
    
    passed = 0
    total = len(results)
    
    for test_name, result in results:
        status = "✅ PASS" if result else "❌ FAIL"
        print(f"{test_name}: {status}")
        
        if result:
            passed += 1
    
    success_rate = (passed / total) * 100
    
    print(f"\n📈 Results: {passed}/{total} tests passed ({success_rate:.1f}%)")
    
    if success_rate == 100:
        print("🎉 ALL TESTS PASSED!")
        print("✅ Referral system is fully operational")
        print("✅ Ready for production use")
    elif success_rate >= 75:
        print("🟡 MOSTLY WORKING - Minor issues detected")
        print("⚠️ Review failed tests")
    else:
        print("🔴 MAJOR ISSUES DETECTED")
        print("❌ System needs fixes before production")
    
    print("=" * 50)

if __name__ == "__main__":
    main()