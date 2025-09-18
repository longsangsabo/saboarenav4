import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:sabo_arena/core/app_export.dart';
import 'package:sabo_arena/theme/app_theme.dart';
import 'package:sabo_arena/services/tournament_service.dart';

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
      child: SingleChildScrollView(
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
                margin: EdgeInsets.only(right: 8.sp),
                padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 8.sp),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryLight : Colors.transparent,
                  borderRadius: BorderRadius.circular(20.sp),
                  border: Border.all(
                    color: isSelected ? AppTheme.primaryLight : AppTheme.dividerLight,
                  ),
                ),
                child: Text(
                  tab,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.textSecondaryLight,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
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
        return _BracketManagementTab(tournamentId: widget.tournamentId);
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

class _TournamentOverviewTab extends StatelessWidget {
  final String tournamentId;
  final String tournamentStatus;
  final VoidCallback? onStatusChanged;

  const _TournamentOverviewTab({
    required this.tournamentId,
    required this.tournamentStatus,
    this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuickStats(),
          SizedBox(height: 16.sp),
          _buildQuickActions(),
          SizedBox(height: 16.sp),
          _buildRecentActivity(),
          SizedBox(height: 16.sp),
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
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16.sp),
          
          Row(
            children: [
              Expanded(
                child: _buildStatItem("Người chơi", "16/32", Icons.people_outline),
              ),
              Container(width: 1, height: 40.sp, color: Colors.white.withOpacity(0.3)),
              Expanded(
                child: _buildStatItem("Trận đấu", "8/15", Icons.sports_esports_outlined),
              ),
              Container(width: 1, height: 40.sp, color: Colors.white.withOpacity(0.3)),
              Expanded(
                child: _buildStatItem("Hoàn thành", "53%", Icons.pie_chart_outline),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.8), size: 20.sp),
        SizedBox(height: 4.sp),
        Text(
          value,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
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
              fontSize: 16.sp,
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
    switch (tournamentStatus) {
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
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryLight,
            ),
          ),
          SizedBox(height: 12.sp),
          
          ..._getMockActivities().map((activity) => _buildActivityItem(
            activity['title'],
            activity['time'],
            activity['icon'],
            activity['color'],
          )),
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

  List<Map<String, dynamic>> _getMockActivities() {
    return [
      {
        'title': 'Nguyễn Văn A đã đăng ký tham gia',
        'time': '2 phút trước',
        'icon': Icons.person_add_outlined,
        'color': AppTheme.successLight,
      },
      {
        'title': 'Trận đấu Round 1 - Match 3 đã hoàn thành',
        'time': '15 phút trước',
        'icon': Icons.sports_esports_outlined,
        'color': AppTheme.primaryLight,
      },
      {
        'title': 'Cập nhật kết quả trận Lê Văn B vs Trần Văn C',
        'time': '30 phút trước',
        'icon': Icons.update_outlined,
        'color': AppTheme.warningLight,
      },
    ];
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
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryLight,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text("Xem tất cả"),
              ),
            ],
          ),
          
          ..._getMockUpcomingMatches().map((match) => _buildMatchItem(match)),
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

  List<Map<String, dynamic>> _getMockUpcomingMatches() {
    return [
      {
        'player1': 'Nguyễn Văn A',
        'player2': 'Lê Văn B',
        'round': 'Round 2 - Match 1',
        'time': '14:30',
        'table': 'Bàn 1',
      },
      {
        'player1': 'Trần Văn C',
        'player2': 'Phạm Văn D',
        'round': 'Round 2 - Match 2',
        'time': '15:00',
        'table': 'Bàn 2',
      },
    ];
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
          padding: EdgeInsets.all(16.sp),
          margin: EdgeInsets.all(16.sp),
          decoration: BoxDecoration(
            color: AppTheme.primaryLight.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.sp),
            border: Border.all(color: AppTheme.primaryLight.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.people, color: AppTheme.primaryLight, size: 24.sp),
              SizedBox(width: 12.sp),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Tổng số người chơi: ${_participants.length}",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryLight,
                    ),
                  ),
                  Text(
                    "Đã thanh toán: ${_participants.where((p) => p['payment_status'] == 'completed' || p['payment_status'] == 'confirmed').length}",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppTheme.textSecondaryLight,
                    ),
                  ),
                ],
              ),
              Spacer(),
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
                  padding: EdgeInsets.symmetric(horizontal: 16.sp),
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
          Icon(Icons.people_outline, size: 64.sp, color: AppTheme.dividerLight),
          SizedBox(height: 16.sp),
          Text("Chưa có người chơi nào đăng ký", 
               style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600)),
          SizedBox(height: 8.sp),
          Text("Người chơi đăng ký sẽ hiển thị ở đây", 
               style: TextStyle(color: AppTheme.textSecondaryLight)),
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
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 24.sp,
                backgroundImage: user['avatar_url'] != null
                    ? NetworkImage(user['avatar_url'])
                    : null,
                child: user['avatar_url'] == null
                    ? Icon(Icons.person, size: 24.sp)
                    : null,
              ),
              SizedBox(width: 12.sp),
              
              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user['full_name'] ?? 'Unknown Player',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryLight,
                      ),
                    ),
                    Text(
                      "ELO: ${user['elo_rating']} - ${user['rank']}",
                      style: TextStyle(
                        fontSize: 12.sp,
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
            SizedBox(height: 8.sp),
            Text(
              "Ghi chú: $notes",
              style: TextStyle(
                fontSize: 12.sp,
                color: AppTheme.textSecondaryLight,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],

          SizedBox(height: 12.sp),
          
          // Action buttons
          Row(
            children: [
              Text(
                _formatRegistrationDate(registeredAt),
                style: TextStyle(
                  fontSize: 11.sp,
                  color: AppTheme.textSecondaryLight,
                ),
              ),
              Spacer(),
              
              // Payment confirmation button
              if (paymentStatus == 'pending') ...[
                TextButton.icon(
                  onPressed: () => _confirmPayment(participant),
                  icon: Icon(Icons.check_circle_outline, size: 16.sp),
                  label: Text("Xác nhận TT"),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.successLight,
                    padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 4.sp),
                  ),
                ),
                SizedBox(width: 8.sp),
              ],
              
              // More actions button
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, size: 20.sp),
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

  Future<void> _confirmPayment(Map<String, dynamic> participant) async {
    try {
      await _tournamentService.updateParticipantPaymentStatus(
        tournamentId: widget.tournamentId,
        userId: participant['user_id'],
        paymentStatus: 'confirmed',
        notes: 'Đã xác nhận thanh toán bởi quản lý CLB',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã xác nhận thanh toán cho ${participant['user']['full_name']}'),
          backgroundColor: AppTheme.successLight,
        ),
      );

      _loadParticipants(); // Refresh list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi xác nhận thanh toán: ${e.toString()}'),
          backgroundColor: AppTheme.errorLight,
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

class _BracketManagementTab extends StatelessWidget {
  final String tournamentId;

  const _BracketManagementTab({required this.tournamentId});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_tree_outlined, size: 64.sp, color: AppTheme.dividerLight),
          SizedBox(height: 16.sp),
          Text("Quản lý bảng đấu", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600)),
          SizedBox(height: 8.sp),
          Text("Tính năng đang được phát triển", style: TextStyle(color: AppTheme.textSecondaryLight)),
        ],
      ),
    );
  }
}

class _MatchManagementTab extends StatelessWidget {
  final String tournamentId;

  const _MatchManagementTab({required this.tournamentId});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sports_esports_outlined, size: 64.sp, color: AppTheme.dividerLight),
          SizedBox(height: 16.sp),
          Text("Quản lý trận đấu", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600)),
          SizedBox(height: 8.sp),
          Text("Tính năng đang được phát triển", style: TextStyle(color: AppTheme.textSecondaryLight)),
        ],
      ),
    );
  }
}

class _TournamentSettingsTab extends StatelessWidget {
  final String tournamentId;
  final VoidCallback? onStatusChanged;

  const _TournamentSettingsTab({
    required this.tournamentId,
    this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.settings_outlined, size: 64.sp, color: AppTheme.dividerLight),
          SizedBox(height: 16.sp),
          Text("Cài đặt giải đấu", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600)),
          SizedBox(height: 8.sp),
          Text("Tính năng đang được phát triển", style: TextStyle(color: AppTheme.textSecondaryLight)),
        ],
      ),
    );
  }
}