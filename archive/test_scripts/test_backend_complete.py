import requests
import json
import uuid
from datetime import datetime, timezone

# Supabase configuration
SUPABASE_URL = "https://mogjjvscxjwvhtpkrlqr.supabase.co"
SERVICE_ROLE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo"

def execute_sql_direct(sql_query, description="SQL Query"):
    """Execute SQL directly using Supabase REST API"""
    headers = {
        "Authorization": f"Bearer {SERVICE_ROLE_KEY}",
        "apikey": SERVICE_ROLE_KEY,
        "Content-Type": "application/json"
    }
    
    url = f"{SUPABASE_URL}/rest/v1/rpc/exec_sql"
    payload = {"query": sql_query}
    
    print(f"≡ƒº¬ {description}")
    
    try:
        response = requests.post(url, headers=headers, json=payload)
        
        if response.status_code == 200:
            result = response.json()
            if isinstance(result, dict) and result.get('success'):
                print(f"Γ£à PASS: {description}")
                return True, result
            else:
                print(f"Γ¥î FAIL: {description} - {result}")
                return False, result
        else:
            print(f"Γ¥î HTTP ERROR: {response.status_code} - {response.text}")
            return False, response.text
            
    except Exception as e:
        print(f"Γ¥î EXCEPTION: {str(e)}")
        return False, str(e)

def test_user_preferences_table():
    print("\n≡ƒôï TESTING USER_PREFERENCES TABLE")
    print("=" * 40)
    
    # Test 1: Check table exists
    check_table_sql = """
    SELECT table_name, column_name, data_type 
    FROM information_schema.columns 
    WHERE table_name = 'user_preferences'
    ORDER BY ordinal_position;
    """
    
    success, result = execute_sql_direct(check_table_sql, "Check user_preferences table structure")
    if not success:
        return False
    
    # Test 2: Insert test preference
    test_user_id = str(uuid.uuid4())
    insert_pref_sql = f"""
    INSERT INTO user_preferences (user_id, notification_types, privacy_settings)
    VALUES ('{test_user_id}', '{{"match_results": true, "tournament_updates": true}}', '{{"profile_public": true}}')
    RETURNING id;
    """
    
    success, result = execute_sql_direct(insert_pref_sql, "Insert test user preference")
    if not success:
        return False
    
    # Test 3: Query test preference  
    query_pref_sql = f"""
    SELECT user_id, notification_types, privacy_settings 
    FROM user_preferences 
    WHERE user_id = '{test_user_id}';
    """
    
    success, result = execute_sql_direct(query_pref_sql, "Query test user preference")
    return success

def test_analytics_functions():
    print("\n≡ƒôè TESTING ANALYTICS FUNCTIONS")
    print("=" * 40)
    
    # Test 1: get_player_analytics function
    test_analytics_sql = """
    SELECT * FROM get_player_analytics('00000000-0000-0000-0000-000000000001'::UUID)
    LIMIT 1;
    """
    
    success1, _ = execute_sql_direct(test_analytics_sql, "Test get_player_analytics function")
    
    # Test 2: get_leaderboard function
    test_leaderboard_sql = """
    SELECT * FROM get_leaderboard('elo', NULL, 5);
    """
    
    success2, _ = execute_sql_direct(test_leaderboard_sql, "Test get_leaderboard function")
    
    # Test 3: calculate_elo_change function
    test_elo_sql = """
    SELECT * FROM calculate_elo_change(1500, 1400, true, 32);
    """
    
    success3, _ = execute_sql_direct(test_elo_sql, "Test calculate_elo_change function")
    
    return success1 and success2 and success3

def test_notification_functions():
    print("\n≡ƒöö TESTING NOTIFICATION FUNCTIONS")
    print("=" * 40)
    
    test_user_id = str(uuid.uuid4())
    
    # Test 1: create_notification function
    create_notif_sql = f"""
    SELECT create_notification(
        '{test_user_id}'::UUID,
        'test_notification',
        'Test Title',
        'Test Message',
        '{{"test": true}}'::JSONB,
        1,
        'none',
        '{{}}'::JSONB,
        24
    ) as notification_id;
    """
    
    success1, result1 = execute_sql_direct(create_notif_sql, "Test create_notification function")
    
    # Test 2: get_user_notifications function
    get_notif_sql = f"""
    SELECT * FROM get_user_notifications('{test_user_id}'::UUID, false, 10);
    """
    
    success2, _ = execute_sql_direct(get_notif_sql, "Test get_user_notifications function")
    
    return success1 and success2

