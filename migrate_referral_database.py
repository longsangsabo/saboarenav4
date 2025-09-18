import requests
import json

# Supabase configuration
SUPABASE_URL = "https://mogjjvscxjwvhtpkrlqr.supabase.co"
SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ"

def run_sql_query(sql):
    """Execute SQL query on Supabase"""
    
    headers = {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': f'Bearer {SUPABASE_ANON_KEY}',
        'Content-Type': 'application/json'
    }
    
    try:
        # Use PostgREST RPC endpoint for executing SQL
        response = requests.post(
            f"{SUPABASE_URL}/rest/v1/rpc/exec_sql",  
            headers=headers,
            json={"sql": sql}
        )
        
        return response.status_code, response.text
    except Exception as e:
        return 500, str(e)

def migrate_referral_schema():
    """Run referral database migration step by step"""
    
    print("🚀 SABO Arena - Database Migration")
    print("=" * 35)
    
    # Step-by-step migration
    migration_steps = [
        {
            "name": "Create referral_codes table",
            "sql": """
            CREATE TABLE IF NOT EXISTS referral_codes (
                id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                user_id UUID REFERENCES users(id) ON DELETE CASCADE,
                code TEXT UNIQUE NOT NULL,
                code_type TEXT DEFAULT 'general' CHECK (code_type IN ('general', 'vip', 'tournament', 'club')),
                max_uses INTEGER DEFAULT NULL,
                current_uses INTEGER DEFAULT 0,
                rewards JSONB DEFAULT '{"referrer": {"spa_points": 100, "elo_boost": 10}, "referred": {"spa_points": 50, "welcome_bonus": true}}',
                expires_at TIMESTAMP NULL,
                is_active BOOLEAN DEFAULT true,
                created_at TIMESTAMP DEFAULT NOW(),
                updated_at TIMESTAMP DEFAULT NOW()
            );
            """
        },
        {
            "name": "Create referral_usage table", 
            "sql": """
            CREATE TABLE IF NOT EXISTS referral_usage (
                id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                referral_code_id UUID REFERENCES referral_codes(id) ON DELETE CASCADE,
                referrer_id UUID REFERENCES users(id) ON DELETE CASCADE,
                referred_user_id UUID REFERENCES users(id) ON DELETE CASCADE,
                bonus_awarded JSONB NOT NULL,
                status TEXT DEFAULT 'completed' CHECK (status IN ('pending', 'completed', 'failed')),
                used_at TIMESTAMP DEFAULT NOW()
            );
            """
        },
        {
            "name": "Add referral fields to users table",
            "sql": """
            ALTER TABLE users ADD COLUMN IF NOT EXISTS referral_stats JSONB DEFAULT '{"total_referred": 0, "total_earned": 0, "codes_created": 0}';
            ALTER TABLE users ADD COLUMN IF NOT EXISTS referred_by UUID REFERENCES users(id);
            ALTER TABLE users ADD COLUMN IF NOT EXISTS referral_bonus_claimed BOOLEAN DEFAULT false;
            """
        },
        {
            "name": "Create performance indexes",
            "sql": """
            CREATE INDEX IF NOT EXISTS idx_referral_codes_user_id ON referral_codes(user_id);
            CREATE INDEX IF NOT EXISTS idx_referral_codes_code ON referral_codes(code);
            CREATE INDEX IF NOT EXISTS idx_referral_codes_active ON referral_codes(is_active, expires_at);
            CREATE INDEX IF NOT EXISTS idx_referral_usage_referrer ON referral_usage(referrer_id);
            CREATE INDEX IF NOT EXISTS idx_referral_usage_referred ON referral_usage(referred_user_id);
            CREATE INDEX IF NOT EXISTS idx_users_referred_by ON users(referred_by);
            """
        }
    ]
    
    # Alternative: Use direct table operations via REST API
    print("📋 Step 1: Checking existing tables...")
    
    headers = {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': f'Bearer {SUPABASE_ANON_KEY}',
        'Content-Type': 'application/json'
    }
    
    # Check if referral_codes table exists
    try:
        response = requests.get(
            f"{SUPABASE_URL}/rest/v1/referral_codes?limit=1",
            headers=headers
        )
        
        if response.status_code == 200:
            print("✅ referral_codes table already exists")
            tables_exist = True
        else:
            print("❌ referral_codes table doesn't exist")
            tables_exist = False
            
    except Exception as e:
        print(f"⚠️ Cannot check tables: {e}")
        tables_exist = False
    
    # If tables don't exist, we need to create them via SQL
    if not tables_exist:
        print("\n🛠️ Creating tables via manual method...")
        
        # Since we can't execute raw SQL, let's update user referral fields first
        print("📋 Step 2: Adding referral stats to existing user...")
        
        try:
            # Get existing user
            response = requests.get(
                f"{SUPABASE_URL}/rest/v1/users?username=eq.SABO123456&select=id,full_name,username",
                headers=headers
            )
            
            if response.status_code == 200:
                users = response.json()
                if users:
                    user = users[0]
                    user_id = user['id']
                    
                    print(f"✅ Found user: {user['full_name']} ({user['username']})")
                    
                    # Check if referral_stats field exists by trying to update
                    referral_stats = {
                        "total_referred": 0,
                        "total_earned": 0,
                        "codes_created": 0
                    }
                    
                    # Try to add metadata in existing fields for now
                    print("⚠️ Tables need to be created via Supabase dashboard SQL editor")
                    print("📄 Copy and paste the referral_system_schema.sql file")
                    return False
                    
        except Exception as e:
            print(f"💥 Exception: {e}")
            return False
    else:
        print("✅ Tables already exist, ready to create referral codes!")
        return True

