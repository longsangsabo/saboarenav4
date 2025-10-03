import psycopg2

# Supabase Transaction Pooler
DATABASE_URL = "postgresql://postgres.mogjjvscxjwvhtpkrlqr:Acookingoil123@aws-1-ap-southeast-1.pooler.supabase.com:6543/postgres"

print("🔍 Checking matches with missing players...")
print("=" * 80)

try:
    conn = psycopg2.connect(DATABASE_URL)
    cursor = conn.cursor()
    
    # Check matches without players by bracket group
    cursor.execute("""
        SELECT 
            bracket_group,
            bracket_type,
            stage_round,
            COUNT(*) as total_matches,
            SUM(CASE WHEN player1_id IS NULL OR player2_id IS NULL THEN 1 ELSE 0 END) as empty_matches
        FROM matches
        WHERE tournament_id = '7f0b185e-8d53-4c4b-94da-88d8beb1e62d'
        GROUP BY bracket_group, bracket_type, stage_round
        ORDER BY bracket_group, bracket_type, stage_round;
    """)
    
    results = cursor.fetchall()
    
    print("\n📊 Match Status by Group/Bracket/Round:")
    print("-" * 80)
    print(f"{'Group':<10} {'Bracket':<10} {'Round':<8} {'Total':<8} {'Empty':<8} {'Status':<20}")
    print("-" * 80)
    
    total_matches = 0
    total_empty = 0
    
    for b_group, b_type, s_round, total, empty in results:
        group_str = str(b_group) if b_group else "CROSS"
        status = "✅ OK" if empty == 0 else f"⚠️ {empty} missing"
        print(f"{group_str:<10} {b_type:<10} {s_round:<8} {total:<8} {empty:<8} {status:<20}")
        total_matches += total
        total_empty += empty
    
    print("-" * 80)
    print(f"{'TOTAL':<10} {'':<10} {'':<8} {total_matches:<8} {total_empty:<8} {f'⚠️ {total_empty}/{total_matches} empty':<20}")
    print("-" * 80)
    
    # Show some empty matches details
    if total_empty > 0:
        print("\n🔍 Sample empty matches (first 5):")
        cursor.execute("""
            SELECT 
                match_number,
                bracket_group,
                bracket_type,
                stage_round,
                display_order,
                winner_advances_to,
                loser_advances_to
            FROM matches
            WHERE tournament_id = '7f0b185e-8d53-4c4b-94da-88d8beb1e62d'
              AND (player1_id IS NULL OR player2_id IS NULL)
            ORDER BY display_order
            LIMIT 5;
        """)
        
        samples = cursor.fetchall()
        print("-" * 100)
        print(f"{'Match#':<8} {'Group':<8} {'Bracket':<10} {'Round':<8} {'Display':<10} {'Winner→':<10} {'Loser→':<10}")
        print("-" * 100)
        
        for m_num, b_group, b_type, s_round, d_order, w_adv, l_adv in samples:
            group_str = str(b_group) if b_group else "CROSS"
            w_str = str(w_adv) if w_adv else "-"
            l_str = str(l_adv) if l_adv else "-"
            print(f"{m_num:<8} {group_str:<8} {b_type:<10} {s_round:<8} {d_order:<10} {w_str:<10} {l_str:<10}")
    
    cursor.close()
    conn.close()
    
    print("\n" + "=" * 80)
    print("✅ Analysis complete!")
    
except Exception as e:
    print(f"\n❌ Error: {e}")
    import traceback
    traceback.print_exc()
