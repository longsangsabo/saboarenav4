#!/usr/bin/env python3
"""
COMPREHENSIVE AUDIT: RLS Policy and Authentication Analysis
This script performs deep audit to find root cause of RLS failures
"""

import requests
import json
import base64

SUPABASE_URL = "https://mogjjvscxjwvhtpkrlqr.supabase.co"
SERVICE_ROLE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo"
ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ"

def decode_jwt_payload(token):
    """Decode JWT payload to see what's inside"""
    try:
        # JWT format: header.payload.signature
        parts = token.split('.')
        if len(parts) != 3:
            return None
        
        # Decode payload (add padding if needed)
        payload = parts[1]
        payload += '=' * (4 - len(payload) % 4)  # Add padding
        decoded = base64.urlsafe_b64decode(payload)
        return json.loads(decoded)
    except Exception as e:
        print(f"Error decoding JWT: {e}")
        return None

def audit_jwt_tokens():
    """Audit JWT tokens to understand authentication context"""
    print("🔍 AUDIT 1: JWT TOKEN ANALYSIS")
    print("=" * 50)
    
    print("\n📋 SERVICE ROLE KEY Analysis:")
    service_payload = decode_jwt_payload(SERVICE_ROLE_KEY)
    if service_payload:
        print(f"   Role: {service_payload.get('role')}")
        print(f"   ISS: {service_payload.get('iss')}")
        print(f"   REF: {service_payload.get('ref')}")
        print(f"   Expires: {service_payload.get('exp')}")
    
    print("\n📋 ANON KEY Analysis:")
    anon_payload = decode_jwt_payload(ANON_KEY)
    if anon_payload:
        print(f"   Role: {anon_payload.get('role')}")
        print(f"   ISS: {anon_payload.get('iss')}")
        print(f"   REF: {anon_payload.get('ref')}")
        print(f"   Expires: {anon_payload.get('exp')}")
    
    return service_payload, anon_payload

def check_rls_policies():
    """Check current RLS policies on tournament_participants table"""
    print("\n🔍 AUDIT 2: RLS POLICIES ANALYSIS")
    print("=" * 50)
    
    headers = {
        "apikey": SERVICE_ROLE_KEY,
        "Authorization": f"Bearer {SERVICE_ROLE_KEY}",
        "Content-Type": "application/json"
    }
    
    # Query to get RLS policies
    sql_query = """
    SELECT 
        schemaname,
        tablename,
        policyname,
        permissive,
        roles,
        cmd,
        qual,
        with_check
    FROM pg_policies 
    WHERE tablename = 'tournament_participants'
    ORDER BY policyname;
    """
    
    try:
        # Try multiple approaches to get policies
        approaches = [
            ("Direct SQL via rpc", f"{SUPABASE_URL}/rest/v1/rpc/execute_sql", {"sql": sql_query}),
            ("PostgREST query", f"{SUPABASE_URL}/rest/v1/pg_policies?tablename=eq.tournament_participants", None),
        ]
        
        for approach_name, url, payload in approaches:
            print(f"\n📋 Trying {approach_name}...")
            
            if payload:
                response = requests.post(url, headers=headers, json=payload)
            else:
                response = requests.get(url, headers=headers)
            
            print(f"   Status: {response.status_code}")
            if response.status_code == 200:
                data = response.json()
                print(f"   Data type: {type(data)}")
                print(f"   Data: {json.dumps(data, indent=2)[:500]}...")
                return data
            else:
                print(f"   Error: {response.text[:200]}...")
        
        print("   ⚠️  Could not retrieve RLS policies directly")
        return None
        
    except Exception as e:
        print(f"   ❌ Error: {e}")
        return None

def audit_admin_authentication():
    """Check how admin authentication works"""
    print("\n🔍 AUDIT 3: ADMIN AUTHENTICATION FLOW")
    print("=" * 50)
    
    headers = {
        "apikey": SERVICE_ROLE_KEY,
        "Authorization": f"Bearer {SERVICE_ROLE_KEY}",
        "Content-Type": "application/json"
    }
    
    print("📋 Step 1: Get admin users...")
    response = requests.get(
        f"{SUPABASE_URL}/rest/v1/users?select=id,email,role&role=eq.admin&limit=5",
        headers=headers
    )
    
    if response.status_code == 200:
        admins = response.json()
        print(f"   ✅ Found {len(admins)} admin users:")
        for admin in admins:
            print(f"      • {admin['email']} (role: {admin.get('role', 'None')})")
        
        if admins:
            admin_id = admins[0]['id']
            admin_email = admins[0]['email']
            
            print(f"\n📋 Step 2: Test authentication context for {admin_email}...")
            
            # Simulate what happens when admin makes a request
            # This is the key difference - app uses user's JWT token, not service role
            print("   🔍 With SERVICE_ROLE_KEY (what Python script uses):")
            test_insert_with_service_role(admin_id)
            
            print("\n   🔍 With ANON_KEY (what Flutter app might use):")
            test_insert_with_anon_key(admin_id)
            
    else:
        print(f"   ❌ Failed to get admin users: {response.status_code}")

