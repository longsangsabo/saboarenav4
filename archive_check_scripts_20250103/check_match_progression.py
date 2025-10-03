import psycopg2

# Supabase Transaction Pooler
DATABASE_URL = "postgresql://postgres.mogjjvscxjwvhtpkrlqr:Acookingoil123@aws-1-ap-southeast-1.pooler.supabase.com:6543/postgres"

print("🔍 Checking match progression status...")
print("=" * 80)

try:
    conn = psycopg2.connect(DATABASE_URL)
    cursor = conn.cursor()
    
    # Check completed matches
    cursor.execute("""
        SELECT 
            match_number,
            bracket_group,
            bracket_type,
            stage_round,
            display_order,
            status,
            winner_id,
            player1_id,
            player2_id,
            winner_advances_to,
            loser_advances_to
        FROM matches
        WHERE tournament_id = '7f0b185e-8d53-4c4b-94da-88d8beb1e62d'
          AND status = 'completed'
        ORDER BY display_order
        LIMIT 10;
    """)
    
    completed = cursor.fetchall()
    
    print("\n📊 Completed Matches:")
    print("-" * 120)
    print(f"{'Match#':<8} {'Group':<8} {'Bracket':<10} {'Round':<8} {'Status':<12} {'Winner→':<12} {'Loser→':<12}")
    print("-" * 120)
    
    if completed:
        for m_num, b_group, b_type, s_round, d_order, status, w_id, p1_id, p2_id, w_adv, l_adv in completed:
            group_str = str(b_group) if b_group else "CROSS"
            w_str = str(w_adv) if w_adv else "-"
            l_str = str(l_adv) if l_adv else "-"
            print(f"{m_num:<8} {group_str:<8} {b_type:<10} {s_round:<8} {status:<12} {w_str:<12} {l_str:<12}")
    else:
        print("⚠️ NO COMPLETED MATCHES FOUND!")
    
    print("-" * 120)
    
    # Check if any matches have been auto-populated
    print("\n🔍 Checking if Round 2+ matches have been populated...")
    cursor.execute("""
        SELECT 
            bracket_group,
            bracket_type,
            stage_round,
            COUNT(*) as total,
            SUM(CASE WHEN player1_id IS NOT NULL AND player2_id IS NOT NULL THEN 1 ELSE 0 END) as populated
        FROM matches
        WHERE tournament_id = '7f0b185e-8d53-4c4b-94da-88d8beb1e62d'
          AND stage_round > 1
        GROUP BY bracket_group, bracket_type, stage_round
        ORDER BY bracket_group, bracket_type, stage_round;
    """)
    
    round2_plus = cursor.fetchall()
    
    print("-" * 80)
    print(f"{'Group':<10} {'Bracket':<10} {'Round':<8} {'Total':<8} {'Populated':<10} {'Status':<20}")
    print("-" * 80)
    
    total_r2 = 0
    total_populated = 0
    
    for b_group, b_type, s_round, total, populated in round2_plus:
        group_str = str(b_group) if b_group else "CROSS"
        status = "✅ OK" if populated == total else f"⚠️ {total - populated} empty"
        print(f"{group_str:<10} {b_type:<10} {s_round:<8} {total:<8} {populated:<10} {status:<20}")
        total_r2 += total
        total_populated += populated
    
    print("-" * 80)
    print(f"{'TOTAL':<10} {'':<10} {'':<8} {total_r2:<8} {total_populated:<10} {f'{total_populated}/{total_r2} populated':<20}")
    
    # Check advancement mappings
    print("\n🔍 Checking advancement logic (first 5 Round 1 matches)...")
    cursor.execute("""
        SELECT 
            match_number,
            display_order,
            bracket_group,
            bracket_type,
            winner_advances_to,
            loser_advances_to,
            (SELECT display_order FROM matches m2 
             WHERE m2.tournament_id = m1.tournament_id 
               AND m2.display_order = m1.winner_advances_to) as winner_target_exists,
            (SELECT display_order FROM matches m3
             WHERE m3.tournament_id = m1.tournament_id 
               AND m3.display_order = m1.loser_advances_to) as loser_target_exists
        FROM matches m1
        WHERE m1.tournament_id = '7f0b185e-8d53-4c4b-94da-88d8beb1e62d'
          AND m1.stage_round = 1
          AND m1.bracket_type IN ('WB', 'LB-A')
        ORDER BY m1.display_order
        LIMIT 5;
    """)
    
    advancements = cursor.fetchall()
    
    print("-" * 120)
    print(f"{'Match#':<8} {'Display':<10} {'Group':<8} {'Bracket':<10} {'Winner→':<12} {'Loser→':<12} {'W.Valid?':<12} {'L.Valid?':<12}")
    print("-" * 120)
    
    for m_num, d_order, b_group, b_type, w_adv, l_adv, w_valid, l_valid in advancements:
        group_str = str(b_group) if b_group else "CROSS"
        w_str = str(w_adv) if w_adv else "-"
        l_str = str(l_adv) if l_adv else "-"
        w_v = "✅" if w_valid else "❌"
        l_v = "✅" if l_valid else "❌"
        print(f"{m_num:<8} {d_order:<10} {group_str:<8} {b_type:<10} {w_str:<12} {l_str:<12} {w_v:<12} {l_v:<12}")
    
    cursor.close()
    conn.close()
    
    print("\n" + "=" * 80)
    print("✅ Analysis complete!")
    
except Exception as e:
    print(f"\n❌ Error: {e}")
    import traceback
    traceback.print_exc()
