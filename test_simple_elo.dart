import 'lib/core/constants/ranking_constants.dart';
import 'lib/core/constants/elo_constants.dart';
import 'lib/services/simple_tournament_elo_service.dart';

void main() {
  print('=== TEST SIMPLE TOURNAMENT ELO SERVICE ===\n');
  
  print('--- Test 1: Thông tin cơ bản ---');
  int totalParticipants = 16;
  var eloStructure = SimpleTournamentEloService.getEloStructure(totalParticipants);
  print('Cấu trúc ELO rewards cho tournament $totalParticipants người:');
  print('Description: ${eloStructure['description']}');
  Map<String, int> rewards = eloStructure['rewards'];
  rewards.forEach((position, elo) {
    print('  $position: +$elo ELO');
  });
  
  print('\n--- Test 2: Tính ELO mới ---');
  // Test player với ELO hiện tại là 1200 (rank I+) 
  int currentElo = 1200;
  int finishPosition = 1; // Vô địch
  
  String currentRank = RankingConstants.getRankFromElo(currentElo);
  int newElo = SimpleTournamentEloService.calculateNewElo(
    currentElo: currentElo,
    position: finishPosition, 
    totalParticipants: totalParticipants,
  );
  String newRank = RankingConstants.getRankFromElo(newElo);
  
  print('Player ban đầu:');
  print('  ELO: $currentElo');
  print('  Rank: $currentRank');
  print('  Vị trí kết thúc: $finishPosition');
  print('Player sau tournament:');
  print('  ELO mới: $newElo (+${newElo - currentElo})');  
  print('  Rank mới: $newRank');
  
  print('\n--- Test 3: Tính thay đổi rank ---');
  var rankChange = SimpleTournamentEloService.calculateRankChange(
    oldElo: currentElo, 
    newElo: newElo,
  );
  print('Thay đổi rank:');
  print('  Từ: ${rankChange['oldRank']} (${rankChange['oldElo']})');
  print('  Thành: ${rankChange['newRank']} (${rankChange['newElo']})');
  print('  Rank changed: ${rankChange['rankChanged']}');
  print('  Rank up: ${rankChange['rankUp']}');
  print('  ELO change: ${rankChange['eloChange']}');
  
  print('\n--- Test 4: Preview ELO changes ---');
  int testElo = 1000; // Rank I
  var preview = SimpleTournamentEloService.previewEloChanges(
    currentElo: testElo,
    totalParticipants: totalParticipants,
  );
  print('Preview cho player ELO $testElo (${RankingConstants.getRankFromElo(testElo)}):');
  for (var change in preview) {
    int eloChange = change['eloChange'];
    String sign = eloChange >= 0 ? '+' : '';
    print('  Position ${change['position']} (${change['positionCategory']}): ${change['currentRank']} → ${change['newRank']} ($sign$eloChange)');
  }
  
  print('\n--- Test 5: Edge cases ---');
  // Test positions ngoài top rewards
  for (int pos in [9, 17, 33]) {
    int resultElo = SimpleTournamentEloService.calculateNewElo(
      currentElo: testElo,
      position: pos,
      totalParticipants: 64, // Larger tournament
    );
    int delta = resultElo - testElo;
    String sign = delta >= 0 ? '+' : '';
    print('Position $pos: $testElo → $resultElo ($sign$delta)');
  }
  
  print('\n--- Test 6: Different tournament sizes ---');
  for (int size in [4, 8, 16, 32]) {
    var structure = SimpleTournamentEloService.getEloStructure(size);
    print('Tournament $size players: ${(structure['rewards'] as Map).length} reward tiers');
  }
  
  print('\n✅ TẤT CẢ TESTS HOÀN THÀNH!');
}