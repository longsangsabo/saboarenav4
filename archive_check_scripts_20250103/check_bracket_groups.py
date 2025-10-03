import psycopg2

# Supabase Transaction Pooler
DATABASE_URL = "postgresql://postgres.mogjjvscxjwvhtpkrlqr:Acookingoil123@aws-1-ap-southeast-1.pooler.supabase.com:6543/postgres"

print("🔍 Checking bracket_group values in matches table...")
print("=" * 80)

try:
    conn = psycopg2.connect(DATABASE_URL)
    cursor = conn.cursor()
    
    # Check bracket_group distribution
    cursor.execute("""
        SELECT 
            bracket_group,
            bracket_type,
            COUNT(*) as count
        FROM matches
        WHERE tournament_id = '7f0b185e-8d53-4c4b-94da-88d8beb1e62d'
        GROUP BY bracket_group, bracket_type
        ORDER BY bracket_group, bracket_type;
    """)
    
    results = cursor.fetchall()
    
    print("\n📊 Bracket Group Distribution:")
    print("-" * 80)
    print(f"{'bracket_group':<20} {'bracket_type':<15} {'count':<10}")
    print("-" * 80)
    
    for bracket_group, bracket_type, count in results:
        group_str = str(bracket_group) if bracket_group else "NULL"
        print(f"{group_str:<20} {bracket_type:<15} {count:<10}")
    
    print("-" * 80)
    
    # Check sample matches
    print("\n🔍 Sample matches (first 5):")
    cursor.execute("""
        SELECT 
            match_number,
            bracket_group,
            bracket_type,
            stage_round,
            display_order
        FROM matches
        WHERE tournament_id = '7f0b185e-8d53-4c4b-94da-88d8beb1e62d'
        ORDER BY display_order
        LIMIT 5;
    """)
    
    samples = cursor.fetchall()
    print("-" * 80)
    print(f"{'match_number':<15} {'bracket_group':<15} {'bracket_type':<15} {'stage_round':<12} {'display_order':<15}")
    print("-" * 80)
    
    for match_num, b_group, b_type, s_round, d_order in samples:
        group_str = str(b_group) if b_group else "NULL"
        print(f"{match_num:<15} {group_str:<15} {b_type:<15} {s_round:<12} {d_order:<15}")
    
    cursor.close()
    conn.close()
    
    print("\n" + "=" * 80)
    print("✅ Analysis complete!")
    
except Exception as e:
    print(f"\n❌ Error: {e}")
    import traceback
    traceback.print_exc()
