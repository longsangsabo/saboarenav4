import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sabo_arena/core/app_export.dart';
import 'package:sabo_arena/theme/app_theme.dart';
import 'package:sabo_arena/services/tournament_service.dart';
import 'package:sabo_arena/services/bracket_service.dart';

class MatchManagementTab extends StatefulWidget {
  final String tournamentId;

  const MatchManagementTab({super.key, required this.tournamentId});

  @override
  _MatchManagementTabState createState() => _MatchManagementTabState();
}

class _MatchManagementTabState extends State<MatchManagementTab> {
  final TournamentService _tournamentService = TournamentService.instance;
  final BracketService _bracketService = BracketService.instance;
  
  List<Map<String, dynamic>> _matches = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedFilter = 'all'; // all, pending, in_progress, completed

  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  Future<void> _loadMatches() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('🔄 MatchManagementTab: Loading matches for tournament ${widget.tournamentId}');
      final matches = await _tournamentService.getTournamentMatches(widget.tournamentId);
      print('📊 MatchManagementTab: Loaded ${matches.length} matches');
      
      // Debug first match
      if (matches.isNotEmpty) {
        final firstMatch = matches[0];
        print('🎯 MatchManagementTab: First match data:');
        print('   matchId: ${firstMatch['matchId']}');
        print('   player1: ${firstMatch['player1']}');
        print('   player2: ${firstMatch['player2']}');
      }
      
