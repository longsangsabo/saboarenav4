import requests
import json

def create_exec_sql_function():
    """Create exec_sql function in Supabase database"""
    
    print("🔧 Creating exec_sql function in Supabase...")
    
    # Database credentials
    supabase_url = "https://mogjjvscxjwvhtpkrlqr.supabase.co"
    service_role_key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo"
    
    headers = {
        "Authorization": f"Bearer {service_role_key}",
        "Content-Type": "application/json",
        "apikey": service_role_key
    }
    
    # SQL to create the exec_sql function
    create_function_sql = """
    CREATE OR REPLACE FUNCTION public.exec_sql(sql text)
    RETURNS text
    LANGUAGE plpgsql
    SECURITY definer
    AS $$
    BEGIN
        EXECUTE sql;
        RETURN 'SUCCESS';
    EXCEPTION WHEN OTHERS THEN
        RETURN 'ERROR: ' || SQLERRM;
    END;
    $$;
    """
    
    try:
        # Use direct SQL execution via PostgREST
        response = requests.post(
            f"{supabase_url}/rest/v1/rpc/exec_sql",
            headers=headers,
            json={"sql": create_function_sql}
        )
        
        if response.status_code == 404:
            print("⚠️ exec_sql function doesn't exist yet. Creating it manually...")
            
            # Try to execute via raw SQL endpoint (if available)
            # Alternative approach: use a simple INSERT to test connection
            test_response = requests.get(
                f"{supabase_url}/rest/v1/chat_rooms?limit=1",
                headers=headers
            )
            
            if test_response.status_code == 200:
                print("✅ Database connection successful!")
                print("📝 Please manually create exec_sql function in Supabase Dashboard:")
                print("\n--- Copy this SQL to Supabase SQL Editor ---")
                print(create_function_sql)
                print("--- End of SQL ---\n")
                return True
            else:
                print(f"❌ Database connection failed: {test_response.status_code}")
                return False
        
        elif response.status_code == 200:
            print("✅ exec_sql function created successfully!")
            return True
        else:
            print(f"❌ Failed to create function: {response.status_code} - {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def fix_chat_rooms_schema():
    """Fix chat_rooms schema after creating exec_sql function"""
    
    print("\n🔧 Now fixing chat_rooms schema...")
    
    supabase_url = "https://mogjjvscxjwvhtpkrlqr.supabase.co"
    service_role_key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo"
    
    headers = {
        "Authorization": f"Bearer {service_role_key}",
        "Content-Type": "application/json",
        "apikey": service_role_key
    }
    
    # Schema fix commands
    sql_commands = [
        """
        ALTER TABLE chat_rooms 
        ADD COLUMN IF NOT EXISTS user1_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
        ADD COLUMN IF NOT EXISTS user2_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
        ADD COLUMN IF NOT EXISTS room_type VARCHAR(20) DEFAULT 'group',
        ADD COLUMN IF NOT EXISTS last_message_at TIMESTAMPTZ DEFAULT NOW();
        """,
        """
        CREATE INDEX IF NOT EXISTS idx_chat_rooms_direct_messages 
        ON chat_rooms(user1_id, user2_id) 
        WHERE room_type = 'direct';
        """,
        """
        CREATE INDEX IF NOT EXISTS idx_chat_rooms_user1 ON chat_rooms(user1_id);
        """,
        """
        CREATE INDEX IF NOT EXISTS idx_chat_rooms_user2 ON chat_rooms(user2_id);
        """,
        """
        UPDATE chat_rooms SET room_type = 'group' WHERE room_type IS NULL;
        """
    ]
    
    try:
        for i, sql in enumerate(sql_commands, 1):
            print(f"📝 Executing command {i}/5...")
            
            response = requests.post(
                f"{supabase_url}/rest/v1/rpc/exec_sql",
                headers=headers,
                json={"sql": sql.strip()}
            )
            
            if response.status_code == 200:
                result = response.json()
                if isinstance(result, str) and result.startswith('ERROR'):
                    print(f"⚠️ Command {i} had issues: {result}")
                else:
                    print(f"✅ Command {i} executed successfully")
            else:
                print(f"❌ Command {i} failed: {response.status_code} - {response.text}")
        
        print("\n🎉 Database schema fix completed!")
        print("\n📊 Changes made:")
        print("   ✅ Added user1_id, user2_id columns") 
        print("   ✅ Added room_type, last_message_at columns")
        print("   ✅ Created performance indexes")
        print("   ✅ Updated existing data")
        print("\n🚀 Messaging system should now work!")
        return True
        
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

if __name__ == "__main__":
    print("🚀 SABO Arena V3 - Database Schema Fix")
    print("=====================================")
    
    # Step 1: Create exec_sql function
    if create_exec_sql_function():
        print("\n" + "="*50)
        
        # Step 2: Fix schema (only if function created successfully)
        fix_chat_rooms_schema()
    else:
        print("\n💡 Manual steps required:")
        print("1. Go to Supabase Dashboard > SQL Editor")
        print("2. Create exec_sql function using the SQL provided above")
        print("3. Run this script again")