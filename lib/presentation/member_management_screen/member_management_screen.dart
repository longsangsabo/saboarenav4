import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import 'widgets/member_search_bar.dart';
import 'widgets/member_filter_section.dart';
import 'widgets/member_list_view.dart';
import 'widgets/member_analytics_card.dart';
import 'widgets/bulk_action_bar.dart';
import 'widgets/add_member_dialog.dart';

class MemberManagementScreen extends StatefulWidget {
  final String clubId;

  const MemberManagementScreen({
    Key? key,
    required this.clubId,
  }) : super(key: key);

  @override
  _MemberManagementScreenState createState() => _MemberManagementScreenState();
}

class _MemberManagementScreenState extends State<MemberManagementScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late TabController _filterTabController;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'all';
  bool _showAdvancedFilters = false;
  List<String> _selectedMembers = [];
  
  // Mock data - replace with actual API calls
  List<MemberData> _allMembers = [];
  List<MemberData> _filteredMembers = [];
  MemberAnalytics _analytics = MemberAnalytics(
    memberGrowth: GrowthData(thisMonth: 15, lastMonth: 12, growthRate: 25.0),
    activityRate: ActivityRate(active: 78, inactive: 22, percentage: 78.0),
    retentionRate: RetentionRate(rate: 85.5, trend: 'up'),
  );
  
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _filterTabController = TabController(length: 5, vsync: this);
    _animationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut)
    );

    _loadMemberData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _filterTabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMemberData() async {
    // Simulate loading
    await Future.delayed(Duration(milliseconds: 800));
    
    setState(() {
      _allMembers = _generateMockMembers();
      _filteredMembers = _allMembers;
      _isLoading = false;
    });
    
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: _isLoading ? _buildLoadingState() : _buildMainContent(),
      bottomNavigationBar: CustomBottomBar(
        currentRoute: '/member-management',
        onTap: _handleBottomNavTap,
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return CustomAppBar(
      title: 'Quản lý thành viên',
      actions: [
        Badge(
          isLabelVisible: _selectedMembers.isNotEmpty,
          label: Text('${_selectedMembers.length}'),
          child: IconButton(
            icon: Icon(Icons.checklist),
            onPressed: () => setState(() => _selectedMembers.clear()),
            tooltip: 'Clear selection',
          ),
        ),
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'export',
              child: Row(
                children: [
                  Icon(Icons.file_download, size: 20),
                  SizedBox(width: 8),
                  Text('Xuất danh sách'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'import',
              child: Row(
                children: [
                  Icon(Icons.file_upload, size: 20),
                  SizedBox(width: 8),
                  Text('Nhập thành viên'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings, size: 20),
                  SizedBox(width: 8),
                  Text('Cài đặt'),
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
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
          SizedBox(height: 16),
          Text(
            'Đang tải danh sách thành viên...',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Column(
            children: [
              // Analytics section
              Container(
                padding: EdgeInsets.all(16),
                color: AppTheme.lightTheme.colorScheme.surface,
                child: MemberAnalyticsCard(analytics: _analytics),
              ),
              
              // Search and filter section
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  border: Border(
                    bottom: BorderSide(
                      color: AppTheme.lightTheme.colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    MemberSearchBar(
                      controller: _searchController,
                      onChanged: _handleSearchChanged,
                      onFilterTap: _toggleAdvancedFilters,
                      showFilterIndicator: _showAdvancedFilters,
                    ),
                    
                    SizedBox(height: 12),
                    
                    MemberFilterSection(
                      controller: _filterTabController,
                      selectedFilter: _selectedFilter,
                      onFilterChanged: _handleFilterChanged,
                      memberCounts: _getFilterCounts(),
                      showAdvanced: _showAdvancedFilters,
                      onAdvancedFiltersChanged: _handleAdvancedFiltersChanged,
                    ),
                  ],
                ),
              ),
              
              // Bulk actions bar
              if (_selectedMembers.isNotEmpty)
                BulkActionBar(
                  selectedCount: _selectedMembers.length,
                  onAction: _handleBulkAction,
                  onClear: () => setState(() => _selectedMembers.clear()),
                ),
              
              // Member list
              Expanded(
                child: MemberListView(
                  members: _filteredMembers,
                  selectedMembers: _selectedMembers,
                  onMemberSelected: _handleMemberSelection,
                  onMemberAction: _handleMemberAction,
                  onRefresh: _handleRefresh,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _showAddMemberDialog,
      icon: Icon(Icons.person_add),
      label: Text('Thêm thành viên'),
      backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      foregroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
    );
  }

  void _handleSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _filterMembers();
    });
  }

  void _handleFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
      _filterMembers();
    });
  }

  void _toggleAdvancedFilters() {
    setState(() {
      _showAdvancedFilters = !_showAdvancedFilters;
    });
  }

  void _handleAdvancedFiltersChanged(AdvancedFilters filters) {
    // Apply advanced filters
    _filterMembers();
  }

  void _handleMemberSelection(String memberId, bool selected) {
    setState(() {
      if (selected) {
        _selectedMembers.add(memberId);
      } else {
        _selectedMembers.remove(memberId);
      }
    });
  }

  void _handleMemberAction(String action, String memberId) {
    switch (action) {
      case 'view-profile':
        _navigateToMemberDetail(memberId);
        break;
      case 'message':
        _showMessageDialog(memberId);
        break;
      case 'view-stats':
        _showMemberStats(memberId);
        break;
      case 'more':
        _showMemberMoreActions(memberId);
        break;
    }
  }

  void _handleBulkAction(String action) {
    switch (action) {
      case 'message':
        _showBulkMessageDialog();
        break;
      case 'promote':
        _showBulkPromoteDialog();
        break;
      case 'export':
        _exportSelectedMembers();
        break;
      case 'remove':
        _showBulkRemoveDialog();
        break;
    }
  }

  Future<void> _handleRefresh() async {
    await _loadMemberData();
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'export':
        _exportAllMembers();
        break;
      case 'import':
        _showImportDialog();
        break;
      case 'settings':
        _navigateToMemberSettings();
        break;
    }
  }

  void _filterMembers() {
    setState(() {
      _filteredMembers = _allMembers.where((member) {
        // Text search
        final matchesSearch = _searchQuery.isEmpty ||
          member.user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          member.user.username.toLowerCase().contains(_searchQuery.toLowerCase());

        // Status filter
        final matchesStatus = _selectedFilter == 'all' ||
          (_selectedFilter == 'active' && member.membershipInfo.status == MemberStatus.active) ||
          (_selectedFilter == 'new' && _isNewMember(member)) ||
          (_selectedFilter == 'inactive' && member.membershipInfo.status == MemberStatus.inactive) ||
          (_selectedFilter == 'pending' && member.membershipInfo.status == MemberStatus.pending);

        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  Map<String, int> _getFilterCounts() {
    return {
      'all': _allMembers.length,
      'active': _allMembers.where((m) => m.membershipInfo.status == MemberStatus.active).length,
      'new': _allMembers.where((m) => _isNewMember(m)).length,
      'inactive': _allMembers.where((m) => m.membershipInfo.status == MemberStatus.inactive).length,
      'pending': _allMembers.where((m) => m.membershipInfo.status == MemberStatus.pending).length,
    };
  }

  bool _isNewMember(MemberData member) {
    final now = DateTime.now();
    final joinDate = member.membershipInfo.joinDate;
    return now.difference(joinDate).inDays <= 30;
  }

  void _showAddMemberDialog() {
    showDialog(
      context: context,
      builder: (context) => AddMemberDialog(
        clubId: widget.clubId,
        onMemberAdded: (member) {
          setState(() {
            _allMembers.insert(0, member);
            _filterMembers();
          });
        },
      ),
    );
  }

  void _navigateToMemberDetail(String memberId) {
    Navigator.pushNamed(
      context,
      '/member-detail',
      arguments: {'clubId': widget.clubId, 'memberId': memberId},
    );
  }

  void _showMessageDialog(String memberId) {
    // Implementation for single member message
  }

  void _showMemberStats(String memberId) {
    // Implementation for member statistics
  }

  void _showMemberMoreActions(String memberId) {
    // Implementation for more member actions
  }

  void _showBulkMessageDialog() {
    // Implementation for bulk messaging
  }

  void _showBulkPromoteDialog() {
    // Implementation for bulk promotion
  }

  void _exportSelectedMembers() {
    // Implementation for exporting selected members
  }

  void _showBulkRemoveDialog() {
    // Implementation for bulk removal
  }

  void _exportAllMembers() {
    // Implementation for exporting all members
  }

  void _showImportDialog() {
    // Implementation for member import
  }

  void _navigateToMemberSettings() {
    Navigator.pushNamed(context, '/member-settings');
  }

  void _handleBottomNavTap(String route) {
    if (route != '/member-management') {
      Navigator.pushReplacementNamed(context, route);
    }
  }

  List<MemberData> _generateMockMembers() {
    // Generate mock member data - replace with API call
    return List.generate(50, (index) {
      final joinDate = DateTime.now().subtract(Duration(days: index * 10));
      return MemberData(
        id: 'member_$index',
        user: UserInfo(
          avatar: 'https://images.unsplash.com/photo-${1580000000000 + index}?w=100&h=100&fit=crop&crop=face',
          name: 'Thành viên ${index + 1}',
          username: 'member${index + 1}',
          rank: RankType.values[index % RankType.values.length],
          elo: 1000 + (index * 50),
          isOnline: index % 3 == 0,
        ),
        membershipInfo: MembershipInfo(
          type: MembershipType.values[index % MembershipType.values.length],
          status: MemberStatus.values[index % MemberStatus.values.length],
          joinDate: joinDate,
          membershipId: 'MB${1000 + index}',
          autoRenewal: index % 2 == 0,
        ),
        activityStats: ActivityStats(
          lastActive: DateTime.now().subtract(Duration(hours: index % 24)),
          totalMatches: index * 5,
          tournamentsJoined: index % 10,
          winRate: 0.6 + (index % 40) / 100,
          activityScore: 50 + (index % 50),
        ),
        engagement: EngagementStats(
          postsCount: index % 20,
          commentsCount: index % 50,
          likesReceived: index * 10,
          socialScore: index % 100,
        ),
      );
    });
  }
}

// Data models
enum RankType { beginner, amateur, intermediate, advanced, professional }
enum MembershipType { regular, vip, premium }
enum MemberStatus { active, inactive, suspended, pending }

class MemberData {
  final String id;
  final UserInfo user;
  final MembershipInfo membershipInfo;
  final ActivityStats activityStats;
  final EngagementStats engagement;

  MemberData({
    required this.id,
    required this.user,
    required this.membershipInfo,
    required this.activityStats,
    required this.engagement,
  });
}

class UserInfo {
  final String avatar;
  final String name;
  final String username;
  final RankType rank;
  final int elo;
  final bool isOnline;

  UserInfo({
    required this.avatar,
    required this.name,
    required this.username,
    required this.rank,
    required this.elo,
    required this.isOnline,
  });
}

class MembershipInfo {
  final MembershipType type;
  final MemberStatus status;
  final DateTime joinDate;
  final String membershipId;
  final DateTime? expiryDate;
  final bool autoRenewal;

  MembershipInfo({
    required this.type,
    required this.status,
    required this.joinDate,
    required this.membershipId,
    this.expiryDate,
    required this.autoRenewal,
  });
}

class ActivityStats {
  final DateTime lastActive;
  final int totalMatches;
  final int tournamentsJoined;
  final double winRate;
  final int activityScore;

  ActivityStats({
    required this.lastActive,
    required this.totalMatches,
    required this.tournamentsJoined,
    required this.winRate,
    required this.activityScore,
  });
}

class EngagementStats {
  final int postsCount;
  final int commentsCount;
  final int likesReceived;
  final int socialScore;

  EngagementStats({
    required this.postsCount,
    required this.commentsCount,
    required this.likesReceived,
    required this.socialScore,
  });
}

class MemberAnalytics {
  final GrowthData memberGrowth;
  final ActivityRate activityRate;
  final RetentionRate retentionRate;

  MemberAnalytics({
    required this.memberGrowth,
    required this.activityRate,
    required this.retentionRate,
  });
}

class GrowthData {
  final int thisMonth;
  final int lastMonth;
  final double growthRate;

  GrowthData({
    required this.thisMonth,
    required this.lastMonth,
    required this.growthRate,
  });
}

class ActivityRate {
  final int active;
  final int inactive;
  final double percentage;

  ActivityRate({
    required this.active,
    required this.inactive,
    required this.percentage,
  });
}

class RetentionRate {
  final double rate;
  final String trend;

  RetentionRate({
    required this.rate,
    required this.trend,
  });
}

class AdvancedFilters {
  final List<MembershipType> membershipTypes;
  final RankType? minRank;
  final RankType? maxRank;
  final DateTime? joinStartDate;
  final DateTime? joinEndDate;
  final List<String> activityLevels;
  final int? minElo;
  final int? maxElo;

  AdvancedFilters({
    this.membershipTypes = const [],
    this.minRank,
    this.maxRank,
    this.joinStartDate,
    this.joinEndDate,
    this.activityLevels = const [],
    this.minElo,
    this.maxElo,
  });
}