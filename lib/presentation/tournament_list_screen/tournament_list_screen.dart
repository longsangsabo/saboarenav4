import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/tournament_card_widget.dart';
import './widgets/tournament_filter_bottom_sheet.dart';
import './widgets/tournament_search_delegate.dart';

class TournamentListScreen extends StatefulWidget {
  const TournamentListScreen({super.key});

  @override
  State<TournamentListScreen> createState() => _TournamentListScreenState();
}

class _TournamentListScreenState extends State<TournamentListScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  String _selectedTab = 'upcoming';
  Map<String, dynamic> _currentFilters = {
    'locationRadius': 10.0,
    'entryFeeRange': <String>[],
    'formats': <String>[],
    'skillLevels': <String>[],
    'hasLiveStream': false,
    'hasAvailableSlots': false,
    'hasPrizePool': false,
  };

  // Mock tournament data
  final List<Map<String, dynamic>> _allTournaments = [
    {
      'id': 1,
      'title': 'Giải 8-Ball Mùa Xuân 2024',
      'clubName': 'Billiards Club Sài Gòn',
      'format': '8-Ball',
      'entryFee': '200.000 VNĐ',
      'prizePool': '5.000.000 VNĐ',
      'currentParticipants': 24,
      'maxParticipants': 32,
      'startDate': '25/03/2024',
      'startTime': '09:00',
      'registrationDeadline': '20/03/2024',
      'status': 'upcoming',
      'coverImage':
          'https://images.pexels.com/photos/3660204/pexels-photo-3660204.jpeg',
      'isRegistered': false,
      'isBookmarked': true,
      'hasLiveStream': true,
      'skillLevel': 'intermediate',
      'location': 'Quận 1, TP.HCM',
    },
    {
      'id': 2,
      'title': 'Giải 9-Ball Chuyên Nghiệp',
      'clubName': 'Elite Billiards Center',
      'format': '9-Ball',
      'entryFee': '500.000 VNĐ',
      'prizePool': '15.000.000 VNĐ',
      'currentParticipants': 16,
      'maxParticipants': 16,
      'startDate': '28/03/2024',
      'startTime': '14:00',
      'registrationDeadline': '25/03/2024',
      'status': 'live',
      'coverImage':
          'https://images.pexels.com/photos/1040157/pexels-photo-1040157.jpeg',
      'isRegistered': true,
      'isBookmarked': false,
      'hasLiveStream': true,
      'skillLevel': 'professional',
      'location': 'Quận 3, TP.HCM',
    },
    {
      'id': 3,
      'title': 'Giải 10-Ball Cuối Tuần',
      'clubName': 'Weekend Billiards',
      'format': '10-Ball',
      'entryFee': 'Miễn phí',
      'prizePool': null,
      'currentParticipants': 8,
      'maxParticipants': 16,
      'startDate': '30/03/2024',
      'startTime': '10:00',
      'registrationDeadline': '29/03/2024',
      'status': 'upcoming',
      'coverImage':
          'https://images.pexels.com/photos/1040157/pexels-photo-1040157.jpeg',
      'isRegistered': false,
      'isBookmarked': false,
      'hasLiveStream': false,
      'skillLevel': 'beginner',
      'location': 'Quận 7, TP.HCM',
    },
    {
      'id': 4,
      'title': 'Giải 8-Ball Tháng 2',
      'clubName': 'Champion Billiards',
      'format': '8-Ball',
      'entryFee': '300.000 VNĐ',
      'prizePool': '8.000.000 VNĐ',
      'currentParticipants': 32,
      'maxParticipants': 32,
      'startDate': '15/02/2024',
      'startTime': '09:00',
      'registrationDeadline': '10/02/2024',
      'status': 'completed',
      'coverImage':
          'https://images.pexels.com/photos/3660204/pexels-photo-3660204.jpeg',
      'isRegistered': false,
      'isBookmarked': true,
      'hasLiveStream': true,
      'skillLevel': 'advanced',
      'location': 'Quận 1, TP.HCM',
    },
    {
      'id': 5,
      'title': 'Giải 9-Ball Mới Bắt Đầu',
      'clubName': 'Beginner Friendly Club',
      'format': '9-Ball',
      'entryFee': '100.000 VNĐ',
      'prizePool': '2.000.000 VNĐ',
      'currentParticipants': 12,
      'maxParticipants': 24,
      'startDate': '02/04/2024',
      'startTime': '15:00',
      'registrationDeadline': '30/03/2024',
      'status': 'upcoming',
      'coverImage':
          'https://images.pexels.com/photos/1040157/pexels-photo-1040157.jpeg',
      'isRegistered': false,
      'isBookmarked': false,
      'hasLiveStream': false,
      'skillLevel': 'beginner',
      'location': 'Quận 5, TP.HCM',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;

    setState(() {
      switch (_tabController.index) {
        case 0:
          _selectedTab = 'upcoming';
          break;
        case 1:
          _selectedTab = 'live';
          break;
        case 2:
          _selectedTab = 'completed';
          break;
      }
    });
  }

  List<Map<String, dynamic>> get _filteredTournaments {
    return _allTournaments.where((tournament) {
      // Filter by status
      if (tournament['status'] != _selectedTab) return false;

      // Apply other filters
      final formats = _currentFilters['formats'] as List<String>;
      if (formats.isNotEmpty &&
          !formats.contains(tournament['format'].toString().toLowerCase())) {
        return false;
      }

      final skillLevels = _currentFilters['skillLevels'] as List<String>;
      if (skillLevels.isNotEmpty &&
          !skillLevels.contains(tournament['skillLevel'])) {
        return false;
      }

      if (_currentFilters['hasLiveStream'] == true &&
          tournament['hasLiveStream'] != true) {
        return false;
      }

      if (_currentFilters['hasAvailableSlots'] == true) {
        final current = tournament['currentParticipants'] as int;
        final max = tournament['maxParticipants'] as int;
        if (current >= max) return false;
      }

      if (_currentFilters['hasPrizePool'] == true &&
          tournament['prizePool'] == null) {
        return false;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 1,
        title: Text(
          'Giải đấu',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showSearch,
            icon: CustomIconWidget(
              iconName: 'search',
              color: colorScheme.onSurface,
              size: 24,
            ),
            tooltip: 'Tìm kiếm',
          ),
          SizedBox(width: 2.w),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Sắp diễn ra'),
            Tab(text: 'Đang diễn ra'),
            Tab(text: 'Đã kết thúc'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Filter summary
          if (_hasActiveFilters()) _buildFilterSummary(context),

          // Tournament list
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshTournaments,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTournamentList(context),
                  _buildTournamentList(context),
                  _buildTournamentList(context),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showFilterBottomSheet,
        tooltip: 'Bộ lọc',
        child: CustomIconWidget(
          iconName: 'filter_list',
          color: colorScheme.onPrimary,
          size: 24,
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentRoute: '/tournament-list-screen',
        onTap: _onBottomNavTap,
      ),
    );
  }

  Widget _buildFilterSummary(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.1),
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'filter_list',
            color: colorScheme.primary,
            size: 16,
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              'Đang áp dụng bộ lọc',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: _clearFilters,
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Xóa bộ lọc',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTournamentList(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final tournaments = _filteredTournaments;

    if (tournaments.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      padding: EdgeInsets.only(
        top: 1.h,
        bottom: 10.h, // Space for FAB
      ),
      itemCount: tournaments.length,
      itemBuilder: (context, index) {
        final tournament = tournaments[index];
        return TournamentCardWidget(
          tournament: tournament,
          onTap: () => _navigateToTournamentDetail(tournament),
          onBookmark: () => _toggleBookmark(tournament),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    String title;
    String subtitle;
    String iconName;

    switch (_selectedTab) {
      case 'live':
        title = 'Không có giải đấu đang diễn ra';
        subtitle = 'Hãy theo dõi để không bỏ lỡ các giải đấu sắp tới';
        iconName = 'live_tv';
        break;
      case 'completed':
        title = 'Chưa có giải đấu nào kết thúc';
        subtitle = 'Các giải đấu đã hoàn thành sẽ hiển thị ở đây';
        iconName = 'emoji_events';
        break;
      default:
        title = 'Không có giải đấu sắp diễn ra';
        subtitle = 'Hãy tạo giải đấu mới hoặc tham gia các câu lạc bộ';
        iconName = 'event';
    }

    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: iconName,
              color: colorScheme.onSurfaceVariant,
              size: 64,
            ),
            SizedBox(height: 3.h),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (_selectedTab == 'upcoming') ...[
              SizedBox(height: 3.h),
              ElevatedButton.icon(
                onPressed: () => _navigateToClubProfile(),
                icon: CustomIconWidget(
                  iconName: 'add',
                  color: colorScheme.onPrimary,
                  size: 20,
                ),
                label: const Text('Tạo giải đấu'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showSearch() {
    showSearch(
      context: context,
      delegate: TournamentSearchDelegate(
        tournaments: _allTournaments,
        onTournamentSelected: _navigateToTournamentDetail,
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TournamentFilterBottomSheet(
        currentFilters: _currentFilters,
        onFiltersApplied: (filters) {
          setState(() {
            _currentFilters = filters;
          });
        },
      ),
    );
  }

  Future<void> _refreshTournaments() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
    });
  }

  void _navigateToTournamentDetail(Map<String, dynamic> tournament) {
    Navigator.pushNamed(
      context,
      '/tournament-detail-screen',
      arguments: tournament,
    );
  }

  void _navigateToClubProfile() {
    Navigator.pushNamed(context, '/club-profile-screen');
  }

  void _toggleBookmark(Map<String, dynamic> tournament) {
    setState(() {
      tournament['isBookmarked'] =
          !(tournament['isBookmarked'] as bool? ?? false);
    });

    // Show feedback
    final isBookmarked = tournament['isBookmarked'] as bool;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isBookmarked ? 'Đã lưu giải đấu' : 'Đã bỏ lưu giải đấu',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  bool _hasActiveFilters() {
    final formats = _currentFilters['formats'] as List<String>;
    final skillLevels = _currentFilters['skillLevels'] as List<String>;
    final entryFeeRange = _currentFilters['entryFeeRange'] as List<String>;

    return formats.isNotEmpty ||
        skillLevels.isNotEmpty ||
        entryFeeRange.isNotEmpty ||
        (_currentFilters['locationRadius'] as double) != 10.0 ||
        (_currentFilters['hasLiveStream'] as bool) ||
        (_currentFilters['hasAvailableSlots'] as bool) ||
        (_currentFilters['hasPrizePool'] as bool);
  }

  void _clearFilters() {
    setState(() {
      _currentFilters = {
        'locationRadius': 10.0,
        'entryFeeRange': <String>[],
        'formats': <String>[],
        'skillLevels': <String>[],
        'hasLiveStream': false,
        'hasAvailableSlots': false,
        'hasPrizePool': false,
      };
    });
  }

  void _onBottomNavTap(String route) {
    if (route != '/tournament-list-screen') {
      Navigator.pushNamedAndRemoveUntil(
        context,
        route,
        (route) => false,
      );
    }
  }
}
