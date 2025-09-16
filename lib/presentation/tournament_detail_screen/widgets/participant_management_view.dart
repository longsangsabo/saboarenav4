import 'package:flutter/material.dart';
import 'package:sabo_arena/core/app_export.dart';

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
      duration: Duration(milliseconds: 600),
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

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.h)),
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
      padding: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: appTheme.gray200)),
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
                        fontSize: 18.fSize,
                        fontWeight: FontWeight.bold,
                        color: appTheme.gray900,
                      ),
                    ),
                    Text(
                      "${_participants.length}/${widget.maxParticipants} người chơi",
                      style: TextStyle(
                        fontSize: 12.fSize,
                        color: appTheme.gray600,
                      ),
                    ),
                  ],
                ),
              ),
              
              if (widget.canManage)
                ElevatedButton.icon(
                  onPressed: _showAddParticipantDialog,
                  icon: Icon(Icons.person_add, size: 16.adaptSize),
                  label: Text("Thêm"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appTheme.blue600,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 12.h, vertical: 8.v),
                  ),
                ),
            ],
          ),
          
          SizedBox(height: 12.v),
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
              color: appTheme.gray100,
              borderRadius: BorderRadius.circular(8.h),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Tìm kiếm người chơi...",
                prefixIcon: Icon(Icons.search, color: appTheme.gray500),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12.h, vertical: 8.v),
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
        
        SizedBox(width: 8.h),
        Container(
          decoration: BoxDecoration(
            color: appTheme.gray100,
            borderRadius: BorderRadius.circular(8.h),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedFilter,
              items: [
                DropdownMenuItem(value: 'all', child: Text('Tất cả')),
                DropdownMenuItem(value: 'confirmed', child: Text('Đã xác nhận')),
                DropdownMenuItem(value: 'pending', child: Text('Chờ duyệt')),
                DropdownMenuItem(value: 'checked_in', child: Text('Đã check-in')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value ?? 'all';
                  _filterParticipants();
                });
              },
              icon: Icon(Icons.filter_list, color: appTheme.gray600),
              style: TextStyle(color: appTheme.gray700, fontSize: 12.fSize),
              padding: EdgeInsets.symmetric(horizontal: 8.h),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: appTheme.gray200)),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: appTheme.blue600,
        unselectedLabelColor: appTheme.gray600,
        indicatorColor: appTheme.blue600,
        tabs: [
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
          CircularProgressIndicator(color: appTheme.blue600),
          SizedBox(height: 16.v),
          Text(
            "Đang tải danh sách...",
            style: TextStyle(
              fontSize: 14.fSize,
              color: appTheme.gray600,
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
      padding: EdgeInsets.all(16.h),
      itemCount: _filteredParticipants.length,
      itemBuilder: (context, index) {
        final participant = _filteredParticipants[index];
        return _buildParticipantCard(participant);
      },
    );
  }

  Widget _buildParticipantCard(TournamentParticipant participant) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.v),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.h),
        border: Border.all(color: appTheme.gray200),
        boxShadow: [
          BoxShadow(
            color: appTheme.black900.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(12.h),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 24.adaptSize,
              backgroundImage: NetworkImage(participant.avatarUrl),
              backgroundColor: appTheme.gray200,
            ),
            
            SizedBox(width: 12.h),
            
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
                            fontSize: 14.fSize,
                            fontWeight: FontWeight.w600,
                            color: appTheme.gray900,
                          ),
                        ),
                      ),
                      _buildStatusChip(participant.status),
                    ],
                  ),
                  
                  SizedBox(height: 4.v),
                  Row(
                    children: [
                      Icon(Icons.star, size: 12.adaptSize, color: appTheme.orange600),
                      SizedBox(width: 4.h),
                      Text(
                        "Rank ${participant.rank}",
                        style: TextStyle(
                          fontSize: 12.fSize,
                          color: appTheme.gray600,
                        ),
                      ),
                      
                      SizedBox(width: 12.h),
                      Icon(Icons.access_time, size: 12.adaptSize, color: appTheme.gray500),
                      SizedBox(width: 4.h),
                      Text(
                        _formatRegistrationTime(participant.registeredAt),
                        style: TextStyle(
                          fontSize: 11.fSize,
                          color: appTheme.gray500,
                        ),
                      ),
                    ],
                  ),
                  
                  if (participant.club != null) ...[
                    SizedBox(height: 4.v),
                    Row(
                      children: [
                        Icon(Icons.group, size: 12.adaptSize, color: appTheme.blue600),
                        SizedBox(width: 4.h),
                        Text(
                          participant.club!,
                          style: TextStyle(
                            fontSize: 11.fSize,
                            color: appTheme.blue600,
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
                icon: Icon(Icons.more_vert, color: appTheme.gray600),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'view',
                    child: Row(
                      children: [
                        Icon(Icons.visibility, size: 16.adaptSize),
                        SizedBox(width: 8.h),
                        Text("Xem hồ sơ"),
                      ],
                    ),
                  ),
                  if (participant.status == 'pending')
                    PopupMenuItem(
                      value: 'approve',
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, size: 16.adaptSize, color: appTheme.green600),
                          SizedBox(width: 8.h),
                          Text("Duyệt"),
                        ],
                      ),
                    ),
                  PopupMenuItem(
                    value: 'remove',
                    child: Row(
                      children: [
                        Icon(Icons.remove_circle, size: 16.adaptSize, color: appTheme.red600),
                        SizedBox(width: 8.h),
                        Text("Loại bỏ"),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) => _handleParticipantAction(participant, value),
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
        color = appTheme.green600;
        label = 'Đã xác nhận';
        break;
      case 'pending':
        color = appTheme.orange600;
        label = 'Chờ duyệt';
        break;
      case 'checked_in':
        color = appTheme.blue600;
        label = 'Đã check-in';
        break;
      case 'eliminated':
        color = appTheme.red600;
        label = 'Bị loại';
        break;
      default:
        color = appTheme.gray600;
        label = 'Không rõ';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.h, vertical: 2.v),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.h),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.fSize,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  Widget _buildStatisticsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.h),
      child: Column(
        children: [
          _buildRegistrationChart(),
          SizedBox(height: 16.v),
          _buildRankDistribution(),
          SizedBox(height: 16.v),
          _buildClubRepresentation(),
        ],
      ),
    );
  }

  Widget _buildRegistrationChart() {
    return Container(
      padding: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.h),
        border: Border.all(color: appTheme.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Đăng ký theo thời gian",
            style: TextStyle(
              fontSize: 16.fSize,
              fontWeight: FontWeight.bold,
              color: appTheme.gray900,
            ),
          ),
          SizedBox(height: 16.v),
          
          // Mock chart representation
          SizedBox(
            height: 120.v,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(7, (index) {
                final height = (index + 1) * 15.0 + 20;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 20.h,
                      height: height,
                      decoration: BoxDecoration(
                        color: appTheme.blue600,
                        borderRadius: BorderRadius.circular(4.h),
                      ),
                    ),
                    SizedBox(height: 4.v),
                    Text(
                      'T${index + 2}',
                      style: TextStyle(fontSize: 10.fSize, color: appTheme.gray600),
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
      {'range': 'Dưới 1000', 'count': 3, 'color': appTheme.red600},
      {'range': '1000-1500', 'count': 8, 'color': appTheme.orange600},
      {'range': '1500-2000', 'count': 5, 'color': appTheme.blue600},
      {'range': 'Trên 2000', 'count': 2, 'color': appTheme.green600},
    ];

    return Container(
      padding: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.h),
        border: Border.all(color: appTheme.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Phân bổ theo rank",
            style: TextStyle(
              fontSize: 16.fSize,
              fontWeight: FontWeight.bold,
              color: appTheme.gray900,
            ),
          ),
          SizedBox(height: 12.v),
          
          ...rankData.map((data) => Padding(
            padding: EdgeInsets.only(bottom: 8.v),
            child: Row(
              children: [
                Container(
                  width: 12.h,
                  height: 12.v,
                  decoration: BoxDecoration(
                    color: data['color'] as Color,
                    borderRadius: BorderRadius.circular(2.h),
                  ),
                ),
                SizedBox(width: 8.h),
                
                Expanded(
                  child: Text(
                    data['range'] as String,
                    style: TextStyle(fontSize: 13.fSize, color: appTheme.gray700),
                  ),
                ),
                
                Text(
                  "${data['count']} người",
                  style: TextStyle(
                    fontSize: 13.fSize,
                    fontWeight: FontWeight.w600,
                    color: appTheme.gray900,
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
      padding: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.h),
        border: Border.all(color: appTheme.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Đại diện các club",
            style: TextStyle(
              fontSize: 16.fSize,
              fontWeight: FontWeight.bold,
              color: appTheme.gray900,
            ),
          ),
          SizedBox(height: 12.v),
          
          ...clubData.map((club) => Padding(
            padding: EdgeInsets.only(bottom: 8.v),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    club['name'] as String,
                    style: TextStyle(fontSize: 13.fSize, color: appTheme.gray700),
                  ),
                ),
                Text(
                  "${club['count']} người",
                  style: TextStyle(
                    fontSize: 13.fSize,
                    fontWeight: FontWeight.w600,
                    color: appTheme.blue600,
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
      padding: EdgeInsets.all(16.h),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        return _buildActivityItem(activity);
      },
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.v),
      padding: EdgeInsets.all(12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.h),
        border: Border.all(color: appTheme.gray200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16.adaptSize,
            backgroundImage: NetworkImage(activity['avatar']),
            backgroundColor: appTheme.gray200,
          ),
          
          SizedBox(width: 12.h),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['title'],
                  style: TextStyle(
                    fontSize: 13.fSize,
                    fontWeight: FontWeight.w600,
                    color: appTheme.gray900,
                  ),
                ),
                Text(
                  activity['time'],
                  style: TextStyle(
                    fontSize: 11.fSize,
                    color: appTheme.gray500,
                  ),
                ),
              ],
            ),
          ),
          
          Icon(
            activity['icon'],
            color: activity['color'],
            size: 16.adaptSize,
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
          Icon(Icons.people_outline, size: 64.adaptSize, color: appTheme.gray400),
          SizedBox(height: 16.v),
          Text(
            "Chưa có người chơi nào",
            style: TextStyle(
              fontSize: 16.fSize,
              fontWeight: FontWeight.w600,
              color: appTheme.gray600,
            ),
          ),
          SizedBox(height: 8.v),
          Text(
            _searchQuery.isNotEmpty 
              ? "Không tìm thấy kết quả phù hợp"
              : "Hãy mời người chơi tham gia giải đấu",
            style: TextStyle(
              fontSize: 14.fSize,
              color: appTheme.gray500,
            ),
          ),
        ],
      ),
    );
  }

  void _filterParticipants() {
    setState(() {
      _filteredParticipants = _participants.where((participant) {
        final matchesSearch = _searchQuery.isEmpty || 
          participant.name.toLowerCase().contains(_searchQuery.toLowerCase());
        
        final matchesFilter = _selectedFilter == 'all' || 
          participant.status == _selectedFilter;
        
        return matchesSearch && matchesFilter;
      }).toList();
    });
  }

  void _showAddParticipantDialog() {
    // Implementation for adding participant
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Thêm người chơi"),
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

  void _handleParticipantAction(TournamentParticipant participant, String action) {
    // Implementation for participant actions
    switch (action) {
      case 'view':
        // Show participant profile
        break;
      case 'approve':
        // Approve participant
        break;
      case 'remove':
        // Remove participant
        break;
    }
  }

  String _formatRegistrationTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inDays > 0) {
      return "${difference.inDays} ngày trước";
    } else if (difference.inHours > 0) {
      return "${difference.inHours} giờ trước";
    } else {
      return "${difference.inMinutes} phút trước";
    }
  }

  List<TournamentParticipant> _generateMockParticipants() {
    final names = [
      'Nguyễn Văn A', 'Lê Văn B', 'Trần Văn C', 'Phạm Văn D',
      'Hoàng Văn E', 'Vũ Văn F', 'Đinh Văn G', 'Bùi Văn H',
      'Đỗ Văn I', 'Hồ Văn J', 'Lý Văn K', 'Mai Văn L',
      'Phan Văn M', 'Tô Văn N', 'Lâm Văn O', 'Đặng Văn P',
      'Dương Văn Q', 'Cao Văn R'
    ];
    
    final statuses = ['confirmed', 'pending', 'checked_in', 'confirmed'];
    final clubs = ['Saigon Ping Pong', 'Hanoi TT Club', 'Da Nang Sports', null];
    
    return List.generate(names.length, (index) {
      return TournamentParticipant(
        id: 'p_${index + 1}',
        name: names[index],
        avatarUrl: 'https://images.unsplash.com/photo-${1580000000000 + index}?w=100&h=100&fit=crop&crop=face',
        rank: 800 + (index * 150) + (index % 3) * 50,
        status: statuses[index % statuses.length],
        club: clubs[index % clubs.length],
        registeredAt: DateTime.now().subtract(Duration(days: index + 1, hours: index * 2)),
      );
    });
  }

  List<Map<String, dynamic>> _getMockActivities() {
    return [
      {
        'title': 'Nguyễn Văn A đã đăng ký tham gia',
        'time': '2 phút trước',
        'avatar': 'https://images.unsplash.com/photo-1580000000001?w=50&h=50&fit=crop&crop=face',
        'icon': Icons.person_add,
        'color': appTheme.green600,
      },
      {
        'title': 'Lê Văn B đã check-in',
        'time': '15 phút trước',
        'avatar': 'https://images.unsplash.com/photo-1580000000002?w=50&h=50&fit=crop&crop=face',
        'icon': Icons.check_circle,
        'color': appTheme.blue600,
      },
      {
        'title': 'Trần Văn C đã được duyệt tham gia',
        'time': '30 phút trước',
        'avatar': 'https://images.unsplash.com/photo-1580000000003?w=50&h=50&fit=crop&crop=face',
        'icon': Icons.approval,
        'color': appTheme.orange600,
      },
    ];
  }
}

class TournamentParticipant {
  final String id;
  final String name;
  final String avatarUrl;
  final int rank;
  final String status; // confirmed, pending, checked_in, eliminated
  final String? club;
  final DateTime registeredAt;

  TournamentParticipant({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.rank,
    required this.status,
    this.club,
    required this.registeredAt,
  });
}