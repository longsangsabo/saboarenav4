import requests
import json
import uuid
from datetime import datetime, timedelta
import random
import time

# Supabase configuration
SUPABASE_URL = "https://mogjjvscxjwvhtpkrlqr.supabase.co"
SERVICE_ROLE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo"

headers = {
    "apikey": SERVICE_ROLE_KEY,
    "Authorization": f"Bearer {SERVICE_ROLE_KEY}",
    "Content-Type": "application/json"
}

# Vietnamese names for realistic data
first_names = [
    "An", "Bình", "Cường", "Dũng", "Đức", "Giang", "Hải", "Hùng", "Khang", "Long",
    "Minh", "Nam", "Phong", "Quang", "Sơn", "Thành", "Tuấn", "Văn", "Vinh", "Yên",
    "Anh", "Linh", "Mai", "Nga", "Oanh", "Phương", "Quyên", "Thu", "Trang", "Vy",
    "Bảo", "Duy", "Hiếu", "Khánh", "Lâm", "Nhật", "Phúc", "Quốc", "Tâm", "Xuân"
]

last_names = [
    "Nguyễn", "Trần", "Lê", "Phạm", "Hoàng", "Phan", "Vũ", "Võ", "Đặng", "Bùi",
    "Đỗ", "Hồ", "Ngô", "Dương", "Lý", "Đinh", "Trịnh", "Tăng", "Lương", "Đào",
    "Chu", "Mai", "Vương", "Lại", "Cao", "Huỳnh", "Tô", "Nghiêm", "La", "Kiều"
]

def get_rank_from_elo(elo):
    """Chuyển đổi ELO rating thành rank theo hệ thống SABO Arena"""
    if elo >= 2100:
        return 'E+'
    elif elo >= 2000:
        return 'E'
    elif elo >= 1900:
        return 'F+'
    elif elo >= 1800:
        return 'F'
    elif elo >= 1700:
        return 'G+'
    elif elo >= 1600:
        return 'G'
    elif elo >= 1500:
        return 'H+'
    elif elo >= 1400:
        return 'H'
    elif elo >= 1300:
        return 'I+'
    elif elo >= 1200:
        return 'I'
    elif elo >= 1100:
        return 'K+'
    else:
        return 'K'

def create_auth_user(email, password, full_name):
    """Tạo user trong Supabase Auth"""
    auth_data = {
        "email": email,
        "password": password,
        "email_confirm": True,
        "user_metadata": {
            "full_name": full_name
        }
    }
    
    try:
        response = requests.post(
            f"{SUPABASE_URL}/auth/v1/admin/users",
            headers=headers,
            json=auth_data
        )
        
        if response.status_code in [200, 201]:
            return response.json()
        else:
            print(f"   ❌ Auth error: {response.status_code} - {response.text[:200]}")
            return None
            
    except Exception as e:
        print(f"   ❌ Auth exception: {e}")
        return None

def create_public_user(auth_user_id, user_data):
    """Tạo user trong public.users table"""
    user_data["id"] = auth_user_id
    
    try:
        response = requests.post(
            f"{SUPABASE_URL}/rest/v1/users",
            headers={**headers, "Prefer": "return=representation"},
            json=user_data
        )
        
        if response.status_code in [200, 201]:
            return response.json()
        else:
            print(f"   ❌ Public user error: {response.status_code} - {response.text[:200]}")
            return None
            
    except Exception as e:
        print(f"   ❌ Public user exception: {e}")
        return None

