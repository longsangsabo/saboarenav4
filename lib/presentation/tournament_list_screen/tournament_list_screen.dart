import 'package:flutter/material.dart';
import 'package:sabo_arena/core/app_export.dart';
import 'package:sabo_arena/models/tournament.dart';
import 'package:sabo_arena/presentation/tournament_list_screen/widgets/tournament_card_widget.dart';
import 'package:sabo_arena/presentation/tournament_list_screen/widgets/tournament_filter_bottom_sheet.dart';
import 'package:sabo_arena/presentation/tournament_list_screen/widgets/tournament_search_delegate.dart';
import 'package:sabo_arena/presentation/demo_bracket_screen/demo_bracket_screen.dart';
import 'package:sabo_arena/services/tournament_service.dart';


class TournamentListScreen extends StatefulWidget {
  const TournamentListScreen({super.key});

  @override
  State<TournamentListScreen> createState() => _TournamentListScreenState();
}

class _TournamentListScreenState extends State<TournamentListScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TournamentService _tournamentService = TournamentService.instance;
  bool _isLoading = true;
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

  List<Tournament> _allTournaments = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadTournaments();
  }

  Future<void> _loadTournaments() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final tournaments = await _tournamentService.getTournaments(status: _selectedTab);
      if (mounted) {
        setState(() {
          _allTournaments = tournaments;
          _isLoading = false;
        });
      }
    } catch (e) {
      // Show error if data loading fails
      if (mounted) {
        setState(() {
          _allTournaments = [];
          _isLoading = false;
          _errorMessage = 'Không thể tải dữ liệu giải đấu: $e';
        });
      }
    }
  }

  List<Tournament> _getMockTournaments() {
    return [
      Tournament(
        id: '1',
        title: 'Giải Bi-da Mùa Xuân 2025',
        description: 'Giải đấu bi-da lớn nhất trong năm dành cho tất cả các cấp độ',
        startDate: DateTime.now().add(const Duration(days: 7)),
        registrationDeadline: DateTime.now().add(const Duration(days: 5)),
        maxParticipants: 32,
        currentParticipants: 18,
        entryFee: 200000,
        prizePool: 5000000,
        status: 'upcoming',
        skillLevelRequired: 'intermediate',
        tournamentType: '8-ball',
        isPublic: true,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now(),
      ),
      Tournament(
        id: '2',
        title: 'Giải Tốc Độ Hàng Tuần',
        description: 'Giải đấu nhanh gọn trong 1 ngày, phù hợp mọi người chơi',
        startDate: DateTime.now().add(const Duration(days: 3)),
        registrationDeadline: DateTime.now().add(const Duration(days: 2)),
        maxParticipants: 16,
        currentParticipants: 8,
        entryFee: 50000,
        prizePool: 800000,
        status: 'upcoming',
        tournamentType: '9-ball',
        isPublic: true,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now(),
      ),
      Tournament(
        id: '3',
        title: 'Giải Đấu Miễn Phí Newbie',
        description: 'Dành cho người mới bắt đầu, hoàn toàn miễn phí',
        startDate: DateTime.now().add(const Duration(days: 14)),
        registrationDeadline: DateTime.now().add(const Duration(days: 12)),
        maxParticipants: 24,
        currentParticipants: 5,
        entryFee: 0,
        prizePool: 0,
        status: 'upcoming',
        skillLevelRequired: 'beginner',
        tournamentType: '8-ball',
        isPublic: true,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      return;
    }
    final newTab = ['upcoming', 'live', 'completed'][_tabController.index];
    if (newTab != _selectedTab) {
      setState(() {
        _selectedTab = newTab;
      });
      _loadTournaments();
    }
  }

  void _handleNavigation(String route) {
    if (route != AppRoutes.tournamentListScreen) {
      Navigator.pushReplacementNamed(context, route);
    }
  }

  List<Tournament> get _filteredTournaments {
    // Temporarily simplified to fix dead_null_aware_expression warnings
    return _allTournaments;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Giải đấu"),
        actions: [
          IconButton(
            icon: const Icon(Icons.preview),
            tooltip: 'Demo Bảng Đấu',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DemoBracketScreen(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearch(context),
          ),
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
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFilterBottomSheet(context),
        child: const Icon(Icons.filter_list),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(
                color: Colors.grey.withOpacity(0.2),
                width: 1,
              ),
            ),
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: 2, // Tournaments tab
            selectedItemColor: Colors.green,
            unselectedItemColor: Colors.grey,
            backgroundColor: Colors.white,
            elevation: 0,
            onTap: (index) {
              switch (index) {
                case 0:
                  _handleNavigation(AppRoutes.homeFeedScreen);
                  break;
                case 1:
                  _handleNavigation(AppRoutes.findOpponentsScreen);
                  break;
                case 2:
                  // Already on tournaments
                  break;
                case 3:
                  _handleNavigation(AppRoutes.clubMainScreen);
                  break;
                case 4:
                  _handleNavigation(AppRoutes.userProfileScreen);
                  break;
              }
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Trang chủ',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people_outline),
                activeIcon: Icon(Icons.people),
                label: 'Đối thủ',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.emoji_events_outlined),
                activeIcon: Icon(Icons.emoji_events),
                label: 'Giải đấu',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.business_outlined),
                activeIcon: Icon(Icons.business),
                label: 'Câu lạc bộ',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Cá nhân',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage ?? ''));
    }
    if (_filteredTournaments.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadTournaments,
        child: const Center(child: Text("Không có giải đấu nào.")),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadTournaments,
      child: ListView.builder(
        itemCount: _filteredTournaments.length,
        itemBuilder: (context, index) {
          final tournament = _filteredTournaments[index];
          return TournamentCardWidget(tournament: tournament);
        },
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
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

  Map<String, dynamic> _tournamentToMap(Tournament tournament) {
    return {
      'id': tournament.id,
      'title': tournament.title,
      'clubName': tournament.clubId ?? 'N/A',
      'format': tournament.tournamentType,
      'entryFee': tournament.entryFee > 0
          ? '${tournament.entryFee.toStringAsFixed(0)}đ'
          : 'Miễn phí',
      'coverImage': tournament.coverImageUrl,
      'skillLevelRequired': tournament.skillLevelRequired,
    };
  }

  void _showSearch(BuildContext context) {
    final tournamentsForSearch = _filteredTournaments.map(_tournamentToMap).toList();

    showSearch<String>(
      context: context,
      delegate: TournamentSearchDelegate(
        tournaments: tournamentsForSearch,
        onTournamentSelected: (tournamentMap) {
          Navigator.pushNamed(
            context,
            AppRoutes.tournamentDetailScreen,
            arguments: tournamentMap['id'],
          );
        },
      ),
    );
  }
}
