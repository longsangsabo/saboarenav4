import requests
import json

def check_tournament_participants_schema():
    print('🔍 CHECKING TOURNAMENT PARTICIPANTS SCHEMA')
    print('=' * 60)
    
    SUPABASE_URL = "https://mogjjvscxjwvhtpkrlqr.supabase.co"
    SERVICE_ROLE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo"
    
    headers = {
        "apikey": SERVICE_ROLE_KEY,
        "Authorization": f"Bearer {SERVICE_ROLE_KEY}",
        "Content-Type": "application/json"
    }
    
    try:
        print('\n📋 Step 1: Get existing tournament_participants records...')
        
        response = requests.get(
            f"{SUPABASE_URL}/rest/v1/tournament_participants?limit=3",
            headers=headers
        )
        
        if response.status_code == 200:
            participants = response.json()
            if participants:
                print(f'   ✅ Found {len(participants)} existing records')
                print('   📊 Sample record structure:')
                sample = participants[0]
                for key, value in sample.items():
                    print(f'      • {key}: {type(value).__name__} = {value}')
            else:
                print('   ⚠️  No existing records found')
                
                # Let's try to insert a minimal record to see what fields are required
                print('\n📋 Step 2: Testing minimal insert to understand schema...')
                
                test_data = {
                    'tournament_id': '00000000-0000-0000-0000-000000000001',  # fake ID
                    'user_id': '00000000-0000-0000-0000-000000000002',  # fake ID
                }
                
                response = requests.post(
                    f"{SUPABASE_URL}/rest/v1/tournament_participants",
                    headers=headers,
                    json=test_data
                )
                
                print(f'   📊 Test insert response: {response.status_code}')
                print(f'   📊 Response: {response.text}')
                
        else:
            print(f'   ❌ Failed to get records: {response.status_code} - {response.text}')
            
    except Exception as e:
        print(f'   ❌ Error: {e}')

if __name__ == "__main__":
    check_tournament_participants_schema()