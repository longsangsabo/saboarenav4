import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:sabo_arena/core/app_export.dart';
import 'package:sabo_arena/theme/app_theme.dart';

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
    super.key,
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

// Placeholder tabs for other management functions
class _ParticipantManagementTab extends StatelessWidget {
  final String tournamentId;

  const _ParticipantManagementTab({super.key, required this.tournamentId});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64.sp, color: AppTheme.dividerLight),
          SizedBox(height: 16.sp),
          Text("Quản lý người chơi", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600)),
          SizedBox(height: 8.sp),
          Text("Tính năng đang được phát triển", style: TextStyle(color: AppTheme.textSecondaryLight)),
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

  const _MatchManagementTab({super.key, required this.tournamentId});

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
    super.key,
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