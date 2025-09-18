import '../../core/constants/elo_constants.dart';
import '../../core/constants/ranking_constants.dart';

/// Tournament ELO Service - Handles ELO calculations for tournaments
/// Uses simplified fixed position-based rewards system
class TournamentEloService {
  
  /// Calculate ELO change for a player based on their tournament position
  /// Simplified system: Fixed rewards based on position only
  static int calculateEloChange({
    required int position,
    required int totalParticipants, // Not used in simplified system
  }) {
    // Fixed positions (tested and verified)
    if (position == 1) return 75;   // 1st: +75
    if (position == 2) return 45;   // 2nd: +45
    if (position == 3) return 30;   // 3rd: +30  
    if (position == 4) return 20;   // 4th: +20
    
    // Range-based positions
    if (position >= 5 && position <= 8) return 10;     // 5-8: +10
    if (position >= 9 && position <= 16) return 5;     // 9-16: +5
    
    return 0; // Others: 0
  }

  /// Calculate ELO changes for all participants in a tournament
  static Map<String, int> calculateTournamentEloChanges({
    required Map<String, int> playerPositions, // playerId -> position
    required int totalParticipants,
  }) {
    Map<String, int> eloChanges = {};
    
    for (String playerId in playerPositions.keys) {
      int position = playerPositions[playerId]!;
      int eloChange = calculateEloChange(
        position: position,
        totalParticipants: totalParticipants,
      );
      eloChanges[playerId] = eloChange;
    }
    
    return eloChanges;
  }

  /// Update player ELOs after tournament completion
  static Map<String, int> applyEloChanges({
    required Map<String, int> currentElos, // playerId -> current ELO
    required Map<String, int> eloChanges,  // playerId -> ELO change
  }) {
    Map<String, int> newElos = {};
    
    for (String playerId in currentElos.keys) {
      int currentElo = currentElos[playerId]!;
      int eloChange = eloChanges[playerId] ?? 0;
      
      int newElo = currentElo + eloChange;
      
      // Apply ELO limits
      newElo = newElo.clamp(EloConstants.MIN_ELO, EloConstants.MAX_ELO);
      
      newElos[playerId] = newElo;
    }
    
    return newElos;
  }

  /// Calculate new rank based on ELO
  static String calculateNewRank(int newElo) {
    return RankingConstants.getRankFromElo(newElo);
  }

  /// Get detailed tournament results with ELO changes and rank updates
  static Map<String, Map<String, dynamic>> getTournamentResults({
    required Map<String, int> playerPositions, // playerId -> position
    required Map<String, int> currentElos,     // playerId -> current ELO
    required Map<String, String> currentRanks, // playerId -> current rank
    required int totalParticipants,
  }) {
    Map<String, Map<String, dynamic>> results = {};
    
    // Calculate ELO changes
    Map<String, int> eloChanges = calculateTournamentEloChanges(
      playerPositions: playerPositions,
      totalParticipants: totalParticipants,
    );
    
    // Apply ELO changes
    Map<String, int> newElos = applyEloChanges(
      currentElos: currentElos,
      eloChanges: eloChanges,
    );
    
    // Calculate results for each player
    for (String playerId in playerPositions.keys) {
      int position = playerPositions[playerId]!;
      int currentElo = currentElos[playerId]!;
      int eloChange = eloChanges[playerId]!;
      int newElo = newElos[playerId]!;
      String currentRank = currentRanks[playerId]!;
      String newRank = calculateNewRank(newElo);
      
      results[playerId] = {
        'position': position,
        'positionCategory': EloConstants.getPositionCategoryVi(position),
        'currentElo': currentElo,
        'eloChange': eloChange,
        'newElo': newElo,
        'currentRank': currentRank,
        'newRank': newRank,
        'rankChanged': currentRank != newRank,
        'rankUp': RankingConstants.getRankIndex(newRank) > RankingConstants.getRankIndex(currentRank),
      };
    }
    
    return results;
  }

  /// Get ELO reward preview for tournament positions
  static Map<int, Map<String, dynamic>> getEloRewardPreview(int totalParticipants) {
    Map<int, Map<String, dynamic>> preview = {};
    
    for (int position = 1; position <= totalParticipants; position++) {
      int eloReward = calculateEloChange(position: position, totalParticipants: totalParticipants);
      String category = EloConstants.getPositionCategoryVi(position);
      
      preview[position] = {
        'position': position,
        'eloReward': eloReward,
        'category': category,
        'hasReward': eloReward > 0,
      };
    }
    
    return preview;
  }

  /// Validate tournament completion requirements
  static bool canCompleteTournament({
    required Map<String, int> playerPositions,
    required int expectedParticipants,
  }) {
    // Check if all positions are assigned
    if (playerPositions.length != expectedParticipants) {
      return false;
    }
    
    // Check if positions are valid (1 to totalParticipants)
    List<int> positions = playerPositions.values.toList();
    positions.sort();
    
    for (int i = 0; i < positions.length; i++) {
      if (positions[i] != i + 1) {
        return false; // Missing or duplicate position
      }
    }
    
    return true;
  }

  /// Get tournament statistics
  static Map<String, dynamic> getTournamentStats({
    required Map<String, int> playerPositions,
    required int totalParticipants,
  }) {
    Map<String, int> eloChanges = calculateTournamentEloChanges(
      playerPositions: playerPositions,
      totalParticipants: totalParticipants,
    );
    
    int totalEloAwarded = eloChanges.values.fold(0, (sum, change) => sum + change);
    int playersWithRewards = eloChanges.values.where((change) => change > 0).length;
    int maxEloReward = eloChanges.values.reduce((a, b) => a > b ? a : b);
    int minEloReward = eloChanges.values.reduce((a, b) => a < b ? a : b);
    
    return {
      'totalParticipants': totalParticipants,
      'totalEloAwarded': totalEloAwarded,
      'playersWithRewards': playersWithRewards,
      'maxEloReward': maxEloReward,
      'minEloReward': minEloReward,
      'averageEloChange': totalEloAwarded / totalParticipants,
    };
  }
}