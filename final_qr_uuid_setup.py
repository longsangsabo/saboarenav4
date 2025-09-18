import requests
import json
import uuid

# Supabase configuration
SUPABASE_URL = "https://mogjjvscxjwvhtpkrlqr.supabase.co"
SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ"

def create_qr_users_with_valid_uuid():
    """Create QR users with proper UUID format"""
    
    headers = {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': f'Bearer {SUPABASE_ANON_KEY}',
        'Content-Type': 'application/json',
        'Prefer': 'return=representation'
    }
    
    print("🚀 SABO Arena - QR Users (Valid UUID)")
    print("=" * 35)
    
    qr_users = [
        {
            "id": str(uuid.uuid4()),
            "email": "qr123456@saboarena.com",
            "full_name": "QR Test User",
            "username": "SABO123456",
            "role": "player",
            "skill_level": "intermediate",
            "rank": "Intermediate",
            "elo_rating": 1500,
            "spa_points": 200,
            "is_verified": True,
            "is_active": True,
            "bio": "SABO123456"
        },
        {
            "id": str(uuid.uuid4()),
            "email": "qr111111@saboarena.com",
            "full_name": "Nguyễn Văn A",
            "username": "SABO111111",
            "role": "player",
            "skill_level": "beginner",
            "rank": "Beginner", 
            "elo_rating": 1200,
            "spa_points": 100,
            "is_verified": True,
            "is_active": True,
            "bio": "SABO111111"
        },
        {
            "id": str(uuid.uuid4()),
            "email": "qr222222@saboarena.com", 
            "full_name": "Trần Thị B",
            "username": "SABO222222",
            "role": "player",
            "skill_level": "advanced",
            "rank": "Advanced",
            "elo_rating": 1800,
            "spa_points": 500,
            "is_verified": True,
            "is_active": True,
            "bio": "SABO222222"
        }
    ]
    
    created = 0
    
    for user in qr_users:
        print(f"\n👤 Creating: {user['full_name']} ({user['username']})")
        print(f"   UUID: {user['id']}")
        
        try:
            response = requests.post(
                f"{SUPABASE_URL}/rest/v1/users",
                headers=headers,
                json=user
            )
            
            if response.status_code in [200, 201]:
                print(f"   ✅ Created successfully!")
                created += 1
            elif response.status_code == 409:
                print(f"   ⚠️ Already exists (conflict)")
                created += 1
            else:
                print(f"   ❌ Failed: {response.status_code}")
                print(f"   Error: {response.text}")
                
        except Exception as e:
            print(f"   💥 Exception: {e}")
    
    return created

def test_qr_lookups():
    """Test QR lookups for all created users"""
    
    headers = {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': f'Bearer {SUPABASE_ANON_KEY}',
        'Content-Type': 'application/json'
    }
    
    print(f"\n🔍 Testing QR Lookups...")
    print("=" * 20)
    
    test_codes = ["SABO123456", "SABO111111", "SABO222222"]
    working = []
    
    for code in test_codes:
        print(f"\n🔍 Testing: {code}")
        
        # Test username lookup
        try:
            response = requests.get(
                f"{SUPABASE_URL}/rest/v1/users?username=eq.{code}&select=id,full_name,username,skill_level,elo_rating",
                headers=headers
            )
            
            if response.status_code == 200:
                data = response.json()
                if data:
                    user = data[0]
                    print(f"   ✅ {user.get('full_name', 'N/A')} (ELO: {user.get('elo_rating', 'N/A')})")
                    working.append(code)
                else:
                    print(f"   ❌ Not found via username")
            else:
                print(f"   ⚠️ Username lookup error: {response.status_code}")
                
        except Exception as e:
            print(f"   💥 Exception: {e}")
    
    return working

def generate_qr_codes_html():
    """Generate HTML file with QR codes for testing"""
    
    print(f"\n📱 Generating QR Test Page...")
    print("=" * 25)
    
    html_content = """<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SABO Arena QR Test Codes</title>
    <script src="https://cdn.jsdelivr.net/npm/qrcode@1.5.3/build/qrcode.min.js"></script>
    <style>
        body {
            font-family: Arial, sans-serif;
            padding: 20px;
            background: #f0f0f0;
        }
        .qr-container {
            display: flex;
            flex-wrap: wrap;
            gap: 20px;
            justify-content: center;
        }
        .qr-card {
            background: white;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            text-align: center;
            min-width: 250px;
        }
        .qr-code {
            margin: 15px 0;
        }
        h1 {
            text-align: center;
            color: #333;
        }
        .user-info {
            color: #666;
            font-size: 14px;
            margin-top: 10px;
        }
    </style>
</head>
<body>
    <h1>🎯 SABO Arena QR Test Codes</h1>
    <p style="text-align: center;">Scan these QR codes with the Flutter app to test user lookup</p>
    
    <div class="qr-container">
        <div class="qr-card">
            <h3>QR Test User</h3>
            <div class="qr-code" id="qr1"></div>
            <div class="user-info">
                <strong>SABO123456</strong><br>
                Skill: Intermediate<br>
                ELO: 1500
            </div>
        </div>
        
        <div class="qr-card">
            <h3>Nguyễn Văn A</h3>
            <div class="qr-code" id="qr2"></div>
            <div class="user-info">
                <strong>SABO111111</strong><br>
                Skill: Beginner<br>
                ELO: 1200
            </div>
        </div>
        
        <div class="qr-card">
            <h3>Trần Thị B</h3>
            <div class="qr-code" id="qr3"></div>
            <div class="user-info">
                <strong>SABO222222</strong><br>
                Skill: Advanced<br>
                ELO: 1800
            </div>
        </div>
    </div>

    <script>
        // Generate QR codes
        QRCode.toCanvas(document.getElementById('qr1'), 'SABO123456', function (error) {
            if (error) console.error(error);
            console.log('QR1 generated successfully!');
        });
        
        QRCode.toCanvas(document.getElementById('qr2'), 'SABO111111', function (error) {
            if (error) console.error(error);
            console.log('QR2 generated successfully!');
        });
        
        QRCode.toCanvas(document.getElementById('qr3'), 'SABO222222', function (error) {
            if (error) console.error(error);
            console.log('QR3 generated successfully!');
        });
        
        console.log('🎯 QR codes ready for testing!');
    </script>
</body>
</html>"""
    
    with open('qr_test_codes.html', 'w', encoding='utf-8') as f:
        f.write(html_content)
    
    print("✅ Generated: qr_test_codes.html")
    print("📱 Open this file in browser to get QR codes for testing")

if __name__ == "__main__":
    print("🚀 SABO Arena - Final QR Setup")
    print("Creating users with proper UUIDs")
    print("=" * 40)
    
    # Create QR users
    created = create_qr_users_with_valid_uuid()
    
    # Test lookups
    working = test_qr_lookups()
    
    # Generate QR codes for testing
    generate_qr_codes_html()
    
    print(f"\n" + "=" * 40)
    print("🎯 QR System Final Status:")
    print(f"✅ Users created: {created}/3")
    print(f"✅ Working QR codes: {len(working)}")
    
    if working:
        print(f"\n🔍 Ready QR codes:")
        for code in working:
            print(f"   • {code}")
        
        print(f"\n📱 Next steps:")
        print(f"   1. Open qr_test_codes.html in browser")
        print(f"   2. Launch Flutter app on Chrome")
        print(f"   3. Test QR scanning!")
        print(f"\n🚀 Ready to launch Chrome!")
    else:
        print(f"\n❌ No working QR codes - check database")
    
    print("=" * 40)