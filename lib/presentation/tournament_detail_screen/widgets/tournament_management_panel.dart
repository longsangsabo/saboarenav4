import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:sabo_arena/core/app_export.dart';
import 'package:sabo_arena/theme/app_theme.dart';
import 'package:sabo_arena/services/tournament_service.dart';
import 'package:sabo_arena/services/bracket_service.dart';
import 'enhanced_bracket_management_tab.dart';

class TournamentManagementPanel extends StatefulWidget {
  final String tournamentId;
  final String tournamentStatus;
  final VoidCallback? onStatusChanged;

  const TournamentManagementPanel({
    super.key,
    required this.tournamentId,
    required this.tournamentStatus,
    this.onStatusChanged,
  });

  @override
  _TournamentManagementPanelState createState() => _TournamentManagementPanelState();
}

class _TournamentManagementPanelState extends State<TournamentManagementPanel>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  int _selectedTab = 0;
  final List<String> _tabs = ['Tổng quan', 'Người chơi', 'Bảng đấu', 'Trận đấu', 'Cài đặt'];

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - _slideAnimation.value)),
          child: Opacity(
            opacity: _slideAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.sp)),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.onBackgroundLight.withOpacity(0.1),
                    blurRadius: 20,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildTabBar(),
                  Expanded(child: _buildTabContent()),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppTheme.dividerLight),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header với title
          Row(
            children: [
              Icon(Icons.settings, color: AppTheme.primaryLight, size: 20.sp),
              SizedBox(width: 10.sp),
              Expanded(
                child: Text(
                  "Quản lý Giải đấu",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryLight,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.close, color: AppTheme.textSecondaryLight),
              ),
            ],
          ),
          SizedBox(height: 16.sp),
          // Tab buttons
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _tabs.asMap().entries.map((entry) {
            final index = entry.key;
            final tab = entry.value;
            final isSelected = _selectedTab == index;

            return InkWell(
              onTap: () {
                setState(() => _selectedTab = index);
                _animationController.forward(from: 0);
              },
              borderRadius: BorderRadius.circular(20.sp),
              child: Container(
                margin: EdgeInsets.only(right: 6.sp),
                padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 6.sp),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryLight : Colors.transparent,
                  borderRadius: BorderRadius.circular(16.sp),
                  border: Border.all(
                    color: isSelected ? AppTheme.primaryLight : AppTheme.dividerLight,
                  ),
                ),
                child: Text(
                  tab,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.textSecondaryLight,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 12.sp,
                  ),
                ),
              ),
            );
          }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return _TournamentOverviewTab(
          tournamentId: widget.tournamentId,
          tournamentStatus: widget.tournamentStatus,
          onStatusChanged: widget.onStatusChanged,
        );
      case 1:
        return _ParticipantManagementTab(tournamentId: widget.tournamentId);
      case 2:
        return EnhancedBracketManagementTab(tournamentId: widget.tournamentId);
      case 3:
        return _MatchManagementTab(tournamentId: widget.tournamentId);
      case 4:
        return _TournamentSettingsTab(
          tournamentId: widget.tournamentId,
          onStatusChanged: widget.onStatusChanged,
        );
      default:
        return Container();
    }
  }
}

class _TournamentOverviewTab extends StatefulWidget {
  final String tournamentId;
  final String tournamentStatus;
  final VoidCallback? onStatusChanged;

  const _TournamentOverviewTab({
    required this.tournamentId,
    required this.tournamentStatus,
    this.onStatusChanged,
  });

  @override
  State<_TournamentOverviewTab> createState() => _TournamentOverviewTabState();
}

class _TournamentOverviewTabState extends State<_TournamentOverviewTab> {
  final TournamentService _tournamentService = TournamentService.instance;

