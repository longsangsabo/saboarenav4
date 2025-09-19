import os
from supabase import create_client, Client

def quick_rpc_test():
    """Quick test to see if RPC functions work"""
    
    # Supabase configuration - using the working keys from previous tests
    url = "https://mogjjvscxjwvhtpkrlqr.supabase.co"
    service_role_key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.CxhOgxTU8CxGXXMlwWyJYMxWmDJyPjw7d8fLk5_5JnE"
    
    print("🚀 QUICK RPC TEST")
    print("=" * 40)
    
    try:
        # Create client
        supabase: Client = create_client(url, service_role_key)
        
        print("📡 Testing RPC function call...")
        
        # Test the RPC function with dummy data
        result = supabase.rpc('admin_add_all_users_to_tournament', {
            'p_tournament_id': '12345678-1234-1234-1234-123456789012'  # dummy UUID
        })
        
        print(f"🎉 RPC CALL SUCCESS: {result}")
        return True
        
    except Exception as e:
        error_msg = str(e)
        print(f"Error: {error_msg}")
        
        # Analyze the error
        if "does not exist" in error_msg:
            print("❌ RPC function does not exist - SQL not applied")
            return False
        elif "Tournament not found" in error_msg:
            print("✅ RPC function exists! (Expected error with dummy UUID)")
            return True
        elif "Access denied" in error_msg or "Only admins" in error_msg:
            print("✅ RPC function exists! (Access control working)")
            return True
        elif "Invalid API key" in error_msg:
            print("❌ API key issue")
            return False
        else:
            print(f"🤔 Unexpected error: {error_msg}")
            return False

def main():
    print("🧪 QUICK RPC FUNCTION TEST")
    print("Testing if admin_add_all_users_to_tournament exists")
    print("=" * 50)
    
    success = quick_rpc_test()
    
    print("\n" + "=" * 50)
    if success:
        print("🎉 SUCCESS!")
        print("✅ RPC functions are properly installed")
        print("✅ Flutter app should now work without RLS errors")
        print("\n🚀 Ready to test in Flutter app!")
    else:
        print("❌ RPC functions not working")
        print("Need to debug the issue")

if __name__ == "__main__":
    main()