      setState(() {
        _matches = matches;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ MatchManagementTab: Error loading matches: $e');
      setState(() {
        _errorMessage = 'Lỗi tải trận đấu: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredMatches {
    switch (_selectedFilter) {
      case 'pending':
        return _matches.where((m) => m['status'] == 'pending').toList();
      case 'in_progress':
        return _matches.where((m) => m['status'] == 'in_progress').toList();
      case 'completed':
        return _matches.where((m) => m['status'] == 'completed').toList();
      default:
        return _matches;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16.sp),
            Text('Đang tải trận đấu...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 40.sp, color: AppTheme.errorLight),
            SizedBox(height: 10.sp),
            Text("Lỗi tải dữ liệu", 
                 style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600)),
            SizedBox(height: 4.sp),
            Text(_errorMessage!, 
                 textAlign: TextAlign.center,
                 style: TextStyle(fontSize: 11.sp, color: Colors.grey[600])),
            SizedBox(height: 12.sp),
            ElevatedButton(
              onPressed: _loadMatches,
              child: Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_matches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sports_esports, size: 40.sp, color: AppTheme.dividerLight),
            SizedBox(height: 10.sp),
            Text("Chưa có trận đấu nào", 
                 style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600)),
            SizedBox(height: 4.sp),
            Text("Tạo bảng đấu để bắt đầu các trận đấu",
                 style: TextStyle(fontSize: 11.sp, color: Colors.grey[600])),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header with stats and filter
        Container(
          padding: EdgeInsets.all(12.sp),
          margin: EdgeInsets.all(12.sp),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.sp),
            border: Border.all(color: AppTheme.dividerLight),
          ),
          child: Column(
            children: [
              // Stats row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatColumn('Tổng cộng', _matches.length.toString(), Icons.sports_esports),
                  _buildStatColumn('Chờ đấu', 
                    _matches.where((m) => m['status'] == 'pending').length.toString(), 
                    Icons.schedule),
                  _buildStatColumn('Đang đấu', 
                    _matches.where((m) => m['status'] == 'in_progress').length.toString(), 
                    Icons.play_circle),
                  _buildStatColumn('Hoàn thành', 
                    _matches.where((m) => m['status'] == 'completed').length.toString(), 
                    Icons.check_circle),
                ],
              ),
              SizedBox(height: 12.sp),
              
              // Filter tabs
              Row(
                children: [
                  _buildFilterTab('all', 'Tất cả', _matches.length),
                  _buildFilterTab('pending', 'Chờ đấu', _matches.where((m) => m['status'] == 'pending').length),
                  _buildFilterTab('in_progress', 'Đang đấu', _matches.where((m) => m['status'] == 'in_progress').length),
                  _buildFilterTab('completed', 'Hoàn thành', _matches.where((m) => m['status'] == 'completed').length),
                ],
              ),
            ],
          ),
        ),

        // Matches list
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 12.sp),
            itemCount: _filteredMatches.length,
            itemBuilder: (context, index) {
              return _buildMatchCard(_filteredMatches[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatColumn(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryLight, size: 18.sp),
        SizedBox(height: 4.sp),
        Text(value, 
             style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
        Text(label, 
             textAlign: TextAlign.center,
             style: TextStyle(fontSize: 9.sp, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildFilterTab(String filter, String title, int count) {
    bool isSelected = _selectedFilter == filter;
    
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedFilter = filter),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8.sp, horizontal: 4.sp),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryLight.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(8.sp),
            border: Border.all(
              color: isSelected ? AppTheme.primaryLight : Colors.transparent,
            ),
          ),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppTheme.primaryLight : Colors.grey[600],
                ),
              ),
              Text(
                '($count)',
                style: TextStyle(
                  fontSize: 9.sp,
                  color: isSelected ? AppTheme.primaryLight : Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMatchCard(Map<String, dynamic> match) {
    final status = match['status'] ?? 'pending';
    final roundNumber = match['round_number'] ?? 1;
    final matchNumber = match['match_number'] ?? 1;
    final player1Score = match['player1_score'] ?? 0;
    final player2Score = match['player2_score'] ?? 0;

    return Container(
      margin: EdgeInsets.only(bottom: 12.sp),
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.sp),
        border: Border.all(color: AppTheme.dividerLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Vòng $roundNumber - Trận $matchNumber',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryLight,
                ),
              ),
              _buildMatchStatusBadge(status),
            ],
          ),
          SizedBox(height: 12.sp),
          
          // Players and scores
          Row(
            children: [
              // Player 1
              Expanded(
                child: _buildPlayerInfo(
                  match['player1'], 
                  player1Score, 
                  match['winner'] == 'player1',
                ),
              ),
              
              // VS separator
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.sp),
                child: Column(
                  children: [
                    Text(
                      'VS',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryLight,
                      ),
                    ),
                    if (status == 'completed')
                      Text(
                        '$player1Score - $player2Score',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
              
              // Player 2
              Expanded(
                child: _buildPlayerInfo(
                  match['player2'], 
                  player2Score, 
                  match['winner'] == 'player2',
                  isPlayer2: true,
                ),
              ),
            ],
          ),
          
          // Action buttons
          if (status != 'completed') ...[
            SizedBox(height: 12.sp),
            Row(
              children: [
                if (status == 'pending')
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _startMatch(match),
                      icon: Icon(Icons.play_arrow, size: 16.sp),
                      label: Text('Bắt đầu'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryLight,
                      ),
                    ),
                  ),
                if (status == 'pending') SizedBox(width: 8.sp),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _enterScore(match),
                    icon: Icon(Icons.edit, size: 16.sp),
                    label: Text(status == 'pending' ? 'Nhập tỷ số' : 'Cập nhật tỷ số'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.successLight,
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            SizedBox(height: 12.sp),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _editCompletedMatch(match),
                    icon: Icon(Icons.edit, size: 16.sp),
                    label: Text('Chỉnh sửa kết quả'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlayerInfo(Map<String, dynamic>? player, int score, bool isWinner, {bool isPlayer2 = false}) {
    if (player == null) {
      return Container(
        padding: EdgeInsets.all(12.sp),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8.sp),
          border: Border.all(color: AppTheme.dividerLight),
        ),
        child: Text(
          'TBD',
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey[600],
          ),
          textAlign: isPlayer2 ? TextAlign.right : TextAlign.left,
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(12.sp),
      decoration: BoxDecoration(
        color: isWinner ? AppTheme.successLight.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(8.sp),
        border: Border.all(
          color: isWinner ? AppTheme.successLight : AppTheme.dividerLight,
          width: isWinner ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: isPlayer2 ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            player['name'] ?? player['full_name'] ?? player['email'] ?? 'Unknown',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
            textAlign: isPlayer2 ? TextAlign.right : TextAlign.left,
          ),
          if (isWinner)
            Padding(
              padding: EdgeInsets.only(top: 4.sp),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.emoji_events,
                    color: AppTheme.successLight,
                    size: 14.sp,
                  ),
                  SizedBox(width: 4.sp),
                  Text(
                    'Thắng',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: AppTheme.successLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMatchStatusBadge(String status) {
    Color backgroundColor;
    Color textColor;
    String text;
    IconData icon;

    switch (status) {
      case 'completed':
        backgroundColor = AppTheme.successLight.withOpacity(0.1);
        textColor = AppTheme.successLight;
        text = 'Hoàn thành';
        icon = Icons.check_circle;
        break;
      case 'in_progress':
        backgroundColor = AppTheme.warningLight.withOpacity(0.1);
        textColor = AppTheme.warningLight;
        text = 'Đang đấu';
        icon = Icons.play_circle;
        break;
      case 'pending':
      default:
        backgroundColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey[600]!;
        text = 'Chờ đấu';
        icon = Icons.schedule;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 4.sp),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.sp),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textColor, size: 12.sp),
          SizedBox(width: 4.sp),
          Text(
            text,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _startMatch(Map<String, dynamic> match) async {
    try {
      print('🚀 Starting match: ${match["matchId"]}');
      
      // Use BracketService to start match with RPC function
      await _bracketService.startMatch(match['matchId']);

      print('✅ Match started successfully');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã bắt đầu trận đấu'),
          backgroundColor: AppTheme.successLight,
        ),
      );
      
      _loadMatches(); // Refresh
    } catch (e) {
      print('❌ Error starting match: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi bắt đầu trận đấu: ${e.toString()}'),
          backgroundColor: AppTheme.errorLight,
        ),
      );
    }
  }

  void _enterScore(Map<String, dynamic> match) {
    showDialog(
      context: context,
      builder: (context) => ScoreEntryDialog(
        match: match,
        onScoreSubmitted: (player1Score, player2Score, winnerId) {
          _updateMatchScore(match, player1Score, player2Score, winnerId);
        },
      ),
    );
  }

  void _editCompletedMatch(Map<String, dynamic> match) {
    showDialog(
      context: context,
      builder: (context) => ScoreEntryDialog(
        match: match,
        isEditing: true,
        onScoreSubmitted: (player1Score, player2Score, winnerId) {
          _updateMatchScore(match, player1Score, player2Score, winnerId);
        },
      ),
    );
  }

  Future<void> _updateMatchScore(
    Map<String, dynamic> match,
    int player1Score,
    int player2Score,
    String winnerId,
  ) async {
    try {
      print('🎯 MatchManagementTab: Updating match result: ${match["matchId"]}');
      print('   Scores: $player1Score - $player2Score');
      print('   Winner: $winnerId');
      
      // Update match result in database using BracketService
      final success = await _bracketService.saveMatchResultToDatabase(
        matchId: match['matchId'], // Use matchId not id
        winnerId: winnerId,
        player1Score: player1Score,
        player2Score: player2Score,
      );
      
      print('✅ MatchManagementTab: Match update success: $success');
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã cập nhật kết quả trận đấu'),
            backgroundColor: AppTheme.successLight,
          ),
        );
        
        print('🔄 MatchManagementTab: Refreshing matches after update...');
        await _loadMatches(); // Refresh and wait for completion
        print('✅ MatchManagementTab: Refresh completed');
      } else {
        throw Exception('Update failed - RPC returned false');
      }
    } catch (e) {
      print('❌ Error updating match result: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi cập nhật kết quả: ${e.toString()}'),
          backgroundColor: AppTheme.errorLight,
        ),
      );
    }
  }
}

