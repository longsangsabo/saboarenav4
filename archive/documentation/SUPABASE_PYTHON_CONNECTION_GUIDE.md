# 🚀 Hướng Dẫn Kết Nối Backend Supabase với Python

## 📋 Mục Lục
1. [Thông Tin Kết Nối](#thông-tin-kết-nối)
2. [Cài Đặt Dependencies](#cài-đặt-dependencies)
3. [Cấu Hình Kết Nối](#cấu-hình-kết-nối)
4. [Ví Dụ CRUD Operations](#ví-dụ-crud-operations)
5. [Authentication](#authentication)
6. [Best Practices](#best-practices)
7. [Troubleshooting](#troubleshooting)

---

## 🔑 Thông Tin Kết Nối

### Supabase Project Details
```
Project URL: https://mogjjvscxjwvhtpkrlqr.supabase.co
Project ID: mogjjvscxjwvhtpkrlqr
```

### API Keys
```python
# Public Anon Key (client-side, read-only trong RLS)
SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ"

# Service Role Key (server-side, full admin access)
SERVICE_ROLE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo"
```

⚠️ **LƯU Ý BẢO MẬT:**
- **Anon Key**: Có thể public, dùng cho client-side
- **Service Role Key**: TUYỆT ĐỐI không public, chỉ dùng server-side

---

## 📦 Cài Đặt Dependencies

### Method 1: Sử dụng supabase-py (Recommended)
```bash
pip install supabase
```

### Method 2: Sử dụng requests (Manual)
```bash
pip install requests
```

---

## ⚙️ Cấu Hình Kết Nối

### 1. Sử dụng supabase-py Library

#### Basic Setup
```python
from supabase import create_client, Client

# Configuration
SUPABASE_URL = "https://mogjjvscxjwvhtpkrlqr.supabase.co"
SUPABASE_KEY = "your-anon-or-service-key"

# Create client
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
```

#### Environment Variables (Recommended)
```python
import os
from supabase import create_client, Client

# Load from environment
SUPABASE_URL = os.environ.get("SUPABASE_URL")
SUPABASE_KEY = os.environ.get("SUPABASE_KEY")

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
```

### 2. Sử dụng Raw HTTP Requests

```python
import requests
import json

class SupabaseClient:
    def __init__(self, url, key):
        self.url = url
        self.key = key
        self.headers = {
            "apikey": key,
            "Authorization": f"Bearer {key}",
            "Content-Type": "application/json",
            "Prefer": "return=representation"
        }
    
    def get(self, table, params=None):
        response = requests.get(
            f"{self.url}/rest/v1/{table}",
            headers=self.headers,
            params=params
        )
        return response.json() if response.status_code == 200 else None
    
    def post(self, table, data):
        response = requests.post(
            f"{self.url}/rest/v1/{table}",
            headers=self.headers,
            json=data
        )
        return response.json() if response.status_code in [200, 201] else None

# Usage
client = SupabaseClient(
    "https://mogjjvscxjwvhtpkrlqr.supabase.co",
    "your-key"
)
```

---

## 🔨 Ví Dụ CRUD Operations

### 1. READ Operations

#### Get All Users
```python
# Method 1: supabase-py
users = supabase.table('users').select('*').execute()
print(users.data)

# Method 2: requests
response = requests.get(
    "https://mogjjvscxjwvhtpkrlqr.supabase.co/rest/v1/users",
    headers=headers
)
users = response.json()
```

#### Get User by ID
```python
# Method 1: supabase-py
user = supabase.table('users').select('*').eq('id', 'user-uuid').execute()

# Method 2: requests
user = requests.get(
    f"https://mogjjvscxjwvhtpkrlqr.supabase.co/rest/v1/users?id=eq.{user_id}",
    headers=headers
).json()
```

#### Advanced Filtering
```python
# Method 1: supabase-py
high_elo_users = supabase.table('users')\
    .select('full_name, elo_rating, rank')\
    .gte('elo_rating', 1800)\
    .order('elo_rating', desc=True)\
    .limit(10)\
    .execute()

# Method 2: requests
params = {
    'select': 'full_name,elo_rating,rank',
    'elo_rating': 'gte.1800',
    'order': 'elo_rating.desc',
    'limit': 10
}
response = requests.get(
    "https://mogjjvscxjwvhtpkrlqr.supabase.co/rest/v1/users",
    headers=headers,
    params=params
)
```

### 2. CREATE Operations

#### Create New User
```python
# Method 1: supabase-py
new_user = {
    "email": "newuser@example.com",
    "full_name": "New User",
    "elo_rating": 1200,
    "rank": "I"
}
result = supabase.table('users').insert(new_user).execute()

# Method 2: requests
response = requests.post(
    "https://mogjjvscxjwvhtpkrlqr.supabase.co/rest/v1/users",
    headers=headers,
    json=new_user
)
```

### 3. UPDATE Operations

#### Update User ELO
```python
# Method 1: supabase-py
supabase.table('users')\
    .update({'elo_rating': 1350, 'rank': 'I+'})\
    .eq('id', user_id)\
    .execute()

# Method 2: requests
requests.patch(
    f"https://mogjjvscxjwvhtpkrlqr.supabase.co/rest/v1/users?id=eq.{user_id}",
    headers=headers,
    json={'elo_rating': 1350, 'rank': 'I+'}
)
```

### 4. DELETE Operations

#### Delete User
```python
# Method 1: supabase-py
supabase.table('users').delete().eq('id', user_id).execute()

# Method 2: requests
requests.delete(
    f"https://mogjjvscxjwvhtpkrlqr.supabase.co/rest/v1/users?id=eq.{user_id}",
    headers=headers
)
```

---

## 🔐 Authentication

### 1. User Authentication

#### Sign Up
```python
# Method 1: supabase-py
auth_response = supabase.auth.sign_up({
    "email": "user@example.com",
    "password": "password123"
})

# Method 2: requests
auth_data = {
    "email": "user@example.com",
    "password": "password123"
}
response = requests.post(
    "https://mogjjvscxjwvhtpkrlqr.supabase.co/auth/v1/signup",
    headers=headers,
    json=auth_data
)
```

#### Sign In
```python
# Method 1: supabase-py
auth_response = supabase.auth.sign_in_with_password({
    "email": "user@example.com",
    "password": "password123"
})

# Method 2: requests
response = requests.post(
    "https://mogjjvscxjwvhtpkrlqr.supabase.co/auth/v1/token?grant_type=password",
    headers=headers,
    json={
        "email": "user@example.com",
        "password": "password123"
    }
)
```

### 2. Admin Operations (Service Role Required)

#### Create User as Admin
```python
admin_headers = {
    "apikey": SERVICE_ROLE_KEY,
    "Authorization": f"Bearer {SERVICE_ROLE_KEY}",
    "Content-Type": "application/json"
}

# Create auth user
auth_user = requests.post(
    "https://mogjjvscxjwvhtpkrlqr.supabase.co/auth/v1/admin/users",
    headers=admin_headers,
    json={
        "email": "admin-created@example.com",
        "password": "temp123",
        "email_confirm": True
    }
)
```

---

## 📈 Best Practices

### 1. Environment Configuration
```python
# .env file
SUPABASE_URL=https://mogjjvscxjwvhtpkrlqr.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_KEY=your-service-key

# Python code
from dotenv import load_dotenv
load_dotenv()

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_ANON_KEY")  # or SERVICE_KEY for admin
```

### 2. Connection Management
```python
import functools

@functools.lru_cache()
def get_supabase_client():
    return create_client(SUPABASE_URL, SUPABASE_KEY)

# Usage
supabase = get_supabase_client()
```

### 3. Error Handling
```python
def safe_db_operation(operation):
    try:
        result = operation()
        if hasattr(result, 'data') and result.data:
            return result.data
        else:
            print(f"No data returned: {result}")
            return None
    except Exception as e:
        print(f"Database error: {e}")
        return None

# Usage
users = safe_db_operation(
    lambda: supabase.table('users').select('*').execute()
)
```

### 4. Rate Limiting
```python
import time
from functools import wraps

def rate_limit(delay=1):
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            result = func(*args, **kwargs)
            time.sleep(delay)
            return result
        return wrapper
    return decorator

@rate_limit(0.5)  # 0.5 second delay between calls
def batch_create_users(users_data):
    for user_data in users_data:
        supabase.table('users').insert(user_data).execute()
```

---

## 🐛 Troubleshooting

### Common Issues

#### 1. Authentication Errors
```
Error: Invalid API key
```
**Solution:** Kiểm tra API key và đảm bảo sử dụng đúng key cho môi trường

#### 2. RLS (Row Level Security) Issues
```
Error: new row violates row-level security policy
```
**Solution:** Sử dụng Service Role Key hoặc cấu hình RLS policies

#### 3. Foreign Key Constraints
```
Error: insert or update violates foreign key constraint
```
**Solution:** Đảm bảo referenced records tồn tại trước khi insert

#### 4. Schema Cache Issues
```
Error: Could not find table 'tablename' in schema cache
```
**Solution:** Kiểm tra tên table và đợi schema cache refresh

### Debug Script
```python
def debug_connection():
    print("🔍 Testing Supabase Connection...")
    
    try:
        # Test basic connection
        response = requests.get(
            f"{SUPABASE_URL}/rest/v1/users?select=count",
            headers={"apikey": SUPABASE_KEY, "Authorization": f"Bearer {SUPABASE_KEY}"}
        )
        
        if response.status_code == 200:
            print("✅ Connection successful")
            print(f"📊 Response: {response.headers.get('Content-Range', 'No count header')}")
        else:
            print(f"❌ Connection failed: {response.status_code}")
            print(f"📋 Error: {response.text}")
            
    except Exception as e:
        print(f"❌ Exception: {e}")

# Run debug
debug_connection()
```

---

## 📚 Useful Resources

- [Supabase Python Documentation](https://supabase.com/docs/reference/python)
- [PostgREST API Documentation](https://postgrest.org/en/stable/api.html)
- [Supabase Dashboard](https://supabase.com/dashboard/project/mogjjvscxjwvhtpkrlqr)

---

## 🔄 Database Schema Overview

### Main Tables
- `users` - User profiles và thống kê
- `tournaments` - Tournament information
- `tournament_participants` - User participation in tournaments
- `matches` - Individual matches
- `clubs` - Club information
- `posts` - Social posts
- `comments` - Post comments
- `achievements` - User achievements

### Key Fields in Users Table
```sql
users (
  id UUID PRIMARY KEY,
  email VARCHAR UNIQUE,
  full_name VARCHAR,
  username VARCHAR UNIQUE,
  rank VARCHAR(5), -- K, K+, I, I+, H, H+, G, G+, F, F+, E, E+
  elo_rating INTEGER DEFAULT 1200,
  spa_points INTEGER DEFAULT 0,
  wins INTEGER DEFAULT 0,
  losses INTEGER DEFAULT 0,
  -- ... more fields
)
```

---

*📅 Last Updated: September 18, 2025*  
*👨‍💻 Author: SABO Arena Development Team*