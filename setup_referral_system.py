import requests
import json

# Supabase configuration
SUPABASE_URL = "https://mogjjvscxjwvhtpkrlqr.supabase.co"
SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ"

def setup_referral_database():
    """Setup referral system database tables"""
    
    headers = {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': f'Bearer {SUPABASE_ANON_KEY}',
        'Content-Type': 'application/json'
    }
    
    print("🚀 SABO Arena - Referral System Setup")
    print("=" * 40)
    
    # First, let's add referral fields to existing user
    print("📋 Step 1: Adding referral fields to existing user...")
    
    try:
        # Get existing user to update
        response = requests.get(
            f"{SUPABASE_URL}/rest/v1/users?username=eq.SABO123456&select=id,full_name,username",
            headers=headers
        )
        
        if response.status_code == 200:
            users = response.json()
            if users:
                user = users[0]
                user_id = user['id']
                
                print(f"✅ Found user: {user['full_name']} ({user['username']})")
                
                # Update user with referral stats
                referral_stats = {
                    "total_referred": 0,
                    "total_earned": 0,
                    "codes_created": 0
                }
                
                update_response = requests.patch(
                    f"{SUPABASE_URL}/rest/v1/users?id=eq.{user_id}",
                    headers=headers,
                    json={
                        "referral_stats": referral_stats,
                        "referral_bonus_claimed": False
                    }
                )
                
                if update_response.status_code == 200:
                    print("✅ User updated with referral fields")
                    return user_id
                else:
                    print(f"❌ Failed to update user: {update_response.text}")
                    return None
            else:
                print("❌ No users found with QR username")
                return None
        else:
            print(f"❌ Error getting users: {response.status_code}")
            return None
            
    except Exception as e:
        print(f"💥 Exception: {e}")
        return None

def create_test_referral_codes(user_id):
    """Create test referral codes for the user"""
    
    headers = {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': f'Bearer {SUPABASE_ANON_KEY}',
        'Content-Type': 'application/json',
        'Prefer': 'return=representation'
    }
    
    print(f"\n🎁 Step 2: Creating test referral codes...")
    print("=" * 35)
    
    # Test referral codes to create
    test_codes = [
        {
            "user_id": user_id,
            "code": "SABO-GIANG-VIP",
            "code_type": "vip",
            "max_uses": 10,
            "rewards": {
                "referrer": {"spa_points": 200, "premium_days": 7},
                "referred": {"spa_points": 100, "premium_trial": 14}
            }
        },
        {
            "user_id": user_id, 
            "code": "SABO-WELCOME-2025",
            "code_type": "general",
            "max_uses": None,  # Unlimited
            "rewards": {
                "referrer": {"spa_points": 100, "elo_boost": 10},
                "referred": {"spa_points": 50, "welcome_bonus": True}
            }
        },
        {
            "user_id": user_id,
            "code": "SABO-TOURNAMENT-SPECIAL",
            "code_type": "tournament", 
            "max_uses": 25,
            "rewards": {
                "referrer": {"free_entry_tickets": 2, "spa_points": 150},
                "referred": {"free_entry_tickets": 1, "practice_mode": True}
            }
        }
    ]
    
    created_codes = []
    
    for code_data in test_codes:
        print(f"\n👤 Creating: {code_data['code']} ({code_data['code_type']})")
        
        try:
            response = requests.post(
                f"{SUPABASE_URL}/rest/v1/referral_codes",
                headers=headers,
                json=code_data
            )
            
            if response.status_code in [200, 201]:
                result = response.json()
                if result:
                    created_code = result[0] if isinstance(result, list) else result
                    print(f"   ✅ Created successfully!")
                    print(f"   🎯 Type: {created_code.get('code_type', 'N/A')}")
                    print(f"   🎁 Max uses: {created_code.get('max_uses', 'Unlimited')}")
                    created_codes.append(created_code)
                else:
                    print(f"   ⚠️ Created but no data returned")
            elif response.status_code == 409:
                print(f"   ⚠️ Code already exists")
            else:
                print(f"   ❌ Failed: {response.status_code}")
                print(f"   Error: {response.text}")
                
        except Exception as e:
            print(f"   💥 Exception: {e}")
    
    return created_codes

