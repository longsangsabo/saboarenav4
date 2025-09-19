#!/usr/bin/env python3
'''
SABO Arena Referral System - Final Verification
Run after executing FINAL_REFERRAL_MIGRATION.sql
'''

import requests
import json

SUPABASE_URL = "https://mogjjvscxjwvhtpkrlqr.supabase.co"
SERVICE_ROLE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo"

headers = {
    "apikey": SERVICE_ROLE_KEY,
    "Authorization": f"Bearer {SERVICE_ROLE_KEY}",
    "Content-Type": "application/json"
}

def verify_setup():
    print("🔍 Verifying Referral System Setup...")
    print("=" * 50)
    
    checks = [
        ("referral_codes", "Referral Codes Table"),
        ("referral_usage", "Referral Usage Table")
    ]
    
    all_passed = True
    
    for table, name in checks:
        try:
            response = requests.get(
                f"{SUPABASE_URL}/rest/v1/{table}?select=count",
                headers=headers
            )
            
            if response.status_code == 200:
                print(f"✅ {name}: EXISTS")
            else:
                print(f"❌ {name}: NOT FOUND ({response.status_code})")
                all_passed = False
                
        except Exception as e:
            print(f"💥 {name}: ERROR ({e})")
            all_passed = False
    
    # Check test codes
    try:
        response = requests.get(
            f"{SUPABASE_URL}/rest/v1/referral_codes?select=code,code_type,rewards&code=like.SABO-*",
            headers=headers
        )
        
        if response.status_code == 200:
            codes = response.json()
            print(f"✅ Test Codes: {len(codes)} created")
            for code in codes:
                print(f"   📝 {code['code']} ({code['code_type']})")
        else:
            print(f"⚠️ Test Codes: Could not verify")
            
    except Exception as e:
        print(f"💥 Test Codes: Error ({e})")
    
    print("=" * 50)
    if all_passed:
        print("🏆 REFERRAL SYSTEM SETUP VERIFIED!")
        print("🚀 Ready for UI components and testing!")
    else:
        print("⚠️ Setup incomplete - check manual SQL execution")
    
    return all_passed

if __name__ == "__main__":
    verify_setup()
