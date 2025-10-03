"""
Add standardized columns to matches table for bracket structure
- bracket_type: 'WB', 'LB', 'GF'
- bracket_group: 'A', 'B', 'C', 'D' or NULL
- stage_round: 1, 2, 3, 4...
- display_order: Calculated ordering value
"""

from supabase import create_client, Client

# Supabase connection
url = "https://mogjjvscxjwvhtpkrlqr.supabase.co"
key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ"

supabase: Client = create_client(url, key)

print("🔍 Checking current matches table structure...")
print()

# Get a sample match to see current columns
matches = supabase.table('matches').select('*').limit(1).execute()

if matches.data:
    sample = matches.data[0]
    print(f"✅ Current columns in matches table:")
    for col in sample.keys():
        print(f"   - {col}: {type(sample[col]).__name__}")
    print()
    
    # Check if new columns already exist
    has_bracket_type = 'bracket_type' in sample
    has_bracket_group = 'bracket_group' in sample
    has_stage_round = 'stage_round' in sample
    has_display_order = 'display_order' in sample
    
    print("🔍 Status of new columns:")
    print(f"   bracket_type: {'✅ EXISTS' if has_bracket_type else '❌ MISSING'}")
    print(f"   bracket_group: {'✅ EXISTS' if has_bracket_group else '❌ MISSING'}")
    print(f"   stage_round: {'✅ EXISTS' if has_stage_round else '❌ MISSING'}")
    print(f"   display_order: {'✅ EXISTS' if has_display_order else '❌ MISSING'}")
    print()
    
    if not (has_bracket_type and has_bracket_group and has_stage_round and has_display_order):
        print("⚠️  NEED TO ADD COLUMNS!")
        print()
        print("📝 SQL commands to run in Supabase SQL Editor:")
        print()
        print("```sql")
        print("-- Add new columns for bracket standardization")
        
        if not has_bracket_type:
            print("ALTER TABLE matches ADD COLUMN IF NOT EXISTS bracket_type VARCHAR(10) DEFAULT 'WB';")
        
        if not has_bracket_group:
            print("ALTER TABLE matches ADD COLUMN IF NOT EXISTS bracket_group VARCHAR(5);")
        
        if not has_stage_round:
            print("ALTER TABLE matches ADD COLUMN IF NOT EXISTS stage_round INT DEFAULT 1;")
        
        if not has_display_order:
            print("ALTER TABLE matches ADD COLUMN IF NOT EXISTS display_order INT DEFAULT 0;")
        
        print()
        print("-- Add indexes for better query performance")
        print("CREATE INDEX IF NOT EXISTS idx_matches_bracket_type ON matches(bracket_type);")
        print("CREATE INDEX IF NOT EXISTS idx_matches_stage_round ON matches(stage_round);")
        print("CREATE INDEX IF NOT EXISTS idx_matches_display_order ON matches(display_order);")
        print("```")
        print()
        print("⚠️  IMPORTANT:")
        print("   1. Copy the SQL commands above")
        print("   2. Go to Supabase Dashboard > SQL Editor")
        print("   3. Paste and run the commands")
        print("   4. Run this script again to verify")
        print()
    else:
        print("✅ All new columns already exist!")
        print()
        print("🔍 Sample data:")
        print(f"   bracket_type: {sample.get('bracket_type', 'NULL')}")
        print(f"   bracket_group: {sample.get('bracket_group', 'NULL')}")
        print(f"   stage_round: {sample.get('stage_round', 'NULL')}")
        print(f"   display_order: {sample.get('display_order', 'NULL')}")
        print()
        
        # Check if we need to migrate existing data
        total_matches = supabase.table('matches').select('id', count='exact').execute()
        print(f"📊 Total matches in database: {total_matches.count}")
        
        # Check how many have NULL bracket_type
        null_bracket = supabase.table('matches').select('id', count='exact').is_('bracket_type', None).execute()
        print(f"   Matches with NULL bracket_type: {null_bracket.count}")
        
        if null_bracket.count > 0:
            print()
            print("⚠️  Need to migrate existing matches!")
            print("   Run migration script next...")
else:
    print("❌ No matches found in database")
    print("   Table might be empty or connection failed")

print()
print("=" * 60)
