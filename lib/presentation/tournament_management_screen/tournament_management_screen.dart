import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../models/tournament.dart';
import '../../services/tournament_service.dart';
import '../../services/club_permission_service.dart';
import '../tournament_creation_wizard/tournament_creation_wizard.dart';
import '../tournament_detail_screen/tournament_detail_screen.dart';
import '../tournament_detail_screen/widgets/tournament_management_panel.dart';
import '../member_management_screen/member_management_screen.dart';
import '../club_settings_screen/club_settings_screen.dart';
import 'widgets/tournament_stats_overview.dart';
import 'widgets/tournament_list_section.dart';
import 'widgets/tournament_quick_actions.dart';

class TournamentManagementScreen extends StatefulWidget {
  final String clubId;

  const TournamentManagementScreen({
    super.key,
    required this.clubId,
  });

  @override
  _TournamentManagementScreenState createState() => _TournamentManagementScreenState();
}

class _TournamentManagementScreenState extends State<TournamentManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TournamentService _tournamentService = TournamentService.instance;
  final ClubPermissionService _permissionService = ClubPermissionService();

  bool _isLoading = true;
  List<Tournament> _allTournaments = [];
  List<Tournament> _upcomingTournaments = [];
  List<Tournament> _ongoingTournaments = [];
  List<Tournament> _completedTournaments = [];
  String? _errorMessage;
  bool _canCreateTournaments = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Check permissions - For now, always allow create tournaments in management screen
      _canCreateTournaments = true; // TODO: Re-enable proper permission check later
      // _canCreateTournaments = await _permissionService.canManageTournaments(widget.clubId);

      // Load tournaments for this club (including private ones)
      final tournaments = await _tournamentService.getClubTournaments(
        widget.clubId,
        pageSize: 100,
      );

      // Filter tournaments by status
      _allTournaments = tournaments;
      _upcomingTournaments = tournaments.where((t) => t.status == 'upcoming').toList();
      _ongoingTournaments = tournaments.where((t) => t.status == 'ongoing').toList();
      _completedTournaments = tournaments.where((t) => t.status == 'completed').toList();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Lỗi tải dữ liệu: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Quản lý Giải đấu',
        actions: [
          if (_canCreateTournaments)
            IconButton(
              onPressed: _navigateToCreateTournament,
              icon: Icon(Icons.add),
              tooltip: 'Tạo giải đấu mới',
            ),
        ],
      ),
      backgroundColor: AppTheme.backgroundLight,
      body: _isLoading
          ? _buildLoadingState()
          : _errorMessage != null
              ? _buildErrorState()
              : _buildContent(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppTheme.primaryLight),
          SizedBox(height: 16),
          Text(
            'Đang tải danh sách giải đấu...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppTheme.errorLight,
          ),
          SizedBox(height: 16),
          Text(
            _errorMessage ?? 'Có lỗi xảy ra',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.errorLight,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadData,
            child: Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        // Stats Overview - Fixed height section
        TournamentStatsOverview(
          totalTournaments: _allTournaments.length,
          upcomingCount: _upcomingTournaments.length,
          ongoingCount: _ongoingTournaments.length,
          completedCount: _completedTournaments.length,
        ),

        // Quick Actions - Fixed height section
        if (_canCreateTournaments)
          TournamentQuickActions(
            onCreateTournament: _navigateToCreateTournament,
            onManageSchedule: _showScheduleManagement,
            onViewReports: _showReports,
          ),

        // Management Panel Quick Access
        if (_canCreateTournaments && _ongoingTournaments.isNotEmpty)
          _buildQuickManagementPanel(),

        // Tab Bar - Fixed height
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: AppTheme.primaryLight,
            unselectedLabelColor: AppTheme.textSecondaryLight,
            indicatorColor: AppTheme.primaryLight,
            isScrollable: false,
            tabs: [
              Tab(text: 'Tất cả (${_allTournaments.length})'),
              Tab(text: 'Sắp tới (${_upcomingTournaments.length})'),
              Tab(text: 'Đang diễn ra (${_ongoingTournaments.length})'),
              Tab(text: 'Đã kết thúc (${_completedTournaments.length})'),
            ],
          ),
        ),

        // Tournament Lists - Expandable scrollable section
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildScrollableTournamentList(_allTournaments),
              _buildScrollableTournamentList(_upcomingTournaments),
              _buildScrollableTournamentList(_ongoingTournaments),
              _buildScrollableTournamentList(_completedTournaments),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScrollableTournamentList(List<Tournament> tournaments) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: TournamentListSection(
        tournaments: tournaments,
        onTournamentTap: _navigateToTournamentDetail,
        canManage: _canCreateTournaments,
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.blue[600],
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
      currentIndex: 2, // Current tab is "Giải đấu"
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pop(context); // Go back to dashboard
            break;
          case 1:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MemberManagementScreen(clubId: widget.clubId),
              ),
            );
            break;
          case 2:
            // Already on tournament management
            break;
          case 3:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ClubSettingsScreen(clubId: widget.clubId),
              ),
            );
            break;
        }
      },
    );
  }

  void _navigateToCreateTournament() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TournamentCreationWizard(
          clubId: widget.clubId,
        ),
      ),
    );

    if (result != null) {
      // Refresh tournament list after creating new tournament
      _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Giải đấu đã được tạo thành công!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _navigateToTournamentDetail(Tournament tournament) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TournamentDetailScreen(),
        settings: RouteSettings(arguments: tournament.id),
      ),
    );
  }

  void _showScheduleManagement() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Quản lý lịch trình - Tính năng đang phát triển')),
    );
  }

  void _showReports() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Báo cáo giải đấu - Tính năng đang phát triển')),
    );
  }

  Widget _buildQuickManagementPanel() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryLight.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flash_on, color: AppTheme.primaryLight, size: 20),
              SizedBox(width: 8),
              Text(
                'Quản lý nhanh',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryLight,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'Bạn có ${_ongoingTournaments.length} giải đấu đang diễn ra cần quản lý',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondaryLight,
            ),
          ),
          SizedBox(height: 12),
          if (_ongoingTournaments.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _ongoingTournaments.take(3).map((tournament) => 
                InkWell(
                  onTap: () => _showTournamentManagement(tournament),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.primaryLight.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.settings, size: 14, color: AppTheme.primaryLight),
                        SizedBox(width: 4),
                        Text(
                          tournament.title.length > 15 
                              ? '${tournament.title.substring(0, 15)}...'
                              : tournament.title,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.primaryLight,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ).toList(),
            ),
        ],
      ),
    );
  }

  void _showTournamentManagement(Tournament tournament) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: TournamentManagementPanel(
            tournamentId: tournament.id,
            tournamentStatus: tournament.status,
            onStatusChanged: () {
              _loadData(); // Refresh data after changes
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
    );
  }
}