def test_referral_code_lookup():
    """Test referral code lookup functionality"""
    
    headers = {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': f'Bearer {SUPABASE_ANON_KEY}',
        'Content-Type': 'application/json'
    }
    
    print(f"\n🔍 Step 3: Testing referral code lookup...")
    print("=" * 38)
    
    test_codes = ["SABO-GIANG-VIP", "SABO-WELCOME-2025", "SABO-TOURNAMENT-SPECIAL"]
    working_codes = []
    
    for code in test_codes:
        print(f"\n🎁 Testing: {code}")
        
        try:
            response = requests.get(
                f"{SUPABASE_URL}/rest/v1/referral_codes?code=eq.{code}&select=code,code_type,rewards,max_uses,current_uses,is_active",
                headers=headers
            )
            
            if response.status_code == 200:
                data = response.json()
                if data:
                    code_info = data[0]
                    print(f"   ✅ Found: {code_info['code_type']} referral code")
                    print(f"   🎯 Status: {'Active' if code_info['is_active'] else 'Inactive'}")
                    print(f"   📊 Usage: {code_info['current_uses']}/{code_info.get('max_uses', '∞')}")
                    
                    rewards = code_info.get('rewards', {})
                    if rewards:
                        referrer_rewards = rewards.get('referrer', {})
                        referred_rewards = rewards.get('referred', {})
                        print(f"   🎁 Referrer gets: {referrer_rewards}")
                        print(f"   🎁 Referred gets: {referred_rewards}")
                    
                    working_codes.append(code)
                else:
                    print(f"   ❌ Code not found")
            else:
                print(f"   ⚠️ API Error: {response.status_code}")
                
        except Exception as e:
            print(f"   💥 Exception: {e}")
    
    return working_codes

def generate_referral_qr_codes():
    """Generate QR codes for referral testing"""
    
    print(f"\n📱 Step 4: Generating referral QR codes...")
    print("=" * 38)
    
    html_content = """<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SABO Arena - Referral QR Codes</title>
    <script src="https://cdn.jsdelivr.net/npm/qrcode@1.5.3/build/qrcode.min.js"></script>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            padding: 20px;
            background: linear-gradient(135deg, #ff6b6b 0%, #ee5a24 100%);
            min-height: 100vh;
            margin: 0;
        }
        
        .container { max-width: 1200px; margin: 0 auto; }
        
        h1 {
            text-align: center;
            color: white;
            margin-bottom: 10px;
            font-size: 2.5em;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
        }
        
        .subtitle {
            text-align: center;
            color: rgba(255,255,255,0.9);
            margin-bottom: 30px;
            font-size: 1.2em;
        }
        
        .qr-container {
            display: flex;
            flex-wrap: wrap;
            gap: 25px;
            justify-content: center;
        }
        
        .qr-card {
            background: white;
            padding: 25px;
            border-radius: 15px;
            box-shadow: 0 8px 25px rgba(0,0,0,0.15);
            text-align: center;
            min-width: 300px;
            transition: transform 0.3s ease;
        }
        
        .qr-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 12px 35px rgba(0,0,0,0.2);
        }
        
        .qr-card h3 {
            color: #333;
            margin-bottom: 15px;
            font-size: 1.4em;
        }
        
        .qr-code {
            margin: 20px 0;
            display: flex;
            justify-content: center;
        }
        
        .rewards-info {
            background: #f8f9fa;
            padding: 15px;
            border-radius: 8px;
            margin: 15px 0;
            text-align: left;
            font-size: 13px;
            color: #495057;
        }
        
        .code-display {
            background: #007bff;
            color: white;
            padding: 10px;
            border-radius: 8px;
            font-family: 'Courier New', monospace;
            font-weight: bold;
            margin: 10px 0;
        }
        
        .badge {
            display: inline-block;
            padding: 6px 12px;
            border-radius: 15px;
            font-size: 12px;
            font-weight: bold;
            margin: 5px;
        }
        
        .badge-vip { background: #ffd700; color: #333; }
        .badge-general { background: #28a745; color: white; }
        .badge-tournament { background: #6f42c1; color: white; }
        
        .instructions {
            background: rgba(255,255,255,0.95);
            padding: 25px;
            border-radius: 10px;
            margin-top: 30px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🎁 SABO Arena Referral Codes</h1>
        <p class="subtitle">Mã giới thiệu - Chia sẻ và nhận thưởng!</p>
        
        <div class="qr-container">
            <div class="qr-card">
                <h3>🌟 VIP Referral</h3>
                <span class="badge badge-vip">VIP</span>
                <div class="qr-code" id="qr1"></div>
                <div class="code-display">SABO-GIANG-VIP</div>
                <div class="rewards-info">
                    <strong>🎁 Người giới thiệu nhận:</strong><br>
                    • 200 SPA Points<br>
                    • 7 ngày Premium<br><br>
                    
                    <strong>🎁 Người được giới thiệu nhận:</strong><br>
                    • 100 SPA Points<br>
                    • 14 ngày Premium trial<br><br>
                    
                    <strong>📊 Giới hạn:</strong> 10 lần sử dụng
                </div>
            </div>
            
            <div class="qr-card">
                <h3>🎯 Welcome 2025</h3>
                <span class="badge badge-general">GENERAL</span>
                <div class="qr-code" id="qr2"></div>
                <div class="code-display">SABO-WELCOME-2025</div>
                <div class="rewards-info">
                    <strong>🎁 Người giới thiệu nhận:</strong><br>
                    • 100 SPA Points<br>
                    • +10 ELO boost<br><br>
                    
                    <strong>🎁 Người được giới thiệu nhận:</strong><br>
                    • 50 SPA Points<br>
                    • Welcome bonus<br><br>
                    
                    <strong>📊 Giới hạn:</strong> Không giới hạn
                </div>
            </div>
            
            <div class="qr-card">
                <h3>🏆 Tournament Special</h3>
                <span class="badge badge-tournament">TOURNAMENT</span>
                <div class="qr-code" id="qr3"></div>
                <div class="code-display">SABO-TOURNAMENT-SPECIAL</div>
                <div class="rewards-info">
                    <strong>🎁 Người giới thiệu nhận:</strong><br>
                    • 2 vé tham gia tournament miễn phí<br>
                    • 150 SPA Points<br><br>
                    
                    <strong>🎁 Người được giới thiệu nhận:</strong><br>
                    • 1 vé tournament miễn phí<br>
                    • Practice mode unlock<br><br>
                    
                    <strong>📊 Giới hạn:</strong> 25 lần sử dụng
                </div>
            </div>
        </div>
        
        <div class="instructions">
            <h3>🚀 Cách sử dụng mã giới thiệu:</h3>
            <ol>
                <li><strong>Chia sẻ QR code</strong> - Gửi cho bạn bè via social media</li>
                <li><strong>Bạn bè scan QR</strong> - Sử dụng SABO Arena app để scan</li>
                <li><strong>Đăng ký tài khoản</strong> - App sẽ tự động apply mã giới thiệu</li>
                <li><strong>Nhận thưởng</strong> - Cả hai đều nhận bonus ngay lập tức!</li>
            </ol>
            
            <p><strong>💡 Tips để tăng hiệu quả:</strong></p>
            <ul>
                <li>🎯 Share trong group gaming, esports communities</li>
                <li>📱 Post trên social media với hashtag #SABOArena</li>
                <li>🏆 Sử dụng Tournament code cho gamers hardcore</li>
                <li>🌟 VIP code cho những người muốn trải nghiệm premium</li>
            </ul>
        </div>
    </div>

    <script>
        const qrOptions = {
            width: 200,
            height: 200,
            colorDark: "#000000",
            colorLight: "#FFFFFF",
            correctLevel: QRCode.CorrectLevel.M
        };
        
        QRCode.toCanvas(document.getElementById('qr1'), 'SABO-GIANG-VIP', qrOptions, function (error) {
            if (error) console.error('QR1 error:', error);
            else console.log('✅ VIP referral QR generated');
        });
        
        QRCode.toCanvas(document.getElementById('qr2'), 'SABO-WELCOME-2025', qrOptions, function (error) {
            if (error) console.error('QR2 error:', error);
            else console.log('✅ Welcome referral QR generated');
        });
        
        QRCode.toCanvas(document.getElementById('qr3'), 'SABO-TOURNAMENT-SPECIAL', qrOptions, function (error) {
            if (error) console.error('QR3 error:', error);
            else console.log('✅ Tournament referral QR generated');
        });
        
        console.log('🎁 All referral QR codes generated!');
        console.log('📱 Ready for viral growth testing!');
    </script>
</body>
</html>"""
    
    with open('referral_qr_codes.html', 'w', encoding='utf-8') as f:
        f.write(html_content)
    
    print("✅ Generated: referral_qr_codes.html")
    print("🎁 Professional referral QR codes ready!")

