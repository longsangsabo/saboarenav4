import os
import json
from supabase import create_client, Client

# Load environment variables
with open('env.json') as f:
    env = json.load(f)

url: str = env['SUPABASE_URL']
key: str = env['SUPABASE_ANON_KEY']
supabase: Client = create_client(url, key)

print("🔍 Checking round_number column constraint...")

sql = """
SELECT 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'matches' 
AND column_name IN ('round_number', 'stage_round', 'display_order')
ORDER BY column_name;
"""

try:
    result = supabase.rpc('exec_sql', {'query': sql}).execute()
    
    if result.data:
        print("\n📊 Matches table column info:")
        for row in result.data:
            nullable = "✅ NULL" if row['is_nullable'] == 'YES' else "❌ NOT NULL"
            print(f"  - {row['column_name']}: {row['data_type']} | {nullable} | Default: {row['column_default']}")
    else:
        print("No data returned")
        
except Exception as e:
    print(f"❌ Error: {e}")
    print("\nℹ️  Manual SQL to check:")
    print(sql)
