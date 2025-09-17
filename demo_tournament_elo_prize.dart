// 🎯 SABO ARENA - Tournament ELO & Prize Distribution Demo
// Minh họa thực tế tính toán ELO và phân phối giải thưởng
// Với dữ liệu tournament cụ thể

void main() async {
  print('🎯 DEMO TÍNH TOÁN ELO VÀ PHÂN PHỐI GIẢI THƯỞNG');
  print('=' * 60);
  
  await demoTournamentExample();
}

Future<void> demoTournamentExample() async {
  print('\n🏆 GIẢI ĐẤU VÍ DỤ: "Giải Vô Địch Mùa Thu 2025"');
  print('📋 Thông tin giải đấu:');
  print('   • Format: Single Elimination');
  print('   • Số người tham gia: 16 người');
  print('   • Tổng tiền thưởng: 5.000.000 VNĐ');
  print('   • Phí tham gia: 100.000 VNĐ/người');
  print('   • Loại hình: 9-Ball');
  
  // Mock participants với ELO rating thực tế
  final participants = [
    {'name': 'Nguyễn Văn A', 'id': 'p1', 'elo': 2100, 'rank': 'A', 'seed': 1},
    {'name': 'Trần Văn B', 'id': 'p2', 'elo': 1950, 'rank': 'B+', 'seed': 2},
    {'name': 'Lê Văn C', 'id': 'p3', 'elo': 1890, 'rank': 'B', 'seed': 3},
    {'name': 'Phạm Văn D', 'id': 'p4', 'elo': 1820, 'rank': 'B-', 'seed': 4},
    {'name': 'Hoàng Văn E', 'id': 'p5', 'elo': 1750, 'rank': 'C+', 'seed': 5},
    {'name': 'Vũ Văn F', 'id': 'p6', 'elo': 1680, 'rank': 'C', 'seed': 6},
    {'name': 'Đỗ Văn G', 'id': 'p7', 'elo': 1620, 'rank': 'C-', 'seed': 7},
    {'name': 'Bùi Văn H', 'id': 'p8', 'elo': 1550, 'rank': 'D+', 'seed': 8},
    {'name': 'Mai Văn I', 'id': 'p9', 'elo': 1480, 'rank': 'D', 'seed': 9},
    {'name': 'Cao Văn J', 'id': 'p10', 'elo': 1420, 'rank': 'D-', 'seed': 10},
    {'name': 'Đinh Văn K', 'id': 'p11', 'elo': 1350, 'rank': 'E+', 'seed': 11},
    {'name': 'Dương Văn L', 'id': 'p12', 'elo': 1290, 'rank': 'E', 'seed': 12},
    {'name': 'Lý Văn M', 'id': 'p13', 'elo': 1230, 'rank': 'E-', 'seed': 13},
    {'name': 'Phan Văn N', 'id': 'p14', 'elo': 1180, 'rank': 'F', 'seed': 14},
    {'name': 'Tô Văn O', 'id': 'p15', 'elo': 1120, 'rank': 'K+', 'seed': 15},
    {'name': 'Võ Văn P', 'id': 'p16', 'elo': 1050, 'rank': 'K', 'seed': 16},
  ];
  
  print('\n👥 DANH SÁCH THAM GIA (seeded theo ELO):');
  for (int i = 0; i < participants.length; i++) {
    final p = participants[i];
    print('   ${i + 1}. ${p['name']} - ELO: ${p['elo']} (${p['rank']})');
  }
  
  // Simulate tournament results với một số upset
  final tournamentResults = [
    // Final results after tournament
    {'participant': participants[2], 'position': 1, 'matches_won': 4, 'matches_lost': 0, 'upsets': 2}, // Lê Văn C (seed 3) WON!
    {'participant': participants[0], 'position': 2, 'matches_won': 3, 'matches_lost': 1, 'upsets': 0}, // Nguyễn Văn A (seed 1) Runner-up
    {'participant': participants[4], 'position': 3, 'matches_won': 3, 'matches_lost': 1, 'upsets': 1}, // Hoàng Văn E (seed 5) 3rd
    {'participant': participants[6], 'position': 4, 'matches_won': 2, 'matches_lost': 1, 'upsets': 2}, // Đỗ Văn G (seed 7) 4th
    {'participant': participants[1], 'position': 5, 'matches_won': 2, 'matches_lost': 1, 'upsets': 0}, // Trần Văn B (seed 2) 5-8th
    {'participant': participants[3], 'position': 6, 'matches_won': 2, 'matches_lost': 1, 'upsets': 0}, // Phạm Văn D (seed 4) 5-8th
    {'participant': participants[5], 'position': 7, 'matches_won': 2, 'matches_lost': 1, 'upsets': 0}, // Vũ Văn F (seed 6) 5-8th
    {'participant': participants[7], 'position': 8, 'matches_won': 2, 'matches_lost': 1, 'upsets': 0}, // Bùi Văn H (seed 8) 5-8th
    {'participant': participants[8], 'position': 9, 'matches_won': 1, 'matches_lost': 1, 'upsets': 0}, // Mai Văn I (seed 9) 9-16th
    {'participant': participants[9], 'position': 10, 'matches_won': 1, 'matches_lost': 1, 'upsets': 0}, // Cao Văn J (seed 10)
    {'participant': participants[10], 'position': 11, 'matches_won': 1, 'matches_lost': 1, 'upsets': 0}, // Đinh Văn K (seed 11)
    {'participant': participants[11], 'position': 12, 'matches_won': 1, 'matches_lost': 1, 'upsets': 0}, // Dương Văn L (seed 12)
    {'participant': participants[12], 'position': 13, 'matches_won': 0, 'matches_lost': 1, 'upsets': 0}, // Lý Văn M (seed 13)
    {'participant': participants[13], 'position': 14, 'matches_won': 0, 'matches_lost': 1, 'upsets': 0}, // Phan Văn N (seed 14)
    {'participant': participants[14], 'position': 15, 'matches_won': 0, 'matches_lost': 1, 'upsets': 0}, // Tô Văn O (seed 15)
    {'participant': participants[15], 'position': 16, 'matches_won': 0, 'matches_lost': 1, 'upsets': 0}, // Võ Văn P (seed 16)
  ];
  
  print('\n🏁 KỐT QUẢ GIẢI ĐẤU:');
  final winner = tournamentResults[0]['participant'] as Map<String, dynamic>;
  final runnerUp = tournamentResults[1]['participant'] as Map<String, dynamic>;
  final third = tournamentResults[2]['participant'] as Map<String, dynamic>;
  final fourth = tournamentResults[3]['participant'] as Map<String, dynamic>;
  
  print('   🥇 1st: ${winner['name']} (Seed ${winner['seed']}) - UPSET WINNER!');
  print('   � 2nd: ${runnerUp['name']} (Seed ${runnerUp['seed']})');
  print('   🥉 3rd: ${third['name']} (Seed ${third['seed']})');
  print('   4th: ${fourth['name']} (Seed ${fourth['seed']})');
  print('   ...');
  
  // Calculate prize distribution
  await calculatePrizeDistribution(tournamentResults);
  
  // Calculate ELO changes
  await calculateEloChanges(tournamentResults);
  
  // Show ranking changes
  await showRankingChanges(tournamentResults);
}

