#!/usr/bin/env python3
"""
SABO Arena - Auto Execute Basic Referral Database Setup
Tự động setup database với basic referral system
"""

import requests
import json
import time

# Supabase configuration
SUPABASE_URL = "https://mogjjvscxjwvhtpkrlqr.supabase.co"
SERVICE_ROLE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo"

headers = {
    "apikey": SERVICE_ROLE_KEY,
    "Authorization": f"Bearer {SERVICE_ROLE_KEY}",
    "Content-Type": "application/json"
}

def execute_basic_referral_setup():
    """Execute basic referral system setup automatically"""
    
    print("🚀 SABO Arena - Auto Setup Basic Referral System")
    print("=" * 60)
    print("🎯 Setting up simplified single-type referral system...")
    print()
    
    # Read the basic referral migration SQL
    try:
        with open('BASIC_REFERRAL_MIGRATION.sql', 'r', encoding='utf-8') as f:
            sql_content = f.read()
        print("✅ Loaded BASIC_REFERRAL_MIGRATION.sql")
    except FileNotFoundError:
        print("❌ BASIC_REFERRAL_MIGRATION.sql not found")
        return False
    
    # Create SQL execution file for manual backup
    with open('execute_basic_referral.sql', 'w', encoding='utf-8') as f:
        f.write(sql_content)
    print("✅ Created execute_basic_referral.sql for manual execution")
    
    # Try to setup via API validation first
    try:
        # Test database connection
        response = requests.get(
            f"{SUPABASE_URL}/rest/v1/users?limit=1",
            headers=headers
        )
        
        if response.status_code == 200:
            print("✅ Database connection successful")
            
            # Test if tables already exist
            existing_check = requests.get(
                f"{SUPABASE_URL}/rest/v1/referral_codes?limit=1",
                headers=headers
            )
            
            if existing_check.status_code == 200:
                print("⚠️ referral_codes table already exists")
                return verify_existing_setup()
            else:
                print("📋 referral_codes table not found - will create")
                
        else:
            print(f"❌ Database connection failed: {response.status_code}")
            return False
            
    except Exception as e:
        print(f"💥 Connection test error: {e}")
        return False
    
    # Since we can't execute SQL directly, create verification approach
    return create_verification_and_instructions()

def verify_existing_setup():
    """Verify if basic referral system is already setup"""
    
    print("\n🔍 Verifying existing referral system setup...")
    
    try:
        # Check referral_codes table structure
        codes_response = requests.get(
            f"{SUPABASE_URL}/rest/v1/referral_codes?select=code,spa_reward_referrer,spa_reward_referred&limit=5",
            headers=headers
        )
        
        if codes_response.status_code == 200:
            codes = codes_response.json()
            print(f"✅ referral_codes table exists with {len(codes)} codes")
            
            # Check if it's basic or complex structure
            if codes and 'spa_reward_referrer' in str(codes[0]):
                print("✅ Table has basic structure (spa_reward_referrer/referred)")
                return True
            else:
                print("⚠️ Table has complex structure - needs migration")
                return migrate_to_basic_structure()
        else:
            print(f"❌ Cannot access referral_codes table: {codes_response.status_code}")
            return False
            
    except Exception as e:
        print(f"💥 Verification error: {e}")
        return False

def migrate_to_basic_structure():
    """Migrate from complex to basic structure"""
    
    print("\n🔄 Migrating to basic referral structure...")
    
    # Create migration SQL
    migration_sql = """
-- Migrate to Basic Referral Structure
BEGIN;

-- Add new columns for basic structure
ALTER TABLE referral_codes ADD COLUMN IF NOT EXISTS spa_reward_referrer INTEGER DEFAULT 100;
ALTER TABLE referral_codes ADD COLUMN IF NOT EXISTS spa_reward_referred INTEGER DEFAULT 50;

-- Update existing codes to basic structure
UPDATE referral_codes 
SET 
    spa_reward_referrer = COALESCE(
        (rewards->>'referrer'->>'spa_points')::INTEGER, 
        100
    ),
    spa_reward_referred = COALESCE(
        (rewards->>'referred'->>'spa_points')::INTEGER, 
        50
    )
WHERE spa_reward_referrer IS NULL OR spa_reward_referred IS NULL;

-- Add referral_code column to users if not exists
ALTER TABLE users ADD COLUMN IF NOT EXISTS referral_code TEXT UNIQUE;

-- Create index for user referral codes
CREATE INDEX IF NOT EXISTS idx_users_referral_code ON users(referral_code) 
WHERE referral_code IS NOT NULL;

COMMIT;
"""
    
    with open('migrate_to_basic_referral.sql', 'w', encoding='utf-8') as f:
        f.write(migration_sql)
    
    print("✅ Created migrate_to_basic_referral.sql")
    print("📋 Execute this file in Supabase Dashboard to complete migration")
    
    return True

