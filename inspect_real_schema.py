import requests
import json

# Supabase connection details with service role
SUPABASE_URL = "https://mogjjvscxjwvhtpkrlqr.supabase.co"
SERVICE_ROLE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo"

headers = {
    'apikey': SERVICE_ROLE_KEY,
    'Authorization': f'Bearer {SERVICE_ROLE_KEY}',
    'Content-Type': 'application/json'
}

def inspect_database_schema():
    print("=== INSPECTING DATABASE SCHEMA ===\n")
    
    # Query to get all tables and their columns
    query = """
    SELECT 
        t.table_name,
        c.column_name,
        c.data_type,
        c.is_nullable,
        c.column_default
    FROM 
        information_schema.tables t
    LEFT JOIN 
        information_schema.columns c ON t.table_name = c.table_name
    WHERE 
        t.table_schema = 'public'
        AND t.table_type = 'BASE TABLE'
    ORDER BY 
        t.table_name, c.ordinal_position;
    """
    
    try:
        response = requests.post(
            f"{SUPABASE_URL}/rest/v1/rpc/execute_sql",
            headers=headers,
            json={"query": query}
        )
        
        if response.status_code != 200:
            # Try alternative method using direct SQL
            print("Trying alternative method...")
            
            # Get list of tables first
            tables_query = """
            SELECT table_name 
            FROM information_schema.tables 
            WHERE table_schema = 'public' 
            AND table_type = 'BASE TABLE'
            ORDER BY table_name;
            """
            
            # Use PostgREST to execute
            rest_response = requests.get(
                f"{SUPABASE_URL}/rest/v1/rpc/execute_raw_sql",
                headers=headers,
                params={"sql": tables_query}
            )
            
            if rest_response.status_code != 200:
                print(f"Error: {rest_response.status_code} - {rest_response.text}")
                return
                
        print("Schema inspection results:")
        print(json.dumps(response.json(), indent=2))
        
    except Exception as e:
        print(f"Error inspecting schema: {e}")

def check_specific_tables():
    print("\n=== CHECKING SPECIFIC TABLES ===\n")
    
    # Check for club-related tables
    club_tables = ['clubs', 'club_members', 'club_memberships']
    
    for table in club_tables:
        try:
            response = requests.get(
                f"{SUPABASE_URL}/rest/v1/{table}",
                headers=headers,
                params={"select": "*", "limit": "0"}  # Just check if table exists
            )
            
            if response.status_code == 200:
                print(f"✅ Table '{table}' exists")
            else:
                print(f"❌ Table '{table}' does not exist - Status: {response.status_code}")
                
        except Exception as e:
            print(f"❌ Error checking table '{table}': {e}")

def check_functions():
    print("\n=== CHECKING FUNCTIONS ===\n")
    
    functions_query = """
    SELECT 
        routine_name,
        routine_type,
        specific_name
    FROM 
        information_schema.routines
    WHERE 
        routine_schema = 'public'
        AND routine_name LIKE '%rank%'
    ORDER BY routine_name;
    """
    
    try:
        # For now, let's just list what we know about functions
        print("Checking for rank-related functions...")
        
        # Try to call the function to see if it exists
        response = requests.post(
            f"{SUPABASE_URL}/rest/v1/rpc/get_pending_rank_change_requests",
            headers=headers,
            json={}
        )
        
        if response.status_code == 200:
            print("✅ Function 'get_pending_rank_change_requests' exists and is callable")
        else:
            print(f"❌ Function issue - Status: {response.status_code}")
            print(f"Response: {response.text}")
            
    except Exception as e:
        print(f"Error checking functions: {e}")

if __name__ == "__main__":
    inspect_database_schema()
    check_specific_tables()
    check_functions()