import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/app_export.dart';
import '../../services/admin_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../routes/app_routes.dart';
import './club_approval_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AdminService _adminService = AdminService.instance;
  
  Map<String, dynamic>? _stats;
  List<Map<String, dynamic>> _recentActivities = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final results = await Future.wait([
        _adminService.getAdminStats(),
        _adminService.getRecentActivities(limit: 10),
      ]);

      setState(() {
        _stats = results[0] as Map<String, dynamic>;
        _recentActivities = results[1] as List<Map<String, dynamic>>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Lỗi tải dữ liệu dashboard: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.whiteA700,
      appBar: CustomAppBar(
        title: "Admin Dashboard",
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: appTheme.blueGray900),
            onPressed: _loadDashboardData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorState()
              : _buildDashboardContent(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: appTheme.red600),
          SizedBox(height: 16),
          Text(
            _errorMessage!,
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadDashboardData,
            child: Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent() {
    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeSection(),
            SizedBox(height: 24),
            _buildStatsCards(),
            SizedBox(height: 24),
            _buildQuickActions(),
            SizedBox(height: 24),
            _buildRecentActivities(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [appTheme.deepPurple500, appTheme.indigo500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chào mừng Admin!',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: appTheme.whiteA700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Quản lý hệ thống Sabo Arena',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: appTheme.whiteA700.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: appTheme.whiteA700.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.admin_panel_settings,
              color: appTheme.whiteA700,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    if (_stats == null) return SizedBox.shrink();

    final clubStats = _stats!['clubs'] as Map<String, dynamic>;
    final userStats = _stats!['users'] as Map<String, dynamic>;
    final tournamentStats = _stats!['tournaments'] as Map<String, dynamic>;
    final matchStats = _stats!['matches'] as Map<String, dynamic>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thống kê hệ thống',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'CLB chờ duyệt',
                value: clubStats['pending'].toString(),
                icon: Icons.pending_actions,
                color: appTheme.orange600,
                onTap: () => _navigateToClubApproval('pending'),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'CLB đã duyệt',
                value: clubStats['approved'].toString(),
                icon: Icons.check_circle,
                color: appTheme.green600,
                onTap: () => _navigateToClubApproval('approved'),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Tổng Users',
                value: userStats['total'].toString(),
                icon: Icons.people,
                color: appTheme.blue600,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'Tournaments',
                value: tournamentStats['total'].toString(),
                icon: Icons.emoji_events,
                color: appTheme.purple600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: appTheme.whiteA700,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: appTheme.gray200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                if (onTap != null)
                  Icon(Icons.arrow_forward_ios, size: 16, color: appTheme.gray600),
              ],
            ),
            SizedBox(height: 12),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: appTheme.blueGray900,
              ),
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: appTheme.blueGray600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thao tác nhanh',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                title: 'Duyệt CLB',
                subtitle: 'Quản lý đăng ký CLB',
                icon: Icons.approval,
                color: appTheme.green600,
                onTap: () => _navigateToClubApproval(null),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                title: 'Quản lý User',
                subtitle: 'Xem danh sách users',
                icon: Icons.people_outline,
                color: appTheme.blue600,
                onTap: () {
                  // TODO: Navigate to user management
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Tính năng đang phát triển')),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: appTheme.whiteA700,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: appTheme.gray200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: appTheme.blueGray600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Hoạt động gần đây',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to full activity log
              },
              child: Text('Xem tất cả'),
            ),
          ],
        ),
        SizedBox(height: 16),
        if (_recentActivities.isEmpty)
          Container(
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: appTheme.gray50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'Chưa có hoạt động nào',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: appTheme.blueGray600,
                ),
              ),
            ),
          )
        else
          ...(_recentActivities.take(5).map((activity) => _buildActivityItem(activity))),
      ],
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    final timestamp = activity['timestamp'] as DateTime;
    final timeAgo = _formatTimeAgo(timestamp);

    Color statusColor = appTheme.gray500;
    IconData statusIcon = Icons.info;

    switch (activity['status']) {
      case 'pending':
        statusColor = appTheme.orange600;
        statusIcon = Icons.pending;
        break;
      case 'approved':
        statusColor = appTheme.green600;
        statusIcon = Icons.check_circle;
        break;
      case 'rejected':
        statusColor = appTheme.red600;
        statusIcon = Icons.cancel;
        break;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appTheme.whiteA700,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: appTheme.gray200),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(statusIcon, color: statusColor, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['title'],
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  activity['description'],
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: appTheme.blueGray600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  timeAgo,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: appTheme.blueGray500,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16, color: appTheme.gray400),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Vừa xong';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  void _navigateToClubApproval(String? filterStatus) {
    // Use MaterialPageRoute for now since we need to pass initialFilter parameter
    // In future, could improve with route arguments
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClubApprovalScreen(initialFilter: filterStatus),
      ),
    ).then((_) {
      // Refresh dashboard when returning
      _loadDashboardData();
    });
  }
}