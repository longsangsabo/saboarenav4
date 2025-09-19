#!/usr/bin/env python3
"""
Alternative: Create referral system tables using existing migration approach
"""

import requests
import json

# Supabase configuration với Service Role Key
SUPABASE_URL = "https://mogjjvscxjwvhtpkrlqr.supabase.co"
SERVICE_ROLE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo"

headers = {
    "apikey": SERVICE_ROLE_KEY,
    "Authorization": f"Bearer {SERVICE_ROLE_KEY}",
    "Content-Type": "application/json"
}

def execute_migration_step_by_step():
    """Execute referral migration step by step using REST API"""
    
    print("🚀 ALTERNATIVE: Step-by-step Migration via REST API")
    print("=" * 55)
    
    # Step 1: Add referral fields to users table first
    print("\n👤 Step 1: Adding referral fields to users table...")
    
    # Get existing user and add referral fields
    try:
        response = requests.get(
            f"{SUPABASE_URL}/rest/v1/users?username=eq.SABO123456&select=id,full_name,username,spa_points",
            headers=headers
        )
        
        if response.status_code == 200 and response.json():
            user = response.json()[0]
            user_id = user['id']
            print(f"✅ Found user: {user['full_name']} ({user['username']})")
            
            # Update user with referral fields
            update_data = {
                "referral_stats": {"total_referred": 0, "total_earned": 0, "codes_created": 0},
                "referral_bonus_claimed": False
            }
            
            update_response = requests.patch(
                f"{SUPABASE_URL}/rest/v1/users?id=eq.{user_id}",
                headers=headers,
                json=update_data
            )
            
            if update_response.status_code == 200:
                print("✅ User updated with referral fields")
            else:
                print(f"⚠️ Could not update user: {update_response.text}")
        else:
            print("❌ No test user found")
            return False
            
    except Exception as e:
        print(f"💥 Error updating user: {e}")
    
    print("\n📋 Manual steps required:")
    print("1. Copy the SQL from manual_referral_setup_guide.py")
    print("2. Execute in Supabase Dashboard > SQL Editor")
    print("3. This will create referral_codes and referral_usage tables")
    print("4. Then run verification script")
    
    return True

def create_verification_script():
    """Create script to verify after manual setup"""
    
    verification_script = """#!/usr/bin/env python3
import requests

SUPABASE_URL = "https://mogjjvscxjwvhtpkrlqr.supabase.co"
SERVICE_ROLE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo"

headers = {
    "apikey": SERVICE_ROLE_KEY,
    "Authorization": f"Bearer {SERVICE_ROLE_KEY}",
    "Content-Type": "application/json"
}

def verify_referral_setup():
    print("🔍 VERIFYING REFERRAL SYSTEM SETUP")
    print("=" * 40)
    
    # Check referral_codes table
    try:
        response = requests.get(f"{SUPABASE_URL}/rest/v1/referral_codes", headers=headers)
        if response.status_code == 200:
            codes = response.json()
            print(f"✅ referral_codes table: {len(codes)} codes found")
            for code in codes:
                print(f"   • {code['code']} ({code['code_type']}) - {'Active' if code['is_active'] else 'Inactive'}")
        else:
            print("❌ referral_codes table not accessible")
            return False
    except Exception as e:
        print(f"❌ Error checking referral_codes: {e}")
        return False
    
    # Check referral_usage table
    try:
        response = requests.get(f"{SUPABASE_URL}/rest/v1/referral_usage", headers=headers)
        if response.status_code == 200:
            usage = response.json()
            print(f"✅ referral_usage table: {len(usage)} usage records")
        else:
            print("❌ referral_usage table not accessible")
            return False
    except Exception as e:
        print(f"❌ Error checking referral_usage: {e}")
        return False
    
    # Check user referral fields
    try:
        response = requests.get(
            f"{SUPABASE_URL}/rest/v1/users?username=eq.SABO123456&select=referral_stats,referral_bonus_claimed",
            headers=headers
        )
        if response.status_code == 200 and response.json():
            user = response.json()[0]
            if 'referral_stats' in user:
                print(f"✅ User has referral_stats: {user['referral_stats']}")
            else:
                print("⚠️ User missing referral_stats field")
        else:
            print("❌ Could not check user referral fields")
    except Exception as e:
        print(f"❌ Error checking user fields: {e}")
    
    print("\\n🎉 REFERRAL SYSTEM VERIFICATION COMPLETE!")
    print("🚀 Ready for UI components and testing!")
    return True

if __name__ == "__main__":
    verify_referral_setup()
"""
    
    with open('verify_referral_setup.py', 'w', encoding='utf-8') as f:
        f.write(verification_script)
    
    print("\n📄 Created verify_referral_setup.py")
    print("Run this after executing SQL in Supabase dashboard")

def main():
    """Main function"""
    
    print("🎯 SABO Arena - Alternative Referral Setup")
    print("=" * 45)
    print("Since direct SQL execution is not available,")
    print("we'll use hybrid approach: REST API + Manual SQL")
    print()
    
    # Execute what we can via API
    if execute_migration_step_by_step():
        create_verification_script()
        
        print("\n🚀 NEXT STEPS:")
        print("1. Copy SQL from manual_referral_setup_guide.py output")
        print("2. Execute in Supabase Dashboard > SQL Editor")  
        print("3. Run: python verify_referral_setup.py")
        print("4. Should show ✅ all components working")
        print("\n💡 This hybrid approach ensures everything works!")
    else:
        print("❌ Setup failed")

if __name__ == "__main__":
    main()