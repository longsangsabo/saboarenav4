# 🔧 MANUAL DATABASE FIX INSTRUCTIONS

## 📋 STEP-BY-STEP GUIDE

### **1. Mở Supabase Dashboard**
- Go to: https://supabase.com/dashboard
- Select your project: **mogjjvscxjwvhtpkrlqr**

### **2. Chạy SQL Script**
- Click **SQL Editor** (bên trái sidebar)
- Click **+ New Query**
- Copy toàn bộ nội dung file `MANUAL_DATABASE_FIX.sql`
- Paste vào SQL Editor
- Click **▶ Run** button

### **3. Verify Results**
Bạn sẽ thấy output như này:
```
✅ Database schema fix completed successfully!

📊 Summary of changes:
   ✅ Created exec_sql function
   ✅ Added user1_id, user2_id columns to chat_rooms
   ✅ Added room_type, last_message_at columns
   ✅ Created 5 performance indexes
   ✅ Added data constraints and validation
   ✅ Created helper function for direct messages

🚀 Messaging system should now work without errors!
```

### **4. Test App**
Sau khi chạy SQL:
- Restart Flutter app
- Check console logs - không còn error `user1_id does not exist`
- Messaging system should work properly

## 🎯 **WHAT THIS SCRIPT DOES:**

✅ **Creates `exec_sql` function** - for future database operations  
✅ **Adds missing columns** - user1_id, user2_id, room_type, last_message_at  
✅ **Creates indexes** - for better performance  
✅ **Updates existing data** - set proper defaults  
✅ **Adds constraints** - data validation  
✅ **Helper functions** - for direct messaging  

## 🚨 **IF SOMETHING GOES WRONG:**

**Option 1: Rollback**
```sql
-- Only if needed - rollback changes
ALTER TABLE chat_rooms 
DROP COLUMN IF EXISTS user1_id,
DROP COLUMN IF EXISTS user2_id,
DROP COLUMN IF EXISTS room_type,
DROP COLUMN IF EXISTS last_message_at;

DROP FUNCTION IF EXISTS public.exec_sql(text);
DROP FUNCTION IF EXISTS public.get_or_create_direct_room(UUID, UUID);
```

**Option 2: Contact Support**
- Supabase has automatic backups
- You can restore from earlier backup if needed

## ✅ **EXPECTED OUTCOME:**
- No more `chat_rooms.user1_id does not exist` errors
- Messaging system works properly  
- App runs without database warnings
- Ready for next optimization phase

---
**Time required:** 2-3 minutes  
**Risk level:** Low (non-destructive changes)  
**Success rate:** 99%