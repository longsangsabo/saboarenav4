import 'package:flutter/material.dart';
import 'package:sabo_arena/core/app_export.dart';

class TournamentBracketView extends StatefulWidget {
  final String tournamentId;
  final String format; // 'single_elimination', 'double_elimination', 'round_robin'
  final int totalParticipants;
  final bool isEditable;

  const TournamentBracketView({
    super.key,
    required this.tournamentId,
    required this.format,
    required this.totalParticipants,
    this.isEditable = false,
  });

  @override
  _TournamentBracketViewState createState() => _TournamentBracketViewState();
}

class _TournamentBracketViewState extends State<TournamentBracketView>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  final ScrollController _scrollController = ScrollController();
  double _scaleFactor = 1.0;
  
  List<BracketRound> _rounds = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _loadBracketData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadBracketData() async {
    // Simulate data loading
    await Future.delayed(Duration(milliseconds: 1000));
    
    setState(() {
      _rounds = _generateMockBracket();
      _isLoading = false;
    });
    
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.h)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _isLoading ? _buildLoadingState() : _buildBracketContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: appTheme.gray200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Bảng đấu",
                  style: TextStyle(
                    fontSize: 18.fSize,
                    fontWeight: FontWeight.bold,
                    color: appTheme.gray900,
                  ),
                ),
                Text(
                  _getFormatDescription(),
                  style: TextStyle(
                    fontSize: 12.fSize,
                    color: appTheme.gray600,
                  ),
                ),
              ],
            ),
          ),
          
          // Zoom controls
          Container(
            decoration: BoxDecoration(
              color: appTheme.gray100,
              borderRadius: BorderRadius.circular(8.h),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => _updateScale(false),
                  icon: Icon(Icons.zoom_out, size: 18.adaptSize),
                  padding: EdgeInsets.all(8.h),
                  constraints: BoxConstraints(minWidth: 32.h, minHeight: 32.v),
                ),
                Container(width: 1, height: 20.v, color: appTheme.gray300),
                IconButton(
                  onPressed: () => _updateScale(true),
                  icon: Icon(Icons.zoom_in, size: 18.adaptSize),
                  padding: EdgeInsets.all(8.h),
                  constraints: BoxConstraints(minWidth: 32.h, minHeight: 32.v),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: appTheme.blue600),
          SizedBox(height: 16.v),
          Text(
            "Đang tải bảng đấu...",
            style: TextStyle(
              fontSize: 14.fSize,
              color: appTheme.gray600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBracketContent() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(
            scale: _scaleFactor,
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Container(
                  padding: EdgeInsets.all(16.h),
                  child: _buildBracketLayout(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBracketLayout() {
    if (widget.format == 'round_robin') {
      return _buildRoundRobinTable();
    } else {
      return _buildEliminationBracket();
    }
  }

  Widget _buildEliminationBracket() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: _rounds.asMap().entries.map((entry) {
        final index = entry.key;
        final round = entry.value;
        
        return Row(
          children: [
            _buildRoundColumn(round, index),
            if (index < _rounds.length - 1)
              SizedBox(width: 40.h), // Spacing between rounds
          ],
        );
      }).toList(),
    );
  }

  Widget _buildRoundColumn(BracketRound round, int roundIndex) {
    return Column(
      children: [
        // Round header
        Container(
          margin: EdgeInsets.only(bottom: 16.v),
          padding: EdgeInsets.symmetric(horizontal: 12.h, vertical: 6.v),
          decoration: BoxDecoration(
            color: appTheme.blue600,
            borderRadius: BorderRadius.circular(12.h),
          ),
          child: Text(
            round.name,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.fSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        
        // Matches in this round
        ...round.matches.asMap().entries.map((entry) {
          final matchIndex = entry.key;
          final match = entry.value;
          
          return Container(
            margin: EdgeInsets.only(bottom: _getMatchSpacing(roundIndex, matchIndex)),
            child: _buildMatchCard(match),
          );
        }),
      ],
    );
  }

  Widget _buildMatchCard(BracketMatch match) {
    return Container(
      width: 180.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.h),
        border: Border.all(
          color: match.status == 'completed' 
            ? appTheme.green600.withOpacity(0.3)
            : appTheme.gray300,
        ),
        boxShadow: [
          BoxShadow(
            color: appTheme.black900.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildPlayerRow(match.player1, match.score1, match.winner == 1),
          Container(height: 1, color: appTheme.gray200),
          _buildPlayerRow(match.player2, match.score2, match.winner == 2),
          
          if (match.status != 'pending' && match.scheduledTime != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.h, vertical: 4.v),
              decoration: BoxDecoration(
                color: appTheme.gray50,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(8.h)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    match.status == 'completed' ? Icons.check_circle_outline : Icons.schedule,
                    size: 12.adaptSize,
                    color: match.status == 'completed' ? appTheme.green600 : appTheme.orange600,
                  ),
                  SizedBox(width: 4.h),
                  Text(
                    match.status == 'completed' ? 'Hoàn thành' : match.scheduledTime!,
                    style: TextStyle(
                      fontSize: 10.fSize,
                      color: match.status == 'completed' ? appTheme.green600 : appTheme.orange600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlayerRow(String? playerName, int? score, bool isWinner) {
    final isEmpty = playerName == null;
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.h, vertical: 8.v),
      decoration: BoxDecoration(
        color: isWinner 
          ? appTheme.green600.withOpacity(0.1)
          : Colors.transparent,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              isEmpty ? 'TBD' : playerName,
              style: TextStyle(
                fontSize: 13.fSize,
                fontWeight: isWinner ? FontWeight.w600 : FontWeight.normal,
                color: isEmpty 
                  ? appTheme.gray400
                  : (isWinner ? appTheme.green700 : appTheme.gray900),
              ),
            ),
          ),
          
          if (!isEmpty && score != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.h, vertical: 2.v),
              decoration: BoxDecoration(
                color: isWinner ? appTheme.green600 : appTheme.gray400,
                borderRadius: BorderRadius.circular(4.h),
              ),
              child: Text(
                score.toString(),
                style: TextStyle(
                  fontSize: 11.fSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRoundRobinTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.h),
        border: Border.all(color: appTheme.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16.h),
            decoration: BoxDecoration(
              color: appTheme.gray50,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12.h)),
            ),
            child: Text(
              "Bảng xếp hạng Round Robin",
              style: TextStyle(
                fontSize: 16.fSize,
                fontWeight: FontWeight.bold,
                color: appTheme.gray900,
              ),
            ),
          ),
          
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                DataColumn(label: Text('Hạng')),
                DataColumn(label: Text('Người chơi')),
                DataColumn(label: Text('Thắng')),
                DataColumn(label: Text('Thua')),
                DataColumn(label: Text('Điểm')),
              ],
              rows: _getMockRoundRobinData().map((player) {
                return DataRow(
                  cells: [
                    DataCell(Text(player['rank'].toString())),
                    DataCell(Text(player['name'])),
                    DataCell(Text(player['wins'].toString())),
                    DataCell(Text(player['losses'].toString())),
                    DataCell(Text(player['points'].toString())),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  double _getMatchSpacing(int roundIndex, int matchIndex) {
    // Increase spacing in later rounds to align with bracket structure
    return 16.v * (1 << roundIndex);
  }

  void _updateScale(bool zoomIn) {
    setState(() {
      if (zoomIn && _scaleFactor < 2.0) {
        _scaleFactor += 0.2;
      } else if (!zoomIn && _scaleFactor > 0.5) {
        _scaleFactor -= 0.2;
      }
    });
  }

  String _getFormatDescription() {
    switch (widget.format) {
      case 'single_elimination':
        return 'Loại trực tiếp đơn - ${widget.totalParticipants} người chơi';
      case 'double_elimination':
        return 'Loại trực tiếp kép - ${widget.totalParticipants} người chơi';
      case 'round_robin':
        return 'Đấu vòng tròn - ${widget.totalParticipants} người chơi';
      default:
        return '${widget.totalParticipants} người chơi';
    }
  }

  List<BracketRound> _generateMockBracket() {
    if (widget.format == 'round_robin') {
      return []; // Round robin doesn't use bracket structure
    }
    
    // Generate single elimination bracket for demo
    final rounds = <BracketRound>[];
    int participantsInRound = widget.totalParticipants;
    int roundNumber = 1;
    
    while (participantsInRound > 1) {
      final matches = <BracketMatch>[];
      final matchesInRound = participantsInRound ~/ 2;
      
      for (int i = 0; i < matchesInRound; i++) {
        String? player1, player2;
        int? score1, score2;
        int? winner;
        String status = 'pending';
        
        // Mock some completed matches in early rounds
        if (roundNumber == 1) {
          player1 = 'Người chơi ${i * 2 + 1}';
          player2 = 'Người chơi ${i * 2 + 2}';
          
          if (i < 2) { // First 2 matches completed
            score1 = 3;
            score2 = 1;
            winner = 1;
            status = 'completed';
          }
        } else if (roundNumber == 2 && i == 0) {
          player1 = 'Người chơi 1';
          player2 = 'Người chơi 3';
          score1 = 3;
          score2 = 2;
          winner = 1;
          status = 'completed';
        }
        
        matches.add(BracketMatch(
          id: 'r${roundNumber}_m${i + 1}',
          player1: player1,
          player2: player2,
          score1: score1,
          score2: score2,
          winner: winner,
          status: status,
          scheduledTime: status != 'pending' ? null : '14:${30 + i * 15}',
        ));
      }
      
      rounds.add(BracketRound(
        name: _getRoundName(roundNumber, participantsInRound),
        matches: matches,
      ));
      
      participantsInRound = matchesInRound;
      roundNumber++;
    }
    
    return rounds;
  }

  String _getRoundName(int roundNumber, int participantsInRound) {
    if (participantsInRound <= 2) return 'Chung kết';
    if (participantsInRound <= 4) return 'Bán kết';
    if (participantsInRound <= 8) return 'Tứ kết';
    return 'Vòng $roundNumber';
  }

  List<Map<String, dynamic>> _getMockRoundRobinData() {
    return [
      {'rank': 1, 'name': 'Nguyễn Văn A', 'wins': 4, 'losses': 0, 'points': 12},
      {'rank': 2, 'name': 'Lê Văn B', 'wins': 3, 'losses': 1, 'points': 9},
      {'rank': 3, 'name': 'Trần Văn C', 'wins': 2, 'losses': 2, 'points': 6},
      {'rank': 4, 'name': 'Phạm Văn D', 'wins': 1, 'losses': 3, 'points': 3},
      {'rank': 5, 'name': 'Hoàng Văn E', 'wins': 0, 'losses': 4, 'points': 0},
    ];
  }
}

class BracketRound {
  final String name;
  final List<BracketMatch> matches;

  BracketRound({
    required this.name,
    required this.matches,
  });
}

class BracketMatch {
  final String id;
  final String? player1;
  final String? player2;
  final int? score1;
  final int? score2;
  final int? winner; // 1 for player1, 2 for player2, null for no winner yet
  final String status; // 'pending', 'ongoing', 'completed'
  final String? scheduledTime;

  BracketMatch({
    required this.id,
    this.player1,
    this.player2,
    this.score1,
    this.score2,
    this.winner,
    required this.status,
    this.scheduledTime,
  });
}