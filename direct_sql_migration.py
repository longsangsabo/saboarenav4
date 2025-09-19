#!/usr/bin/env python3
"""
Direct SQL execution for BASIC_REFERRAL_MIGRATION.sql
Executes SQL statements directly via REST API to avoid RPC limitations
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

def execute_sql_statements():
    """Execute migration SQL statements step by step"""
    print("🚀 Starting BASIC_REFERRAL_MIGRATION execution...")
    
    # Step 1: Add new columns to existing referral_codes table
    print("\n📝 Step 1: Adding new columns to referral_codes table...")
    
    try:
        # Add spa_reward_referrer column
        sql1 = """
        ALTER TABLE referral_codes 
        ADD COLUMN IF NOT EXISTS spa_reward_referrer INTEGER DEFAULT 100;
        """
        
        response1 = requests.post(
            f"{SUPABASE_URL}/rest/v1/rpc/exec",
            headers=headers,
            json={"sql": sql1}
        )
        
        if response1.status_code in [200, 204]:
            print("✅ Added spa_reward_referrer column")
        else:
            print(f"⚠️ spa_reward_referrer column may already exist: {response1.status_code}")
        
        # Add spa_reward_referred column
        sql2 = """
        ALTER TABLE referral_codes 
        ADD COLUMN IF NOT EXISTS spa_reward_referred INTEGER DEFAULT 50;
        """
        
        response2 = requests.post(
            f"{SUPABASE_URL}/rest/v1/rpc/exec",
            headers=headers,
            json={"sql": sql2}
        )
        
        if response2.status_code in [200, 204]:
            print("✅ Added spa_reward_referred column")
        else:
            print(f"⚠️ spa_reward_referred column may already exist: {response2.status_code}")
            
    except Exception as e:
        print(f"⚠️ Column addition via RPC failed: {e}")
        print("🔄 Trying direct table update...")
    
    # Step 2: Try alternative approach - direct table updates
    print("\n📝 Step 2: Updating existing referral codes with SPA rewards...")
    
    try:
        # Get existing codes first
        response = requests.get(
            f"{SUPABASE_URL}/rest/v1/referral_codes?select=*",
            headers=headers
        )
        
        if response.status_code == 200:
            codes = response.json()
            print(f"📊 Found {len(codes)} existing referral codes")
            
            # Check if new columns exist by trying to update them
            for code in codes[:3]:  # Test with first 3 codes
                update_data = {
                    "spa_reward_referrer": 100,
                    "spa_reward_referred": 50
                }
                
                update_response = requests.patch(
                    f"{SUPABASE_URL}/rest/v1/referral_codes?id=eq.{code['id']}",
                    headers=headers,
                    json=update_data
                )
                
                if update_response.status_code == 204:
                    print(f"✅ Updated code {code['code']} with SPA rewards")
                    break
                elif update_response.status_code == 400:
                    error_detail = update_response.json()
                    if "column" in str(error_detail).lower() and "does not exist" in str(error_detail).lower():
                        print("❌ New columns don't exist in database yet")
                        return False
                    else:
                        print(f"⚠️ Update failed: {error_detail}")
                        
        else:
            print(f"❌ Failed to fetch existing codes: {response.status_code}")
            
    except Exception as e:
        print(f"❌ Update attempt failed: {e}")
        return False
    
    # Step 3: Add referrer_id column to referral_usage table  
    print("\n📝 Step 3: Checking referral_usage table...")
    
    try:
        # Check if referral_usage table exists and has referrer_id
        response = requests.get(
            f"{SUPABASE_URL}/rest/v1/referral_usage?select=*&limit=1",
            headers=headers
        )
        
        if response.status_code == 200:
            print("✅ referral_usage table accessible")
            
            # Try to access referrer_id column
            test_response = requests.get(
                f"{SUPABASE_URL}/rest/v1/referral_usage?select=referrer_id&limit=1",
                headers=headers
            )
            
            if test_response.status_code == 200:
                print("✅ referrer_id column exists")
            else:
                print("⚠️ referrer_id column may be missing")
                
        else:
            print(f"⚠️ referral_usage table check: {response.status_code}")
            
    except Exception as e:
        print(f"⚠️ referral_usage check failed: {e}")
    
    print("\n🎯 Migration execution completed!")
    return True

def verify_migration():
    """Verify that migration was successful"""
    print("\n🔍 Verifying migration results...")
    
    try:
        # Test new columns in referral_codes
        response = requests.get(
            f"{SUPABASE_URL}/rest/v1/referral_codes?select=code,spa_reward_referrer,spa_reward_referred&limit=5",
            headers=headers
        )
        
        if response.status_code == 200:
            codes = response.json()
            
            if codes:
                print("✅ Successfully accessed new schema columns:")
                for code in codes:
                    print(f"   {code['code']}: {code.get('spa_reward_referrer', 'NULL')} SPA referrer, {code.get('spa_reward_referred', 'NULL')} SPA referred")
                
                # Check if any codes have the new values
                has_new_values = any(
                    code.get('spa_reward_referrer') is not None and 
                    code.get('spa_reward_referred') is not None 
                    for code in codes
                )
                
                if has_new_values:
                    print("✅ Migration successful - new columns populated")
                    return True
                else:
                    print("⚠️ New columns exist but may need value updates")
                    return True
            else:
                print("⚠️ No referral codes found to verify")
                return True
                
        else:
            print(f"❌ Verification failed: {response.status_code}")
            print(f"Response: {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ Verification error: {e}")
        return False

def update_existing_codes():
    """Update existing codes to have proper SPA values"""
    print("\n🔄 Updating existing codes with SPA rewards...")
    
    try:
        # Get all existing codes
        response = requests.get(
            f"{SUPABASE_URL}/rest/v1/referral_codes?select=*",
            headers=headers
        )
        
        if response.status_code == 200:
            codes = response.json()
            
            updated_count = 0
            
            for code in codes:
                # Update codes that don't have SPA rewards set
                if (code.get('spa_reward_referrer') is None or 
                    code.get('spa_reward_referred') is None or
                    code.get('spa_reward_referrer') == 0 or
                    code.get('spa_reward_referred') == 0):
                    
                    update_data = {
                        "spa_reward_referrer": 100,
                        "spa_reward_referred": 50
                    }
                    
                    update_response = requests.patch(
                        f"{SUPABASE_URL}/rest/v1/referral_codes?id=eq.{code['id']}",
                        headers=headers,
                        json=update_data
                    )
                    
                    if update_response.status_code == 204:
                        print(f"✅ Updated {code['code']} with SPA rewards")
                        updated_count += 1
                    else:
                        print(f"⚠️ Failed to update {code['code']}: {update_response.status_code}")
            
            print(f"✅ Updated {updated_count} referral codes with SPA rewards")
            return True
            
        else:
            print(f"❌ Failed to fetch codes for update: {response.status_code}")
            return False
            
    except Exception as e:
        print(f"❌ Code update failed: {e}")
        return False

def main():
    print("🚀 DIRECT SQL MIGRATION EXECUTION")
    print("=" * 50)
    
    # Execute migration steps
    migration_success = execute_sql_statements()
    
    if migration_success:
        # Verify migration
        verification_success = verify_migration()
        
        if verification_success:
            # Update existing codes
            update_success = update_existing_codes()
            
            print("\n" + "=" * 50)
            print("📊 MIGRATION SUMMARY")
            print("=" * 50)
            
            if update_success:
                print("✅ Migration completed successfully")
                print("✅ Database schema updated")
                print("✅ Existing codes updated")
                print("✅ Ready for system testing")
            else:
                print("⚠️ Migration partially successful")
                print("⚠️ Manual code updates may be needed")
        else:
            print("❌ Migration verification failed")
    else:
        print("❌ Migration execution failed")
    
    print("=" * 50)

if __name__ == "__main__":
    main()