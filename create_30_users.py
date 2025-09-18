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

# Generate 30 users
users_to_create = []

for i in range(30):
    first_name = random.choice(first_names)
    last_name = random.choice(last_names)
    full_name = f"{last_name} {first_name}"
    
    # Create unique email and username
    username = f"{first_name.lower()}{last_name.lower()}{i+1:02d}"
    email = f"{username}@saboarena.com"
    
    # Random ELO rating theo hệ thống SABO - từ K (1000) đến E+ (2200+)
    elo_rating = random.randint(1000, 2200)
    
    # Random creation time in the last 30 days
    created_at = datetime.now() - timedelta(days=random.randint(1, 30))
    
    # Thống kê phù hợpc với ELO rating
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
    ranking_points = elo_rating + random.randint(-200, 200)  # Gần bằng ELO
    spa_points = random.randint(min(100, elo_rating//10), max(500, elo_rating//2))
    
    # Tạo user data theo cấu trúc chính xác từ database
    user_data = {
        "id": str(uuid.uuid4()),
        "email": email,
        "full_name": full_name,
        "username": username,
        "bio": f"Tôi là {full_name}, chơi bida với ELO {elo_rating}",
        "avatar_url": None,
        "phone": None,  # Để null như user mẫu
        "date_of_birth": None,
        "role": "player",
        "skill_level": "beginner",  # Giữ lại vì vẫn có trong DB
        "total_wins": wins,
        "total_losses": losses,
        "total_tournaments": random.randint(0, 5),
        "ranking_points": ranking_points,
        "is_verified": random.choice([True, False]),
        "is_active": True,
        "location": None,  # Để null như user mẫu
        "created_at": created_at.isoformat(),
        "updated_at": datetime.now().isoformat(),
        "display_name": username,
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
        "latitude": round(random.uniform(20.5, 21.5), 8),  # Gần Hà Nội
        "longitude": round(random.uniform(105.5, 106.5), 8),  # Gần Hà Nội
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
        "is_available_for_challenges": random.choice([True, False]),
        "preferred_match_type": random.choice(["thach_dau", "giai_dau", "tu_do"]),
        "max_challenge_distance": random.randint(1, 10),
        "total_prize_pool": random.randint(0, wins * 10000),  # Dựa trên số wins
        "total_games": total_matches
    }
    
    users_to_create.append(user_data)

def create_users():
    print(f"Bắt đầu tạo {len(users_to_create)} user mới...")
    
    # Create users in batches
    batch_size = 10
    successful_creates = 0
    
    for i in range(0, len(users_to_create), batch_size):
        batch = users_to_create[i:i + batch_size]
        
        try:
            response = requests.post(
                f"{SUPABASE_URL}/rest/v1/users",
                headers=headers,
                json=batch
            )
            
            if response.status_code in [200, 201]:
                successful_creates += len(batch)
                print(f"✅ Tạo thành công batch {i//batch_size + 1}: {len(batch)} users")
                
                # Print some user info
                for user in batch:
                    print(f"   - {user['full_name']} ({user['username']}) - ELO: {user['elo_rating']}")
                    
            else:
                print(f"❌ Lỗi tạo batch {i//batch_size + 1}: {response.status_code}")
                print(f"Response: {response.text}")
                
        except Exception as e:
            print(f"❌ Exception khi tạo batch {i//batch_size + 1}: {str(e)}")
    
    print(f"\n🎉 Hoàn thành! Đã tạo thành công {successful_creates}/{len(users_to_create)} users")
    
    # Verify total users count
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
    create_users()