Future<void> calculatePrizeDistribution(List<Map<String, dynamic>> results) async {
  print('\n💰 PHÂN PHỐI GIẢI THƯỞNG (Template: Standard cho 16 người):');
  
  final totalPrizePool = 5000000.0; // 5 triệu VNĐ
  
  // Standard distribution for 16 players: [40%, 25%, 15%, 10%, 5%, 5%]
  final distribution = [0.40, 0.25, 0.15, 0.10, 0.05, 0.05];
  
  for (int i = 0; i < distribution.length; i++) {
    final position = i + 1;
    final percentage = distribution[i];
    final prizeAmount = totalPrizePool * percentage;
    final participant = results[i]['participant'];
    
    print('   ${position == 1 ? '🥇' : position == 2 ? '🥈' : position == 3 ? '🥉' : '${position}th'} ${participant['name']}: ${prizeAmount.toStringAsFixed(0)} VNĐ (${(percentage * 100).toStringAsFixed(1)}%)');
  }
  
  final totalDistributed = distribution.fold(0.0, (sum, p) => sum + p) * totalPrizePool;
  print('   📊 Tổng đã phân phối: ${totalDistributed.toStringAsFixed(0)} VNĐ');
  print('   💳 Phí BTC (10%): ${(totalPrizePool * 0.1).toStringAsFixed(0)} VNĐ');
}

