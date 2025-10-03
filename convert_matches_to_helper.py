import re

# Read the file
with open('lib/services/hardcoded_sabo_de32_service.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Pattern to find allMatches.add({ ... }) blocks
# This will match the old format and convert to helper function

# Define replacement patterns for different match types

# Pattern 1: Matches WITH player IDs (WB R1 matches for both groups)
pattern_with_players = r'''allMatches\.add\(\{
\s+'tournament_id': tournamentId,
\s+'match_number': matchNumber,
\s+'bracket_type': '(\w+)',
\s+'bracket_group': '([AB])',
\s+'stage_round': (\d+),
\s+'display_order': displayOrder,
\s+'winner_advances_to': advancement\['winner'\],
\s+'loser_advances_to': advancement\['loser'\],
\s+'player1_id': ([^,]+),
\s+'player2_id': ([^,]+),
\s+'status': 'pending',
\s+\}\);'''

# Pattern 2: Matches WITHOUT player IDs (all other matches)
pattern_without_players = r'''allMatches\.add\(\{
\s+'tournament_id': tournamentId,
\s+'match_number': matchNumber,
\s+'bracket_type': '(\w+)',
\s+'bracket_group': ('[AB]'|null),
\s+'stage_round': (\d+),
\s+'display_order': displayOrder,
\s+'winner_advances_to': advancement\['winner'\],
\s+'loser_advances_to': advancement\['loser'\],
\s+'player1_id': null,
\s+'player2_id': null,
\s+'status': 'pending',
\s+\}\);'''

def replace_with_players(match):
    bracket_type = match.group(1)
    bracket_group = match.group(2)
    stage_round = match.group(3)
    player1 = match.group(4)
    player2 = match.group(5)
    
    return f'''allMatches.add(_createMatch(
        tournamentId: tournamentId,
        matchNumber: matchNumber,
        roundNumber: {stage_round},
        bracketType: '{bracket_type}',
        bracketGroup: '{bracket_group}',
        stageRound: {stage_round},
        displayOrder: displayOrder,
        winnerAdvancesTo: advancement['winner'],
        loserAdvancesTo: advancement['loser'],
        player1Id: {player1},
        player2Id: {player2},
      ));'''

def replace_without_players(match):
    bracket_type = match.group(1)
    bracket_group = match.group(2)
    stage_round = match.group(3)
    
    return f'''allMatches.add(_createMatch(
        tournamentId: tournamentId,
        matchNumber: matchNumber,
        roundNumber: {stage_round},
        bracketType: '{bracket_type}',
        bracketGroup: {bracket_group},
        stageRound: {stage_round},
        displayOrder: displayOrder,
        winnerAdvancesTo: advancement['winner'],
        loserAdvancesTo: advancement['loser'],
      ));'''

# Apply replacements
content = re.sub(pattern_with_players, replace_with_players, content, flags=re.MULTILINE)
content = re.sub(pattern_without_players, replace_without_players, content, flags=re.MULTILINE)

# Write back
with open('lib/services/hardcoded_sabo_de32_service.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print("✅ Converted all allMatches.add() calls to use _createMatch() helper")
