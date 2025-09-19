#!/usr/bin/env python3
"""
🔄 RANK MIGRATION TEST SCRIPT
Test việc migration hệ thống rank từ tên cũ sang hệ thống mới
"""

from supabase import create_client
import json

# Supabase config
SUPABASE_URL = "https://mogjjvscxjwvhtpkrlqr.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ"

def test_rank_migration():
    print("🔄 TESTING RANK MIGRATION SYSTEM")
    print("=" * 50)
    
    # Create client
    supabase = create_client(SUPABASE_URL, SUPABASE_KEY)
    
    # Rank mapping for testing
    rank_mapping = {
        'K': 'Người mới',
        'K+': 'Học việc', 
        'I': 'Thợ 3',
        'I+': 'Thợ 2',
        'H': 'Thợ 1',
        'H+': 'Thợ chính',
        'G': 'Thợ giỏi',
        'G+': 'Cao thủ',
        'F': 'Chuyên gia',
        'F+': 'Đại cao thủ',
        'E': 'Huyền thoại',
        'E+': 'Vô địch'
    }
    
    try:
        # 1. Test validate_rank_migration function
        print("\n1️⃣ Testing validation function...")
        result = supabase.rpc('validate_rank_migration').execute()
        
        if result.data:
            validation = result.data[0]
            print(f"✅ Validation successful:")
            print(f"   Total users: {validation['total_users']}")
            print(f"   Users with rank: {validation['users_with_rank']}")
            print(f"   Rank distribution: {json.dumps(validation['rank_distribution'], indent=2)}")
        else:
            print("❌ Validation function not found")
            
    except Exception as e:
        print(f"⚠️ Validation test failed: {e}")
    
    try:
        # 2. Test get_rank_display_name function
        print("\n2️⃣ Testing rank display name function...")
        for rank_code, expected_name in rank_mapping.items():
            result = supabase.rpc('get_rank_display_name', {'rank_code': rank_code}).execute()
            
            if result.data:
                actual_name = result.data
                status = "✅" if actual_name == expected_name else "❌"
                print(f"   {status} {rank_code}: '{actual_name}' (expected: '{expected_name}')")
            else:
                print(f"   ❌ {rank_code}: Function returned no data")
                
    except Exception as e:
        print(f"⚠️ Display name test failed: {e}")
    
    try:
        # 3. Test actual user data
        print("\n3️⃣ Testing user data migration...")
        result = supabase.from_('users').select('id, rank, elo_rating').limit(10).execute()
        
        if result.data:
            print(f"   Found {len(result.data)} users:")
            for user in result.data:
                rank_code = user.get('rank')
                elo = user.get('elo_rating', 0)
                display_name = rank_mapping.get(rank_code, 'Unknown')
                print(f"   - User {user['id'][:8]}...: {rank_code} ({display_name}) - ELO: {elo}")
        else:
            print("   ❌ No user data found")
            
    except Exception as e:
        print(f"⚠️ User data test failed: {e}")
    
    try:
        # 4. Test rank distribution by ELO
        print("\n4️⃣ Testing ELO-Rank consistency...")
        elo_ranges = {
            'K': (1000, 1099),
            'K+': (1100, 1199),
            'I': (1200, 1299),
            'I+': (1300, 1399),
            'H': (1400, 1499),
            'H+': (1500, 1599),
            'G': (1600, 1699),
            'G+': (1700, 1799),
            'F': (1800, 1899),
            'F+': (1900, 1999),
            'E': (2000, 2099),
            'E+': (2100, 9999)
        }
        
        for rank_code, (min_elo, max_elo) in elo_ranges.items():
            # Count users in this rank with correct ELO range
            result = supabase.from_('users').select('id', count='exact')\
                .eq('rank', rank_code)\
                .gte('elo_rating', min_elo)\
                .lte('elo_rating', max_elo).execute()
                
            correct_count = result.count or 0
            
            # Count users in this rank with incorrect ELO range  
            result2 = supabase.from_('users').select('id', count='exact')\
                .eq('rank', rank_code)\
                .or_(f'elo_rating.lt.{min_elo},elo_rating.gt.{max_elo}').execute()
                
            incorrect_count = result2.count or 0
            
            total = correct_count + incorrect_count
            if total > 0:
                consistency = (correct_count / total) * 100
                status = "✅" if consistency > 90 else "⚠️" if consistency > 70 else "❌"
                print(f"   {status} {rank_code} ({rank_mapping[rank_code]}): {consistency:.1f}% consistent ({correct_count}/{total})")
            
    except Exception as e:
        print(f"⚠️ ELO consistency test failed: {e}")
    
    print("\n🎯 MIGRATION TEST COMPLETED!")
    print("=" * 50)

if __name__ == "__main__":
    test_rank_migration()