def create_32_demo_users():
    print("🎯 CREATING 32 DEMO USERS FOR TOURNAMENT TESTING")
    print("="*60)
    
    # Check current user count
    response = requests.get(
        f"{SUPABASE_URL}/rest/v1/users?select=count",
        headers={**headers, "Prefer": "count=exact"}
    )
    
    current_count = 0
    if response.status_code == 200:
        current_count = int(response.headers.get('Content-Range', '0').split('/')[-1])
        print(f"📊 Current users in database: {current_count}")
    
    needed_users = max(0, 32 - current_count)
    print(f"🎯 Need to create: {needed_users} more users")
    
    if needed_users <= 0:
        print("✅ Already have enough users!")
        return
    
    successful_creates = 0
    
    for i in range(needed_users):
        print(f"\n🔄 Creating user {i+1}/{needed_users}...")
        
        # Generate user data
        first_name = random.choice(first_names)
        last_name = random.choice(last_names)
        full_name = f"{last_name} {first_name}"
        
        username = f"{first_name.lower()}{last_name.lower()}{i+1:02d}_{random.randint(1000,9999)}"
        email = f"demo{current_count + i + 1:02d}@saboarena.com"
        password = "demo123456"  # Simple password for demo
        
        print(f"   👤 {full_name} ({email})")
        
        # Step 1: Create auth user
        auth_user = create_auth_user(email, password, full_name)
        if not auth_user:
            continue
        
        auth_user_id = auth_user["id"]
        print(f"   ✅ Auth user created: {auth_user_id}")
        
        # Step 2: Generate profile data
        elo_rating = random.randint(1000, 2200)
        
        if elo_rating >= 2000:  # E, E+ ranks
            wins = random.randint(40, 80)
            losses = random.randint(5, 20)
        elif elo_rating >= 1600:  # G, G+, F, F+ ranks  
            wins = random.randint(20, 50)
            losses = random.randint(10, 30)
        elif elo_rating >= 1300:  # I+, H, H+ ranks
            wins = random.randint(10, 30)
            losses = random.randint(15, 35)
        else:  # K, K+, I ranks
            wins = random.randint(5, 20)
            losses = random.randint(10, 40)
        
        total_matches = wins + losses
        ranking_points = elo_rating + random.randint(-200, 200)
        spa_points = random.randint(min(100, elo_rating//10), max(500, elo_rating//2))
        
        # Create user profile data
        user_data = {
            "email": email,
            "full_name": full_name,
            "username": username,
            "display_name": username,
            "bio": f"Demo user - {full_name}, ELO {elo_rating}",
            "avatar_url": None,
            "phone": None,
            "date_of_birth": None,
            "role": "player",
            "skill_level": "beginner",
            "total_wins": wins,
            "total_losses": losses,
            "total_tournaments": random.randint(0, 5),
            "ranking_points": ranking_points,
            "is_verified": True,  # Auto verify demo users
            "is_active": True,
            "location": None,
            "created_at": (datetime.now() - timedelta(days=random.randint(1, 30))).isoformat(),
            "updated_at": datetime.now().isoformat(),
            "rank": get_rank_from_elo(elo_rating),
            "elo_rating": elo_rating,
            "spa_points": spa_points,
            "favorite_game": random.choice(["8-Ball", "9-Ball", "10-Ball", "Straight Pool"]),
            "total_matches": total_matches,
            "wins": wins,
            "losses": losses,
            "win_streak": random.randint(0, 5),
            "tournaments_played": random.randint(0, 3),
            "tournament_wins": random.randint(0, 1),
            "is_online": random.choice([True, False]),
            "last_seen": datetime.now().isoformat(),
            "cover_photo_url": None,
            "latitude": round(random.uniform(20.5, 21.5), 8),
            "longitude": round(random.uniform(105.5, 106.5), 8),
            "location_name": random.choice([
                "Quận Hoàn Kiếm, Hà Nội",
                "Quận Ba Đình, Hà Nội", 
                "Quận Cầu Giấy, Hà Nội",
                "Quận 1, TP.HCM",
                "Quận 3, TP.HCM",
                "Hải Châu, Đà Nẵng"
            ]),
            "spa_points_won": random.randint(0, spa_points),
            "spa_points_lost": random.randint(0, spa_points//2),
            "challenge_win_streak": random.randint(0, 3),
            "is_available_for_challenges": True,
            "preferred_match_type": random.choice(["thach_dau", "giai_dau", "tu_do"]),
            "max_challenge_distance": random.randint(1, 10),
            "total_prize_pool": random.randint(0, wins * 10000),
            "total_games": total_matches
        }
        
        # Step 3: Create public user
        public_user = create_public_user(auth_user_id, user_data)
        if public_user:
            successful_creates += 1
            rank = user_data['rank']
            elo = user_data['elo_rating']
            print(f"   ✅ Profile created: Rank {rank} (ELO: {elo})")
        
        # Small delay to avoid rate limiting
        time.sleep(0.5)
    
    print(f"\n🎉 HOÀN THÀNH! Đã tạo thành công {successful_creates}/{needed_users} demo users")
    
    # Final verification
    response = requests.get(
        f"{SUPABASE_URL}/rest/v1/users?select=count",
        headers={**headers, "Prefer": "count=exact"}
    )
    
    if response.status_code == 200:
        final_count = int(response.headers.get('Content-Range', '0').split('/')[-1])
        print(f"📊 Total users now: {final_count}")
        
        if final_count >= 32:
            print("🎯 READY FOR 32-PLAYER TOURNAMENT TESTING! 🏆")
        else:
            print(f"⚠️  Still need {32 - final_count} more users for 32-player tournament")

if __name__ == "__main__":
    create_32_demo_users()