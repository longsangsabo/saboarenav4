// Simple standalone test without imports
void main() {
  print('=== TEST SIMPLE ELO CALCULATIONS ===\n');
  
  // ELO Constants
  const int ELO_1ST_PLACE = 75;
  const int ELO_2ND_PLACE = 45;
  const int ELO_3RD_PLACE = 30;
  const int ELO_4TH_PLACE = 20;
  const int ELO_TOP_5_8 = 10;
  const int ELO_TOP_9_16 = 5;
  const int ELO_OTHERS = 0;
  
  // Ranking data
  final Map<String, List<int>> rankEloRanges = {
    'K': [600, 699],
    'K+': [700, 799],
    'I': [800, 999],
    'I+': [1000, 1199],
    'H': [1200, 1399],
    'H+': [1400, 1599],
    'G': [1600, 1799],
    'G+': [1800, 1999],
    'F': [2000, 2199],
    'F+': [2200, 2399],
    'E': [2400, 2599],
    'E+': [2600, 3000],
  };
  
  // Calculate ELO change
  int calculateEloChange(int position) {
    if (position == 1) return ELO_1ST_PLACE;
    if (position == 2) return ELO_2ND_PLACE;
    if (position == 3) return ELO_3RD_PLACE;
    if (position == 4) return ELO_4TH_PLACE;
    if (position >= 5 && position <= 8) return ELO_TOP_5_8;
    if (position >= 9 && position <= 16) return ELO_TOP_9_16;
    return ELO_OTHERS;
  }
  
  // Get rank from ELO
  String getRankFromElo(int elo) {
    for (String rank in rankEloRanges.keys) {
      List<int> range = rankEloRanges[rank]!;
      if (elo >= range[0] && elo <= range[1]) {
        return rank;
      }
    }
    if (elo < 600) return 'Newbie';
    if (elo > 3000) return 'Legend';
    return 'Unknown';
  }
  
  print('--- Test 1: ELO Calculation ---');
  List<int> testPositions = [1, 2, 3, 4, 8, 16, 32];
  for (int pos in testPositions) {
    int eloChange = calculateEloChange(pos);
    print('Position $pos: +$eloChange ELO');
  }
  
  print('\n--- Test 2: Player Example ---');
  int currentElo = 1200;
  int position = 1;
  String currentRank = getRankFromElo(currentElo);
  int eloChange = calculateEloChange(position);
  int newElo = currentElo + eloChange;
  String newRank = getRankFromElo(newElo);
  
  print('Player hiện tại:');
  print('  ELO: $currentElo');
  print('  Rank: $currentRank');
  print('Player sau tournament (vị trí $position):');
  print('  ELO mới: $newElo (+$eloChange)');
  print('  Rank mới: $newRank');
  print('  Rank up: ${currentRank != newRank}');
  
  print('\n--- Test 3: Multiple scenarios ---');
  List<Map<String, dynamic>> scenarios = [
    {'elo': 800, 'pos': 1, 'name': 'Player I rank wins tournament'},
    {'elo': 1000, 'pos': 2, 'name': 'Player I+ rank gets 2nd'},
    {'elo': 1400, 'pos': 3, 'name': 'Player H+ rank gets 3rd'},
    {'elo': 1800, 'pos': 9, 'name': 'Player G+ rank gets 9th'},
  ];
  
  for (var scenario in scenarios) {
    int elo = scenario['elo'];
    int pos = scenario['pos'];
    String name = scenario['name'];
    
    String oldRank = getRankFromElo(elo);
    int change = calculateEloChange(pos);
    int newElo = elo + change;
    String newRank = getRankFromElo(newElo);
    
    print('$name:');
    print('  $oldRank ($elo) → $newRank ($newElo) [+$change]');
  }
  
  print('\n✅ ALL TESTS COMPLETED!');
  print('ELO System: Fixed position-based rewards');
  print('Rank System: Vietnamese billiards 12-tier system');
}