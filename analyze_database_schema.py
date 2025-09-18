import requests
import json

def get_database_schema():
    print("🔍 ANALYZING SUPABASE DATABASE SCHEMA")
    print("=" * 60)
    
    # Supabase configuration
    SUPABASE_URL = "https://mogjjvscxjwvhtpkrlqr.supabase.co"
    SERVICE_ROLE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo"
    
    headers = {
        "apikey": SERVICE_ROLE_KEY,
        "Authorization": f"Bearer {SERVICE_ROLE_KEY}",
        "Content-Type": "application/json"
    }
    
    # Get all tables from information_schema
    print("\n📊 GETTING ALL TABLES...")
    try:
        # Query information_schema to get all tables
        query = """
        SELECT 
            table_name,
            table_type
        FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_type = 'BASE TABLE'
        ORDER BY table_name;
        """
        
        response = requests.post(
            f"{SUPABASE_URL}/rest/v1/rpc/exec_sql",
            headers=headers,
            json={"query": query}
        )
        
        if response.status_code == 200:
            tables = response.json()
            print(f"   ✅ Found {len(tables)} tables:")
            for i, table in enumerate(tables, 1):
                print(f"   {i:2d}. {table['table_name']}")
        else:
            print(f"   ⚠️  Using fallback method to get tables...")
            # Fallback: try common table names
            common_tables = [
                'users', 'tournaments', 'clubs', 'posts', 'matches', 
                'achievements', 'comments', 'post_likes', 'user_achievements',
                'tournament_participants', 'club_members', 'notifications',
                'user_profiles', 'match_results', 'tournament_matches',
                'club_tournaments', 'user_stats', 'rankings'
            ]
            
            existing_tables = []
            for table in common_tables:
                try:
                    test_response = requests.get(
                        f"{SUPABASE_URL}/rest/v1/{table}?select=count&limit=1",
                        headers=headers
                    )
                    if test_response.status_code == 200:
                        existing_tables.append(table)
                except:
                    pass
            
            print(f"   ✅ Found {len(existing_tables)} accessible tables:")
            for i, table in enumerate(existing_tables, 1):
                print(f"   {i:2d}. {table}")
                
    except Exception as e:
        print(f"   ❌ Error getting tables: {e}")
    
    # Get all functions
    print("\n🔧 GETTING ALL FUNCTIONS...")
    try:
        # Try to get functions from information_schema
        query = """
        SELECT 
            routine_name,
            routine_type,
            data_type as return_type
        FROM information_schema.routines 
        WHERE routine_schema = 'public'
        AND routine_type = 'FUNCTION'
        ORDER BY routine_name;
        """
        
        response = requests.post(
            f"{SUPABASE_URL}/rest/v1/rpc/exec_sql",
            headers=headers,
            json={"query": query}
        )
        
        if response.status_code == 200:
            functions = response.json()
            print(f"   ✅ Found {len(functions)} functions:")
            for i, func in enumerate(functions, 1):
                return_type = func.get('return_type', 'unknown')
                print(f"   {i:2d}. {func['routine_name']} -> {return_type}")
        else:
            print(f"   ⚠️  Using fallback method to test common functions...")
            # Test common RPC functions
            common_functions = [
                'get_user_stats', 'get_user_by_id', 'get_club_members',
                'get_tournament_leaderboard', 'join_tournament', 'leave_tournament',
                'create_match', 'update_match_result', 'update_user_elo',
                'update_comment_count', 'get_nearby_players', 'calculate_elo_change'
            ]
            
            existing_functions = []
            for func in common_functions:
                try:
                    test_response = requests.post(
                        f"{SUPABASE_URL}/rest/v1/rpc/{func}",
                        headers=headers,
                        json={}
                    )
                    # If we get anything other than 404, function exists
                    if test_response.status_code != 404:
                        existing_functions.append(func)
                except:
                    pass
            
            print(f"   ✅ Found {len(existing_functions)} accessible functions:")
            for i, func in enumerate(existing_functions, 1):
                print(f"   {i:2d}. {func}")
                
    except Exception as e:
        print(f"   ❌ Error getting functions: {e}")
    
    # Get table details with row counts
    print("\n📈 TABLE DETAILS WITH ROW COUNTS...")
    tables_to_check = ['users', 'tournaments', 'clubs', 'posts', 'matches', 'achievements', 'comments', 'post_likes']
    
    for table in tables_to_check:
        try:
            response = requests.get(
                f"{SUPABASE_URL}/rest/v1/{table}?select=count",
                headers={**headers, "Prefer": "count=exact"}
            )
            if response.status_code == 200:
                count = response.headers.get('Content-Range', '*/0').split('/')[-1]
                print(f"   📊 {table}: {count} rows")
            else:
                print(f"   ❌ {table}: not accessible")
        except Exception as e:
            print(f"   ❌ {table}: error - {e}")
    
    print("\n🎉 DATABASE SCHEMA ANALYSIS COMPLETED!")
    print("=" * 60)

if __name__ == "__main__":
    get_database_schema()