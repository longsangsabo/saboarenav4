import requests
import json
import uuid
from datetime import datetime, timedelta
import random

# Supabase configuration
SUPABASE_URL = "https://mogjjvscxjwvhtpkrlqr.supabase.co"
SERVICE_ROLE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo"

headers = {
    "apikey": SERVICE_ROLE_KEY,
    "Authorization": f"Bearer {SERVICE_ROLE_KEY}",
    "Content-Type": "application/json",
    "Prefer": "return=representation"
}

# Vietnamese names for realistic data
first_names = [
    "An", "Bình", "Cường", "Dũng", "Đức", "Giang", "Hải", "Hùng", "Khang", "Long",
    "Minh", "Nam", "Phong", "Quang", "Sơn", "Thành", "Tuấn", "Văn", "Vinh", "Yên",
    "Anh", "Linh", "Mai", "Nga", "Oanh", "Phương", "Quyên", "Thu", "Trang", "Vy"
]

last_names = [
    "Nguyễn", "Trần", "Lê", "Phạm", "Hoàng", "Phan", "Vũ", "Võ", "Đặng", "Bùi",
    "Đỗ", "Hồ", "Ngô", "Dương", "Lý", "Đinh", "Trịnh", "Tăng", "Lương", "Đào"
]

# SABO Rank System - Chính xác theo core logic
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

def duplicate_existing_users():
    print("🔄 STRATEGY: Duplicate existing users with new data")
    print("="*60)
    
    # Get existing users
    response = requests.get(
        f"{SUPABASE_URL}/rest/v1/users",
        headers=headers
    )
    
    if response.status_code != 200:
        print(f"❌ Cannot get existing users: {response.text}")
        return
    
    existing_users = response.json()
    print(f"📊 Found {len(existing_users)} existing users")
    
    if not existing_users:
        print("❌ No existing users to duplicate")
        return
    
    # Use first user as template
    template_user = existing_users[0]
    print(f"📋 Using user '{template_user['username']}' as template")
    
    successful_creates = 0
    
    for i in range(30):
        first_name = random.choice(first_names)
        last_name = random.choice(last_names)
        full_name = f"{last_name} {first_name}"
        
        # Create unique identifiers
        username = f"{first_name.lower()}{last_name.lower()}{i+1:02d}_{random.randint(1000,9999)}"
        email = f"{username}@saboarena.com"
        
        # Random ELO rating theo hệ thống SABO - từ K (1000) đến E+ (2200+)
        elo_rating = random.randint(1000, 2200)
        
        # Thống kê phù hợp với ELO rating
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
        
        # Duplicate template user and modify data
        new_user = template_user.copy()
        
        # Update with new data
        new_user.update({
            "email": email,
            "full_name": full_name,
            "username": username,
            "display_name": username,
            "bio": f"Tôi là {full_name}, chơi bida với ELO {elo_rating}",
            "rank": get_rank_from_elo(elo_rating),
            "elo_rating": elo_rating,
            "total_wins": wins,
            "total_losses": losses,
            "wins": wins,
            "losses": losses,
            "total_matches": total_matches,
            "total_games": total_matches,
            "ranking_points": ranking_points,
            "spa_points": spa_points,
            "spa_points_won": random.randint(0, spa_points),
            "spa_points_lost": random.randint(0, spa_points//2),
            "win_streak": random.randint(0, 5),
            "tournaments_played": random.randint(0, 3),
            "tournament_wins": random.randint(0, 1),
            "total_tournaments": random.randint(0, 5),
            "is_online": random.choice([True, False]),
            "is_verified": random.choice([True, False]),
            "challenge_win_streak": random.randint(0, 3),
            "is_available_for_challenges": random.choice([True, False]),
            "preferred_match_type": random.choice(["thach_dau", "giai_dau", "tu_do"]),
            "max_challenge_distance": random.randint(1, 10),
            "total_prize_pool": random.randint(0, wins * 10000),
            "favorite_game": random.choice(["8-Ball", "9-Ball", "10-Ball", "Straight Pool"]),
            "location_name": random.choice([
                "Quận Hoàn Kiếm, Hà Nội",
                "Quận Ba Đình, Hà Nội", 
                "Quận Cầu Giấy, Hà Nội",
                "Quận 1, TP.HCM",
                "Quận 3, TP.HCM",
                "Hải Châu, Đà Nẵng"
            ]),
            "latitude": round(random.uniform(20.5, 21.5), 8),
            "longitude": round(random.uniform(105.5, 106.5), 8),
            "created_at": (datetime.now() - timedelta(days=random.randint(1, 30))).isoformat(),
            "updated_at": datetime.now().isoformat(),
            "last_seen": datetime.now().isoformat(),
        })
        
        # Remove ID to let database generate new one
        if 'id' in new_user:
            del new_user['id']
        
        try:
            response = requests.post(
                f"{SUPABASE_URL}/rest/v1/users",
                headers=headers,
                json=new_user
            )
            
            if response.status_code in [200, 201]:
                successful_creates += 1
                rank = new_user['rank']
                elo = new_user['elo_rating']
                print(f"✅ {successful_creates:2d}/30: {full_name} ({username}) - Rank {rank} (ELO: {elo})")
            else:
                print(f"❌ Error creating {username}: {response.status_code}")
                print(f"   Response: {response.text[:200]}...")
                
        except Exception as e:
            print(f"❌ Exception creating {username}: {str(e)}")
    
    print(f"\n🎉 HOÀN THÀNH! Đã tạo thành công {successful_creates}/30 users")
    
    # Verify total count
    try:
        response = requests.get(
            f"{SUPABASE_URL}/rest/v1/users?select=count",
            headers={**headers, "Prefer": "count=exact"}
        )
        
        if response.status_code == 200:
            total_count = response.headers.get('Content-Range', '0').split('/')[-1]
            print(f"📊 Tổng số user trong database: {total_count}")
            
    except Exception as e:
        print(f"Không thể kiểm tra tổng số user: {e}")

if __name__ == "__main__":
    duplicate_existing_users()