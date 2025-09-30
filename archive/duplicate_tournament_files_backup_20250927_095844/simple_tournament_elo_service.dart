import '../core/constants/elo_constants.dart';
import '../core/constants/ranking_constants.dart';

/// Simple Tournament ELO Service - Handles basic ELO calculations
/// Based on simplified fixed position-based rewards system
class SimpleTournamentEloService {
  
  /// Calculate ELO change for a player based on tournament result
  static int calculateNewElo({
    required int position,
    required int totalParticipants,
    required int currentElo,
  }) {
    // Get ELO change based on position
    int eloChange = EloConstants.calculateEloChange(position, totalParticipants);
    
    // Calculate new ELO
    int newElo = currentElo + eloChange;
    
    // Apply ELO limits
    newElo = newElo.clamp(EloConstants.MIN_ELO, EloConstants.MAX_ELO);
    
    return newElo;
  }

  /// Get ELO change (delta) for a specific position
  static int getEloChange(int position, int totalParticipants) {
    return EloConstants.calculateEloChange(position, totalParticipants);
  }

  /// Calculate rank change after ELO update
  static Map<String, dynamic> calculateRankChange({
    required int oldElo,
    required int newElo,
  }) {
    String oldRank = RankingConstants.getRankFromElo(oldElo);
    String newRank = RankingConstants.getRankFromElo(newElo);
    
    bool rankChanged = oldRank != newRank;
    bool rankUp = false;
    bool rankDown = false;
    
    if (rankChanged) {
      List<String> rankOrder = RankingConstants.RANK_ORDER;
      int oldIndex = rankOrder.indexOf(oldRank);
      int newIndex = rankOrder.indexOf(newRank);
      
      rankUp = newIndex > oldIndex;
      rankDown = newIndex < oldIndex;
    }
    
    return {
      'oldRank': oldRank,
      'newRank': newRank,
      'rankChanged': rankChanged,
      'rankUp': rankUp,
      'rankDown': rankDown,
      'oldElo': oldElo,
      'newElo': newElo,
      'eloChange': newElo - oldElo,
    };
  }

  /// Get ELO reward structure for a tournament size
  static Map<String, dynamic> getEloStructure(int totalParticipants) {
    Map<String, int> rewards = {};
    
    // Add specific positions
    rewards['1st'] = EloConstants.ELO_1ST_PLACE;
    rewards['2nd'] = EloConstants.ELO_2ND_PLACE;
    rewards['3rd'] = EloConstants.ELO_3RD_PLACE;
    rewards['4th'] = EloConstants.ELO_4TH_PLACE;
    
    // Add ranges if applicable
    if (totalParticipants >= 5) {
      rewards['5th-8th'] = EloConstants.ELO_TOP_5_8;
    }
    if (totalParticipants >= 9) {
      rewards['9th-16th'] = EloConstants.ELO_TOP_9_16;
    }
    if (totalParticipants > 16) {
      rewards['Others'] = EloConstants.ELO_OTHERS;
    }
    
    return {
      'totalParticipants': totalParticipants,
      'rewards': rewards,
      'description': 'ELO rewards for $totalParticipants-player tournament',
    };
  }

  /// Preview ELO changes for a player across different positions
  static List<Map<String, dynamic>> previewEloChanges({
    required int currentElo,
    required int totalParticipants,
  }) {
    List<Map<String, dynamic>> preview = [];
    String currentRank = RankingConstants.getRankFromElo(currentElo);
    
    // Show changes for key positions
    List<int> keyPositions = [1, 2, 3, 4];
    if (totalParticipants >= 8) keyPositions.add(8);
    if (totalParticipants >= 16) keyPositions.add(16);
    
    for (int position in keyPositions) {
      if (position <= totalParticipants) {
        int newElo = calculateNewElo(
          position: position,
          totalParticipants: totalParticipants,
          currentElo: currentElo,
        );
        
        String newRank = RankingConstants.getRankFromElo(newElo);
        
        preview.add({
          'position': position,
          'positionCategory': EloConstants.getPositionCategoryVi(position),
          'eloChange': newElo - currentElo,
          'newElo': newElo,
          'currentRank': currentRank,
          'newRank': newRank,
          'rankChange': currentRank != newRank,
        });
      }
    }
    
    return preview;
  }
}