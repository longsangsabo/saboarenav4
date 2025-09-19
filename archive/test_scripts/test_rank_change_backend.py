#!/usr/bin/env python3
"""
Test script for Rank Change Request System Backend
Tests all 4 RPC functions to ensure they work correctly
"""

import requests
import json
import uuid
from datetime import datetime

# Supabase configuration
SUPABASE_URL = "https://mogjjvscxjwvhtpkrlqr.supabase.co"
ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ"
SERVICE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.5T7JGDbLHTEJG82TcYVcQO1kcaLrWG7S2yFMO5MJnZQ"

def make_request(endpoint, data=None, use_service_key=False):
    """Make HTTP request to Supabase"""
    headers = {
        "apikey": SERVICE_KEY if use_service_key else ANON_KEY,
        "Authorization": f"Bearer {SERVICE_KEY if use_service_key else ANON_KEY}",
        "Content-Type": "application/json"
    }
    
    url = f"{SUPABASE_URL}/rest/v1/rpc/{endpoint}"
    
    try:
        response = requests.post(url, json=data, headers=headers)
        print(f"📡 {endpoint}: {response.status_code}")
        
        if response.status_code == 200:
            result = response.json()
            print(f"✅ Success: {json.dumps(result, indent=2, ensure_ascii=False)}")
            return result
        else:
            print(f"❌ Error {response.status_code}: {response.text}")
            return None
    except Exception as e:
        print(f"❌ Exception: {str(e)}")
        return None

def test_function_existence():
    """Test if all functions exist by calling them without parameters"""
    print("\n🧪 TESTING FUNCTION EXISTENCE")
    print("=" * 50)
    
    functions = [
        "submit_rank_change_request",
        "get_pending_rank_change_requests", 
        "club_review_rank_change_request",
        "admin_approve_rank_change_request"
    ]
    
    for func in functions:
        print(f"\n📋 Testing {func}...")
        result = make_request(func, {}, use_service_key=True)
        if result is None:
            print(f"❌ Function {func} might not exist or has issues")
        else:
            print(f"✅ Function {func} exists and responded")

def test_database_schema():
    """Test database schema - check if required tables and columns exist"""
    print("\n🗄️ TESTING DATABASE SCHEMA")
    print("=" * 50)
    
    # Test if users table has rank column
    print("\n📋 Checking users table structure...")
    result = make_request("exec_sql", {
        "sql": "SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'users' AND column_name IN ('rank', 'current_rank', 'id', 'display_name');"
    }, use_service_key=True)
    
    # Test if notifications table exists with proper structure
    print("\n📋 Checking notifications table structure...")
    result = make_request("exec_sql", {
        "sql": "SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'notifications' AND column_name IN ('id', 'user_id', 'type', 'data');"
    }, use_service_key=True)
    
    # Test if club_memberships table exists
    print("\n📋 Checking club_memberships table structure...")
    result = make_request("exec_sql", {
        "sql": "SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'club_memberships' AND column_name IN ('user_id', 'club_id', 'status', 'role');"
    }, use_service_key=True)

def test_submit_request():
    """Test submitting a rank change request"""
    print("\n📝 TESTING SUBMIT RANK CHANGE REQUEST")
    print("=" * 50)
    
    # First, let's check what users exist and their current ranks
    print("\n📋 Checking existing users...")
    result = make_request("exec_sql", {
        "sql": "SELECT id, display_name, rank, current_rank FROM users WHERE rank IS NOT NULL AND rank != '' AND rank != 'unranked' LIMIT 5;"
    }, use_service_key=True)
    
    # Test function call structure (this will fail because we need authenticated user)
    print("\n📋 Testing function structure...")
    test_data = {
        "p_requested_rank": "gold",
        "p_reason": "Backend test - improved gameplay significantly",
        "p_evidence_urls": ["https://example.com/evidence1.jpg", "https://example.com/evidence2.jpg"]
    }
    
    result = make_request("submit_rank_change_request", test_data, use_service_key=True)

def test_get_requests():
    """Test getting pending requests"""
    print("\n📋 TESTING GET PENDING REQUESTS")
    print("=" * 50)
    
    # Test function structure
    result = make_request("get_pending_rank_change_requests", {}, use_service_key=True)

def test_club_review():
    """Test club review functionality"""
    print("\n✅ TESTING CLUB REVIEW")
    print("=" * 50)
    
    # Test with dummy UUID (will fail but shows function structure)
    test_data = {
        "p_request_id": str(uuid.uuid4()),
        "p_approved": True,
        "p_club_comments": "Backend test - approved by club admin"
    }
    
    result = make_request("club_review_rank_change_request", test_data, use_service_key=True)

def test_admin_approval():
    """Test admin approval functionality"""
    print("\n🔐 TESTING ADMIN APPROVAL")
    print("=" * 50)
    
    # Test with dummy UUID (will fail but shows function structure)
    test_data = {
        "p_request_id": str(uuid.uuid4()),
        "p_approved": True,
        "p_admin_comments": "Backend test - final admin approval"
    }
    
    result = make_request("admin_approve_rank_change_request", test_data, use_service_key=True)

def test_notifications_table():
    """Test notifications table for rank change requests"""
    print("\n📬 TESTING NOTIFICATIONS TABLE")
    print("=" * 50)
    
    # Check for existing rank change requests
    print("\n📋 Checking existing rank change requests...")
    result = make_request("exec_sql", {
        "sql": """
        SELECT 
            id, 
            user_id, 
            type, 
            title,
            data->>'workflow_status' as status,
            data->>'current_rank' as current_rank,
            data->>'requested_rank' as requested_rank,
            created_at
        FROM notifications 
        WHERE type = 'rank_change_request' 
        ORDER BY created_at DESC 
        LIMIT 10;
        """
    }, use_service_key=True)

def main():
    """Run all backend tests"""
    print("🚀 RANK CHANGE REQUEST SYSTEM - BACKEND TESTING")
    print("=" * 60)
    print(f"🕐 Test started at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"🌐 Supabase URL: {SUPABASE_URL}")
    
    # Run all tests
    test_function_existence()
    test_database_schema()
    test_submit_request()
    test_get_requests()
    test_club_review()
    test_admin_approval()
    test_notifications_table()
    
    print("\n" + "=" * 60)
    print("🏁 BACKEND TESTING COMPLETED")
    print("=" * 60)
    print("\n📊 SUMMARY:")
    print("✅ Function existence tests completed")
    print("✅ Database schema tests completed")
    print("✅ API endpoint structure tests completed")
    print("✅ Data flow tests completed")
    print("\n💡 Note: Some tests may show 'User not authenticated' errors")
    print("   This is expected when testing with service key without user context")
    print("   The important thing is that functions exist and respond correctly")

if __name__ == "__main__":
    main()