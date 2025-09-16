import 'package:flutter/material.dart';
import 'package:sabo_arena/core/app_export.dart';
import 'package:sabo_arena/widgets/custom_app_bar.dart';

class ClubDashboardScreen extends StatefulWidget {
  const ClubDashboardScreen({super.key});

  @override
  _ClubDashboardScreenState createState() => _ClubDashboardScreenState();
}

class _ClubDashboardScreenState extends State<ClubDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.gray50,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildQuickStatsSection(),
              SizedBox(height: 24.v),
              _buildQuickActionsSection(),
              SizedBox(height: 24.v),
              _buildRecentActivitySection(),
            ],
          ),
        ),
      ),
    );
  }

  /// Section Widget - App Bar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Container(
        margin: EdgeInsets.all(8.h),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.h),
          child: CustomImageWidget(
            imagePath: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=100&h=100&fit=crop',
            height: 40.adaptSize,
            width: 40.adaptSize,
            fit: BoxFit.cover,
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "SABO Arena Central",
                style: CustomTextStyles.titleMediumBold,
              ),
              SizedBox(width: 4.h),
              Icon(
                Icons.verified,
                color: appTheme.blue600,
                size: 20.adaptSize,
              ),
            ],
          ),
          Text(
            "@saboarena_central",
            style: CustomTextStyles.bodySmall.copyWith(
              color: appTheme.gray600,
            ),
          ),
        ],
      ),
      actions: [
        Stack(
          children: [
            IconButton(
              icon: Icon(Icons.notifications_outlined, color: appTheme.gray700),
              onPressed: () => _onNotificationPressed(),
            ),
            if (_getNotificationCount() > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: EdgeInsets.all(4.h),
                  decoration: BoxDecoration(
                    color: appTheme.red600,
                    shape: BoxShape.circle,
                  ),
                  constraints: BoxConstraints(
                    minWidth: 16.h,
                    minHeight: 16.h,
                  ),
                  child: Text(
                    '${_getNotificationCount()}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.fSize,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        IconButton(
          icon: Icon(Icons.settings_outlined, color: appTheme.gray700),
          onPressed: () => _onSettingsPressed(),
        ),
        SizedBox(width: 8.h),
      ],
    );
  }

  /// Section Widget - Quick Stats
  Widget _buildQuickStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Tổng quan CLB",
          style: CustomTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16.v),
        Row(
          children: [
            Expanded(
              child: _buildStatsCard(
                title: "Thành viên",
                value: "156",
                trend: "up",
                trendValue: "+12",
                icon: Icons.people_outline,
                color: appTheme.green600,
              ),
            ),
            SizedBox(width: 12.h),
            Expanded(
              child: _buildStatsCard(
                title: "Giải đấu hoạt động",
                value: "3",
                icon: Icons.emoji_events_outlined,
                color: appTheme.orange600,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.v),
        Row(
          children: [
            Expanded(
              child: _buildStatsCard(
                title: "Doanh thu tháng",
                value: "45.2M",
                trend: "up",
                trendValue: "+8.5%",
                icon: Icons.attach_money_outlined,
                color: appTheme.blue600,
                subtitle: "VND",
              ),
            ),
            SizedBox(width: 12.h),
            Expanded(
              child: _buildStatsCard(
                title: "Xếp hạng CLB",
                value: "#12",
                icon: Icons.military_tech_outlined,
                color: appTheme.purple600,
                subtitle: "Khu vực",
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Section Widget - Quick Actions
  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Thao tác nhanh",
          style: CustomTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16.v),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                title: "Tạo giải đấu",
                subtitle: "Tổ chức giải đấu mới",
                icon: Icons.add_circle_outline,
                color: appTheme.green600,
                onPress: () => _onCreateTournament(),
              ),
            ),
            SizedBox(width: 12.h),
            Expanded(
              child: _buildQuickActionCard(
                title: "Quản lý thành viên",
                subtitle: "Xem và quản lý thành viên",
                icon: Icons.people_outline,
                color: appTheme.blue600,
                badge: 3,
                onPress: () => _onManageMembers(),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.v),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                title: "Cập nhật thông tin",
                subtitle: "Chỉnh sửa thông tin CLB",
                icon: Icons.edit_outlined,
                color: appTheme.orange600,
                onPress: () => _onEditProfile(),
              ),
            ),
            SizedBox(width: 12.h),
            Expanded(
              child: _buildQuickActionCard(
                title: "Thông báo",
                subtitle: "Gửi thông báo đến thành viên",
                icon: Icons.notifications_outlined,
                color: appTheme.purple600,
                onPress: () => _onSendNotification(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Section Widget - Recent Activity
  Widget _buildRecentActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Hoạt động gần đây",
              style: CustomTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => _onViewAllActivity(),
              child: Text(
                "Xem tất cả",
                style: CustomTextStyles.bodyMedium.copyWith(
                  color: appTheme.blue600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.v),
        Container(
          padding: EdgeInsets.all(16.h),
          decoration: AppDecoration.fillWhite.copyWith(
            borderRadius: BorderRadiusStyle.roundedBorder12,
            boxShadow: [
              BoxShadow(
                color: appTheme.black900.withOpacity(0.05),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildActivityItem(
                type: "member_joined",
                title: "Nguyễn Văn Nam đã tham gia CLB",
                subtitle: "Thành viên mới từ quận 1",
                timestamp: DateTime.now().subtract(Duration(minutes: 15)),
                avatar: "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=50&h=50&fit=crop&crop=face",
                color: appTheme.green600,
              ),
              _buildDivider(),
              _buildActivityItem(
                type: "tournament_created",
                title: "Giải đấu 'Golden Cup 2025' đã được tạo",
                subtitle: "32 người tham gia • Bắt đầu 25/09",
                timestamp: DateTime.now().subtract(Duration(hours: 2)),
                icon: Icons.emoji_events,
                color: appTheme.orange600,
              ),
              _buildDivider(),
              _buildActivityItem(
                type: "match_completed",
                title: "Trận đấu giữa Mai và Long đã kết thúc",
                subtitle: "Mai thắng 8-6 • Thời gian: 45 phút",
                timestamp: DateTime.now().subtract(Duration(hours: 4)),
                icon: Icons.sports_esports,
                color: appTheme.blue600,
              ),
              _buildDivider(),
              _buildActivityItem(
                type: "payment_received",
                title: "Thanh toán từ Trần Thị Hương",
                subtitle: "Phí thành viên tháng 9 • 200,000 VND",
                timestamp: DateTime.now().subtract(Duration(days: 1)),
                icon: Icons.payment,
                color: appTheme.purple600,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Component - Stats Card
  Widget _buildStatsCard({
    required String title,
    required String value,
    String? trend,
    String? trendValue,
    required IconData icon,
    required Color color,
    String? subtitle,
  }) {
    return Container(
      padding: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.h),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.h),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8.h),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20.adaptSize,
                ),
              ),
              Spacer(),
              if (trend != null)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.h, vertical: 2.v),
                  decoration: BoxDecoration(
                    color: trend == "up" ? appTheme.green50 : appTheme.red50,
                    borderRadius: BorderRadius.circular(12.h),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        trend == "up" ? Icons.trending_up : Icons.trending_down,
                        color: trend == "up" ? appTheme.green600 : appTheme.red600,
                        size: 12.adaptSize,
                      ),
                      SizedBox(width: 2.h),
                      Text(
                        trendValue ?? "",
                        style: TextStyle(
                          color: trend == "up" ? appTheme.green600 : appTheme.red600,
                          fontSize: 10.fSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: 12.v),
          Text(
            value,
            style: TextStyle(
              fontSize: 24.fSize,
              fontWeight: FontWeight.bold,
              color: appTheme.gray900,
            ),
          ),
          if (subtitle != null) ...[
            SizedBox(height: 2.v),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12.fSize,
                color: appTheme.gray600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          SizedBox(height: 4.v),
          Text(
            title,
            style: TextStyle(
              fontSize: 12.fSize,
              color: appTheme.gray600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Component - Quick Action Card  
  Widget _buildQuickActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    int? badge,
    required VoidCallback onPress,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12.h),
      child: InkWell(
        onTap: onPress,
        borderRadius: BorderRadius.circular(12.h),
        child: Container(
          padding: EdgeInsets.all(16.h),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: color, width: 4.h),
            ),
            borderRadius: BorderRadius.circular(12.h),
            boxShadow: [
              BoxShadow(
                color: appTheme.black900.withOpacity(0.05),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.h),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.h),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 20.adaptSize,
                    ),
                  ),
                  Spacer(),
                  if (badge != null && badge > 0)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.h, vertical: 2.v),
                      decoration: BoxDecoration(
                        color: appTheme.red600,
                        borderRadius: BorderRadius.circular(10.h),
                      ),
                      child: Text(
                        badge.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.fSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 12.v),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.fSize,
                  fontWeight: FontWeight.bold,
                  color: appTheme.gray900,
                ),
              ),
              SizedBox(height: 4.v),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12.fSize,
                  color: appTheme.gray600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Component - Activity Item
  Widget _buildActivityItem({
    required String type,
    required String title,
    required String subtitle,
    required DateTime timestamp,
    String? avatar,
    IconData? icon,
    required Color color,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.v),
      child: Row(
        children: [
          // Avatar or Icon
          Container(
            width: 40.adaptSize,
            height: 40.adaptSize,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.h),
              color: avatar != null ? null : color.withOpacity(0.1),
            ),
            child: avatar != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(20.h),
                    child: CustomImageWidget(
                      imagePath: avatar,
                      fit: BoxFit.cover,
                    ),
                  )
                : Icon(
                    icon,
                    color: color,
                    size: 20.adaptSize,
                  ),
          ),
          SizedBox(width: 12.h),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.fSize,
                    fontWeight: FontWeight.w600,
                    color: appTheme.gray900,
                  ),
                ),
                SizedBox(height: 2.v),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12.fSize,
                    color: appTheme.gray600,
                  ),
                ),
              ],
            ),
          ),
          // Timestamp
          Text(
            _formatRelativeTime(timestamp),
            style: TextStyle(
              fontSize: 11.fSize,
              color: appTheme.gray500,
            ),
          ),
        ],
      ),
    );
  }

  /// Component - Divider
  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.v),
      child: Divider(
        color: appTheme.gray200,
        thickness: 1,
      ),
    );
  }

  // Helper Methods
  String _formatRelativeTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else {
      return '${difference.inDays} ngày trước';
    }
  }

  int _getNotificationCount() => 5; // Mock data

  // Event Handlers
  void _onNotificationPressed() {
    // Navigate to notifications screen
    print('Notifications pressed');
  }

  void _onSettingsPressed() {
    // Navigate to settings screen
    print('Settings pressed');
  }

  void _onCreateTournament() {
    // Navigate to create tournament screen
    print('Create tournament pressed');
  }

  void _onManageMembers() {
    // Navigate to manage members screen
    print('Manage members pressed');
  }

  void _onEditProfile() {
    // Navigate to edit profile screen
    print('Edit profile pressed');
  }

  void _onSendNotification() {
    // Navigate to send notification screen
    print('Send notification pressed');
  }

  void _onViewAllActivity() {
    // Navigate to all activity screen
    print('View all activity pressed');
  }
}