Future<void> calculateEloChanges(List<Map<String, dynamic>> results) async {
  print('\n⭐ TÍNH TOÁN THAY ĐỔI ELO:');
  print('📋 Công thức: Base Change + Tournament Bonuses + Performance Modifier');
  
  for (int i = 0; i < results.length && i < 8; i++) { // Show top 8
    final result = results[i];
    final participant = result['participant'];
    final position = result['position'] as int;
    final currentElo = participant['elo'] as int;
    final seed = participant['seed'] as int;
    final upsets = result['upsets'] as int;
    final matchesLost = result['matches_lost'] as int;
    
    // Calculate base ELO change
    final kFactor = getKFactor(currentElo);
    final baseChange = calculateBaseEloChange(position, 16, kFactor);
    
    // Calculate bonuses
    int bonuses = 0;
    
    // Tournament size bonus (16 players = +3)
    bonuses += 3;
    
    // Perfect run bonus
    if (matchesLost == 0 && position == 1) {
      bonuses += 8;
      print('     🔥 Perfect run bonus: +8');
    }
    
    // Upset bonus
    if (upsets > 0) {
      final upsetBonus = upsets * 5;
      bonuses += upsetBonus;
      print('     💥 Upset bonus (${upsets}x): +${upsetBonus}');
    }
    
    // Performance modifier
    final expectedPosition = seed; // Seed = expected position
    final performanceDiff = expectedPosition - position;
    double performanceMultiplier = 1.0;
    
    if (performanceDiff > 0) {
      // Outperformed
      performanceMultiplier = 1.0 + (performanceDiff * 0.2);
      performanceMultiplier = performanceMultiplier > 2.0 ? 2.0 : performanceMultiplier;
    } else if (performanceDiff < 0) {
      // Underperformed  
      performanceMultiplier = 1.0 + (performanceDiff * 0.1);
      performanceMultiplier = performanceMultiplier < 0.5 ? 0.5 : performanceMultiplier;
    }
    
    final finalChange = ((baseChange + bonuses) * performanceMultiplier).round();
    final newElo = currentElo + finalChange;
    
    final positionText = position == 1 ? '🥇 1st' : position == 2 ? '🥈 2nd' : position == 3 ? '🥉 3rd' : '${position}th';
    
    print('\n   $positionText ${participant['name']} (Seed $seed):');
    print('     📊 Current ELO: $currentElo → $newElo (${finalChange >= 0 ? '+' : ''}$finalChange)');
    print('     📈 Base change: ${baseChange >= 0 ? '+' : ''}$baseChange (K-factor: $kFactor)');
    print('     🎁 Bonuses: +$bonuses');
    print('     ⚡ Performance: x${performanceMultiplier.toStringAsFixed(2)} ${performanceDiff > 0 ? '(outperformed)' : performanceDiff < 0 ? '(underperformed)' : '(as expected)'}');
    
    // Check for rank change
    final oldRank = getRankFromElo(currentElo);
    final newRank = getRankFromElo(newElo);
    if (oldRank != newRank) {
      print('     🔄 Rank change: $oldRank → $newRank ${isPromotion(oldRank, newRank) ? '⬆️' : '⬇️'}');
    }
  }
}

