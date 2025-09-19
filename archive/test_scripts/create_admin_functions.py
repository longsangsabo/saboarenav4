import requests
import json

def create_admin_functions():
    print("🔧 CREATING ADMIN FUNCTIONS FOR TOURNAMENT MANAGEMENT")
    print("=" * 60)
    
    SUPABASE_URL = "https://mogjjvscxjwvhtpkrlqr.supabase.co"
    SERVICE_ROLE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo"
    
    headers = {
        "apikey": SERVICE_ROLE_KEY,
        "Authorization": f"Bearer {SERVICE_ROLE_KEY}",
        "Content-Type": "application/json"
    }
    
    # Read the SQL file and execute it
    with open('scripts/admin_add_all_users_to_tournament.sql', 'r', encoding='utf-8') as f:
        sql_content = f.read()
    
    print("\n📋 Creating admin functions...")
    
    # Since we don't have exec_sql, we'll need to create the function via direct SQL execution
    # Let's try using PostgREST's ability to execute SQL through raw queries
    
    # First, let's try to create a simple exec_sql function
    exec_sql_function = """
    CREATE OR REPLACE FUNCTION public.exec_sql(query text)
    RETURNS json
    LANGUAGE plpgsql
    SECURITY DEFINER
    AS $$
    DECLARE
        result json;
    BEGIN
        EXECUTE format('SELECT array_to_json(array_agg(row_to_json(t))) FROM (%s) t', query) INTO result;
        RETURN COALESCE(result, '[]'::json);
    EXCEPTION
        WHEN OTHERS THEN
            RETURN json_build_object(
                'error', SQLERRM,
                'code', SQLSTATE,
                'query', query
            );
    END;
    $$;
    """
    
    print("   🔧 Attempting to create exec_sql function first...")
    
    # Try to execute using direct table manipulation (create a temporary way)
    # Since we can't execute raw SQL directly, let's create the function by inserting into pg_proc
    # Actually, let's try a different approach - use Supabase's built-in SQL editor simulation
    
    print("   ⚠️  Cannot execute SQL directly via REST API")
    print("   📝 Please execute the following SQL manually in Supabase SQL Editor:")
    print("   " + "=" * 50)
    print()
    
    # Split the SQL into individual functions for easier copying
    functions = sql_content.split('CREATE OR REPLACE FUNCTION')
    
    for i, func in enumerate(functions[1:], 1):  # Skip empty first element
        print(f"   -- Function {i}: add_all_users_to_tournament")
        print("   CREATE OR REPLACE FUNCTION" + func)
        print("   " + "-" * 40)
    
    print()
    print("   📋 After executing the SQL, the following functions will be available:")
    print("      1. add_all_users_to_tournament(tournament_id, admin_user_id)")
    print("      2. remove_all_users_from_tournament(tournament_id, admin_user_id)")
    
    return True

if __name__ == "__main__":
    create_admin_functions()