import psycopg2
from psycopg2 import sql

# Supabase Transaction Pooler connection string
DATABASE_URL = "postgresql://postgres.mogjjvscxjwvhtpkrlqr:Acookingoil123@aws-1-ap-southeast-1.pooler.supabase.com:6543/postgres"

print("🔧 Connecting to Supabase via Transaction Pooler...")
print("=" * 70)

try:
    # Connect to PostgreSQL
    conn = psycopg2.connect(DATABASE_URL)
    conn.autocommit = True  # Important for DDL statements
    cursor = conn.cursor()
    
    print("✅ Connected successfully!\n")
    
    # Step 1: Check current constraint status
    print("📋 Step 1: Checking current round_number constraint...")
    cursor.execute("""
        SELECT column_name, data_type, is_nullable, column_default
        FROM information_schema.columns 
        WHERE table_name = 'matches' 
        AND column_name IN ('round_number', 'stage_round', 'display_order')
        ORDER BY column_name;
    """)
    
    columns = cursor.fetchall()
    print("\nCurrent column status:")
    print("-" * 70)
    for col in columns:
        col_name, data_type, is_nullable, default = col
        nullable_str = "✅ NULLABLE" if is_nullable == "YES" else "❌ NOT NULL"
        print(f"  {col_name:20} | {data_type:15} | {nullable_str}")
    print("-" * 70)
    
    # Step 2: Remove NOT NULL constraint from round_number
    print("\n🔨 Step 2: Removing NOT NULL constraint from round_number...")
    
    alter_sql = "ALTER TABLE matches ALTER COLUMN round_number DROP NOT NULL"
    cursor.execute(alter_sql)
    
    print("✅ ALTER TABLE executed successfully!\n")
    
    # Step 3: Verify the change
    print("📋 Step 3: Verifying the change...")
    cursor.execute("""
        SELECT column_name, is_nullable
        FROM information_schema.columns 
        WHERE table_name = 'matches' AND column_name = 'round_number';
    """)
    
    result = cursor.fetchone()
    col_name, is_nullable = result
    
    print("-" * 70)
    if is_nullable == "YES":
        print(f"✅ SUCCESS! {col_name} is now NULLABLE")
    else:
        print(f"❌ FAILED! {col_name} is still NOT NULL")
    print("-" * 70)
    
    # Step 4: Check if there are any existing NULL values
    print("\n📊 Step 4: Checking existing data...")
    cursor.execute("""
        SELECT 
            COUNT(*) as total_matches,
            COUNT(round_number) as with_round_number,
            COUNT(*) - COUNT(round_number) as null_round_number
        FROM matches;
    """)
    
    stats = cursor.fetchone()
    total, with_rn, null_rn = stats
    
    print(f"\n  Total matches: {total}")
    print(f"  With round_number: {with_rn}")
    print(f"  NULL round_number: {null_rn}")
    
    # Close connection
    cursor.close()
    conn.close()
    
    print("\n" + "=" * 70)
    print("✅ MIGRATION COMPLETE!")
    print("=" * 70)
    print("\n📌 Next steps:")
    print("   1. Restart Flutter app (hot reload with 'r')")
    print("   2. Try creating SABO DE32 bracket")
    print("   3. Should work now with round_number = null")
    print("\n🎉 Database is ready!")
    
except psycopg2.Error as e:
    print(f"\n❌ PostgreSQL Error: {e}")
    print(f"   Code: {e.pgcode}")
    print(f"   Message: {e.pgerror}")
    
except Exception as e:
    print(f"\n❌ Unexpected Error: {e}")
    import traceback
    traceback.print_exc()

finally:
    print("\n" + "=" * 70)
