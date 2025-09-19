import os
import json
from supabase import create_client, Client

def check_actual_database_schema():
    """Check the actual database schema structure"""
    
    with open('env.json', 'r') as f:
        env_vars = json.load(f)
    
    url = env_vars.get('SUPABASE_URL')
    service_key = env_vars.get('SUPABASE_SERVICE_ROLE_KEY')
    supabase: Client = create_client(url, service_key)
    
    print("🔍 Database Schema Analysis")
    print("=" * 50)
    
    # Check referral_codes table structure
    print("\n📋 referral_codes table:")
    codes_response = supabase.table('referral_codes').select('*').limit(1).execute()
    
    if codes_response.data and len(codes_response.data) > 0:
        sample_record = codes_response.data[0]
        print("   Columns found:")
        for column, value in sample_record.items():
            print(f"   • {column}: {type(value).__name__}")
    else:
        print("   No records to analyze schema")
    
    # Check referral_usage table structure  
    print("\n📋 referral_usage table:")
    usage_response = supabase.table('referral_usage').select('*').limit(1).execute()
    
    if usage_response.data and len(usage_response.data) > 0:
        sample_record = usage_response.data[0]
        print("   Columns found:")
        for column, value in sample_record.items():
            print(f"   • {column}: {type(value).__name__}")
    else:
        print("   No records to analyze schema")

if __name__ == "__main__":
    check_actual_database_schema()