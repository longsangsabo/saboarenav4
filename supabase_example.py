#!/usr/bin/env python3
"""
SABO Arena - Supabase Connection Example
========================================

This script demonstrates how to connect and interact with SABO Arena's Supabase backend.
Run this script to test your connection and see example operations.

Usage:
    python supabase_example.py

Requirements:
    pip install requests
"""

import requests
import json
from datetime import datetime

# =============================================================================
# CONFIGURATION
# =============================================================================

SUPABASE_URL = "https://mogjjvscxjwvhtpkrlqr.supabase.co"

# Choose your key based on use case:
# - ANON_KEY for client-side operations (respects RLS)
# - SERVICE_ROLE_KEY for admin operations (bypasses RLS)
ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ"
SERVICE_ROLE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo"

# Use SERVICE_ROLE_KEY for this example (full access)
API_KEY = SERVICE_ROLE_KEY

# =============================================================================
# SUPABASE CLIENT CLASS
# =============================================================================

class SaboSupabaseClient:
    """Simple Supabase client for SABO Arena backend operations"""
    
    def __init__(self, url, api_key):
        self.url = url
        self.api_key = api_key
        self.headers = {
            "apikey": api_key,
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json",
            "Prefer": "return=representation"
        }
    
    def get(self, table, select="*", filters=None, limit=None, order=None):
        """GET request to Supabase table"""
        params = {"select": select}
        
        if filters:
            params.update(filters)
        if limit:
            params["limit"] = limit
        if order:
            params["order"] = order
            
        response = requests.get(
            f"{self.url}/rest/v1/{table}",
            headers=self.headers,
            params=params
        )
        
        return self._handle_response(response)
    
    def post(self, table, data):
        """POST request to create new record"""
        response = requests.post(
            f"{self.url}/rest/v1/{table}",
            headers=self.headers,
            json=data
        )
        return self._handle_response(response)
    
    def patch(self, table, data, filters):
        """PATCH request to update records"""
        params = filters
        response = requests.patch(
            f"{self.url}/rest/v1/{table}",
            headers=self.headers,
            params=params,
            json=data
        )
        return self._handle_response(response)
    
    def delete(self, table, filters):
        """DELETE request to remove records"""
        response = requests.delete(
            f"{self.url}/rest/v1/{table}",
            headers=self.headers,
            params=filters
        )
        return self._handle_response(response)
    
    def count(self, table, filters=None):
        """Get count of records in table"""
        headers = {**self.headers, "Prefer": "count=exact"}
        params = filters or {}
        params["select"] = "count"
        
        response = requests.get(
            f"{self.url}/rest/v1/{table}",
            headers=headers,
            params=params
        )
        
        if response.status_code in [200, 206]:  # 206 for partial content with count
            count_header = response.headers.get('Content-Range', '0')
            return int(count_header.split('/')[-1])
        return 0
    
    def _handle_response(self, response):
        """Handle HTTP response and return data or error info"""
        if response.status_code in [200, 201, 204]:
            try:
                return response.json() if response.text else {"success": True}
            except:
                return {"success": True}
        else:
            return {
                "error": True,
                "status_code": response.status_code,
                "message": response.text
            }

# =============================================================================
# EXAMPLE FUNCTIONS
# =============================================================================

def test_connection(client):
    """Test basic connection to Supabase"""
    print("🔍 Testing Supabase Connection...")
    print("-" * 50)
    
    try:
        count = client.count("users")
        print(f"✅ Connection successful!")
        print(f"📊 Total users in database: {count}")
        return True
    except Exception as e:
        print(f"❌ Connection failed: {e}")
        return False

def show_users_overview(client):
    """Display overview of users in database"""
    print("\n👥 Users Overview")
    print("-" * 50)
    
    # Get top 10 users by ELO
    users = client.get(
        "users",
        select="full_name,rank,elo_rating,email",
        limit=10,
        order="elo_rating.desc"
    )
    
    if users and isinstance(users, list) and len(users) > 0:
        print("🏆 Top 10 Users by ELO:")
        for i, user in enumerate(users, 1):
            name = user['full_name']
            rank = user['rank']
            elo = user['elo_rating']
            email = user['email'][:30] + "..." if len(user['email']) > 30 else user['email']
            print(f"  {i:2d}. {name:<20} | Rank {rank:<3} | ELO {elo:<4} | {email}")
    else:
        print(f"❌ Error fetching users: {users}")

