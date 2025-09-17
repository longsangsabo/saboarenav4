import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../member_management_screen/member_management_screen.dart';
import 'widgets/member_overview_tab.dart';
import 'widgets/member_activity_tab.dart';
import 'widgets/member_matches_tab.dart';
import 'widgets/member_tournaments_tab.dart';
import 'widgets/member_settings_tab.dart';

class MemberDetailScreen extends StatefulWidget {
  final String clubId;
  final String memberId;
  final MemberData? initialMemberData;

  const MemberDetailScreen({
    Key? key,
    required this.clubId,
    required this.memberId,
    this.initialMemberData,
  }) : super(key: key);

  @override
  _MemberDetailScreenState createState() => _MemberDetailScreenState();
}

class _MemberDetailScreenState extends State<MemberDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  MemberData? _memberData;
  bool _isLoading = true;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _loadMemberData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadMemberData() async {
    if (widget.initialMemberData != null) {
      setState(() {
        _memberData = widget.initialMemberData;
        _isLoading = false;
      });
      _animationController.forward();
      return;
    }

    // Simulate API call
    await Future.delayed(Duration(milliseconds: 1200));

    setState(() {
      _memberData = _generateMockMemberData();
      _isLoading = false;
    });

    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: _buildAppBar(),
      body: _isLoading ? _buildLoadingState() : _buildMainContent(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return CustomAppBar(
      title: _memberData?.user.name ?? 'Chi tiết thành viên',
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.share),
          onPressed: _shareMemberProfile,
          tooltip: 'Chia sẻ hồ sơ',
        ),
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Chỉnh sửa'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'message',
              child: Row(
                children: [
                  Icon(Icons.message, size: 20),
                  SizedBox(width: 8),
                  Text('Nhắn tin'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'export',
              child: Row(
                children: [
                  Icon(Icons.download, size: 20),
                  SizedBox(width: 8),
                  Text('Xuất dữ liệu'),
                ],
              ),
            ),
            PopupMenuDivider(),
            PopupMenuItem(
              value: 'promote',
              child: Row(
                children: [
                  Icon(Icons.trending_up, size: 20, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Thăng cấp', style: TextStyle(color: Colors.green)),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'suspend',
              child: Row(
                children: [
                  Icon(Icons.block, size: 20, color: Colors.orange),
                  SizedBox(width: 8),
                  Text('Tạm khóa', style: TextStyle(color: Colors.orange)),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'remove',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Xóa khỏi CLB', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: _handleMenuAction,
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(height: 16),
          Text(
            'Đang tải thông tin thành viên...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: [
                // Member header section
                _buildMemberHeader(),

                // Tab bar
                _buildTabBar(),

                // Tab content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      MemberOverviewTab(memberData: _memberData!),
                      MemberActivityTab(memberData: _memberData!),
                      MemberMatchesTab(memberData: _memberData!),
                      MemberTournamentsTab(memberData: _memberData!),
                      MemberSettingsTab(
                        memberData: _memberData!,
                        onMemberUpdated: _handleMemberUpdated,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMemberHeader() {
    if (_memberData == null) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.secondary.withOpacity(0.1),
          ],
        ),
      ),
      child: Row(
        children: [
          // Avatar section
          Stack(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _getMembershipColor().withOpacity(0.5),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _getMembershipColor().withOpacity(0.3),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 38,
                  backgroundImage: NetworkImage(_memberData!.user.avatar),
                  backgroundColor: Theme.of(context).colorScheme.surface,
                ),
              ),

              // Online status
              if (_memberData!.user.isOnline)
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.surface,
                        width: 3,
                      ),
                    ),
                  ),
                ),

              // Membership badge
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: _getMembershipColor(),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    _getMembershipLabel(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(width: 16),

          // Member info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name and username
                Text(
                  _memberData!.user.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '@${_memberData!.user.username}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                  ),
                ),

                SizedBox(height: 12),

                // Status and rank
                Row(
                  children: [
                    _buildStatusBadge(),
                    SizedBox(width: 12),
                    _buildRankBadge(),
                  ],
                ),

                SizedBox(height: 8),

                // Quick stats
                Row(
                  children: [
                    _buildQuickStat('ELO', '${_memberData!.user.elo}'),
                    SizedBox(width: 16),
                    _buildQuickStat('Trận', '${_memberData!.activityStats.totalMatches}'),
                    SizedBox(width: 16),
                    _buildQuickStat('Thắng', '${(_memberData!.activityStats.winRate * 100).toInt()}%'),
                  ],
                ),
              ],
            ),
          ),

          // Quick actions
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton.filled(
                onPressed: _sendMessage,
                icon: Icon(Icons.message),
                tooltip: 'Nhắn tin',
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(height: 8),
              IconButton.outlined(
                onPressed: _viewStats,
                icon: Icon(Icons.bar_chart),
                tooltip: 'Thống kê',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        tabs: [
          Tab(
            icon: Icon(Icons.person),
            text: 'Tổng quan',
          ),
          Tab(
            icon: Icon(Icons.activity),
            text: 'Hoạt động',
          ),
          Tab(
            icon: Icon(Icons.sports_esports),
            text: 'Trận đấu',
          ),
          Tab(
            icon: Icon(Icons.emoji_events),
            text: 'Giải đấu',
          ),
          Tab(
            icon: Icon(Icons.settings),
            text: 'Cài đặt',
          ),
        ],
        labelColor: Theme.of(context).colorScheme.primary,
        unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        indicatorColor: Theme.of(context).colorScheme.primary,
        indicatorWeight: 3,
        labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 12),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _toggleEditMode,
      icon: Icon(_isEditing ? Icons.save : Icons.edit),
      label: Text(_isEditing ? 'Lưu' : 'Chỉnh sửa'),
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
    );
  }

  Widget _buildStatusBadge() {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (_memberData!.membershipInfo.status) {
      case MemberStatus.active:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Hoạt động';
        break;
      case MemberStatus.inactive:
        statusColor = Colors.grey;
        statusIcon = Icons.pause_circle;
        statusText = 'Không hoạt động';
        break;
      case MemberStatus.suspended:
        statusColor = Colors.orange;
        statusIcon = Icons.block;
        statusText = 'Tạm khóa';
        break;
      case MemberStatus.pending:
        statusColor = Colors.blue;
        statusIcon = Icons.pending;
        statusText = 'Chờ duyệt';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 14, color: statusColor),
          SizedBox(width: 4),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getRankColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getRankColor().withOpacity(0.3)),
      ),
      child: Text(
        _getRankLabel(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _getRankColor(),
        ),
      ),
    );
  }

  Widget _buildQuickStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Color _getMembershipColor() {
    if (_memberData == null) return Colors.grey;
    switch (_memberData!.membershipInfo.type) {
      case MembershipType.regular:
        return Colors.grey;
      case MembershipType.vip:
        return Colors.amber;
      case MembershipType.premium:
        return Colors.purple;
    }
  }

  String _getMembershipLabel() {
    if (_memberData == null) return 'REG';
    switch (_memberData!.membershipInfo.type) {
      case MembershipType.regular:
        return 'REG';
      case MembershipType.vip:
        return 'VIP';
      case MembershipType.premium:
        return 'PRE';
    }
  }

  Color _getRankColor() {
    if (_memberData == null) return Colors.green;
    switch (_memberData!.user.rank) {
      case RankType.beginner:
        return Colors.green;
      case RankType.amateur:
        return Colors.blue;
      case RankType.intermediate:
        return Colors.orange;
      case RankType.advanced:
        return Colors.red;
      case RankType.professional:
        return Colors.purple;
    }
  }

  String _getRankLabel() {
    if (_memberData == null) return 'Mới';
    switch (_memberData!.user.rank) {
      case RankType.beginner:
        return 'Mới bắt đầu';
      case RankType.amateur:
        return 'Nghiệp dư';
      case RankType.intermediate:
        return 'Trung bình';
      case RankType.advanced:
        return 'Nâng cao';
      case RankType.professional:
        return 'Chuyên nghiệp';
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'edit':
        _toggleEditMode();
        break;
      case 'message':
        _sendMessage();
        break;
      case 'export':
        _exportMemberData();
        break;
      case 'promote':
        _promoteMember();
        break;
      case 'suspend':
        _suspendMember();
        break;
      case 'remove':
        _removeMember();
        break;
    }
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _sendMessage() {
    // Implementation for sending message
  }

  void _viewStats() {
    // Implementation for viewing detailed stats
  }

  void _shareMemberProfile() {
    // Implementation for sharing member profile
  }

  void _exportMemberData() {
    // Implementation for exporting member data
  }

  void _promoteMember() {
    // Implementation for promoting member
  }

  void _suspendMember() {
    // Implementation for suspending member
  }

  void _removeMember() {
    // Implementation for removing member
  }

  void _handleMemberUpdated(MemberData updatedMember) {
    setState(() {
      _memberData = updatedMember;
    });
  }

  MemberData _generateMockMemberData() {
    final joinDate = DateTime.now().subtract(Duration(days: 180));
    return MemberData(
      id: widget.memberId,
      user: UserInfo(
        avatar: 'https://images.unsplash.com/photo-1580000000000?w=200&h=200&fit=crop&crop=face',
        name: 'Nguyễn Văn A',
        username: 'user123',
        rank: RankType.intermediate,
        elo: 1450,
        isOnline: true,
      ),
      membershipInfo: MembershipInfo(
        type: MembershipType.vip,
        status: MemberStatus.active,
        joinDate: joinDate,
        membershipId: 'MB1234',
        expiryDate: DateTime.now().add(Duration(days: 365)),
        autoRenewal: true,
      ),
      activityStats: ActivityStats(
        lastActive: DateTime.now().subtract(Duration(minutes: 30)),
        totalMatches: 125,
        tournamentsJoined: 8,
        winRate: 0.68,
        activityScore: 85,
      ),
      engagement: EngagementStats(
        postsCount: 15,
        commentsCount: 48,
        likesReceived: 120,
        socialScore: 75,
      ),
    );
  }
}