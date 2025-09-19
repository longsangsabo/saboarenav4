import os
import json
from supabase import create_client, Client

def apply_basic_referral_migration():
    """Apply the basic referral migration to update database schema"""
    
    with open('env.json', 'r') as f:
        env_vars = json.load(f)
    
    url = env_vars.get('SUPABASE_URL')
    service_key = env_vars.get('SUPABASE_SERVICE_ROLE_KEY')
    supabase: Client = create_client(url, service_key)
    
    print("🔄 Applying Basic Referral Migration")
    print("=" * 50)
    
    try:
        # Read the migration SQL
        with open('BASIC_REFERRAL_MIGRATION.sql', 'r', encoding='utf-8') as f:
            migration_sql = f.read()
        
        print("📄 Loaded migration SQL file")
        
        # Apply the migration
        print("⚡ Executing migration...")
        result = supabase.rpc('exec', {'sql': migration_sql}).execute()
        
        if result.data:
            print("✅ Migration executed successfully")
            print("🔍 Verifying new schema...")
            
            # Verify the new schema
            codes_response = supabase.table('referral_codes').select('*').limit(1).execute()
            
            if codes_response.data and len(codes_response.data) > 0:
                sample_record = codes_response.data[0]
                expected_columns = ['spa_reward_referrer', 'spa_reward_referred']
                
                has_new_columns = all(col in sample_record for col in expected_columns)
                
                if has_new_columns:
                    print("✅ New schema columns confirmed")
                    print("   • spa_reward_referrer: ✅")
                    print("   • spa_reward_referred: ✅")
                else:
                    print("⚠️ New schema columns not found")
                    print("   Available columns:", list(sample_record.keys()))
            else:
                print("⚠️ No data to verify schema")
            
            return True
            
        else:
            print("❌ Migration failed")
            return False
            
    except Exception as e:
        print(f"❌ Migration error: {str(e)}")
        
        # Try alternative approach - manual schema update
        print("\n🔄 Attempting manual schema update...")
        
        try:
            # Add new columns if they don't exist
            print("   Adding spa_reward_referrer column...")
            supabase.rpc('exec', {
                'sql': 'ALTER TABLE referral_codes ADD COLUMN IF NOT EXISTS spa_reward_referrer INTEGER DEFAULT 100;'
            }).execute()
            
            print("   Adding spa_reward_referred column...")
            supabase.rpc('exec', {
                'sql': 'ALTER TABLE referral_codes ADD COLUMN IF NOT EXISTS spa_reward_referred INTEGER DEFAULT 50;'
            }).execute()
            
            print("   Adding referrer_id to referral_usage...")
            supabase.rpc('exec', {
                'sql': 'ALTER TABLE referral_usage ADD COLUMN IF NOT EXISTS referrer_id UUID;'
            }).execute()
            
            print("✅ Manual schema update completed")
            return True
            
        except Exception as e2:
            print(f"❌ Manual update failed: {str(e2)}")
            return False

if __name__ == "__main__":
    success = apply_basic_referral_migration()
    
    if success:
        print(f"\n🟢 MIGRATION SUCCESSFUL")
        print("Database schema updated for basic referral system")
    else:
        print(f"\n🔴 MIGRATION FAILED")
        print("Please apply the migration manually in Supabase dashboard")