def show_rank_distribution(client):
    """Show distribution of users by rank"""
    print("\n🎯 Rank Distribution")
    print("-" * 50)
    
    users = client.get("users", select="rank")
    
    if users and isinstance(users, list):
        rank_counts = {}
        for user in users:
            rank = user['rank']
            rank_counts[rank] = rank_counts.get(rank, 0) + 1
        
        # Sort ranks by hierarchy
        rank_order = ['K', 'K+', 'I', 'I+', 'H', 'H+', 'G', 'G+', 'F', 'F+', 'E', 'E+']
        
        print("📈 Distribution:")
        for rank in rank_order:
            if rank in rank_counts:
                count = rank_counts[rank]
                bar = "█" * min(count, 20)  # Visual bar
                print(f"  Rank {rank:<3}: {count:2d} users {bar}")
    else:
        print(f"❌ Error fetching rank data: {users}")

def show_tournaments_overview(client):
    """Display tournaments overview"""
    print("\n🏆 Tournaments Overview")
    print("-" * 50)
    
    tournaments = client.get(
        "tournaments",
        select="id,title,status,max_participants,start_date",
        limit=5,
        order="created_at.desc"
    )
    
    if tournaments and isinstance(tournaments, list) and len(tournaments) > 0:
        print("📋 Recent Tournaments:")
        for i, tournament in enumerate(tournaments, 1):
            title = tournament.get('title', 'Untitled Tournament')
            status = tournament['status']
            max_p = tournament['max_participants']
            start_date = tournament.get('start_date', 'TBD')
            print(f"  {i}. {title:<30} | {status:<10} | Max: {max_p} | Start: {start_date}")
    else:
        print(f"❌ Error fetching tournaments: {tournaments}")

def example_crud_operations(client):
    """Demonstrate CRUD operations"""
    print("\n🔧 CRUD Operations Example")
    print("-" * 50)
    
    # Example: Get specific user
    print("📖 READ Example - Get user by email:")
    user = client.get(
        "users",
        select="full_name,rank,elo_rating",
        filters={"email": "eq.longsangsabo@gmail.com"},
        limit=1
    )
    
    if user and isinstance(user, list) and len(user) > 0:
        user_data = user[0]
        print(f"   Found: {user_data['full_name']} (Rank {user_data['rank']}, ELO {user_data['elo_rating']})")
    else:
        print("   No user found with that email")
    
    # Example: Count high-ELO users
    print("\n🔍 FILTER Example - Count users with ELO > 1500:")
    high_elo_users = client.get(
        "users",
        select="full_name,elo_rating",
        filters={"elo_rating": "gt.1500"}
    )
    
    if high_elo_users and isinstance(high_elo_users, list):
        print(f"   Found {len(high_elo_users)} users with ELO > 1500")
        for user in high_elo_users[:3]:  # Show first 3
            print(f"     - {user['full_name']}: {user['elo_rating']} ELO")
        if len(high_elo_users) > 3:
            print(f"     ... and {len(high_elo_users) - 3} more")

def show_database_tables(client):
    """Show information about available tables"""
    print("\n📋 Database Tables")
    print("-" * 50)
    
    tables_info = [
        ("users", "User profiles and statistics"),
        ("tournaments", "Tournament information"),
        ("tournament_participants", "User participation in tournaments"),
        ("matches", "Individual match records"),
        ("clubs", "Club information"),
        ("posts", "Social media posts"),
        ("comments", "Comments on posts"),
        ("achievements", "User achievements")
    ]
    
    print("📊 Available Tables:")
    for table, description in tables_info:
        try:
            count = client.count(table)
            print(f"  {table:<25} | {count:4d} records | {description}")
        except:
            print(f"  {table:<25} | ---- records | {description} (access denied)")

# =============================================================================
# MAIN EXECUTION
# =============================================================================

def main():
    """Main function to run all examples"""
    print("🎱 SABO Arena - Supabase Connection Example")
    print("=" * 60)
    print(f"📡 Connecting to: {SUPABASE_URL}")
    print(f"🔑 Using: {'Service Role Key' if API_KEY == SERVICE_ROLE_KEY else 'Anon Key'}")
    print(f"📅 Date: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    
    # Initialize client
    client = SaboSupabaseClient(SUPABASE_URL, API_KEY)
    
    # Run tests
    if test_connection(client):
        show_database_tables(client)
        show_users_overview(client)
        show_rank_distribution(client)
        show_tournaments_overview(client)
        example_crud_operations(client)
        
        print("\n" + "=" * 60)
        print("✅ All examples completed successfully!")
        print("📚 Check SUPABASE_PYTHON_CONNECTION_GUIDE.md for detailed documentation")
    else:
        print("\n❌ Connection test failed. Please check your configuration.")

if __name__ == "__main__":
    main()