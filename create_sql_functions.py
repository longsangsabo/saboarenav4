#!/usr/bin/env python3
"""
Script to create necessary SQL functions for tournament registration
"""

from supabase import create_client, Client

# Supabase configuration
SUPABASE_URL = "https://mogjjvscxjwvhtpkrlqr.supabase.co"
SUPABASE_SERVICE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo"

def main():
    try:
        # Initialize Supabase client
        supabase: Client = create_client(SUPABASE_URL, SUPABASE_SERVICE_KEY)
        print("✅ Connected to Supabase with service role")
        
        # SQL to create increment function
        increment_sql = '''
        CREATE OR REPLACE FUNCTION increment_tournament_participants(tournament_id UUID)
        RETURNS void 
        LANGUAGE sql
        AS $$
          UPDATE tournaments 
          SET current_participants = current_participants + 1,
              updated_at = NOW()
          WHERE id = tournament_id;
        $$;
        '''
        
        # SQL to create decrement function
        decrement_sql = '''
        CREATE OR REPLACE FUNCTION decrement_tournament_participants(tournament_id UUID)
        RETURNS void
        LANGUAGE sql  
        AS $$
          UPDATE tournaments 
          SET current_participants = GREATEST(current_participants - 1, 0),
              updated_at = NOW()
          WHERE id = tournament_id;
        $$;
        '''
        
        print("🔧 Creating increment_tournament_participants function...")
        result = supabase.rpc('exec', {'sql': increment_sql}).execute()
        print("✅ increment_tournament_participants function created")
        
        print("🔧 Creating decrement_tournament_participants function...")
        result = supabase.rpc('exec', {'sql': decrement_sql}).execute()
        print("✅ decrement_tournament_participants function created")
        
        # Grant permissions
        grant_sql = '''
        GRANT EXECUTE ON FUNCTION increment_tournament_participants(UUID) TO authenticated;
        GRANT EXECUTE ON FUNCTION decrement_tournament_participants(UUID) TO authenticated;
        '''
        
        print("🔧 Granting permissions...")
        result = supabase.rpc('exec', {'sql': grant_sql}).execute()
        print("✅ Permissions granted")
        
        print("\n🎯 SQL functions created successfully! Ready for tournament registration testing.")
        
    except Exception as e:
        print(f"❌ Error: {e}")
        print("ℹ️  Functions might already exist or need to be created through Supabase SQL editor")

if __name__ == "__main__":
    main()