class ScoreEntryDialog extends StatefulWidget {
  final Map<String, dynamic> match;
  final bool isEditing;
  final Function(int player1Score, int player2Score, String winnerId) onScoreSubmitted;

  const ScoreEntryDialog({
    super.key,
    required this.match,
    required this.onScoreSubmitted,
    this.isEditing = false,
  });

  @override
  _ScoreEntryDialogState createState() => _ScoreEntryDialogState();
}

class _ScoreEntryDialogState extends State<ScoreEntryDialog> {
  late TextEditingController _player1ScoreController;
  late TextEditingController _player2ScoreController;
  String? _selectedWinnerId;

  @override
  void initState() {
    super.initState();
    _player1ScoreController = TextEditingController(
      text: widget.isEditing ? '${widget.match['player1_score'] ?? 0}' : '0'
    );
    _player2ScoreController = TextEditingController(
      text: widget.isEditing ? '${widget.match['player2_score'] ?? 0}' : '0'
    );
    _selectedWinnerId = widget.match['winner_id'];
  }

  @override
  void dispose() {
    _player1ScoreController.dispose();
    _player2ScoreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final player1 = widget.match['player1'];
    final player2 = widget.match['player2'];

    return AlertDialog(
      title: Text(widget.isEditing ? 'Chỉnh sửa tỷ số' : 'Nhập tỷ số'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Player 1 score
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    player1?['name'] ?? player1?['full_name'] ?? 'Player 1',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _player1ScoreController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Điểm',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => _updateWinner(),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.sp),
            
            // Player 2 score
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    player2?['name'] ?? player2?['full_name'] ?? 'Player 2',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _player2ScoreController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Điểm',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => _updateWinner(),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.sp),
            
            // Winner selection
            if (_selectedWinnerId != null) ...[
              Container(
                padding: EdgeInsets.all(12.sp),
                decoration: BoxDecoration(
                  color: AppTheme.successLight.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.sp),
                  border: Border.all(color: AppTheme.successLight.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.emoji_events, color: AppTheme.successLight),
                    SizedBox(width: 8.sp),
                    Text(
                      'Người thắng: ${_getWinnerName()}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.successLight,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                padding: EdgeInsets.all(12.sp),
                decoration: BoxDecoration(
                  color: AppTheme.warningLight.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.sp),
                  border: Border.all(color: AppTheme.warningLight.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: AppTheme.warningLight),
                    SizedBox(width: 8.sp),
                    Text(
                      'Tỷ số hòa - hãy chọn người thắng',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.warningLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: _canSubmit() ? _submitScore : null,
          child: Text(widget.isEditing ? 'Cập nhật' : 'Xác nhận'),
        ),
      ],
    );
  }

  void _updateWinner() {
    final player1Score = int.tryParse(_player1ScoreController.text) ?? 0;
    final player2Score = int.tryParse(_player2ScoreController.text) ?? 0;

    setState(() {
      if (player1Score > player2Score) {
        _selectedWinnerId = widget.match['player1']?['id'];
      } else if (player2Score > player1Score) {
        _selectedWinnerId = widget.match['player2_id'];
      } else {
        _selectedWinnerId = null;
      }
    });
  }

  String _getWinnerName() {
    if (_selectedWinnerId == widget.match['player1']?['id']) {
      return widget.match['player1']?['name'] ?? widget.match['player1']?['full_name'] ?? 'Player 1';
    } else if (_selectedWinnerId == widget.match['player2']?['id']) {
      return widget.match['player2']?['name'] ?? widget.match['player2']?['full_name'] ?? 'Player 2';
    }
    return '';
  }

  bool _canSubmit() {
    final player1Score = int.tryParse(_player1ScoreController.text) ?? -1;
    final player2Score = int.tryParse(_player2ScoreController.text) ?? -1;
    return player1Score >= 0 && player2Score >= 0 && _selectedWinnerId != null;
  }

  void _submitScore() {
    final player1Score = int.tryParse(_player1ScoreController.text) ?? 0;
    final player2Score = int.tryParse(_player2ScoreController.text) ?? 0;
    
    if (_selectedWinnerId != null) {
      widget.onScoreSubmitted(player1Score, player2Score, _selectedWinnerId!);
      Navigator.of(context).pop();
    }
  }
}