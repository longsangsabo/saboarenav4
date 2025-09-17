import 'package:flutter/material.dart';
import 'package:sabo_arena/core/app_export.dart';
import 'package:sabo_arena/widgets/custom_app_bar.dart';
import 'package:sabo_arena/theme/app_theme.dart';
import 'package:sabo_arena/models/club.dart';
import 'package:sabo_arena/services/club_service.dart';
import 'package:sabo_arena/services/auth_service.dart';
import 'package:sabo_arena/services/club_dashboard_service.dart';
import '../member_management_screen/member_management_screen.dart';
import '../tournament_create_screen/tournament_create_screen_simple.dart';
import '../club_notification_screen/club_notification_screen_simple.dart';
import '../club_settings_screen/club_settings_screen.dart';
import '../club_reports_screen/club_reports_screen.dart';

class ClubDashboardScreenSimple extends StatefulWidget {
  final String clubId;

  const ClubDashboardScreenSimple({
    super.key,
    required this.clubId,
  });

  @override
  State<ClubDashboardScreenSimple> createState() => _ClubDashboardScreenSimpleState();
}

class _ClubDashboardScreenSimpleState extends State<ClubDashboardScreenSimple> {
  bool _isLoading = true;
  Club? _club;
  bool _isOwner = false;
  
  // Dashboard data
  ClubDashboardStats? _dashboardStats;
  List<ClubActivity> _recentActivities = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final club = await ClubService.instance.getClubById(widget.clubId);
      final currentUserId = AuthService.instance.currentUser?.id;
      final isOwner = club.ownerId == currentUserId;
      
      setState(() {
        _club = club;
        _isOwner = isOwner;
      });

      if (isOwner) {
        // Load dashboard data for club owner
        final results = await Future.wait([
          ClubDashboardService.instance.getClubStats(widget.clubId),
          ClubDashboardService.instance.getRecentActivities(widget.clubId),
        ]);

        setState(() {
          _dashboardStats = results[0] as ClubDashboardStats;
          _recentActivities = results[1] as List<ClubActivity>;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải dữ liệu: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: CustomAppBar(title: 'Club Dashboard'),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (!_isOwner) {
      return Scaffold(
        appBar: CustomAppBar(title: 'Club Dashboard'),
        body: const Center(
          child: Text(
            'Bạn không có quyền truy cập vào dashboard này.\nChỉ chủ club mới có thể xem.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: _club?.name ?? 'Club Dashboard',

      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thống kê',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.textPrimaryLight,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            _buildStatsGrid(),
            const SizedBox(height: 32),
            Text(
              'Quản lý nhanh',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.textPrimaryLight,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            _buildQuickActions(),
            const SizedBox(height: 32),
            Text(
              'Hoạt động gần đây',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.textPrimaryLight,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            _buildRecentActivities(),
            const SizedBox(height: 100), // Space for bottom navigation
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _buildStatCard(
          'Thành viên', 
          _dashboardStats?.activeMembers.toString() ?? '0', 
          Icons.people, 
          AppTheme.primaryLight
        ),
        _buildStatCard(
          'Giải đấu', 
          _dashboardStats?.tournaments.toString() ?? '0', 
          Icons.emoji_events, 
          AppTheme.accentLight
        ),
        _buildStatCard(
          'Doanh thu', 
          _formatRevenue(_dashboardStats?.monthlyRevenue ?? 0), 
          Icons.monetization_on, 
          AppTheme.successLight
        ),
        _buildStatCard(
          'Hoạt động', 
          _recentActivities.length.toString(), 
          Icons.trending_up, 
          AppTheme.warningLight
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight,
            offset: const Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppTheme.textPrimaryLight,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondaryLight,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildActionCard(
          'Quản lý thành viên',
          'Thêm, sửa, xóa thành viên',
          Icons.people_outline,
          AppTheme.primaryLight,
          () => _navigateToMemberManagement(),
        ),
        _buildActionCard(
          'Tạo giải đấu',
          'Tổ chức giải đấu mới',
          Icons.add_circle_outline,
          AppTheme.accentLight,
          () => _navigateToTournamentCreate(),
        ),
        _buildActionCard(
          'Gửi thông báo',
          'Thông báo đến thành viên',
          Icons.notifications,
          AppTheme.warningLight,
          () => _navigateToNotifications(),
        ),
        _buildActionCard(
          'Báo cáo',
          'Xem báo cáo chi tiết',
          Icons.bar_chart_outlined,
          AppTheme.successLight,
          () => _showReports(),
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.15), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppTheme.shadowLight,
              offset: const Offset(0, 2),
              blurRadius: 8,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.textPrimaryLight,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivities() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight,
            offset: const Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: _recentActivities.isNotEmpty
            ? _recentActivities.map((activity) => _buildActivityItem(
                activity.title,
                activity.subtitle,
                _getActivityIcon(activity.type),
              )).toList()
            : [
                _buildActivityItem(
                  'Chưa có hoạt động nào',
                  'Hoạt động sẽ xuất hiện tại đây',
                  Icons.info_outline,
                ),
              ],
      ),
    );
  }

  Widget _buildActivityItem(String title, String time, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primaryLight, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textPrimaryLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
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

  IconData _getActivityIcon(String activityType) {
    switch (activityType.toLowerCase()) {
      case 'member_join':
        return Icons.person_add;
      case 'tournament_end':
        return Icons.emoji_events;
      case 'payment':
        return Icons.payment;
      case 'match_result':
        return Icons.sports_esports;
      default:
        return Icons.notifications;
    }
  }

  void _navigateToMemberManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MemberManagementScreen(clubId: widget.clubId),
      ),
    );
  }

  void _navigateToTournamentCreate() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TournamentCreateScreenSimple(clubId: widget.clubId),
      ),
    );
  }

  void _navigateToNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClubNotificationScreenSimple(clubId: widget.clubId),
      ),
    );
  }

  void _showReports() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClubReportsScreen(clubId: widget.clubId),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppTheme.primaryLight,
      unselectedItemColor: Colors.grey[600],
      backgroundColor: Colors.white,
      elevation: 8,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'Thành viên',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.emoji_events),
          label: 'Giải đấu',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Cài đặt',
        ),
      ],
      currentIndex: 0,
      onTap: (index) {
        switch (index) {
          case 0:
            // Already on dashboard
            break;
          case 1:
            _navigateToMemberManagement();
            break;
          case 2:
            _navigateToTournamentCreate();
            break;
          case 3:
            _navigateToClubSettings();
            break;
        }
      },
    );
  }

  void _navigateToClubSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClubSettingsScreen(clubId: widget.clubId),
      ),
    );
  }

  String _formatRevenue(double revenue) {
    if (revenue >= 1000000) {
      return '${(revenue / 1000000).toStringAsFixed(1)}M';
    } else if (revenue >= 1000) {
      return '${(revenue / 1000).toStringAsFixed(1)}K';
    } else {
      return revenue.toStringAsFixed(0);
    }
  }
}