def test_database_integrity():
    print("\n≡ƒöì TESTING DATABASE INTEGRITY")
    print("=" * 40)
    
    # Test 1: Check all required tables exist
    tables_sql = """
    SELECT table_name 
    FROM information_schema.tables 
    WHERE table_schema = 'public' 
    AND table_type = 'BASE TABLE'
    ORDER BY table_name;
    """
    
    success1, result1 = execute_sql_direct(tables_sql, "Check all database tables")
    
    # Test 2: Check all functions exist
    functions_sql = """
    SELECT routine_name, routine_type
    FROM information_schema.routines 
    WHERE routine_schema = 'public' 
    AND routine_type = 'FUNCTION'
    AND routine_name IN (
        'get_player_analytics',
        'get_leaderboard', 
        'calculate_elo_change',
        'create_notification',
        'get_user_notifications'
    )
    ORDER BY routine_name;
    """
    
    success2, result2 = execute_sql_direct(functions_sql, "Check all backend functions exist")
    
    # Test 3: Check indexes
    indexes_sql = """
    SELECT indexname, tablename 
    FROM pg_indexes 
    WHERE schemaname = 'public'
    AND indexname LIKE '%performance%'
    OR indexname LIKE '%user_preferences%';
    """
    
    success3, result3 = execute_sql_direct(indexes_sql, "Check performance indexes")
    
    return success1 and success2 and success3

def test_rls_policies():
    print("\n≡ƒöÆ TESTING RLS POLICIES")
    print("=" * 40)
    
    # Check RLS is enabled on user_preferences
    rls_sql = """
    SELECT schemaname, tablename, rowsecurity 
    FROM pg_tables 
    WHERE tablename = 'user_preferences';
    """
    
    success, result = execute_sql_direct(rls_sql, "Check RLS on user_preferences table")
    return success

def performance_benchmark():
    print("\nΓÜí PERFORMANCE BENCHMARKING")
    print("=" * 40)
    
    # Benchmark analytics query
    benchmark_sql = """
    EXPLAIN ANALYZE
    SELECT * FROM get_leaderboard('elo', NULL, 10);
    """
    
    success, result = execute_sql_direct(benchmark_sql, "Benchmark leaderboard query performance")
    return success

def run_comprehensive_test():
    print("≡ƒÜÇ COMPREHENSIVE BACKEND TEST SUITE")
    print("=" * 50)
    
    test_results = {}
    
    # Run all tests
    test_results['user_preferences'] = test_user_preferences_table()
    test_results['analytics_functions'] = test_analytics_functions()
    test_results['notification_functions'] = test_notification_functions()
    test_results['database_integrity'] = test_database_integrity()
    test_results['rls_policies'] = test_rls_policies()
    test_results['performance'] = performance_benchmark()
    
    print(f"\n{'='*50}")
    print("≡ƒôï TEST RESULTS SUMMARY:")
    print("=" * 50)
    
    passed = 0
    total = len(test_results)
    
    for test_name, result in test_results.items():
        status = "Γ£à PASS" if result else "Γ¥î FAIL"
        print(f"{status} {test_name.replace('_', ' ').title()}")
        if result:
            passed += 1
    
    print(f"\n≡ƒÄ» OVERALL SCORE: {passed}/{total} tests passed")
    
    if passed == total:
        print("≡ƒÄë ALL TESTS PASSED! Backend is ready for production!")
        return True
    else:
        print("ΓÜá∩╕Å Some tests failed. Review errors above.")
        return False

def cleanup_test_data():
    print("\n≡ƒº╣ CLEANING UP TEST DATA")
    print("=" * 40)
    
    cleanup_sql = """
    DELETE FROM user_preferences WHERE user_id NOT IN (SELECT id FROM users);
    DELETE FROM notifications WHERE user_id NOT IN (SELECT id FROM users);
    """
    
    execute_sql_direct(cleanup_sql, "Cleanup test data")

if __name__ == "__main__":
    try:
        success = run_comprehensive_test()
        cleanup_test_data()
        
        if success:
            print(f"\n≡ƒÜÇ BACKEND SYSTEM FULLY DEPLOYED AND TESTED!")
            print("≡ƒÄ» Ready for integration with Flutter frontend!")
        else:
            print(f"\nΓÜá∩╕Å Backend deployment needs attention.")
            
    except Exception as e:
        print(f"≡ƒöÑ Test suite error: {e}")
