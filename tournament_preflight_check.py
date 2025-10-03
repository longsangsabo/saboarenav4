"""
🛡️ TOURNAMENT PRE-FLIGHT CHECKER
Validates tournament structure BEFORE deployment to catch all issues early

Run this BEFORE creating any tournament to ensure 100% correctness!
"""
import os
from supabase import create_client

# Initialize Supabase
url = "https://mogjjvscxjwvhtpkrlqr.supabase.co"
key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ"
supabase = create_client(url, key)

def validate_tournament(tournament_id: str = None, tournament_name: str = None):
    """
    Run comprehensive validation on tournament structure
    
    Args:
        tournament_id: UUID of tournament to validate
        tournament_name: Name of tournament (will search by name if id not provided)
    """
    print("🛡️ TOURNAMENT PRE-FLIGHT CHECK")
    print("=" * 80)
    
    # Get tournament
    if tournament_id:
        tournament = supabase.table('tournaments').select('*').eq('id', tournament_id).single().execute()
    elif tournament_name:
        tournament = supabase.table('tournaments').select('*').ilike('name', f'%{tournament_name}%').single().execute()
    else:
        print("❌ ERROR: Must provide tournament_id or tournament_name")
        return False
    
    tournament_id = tournament.data['id']
    print(f"\n📋 Tournament: {tournament.data['name']}")
    print(f"   ID: {tournament_id}")
    print(f"   Format: {tournament.data['format']}")
    print(f"   Status: {tournament.data['status']}")
    
    # Get all matches
    matches = supabase.table('matches').select('*').eq('tournament_id', tournament_id).order('match_number').execute()
    total_matches = len(matches.data)
    print(f"   Matches: {total_matches}")
    
    print(f"\n{'='*80}")
    print("🔍 RUNNING VALIDATION CHECKS...")
    print(f"{'='*80}\n")
    
    errors = []
    warnings = []
    
    # CHECK 1: Duplicate players in same match
    print("✓ Check 1: Duplicate players...")
    for match in matches.data:
        if match['player1_id'] and match['player2_id']:
            if match['player1_id'] == match['player2_id']:
                errors.append(f"  ❌ M{match['match_number']}: Same user in both slots!")
    
    if not errors:
        print("  ✅ No duplicate players found\n")
    else:
        print(f"  ❌ Found {len(errors)} duplicate player errors\n")
    
    # CHECK 2: Advancement target existence
    print("✓ Check 2: Advancement targets exist...")
    advancement_errors = 0
    for match in matches.data:
        # Check winner_advances_to
        if match['winner_advances_to']:
            target = supabase.table('matches').select('match_number').eq('tournament_id', tournament_id).eq('display_order', match['winner_advances_to']).maybeSingle().execute()
            if not target.data:
                errors.append(f"  ❌ M{match['match_number']}: winner_advances_to={match['winner_advances_to']} does not exist!")
                advancement_errors += 1
        
        # Check loser_advances_to
        if match['loser_advances_to']:
            target = supabase.table('matches').select('match_number').eq('tournament_id', tournament_id).eq('display_order', match['loser_advances_to']).maybeSingle().execute()
            if not target.data:
                errors.append(f"  ❌ M{match['match_number']}: loser_advances_to={match['loser_advances_to']} does not exist!")
                advancement_errors += 1
    
    if advancement_errors == 0:
        print("  ✅ All advancement targets exist\n")
    else:
        print(f"  ❌ Found {advancement_errors} missing advancement targets\n")
    
    # CHECK 3: No self-advancement (match advancing to itself)
    print("✓ Check 3: No self-advancement loops...")
    self_adv_errors = 0
    for match in matches.data:
        if match['winner_advances_to'] == match['display_order']:
            errors.append(f"  ❌ M{match['match_number']}: winner_advances_to points to itself!")
            self_adv_errors += 1
        if match['loser_advances_to'] == match['display_order']:
            errors.append(f"  ❌ M{match['match_number']}: loser_advances_to points to itself!")
            self_adv_errors += 1
    
    if self_adv_errors == 0:
        print("  ✅ No self-advancement loops\n")
    else:
        print(f"  ❌ Found {self_adv_errors} self-advancement loops\n")
    
    # CHECK 4: Completed matches have winner and scores
    print("✓ Check 4: Completed matches integrity...")
    completed_errors = 0
    for match in matches.data:
        if match['status'] == 'completed':
            if not match['winner_id']:
                errors.append(f"  ❌ M{match['match_number']}: Completed but no winner!")
                completed_errors += 1
            if match['player1_score'] is None or match['player2_score'] is None:
                errors.append(f"  ❌ M{match['match_number']}: Completed but missing scores!")
                completed_errors += 1
            
            # Winner must be one of the players
            if match['winner_id']:
                if match['winner_id'] != match['player1_id'] and match['winner_id'] != match['player2_id']:
                    errors.append(f"  ❌ M{match['match_number']}: Winner is not one of the players!")
                    completed_errors += 1
    
    if completed_errors == 0:
        print("  ✅ All completed matches are valid\n")
    else:
        print(f"  ❌ Found {completed_errors} completed match errors\n")
    
    # CHECK 5: Pending matches have both players
    print("✓ Check 5: Pending matches status...")
    pending_errors = 0
    for match in matches.data:
        if match['status'] == 'pending':
            if not match['player1_id'] or not match['player2_id']:
                warnings.append(f"  ⚠️ M{match['match_number']}: Status=pending but missing players!")
                pending_errors += 1
    
    if pending_errors == 0:
        print("  ✅ All pending matches have both players\n")
    else:
        print(f"  ⚠️ Found {pending_errors} pending match warnings\n")
    
    # CHECK 6: Display order uniqueness
    print("✓ Check 6: Display order uniqueness...")
    display_orders = [m['display_order'] for m in matches.data if m['display_order']]
    duplicates = [x for x in display_orders if display_orders.count(x) > 1]
    if duplicates:
        errors.append(f"  ❌ Duplicate display_orders found: {set(duplicates)}")
        print(f"  ❌ Found duplicate display_orders\n")
    else:
        print("  ✅ All display_orders are unique\n")
    
    # CHECK 7: Match number sequence
    print("✓ Check 7: Match number sequence...")
    match_numbers = [m['match_number'] for m in matches.data]
    expected_sequence = list(range(1, len(match_numbers) + 1))
    if match_numbers != expected_sequence:
        warnings.append(f"  ⚠️ Match numbers are not sequential: {match_numbers[:10]}...")
        print(f"  ⚠️ Match numbers are not sequential\n")
    else:
        print("  ✅ Match numbers are sequential\n")
    
    # SUMMARY
    print(f"{'='*80}")
    print("📊 VALIDATION SUMMARY")
    print(f"{'='*80}\n")
    
    print(f"Total Matches: {total_matches}")
    print(f"Errors: {len(errors)}")
    print(f"Warnings: {len(warnings)}")
    
    if errors:
        print(f"\n❌ CRITICAL ERRORS ({len(errors)}):")
        for error in errors:
            print(error)
    
    if warnings:
        print(f"\n⚠️ WARNINGS ({len(warnings)}):")
        for warning in warnings:
            print(warning)
    
    if not errors and not warnings:
        print("\n🎉 ✅ TOURNAMENT STRUCTURE IS 100% VALID!")
        print("   Safe to deploy and start tournament!")
        return True
    elif errors:
        print("\n❌ TOURNAMENT HAS CRITICAL ERRORS!")
        print("   DO NOT DEPLOY - Fix errors first!")
        return False
    else:
        print("\n⚠️ TOURNAMENT HAS WARNINGS!")
        print("   Review warnings before deploying!")
        return True

# ============================================================================
# USAGE EXAMPLES
# ============================================================================

if __name__ == "__main__":
    # Example 1: Validate by tournament name
    print("Example 1: Validate SABO DE32 tournament")
    print("-" * 80)
    validate_tournament(tournament_name="SABO")
    
    # Example 2: Validate by tournament ID
    # validate_tournament(tournament_id="your-tournament-uuid-here")
    
    print("\n" + "="*80)
    print("💡 TIP: Run this script BEFORE starting any tournament!")
    print("="*80)
