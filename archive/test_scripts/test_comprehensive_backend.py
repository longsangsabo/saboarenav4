#!/usr/bin/env python3
"""
Direct Supabase Client Test for Rank Change Request System
"""

from supabase import create_client, Client
import json
import uuid
from datetime import datetime

# Supabase configuration
SUPABASE_URL = "https://mogjjvscxjwvhtpkrlqr.supabase.co"
ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ"

def test_supabase_connection():
    """Test basic Supabase connection"""
    print("\n🔌 TESTING SUPABASE CONNECTION")
    print("=" * 50)
    
    try:
        client: Client = create_client(SUPABASE_URL, ANON_KEY)
        
        # Test basic table access
        print("📋 Testing basic table access...")
        result = client.table('users').select('id, display_name, rank').limit(3).execute()
        print(f"✅ Users table accessible: {len(result.data)} records found")
        
        # Print some sample data
        for user in result.data[:2]:
            print(f"   User: {user.get('display_name', 'Unknown')} - Rank: {user.get('rank', 'No rank')}")
        
        return client
    except Exception as e:
        print(f"❌ Connection failed: {str(e)}")
        return None

def test_notifications_table(client):
    """Test notifications table structure"""
    print("\n📬 TESTING NOTIFICATIONS TABLE")
    print("=" * 50)
    
    try:
        # Check notifications table structure
        result = client.table('notifications').select('*').limit(1).execute()
        print(f"✅ Notifications table accessible")
        
        if result.data:
            print("📋 Sample notification structure:")
            sample = result.data[0]
            for key in ['id', 'user_id', 'type', 'title', 'data']:
                if key in sample:
                    print(f"   {key}: {type(sample[key]).__name__}")
        
        # Check for existing rank change requests
        result = client.table('notifications').select('*').eq('type', 'rank_change_request').execute()
        print(f"📊 Existing rank change requests: {len(result.data)}")
        
        return True
    except Exception as e:
        print(f"❌ Notifications table test failed: {str(e)}")
        return False

def test_function_calls(client):
    """Test RPC function calls"""
    print("\n🔧 TESTING RPC FUNCTIONS")
    print("=" * 50)
    
    functions_to_test = [
        {
            'name': 'submit_rank_change_request',
            'params': {
                'p_requested_rank': 'gold',
                'p_reason': 'Backend test submission',
                'p_evidence_urls': ['https://example.com/test.jpg']
            }
        },
        {
            'name': 'get_pending_rank_change_requests',
            'params': {}
        },
        {
            'name': 'club_review_rank_change_request',
            'params': {
                'p_request_id': str(uuid.uuid4()),
                'p_approved': True,
                'p_club_comments': 'Test approval'
            }
        },
        {
            'name': 'admin_approve_rank_change_request',
            'params': {
                'p_request_id': str(uuid.uuid4()),
                'p_approved': True,
                'p_admin_comments': 'Test admin approval'
            }
        }
    ]
    
    results = {}
    
    for func_test in functions_to_test:
        func_name = func_test['name']
        params = func_test['params']
        
        print(f"\n📋 Testing {func_name}...")
        try:
            result = client.rpc(func_name, params).execute()
            print(f"✅ Function {func_name} exists and responds")
            
            if hasattr(result, 'data') and result.data:
                print(f"📄 Response preview: {str(result.data)[:200]}...")
                results[func_name] = {
                    'status': 'success',
                    'data': result.data
                }
            else:
                results[func_name] = {
                    'status': 'success',
                    'data': None
                }
                
        except Exception as e:
            error_msg = str(e)
            print(f"⚠️  Function {func_name} error: {error_msg[:200]}...")
            results[func_name] = {
                'status': 'error',
                'error': error_msg
            }
    
    return results

def test_database_schema(client):
    """Test database schema requirements"""
    print("\n🗄️ TESTING DATABASE SCHEMA")
    print("=" * 50)
    
    schema_tests = []
    
    # Test users table
    try:
        result = client.table('users').select('id, display_name, rank').limit(1).execute()
        schema_tests.append(('users table', True, 'Accessible'))
    except Exception as e:
        schema_tests.append(('users table', False, str(e)))
    
    # Test notifications table
    try:
        result = client.table('notifications').select('id, user_id, type, data').limit(1).execute()
        schema_tests.append(('notifications table', True, 'Accessible'))
    except Exception as e:
        schema_tests.append(('notifications table', False, str(e)))
    
    # Test club_members table (corrected name)
    try:
        result = client.table('club_members').select('user_id, club_id, status, role').limit(1).execute()
        schema_tests.append(('club_members table', True, 'Accessible'))
    except Exception as e:
        schema_tests.append(('club_members table', False, str(e)))
    
    # Print results
    for test_name, success, message in schema_tests:
        status = "✅" if success else "❌"
        print(f"{status} {test_name}: {message}")
    
    return schema_tests

def analyze_results(function_results, schema_results):
    """Analyze test results and provide summary"""
    print("\n📊 ANALYSIS SUMMARY")
    print("=" * 50)
    
    # Function analysis
    function_success = 0
    function_total = len(function_results)
    
    print("\n🔧 RPC Functions Status:")
    for func_name, result in function_results.items():
        if result['status'] == 'success':
            function_success += 1
            print(f"✅ {func_name}: Working")
        else:
            print(f"❌ {func_name}: {result['error'][:100]}...")
    
    # Schema analysis
    schema_success = sum(1 for _, success, _ in schema_results if success)
    schema_total = len(schema_results)
    
    print(f"\n🗄️ Database Schema: {schema_success}/{schema_total} tables accessible")
    
    # Overall assessment
    print(f"\n🎯 OVERALL ASSESSMENT:")
    print(f"   Functions: {function_success}/{function_total} responding")
    print(f"   Schema: {schema_success}/{schema_total} tables accessible")
    
    if function_success == function_total and schema_success == schema_total:
        print("🎉 SYSTEM STATUS: FULLY OPERATIONAL")
    elif function_success > 0 and schema_success > 0:
        print("⚠️  SYSTEM STATUS: PARTIALLY OPERATIONAL")
    else:
        print("❌ SYSTEM STATUS: NEEDS ATTENTION")

def main():
    """Run comprehensive backend test"""
    print("🚀 RANK CHANGE REQUEST SYSTEM - COMPREHENSIVE TEST")
    print("=" * 60)
    print(f"🕐 Test started at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    
    # Test connection
    client = test_supabase_connection()
    if not client:
        print("❌ Cannot proceed without Supabase connection")
        return
    
    # Run tests
    notifications_ok = test_notifications_table(client)
    function_results = test_function_calls(client)
    schema_results = test_database_schema(client)
    
    # Analyze results
    analyze_results(function_results, schema_results)
    
    print("\n" + "=" * 60)
    print("🏁 COMPREHENSIVE TESTING COMPLETED")
    print("=" * 60)

if __name__ == "__main__":
    main()