import re

# Read file
with open('lib/presentation/tournament_detail_screen/widgets/match_management_tab.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Find and replace the advancement logic
old_pattern = r'''      
      // Check if there's a next match \(not final\)
      if \(winnerAdvancesTo == null\) \{
        debugPrint\('[\w\W]*? NO NEXT MATCH - THIS IS THE FINAL! Champion: \$winnerId'\);
        return;
      \}
      
      // Find the next match by match_number \(using winner_advances_to\)
      final nextMatches = await Supabase\.instance\.client
          \.from\('matches'\)
          \.select\('\*'\)
          \.eq\('tournament_id', widget\.tournamentId\)
          \.eq\('match_number', winnerAdvancesTo\);
      
      if \(nextMatches\.isEmpty\) \{
        debugPrint\('🏆 NO NEXT MATCH FOUND - TOURNAMENT COMPLETE! Champion: \$winnerId'\);
        return;
      \}
      
      final nextMatch = nextMatches\.first;
      debugPrint\('📋 Next match found: \$\{nextMatch\['id'\]\}'\);
      
      // Determine which slot \(player1_id or player2_id\) to place winner
      // Even match numbers go to player2_id, odd go to player1_id
      final isEvenCurrentMatch = currentMatchNumber % 2 == 0;
      final playerSlot = isEvenCurrentMatch \? 'player2_id' : 'player1_id';
      
      debugPrint\('🎪 Assigning winner to \$playerSlot \(Current match \$currentMatchNumber is \$\{isEvenCurrentMatch \? \'even\' : \'odd\'\}\)'\);
      
      // Update the next round match with the winner
      await Supabase\.instance\.client
          \.from\('matches'\)
          \.update\(\{playerSlot: winnerId\}\)
          \.eq\('id', nextMatch\['id'\]\);
      
      debugPrint\('✅ WINNER ADVANCED SUCCESSFULLY! \$winnerId → Match \$winnerAdvancesTo \(\$\{nextMatch\['round_number'\]\}\)'\);
      
      // Refresh the matches display to show the update
      await _refreshMatches\(\);'''

new_code = '''      
      // ADVANCE WINNER
      if (winnerAdvancesTo != null) {
        await _advancePlayerToMatch(
          playerId: winnerId,
          targetMatchNumber: winnerAdvancesTo,
          currentMatchNumber: currentMatchNumber,
          role: 'WINNER',
        );
      } else {
        debugPrint('🏆 NO NEXT MATCH FOR WINNER - THIS IS THE FINAL! Champion: $winnerId');
      }
      
      // ADVANCE LOSER (for Double Elimination)
      if (loserAdvancesTo != null && loserId != null) {
        await _advancePlayerToMatch(
          playerId: loserId,
          targetMatchNumber: loserAdvancesTo,
          currentMatchNumber: currentMatchNumber,
          role: 'LOSER',
        );
      }
      
      // Refresh the matches display to show the update
      await _refreshMatches();'''

# Simpler approach - find exact lines and replace
lines = content.split('\n')

# Find start line "// Check if there's a next match"
start_idx = None
end_idx = None

for i, line in enumerate(lines):
    if "// Check if there's a next match (not final)" in line:
        start_idx = i - 1  # Include blank line before
        print(f"Found start at line {i+1}")
    if start_idx is not None and "await _refreshMatches();" in line:
        end_idx = i
        print(f"Found end at line {i+1}")
        break

if start_idx and end_idx:
    print(f"\nReplacing lines {start_idx+1} to {end_idx+1}")
    
    # Replace the section
    new_lines = lines[:start_idx] + new_code.split('\n') + lines[end_idx+1:]
    
    # Write back
    with open('lib/presentation/tournament_detail_screen/widgets/match_management_tab.dart', 'w', encoding='utf-8') as f:
        f.write('\n'.join(new_lines))
    
    print("✅ Replacement successful!")
else:
    print("❌ Could not find section to replace")
    print(f"start_idx: {start_idx}, end_idx: {end_idx}")
