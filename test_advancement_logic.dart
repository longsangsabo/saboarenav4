// Test logic advancement map cho 32 người
void main() {
  print("Testing advancement map for 32 players:\n");
  
  int playerCount = 32;
  int totalRounds = 5; // log2(32) = 5
  
  Map<int, int?> map = {};
  int matchNumber = 1;
  int nextRoundStartMatch = 1;
  
  for (int round = 1; round <= totalRounds; round++) {
    int matchesInRound = (playerCount / (1 << round)).floor(); // 32/2^round
    
    print("Round $round:");
    print("  matchNumber starts at: $matchNumber");
    print("  matchesInRound: $matchesInRound");
    print("  nextRoundStartMatch BEFORE: $nextRoundStartMatch");
    
    nextRoundStartMatch += matchesInRound;
    print("  nextRoundStartMatch AFTER: $nextRoundStartMatch");
    
    for (int i = 0; i < matchesInRound; i++) {
      int currentMatch = matchNumber + i;
      
      if (round < totalRounds) {
        int nextMatchIndex = i ~/ 2;
        int nextMatch = nextRoundStartMatch + nextMatchIndex;
        map[currentMatch] = nextMatch;
        print("    Match $currentMatch → Match $nextMatch");
      } else {
        map[currentMatch] = null;
        print("    Match $currentMatch → FINAL");
      }
    }
    
    matchNumber += matchesInRound;
    print("  matchNumber AFTER: $matchNumber\n");
  }
  
  // Verify
  print("\n=== VERIFICATION ===");
  print("Expected structure:");
  print("Round 1: 16 matches (1-16) → Round 2");
  print("Round 2: 8 matches (17-24) → Round 3");
  print("Round 3: 4 matches (25-28) → Round 4");
  print("Round 4: 2 matches (29-30) → Round 5");
  print("Round 5: 1 match (31) → FINAL");
}
