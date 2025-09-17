import 'package:flutter/material.dart';
import 'package:sabo_arena/core/app_export.dart';
import 'package:sizer/sizer.dart';
import 'package:sabo_arena/theme/app_theme.dart';

// Define the missing data model for a tournament participant.
class TournamentParticipant {
  final String id;
  final String name;
  final String avatarUrl;
  final int rank;
  final String status;
  final DateTime registeredAt;
  final String? club;

  TournamentParticipant({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.rank,
    required this.status,
    required this.registeredAt,
    this.club,
  });
}

class ParticipantManagementView extends StatefulWidget {
  final String tournamentId;
  final String tournamentStatus;
  final int maxParticipants;
  final bool canManage;

  const ParticipantManagementView({
    super.key,
    required this.tournamentId,
    required this.tournamentStatus,
    required this.maxParticipants,
    this.canManage = false,
  });

  @override
  _ParticipantManagementViewState createState() => _ParticipantManagementViewState();
}

class _ParticipantManagementViewState extends State<ParticipantManagementView>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'all';
  
  List<TournamentParticipant> _participants = [];
  List<TournamentParticipant> _filteredParticipants = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    
    _tabController = TabController(length: 3, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _loadParticipants();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadParticipants() async {
    // Simulate data loading
    await Future.delayed(Duration(milliseconds: 1000));
    
    setState(() {
      _participants = _generateMockParticipants();
      _filteredParticipants = _participants;
      _isLoading = false;
    });
    
    _animationController.forward();
  }

  // Add the missing mock data generation function.
  List<TournamentParticipant> _generateMockParticipants() {
    return List.generate(18, (index) {
      final statuses = ['confirmed', 'pending', 'checked_in', 'eliminated'];
      return TournamentParticipant(
        id: 'user_$index',
        name: 'Cơ thủ ${index + 1}',
        avatarUrl: 'https://i.pravatar.cc/150?img=$index',
        rank: 1200 + (index * 50),
        status: statuses[index % statuses.length],
        registeredAt: DateTime.now().subtract(Duration(days: index)),
        club: index % 3 == 0 ? 'CLB Bida Sài Gòn' : null,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.sp)),
      ),
      child: Column(
        children: [
          _buildHeader(),
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
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Quản lý người chơi",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryLight,
                      ),
                    ),
                    Text(
                      "${_participants.length}/${widget.maxParticipants} người chơi",
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
                  onPressed: _showAddParticipantDialog,
                  icon: Icon(Icons.person_add, size: 16.sp),
                  label: const Text("Thêm"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryLight,
                    foregroundColor: Colors.white,
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.sp, vertical: 8.sp),
                  ),
                ),
            ],
          ),
          
          SizedBox(height: 12.sp),
          _buildSearchAndFilter(),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.backgroundLight,
              borderRadius: BorderRadius.circular(8.sp),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Tìm kiếm người chơi...",
                prefixIcon: Icon(Icons.search, color: AppTheme.textDisabledLight),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12.sp, vertical: 8.sp),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _filterParticipants();
                });
              },
            ),
          ),
        ),
        
        SizedBox(width: 8.sp),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.backgroundLight,
            borderRadius: BorderRadius.circular(8.sp),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedFilter,
              items: const [
                DropdownMenuItem(value: 'all', child: Text('Tất cả')),
                DropdownMenuItem(
                    value: 'confirmed', child: Text('Đã xác nhận')),
                DropdownMenuItem(value: 'pending', child: Text('Chờ duyệt')),
                DropdownMenuItem(
                    value: 'checked_in', child: Text('Đã check-in')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value ?? 'all';
                  _filterParticipants();
                });
              },
              icon: Icon(Icons.filter_list, color: AppTheme.textSecondaryLight),
              style: TextStyle(color: AppTheme.textSecondaryLight, fontSize: 12.sp),
              padding: EdgeInsets.symmetric(horizontal: 8.sp),
            ),
          ),
        ),
      ],
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
        tabs: const [
          Tab(text: 'Danh sách'),
          Tab(text: 'Thống kê'),
          Tab(text: 'Hoạt động'),
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
            "Đang tải danh sách...",
            style: TextStyle(
              fontSize: 14.sp,
              color: AppTheme.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildParticipantList(),
              _buildStatisticsTab(),
              _buildActivityTab(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildParticipantList() {
    if (_filteredParticipants.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.sp),
      itemCount: _filteredParticipants.length,
      itemBuilder: (context, index) {
        final participant = _filteredParticipants[index];
        return _buildParticipantCard(participant);
      },
    );
  }

  Widget _buildParticipantCard(TournamentParticipant participant) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.sp),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.sp),
        border: Border.all(color: AppTheme.dividerLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(12.sp),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 24.sp,
              backgroundImage: NetworkImage(participant.avatarUrl),
              backgroundColor: AppTheme.backgroundLight,
            ),

            SizedBox(width: 12.sp),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          participant.name,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimaryLight,
                          ),
                        ),
                      ),
                      _buildStatusChip(participant.status),
                    ],
                  ),
                  
                  SizedBox(height: 4.sp),
                  Row(
                    children: [
                      Icon(Icons.star, size: 12.sp, color: AppTheme.accentLight),
                      SizedBox(width: 4.sp),
                      Text(
                        "Rank ${participant.rank}",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppTheme.textSecondaryLight,
                        ),
                      ),
                      
                      SizedBox(width: 12.sp),
                      Icon(Icons.access_time,
                          size: 12.sp, color: AppTheme.textDisabledLight),
                      SizedBox(width: 4.sp),
                      Text(
                        _formatRegistrationTime(participant.registeredAt),
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppTheme.textDisabledLight,
                        ),
                      ),
                    ],
                  ),
                  
                  if (participant.club != null) ...[
                    SizedBox(height: 4.sp),
                    Row(
                      children: [
                        Icon(Icons.group, size: 12.sp, color: AppTheme.primaryLight),
                        SizedBox(width: 4.sp),
                        Text(
                          participant.club!,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppTheme.primaryLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            
            // Actions
            if (widget.canManage)
              PopupMenuButton(
                icon: Icon(Icons.more_vert, color: AppTheme.textSecondaryLight),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'view',
                    child: Row(
                      children: [
                        Icon(Icons.visibility, size: 16.sp),
                        SizedBox(width: 8.sp),
                        const Text("Xem hồ sơ"),
                      ],
                    ),
                  ),
                  if (participant.status == 'pending')
                    PopupMenuItem(
                      value: 'approve',
                      child: Row(
                        children: [
                          Icon(Icons.check_circle,
                              size: 16.sp, color: AppTheme.successLight),
                          SizedBox(width: 8.sp),
                          const Text("Duyệt"),
                        ],
                      ),
                    ),
                  PopupMenuItem(
                    value: 'remove',
                    child: Row(
                      children: [
                        Icon(Icons.remove_circle,
                            size: 16.sp, color: AppTheme.errorLight),
                        SizedBox(width: 8.sp),
                        const Text("Loại bỏ"),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) =>
                    _handleParticipantAction(participant, value),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;
    
    switch (status) {
      case 'confirmed':
        color = AppTheme.successLight;
        label = 'Đã xác nhận';
        break;
      case 'pending':
        color = AppTheme.warningLight;
        label = 'Chờ duyệt';
        break;
      case 'checked_in':
        color = AppTheme.primaryLight;
        label = 'Đã check-in';
        break;
      case 'eliminated':
        color = AppTheme.errorLight;
        label = 'Bị loại';
        break;
      default:
        color = AppTheme.textSecondaryLight;
        label = 'Không rõ';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.sp, vertical: 2.sp),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.sp),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  Widget _buildStatisticsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.sp),
      child: Column(
        children: [
          _buildRegistrationChart(),
          SizedBox(height: 16.sp),
          _buildRankDistribution(),
          SizedBox(height: 16.sp),
          _buildClubRepresentation(),
        ],
      ),
    );
  }

  Widget _buildRegistrationChart() {
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
            "Đăng ký theo thời gian",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryLight,
            ),
          ),
          SizedBox(height: 16.sp),
          
          // Mock chart representation
          SizedBox(
            height: 120.sp,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(7, (index) {
                final height = (index + 1) * 15.0 + 20;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 20.sp,
                      height: height,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(4.sp),
                      ),
                    ),
                    SizedBox(height: 4.sp),
                    Text(
                      'T${index + 2}',
                      style: TextStyle(
                          fontSize: 10.sp, color: AppTheme.textSecondaryLight),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankDistribution() {
    final rankData = [
      {'range': 'Dưới 1000', 'count': 3, 'color': AppTheme.errorLight},
      {'range': '1000-1500', 'count': 8, 'color': AppTheme.accentLight},
      {'range': '1500-2000', 'count': 5, 'color': AppTheme.primaryLight},
      {'range': 'Trên 2000', 'count': 2, 'color': AppTheme.successLight},
    ];

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
            "Phân bổ theo rank",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryLight,
            ),
          ),
          SizedBox(height: 12.sp),
          
          ...rankData.map((data) => Padding(
            padding: EdgeInsets.only(bottom: 8.sp),
            child: Row(
              children: [
                Container(
                  width: 12.sp,
                  height: 12.sp,
                  decoration: BoxDecoration(
                    color: data['color'] as Color,
                    borderRadius: BorderRadius.circular(2.sp),
                  ),
                ),
                SizedBox(width: 8.sp),
                
                Expanded(
                  child: Text(
                    data['range'] as String,
                    style: TextStyle(
                        fontSize: 13.sp, color: AppTheme.textSecondaryLight),
                  ),
                ),
                
                Text(
                  "${data['count']} người",
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryLight,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildClubRepresentation() {
    final clubData = [
      {'name': 'Saigon Ping Pong', 'count': 8},
      {'name': 'Hanoi TT Club', 'count': 5},
      {'name': 'Da Nang Sports', 'count': 3},
      {'name': 'Cá nhân', 'count': 2},
    ];

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
            "Đại diện các club",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryLight,
            ),
          ),
          SizedBox(height: 12.sp),
          
          ...clubData.map((club) => Padding(
            padding: EdgeInsets.only(bottom: 8.sp),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    club['name'] as String,
                    style: TextStyle(
                        fontSize: 13.sp, color: AppTheme.textSecondaryLight),
                  ),
                ),
                Text(
                  "${club['count']} người",
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryLight,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildActivityTab() {
    final activities = _getMockActivities();
    
    return ListView.builder(
      padding: EdgeInsets.all(16.sp),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        return _buildActivityItem(activity);
      },
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.sp),
      padding: EdgeInsets.all(12.sp),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.sp),
        border: Border.all(color: AppTheme.dividerLight),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16.sp,
            backgroundImage: NetworkImage(activity['avatar']),
            backgroundColor: AppTheme.backgroundLight,
          ),

          SizedBox(width: 12.sp),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppTheme.textSecondaryLight,
                      fontFamily: 'Roboto',
                    ),
                    children: [
                      TextSpan(
                        text: activity['message'].replaceAll(RegExp(r'<strong>|<\/strong>'), ''),
                        style: TextStyle(color: AppTheme.textPrimaryLight),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 2.sp),
                Text(
                  activity['time'],
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppTheme.textDisabledLight,
                  ),
                ),
              ],
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
          Icon(Icons.group_off, size: 64.sp, color: AppTheme.textDisabledLight),
          SizedBox(height: 16.sp),
          Text(
            "Không tìm thấy người chơi",
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8.sp),
          Text(
            "Thử thay đổi bộ lọc hoặc từ khóa tìm kiếm.",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondaryLight),
          ),
        ],
      ),
    );
  }

  void _filterParticipants() {
    setState(() {
      _filteredParticipants = _participants.where((p) {
        final matchesQuery = p.name.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesFilter = _selectedFilter == 'all' || p.status == _selectedFilter;
        return matchesQuery && matchesFilter;
      }).toList();
    });
  }

  void _showAddParticipantDialog() {
    // Placeholder for showing a dialog to add a new participant.
  }

  void _handleParticipantAction(TournamentParticipant participant, String action) {
    // Placeholder for handling actions like 'view', 'approve', 'remove'.
  }

  String _formatRegistrationTime(DateTime time) {
    final difference = DateTime.now().difference(time);
    if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else {
      return '${difference.inMinutes} phút trước';
    }
  }

  List<Map<String, dynamic>> _getMockActivities() {
    return [
      {
        'avatar': 'https://i.pravatar.cc/150?img=1',
        'message': '<strong>Cơ thủ 2</strong> đã được duyệt.',
        'time': '5 phút trước',
      },
      {
        'avatar': 'https://i.pravatar.cc/150?img=3',
        'message': '<strong>Cơ thủ 4</strong> đã đăng ký.',
        'time': '1 giờ trước',
      },
      {
        'avatar': 'https://i.pravatar.cc/150?img=5',
        'message': '<strong>Cơ thủ 6</strong> đã bị loại.',
        'time': '3 giờ trước',
      }
    ];
  }
}