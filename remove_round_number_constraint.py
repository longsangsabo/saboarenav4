import os
import json
from supabase import create_client, Client

# Load environment variables
with open('env.json') as f:
    env = json.load(f)

url: str = env['SUPABASE_URL']
key: str = env['SUPABASE_ANON_KEY']
supabase: Client = create_client(url, key)

print("🔧 Removing NOT NULL constraint from round_number column...")

# Read SQL file
with open('remove_round_number_constraint.sql', 'r', encoding='utf-8') as f:
    sql = f.read()

# Split by semicolon to execute step by step
statements = [s.strip() for s in sql.split(';') if s.strip() and not s.strip().startswith('--')]

try:
    for i, statement in enumerate(statements):
        if statement:
            print(f"\n📝 Executing statement {i+1}:")
            print(statement[:100] + "..." if len(statement) > 100 else statement)
            
            result = supabase.rpc('exec_sql', {'query': statement}).execute()
            print(f"✅ Statement {i+1} executed successfully")
            
            if result.data:
                print(f"📊 Result: {result.data}")
    
    print("\n✅ Migration completed successfully!")
    print("🎉 round_number is now nullable")
    
except Exception as e:
    print(f"\n❌ Error: {e}")
    print("ℹ️  You may need to execute the SQL manually in Supabase SQL Editor")