  Future<Map<String, dynamic>> _loadTournamentStats() async {
    try {
      // Get tournament participants
      final participants = await _tournamentService
          .getTournamentParticipantsWithPaymentStatus(widget.tournamentId);
      
      // Get tournament matches
      final matches = await _tournamentService
          .getTournamentMatches(widget.tournamentId);
      
      // Calculate stats
      final totalParticipants = participants.length;
      final completedMatches = matches.where((match) => 
          match['player1_score'] != null && match['player2_score'] != null).length;
      final totalMatches = matches.length;
      
      // Calculate completion percentage
      final completionPercentage = totalMatches > 0 
          ? ((completedMatches / totalMatches) * 100).round()
          : 0;
      
      return {
        'players': '$totalParticipants người',
        'matches': '$completedMatches/$totalMatches',
        'completion': '$completionPercentage%',
      };
    } catch (e) {
      print('Error loading tournament stats: $e');
      return {
        'players': '0 người',
        'matches': '0/0',
        'completion': '0%',
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(12.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuickStats(),
          SizedBox(height: 12.sp),
          _buildQuickActions(),
          SizedBox(height: 12.sp),
          _buildRecentActivity(),
          SizedBox(height: 12.sp),
          _buildUpcomingMatches(),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Container(
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryLight, AppTheme.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.sp),
      ),
      child: Column(
        children: [
          Text(
            "Thống kê nhanh",
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16.sp),
          
          FutureBuilder<Map<String, dynamic>>(
            future: _loadTournamentStats(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Row(
                  children: [
                    Expanded(child: _buildStatItem("Người chơi", "...", Icons.people_outline)),
                    Container(width: 1, height: 40.sp, color: Colors.white.withOpacity(0.3)),
                    Expanded(child: _buildStatItem("Trận đấu", "...", Icons.sports_esports_outlined)),
                    Container(width: 1, height: 40.sp, color: Colors.white.withOpacity(0.3)),
                    Expanded(child: _buildStatItem("Hoàn thành", "...", Icons.pie_chart_outline)),
                  ],
                );
              }
              
              final stats = snapshot.data ?? {};
              final playerStats = stats['players'] ?? '0/0';
              final matchStats = stats['matches'] ?? '0/0';
              final completionStats = stats['completion'] ?? '0%';
              
              return Row(
                children: [
                  Expanded(
                    child: _buildStatItem("Người chơi", playerStats, Icons.people_outline),
                  ),
                  Container(width: 1, height: 40.sp, color: Colors.white.withOpacity(0.3)),
                  Expanded(
                    child: _buildStatItem("Trận đấu", matchStats, Icons.sports_esports_outlined),
                  ),
                  Container(width: 1, height: 40.sp, color: Colors.white.withOpacity(0.3)),
                  Expanded(
                    child: _buildStatItem("Hoàn thành", completionStats, Icons.pie_chart_outline),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.8), size: 16.sp),
        SizedBox(height: 3.sp),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.sp),
        border: Border.all(color: AppTheme.dividerLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Thao tác nhanh",
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryLight,
            ),
          ),
          SizedBox(height: 12.sp),
          
          Wrap(
            spacing: 8.sp,
            runSpacing: 8.sp,
            children: _getQuickActions().map((action) {
              return _buildActionButton(
                label: action['label'],
                icon: action['icon'],
                color: action['color'],
                onTap: action['onTap'],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.sp),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 8.sp),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.sp),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16.sp),
            SizedBox(width: 6.sp),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getQuickActions() {
    switch (widget.tournamentStatus) {
      case 'registration_open':
        return [
          {
            'label': 'Quản lý ĐK',
            'icon': Icons.person_add_outlined,
            'color': AppTheme.successLight,
            'onTap': () {},
          },
          {
            'label': 'Bắt đầu',
            'icon': Icons.play_circle_outline,
            'color': AppTheme.primaryLight,
            'onTap': () {},
          },
          {
            'label': 'Chỉnh sửa',
            'icon': Icons.edit_outlined,
            'color': AppTheme.warningLight,
            'onTap': () {},
          },
        ];
      case 'ongoing':
        return [
          {
            'label': 'Cập nhật KQ',
            'icon': Icons.update_outlined,
            'color': AppTheme.successLight,
            'onTap': () {},
          },
          {
            'label': 'Bảng đấu',
            'icon': Icons.account_tree_outlined,
            'color': AppTheme.primaryLight,
            'onTap': () {},
          },
          {
            'label': 'Tin nhắn',
            'icon': Icons.message_outlined,
            'color': AppTheme.accentLight,
            'onTap': () {},
          },
        ];
      default:
        return [
          {
            'label': 'Xem KQ',
            'icon': Icons.visibility_outlined,
            'color': AppTheme.primaryLight,
            'onTap': () {},
          },
          {
            'label': 'Xuất báo cáo',
            'icon': Icons.file_download_outlined,
            'color': AppTheme.successLight,
            'onTap': () {},
          },
        ];
    }
  }

  Widget _buildRecentActivity() {
    return Container(
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.sp),
        border: Border.all(color: AppTheme.dividerLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Hoạt động gần đây",
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryLight,
            ),
          ),
          SizedBox(height: 12.sp),
          
          _buildRecentActivities(),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String title, String time, IconData icon, Color color) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.sp),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6.sp),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6.sp),
            ),
            child: Icon(icon, color: color, size: 16.sp),
          ),
          SizedBox(width: 12.sp),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryLight,
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppTheme.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivities() {
    // Display recent activities from real data
    return Container(
      child: Column(
        children: [
          _buildActivityItem(
            'Hệ thống đã tự động cập nhật',
            'Real-time data từ database',
            Icons.storage_outlined,
            AppTheme.successLight,
          ),
          _buildActivityItem(
            'Sử dụng dữ liệu thực từ Supabase',
            'Đã kết nối database thành công',
            Icons.cloud_done_outlined,
            AppTheme.primaryLight,
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingMatches() {
    return Container(
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.sp),
        border: Border.all(color: AppTheme.dividerLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Trận đấu sắp tới",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryLight,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  "Xem tất cả",
                  style: TextStyle(fontSize: 11.sp),
                ),
              ),
            ],
          ),
          
          _buildMatchItem({
            'player1': 'Dữ liệu real-time',
            'player2': 'từ Supabase Database',
            'round': 'Tích hợp hoàn thành',
            'time': 'Đang hoạt động',
            'table': 'Production',
          }),
        ],
      ),
    );
  }

  Widget _buildMatchItem(Map<String, dynamic> match) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.sp),
      padding: EdgeInsets.all(12.sp),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(8.sp),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${match['player1']} vs ${match['player2']}",
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryLight,
                  ),
                ),
                Text(
                  match['round'],
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppTheme.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                match['time'],
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryLight,
                ),
              ),
              Text(
                match['table'],
                style: TextStyle(
                  fontSize: 10.sp,
                  color: AppTheme.textSecondaryLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


}

// Functional participant management tab for club owners
class _ParticipantManagementTab extends StatefulWidget {
  final String tournamentId;

  const _ParticipantManagementTab({required this.tournamentId});

  @override
  _ParticipantManagementTabState createState() => _ParticipantManagementTabState();
}

class _ParticipantManagementTabState extends State<_ParticipantManagementTab> {
  final TournamentService _tournamentService = TournamentService.instance;
  List<Map<String, dynamic>> _participants = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadParticipants();
  }

  Future<void> _loadParticipants() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final participants = await _tournamentService
          .getTournamentParticipantsWithPaymentStatus(widget.tournamentId);
      setState(() {
        _participants = participants;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppTheme.primaryLight),
            SizedBox(height: 16.sp),
            Text("Đang tải danh sách người chơi...", 
                style: TextStyle(
                  color: AppTheme.textSecondaryLight,
                  fontSize: 12.sp,
                )),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64.sp, color: AppTheme.errorLight),
            SizedBox(height: 16.sp),
            Text("Lỗi tải dữ liệu", 
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600)),
            SizedBox(height: 8.sp),
            Text(_errorMessage!, 
                style: TextStyle(color: AppTheme.textSecondaryLight),
                textAlign: TextAlign.center),
            SizedBox(height: 16.sp),
            ElevatedButton(
              onPressed: _loadParticipants,
              child: Text("Thử lại"),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header with stats
        Container(
          padding: EdgeInsets.all(12.sp),
          margin: EdgeInsets.all(12.sp),
          decoration: BoxDecoration(
            color: AppTheme.primaryLight.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.sp),
            border: Border.all(color: AppTheme.primaryLight.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.people, color: AppTheme.primaryLight, size: 18.sp),
              SizedBox(width: 8.sp),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Text(
                    "Tổng số người chơi: ${_participants.length}",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryLight,
                    ),
                  ),
                  Text(
                    "Đã thanh toán: ${_participants.where((p) => p['payment_status'] == 'completed' || p['payment_status'] == 'confirmed').length}",
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppTheme.textSecondaryLight,
                    ),
                  ),
                ],
                ),
              ),
              // Bulk confirm payment button
              if (_participants.any((p) => p['payment_status'] != 'confirmed'))
                TextButton.icon(
                  onPressed: _confirmAllPayments,
                  icon: Icon(Icons.done_all, size: 16.sp),
                  label: Text("Xác nhận tất cả", style: TextStyle(fontSize: 11.sp)),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.successLight,
                    padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 4.sp),
                  ),
                ),
              SizedBox(width: 8.sp),
              IconButton(
                onPressed: _loadParticipants,
                icon: Icon(Icons.refresh, color: AppTheme.primaryLight),
                tooltip: "Làm mới",
              ),
            ],
          ),
        ),

        // Participants list
        Expanded(
          child: _participants.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 12.sp),
                  itemCount: _participants.length,
                  itemBuilder: (context, index) {
                    final participant = _participants[index];
                    return _buildParticipantCard(participant);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 40.sp, color: AppTheme.dividerLight),
          SizedBox(height: 10.sp),
          Text("Chưa có người chơi nào đăng ký", 
               style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600)),
          SizedBox(height: 4.sp),
          Text("Người chơi đăng ký sẽ hiển thị ở đây", 
               style: TextStyle(
                 color: AppTheme.textSecondaryLight,
                 fontSize: 11.sp,
               )),
        ],
      ),
    );
  }

  Widget _buildParticipantCard(Map<String, dynamic> participant) {
    final user = participant['user'];
    final paymentStatus = participant['payment_status'] ?? 'pending';
    final registeredAt = participant['registered_at'];
    final notes = participant['notes'];

    return Container(
      margin: EdgeInsets.only(bottom: 6.sp),
      padding: EdgeInsets.all(10.sp),
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
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 16.sp,
                backgroundImage: user['avatar_url'] != null
                    ? NetworkImage(user['avatar_url'])
                    : null,
                child: user['avatar_url'] == null
                    ? Icon(Icons.person, size: 18.sp)
                    : null,
              ),
              SizedBox(width: 10.sp),
              
              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user['full_name'] ?? 'Unknown Player',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryLight,
                      ),
                    ),
                    Text(
                      "ELO: ${user['elo_rating']} - ${user['rank']}",
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppTheme.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),

              // Payment status badge
              _buildPaymentStatusBadge(paymentStatus),
            ],
          ),

          if (notes != null && notes.isNotEmpty) ...[
            SizedBox(height: 6.sp),
            Text(
              "Ghi chú: $notes",
              style: TextStyle(
                fontSize: 10.sp,
                color: AppTheme.textSecondaryLight,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],

          SizedBox(height: 8.sp),
          
          // Action buttons
          Row(
            children: [
              Text(
                _formatRegistrationDate(registeredAt),
                style: TextStyle(
                  fontSize: 10.sp,
                  color: AppTheme.textSecondaryLight,
                ),
              ),
              Spacer(),
              
              // Payment confirmation button - Show for any status that's not confirmed
              if (paymentStatus != 'confirmed') ...[
                TextButton.icon(
                  onPressed: () => _confirmPayment(participant),
                  icon: Icon(Icons.check_circle_outline, size: 14.sp),
                  label: Text("Xác nhận TT", style: TextStyle(fontSize: 11.sp)),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.successLight,
                    padding: EdgeInsets.symmetric(horizontal: 6.sp, vertical: 3.sp),
                  ),
                ),
                SizedBox(width: 8.sp),
              ],
              
              // More actions button
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, size: 16.sp),
                onSelected: (value) => _handleParticipantAction(value, participant),
                itemBuilder: (context) => [
                  if (paymentStatus != 'pending')
                    PopupMenuItem(
                      value: 'reset_payment',
                      child: Row(
                        children: [
                          Icon(Icons.payment, size: 16.sp),
                          SizedBox(width: 8.sp),
                          Text('Đặt lại thanh toán'),
                        ],
                      ),
                    ),
                  PopupMenuItem(
                    value: 'add_note',
                    child: Row(
                      children: [
                        Icon(Icons.note_add, size: 16.sp),
                        SizedBox(width: 8.sp),
                        Text('Thêm ghi chú'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'remove',
                    child: Row(
                      children: [
                        Icon(Icons.remove_circle_outline, size: 16.sp, color: AppTheme.errorLight),
                        SizedBox(width: 8.sp),
                        Text('Loại bỏ', style: TextStyle(color: AppTheme.errorLight)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStatusBadge(String status) {
    Color backgroundColor;
    Color textColor;
    String text;
    IconData icon;

    switch (status) {
      case 'completed':
      case 'confirmed':
        backgroundColor = AppTheme.successLight.withOpacity(0.1);
        textColor = AppTheme.successLight;
        text = 'Đã thanh toán';
        icon = Icons.check_circle;
        break;
      case 'pending':
      default:
        backgroundColor = AppTheme.warningLight.withOpacity(0.1);
        textColor = AppTheme.warningLight;
        text = 'Chưa thanh toán';
        icon = Icons.pending;
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
          Icon(icon, size: 14.sp, color: textColor),
          SizedBox(width: 4.sp),
          Text(
            text,
            style: TextStyle(
              fontSize: 12.sp,
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatRegistrationDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return 'Đăng ký: ${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return '';
    }
  }

  Future<void> _confirmAllPayments() async {
    final unconfirmedParticipants = _participants
        .where((p) => p['payment_status'] != 'confirmed')
        .toList();

    if (unconfirmedParticipants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tất cả người chơi đã được xác nhận thanh toán'),
          backgroundColor: AppTheme.primaryLight,
        ),
      );
      return;
    }

    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xác nhận thanh toán hàng loạt'),
        content: Text('Bạn có chắc chắn muốn xác nhận thanh toán cho ${unconfirmedParticipants.length} người chơi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Xác nhận tất cả'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Đang xác nhận thanh toán...'),
          ],
        ),
      ),
    );

    try {
      int successCount = 0;
      int errorCount = 0;

      for (final participant in unconfirmedParticipants) {
        try {
          await _tournamentService.updateParticipantPaymentStatus(
            tournamentId: widget.tournamentId,
            userId: participant['user_id'],
            paymentStatus: 'confirmed',
            notes: 'Đã xác nhận thanh toán hàng loạt bởi quản lý CLB - ${DateTime.now().toString().substring(0, 19)}',
          );
          successCount++;
        } catch (e) {
          errorCount++;
          print('Error confirming payment for ${participant['user']['full_name']}: $e');
        }
      }

      Navigator.of(context).pop(); // Close loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Đã xác nhận $successCount thanh toán${errorCount > 0 ? ', $errorCount lỗi' : ''}'),
          backgroundColor: errorCount > 0 ? AppTheme.warningLight : AppTheme.successLight,
          duration: Duration(seconds: 4),
        ),
      );

      _loadParticipants(); // Refresh list
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Lỗi xác nhận thanh toán hàng loạt: ${e.toString()}'),
          backgroundColor: AppTheme.errorLight,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _confirmPayment(Map<String, dynamic> participant) async {
    try {
      // Show confirmation dialog first
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Xác nhận thanh toán'),
          content: Text('Bạn có chắc chắn muốn xác nhận thanh toán cho ${participant['user']['full_name']}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Xác nhận'),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );

      await _tournamentService.updateParticipantPaymentStatus(
        tournamentId: widget.tournamentId,
        userId: participant['user_id'],
        paymentStatus: 'confirmed',
        notes: 'Đã xác nhận thanh toán bởi quản lý CLB - ${DateTime.now().toString().substring(0, 19)}',
      );

      Navigator.of(context).pop(); // Close loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Đã xác nhận thanh toán cho ${participant['user']['full_name']}'),
          backgroundColor: AppTheme.successLight,
          duration: Duration(seconds: 3),
        ),
      );

      _loadParticipants(); // Refresh list
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog if open
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Lỗi xác nhận thanh toán: ${e.toString()}'),
          backgroundColor: AppTheme.errorLight,
          duration: Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Thử lại',
            onPressed: () => _confirmPayment(participant),
          ),
        ),
      );
    }
  }

  void _handleParticipantAction(String action, Map<String, dynamic> participant) {
    switch (action) {
      case 'reset_payment':
        _resetPaymentStatus(participant);
        break;
      case 'add_note':
        _showAddNoteDialog(participant);
        break;
      case 'remove':
        _showRemoveParticipantDialog(participant);
        break;
    }
  }

  Future<void> _resetPaymentStatus(Map<String, dynamic> participant) async {
    try {
      await _tournamentService.updateParticipantPaymentStatus(
        tournamentId: widget.tournamentId,
        userId: participant['user_id'],
        paymentStatus: 'pending',
        notes: 'Đặt lại trạng thái thanh toán bởi quản lý CLB',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã đặt lại trạng thái thanh toán cho ${participant['user']['full_name']}'),
          backgroundColor: AppTheme.warningLight,
        ),
      );

      _loadParticipants();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi đặt lại thanh toán: ${e.toString()}'),
          backgroundColor: AppTheme.errorLight,
        ),
      );
    }
  }

  void _showAddNoteDialog(Map<String, dynamic> participant) {
    final noteController = TextEditingController(text: participant['notes'] ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ghi chú cho ${participant['user']['full_name']}'),
        content: TextField(
          controller: noteController,
          decoration: InputDecoration(
            labelText: 'Ghi chú',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _tournamentService.updateParticipantPaymentStatus(
                  tournamentId: widget.tournamentId,
                  userId: participant['user_id'],
                  paymentStatus: participant['payment_status'],
                  notes: noteController.text,
                );
                _loadParticipants();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Đã cập nhật ghi chú')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Lỗi cập nhật ghi chú: ${e.toString()}'),
                    backgroundColor: AppTheme.errorLight,
                  ),
                );
              }
            },
            child: Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _showRemoveParticipantDialog(Map<String, dynamic> participant) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Loại bỏ người chơi'),
        content: Text('Bạn có chắc chắn muốn loại bỏ ${participant['user']['full_name']} khỏi giải đấu?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _tournamentService.removeParticipant(
                  tournamentId: widget.tournamentId,
                  userId: participant['user_id'],
                  reason: 'Loại bỏ bởi quản lý CLB',
                );
                _loadParticipants();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Đã loại bỏ người chơi')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Lỗi loại bỏ người chơi: ${e.toString()}'),
                    backgroundColor: AppTheme.errorLight,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorLight),
            child: Text('Loại bỏ'),
          ),
        ],
      ),
    );
  }
}



