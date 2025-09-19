import requests
import json

def verify_database_schema():
    print("🔍 VERIFYING SUPABASE DATABASE SCHEMA")
    print("=" * 60)
    
    # Supabase configuration
    SUPABASE_URL = "https://mogjjvscxjwvhtpkrlqr.supabase.co"
    SERVICE_ROLE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo"
    
    headers = {
        "apikey": SERVICE_ROLE_KEY,
        "Authorization": f"Bearer {SERVICE_ROLE_KEY}",
        "Content-Type": "application/json"
    }
    
    # Step 1: Direct SQL query to get all tables
    print("\n📊 GETTING ALL TABLES FROM INFORMATION_SCHEMA...")
    
    tables_query = """
    SELECT 
        table_name,
        table_type
    FROM information_schema.tables 
    WHERE table_schema = 'public' 
    AND table_type = 'BASE TABLE'
    ORDER BY table_name;
    """
    
    try:
        response = requests.post(
            f"{SUPABASE_URL}/rest/v1/rpc/exec_sql",
            headers=headers,
            json={"query": tables_query}
        )
        
        if response.status_code == 200:
            tables = response.json()
            print(f"   ✅ Successfully retrieved {len(tables)} tables:")
            
            for i, table in enumerate(tables, 1):
                print(f"   {i:2d}. {table['table_name']}")
                
            print(f"\n📈 TOTAL TABLES: {len(tables)}")
            
        else:
            print(f"   ❌ Failed to get tables: {response.status_code}")
            print(f"   Error: {response.text}")
            
    except Exception as e:
        print(f"   ❌ Error querying tables: {e}")
    
    # Step 2: Get all functions
    print("\n🔧 GETTING ALL FUNCTIONS FROM INFORMATION_SCHEMA...")
    
    functions_query = """
    SELECT 
        routine_name,
        routine_type,
        data_type as return_type
    FROM information_schema.routines 
    WHERE routine_schema = 'public'
    AND routine_type = 'FUNCTION'
    ORDER BY routine_name;
    """
    
    try:
        response = requests.post(
            f"{SUPABASE_URL}/rest/v1/rpc/exec_sql",
            headers=headers,
            json={"query": functions_query}
        )
        
        if response.status_code == 200:
            functions = response.json()
            print(f"   ✅ Successfully retrieved {len(functions)} functions:")
            
            for i, func in enumerate(functions, 1):
                return_type = func.get('return_type', 'unknown')
                print(f"   {i:2d}. {func['routine_name']} -> {return_type}")
                
            print(f"\n🔧 TOTAL FUNCTIONS: {len(functions)}")
            
        else:
            print(f"   ❌ Failed to get functions: {response.status_code}")
            print(f"   Error: {response.text}")
            
    except Exception as e:
        print(f"   ❌ Error querying functions: {e}")
    
    # Step 3: Get row counts for main tables
    print("\n📈 GETTING ROW COUNTS FOR MAIN TABLES...")
    
    count_queries = {
        'users': "SELECT COUNT(*) as count FROM users;",
        'tournaments': "SELECT COUNT(*) as count FROM tournaments;",
        'clubs': "SELECT COUNT(*) as count FROM clubs;",
        'posts': "SELECT COUNT(*) as count FROM posts;",
        'matches': "SELECT COUNT(*) as count FROM matches;",
        'achievements': "SELECT COUNT(*) as count FROM achievements;",
        'comments': "SELECT COUNT(*) as count FROM comments;",
        'post_likes': "SELECT COUNT(*) as count FROM post_likes;",
    }
    
    for table_name, query in count_queries.items():
        try:
            response = requests.post(
                f"{SUPABASE_URL}/rest/v1/rpc/exec_sql",
                headers=headers,
                json={"query": query}
            )
            
            if response.status_code == 200:
                result = response.json()
                if result and len(result) > 0:
                    count = result[0]['count']
                    print(f"   📊 {table_name}: {count} rows")
                else:
                    print(f"   ⚠️  {table_name}: no data returned")
            else:
                print(f"   ❌ {table_name}: {response.status_code}")
                
        except Exception as e:
            print(f"   ❌ {table_name}: error - {e}")
    
    # Step 4: Check if exec_sql function exists
    print("\n🔍 VERIFYING EXEC_SQL FUNCTION...")
    try:
        test_query = "SELECT 1 as test;"
        response = requests.post(
            f"{SUPABASE_URL}/rest/v1/rpc/exec_sql",
            headers=headers,
            json={"query": test_query}
        )
        
        if response.status_code == 200:
            print("   ✅ exec_sql function is working correctly")
        else:
            print(f"   ❌ exec_sql function error: {response.status_code}")
            print(f"   Response: {response.text}")
            
    except Exception as e:
        print(f"   ❌ exec_sql function test failed: {e}")
    
    print("\n🎉 DATABASE SCHEMA VERIFICATION COMPLETED!")
    print("=" * 60)

if __name__ == "__main__":
    verify_database_schema()