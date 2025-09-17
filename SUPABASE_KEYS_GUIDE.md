# ≡ƒöæ SUPABASE KEYS GUIDE

## Service Role Key (Full Access)
```
Key: sb_secret_07Grp_TTwr21BjtBKc_gtw_5qx7UPFE
Usage: Backend scripts, admin operations, full database access
Security: KEEP SECRET - bypass all RLS policies
```

## Anon Key (Limited Access) 
```
Key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ
Usage: Flutter app, frontend, user-facing operations  
Security: Safe to public - follows RLS policies
```

## When to Use Which Key:

### Use SERVICE ROLE KEY for:
Γ£à Database audit scripts
Γ£à Data migration/population
Γ£à Admin operations
Γ£à Bulk data operations
Γ£à Bypassing RLS for maintenance

### Use ANON KEY for:
Γ£à Flutter app authentication
Γ£à User-facing CRUD operations
Γ£à Frontend API calls
Γ£à Following user permissions

## Current Scripts Status:
- Γ£à audit_database.dart - NOW USING SERVICE ROLE KEY (correct)
- Γ£à populate_correct_schema.dart - USING SERVICE ROLE KEY (correct)
- Γ£à verify_database_state.dart - USING SERVICE ROLE KEY (correct)

All database maintenance scripts are now configured correctly!