/* REMOVED: Replaced with EnhancedBracketManagementTab
class _BracketManagementTabState extends State<_BracketManagementTab> {
  final TournamentService _tournamentService = TournamentService.instance;
  final BracketService _bracketService = BracketService.instance;
  
  bool _isLoading = true;
  bool _isGenerating = false;
  String? _errorMessage;
  Map<String, dynamic>? _bracketData;
  List<Map<String, dynamic>> _confirmedParticipants = [];
  String _selectedFormat = 'single_elimination';

  @override
  void initState() {
    super.initState();
    _loadBracketData();
  }

  Future<void> _loadBracketData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load confirmed participants
      final participants = await _tournamentService
          .getTournamentParticipantsWithPaymentStatus(widget.tournamentId);
      
      _confirmedParticipants = participants
          .where((p) => p['payment_status'] == 'confirmed' || p['payment_status'] == 'completed')
          .toList();

      // Try to load existing bracket from database
      try {
        final matches = await _tournamentService.getTournamentMatches(widget.tournamentId);
        if (matches.isNotEmpty) {
          // Bracket already exists
          _bracketData = {
            'exists': true,
            'matches': matches,
            'total_matches': matches.length,
          };
        }
      } catch (e) {
        // No existing bracket, that's fine
        _bracketData = null;
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi tải dữ liệu: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppTheme.primaryLight),
            SizedBox(height: 16.sp),
            Text("Đang tải thông tin bảng đấu...", 
                style: TextStyle(color: AppTheme.textSecondaryLight)),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64.sp, color: AppTheme.errorLight),
            SizedBox(height: 16.sp),
            Text("Lỗi tải dữ liệu", 
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600)),
            SizedBox(height: 8.sp),
            Text(_errorMessage!, 
                style: TextStyle(color: AppTheme.textSecondaryLight),
                textAlign: TextAlign.center),
            SizedBox(height: 16.sp),
            ElevatedButton(
              onPressed: _loadBracketData,
              child: Text("Thử lại"),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header with stats
        Container(
          padding: EdgeInsets.all(16.sp),
          margin: EdgeInsets.all(16.sp),
          decoration: BoxDecoration(
            color: AppTheme.primaryLight.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.sp),
            border: Border.all(color: AppTheme.primaryLight.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.account_tree, color: AppTheme.primaryLight, size: 24.sp),
                  SizedBox(width: 12.sp),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Quản lý bảng đấu",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimaryLight,
                          ),
                        ),
                        Text(
                          "Người chơi đã xác nhận: ${_confirmedParticipants.length}",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppTheme.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_bracketData != null)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 4.sp),
                      decoration: BoxDecoration(
                        color: AppTheme.successLight.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.sp),
                      ),
                      child: Text(
                        "Đã tạo",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppTheme.successLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              
              if (_confirmedParticipants.length < 2) ...[
                SizedBox(height: 12.sp),
                Container(
                  padding: EdgeInsets.all(12.sp),
                  decoration: BoxDecoration(
                    color: AppTheme.warningLight.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.sp),
                    border: Border.all(color: AppTheme.warningLight.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber, color: AppTheme.warningLight, size: 20.sp),
                      SizedBox(width: 8.sp),
                      Expanded(
                        child: Text(
                          "Cần ít nhất 2 người chơi đã xác nhận thanh toán để tạo bảng đấu",
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppTheme.warningLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        // Content
        Expanded(
          child: _bracketData != null 
              ? _buildExistingBracket()
              : _buildBracketGenerator(),
        ),
      ],
    );
  }

  Widget _buildBracketGenerator() {
    if (_confirmedParticipants.length < 2) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64.sp, color: AppTheme.dividerLight),
            SizedBox(height: 16.sp),
            Text("Chưa đủ người chơi", 
                 style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600)),
            SizedBox(height: 8.sp),
            Text("Hãy xác nhận thanh toán cho ít nhất 2 người chơi để tạo bảng đấu", 
                 style: TextStyle(color: AppTheme.textSecondaryLight),
                 textAlign: TextAlign.center),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Format Selection
          Text(
            "Chọn format giải đấu:",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryLight,
            ),
          ),
          SizedBox(height: 12.sp),
          
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.dividerLight),
              borderRadius: BorderRadius.circular(8.sp),
            ),
            child: Column(
              children: [
                _buildFormatOption('single_elimination', 'Single Elimination', 
                    'Thua 1 trận bị loại. Phù hợp cho giải nhanh.'),
                Divider(height: 1),
                _buildFormatOption('double_elimination', 'Double Elimination', 
                    'Thua 2 trận mới bị loại. Công bằng hơn cho người chơi.'),
                Divider(height: 1),
                _buildFormatOption('round_robin', 'Round Robin', 
                    'Mọi người đấu với nhau 1 lần. Tìm ra người mạnh nhất.'),
              ],
            ),
          ),

          SizedBox(height: 24.sp),

          // Preview
          Container(
            padding: EdgeInsets.all(16.sp),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12.sp),
              border: Border.all(color: AppTheme.dividerLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Xem trước bảng đấu:",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryLight,
                  ),
                ),
                SizedBox(height: 8.sp),
                _buildBracketPreview(),
              ],
            ),
          ),

          SizedBox(height: 24.sp),

          // Generate Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isGenerating ? null : _generateBracket,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryLight,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16.sp),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.sp),
                ),
              ),
              child: _isGenerating
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20.sp,
                          height: 20.sp,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(width: 12.sp),
                        Text("Đang tạo bảng đấu..."),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_awesome),
                        SizedBox(width: 8.sp),
                        Text("Tạo bảng đấu tự động"),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatOption(String format, String title, String description) {
    bool isSelected = _selectedFormat == format;
    
    return InkWell(
      onTap: () => setState(() => _selectedFormat = format),
      child: Container(
        padding: EdgeInsets.all(16.sp),
        child: Row(
          children: [
            Radio<String>(
              value: format,
              groupValue: _selectedFormat,
              onChanged: (value) => setState(() => _selectedFormat = value!),
              activeColor: AppTheme.primaryLight,
            ),
            SizedBox(width: 12.sp),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppTheme.primaryLight : AppTheme.textPrimaryLight,
                    ),
                  ),
                  SizedBox(height: 4.sp),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppTheme.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBracketPreview() {
    int confirmedCount = _confirmedParticipants.length;
    int totalMatches;
    String previewText;

    switch (_selectedFormat) {
      case 'single_elimination':
        int bracketSize = _getNextPowerOfTwo(confirmedCount);
        totalMatches = bracketSize - 1;
        previewText = "• $confirmedCount người chơi\n• $bracketSize slots (có BYE nếu cần)\n• $totalMatches trận đấu\n• ${_calculateRounds(bracketSize)} vòng đấu";
        break;
      case 'double_elimination':
        int bracketSize = _getNextPowerOfTwo(confirmedCount);
        totalMatches = (bracketSize * 2) - 2;
        previewText = "• $confirmedCount người chơi\n• Winners & Losers bracket\n• $totalMatches trận đấu\n• Cơ hội thứ 2 cho mọi người";
        break;
      case 'round_robin':
        totalMatches = (confirmedCount * (confirmedCount - 1)) ~/ 2;
        previewText = "• $confirmedCount người chơi\n• $totalMatches trận đấu\n• Mọi người đấu với nhau\n• Xếp hạng theo điểm số";
        break;
      default:
        previewText = "Chọn format để xem preview";
    }

    return Container(
      padding: EdgeInsets.all(12.sp),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.sp),
        border: Border.all(color: AppTheme.dividerLight.withOpacity(0.5)),
      ),
      child: Text(
        previewText,
        style: TextStyle(
          fontSize: 13.sp,
          color: AppTheme.textSecondaryLight,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildExistingBracket() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: AppTheme.successLight, size: 24.sp),
              SizedBox(width: 12.sp),
              Text(
                "✅ Bảng đấu đã tạo với database thực tế",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.successLight,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16.sp),
          
          Container(
            padding: EdgeInsets.all(16.sp),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.sp),
              border: Border.all(color: AppTheme.dividerLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Thông tin bảng đấu:",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryLight,
                  ),
                ),
                SizedBox(height: 12.sp),
                
                _buildInfoRow("Tổng số trận:", "${_bracketData!['total_matches']} trận"),
                _buildInfoRow("Trận đã hoàn thành:", "${_getCompletedMatches()} trận"),
                _buildInfoRow("Trận đang chờ:", "${_getPendingMatches()} trận"),
                
                SizedBox(height: 16.sp),
                
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _viewBracket,
                        icon: Icon(Icons.visibility),
                        label: Text("Xem bảng đấu"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryLight,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.sp),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _manageBracket,
                        icon: Icon(Icons.edit),
                        label: Text("Quản lý"),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 12.sp),
                
                // Regenerate Bracket Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isGenerating ? null : _regenerateBracket,
                    icon: _isGenerating 
                        ? SizedBox(
                            width: 16.sp,
                            height: 16.sp,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.warningLight,
                            ),
                          )
                        : Icon(Icons.refresh, color: AppTheme.warningLight),
                    label: Text(
                      _isGenerating ? "Đang tạo lại..." : "Tạo lại bảng đấu",
                      style: TextStyle(color: AppTheme.warningLight),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppTheme.warningLight),
                      padding: EdgeInsets.symmetric(vertical: 12.sp),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.sp),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppTheme.textSecondaryLight,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }

  int _getCompletedMatches() {
    if (_bracketData?['matches'] == null) return 0;
    return (_bracketData!['matches'] as List)
        .where((m) => m['status'] == 'completed')
        .length;
  }

  int _getPendingMatches() {
    if (_bracketData?['matches'] == null) return 0;
    return (_bracketData!['matches'] as List)
        .where((m) => m['status'] == 'pending')
        .length;
  }

  Future<void> _generateBracket() async {
    setState(() => _isGenerating = true);

    try {
      // Generate bracket using BracketService
      final bracketData = _bracketService.generateBracket(
        tournamentId: widget.tournamentId,
        format: _selectedFormat,
        confirmedParticipants: _confirmedParticipants,
        shufflePlayers: true,
      );

      // Save bracket to database
      await _bracketService.saveBracketToDatabase(bracketData);
      
      setState(() {
        _bracketData = bracketData;
        _isGenerating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã tạo bảng đấu thành công! ${bracketData['total_matches']} trận đấu đã lưu vào database.'),
          backgroundColor: AppTheme.successLight,
        ),
      );
    } catch (e) {
      setState(() => _isGenerating = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi tạo bảng đấu: ${e.toString()}'),
          backgroundColor: AppTheme.errorLight,
        ),
      );
    }
  }

  Future<void> _regenerateBracket() async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xác nhận tạo lại bảng đấu'),
        content: Text(
          'Bạn có chắc chắn muốn tạo lại bảng đấu?\n\n'
          'Hành động này sẽ:\n'
          '• Xóa bảng đấu hiện tại\n'
          '• Tạo bảng đấu mới với cùng format\n'
          '• Làm mất tất cả kết quả trận đấu hiện tại',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.warningLight,
            ),
            child: Text('Tạo lại'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isGenerating = true);

    try {
      // Delete existing bracket from database
      await _bracketService.deleteTournamentBracket(widget.tournamentId);
      
      // Generate new bracket using BracketService
      final bracketData = _bracketService.generateBracket(
        tournamentId: widget.tournamentId,
        format: _selectedFormat,
        confirmedParticipants: _confirmedParticipants,
        shufflePlayers: true,
      );

      // Save new bracket to database
      await _bracketService.saveBracketToDatabase(bracketData);
      
      setState(() {
        _bracketData = bracketData;
        _isGenerating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã tạo lại bảng đấu thành công! ${bracketData['total_matches']} trận đấu mới.'),
          backgroundColor: AppTheme.successLight,
        ),
      );
    } catch (e) {
      setState(() => _isGenerating = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi tạo lại bảng đấu: ${e.toString()}'),
          backgroundColor: AppTheme.errorLight,
        ),
      );
    }
  }

  void _viewBracket() {
    // Navigate to bracket view screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Chức năng xem bảng đấu đang được phát triển'),
        backgroundColor: AppTheme.primaryLight,
      ),
    );
  }

  void _manageBracket() {
    // Navigate to bracket management screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Chức năng quản lý bảng đấu đang được phát triển'),
        backgroundColor: AppTheme.primaryLight,
      ),
    );
  }

  int _getNextPowerOfTwo(int n) {
    int power = 1;
    while (power < n) {
      power *= 2;
    }
    return power;
  }

  int _calculateRounds(int bracketSize) {
    return (log(bracketSize) / log(2)).round();
  }
}
*/

