import os
from supabase import create_client, Client

def test_admin_rpc_fix():
    """Test if the admin RPC fix works properly"""
    
    # Supabase configuration
    url = "https://mogjjvscxjwvhtpkrlqr.supabase.co"
    service_role_key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.CxhOgxTU8CxGXXMlwWyJYMxWmDJyPjw7d8fLk5_5JnE"
    anon_key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ"
    
    print("🧪 TESTING ADMIN RPC FIX")
    print("=" * 50)
    
    # Test 1: Check if RPC functions exist
    print("\n📌 Test 1: Check RPC Functions")
    try:
        service_client = create_client(url, service_role_key)
        
        # Get available functions
        functions_result = service_client.rpc('admin_add_all_users_to_tournament', {
            'p_tournament_id': '00000000-0000-0000-0000-000000000000'  # Invalid UUID to test function existence
        })
        print("❌ Function exists but test with invalid UUID should fail (expected)")
    except Exception as e:
        if "does not exist" in str(e) or "function" in str(e).lower():
            print(f"❌ RPC Function NOT EXISTS: {e}")
            print("⚠️  You need to apply admin_rpc_functions.sql to Supabase first!")
            return False
        else:
            print(f"✅ RPC Function EXISTS (got expected error): {e}")
    
    # Test 2: Test with authenticated admin user
    print("\n📌 Test 2: Test Admin Authentication via RPC")
    try:
        # Create client with anon key and authenticate as admin
        anon_client = create_client(url, anon_key)
        
        # Sign in as admin
        admin_email = "longsangsabo@gmail.com"
        admin_password = "123456"  # Use your actual admin password
        
        auth_result = anon_client.auth.sign_in_with_password({
            "email": admin_email,
            "password": admin_password
        })
        
        if auth_result.user:
            print(f"✅ Admin authenticated: {auth_result.user.email}")
            
            # Get a real tournament ID for testing
            tournaments = anon_client.from_('tournaments').select('id, title, status').limit(1).execute()
            
            if tournaments.data:
                tournament_id = tournaments.data[0]['id']
                tournament_title = tournaments.data[0]['title']
                tournament_status = tournaments.data[0]['status']
                
                print(f"📋 Testing with tournament: {tournament_title} ({tournament_status})")
                
                # Test RPC function
                try:
                    result = anon_client.rpc('admin_add_all_users_to_tournament', {
                        'p_tournament_id': tournament_id
                    })
                    print(f"✅ RPC SUCCESS: {result}")
                    return True
                except Exception as rpc_error:
                    print(f"❌ RPC FAILED: {rpc_error}")
                    
                    # Check if it's an authentication issue
                    if "Access denied" in str(rpc_error) or "Only admins" in str(rpc_error):
                        print("🔍 Issue: Admin role not properly set in database")
                    elif "row-level security" in str(rpc_error):
                        print("🔍 Issue: RLS still blocking (RPC function issue)")
                    elif "does not exist" in str(rpc_error):
                        print("🔍 Issue: RPC function not applied to database")
                    else:
                        print("🔍 Issue: Unknown error")
                    
                    return False
            else:
                print("❌ No tournaments found for testing")
                return False
        else:
            print("❌ Admin authentication failed")
            return False
            
    except Exception as e:
        print(f"❌ Test failed: {e}")
        return False

def main():
    print("🎯 ADMIN RLS FIX - FINAL TEST")
    print("Testing if RPC functions solve the RLS issue")
    print("=" * 60)
    
    success = test_admin_rpc_fix()
    
    print("\n" + "=" * 60)
    if success:
        print("🎉 TEST PASSED! Admin RPC functions are working")
        print("✅ Flutter app should now be able to add users to tournaments")
    else:
        print("❌ TEST FAILED! Next steps:")
        print("1. Apply admin_rpc_functions.sql in Supabase SQL Editor")
        print("2. Verify admin role is set in users table")
        print("3. Test again")

if __name__ == "__main__":
    main()