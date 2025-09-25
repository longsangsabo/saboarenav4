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

def debug_rank_requests():
    print("=== DEBUGGING RANK REQUESTS ===\n")
    
    # 1. First check raw notifications table
    print("1. Checking raw notifications table...")
    try:
        response = requests.get(
            f"{SUPABASE_URL}/rest/v1/notifications",
            headers=headers,
            params={
                "select": "*",
                "type": "eq.rank_change_request",
                "limit": "10"
            }
        )
        
        if response.status_code == 200:
            notifications = response.json()
            print(f"✅ Found {len(notifications)} rank_change_request notifications")
            
            for i, notif in enumerate(notifications):
                print(f"\nNotification {i+1}:")
                print(f"  ID: {notif['id']}")
                print(f"  User ID: {notif['user_id']}")
                print(f"  Created: {notif['created_at']}")
                if 'data' in notif and notif['data']:
                    data = notif['data']
                    print(f"  Workflow Status: {data.get('workflow_status', 'N/A')}")
                    print(f"  Current Rank: {data.get('current_rank', 'N/A')}")
                    print(f"  Requested Rank: {data.get('requested_rank', 'N/A')}")
                    print(f"  User Club ID: {data.get('user_club_id', 'N/A')}")
        else:
            print(f"❌ Error getting notifications: {response.status_code}")
            print(f"Response: {response.text}")
            
    except Exception as e:
        print(f"❌ Error: {e}")

def test_current_function():
    print("\n2. Testing current function...")
    try:
        response = requests.post(
            f"{SUPABASE_URL}/rest/v1/rpc/get_pending_rank_change_requests",
            headers=headers,
            json={}
        )
        
        if response.status_code == 200:
            result = response.json()
            print(f"✅ Function returned: {len(result) if result else 0} requests")
            if result:
                print("Function result:")
                print(json.dumps(result[:2], indent=2))  # Show first 2 results
            else:
                print("❌ Function returned empty array []")
        else:
            print(f"❌ Function error: {response.status_code}")
            print(f"Response: {response.text}")
            
    except Exception as e:
        print(f"❌ Error: {e}")

def check_user_context():
    print("\n3. Checking user context and permissions...")
    
    # Get current user info (if any)
    try:
        # This won't work without user auth, but let's see the error
        response = requests.get(
            f"{SUPABASE_URL}/rest/v1/users",
            headers=headers,
            params={"select": "id,role", "limit": "5"}
        )
        
        if response.status_code == 200:
            users = response.json()
            print(f"✅ Found {len(users)} users in system")
            for user in users[:3]:
                print(f"  User {user['id']}: role = {user.get('role', 'N/A')}")
        
    except Exception as e:
        print(f"User check error: {e}")

def create_debug_function():
    print("\n4. Creating debug version of function...")
    
    debug_sql = """
-- DEBUG VERSION - More detailed logging
DROP FUNCTION IF EXISTS debug_get_pending_rank_change_requests();

CREATE OR REPLACE FUNCTION debug_get_pending_rank_change_requests()
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_user_id UUID;
    v_requests JSON;
    v_is_admin BOOLEAN := false;
    v_user_club_id UUID;
    v_notification_count INTEGER;
BEGIN
    -- Get authenticated user (will be NULL for service role)
    v_user_id := auth.uid();
    
    -- For debugging, if no authenticated user, assume admin access
    IF v_user_id IS NULL THEN
        v_is_admin := true;
        RAISE NOTICE 'No authenticated user - assuming admin access for debug';
    ELSE
        SELECT COALESCE((SELECT role = 'admin' FROM users WHERE id = v_user_id), false) INTO v_is_admin;
        RAISE NOTICE 'User ID: %, Is Admin: %', v_user_id, v_is_admin;
    END IF;

    -- Count total notifications first
    SELECT COUNT(*) INTO v_notification_count 
    FROM notifications 
    WHERE type = 'rank_change_request';
    
    RAISE NOTICE 'Total rank_change_request notifications: %', v_notification_count;

    -- Get pending requests
    WITH ranked_notifications AS (
        SELECT 
            n.id,
            n.user_id,
            n.data,
            n.created_at,
            COALESCE((SELECT display_name FROM users WHERE id = n.user_id), (SELECT full_name FROM users WHERE id = n.user_id), 'Unknown User') as user_name,
            COALESCE((SELECT email FROM users WHERE id = n.user_id), 'unknown@email.com') as user_email,
            (SELECT avatar_url FROM users WHERE id = n.user_id) as user_avatar
        FROM notifications n
        WHERE n.type = 'rank_change_request'
        AND (n.data->>'workflow_status') IN ('pending_club_review', 'pending_admin_review')
        ORDER BY n.created_at DESC
    )
    SELECT json_agg(
        json_build_object(
            'id', rn.id,
            'user_id', rn.user_id,
            'user_name', rn.user_name,
            'user_email', rn.user_email,
            'user_avatar', rn.user_avatar,
            'current_rank', (rn.data->>'current_rank'),
            'requested_rank', (rn.data->>'requested_rank'),
            'reason', (rn.data->>'reason'),
            'evidence_urls', (rn.data->'evidence_urls'),
            'submitted_at', (rn.data->>'submitted_at'),
            'workflow_status', (rn.data->>'workflow_status'),
            'user_club_id', (rn.data->>'user_club_id'),
            'created_at', rn.created_at
        )
    ) INTO v_requests FROM ranked_notifications rn;

    RAISE NOTICE 'Final result count: %', COALESCE(json_array_length(v_requests), 0);
    
    RETURN COALESCE(v_requests, '[]'::JSON);
END;
$$;

GRANT EXECUTE ON FUNCTION debug_get_pending_rank_change_requests() TO authenticated;
GRANT EXECUTE ON FUNCTION debug_get_pending_rank_change_requests() TO service_role;
"""

    print("Debug function created - copy this SQL to Supabase:")
    print("-" * 60)
    print(debug_sql)
    print("-" * 60)

if __name__ == "__main__":
    debug_rank_requests()
    test_current_function()
    check_user_context()
    create_debug_function()