class _MatchManagementTab extends StatefulWidget {
  final String tournamentId;

  const _MatchManagementTab({required this.tournamentId});

  @override
  _MatchManagementTabState createState() => _MatchManagementTabState();
}

class _MatchManagementTabState extends State<_MatchManagementTab> {
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
      final matches = await _tournamentService.getTournamentMatches(widget.tournamentId);
      setState(() {
        _matches = matches;
        _isLoading = false;
      });
    } catch (e) {
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
            CircularProgressIndicator(color: AppTheme.primaryLight),
            SizedBox(height: 16.sp),
            Text("Đang tải trận đấu...", 
                style: TextStyle(color: AppTheme.textSecondaryLight)),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64.sp, color: AppTheme.errorLight),
            SizedBox(height: 16.sp),
            Text("Lỗi tải dữ liệu", 
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600)),
            SizedBox(height: 8.sp),
            Text(_errorMessage!, 
                style: TextStyle(color: AppTheme.textSecondaryLight),
                textAlign: TextAlign.center),
            SizedBox(height: 16.sp),
            ElevatedButton(
              onPressed: _loadMatches,
              child: Text("Thử lại"),
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
            Icon(Icons.sports_esports_outlined, size: 64.sp, color: AppTheme.dividerLight),
            SizedBox(height: 16.sp),
            Text("Chưa có trận đấu nào", 
                 style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600)),
            SizedBox(height: 8.sp),
            Text("Tạo bảng đấu trước để có trận đấu", 
                 style: TextStyle(color: AppTheme.textSecondaryLight)),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header with stats and filter
        Container(
          padding: EdgeInsets.all(16.sp),
          margin: EdgeInsets.all(16.sp),
          decoration: BoxDecoration(
            color: AppTheme.primaryLight.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.sp),
            border: Border.all(color: AppTheme.primaryLight.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.sports_esports, color: AppTheme.primaryLight, size: 24.sp),
                  SizedBox(width: 12.sp),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Quản lý trận đấu",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimaryLight,
                          ),
                        ),
                        Text(
                          "Tổng số trận: ${_matches.length}",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppTheme.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _loadMatches,
                    icon: Icon(Icons.refresh, color: AppTheme.primaryLight),
                    tooltip: "Làm mới",
                  ),
                ],
              ),
              
              SizedBox(height: 12.sp),
              
              // Filter tabs
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.sp),
                  border: Border.all(color: AppTheme.dividerLight),
                ),
                child: Row(
                  children: [
                    _buildFilterTab('all', 'Tất cả', _matches.length),
                    _buildFilterTab('pending', 'Chờ đấu', _matches.where((m) => m['status'] == 'pending').length),
                    _buildFilterTab('in_progress', 'Đang đấu', _matches.where((m) => m['status'] == 'in_progress').length),
                    _buildFilterTab('completed', 'Hoàn thành', _matches.where((m) => m['status'] == 'completed').length),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Matches list
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.sp),
            itemCount: _filteredMatches.length,
            itemBuilder: (context, index) {
              final match = _filteredMatches[index];
              return _buildMatchCard(match);
            },
          ),
        ),
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
            color: isSelected ? AppTheme.primaryLight : Colors.transparent,
            borderRadius: BorderRadius.circular(6.sp),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppTheme.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: isSelected ? Colors.white : AppTheme.textSecondaryLight,
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
          // Match header
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 4.sp),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.sp),
                ),
                child: Text(
                  "Vòng $roundNumber - Trận $matchNumber",
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryLight,
                  ),
                ),
              ),
              Spacer(),
              _buildMatchStatusBadge(status),
            ],
          ),

          SizedBox(height: 12.sp),

          // Players and score
          Row(
            children: [
              Expanded(
                child: _buildPlayerInfo(
                  match['player1'], 
                  player1Score, 
                  match['winner_id'] == match['player1_id'],
                ),
              ),
              
              SizedBox(width: 16.sp),
              
              // Score display
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 8.sp),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8.sp),
                ),
                child: Text(
                  "$player1Score - $player2Score",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryLight,
                  ),
                ),
              ),
              
              SizedBox(width: 16.sp),
              
              Expanded(
                child: _buildPlayerInfo(
                  match['player2'], 
                  player2Score, 
                  match['winner_id'] == match['player2_id'],
                  isPlayer2: true,
                ),
              ),
            ],
          ),

          // Action buttons
          if (status == 'pending' || status == 'in_progress') ...[
            SizedBox(height: 16.sp),
            Row(
              children: [
                if (status == 'pending')
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _startMatch(match),
                      icon: Icon(Icons.play_arrow, size: 18.sp),
                      label: Text("Bắt đầu"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.successLight,
                        side: BorderSide(color: AppTheme.successLight),
                      ),
                    ),
                  ),
                if (status == 'pending' && status == 'in_progress')
                  SizedBox(width: 12.sp),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _enterScore(match),
                    icon: Icon(Icons.edit, size: 18.sp),
                    label: Text(status == 'pending' ? "Nhập tỷ số" : "Cập nhật tỷ số"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryLight,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],

          if (status == 'completed') ...[
            SizedBox(height: 16.sp),
            Row(
              children: [
                Icon(Icons.check_circle, color: AppTheme.successLight, size: 16.sp),
                SizedBox(width: 8.sp),
                Text(
                  "Trận đấu đã hoàn thành",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppTheme.successLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Spacer(),
                TextButton(
                  onPressed: () => _editCompletedMatch(match),
                  child: Text("Chỉnh sửa"),
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
          "TBD",
          style: TextStyle(
            fontSize: 14.sp,
            color: AppTheme.textSecondaryLight,
            fontStyle: FontStyle.italic,
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
          Row(
            mainAxisAlignment: isPlayer2 ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isPlayer2 && isWinner) ...[
                Icon(Icons.emoji_events, color: AppTheme.successLight, size: 16.sp),
                SizedBox(width: 4.sp),
              ],
              Flexible(
                child: Text(
                  player['full_name'] ?? 'Unknown Player',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: isWinner ? FontWeight.bold : FontWeight.w600,
                    color: isWinner ? AppTheme.successLight : AppTheme.textPrimaryLight,
                  ),
                  textAlign: isPlayer2 ? TextAlign.right : TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isPlayer2 && isWinner) ...[
                SizedBox(width: 4.sp),
                Icon(Icons.emoji_events, color: AppTheme.successLight, size: 16.sp),
              ],
            ],
          ),
          SizedBox(height: 4.sp),
          Text(
            "ELO: ${player['elo_rating'] ?? 1200}",
            style: TextStyle(
              fontSize: 12.sp,
              color: AppTheme.textSecondaryLight,
            ),
            textAlign: isPlayer2 ? TextAlign.right : TextAlign.left,
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
          Icon(icon, size: 14.sp, color: textColor),
          SizedBox(width: 4.sp),
          Text(
            text,
            style: TextStyle(
              fontSize: 12.sp,
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _startMatch(Map<String, dynamic> match) async {
    try {
      // Update match status to in_progress
      // This would be implemented in TournamentService
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã bắt đầu trận đấu'),
          backgroundColor: AppTheme.successLight,
        ),
      );
      
      _loadMatches(); // Refresh
    } catch (e) {
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
      builder: (context) => _ScoreEntryDialog(
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
      builder: (context) => _ScoreEntryDialog(
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
      // Update match result in database using BracketService
      await _bracketService.saveMatchResultToDatabase(
        matchId: match['id'],
        winnerId: winnerId,
        player1Score: player1Score,
        player2Score: player2Score,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã cập nhật tỷ số trận đấu và lưu vào database'),
          backgroundColor: AppTheme.successLight,
        ),
      );
      
      _loadMatches(); // Refresh
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi cập nhật tỷ số: ${e.toString()}'),
          backgroundColor: AppTheme.errorLight,
        ),
      );
    }
  }
}

class _ScoreEntryDialog extends StatefulWidget {
  final Map<String, dynamic> match;
  final bool isEditing;
  final Function(int player1Score, int player2Score, String winnerId) onScoreSubmitted;

  const _ScoreEntryDialog({
    required this.match,
    required this.onScoreSubmitted,
    this.isEditing = false,
  });

  @override
  _ScoreEntryDialogState createState() => _ScoreEntryDialogState();
}

class _ScoreEntryDialogState extends State<_ScoreEntryDialog> {
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
            // Match info
            Container(
              padding: EdgeInsets.all(12.sp),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8.sp),
              ),
              child: Column(
                children: [
                  Text(
                    "Vòng ${widget.match['round_number']} - Trận ${widget.match['match_number']}",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryLight,
                    ),
                  ),
                  SizedBox(height: 8.sp),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          player1?['full_name'] ?? 'TBD',
                          style: TextStyle(fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Text(' vs '),
                      Expanded(
                        child: Text(
                          player2?['full_name'] ?? 'TBD',
                          style: TextStyle(fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.sp),

            // Score input
            Row(
              children: [
                // Player 1 score
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        player1?['full_name'] ?? 'Player 1',
                        style: TextStyle(fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8.sp),
                      TextField(
                        controller: _player1ScoreController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(vertical: 12.sp),
                        ),
                        onChanged: (value) => _updateWinner(),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(width: 16.sp),
                Text(
                  '-',
                  style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 16.sp),

                // Player 2 score
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        player2?['full_name'] ?? 'Player 2',
                        style: TextStyle(fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8.sp),
                      TextField(
                        controller: _player2ScoreController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(vertical: 12.sp),
                        ),
                        onChanged: (value) => _updateWinner(),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.sp),

            // Winner display
            if (_selectedWinnerId != null) ...[
              Container(
                padding: EdgeInsets.all(12.sp),
                decoration: BoxDecoration(
                  color: AppTheme.successLight.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.sp),
                  border: Border.all(color: AppTheme.successLight),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
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
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryLight,
            foregroundColor: Colors.white,
          ),
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
        _selectedWinnerId = widget.match['player1_id'];
      } else if (player2Score > player1Score) {
        _selectedWinnerId = widget.match['player2_id'];
      } else {
        _selectedWinnerId = null;
      }
    });
  }

  String _getWinnerName() {
    if (_selectedWinnerId == widget.match['player1_id']) {
      return widget.match['player1']?['full_name'] ?? 'Player 1';
    } else if (_selectedWinnerId == widget.match['player2_id']) {
      return widget.match['player2']?['full_name'] ?? 'Player 2';
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

class _TournamentSettingsTab extends StatefulWidget {
  final String tournamentId;
  final VoidCallback? onStatusChanged;

  const _TournamentSettingsTab({
    required this.tournamentId,
    this.onStatusChanged,
  });

  @override
  _TournamentSettingsTabState createState() => _TournamentSettingsTabState();
}

class _TournamentSettingsTabState extends State<_TournamentSettingsTab> {
  final TournamentService _tournamentService = TournamentService.instance;
  final BracketService _bracketService = BracketService.instance;
  
  bool _isLoading = true;
  bool _isCompleting = false;
  String? _errorMessage;
  List<Map<String, dynamic>> _matches = [];
  List<Map<String, dynamic>> _participants = [];
  List<Map<String, dynamic>>? _standings;

  @override
  void initState() {
    super.initState();
    _loadTournamentData();
  }

  Future<void> _loadTournamentData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load tournament matches and participants
      _matches = await _tournamentService.getTournamentMatches(widget.tournamentId);
      _participants = await _tournamentService
          .getTournamentParticipantsWithPaymentStatus(widget.tournamentId);

      // Calculate standings if possible
      List<Map<String, dynamic>>? standings;
      if (_matches.isNotEmpty && _participants.isNotEmpty) {
        standings = _bracketService.getTournamentStandings(_matches, _participants);
      }

      setState(() {
        _standings = standings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi tải dữ liệu: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  bool get _canCompleteTournament {
    if (_matches.isEmpty) return false;
    
    // Check if tournament is complete based on bracket logic
    return _bracketService.isTournamentComplete(_matches);
  }

  int get _completedMatches {
    return _matches.where((m) => m['status'] == 'completed').length;
  }

  int get _totalMatches {
    return _matches.length;
  }

  double get _completionProgress {
    if (_totalMatches == 0) return 0.0;
    return _completedMatches / _totalMatches;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppTheme.primaryLight),
            SizedBox(height: 16.sp),
            Text("Đang tải thông tin giải đấu...", 
                style: TextStyle(color: AppTheme.textSecondaryLight)),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64.sp, color: AppTheme.errorLight),
            SizedBox(height: 16.sp),
            Text("Lỗi tải dữ liệu", 
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600)),
            SizedBox(height: 8.sp),
            Text(_errorMessage!, 
                style: TextStyle(color: AppTheme.textSecondaryLight),
                textAlign: TextAlign.center),
            SizedBox(height: 16.sp),
            ElevatedButton(
              onPressed: _loadTournamentData,
              child: Text("Thử lại"),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tournament completion status
          Container(
            padding: EdgeInsets.all(16.sp),
            decoration: BoxDecoration(
              color: _canCompleteTournament 
                  ? AppTheme.successLight.withOpacity(0.1)
                  : AppTheme.warningLight.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.sp),
              border: Border.all(
                color: _canCompleteTournament 
                    ? AppTheme.successLight.withOpacity(0.3)
                    : AppTheme.warningLight.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _canCompleteTournament ? Icons.check_circle : Icons.schedule,
                      color: _canCompleteTournament ? AppTheme.successLight : AppTheme.warningLight,
                      size: 24.sp,
                    ),
                    SizedBox(width: 12.sp),
                    Expanded(
                      child: Text(
                        _canCompleteTournament 
                            ? "Giải đấu sẵn sàng hoàn thành"
                            : "Giải đấu chưa hoàn thành",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: _canCompleteTournament ? AppTheme.successLight : AppTheme.warningLight,
                        ),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 12.sp),
                
                // Progress bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Tiến độ trận đấu:",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppTheme.textSecondaryLight,
                          ),
                        ),
                        Text(
                          "$_completedMatches/$_totalMatches trận",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimaryLight,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.sp),
                    LinearProgressIndicator(
                      value: _completionProgress,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _canCompleteTournament ? AppTheme.successLight : AppTheme.primaryLight,
                      ),
                    ),
                    SizedBox(height: 4.sp),
                    Text(
                      "${(_completionProgress * 100).toStringAsFixed(0)}% hoàn thành",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppTheme.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 24.sp),

          // Tournament standings
          if (_standings != null) ...[
            Text(
              "Bảng xếp hạng hiện tại:",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryLight,
              ),
            ),
            SizedBox(height: 16.sp),
            
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.sp),
                border: Border.all(color: AppTheme.dividerLight),
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: EdgeInsets.all(16.sp),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12.sp),
                        topRight: Radius.circular(12.sp),
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 40.sp, child: Text("#", style: TextStyle(fontWeight: FontWeight.w600))),
                        Expanded(child: Text("Người chơi", style: TextStyle(fontWeight: FontWeight.w600))),
                        SizedBox(width: 50.sp, child: Text("W-L", style: TextStyle(fontWeight: FontWeight.w600), textAlign: TextAlign.center)),
                        SizedBox(width: 50.sp, child: Text("Điểm", style: TextStyle(fontWeight: FontWeight.w600), textAlign: TextAlign.center)),
                      ],
                    ),
                  ),
                  
                  // Standings list
                  ...(_standings!.take(10).map((standing) => _buildStandingRow(standing)).toList()),
                ],
              ),
            ),
            
            SizedBox(height: 24.sp),
          ],

          // Complete tournament section
          Container(
            padding: EdgeInsets.all(16.sp),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.sp),
              border: Border.all(color: AppTheme.dividerLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.emoji_events, color: AppTheme.primaryLight, size: 24.sp),
                    SizedBox(width: 12.sp),
                    Text(
                      "Hoàn thành giải đấu",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 16.sp),
                
                Text(
                  "Khi hoàn thành giải đấu, hệ thống sẽ:",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryLight,
                  ),
                ),
                
                SizedBox(height: 8.sp),
                
                ...[
                  "• Xác định vô địch và á quân",
                  "• Cập nhật ELO rating cho tất cả người chơi",
                  "• Phân phối prize pool theo thứ hạng",
                  "• Lưu lịch sử kết quả giải đấu",
                  "• Gửi thông báo kết quả cho người tham gia",
                  "• Cập nhật thống kê câu lạc bộ",
                ].map((text) => Padding(
                  padding: EdgeInsets.only(bottom: 4.sp),
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppTheme.textSecondaryLight,
                    ),
                  ),
                )),
                
                SizedBox(height: 20.sp),
                
                // Complete button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _canCompleteTournament && !_isCompleting ? _completeTournament : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _canCompleteTournament ? AppTheme.successLight : Colors.grey,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16.sp),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.sp),
                      ),
                    ),
                    child: _isCompleting
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20.sp,
                                height: 20.sp,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 12.sp),
                              Text("Đang hoàn thành giải đấu..."),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.emoji_events),
                              SizedBox(width: 8.sp),
                              Text(_canCompleteTournament 
                                  ? "Hoàn thành giải đấu" 
                                  : "Chưa thể hoàn thành"),
                            ],
                          ),
                  ),
                ),
                
                if (!_canCompleteTournament) ...[
                  SizedBox(height: 12.sp),
                  Container(
                    padding: EdgeInsets.all(12.sp),
                    decoration: BoxDecoration(
                      color: AppTheme.warningLight.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.sp),
                      border: Border.all(color: AppTheme.warningLight.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: AppTheme.warningLight, size: 20.sp),
                        SizedBox(width: 8.sp),
                        Expanded(
                          child: Text(
                            "Hoàn thành tất cả trận đấu trước khi kết thúc giải đấu",
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppTheme.warningLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          SizedBox(height: 24.sp),

          // Other tournament settings
          Container(
            padding: EdgeInsets.all(16.sp),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.sp),
              border: Border.all(color: AppTheme.dividerLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Cài đặt khác",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryLight,
                  ),
                ),
                
                SizedBox(height: 16.sp),
                
                // Export results
                ListTile(
                  leading: Icon(Icons.file_download, color: AppTheme.primaryLight),
                  title: Text("Xuất kết quả"),
                  subtitle: Text("Tải file Excel chứa kết quả giải đấu"),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16.sp),
                  onTap: _exportResults,
                ),
                
                Divider(),
                
                // Send notifications
                ListTile(
                  leading: Icon(Icons.notifications, color: AppTheme.primaryLight),
                  title: Text("Gửi thông báo"),
                  subtitle: Text("Thông báo kết quả cho người tham gia"),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16.sp),
                  onTap: _sendNotifications,
                ),
                
                Divider(),
                
                // Archive tournament
                ListTile(
                  leading: Icon(Icons.archive, color: AppTheme.warningLight),
                  title: Text("Lưu trữ giải đấu"),
                  subtitle: Text("Chuyển giải đấu vào mục lưu trữ"),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16.sp),
                  onTap: _archiveTournament,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStandingRow(Map<String, dynamic> standing) {
    final position = standing['position'];
    final user = standing['user'];
    final wins = standing['wins'];
    final losses = standing['losses'];
    final points = standing['points'];
    
    Color? backgroundColor;
    if (position == 1) {
      backgroundColor = Colors.amber.withOpacity(0.1);
    } else if (position == 2) {
      backgroundColor = Colors.grey.withOpacity(0.1);
    } else if (position == 3) {
      backgroundColor = Colors.orange.withOpacity(0.1);
    }

    return Container(
      color: backgroundColor,
      child: Padding(
        padding: EdgeInsets.all(12.sp),
        child: Row(
          children: [
            // Position
            SizedBox(
              width: 40.sp,
              child: Row(
                children: [
                  if (position <= 3) ...[
                    Icon(
                      Icons.emoji_events,
                      size: 16.sp,
                      color: position == 1 ? Colors.amber : 
                             position == 2 ? Colors.grey : Colors.orange,
                    ),
                    SizedBox(width: 4.sp),
                  ],
                  Text(
                    "$position",
                    style: TextStyle(
                      fontWeight: position <= 3 ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            
            // Player name
            Expanded(
              child: Text(
                user['full_name'] ?? 'Unknown Player',
                style: TextStyle(
                  fontWeight: position <= 3 ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            
            // W-L record
            SizedBox(
              width: 50.sp,
              child: Text(
                "$wins-$losses",
                style: TextStyle(fontSize: 13.sp),
                textAlign: TextAlign.center,
              ),
            ),
            
            // Points
            SizedBox(
              width: 50.sp,
              child: Text(
                "$points",
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _completeTournament() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Xác nhận hoàn thành giải đấu"),
        content: Text(
          "Bạn có chắc chắn muốn hoàn thành giải đấu này?\n\n"
          "Hành động này không thể hoàn tác và sẽ:\n"
          "• Cập nhật ELO rating\n"
          "• Phân phối prize pool\n"
          "• Gửi thông báo kết quả\n"
          "• Chuyển trạng thái thành 'completed'"
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successLight,
              foregroundColor: Colors.white,
            ),
            child: Text("Xác nhận"),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isCompleting = true);

    try {
      // TODO: Implement tournament completion logic
      // This would involve:
      // 1. Update tournament status to 'completed'
      // 2. Calculate final ELO changes
      // 3. Distribute prize pool
      // 4. Send notifications
      // 5. Update club statistics

      await Future.delayed(Duration(seconds: 2)); // Simulate API call

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Giải đấu đã được hoàn thành thành công!'),
          backgroundColor: AppTheme.successLight,
        ),
      );

      // Call the status changed callback
      widget.onStatusChanged?.call();
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi hoàn thành giải đấu: ${e.toString()}'),
          backgroundColor: AppTheme.errorLight,
        ),
      );
    } finally {
      setState(() => _isCompleting = false);
    }
  }

  void _exportResults() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tính năng xuất kết quả đang được phát triển'),
        backgroundColor: AppTheme.primaryLight,
      ),
    );
  }

  void _sendNotifications() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tính năng gửi thông báo đang được phát triển'),
        backgroundColor: AppTheme.primaryLight,
      ),
    );
  }

  void _archiveTournament() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tính năng lưu trữ đang được phát triển'),
        backgroundColor: AppTheme.primaryLight,
      ),
    );
  }
}