def create_referral_codes_direct():
    """Create referral codes directly via API"""
    
    headers = {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': f'Bearer {SUPABASE_ANON_KEY}',
        'Content-Type': 'application/json',
        'Prefer': 'return=representation'
    }
    
    print("\n🎁 Creating referral codes...")
    
    # Get user ID first
    try:
        response = requests.get(
            f"{SUPABASE_URL}/rest/v1/users?username=eq.SABO123456&select=id",
            headers=headers
        )
        
        if response.status_code == 200:
            users = response.json()
            if users:
                user_id = users[0]['id']
                
                # Test referral codes
                test_codes = [
                    {
                        "user_id": user_id,
                        "code": "SABO-GIANG-VIP",
                        "code_type": "vip",
                        "max_uses": 10,
                        "current_uses": 0,
                        "rewards": {
                            "referrer": {"spa_points": 200, "premium_days": 7},
                            "referred": {"spa_points": 100, "premium_trial": 14}
                        },
                        "is_active": True
                    },
                    {
                        "user_id": user_id,
                        "code": "SABO-WELCOME-2025", 
                        "code_type": "general",
                        "max_uses": None,
                        "current_uses": 0,
                        "rewards": {
                            "referrer": {"spa_points": 100, "elo_boost": 10},
                            "referred": {"spa_points": 50, "welcome_bonus": True}
                        },
                        "is_active": True
                    },
                    {
                        "user_id": user_id,
                        "code": "SABO-TOURNAMENT-SPECIAL",
                        "code_type": "tournament",
                        "max_uses": 25,
                        "current_uses": 0,
                        "rewards": {
                            "referrer": {"free_entry_tickets": 2, "spa_points": 150},
                            "referred": {"free_entry_tickets": 1, "practice_mode": True}
                        },
                        "is_active": True
                    }
                ]
                
                created_codes = []
                for code_data in test_codes:
                    print(f"\n👤 Creating: {code_data['code']}")
                    
                    try:
                        response = requests.post(
                            f"{SUPABASE_URL}/rest/v1/referral_codes",
                            headers=headers,
                            json=code_data
                        )
                        
                        if response.status_code in [200, 201]:
                            result = response.json()
                            if result:
                                created_code = result[0] if isinstance(result, list) else result
                                print(f"   ✅ Created successfully!")
                                created_codes.append(created_code)
                        elif response.status_code == 409:
                            print(f"   ⚠️ Code already exists")
                        else:
                            print(f"   ❌ Failed: {response.status_code}")
                            print(f"   Error: {response.text}")
                            
                    except Exception as e:
                        print(f"   💥 Exception: {e}")
                
                return len(created_codes) > 0
                
    except Exception as e:
        print(f"💥 Exception getting user: {e}")
        return False

if __name__ == "__main__":
    print("🚀 SABO Arena - Referral System Migration")
    print("=" * 40)
    
    # Check and create tables
    tables_ready = migrate_referral_schema()
    
    if tables_ready:
        # Create referral codes
        codes_created = create_referral_codes_direct()
        
        if codes_created:
            print(f"\n🎉 MIGRATION SUCCESS!")
            print(f"✅ Referral system ready")
            print(f"✅ Test codes created")
            print(f"\n📱 Next: Run Chrome app and test QR scanning!")
        else:
            print(f"\n⚠️ Tables ready but couldn't create codes")
    else:
        print(f"\n📄 MANUAL STEPS REQUIRED:")
        print(f"1. Open Supabase Dashboard > SQL Editor")
        print(f"2. Copy content from referral_system_schema.sql")
        print(f"3. Execute the SQL script")
        print(f"4. Run this script again")
    
    print("=" * 40)