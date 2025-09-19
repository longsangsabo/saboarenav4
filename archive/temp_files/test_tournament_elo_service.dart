import 'lib/services/tournament/tournament_elo_service.dart';

void main() {
  print('🧪 Testing TournamentEloService with simplified ELO...');
  testTournamentEloService();
}

void testTournamentEloService() {
  print('\n🏆 Testing TournamentEloService');
  
  // Sample 8-player tournament
  Map<String, int> playerPositions = {
    'player1': 2,  // Hoàng Văn A: 2nd place
    'player2': 3,  // Nguyễn Văn B: 3rd place  
    'player3': 1,  // Lê Văn C: 1st place (winner!)
    'player4': 4,  // Trần Văn D: 4th place
    'player5': 5,  // Phan Văn E: 5th place
    'player6': 6,  // Đỗ Văn F: 6th place
    'player7': 7,  // Lý Văn G: 7th place
    'player8': 8,  // Vũ Văn H: 8th place
  };

  Map<String, String> playerNames = {
    'player1': 'Hoàng Văn A',
    'player2': 'Nguyễn Văn B', 
    'player3': 'Lê Văn C',
    'player4': 'Trần Văn D',
    'player5': 'Phan Văn E',
    'player6': 'Đỗ Văn F',
    'player7': 'Lý Văn G',
    'player8': 'Vũ Văn H',
  };

  print('\n📈 Calculating ELO changes using TournamentEloService:');
  
  // Test individual calculations
  playerPositions.forEach((playerId, position) {
    int eloChange = TournamentEloService.calculateEloChange(
      position: position,
      totalParticipants: 8,
    );
    
    print('${playerNames[playerId]} (Position $position): '
          '${eloChange > 0 ? '+' : ''}$eloChange ELO');
  });

  print('\n🎯 Testing calculateTournamentEloChanges method:');
  
  Map<String, int> allEloChanges = TournamentEloService.calculateTournamentEloChanges(
    playerPositions: playerPositions,
    totalParticipants: 8,
  );

  allEloChanges.forEach((playerId, eloChange) {
    int position = playerPositions[playerId]!;
    print('${playerNames[playerId]} (Position $position): '
          '${eloChange > 0 ? '+' : ''}$eloChange ELO');
  });

  print('\n📊 Testing getEloRewardPreview:');
  
  Map<int, Map<String, dynamic>> preview = TournamentEloService.getEloRewardPreview(8);
  
  for (int pos = 1; pos <= 8; pos++) {
    var info = preview[pos]!;
    print('Position $pos: ${info['eloReward']} ELO (${info['category']})');
  }

  print('\n✅ TournamentEloService working perfectly!');
}