Future<void> showRankingChanges(List<Map<String, dynamic>> results) async {
  print('\n🔄 THAY ĐỔI HẠNG NỔI BẬT:');
  
  final significantChanges = <Map<String, dynamic>>[];
  
  for (final result in results) {
    final participant = result['participant'];
    final currentElo = participant['elo'] as int;
    final position = result['position'] as int;
    final seed = participant['seed'] as int;
    
    // Calculate new ELO (simplified)
    final kFactor = getKFactor(currentElo);
    final baseChange = calculateBaseEloChange(position, 16, kFactor);
    final bonuses = 3 + ((result['upsets'] as int) * 5); // Simplified
    final performanceDiff = seed - position;
    final performanceMultiplier = performanceDiff > 0 ? 1.5 : performanceDiff < 0 ? 0.8 : 1.0;
    
    final finalChange = ((baseChange + bonuses) * performanceMultiplier).round();
    final newElo = currentElo + finalChange;
    
    final oldRank = getRankFromElo(currentElo);
    final newRank = getRankFromElo(newElo);
    
    if (oldRank != newRank) {
      significantChanges.add({
        'name': participant['name'],
        'old_rank': oldRank,
        'new_rank': newRank,
        'old_elo': currentElo,
        'new_elo': newElo,
        'change': finalChange,
        'is_promotion': isPromotion(oldRank, newRank),
      });
    }
  }
  
  if (significantChanges.isEmpty) {
    print('   📊 Không có thay đổi hạng đáng kể trong giải đấu này');
  } else {
    for (final change in significantChanges) {
      final icon = change['is_promotion'] ? '⬆️ THĂNG HẠNG' : '⬇️ GIÁNG HẠNG';
      print('   $icon ${change['name']}: ${change['old_rank']} → ${change['new_rank']} (ELO: ${change['old_elo']} → ${change['new_elo']})');
    }
  }
  
  print('\n📈 THỐNG KÊ TỔNG QUAN:');
  final totalEloDistributed = results.map((r) {
    final participant = r['participant'];
    final currentElo = participant['elo'] as int;
    final position = r['position'] as int;
    final kFactor = getKFactor(currentElo);
    final baseChange = calculateBaseEloChange(position, 16, kFactor);
    return baseChange;
  }).fold(0, (sum, change) => sum + change);
  
  print('   💎 Tổng ELO được phân phối: ${totalEloDistributed >= 0 ? '+' : ''}$totalEloDistributed điểm');
  print('   🏆 Số người thắng ELO: ${results.take(8).length} người');
  print('   📉 Số người mất ELO: ${results.skip(8).length} người');
  print('   🔄 Số người thay đổi hạng: ${significantChanges.length} người');
}

// Helper functions
int getKFactor(int elo) {
  if (elo < 1400) return 32;      // New players
  if (elo < 2000) return 24;      // Regular players  
  return 16;                      // Expert players
}

int calculateBaseEloChange(int position, int totalParticipants, int kFactor) {
  if (position == 1) return (kFactor * 0.8).round();              // Winner: 80% of K-factor
  if (position <= totalParticipants * 0.25) return (kFactor * 0.4).round(); // Top 25%: 40%
  if (position <= totalParticipants * 0.5) return (kFactor * 0.1).round();  // Top 50%: 10%
  if (position <= totalParticipants * 0.75) return -(kFactor * 0.1).round(); // 50-75%: -10%
  return -(kFactor * 0.3).round();                                // Bottom 25%: -30%
}

String getRankFromElo(int elo) {
  if (elo >= 2400) return 'E+';
  if (elo >= 2200) return 'E';
  if (elo >= 2000) return 'E-';
  if (elo >= 1900) return 'D+';
  if (elo >= 1800) return 'D';
  if (elo >= 1700) return 'D-';
  if (elo >= 1600) return 'C+';
  if (elo >= 1500) return 'C';
  if (elo >= 1400) return 'C-';
  if (elo >= 1350) return 'B+';
  if (elo >= 1300) return 'B';
  if (elo >= 1250) return 'B-';
  if (elo >= 1200) return 'A+';
  if (elo >= 1150) return 'A';
  if (elo >= 1100) return 'A-';
  if (elo >= 1050) return 'K+';
  return 'K';
}

bool isPromotion(String oldRank, String newRank) {
  const rankOrder = ['K', 'K+', 'A-', 'A', 'A+', 'B-', 'B', 'B+', 'C-', 'C', 'C+', 'D-', 'D', 'D+', 'E-', 'E', 'E+'];
  final oldIndex = rankOrder.indexOf(oldRank);
  final newIndex = rankOrder.indexOf(newRank);
  return newIndex > oldIndex;
}