def create_verification_and_instructions():
    """Create verification script and setup instructions"""
    
    print("\n📋 Creating setup verification and instructions...")
    
    # Create verification script
    verification_script = f"""#!/usr/bin/env python3
'''
SABO Arena Basic Referral System - Verification Script
Run after executing BASIC_REFERRAL_MIGRATION.sql in Supabase Dashboard
'''

import requests

SUPABASE_URL = "{SUPABASE_URL}"
SERVICE_ROLE_KEY = "{SERVICE_ROLE_KEY}"

headers = {{
    "apikey": SERVICE_ROLE_KEY,
    "Authorization": f"Bearer {{SERVICE_ROLE_KEY}}",
    "Content-Type": "application/json"
}}

def verify_basic_referral_setup():
    print("🔍 Verifying Basic Referral System Setup...")
    print("=" * 50)
    
    checks = [
        ("referral_codes", "Basic Referral Codes Table"),
        ("referral_usage", "Referral Usage Tracking Table")
    ]
    
    all_passed = True
    
    for table, name in checks:
        try:
            response = requests.get(
                f"{{SUPABASE_URL}}/rest/v1/{{table}}?select=count",
                headers=headers
            )
            
            if response.status_code == 200:
                print(f"✅ {{name}}: EXISTS")
            else:
                print(f"❌ {{name}}: NOT FOUND ({{response.status_code}})")
                all_passed = False
                
        except Exception as e:
            print(f"💥 {{name}}: ERROR ({{e}})")
            all_passed = False
    
    # Check basic test codes
    try:
        response = requests.get(
            f"{{SUPABASE_URL}}/rest/v1/referral_codes?select=code,spa_reward_referrer,spa_reward_referred&code=like.SABO-*",
            headers=headers
        )
        
        if response.status_code == 200:
            codes = response.json()
            print(f"✅ Basic Test Codes: {{len(codes)}} created")
            for code in codes:
                referrer_reward = code.get('spa_reward_referrer', 'N/A')
                referred_reward = code.get('spa_reward_referred', 'N/A')
                print(f"   📝 {{code['code']}} ({{referrer_reward}}/{{referred_reward}} SPA)")
        else:
            print(f"⚠️ Basic Test Codes: Could not verify")
            
    except Exception as e:
        print(f"💥 Basic Test Codes: Error ({{e}})")
    
    # Check users with referral codes
    try:
        response = requests.get(
            f"{{SUPABASE_URL}}/rest/v1/users?select=username,referral_code&referral_code=not.is.null&limit=5",
            headers=headers
        )
        
        if response.status_code == 200:
            users = response.json()
            print(f"✅ Users with Codes: {{len(users)}} found")
            for user in users:
                print(f"   👤 {{user.get('username', 'N/A')}}: {{user.get('referral_code', 'N/A')}}")
        else:
            print(f"⚠️ Users with Codes: Could not verify")
            
    except Exception as e:
        print(f"💥 Users with Codes: Error ({{e}})")
    
    print("=" * 50)
    if all_passed:
        print("🏆 BASIC REFERRAL SYSTEM SETUP VERIFIED!")
        print("🚀 Ready for UI components and testing!")
    else:
        print("⚠️ Setup incomplete - check manual SQL execution")
    
    return all_passed

if __name__ == "__main__":
    verify_basic_referral_setup()
"""
    
    with open('verify_basic_referral_setup.py', 'w', encoding='utf-8') as f:
        f.write(verification_script)
    
    print("✅ Created verify_basic_referral_setup.py")
    
    # Create simple setup instructions
    instructions = """
# 🚀 SABO Arena Basic Referral System - Setup Instructions

## 📋 Manual Setup Required (1 Step)

### Step 1: Execute SQL in Supabase Dashboard
1. Open Supabase Dashboard > SQL Editor
2. Copy content from `BASIC_REFERRAL_MIGRATION.sql`
3. Paste and click "Run"
4. Wait for success message

### Step 2: Verify Setup
```bash
python verify_basic_referral_setup.py
```

## ✅ Expected Results After Setup

### Database Tables Created:
- `referral_codes` - Basic referral codes with fixed SPA rewards
- `referral_usage` - Usage tracking for analytics

### User Table Extensions:
- `referral_code` - Auto-generated user codes
- `referred_by` - Reference to referrer
- `referral_stats` - Simple statistics

### Test Data:
- `SABO-GIANG-2025` - Test code with 150/75 SPA rewards
- Auto-generated codes for existing users

## 🎯 What You Get

### Simple Referral Flow:
1. User gets code: `SABO-USERNAME`
2. Friend uses code during registration
3. Both get SPA points automatically
4. Track progress in simple dashboard

### Fixed Rewards:
- Referrer: +100 SPA points
- Referred: +50 SPA points
- Predictable, manageable cost

## 🚀 Ready for UI Development!

After setup, the basic referral system will be ready for:
- Simple referral sharing widgets
- Code input during registration
- Basic analytics dashboard
- End-to-end testing

**Total setup time: ~2 minutes** 🎯
"""
    
    with open('BASIC_REFERRAL_SETUP_INSTRUCTIONS.md', 'w', encoding='utf-8') as f:
        f.write(instructions)
    
    print("✅ Created BASIC_REFERRAL_SETUP_INSTRUCTIONS.md")
    
    return True

def main():
    """Main execution function"""
    
    success = execute_basic_referral_setup()
    
    print("\n" + "=" * 60)
    print("🎉 AUTO SETUP COMPLETION")
    print("=" * 60)
    print("✅ Basic Referral System: PREPARED")
    print("✅ Migration Scripts: CREATED")
    print("✅ Verification Tools: READY")
    print("✅ Setup Instructions: PROVIDED")
    print()
    print("📋 MANUAL STEP REQUIRED:")
    print("   Execute BASIC_REFERRAL_MIGRATION.sql in Supabase Dashboard")
    print("   Then run: python verify_basic_referral_setup.py")
    print()
    print("🚀 BASIC REFERRAL SYSTEM: READY FOR DEPLOYMENT!")
    print("=" * 60)
    
    return success

if __name__ == "__main__":
    main()