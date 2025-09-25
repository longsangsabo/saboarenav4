import 'package:flutter/material.dart';
import 'package:sabo_arena/core/app_export.dart';
import 'package:sizer/sizer.dart';
import '../../../services/tournament_service.dart';
import 'match_result_entry_widget.dart';

class MatchManagementView extends StatefulWidget {
  final String tournamentId;
  final String tournamentStatus;
  final bool canManage;

  const MatchManagementView({
    super.key,
    required this.tournamentId,
    required this.tournamentStatus,
    this.canManage = false,
  });

  @override
  _MatchManagementViewState createState() => _MatchManagementViewState();
}

class _MatchManagementViewState extends State<MatchManagementView>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  String _selectedRound = 'all';
  String _selectedStatus = 'all';
  
  List<TournamentMatch> _matches = [];
  List<TournamentMatch> _filteredMatches = [];
  bool _isLoading = true;
  final _tournamentService = TournamentService.instance;

  @override
  void initState() {
    super.initState();
    
    _tabController = TabController(length: 3, vsync: this);
    _animationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _loadMatches();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadMatches() async {
    // Load real matches from database
    await _loadRealMatches();
    
    setState(() {
      _filteredMatches = _matches;
      _isLoading = false;
    });
    
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.sp)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          _buildFilters(),
          _buildTabBar(),
          Expanded(
            child: _isLoading ? _buildLoadingState() : _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.dividerLight)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Quản lý trận đấu",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryLight,
                  ),
                ),
                Text(
                  "${_matches.length} trận đấu",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppTheme.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          
          if (widget.canManage)
            ElevatedButton.icon(
              onPressed: _showCreateMatchDialog,
              icon: Icon(Icons.add, size: 16.sp),
              label: Text("Tạo trận"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryLight,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 8.sp),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 8.sp),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(8.sp),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedRound,
                  items: [
                    DropdownMenuItem(value: 'all', child: Text('Tất cả vòng')),
                    DropdownMenuItem(value: 'round_1', child: Text('Vòng 1')),
                    DropdownMenuItem(value: 'quarter', child: Text('Tứ kết')),
                    DropdownMenuItem(value: 'semi', child: Text('Bán kết')),
                    DropdownMenuItem(value: 'final', child: Text('Chung kết')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedRound = value ?? 'all';
                      _filterMatches();
                    });
                  },
                  style: TextStyle(color: AppTheme.textSecondaryLight, fontSize: 12.sp),
                  padding: EdgeInsets.symmetric(horizontal: 12.sp),
                ),
              ),
            ),
          ),
          
          SizedBox(width: 8.sp),
          
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(8.sp),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedStatus,
                  items: [
                    DropdownMenuItem(value: 'all', child: Text('Tất cả')),
                    DropdownMenuItem(value: 'scheduled', child: Text('Đã lên lịch')),
                    DropdownMenuItem(value: 'ongoing', child: Text('Đang diễn ra')),
                    DropdownMenuItem(value: 'completed', child: Text('Hoàn thành')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value ?? 'all';
                      _filterMatches();
                    });
                  },
                  style: TextStyle(color: AppTheme.textSecondaryLight, fontSize: 12.sp),
                  padding: EdgeInsets.symmetric(horizontal: 12.sp),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.dividerLight)),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppTheme.primaryLight,
        unselectedLabelColor: AppTheme.textSecondaryLight,
        indicatorColor: AppTheme.primaryLight,
        tabs: [
          Tab(text: 'Danh sách'),
          Tab(text: 'Lịch thi đấu'),
          Tab(text: 'Kết quả'),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppTheme.primaryLight),
          SizedBox(height: 16.sp),
          Text(
            "Đang tải trận đấu...",
            style: TextStyle(fontSize: 14.sp, color: AppTheme.textSecondaryLight),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _slideAnimation.value)),
          child: Opacity(
            opacity: _slideAnimation.value,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMatchList(),
                _buildScheduleView(),
                _buildResultsView(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMatchList() {
    if (_filteredMatches.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.sp),
      itemCount: _filteredMatches.length,
      itemBuilder: (context, index) {
        final match = _filteredMatches[index];
        return _buildMatchCard(match);
      },
    );
  }

  Widget _buildMatchCard(TournamentMatch match) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.sp),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.sp),
        border: Border.all(
          color: _getStatusColor(match.status).withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.sp),
        child: Column(
          children: [
            // Match header
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 4.sp),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4.sp),
                  ),
                  child: Text(
                    match.round,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryLight,
                    ),
                  ),
                ),
                
                Spacer(),
                
                _buildStatusChip(match.status),
              ],
            ),
            
            SizedBox(height: 12.sp),
            
            // Players and scores
            Row(
              children: [
                Expanded(child: _buildPlayerInfo(match.player1, match.score1, match.winner == 1)),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.sp),
                  child: Text(
                    "VS",
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textSecondaryLight,
                    ),
                  ),
                ),
                Expanded(child: _buildPlayerInfo(match.player2, match.score2, match.winner == 2)),
              ],
            ),
            
            if (match.scheduledTime != null || match.table != null) ...[
              SizedBox(height: 12.sp),
              Container(
                padding: EdgeInsets.all(8.sp),
                decoration: BoxDecoration(
                  color: Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(6.sp),
                ),
                child: Row(
                  children: [
                    if (match.scheduledTime != null) ...[
                      Icon(Icons.schedule, size: 14.sp, color: AppTheme.textSecondaryLight),
                      SizedBox(width: 4.sp),
                      Text(
                        match.scheduledTime!,
                        style: TextStyle(fontSize: 11.sp, color: AppTheme.textSecondaryLight),
                      ),
                    ],
                    
                    if (match.table != null) ...[
                      if (match.scheduledTime != null) ...[
                        SizedBox(width: 12.sp),
                        Container(width: 1, height: 12.sp, color: AppTheme.dividerLight),
                        SizedBox(width: 12.sp),
                      ],
                      Icon(Icons.table_restaurant, size: 14.sp, color: AppTheme.textSecondaryLight),
                      SizedBox(width: 4.sp),
                      Text(
                        match.table!,
                        style: TextStyle(fontSize: 11.sp, color: AppTheme.textSecondaryLight),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            
            if (widget.canManage) ...[
              SizedBox(height: 12.sp),
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      "Cập nhật KQ",
                      Icons.edit,
                      AppTheme.successLight,
                      () => _updateMatchResult(match),
                    ),
                  ),
                  SizedBox(width: 8.sp),
                  Expanded(
                    child: _buildActionButton(
                      "Chỉnh sửa",
                      Icons.settings,
                      AppTheme.primaryLight,
                      () => _editMatch(match),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerInfo(String playerName, int? score, bool isWinner) {
    return Column(
      children: [
        CircleAvatar(
          radius: 20.sp,
          backgroundImage: NetworkImage(
            'https://images.unsplash.com/photo-${1580000000000 + playerName.hashCode.abs() % 1000}?w=100&h=100&fit=crop&crop=face'
          ),
          backgroundColor: AppTheme.dividerLight,
        ),
        
        SizedBox(height: 6.sp),
        
        Text(
          playerName,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
            color: isWinner ? AppTheme.successLight : AppTheme.textPrimaryLight,
          ),
          textAlign: TextAlign.center,
        ),
        
        if (score != null)
          Container(
            margin: EdgeInsets.only(top: 4.sp),
            padding: EdgeInsets.symmetric(horizontal: 6.sp, vertical: 2.sp),
            decoration: BoxDecoration(
              color: isWinner ? AppTheme.successLight : AppTheme.textDisabledLight,
              borderRadius: BorderRadius.circular(8.sp),
            ),
            child: Text(
              score.toString(),
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    final color = _getStatusColor(status);
    final label = _getStatusLabel(status);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 3.sp),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10.sp),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6.sp),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.sp),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6.sp),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14.sp, color: color),
            SizedBox(width: 4.sp),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleView() {
    // Group matches by date
    final matchesByDate = <String, List<TournamentMatch>>{};
    
    for (final match in _filteredMatches) {
      if (match.scheduledTime != null) {
        final date = "Hôm nay"; // Simplified for demo
        if (!matchesByDate.containsKey(date)) {
          matchesByDate[date] = [];
        }
        matchesByDate[date]!.add(match);
      }
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: matchesByDate.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 12.sp),
                padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 6.sp),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(12.sp),
                ),
                child: Text(
                  entry.key,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              
              ...entry.value.map((match) => Container(
                margin: EdgeInsets.only(bottom: 8.sp),
                padding: EdgeInsets.all(12.sp),
                decoration: BoxDecoration(
                  color: Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8.sp),
                ),
                child: Row(
                  children: [
                    Text(
                      match.scheduledTime ?? "",
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryLight,
                      ),
                    ),
                    SizedBox(width: 12.sp),
                    
                    Expanded(
                      child: Text(
                        "${match.player1} vs ${match.player2}",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppTheme.textPrimaryLight,
                        ),
                      ),
                    ),
                    
                    if (match.table != null)
                      Text(
                        match.table!,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppTheme.textSecondaryLight,
                        ),
                      ),
                  ],
                ),
              )),
              
              SizedBox(height: 16.sp),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildResultsView() {
    final completedMatches = _filteredMatches.where((m) => m.status == 'completed').toList();
    
    if (completedMatches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sports_score, size: 64.sp, color: AppTheme.textDisabledLight),
            SizedBox(height: 16.sp),
            Text("Chưa có kết quả", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.sp),
      itemCount: completedMatches.length,
      itemBuilder: (context, index) {
        final match = completedMatches[index];
        return _buildResultCard(match);
      },
    );
  }

  Widget _buildResultCard(TournamentMatch match) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.sp),
      padding: EdgeInsets.all(12.sp),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.sp),
        border: Border.all(color: AppTheme.successLight.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "${match.player1} ${match.score1} - ${match.score2} ${match.player2}",
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimaryLight,
              ),
            ),
          ),
          
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6.sp, vertical: 2.sp),
            decoration: BoxDecoration(
              color: AppTheme.successLight.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4.sp),
            ),
            child: Text(
              match.round,
              style: TextStyle(
                fontSize: 10.sp,
                color: AppTheme.successLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sports_tennis, size: 64.sp, color: AppTheme.textDisabledLight),
          SizedBox(height: 16.sp),
          Text("Chưa có trận đấu", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
          SizedBox(height: 8.sp),
          Text("Hãy tạo trận đấu đầu tiên", style: TextStyle(color: AppTheme.textSecondaryLight)),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'scheduled': return AppTheme.primaryLight;
      case 'ongoing': return AppTheme.warningLight;
      case 'completed': return AppTheme.successLight;
      default: return AppTheme.textSecondaryLight;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'scheduled': return 'Đã lên lịch';
      case 'ongoing': return 'Đang diễn ra';
      case 'completed': return 'Hoàn thành';
      default: return 'Không rõ';
    }
  }

  void _filterMatches() {
    setState(() {
      _filteredMatches = _matches.where((match) {
        final roundMatch = _selectedRound == 'all' || match.round.toLowerCase().contains(_selectedRound);
        final statusMatch = _selectedStatus == 'all' || match.status == _selectedStatus;
        
        return roundMatch && statusMatch;
      }).toList();
    });
  }

  void _showCreateMatchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Tạo trận đấu mới"),
        content: Text("Tính năng đang được phát triển"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Đóng"),
          ),
        ],
      ),
    );
  }

  void _updateMatchResult(TournamentMatch match) {
    // Check if match has both players
    if (match.player1 == 'TBD' || match.player2 == 'TBD') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ Trận đấu chưa có đủ người chơi'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (match.status == 'completed') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ Trận đấu này đã hoàn thành'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Prepare match data for result entry
    final matchData = {
      'round': match.round,
      'matchNumber': match.id.split('_').last,
      'player1': {
        'id': 'player1_${match.id}', // This should come from actual data
        'name': match.player1,
      },
      'player2': {
        'id': 'player2_${match.id}', // This should come from actual data
        'name': match.player2,
      },
    };

    // Show match result entry dialog
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.sp)),
        child: MatchResultEntryWidget(
          matchId: match.id,
          tournamentId: widget.tournamentId,
          matchData: matchData,
          onResultSubmitted: () {
            // Reload matches after result submitted
            _loadRealMatches();
          },
        ),
      ),
    );
  }

  void _editMatch(TournamentMatch match) {
    // Implementation for editing match
  }

  Future<void> _loadRealMatches() async {
    try {
      final matchesData = await _tournamentService.getTournamentMatches(widget.tournamentId);
      
      // Convert database format to TournamentMatch objects
      final matches = matchesData.map((match) => TournamentMatch(
        id: match['id']?.toString() ?? 'unknown',
        player1: match['player1_name']?.toString() ?? 'TBD',
        player2: match['player2_name']?.toString() ?? 'TBD',
        score1: match['player1_score'] as int?,
        score2: match['player2_score'] as int?,
        winner: match['winner_id'] != null ? (match['winner_id'] == match['player1_id'] ? 1 : 2) : null,
        status: match['status']?.toString() ?? 'pending',
        round: match['round']?.toString() ?? 'Round 1',
        scheduledTime: match['scheduled_time']?.toString(),
        table: match['table_name']?.toString(),
      )).toList();
      
      setState(() {
        _matches = matches;
      });
    } catch (e) {
      print('Error loading matches: $e');
      // Show empty list if error
      setState(() {
        _matches = [];
      });
    }
  }
  
  List<TournamentMatch> _generateMockMatches() {
    return [
      TournamentMatch(
        id: 'match_1',
        player1: 'Nguyễn Văn A',
        player2: 'Lê Văn B',
        score1: 3,
        score2: 1,
        winner: 1,
        status: 'completed',
        round: 'Vòng 1',
        scheduledTime: '09:00',
        table: 'Bàn 1',
      ),
      TournamentMatch(
        id: 'match_2',
        player1: 'Trần Văn C',
        player2: 'Phạm Văn D',
        score1: null,
        score2: null,
        winner: null,
        status: 'ongoing',
        round: 'Vòng 1',
        scheduledTime: '09:30',
        table: 'Bàn 2',
      ),
      TournamentMatch(
        id: 'match_3',
        player1: 'Hoàng Văn E',
        player2: 'Vũ Văn F',
        score1: null,
        score2: null,
        winner: null,
        status: 'scheduled',
        round: 'Vòng 1',
        scheduledTime: '10:00',
        table: 'Bàn 1',
      ),
      TournamentMatch(
        id: 'match_4',
        player1: 'Đinh Văn G',
        player2: 'Bùi Văn H',
        score1: 2,
        score2: 3,
        winner: 2,
        status: 'completed',
        round: 'Vòng 1',
        scheduledTime: '10:30',
        table: 'Bàn 2',
      ),
    ];
  }
}

class TournamentMatch {
  final String id;
  final String player1;
  final String player2;
  final int? score1;
  final int? score2;
  final int? winner; // 1 for player1, 2 for player2
  final String status; // scheduled, ongoing, completed
  final String round;
  final String? scheduledTime;
  final String? table;

  TournamentMatch({
    required this.id,
    required this.player1,
    required this.player2,
    this.score1,
    this.score2,
    this.winner,
    required this.status,
    required this.round,
    this.scheduledTime,
    this.table,
  });
}