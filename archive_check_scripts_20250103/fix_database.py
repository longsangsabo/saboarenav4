import requests
import json

def fix_database_schema():
    """Quick fix for chat_rooms database schema using HTTP request"""
    
    print("🔧 Starting database schema fix...")
    
    # Database credentials
    supabase_url = "https://mogjjvscxjwvhtpkrlqr.supabase.co"
    service_role_key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo"
    
    # SQL commands to fix the schema
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
    
    headers = {
        "Authorization": f"Bearer {service_role_key}",
        "Content-Type": "application/json",
        "apikey": service_role_key
    }
    
    try:
        for i, sql in enumerate(sql_commands, 1):
            print(f"📝 Executing command {i}/5...")
            
            # Use RPC call to execute SQL
            response = requests.post(
                f"{supabase_url}/rest/v1/rpc/exec_sql",
                headers=headers,
                json={"sql": sql.strip()}
            )
            
            if response.status_code == 200:
                print(f"✅ Command {i} executed successfully")
            else:
                print(f"❌ Command {i} failed: {response.status_code} - {response.text}")
                return False
        
        print("\n🎉 Database schema fix completed successfully!")
        print("\n📊 Summary of changes:")
        print("   ✅ Added user1_id column (UUID, references auth.users)")
        print("   ✅ Added user2_id column (UUID, references auth.users)")
        print("   ✅ Added room_type column (VARCHAR, default: group)")
        print("   ✅ Added last_message_at column (TIMESTAMPTZ)")
        print("   ✅ Created performance indexes")
        print("   ✅ Updated existing room types")
        print("\n🚀 Messaging system should now work without errors!")
        return True
        
    except Exception as e:
        print(f"❌ Error: {e}")
        print("\n💡 Manual fix option:")
        print("   1. Go to Supabase Dashboard > SQL Editor")
        print("   2. Run the SQL commands in database_fix.sql")
        return False

if __name__ == "__main__":
    fix_database_schema()