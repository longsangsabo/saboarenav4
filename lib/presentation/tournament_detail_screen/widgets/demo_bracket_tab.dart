// 🎯 SABO ARENA - Demo Bracket Visualization Tab
// Cho phép CLB owner xem trước các format bảng đấu với data mẫu

import 'package:flutter/material.dart';
import 'demo_bracket/formats/single_elimination_bracket.dart';
// import 'demo_bracket/formats/double_elimination_bracket.dart'; // Coming soon
import 'demo_bracket/formats/round_robin_bracket.dart';
import 'demo_bracket/formats/swiss_system_bracket.dart';
import 'demo_bracket/components/bracket_components.dart';
import 'demo_bracket/shared/tournament_data_generator.dart';

class DemoBracketTab extends StatefulWidget {
  const DemoBracketTab({super.key});

  @override
  State<DemoBracketTab> createState() => _DemoBracketTabState();
}

class _DemoBracketTabState extends State<DemoBracketTab> {
  String _selectedFormat = 'single_elimination';
  int _selectedPlayerCount = 8;

  final Map<String, String> _formats = {
    'single_elimination': 'Single Elimination',
    'double_elimination': 'Double Elimination',
    'round_robin': 'Round Robin',
    'swiss': 'Swiss System',
  };

  final List<int> _playerCounts = [8, 16, 32, 64];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          _buildControls(),
          const SizedBox(height: 20),
          Expanded(
            child: _buildBracketView(),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🎮 Demo Tournament Formats',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E86AB),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Xem trước các hình thức thi đấu với dữ liệu mẫu',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildFormatSelector(),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 1,
                child: _buildPlayerCountSelector(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormatSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hình thức thi đấu',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedFormat,
              isExpanded: true,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedFormat = newValue;
                  });
                }
              },
              items: _formats.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerCountSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Số người chơi',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _selectedPlayerCount,
              isExpanded: true,
              onChanged: (int? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedPlayerCount = newValue;
                  });
                }
              },
              items: _playerCounts.map((count) {
                return DropdownMenuItem<int>(
                  value: count,
                  child: Text(
                    '$count players',
                    style: const TextStyle(fontSize: 13),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBracketView() {
    switch (_selectedFormat) {
      case 'single_elimination':
        return _buildSingleEliminationBracket();
      case 'double_elimination':
        return _buildDoubleEliminationBracket();
      case 'round_robin':
        return _buildRoundRobinBracket();
      case 'swiss':
        return _buildSwissBracket();
      default:
        return _buildSingleEliminationBracket();
    }
  }

  Widget _buildSingleEliminationBracket() {
    return SingleEliminationBracket(
      playerCount: _selectedPlayerCount,
      onFullscreenTap: _showFullscreenBracket,
    );
  }

  Widget _buildDoubleEliminationBracket() {
    // Use the new comprehensive Double Elimination calculation
    final rounds = TournamentDataGenerator.calculateDoubleEliminationRounds(_selectedPlayerCount);
    
    if (rounds.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Center(
          child: Text(
            'Failed to generate Double Elimination bracket',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }
    
    // Separate rounds by bracket type
    final winnersRounds = rounds.where((r) => r['bracketType'] == 'winners').toList();
    final losersRounds = rounds.where((r) => r['bracketType'] == 'losers').toList();
    final grandFinalRounds = rounds.where((r) => r['bracketType']?.startsWith('grand_final') == true).toList();
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          // Header section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF2E86AB), const Color(0xFF2E86AB).withOpacity(0.8)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.account_tree,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Double Elimination',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$_selectedPlayerCount players',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _showDoubleEliminationInfo(),
                  icon: const Icon(
                    Icons.info_outline,
                    color: Colors.white,
                    size: 24,
                  ),
                  tooltip: 'Thông tin chi tiết',
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _showFullscreenBracket,
                  icon: const Icon(
                    Icons.fullscreen,
                    color: Colors.white,
                    size: 24,
                  ),
                  tooltip: 'Xem toàn màn hình',
                ),
              ],
            ),
          ),
          
          // Bracket content section
          Container(
            height: 350, // Giảm từ 450 xuống 350
            padding: const EdgeInsets.all(12), // Giảm padding từ 16 xuống 12
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Winners Bracket
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.green.withOpacity(0.1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.emoji_events, color: Colors.green, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              'Winners Bracket',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 100, // Giảm height xuống 100
                          child: winnersRounds.isNotEmpty 
                              ? SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.vertical,
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: _buildRoundsWithConnectors(winnersRounds),
                                    ),
                                  ),
                                )
                              : const Center(
                                  child: Text('No winners rounds', style: TextStyle(color: Colors.grey)),
                                ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 8), // Giảm từ 12 xuống 8
                  
                  // Losers Bracket
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.orange.withOpacity(0.1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.trending_down, color: Colors.orange, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              'Losers Bracket',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 80, // Giảm height xuống 80
                          child: losersRounds.isNotEmpty 
                              ? SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.vertical,
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: _buildRoundsWithConnectors(losersRounds),
                                    ),
                                  ),
                                )
                              : const Center(
                                  child: Text(
                                    'Eliminations populate here',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 8), // Giảm từ 12 xuống 8
                  
                  // Grand Final
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.purple.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.purple.withOpacity(0.1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.military_tech, color: Colors.purple, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              'Grand Final',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 60, // Giữ nguyên 60 cho Grand Final
                          child: grandFinalRounds.isNotEmpty 
                              ? SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.vertical,
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: _buildRoundsWithConnectors(grandFinalRounds),
                                    ),
                                  ),
                                )
                              : const Center(
                                  child: Text('Grand Final', style: TextStyle(color: Colors.grey)),
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundRobinBracket() {
    return RoundRobinBracket(
      playerCount: _selectedPlayerCount,
      onFullscreenTap: _showFullscreenBracket,
    );
  }

  Widget _buildSwissBracket() {
    return SwissSystemBracket(
      playerCount: _selectedPlayerCount,
      onFullscreenTap: _showFullscreenBracket,
    );
  }

  void _showFullscreenBracket() {
    Widget dialog;
    
    switch (_selectedFormat) {
      case 'single_elimination':
        dialog = SingleEliminationFullscreenDialog(playerCount: _selectedPlayerCount);
        break;
      case 'double_elimination':
        dialog = _buildDoubleEliminationFullscreenDialog();
        break;
      case 'round_robin':
        dialog = RoundRobinFullscreenDialog(playerCount: _selectedPlayerCount);
        break;
      case 'swiss':
        dialog = SwissSystemFullscreenDialog(playerCount: _selectedPlayerCount);
        break;
      default:
        dialog = SingleEliminationFullscreenDialog(playerCount: _selectedPlayerCount);
    }
    
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => dialog,
    );
  }

  void _showDoubleEliminationInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue),
            SizedBox(width: 8),
            Text('Double Elimination'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Hình thức thi đấu loại kép',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              Text(
                '🎯 Nguyên tắc cơ bản:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 4),
              Text('• Mỗi người chơi có 2 cơ hội'),
              Text('• Thua 1 lần = rớt xuống Losers Bracket'),
              Text('• Thua 2 lần = bị loại khỏi giải đấu'),
              Text('• Winner WB vs Winner LB ở Grand Final'),
              SizedBox(height: 12),
              Text(
                '🏆 Winners Bracket (WB):',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 4),
              Text('• Player chưa thua lần nào'),
              Text('• Thua = rớt xuống Losers Bracket'),
              Text('• Thắng = tiến lên vòng tiếp theo'),
              Text('• Winner WB Final vào Grand Final'),
              SizedBox(height: 12),
              Text(
                '⚡ Losers Bracket (LB):',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              SizedBox(height: 4),
              Text('• Player đã thua 1 lần từ WB'),
              Text('• Thua thêm 1 lần = bị loại'),
              Text('• Thắng = có cơ hội phục sinh'),
              Text('• Winner LB Final vào Grand Final'),
              SizedBox(height: 12),
              Text(
                '🏅 Grand Final:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
              SizedBox(height: 4),
              Text('• Winner WB vs Winner LB'),
              Text('• Nếu Winner WB thắng = Vô địch'),
              Text('• Nếu Winner LB thắng = Reset bracket'),
              Text('• Reset bracket = đấu thêm 1 trận'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Widget _buildDoubleEliminationFullscreenDialog() {
    final rounds = TournamentDataGenerator.calculateDoubleEliminationRounds(_selectedPlayerCount);
    final winnersRounds = rounds.where((r) => r['bracketType'] == 'winners').toList();
    final losersRounds = rounds.where((r) => r['bracketType'] == 'losers').toList();
    final grandFinalRounds = rounds.where((r) => r['bracketType']?.startsWith('grand_final') == true).toList();
    
    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Double Elimination - $_selectedPlayerCount Players'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => _showDoubleEliminationInfo(),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Winners Bracket
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.green.withOpacity(0.1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.emoji_events, color: Colors.green, size: 24),
                          const SizedBox(width: 12),
                          Text(
                            'Winners Bracket',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: winnersRounds.map((round) => 
                            Container(
                              margin: const EdgeInsets.only(right: 16),
                              child: RoundColumn(
                                title: round['title'] ?? 'Round',
                                matches: List<Map<String, String>>.from(round['matches'] ?? []),
                                isFullscreen: true,
                              ),
                            ),
                          ).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Losers Bracket
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.orange.withOpacity(0.1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.trending_down, color: Colors.orange, size: 24),
                          const SizedBox(width: 12),
                          Text(
                            'Losers Bracket',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      losersRounds.isNotEmpty 
                          ? SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: losersRounds.map((round) => 
                                  Container(
                                    margin: const EdgeInsets.only(right: 16),
                                    child: RoundColumn(
                                      title: round['title'] ?? 'Round',
                                      matches: List<Map<String, String>>.from(round['matches'] ?? []),
                                      isFullscreen: true,
                                    ),
                                  ),
                                ).toList(),
                              ),
                            )
                          : Container(
                              padding: const EdgeInsets.all(32),
                              child: const Center(
                                child: Text(
                                  'Losers bracket will populate as players are eliminated from Winners Bracket',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
                
                // Grand Final
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.purple.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.purple.withOpacity(0.1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.military_tech, color: Colors.purple, size: 24),
                          const SizedBox(width: 12),
                          Text(
                            'Grand Final',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: grandFinalRounds.map((round) => 
                            Container(
                              margin: const EdgeInsets.only(right: 16),
                              child: RoundColumn(
                                title: round['title'] ?? 'Grand Final',
                                matches: List<Map<String, String>>.from(round['matches'] ?? []),
                                isFullscreen: true,
                              ),
                            ),
                          ).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Helper method to build rounds with connectors
  List<Widget> _buildRoundsWithConnectors(List<Map<String, dynamic>> rounds) {
    List<Widget> widgets = [];
    
    for (int i = 0; i < rounds.length; i++) {
      final round = rounds[i];
      final isLastRound = i == rounds.length - 1;
      
      // Add round column
      widgets.add(
        Container(
          width: 120,
          margin: const EdgeInsets.only(right: 4),
          child: RoundColumn(
            title: round['title'] ?? 'Round',
            matches: List<Map<String, String>>.from(round['matches'] ?? []),
            isFullscreen: false,
          ),
        ),
      );
      
      // Add connector if not the last round
      if (!isLastRound && i < rounds.length - 1) {
        final nextRound = rounds[i + 1];
        widgets.add(
          BracketConnector(
            fromMatchCount: (round['matches'] as List).length,
            toMatchCount: (nextRound['matches'] as List).length,
            isLastRound: isLastRound,
          ),
        );
      }
    }
    
    return widgets;
  }
}