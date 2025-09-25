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

def execute_sql_function():
    print("=== FIXING DATABASE FUNCTION ===\n")
    
    # The SQL to fix the function with correct schema
    sql_script = """
-- FINAL FIX - Based on actual database schema inspection
-- Using real tables: clubs, club_members, users (NOT club_memberships or user_profiles)

DROP FUNCTION IF EXISTS get_pending_rank_change_requests();

CREATE OR REPLACE FUNCTION get_pending_rank_change_requests()
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_user_id UUID;
    v_requests JSON;
    v_is_admin BOOLEAN := false;
    v_user_club_id UUID;
BEGIN
    -- Get authenticated user
    v_user_id := auth.uid();
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'User not authenticated';
    END IF;

    -- Check if user is system admin (using actual users table)
    SELECT COALESCE(
        (SELECT role = 'admin' FROM users WHERE id = v_user_id),
        false
    ) INTO v_is_admin;

    -- Get user's club using actual club_members table
    IF NOT v_is_admin THEN
        -- First check if user is a member of any club
        SELECT club_id INTO v_user_club_id
        FROM club_members 
        WHERE user_id = v_user_id 
        AND status = 'active'
        LIMIT 1;
        
        -- Also check if user owns any club
        IF v_user_club_id IS NULL THEN
            SELECT id INTO v_user_club_id
            FROM clubs 
            WHERE owner_id = v_user_id 
            LIMIT 1;
        END IF;
        
        -- If user is not admin and not associated with any club, return empty
        IF v_user_club_id IS NULL THEN
            RETURN '[]'::JSON;
        END IF;
    END IF;

    -- Get pending requests using actual users table
    SELECT json_agg(
        json_build_object(
            'id', n.id,
            'user_id', n.user_id,
            'user_name', COALESCE(
                (SELECT display_name FROM users WHERE id = n.user_id),
                (SELECT full_name FROM users WHERE id = n.user_id),
                'Unknown User'
            ),
            'user_email', COALESCE(
                (SELECT email FROM users WHERE id = n.user_id),
                'unknown@email.com'
            ),
            'user_avatar', (SELECT avatar_url FROM users WHERE id = n.user_id),
            'current_rank', (n.data->>'current_rank'),
            'requested_rank', (n.data->>'requested_rank'),
            'reason', (n.data->>'reason'),
            'evidence_urls', (n.data->'evidence_urls'),
            'submitted_at', (n.data->>'submitted_at'),
            'workflow_status', (n.data->>'workflow_status'),
            'user_club_id', (n.data->>'user_club_id'),
            'created_at', n.created_at
        )
    ) INTO v_requests
    FROM notifications n
    WHERE n.type = 'rank_change_request'
    AND (n.data->>'workflow_status') IN ('pending_club_review', 'pending_admin_review')
    AND (
        v_is_admin OR  -- System admin sees all
        (n.data->>'user_club_id')::UUID = v_user_club_id  -- Club admin sees their club's requests
    )
    ORDER BY n.created_at DESC;

    RETURN COALESCE(v_requests, '[]'::JSON);
END;
$$;

-- Grant permissions
GRANT EXECUTE ON FUNCTION get_pending_rank_change_requests() TO authenticated;

SELECT 'Function created successfully with actual schema' as status;
"""

    try:
        # Execute SQL using PostgREST SQL execute
        response = requests.post(
            f"{SUPABASE_URL}/rest/v1/rpc/execute_sql",
            headers=headers,
            json={"sql": sql_script}
        )
        
        if response.status_code == 200:
            print("✅ Function fixed successfully!")
            result = response.json()
            print(f"Result: {result}")
        else:
            print(f"❌ Error executing SQL: {response.status_code}")
            print(f"Response: {response.text}")
            
            # Try alternative method
            print("\nTrying alternative execution method...")
            
            # Split SQL into individual statements
            statements = sql_script.strip().split(';')
            
            for i, stmt in enumerate(statements):
                stmt = stmt.strip()
                if not stmt:
                    continue
                    
                print(f"Executing statement {i+1}/{len(statements)}: {stmt[:50]}...")
                
                try:
                    # Try to execute via direct query
                    exec_response = requests.post(
                        f"{SUPABASE_URL}/rest/v1/rpc/exec_sql",
                        headers=headers,
                        json={"query": stmt}
                    )
                    
                    if exec_response.status_code == 200:
                        print(f"  ✅ Statement {i+1} executed successfully")
                    else:
                        print(f"  ❌ Statement {i+1} failed: {exec_response.status_code}")
                        print(f"     Error: {exec_response.text}")
                        
                except Exception as e:
                    print(f"  ❌ Statement {i+1} error: {e}")
                    
    except Exception as e:
        print(f"❌ Error: {e}")

def test_function():
    print("\n=== TESTING FUNCTION ===\n")
    
    try:
        # Test the function
        response = requests.post(
            f"{SUPABASE_URL}/rest/v1/rpc/get_pending_rank_change_requests",
            headers=headers,
            json={}
        )
        
        if response.status_code == 200:
            print("✅ Function test successful!")
            result = response.json()
            print(f"Function returned: {json.dumps(result, indent=2)}")
        else:
            print(f"❌ Function test failed: {response.status_code}")
            print(f"Response: {response.text}")
            
    except Exception as e:
        print(f"❌ Test error: {e}")

if __name__ == "__main__":
    execute_sql_function()
    test_function()