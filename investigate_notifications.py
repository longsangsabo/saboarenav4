import pyperclip

def create_investigation_query():
    print("=== CREATING INVESTIGATION QUERIES ===\n")
    
    # SQL to investigate all notifications
    investigation_sql = """-- INVESTIGATION: Find all notifications and their types
SELECT 
    type,
    COUNT(*) as count,
    json_agg(
        json_build_object(
            'id', id,
            'user_id', user_id,
            'data', data,
            'created_at', created_at
        ) 
        ORDER BY created_at DESC 
        LIMIT 3
    ) as sample_data
FROM notifications 
GROUP BY type
ORDER BY count DESC;

-- Also check if there are any notifications with different workflow_status
SELECT 
    (data->>'workflow_status') as status,
    COUNT(*) as count
FROM notifications 
WHERE type = 'rank_change_request'
GROUP BY (data->>'workflow_status');

-- Check all notifications in last 7 days
SELECT 
    id,
    type,
    user_id,
    data,
    created_at
FROM notifications 
WHERE created_at >= NOW() - INTERVAL '7 days'
ORDER BY created_at DESC
LIMIT 10;"""

    try:
        pyperclip.copy(investigation_sql)
        print("✅ Investigation SQL copied to clipboard!")
        print("\n📋 PASTE IN SUPABASE SQL EDITOR:")
        print("This will show:")
        print("1. All notification types and counts")
        print("2. All workflow statuses for rank requests")
        print("3. Recent notifications in last 7 days")
        
        print("\n🔍 AFTER RUNNING THIS:")
        print("- We'll see exactly what notifications exist")
        print("- Find the correct type/status for rank requests")
        print("- Understand why function returns empty")
        
        return True
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

if __name__ == "__main__":
    create_investigation_query()