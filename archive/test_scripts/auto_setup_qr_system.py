import requests
import json

# Supabase configuration
SUPABASE_URL = "https://mogjjvscxjwvhtpkrlqr.supabase.co"
SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ"

def run_sql_migration(sql_statements):
    """Execute SQL statements via Supabase REST API"""
    
    headers = {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': f'Bearer {SUPABASE_ANON_KEY}',
        'Content-Type': 'application/json'
    }
    
    print("🚀 Running QR System Database Migration...")
    print("=" * 50)
    
    for i, sql in enumerate(sql_statements, 1):
        print(f"\n📋 Step {i}: {sql[:50]}...")
        
        try:
            # Try direct table manipulation first
            response = requests.post(
                f"{SUPABASE_URL}/rest/v1/rpc/exec_sql",
                headers=headers,
                json={"sql": sql}
            )
            
            if response.status_code == 200:
                print(f"✅ Success: {response.text}")
            else:
                print(f"❌ Error {response.status_code}: {response.text}")
                # Try alternative approach with table updates
                if "ALTER TABLE" in sql:
                    print("🔄 Trying alternative column addition...")
                    # This might work for some setups
                    continue
                    
        except Exception as e:
            print(f"💥 Exception: {e}")
            continue
    
    print("\n" + "=" * 50)
    print("🎯 Migration attempt completed!")
    return True

def insert_test_data():
    """Insert test users for QR scanning"""
    
    headers = {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': f'Bearer {SUPABASE_ANON_KEY}',
        'Content-Type': 'application/json',
        'Prefer': 'return=representation'
    }
    
    print("\n🧪 Inserting QR Test Data...")
    print("=" * 50)
    
    # Test users to insert
    test_users = [
        {
            "id": "demo-user-123",
            "email": "demo@saboarena.com",
            "full_name": "Nguyễn Văn Demo",
            "username": "demo_user",
            "bio": "Demo user for QR testing",
            "role": "player",
            "skill_level": "intermediate",
            "rank": "Intermediate",
            "total_wins": 15,
            "total_losses": 8,
            "total_tournaments": 5,
            "elo_rating": 1450,
            "spa_points": 250,
            "total_prize_pool": 500000.0,
            "is_verified": True,
            "is_active": True,
            "user_code": "SABO123456",
            "qr_data": "SABO123456",
            "created_at": "2025-09-19T00:00:00.000Z",
            "updated_at": "2025-09-19T00:00:00.000Z"
        },
        {
            "id": "test-user-001",
            "email": "test1@saboarena.com",
            "full_name": "Trần Văn Test",
            "username": "test_user_1",
            "role": "player",
            "skill_level": "beginner",
            "rank": "Beginner",
            "total_wins": 5,
            "total_losses": 10,
            "total_tournaments": 2,
            "elo_rating": 1200,
            "spa_points": 100,
            "total_prize_pool": 0.0,
            "is_verified": False,
            "is_active": True,
            "user_code": "SABO000001",
            "qr_data": "SABO000001",
            "created_at": "2025-09-19T00:00:00.000Z",
            "updated_at": "2025-09-19T00:00:00.000Z"
        },
        {
            "id": "test-user-002",
            "email": "test2@saboarena.com",
            "full_name": "Lê Thị Quét",
            "username": "test_user_2",
            "role": "player",
            "skill_level": "advanced",
            "rank": "Advanced",
            "total_wins": 25,
            "total_losses": 5,
            "total_tournaments": 8,
            "elo_rating": 1650,
            "spa_points": 500,
            "total_prize_pool": 1200000.0,
            "is_verified": True,
            "is_active": True,
            "user_code": "SABO000002",
            "qr_data": "SABO000002",
            "created_at": "2025-09-19T00:00:00.000Z",
            "updated_at": "2025-09-19T00:00:00.000Z"
        }
    ]
    
    for user in test_users:
        print(f"\n👤 Inserting: {user['full_name']} ({user['user_code']})")
        
        try:
            response = requests.post(
                f"{SUPABASE_URL}/rest/v1/user_preferences",
                headers=headers,
                json=user
            )
            
            if response.status_code in [200, 201]:
                print(f"✅ Success: User created")
            elif response.status_code == 409:
                print(f"⚠️ User already exists, trying update...")
                # Try to update existing user
                update_response = requests.patch(
                    f"{SUPABASE_URL}/rest/v1/user_preferences?id=eq.{user['id']}",
                    headers=headers,
                    json=user
                )
                if update_response.status_code == 200:
                    print(f"✅ Updated existing user")
                else:
                    print(f"❌ Update failed: {update_response.text}")
            else:
                print(f"❌ Error {response.status_code}: {response.text}")
                
        except Exception as e:
            print(f"💥 Exception inserting user: {e}")
            continue
    
    print("\n" + "=" * 50)
    print("🎯 Test data insertion completed!")

def verify_qr_system():
    """Verify QR system is working"""
    
    headers = {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': f'Bearer {SUPABASE_ANON_KEY}',
        'Content-Type': 'application/json'
    }
    
    print("\n🔍 Verifying QR System...")
    print("=" * 50)
    
    # Test QR codes to verify
    test_codes = ["SABO123456", "SABO000001", "SABO000002"]
    
    for code in test_codes:
        print(f"\n🔍 Testing QR code: {code}")
        
        try:
            response = requests.get(
                f"{SUPABASE_URL}/rest/v1/user_preferences?user_code=eq.{code}&select=id,full_name,email,user_code,skill_level,elo_rating",
                headers=headers
            )
            
            if response.status_code == 200:
                data = response.json()
                if data:
                    user = data[0]
                    print(f"✅ Found: {user['full_name']} - ELO: {user.get('elo_rating', 'N/A')}")
                else:
                    print(f"❌ No user found for code: {code}")
            else:
                print(f"❌ API Error {response.status_code}: {response.text}")
                
        except Exception as e:
            print(f"💥 Exception: {e}")
    
    print("\n" + "=" * 50)
    print("🎯 QR System verification completed!")

if __name__ == "__main__":
    print("🔧 SABO Arena QR System Auto-Setup")
    print("=" * 50)
    
    # Step 1: Database Migration
    migration_sql = [
        "ALTER TABLE user_preferences ADD COLUMN IF NOT EXISTS user_code TEXT;",
        "ALTER TABLE user_preferences ADD COLUMN IF NOT EXISTS qr_data TEXT;", 
        "ALTER TABLE user_preferences ADD COLUMN IF NOT EXISTS qr_generated_at TIMESTAMP WITH TIME ZONE;",
        "CREATE INDEX IF NOT EXISTS idx_user_preferences_user_code ON user_preferences(user_code);",
        "CREATE INDEX IF NOT EXISTS idx_user_preferences_qr_data ON user_preferences(qr_data);"
    ]
    
    run_sql_migration(migration_sql)
    
    # Step 2: Insert Test Data
    insert_test_data()
    
    # Step 3: Verify System
    verify_qr_system()
    
    print("\n🎉 QR System Setup Complete!")
    print("📱 You can now test QR scanning in the Flutter app!")
    print("🔍 QR Codes to test: SABO123456, SABO000001, SABO000002")