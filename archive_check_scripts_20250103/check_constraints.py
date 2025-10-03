import os
from supabase import create_client, Client

# Service role key for admin operations
SUPABASE_URL = "https://mogjjvscxjwvhtpkrlqr.supabase.co"
SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ"

supabase: Client = create_client(SUPABASE_URL, SUPABASE_ANON_KEY)

# Try to check constraint via RPC or query
sql_query = """
SELECT
    conname AS constraint_name,
    pg_get_constraintdef(oid) AS constraint_definition
FROM pg_constraint
WHERE conrelid = 'tournaments'::regclass
AND contype = 'c';
"""

print("Checking constraints on tournaments table...")
print("=" * 80)

try:
    # Use rpc to execute raw SQL (if available)
    result = supabase.rpc('exec_sql', {'query': sql_query}).execute()
    print(result.data)
except Exception as e:
    print(f"Cannot query constraints via RPC: {e}")
    print("\nPlease run this SQL in Supabase SQL Editor:")
    print("-" * 80)
    print(sql_query)
    print("-" * 80)