if __name__ == "__main__":
    print("🚀 SABO Arena - Referral System Database Setup")
    print("=" * 45)
    
    # Setup database
    user_id = setup_referral_database()
    
    if user_id:
        # Create test referral codes
        created_codes = create_test_referral_codes(user_id)
        
        # Test referral code lookup
        working_codes = test_referral_code_lookup()
        
        # Generate QR codes for testing
        generate_referral_qr_codes()
        
        print(f"\n" + "=" * 45)
        print("🎉 REFERRAL SYSTEM SETUP COMPLETE!")
        print(f"✅ Database configured")
        print(f"✅ Referral codes created: {len(created_codes)}")
        print(f"✅ Working codes tested: {len(working_codes)}")
        print(f"✅ QR codes generated")
        
        if working_codes:
            print(f"\n🎁 Ready referral codes:")
            for code in working_codes:
                print(f"   • {code}")
            
            print(f"\n📱 Next steps:")
            print(f"   1. Open referral_qr_codes.html")
            print(f"   2. Test scanning in Chrome app")
            print(f"   3. Check referral signup flow!")
            print(f"\n🚀 READY FOR VIRAL GROWTH!")
        else:
            print(f"\n❌ No working referral codes")
    else:
        print(f"\n❌ Database setup failed")
    
    print("=" * 45)