def test_insert_with_service_role(admin_id):
    """Test insert using service role key"""
    headers = {
        "apikey": SERVICE_ROLE_KEY,
        "Authorization": f"Bearer {SERVICE_ROLE_KEY}",
        "Content-Type": "application/json"
    }
    
    # Get a tournament and user for test
    tournament_response = requests.get(
        f"{SUPABASE_URL}/rest/v1/tournaments?select=id&limit=1",
        headers=headers
    )
    
    user_response = requests.get(
        f"{SUPABASE_URL}/rest/v1/users?select=id&role=neq.admin&limit=1",
        headers=headers
    )
    
    if tournament_response.status_code == 200 and user_response.status_code == 200:
        tournament_id = tournament_response.json()[0]['id']
        user_id = user_response.json()[0]['id']
        
        test_participant = {
            'tournament_id': tournament_id,
            'user_id': user_id,
            'registered_at': '2025-09-18T10:00:00Z',
            'status': 'registered',
            'payment_status': 'completed',
        }
        
        response = requests.post(
            f"{SUPABASE_URL}/rest/v1/tournament_participants",
            headers=headers,
            json=test_participant
        )
        
        if response.status_code in [200, 201]:
            print("      ✅ SUCCESS with SERVICE_ROLE_KEY")
            # Clean up
            requests.delete(
                f"{SUPABASE_URL}/rest/v1/tournament_participants?tournament_id=eq.{tournament_id}&user_id=eq.{user_id}",
                headers=headers
            )
        else:
            print(f"      ❌ FAILED with SERVICE_ROLE_KEY: {response.status_code}")
            print(f"         Error: {response.text}")
    else:
        print("      ⚠️  Could not get test data")

def test_insert_with_anon_key(admin_id):
    """Test insert using anon key (simulating Flutter app)"""
    headers = {
        "apikey": ANON_KEY,
        "Authorization": f"Bearer {ANON_KEY}",
        "Content-Type": "application/json"
    }
    
    # Get a tournament and user for test
    tournament_response = requests.get(
        f"{SUPABASE_URL}/rest/v1/tournaments?select=id&limit=1",
        headers=headers
    )
    
    user_response = requests.get(
        f"{SUPABASE_URL}/rest/v1/users?select=id&role=neq.admin&limit=1",
        headers=headers
    )
    
    if tournament_response.status_code == 200 and user_response.status_code == 200:
        tournament_id = tournament_response.json()[0]['id']
        user_id = user_response.json()[0]['id']
        
        test_participant = {
            'tournament_id': tournament_id,
            'user_id': user_id,
            'registered_at': '2025-09-18T10:00:00Z',
            'status': 'registered',
            'payment_status': 'completed',
        }
        
        response = requests.post(
            f"{SUPABASE_URL}/rest/v1/tournament_participants",
            headers=headers,
            json=test_participant
        )
        
        if response.status_code in [200, 201]:
            print("      ✅ SUCCESS with ANON_KEY")
            # Clean up  
            requests.delete(
                f"{SUPABASE_URL}/rest/v1/tournament_participants?tournament_id=eq.{tournament_id}&user_id=eq.{user_id}",
                headers=headers
            )
        else:
            print(f"      ❌ FAILED with ANON_KEY: {response.status_code}")
            print(f"         Error: {response.text}")
            print("         🔍 This might be the root cause!")
    else:
        print("      ⚠️  Could not get test data")

def audit_flutter_vs_python():
    """Compare Flutter app vs Python script approach"""
    print("\n🔍 AUDIT 4: FLUTTER vs PYTHON COMPARISON")
    print("=" * 50)
    
    print("📋 Key Differences Analysis:")
    print("   Python Script:")
    print("      • Uses SERVICE_ROLE_KEY")
    print("      • Bypasses RLS completely")
    print("      • Has full database access")
    print("      • No user authentication context")
    
    print("\n   Flutter App:")
    print("      • Uses ANON_KEY initially")
    print("      • Relies on user authentication")
    print("      • Subject to RLS policies")
    print("      • auth.uid() must match logged-in user")
    
    print("\n   🔍 ROOT CAUSE HYPOTHESIS:")
    print("      1. Flutter app uses user's JWT token")
    print("      2. RLS policies check auth.uid() = logged-in user")
    print("      3. Admin tries to insert with other user's ID")
    print("      4. RLS policy blocks: auth.uid() != user_id")
    print("      5. Even admin role doesn't help if policy is restrictive")

def main():
    print("🚀 COMPREHENSIVE AUDIT: RLS POLICY ROOT CAUSE ANALYSIS")
    print("=" * 70)
    print("Finding the root cause of tournament participants RLS failures...\n")
    
    # Audit 1: JWT Analysis
    service_payload, anon_payload = audit_jwt_tokens()
    
    # Audit 2: RLS Policies
    policies = check_rls_policies()
    
    # Audit 3: Authentication Flow
    audit_admin_authentication()
    
    # Audit 4: Flutter vs Python
    audit_flutter_vs_python()
    
    print("\n" + "=" * 70)
    print("🎯 ROOT CAUSE ANALYSIS SUMMARY:")
    print("=" * 70)
    
    print("\n🔍 LIKELY ROOT CAUSE:")
    print("   1. Flutter app authenticates users with their own JWT tokens")
    print("   2. When admin tries to add user X to tournament:")
    print("      - App sends request with admin's JWT token")
    print("      - But tries to insert record with user_id = X")
    print("      - RLS policy checks: auth.uid() = admin_id ≠ X")
    print("      - Policy blocks the operation")
    
    print("\n💡 SOLUTION OPTIONS:")
    print("   A. Use SERVICE_ROLE_KEY for admin operations (bypass RLS)")
    print("   B. Create more permissive RLS policy for admin role")
    print("   C. Use RPC functions with SECURITY DEFINER")
    
    print("\n📋 NEXT STEPS:")
    print("   1. Check AdminService implementation")
    print("   2. Verify which JWT token is used for requests")
    print("   3. Apply appropriate fix based on findings")

if __name__ == "__main__":
    main()