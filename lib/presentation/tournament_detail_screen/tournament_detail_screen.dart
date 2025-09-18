import 'package:flutter/material.dart';
// Removed Sizer dependency
import '../../core/layout/responsive.dart';

import 'package:sabo_arena/core/app_export.dart';
import '../../services/tournament_service.dart';
import '../../models/tournament.dart';
import '../../models/user_profile.dart';

import 'widgets/tournament_management_panel.dart';
import 'widgets/tournament_bracket_view.dart';
import 'widgets/participant_management_view.dart';
import 'widgets/match_management_view.dart';
import 'widgets/tournament_stats_view.dart';
import 'widgets/payment_options_dialog.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/participants_list_widget.dart';
import './widgets/prize_pool_widget.dart';
import './widgets/registration_widget.dart';
import './widgets/tournament_bracket_widget.dart';
import './widgets/tournament_header_widget.dart';
import './widgets/tournament_info_widget.dart';
import './widgets/tournament_rules_widget.dart';

class TournamentDetailScreen extends StatefulWidget {
  const TournamentDetailScreen({super.key});

  @override
  State<TournamentDetailScreen> createState() => _TournamentDetailScreenState();
}

class _TournamentDetailScreenState extends State<TournamentDetailScreen>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late TabController _tabController;
  bool _isRegistered = false;
  
  // Service instances
  final TournamentService _tournamentService = TournamentService.instance;
  
  // State variables
  Tournament? _tournament;
  List<UserProfile> _participants = [];
  List<Map<String, dynamic>> _matches = [];
  bool _isLoading = true;
  String? _error;
  String? _tournamentId;
  
  // Tournament data for UI (converted from Tournament model)
  Map<String, dynamic> _tournamentData = {};

  // Mock tournament rules
  final List<String> _tournamentRules = [
    "Giải đấu áp dụng luật 9-ball quốc tế WPA",
    "Mỗi trận đấu thi đấu theo thể thức race to 7 (ai thắng trước 7 game)",
    "Thời gian suy nghĩ tối đa 30 giây cho mỗi cú đánh",
    "Không được sử dụng điện thoại trong quá trình thi đấu",
    "Trang phục lịch sự, không mặc áo ba lỗ hoặc quần short",
    "Nghiêm cấm hành vi gian lận, cãi vã với trọng tài",
    "Thí sinh đến muộn quá 15 phút sẽ bị tước quyền thi đấu",
    "Quyết định của trọng tài là quyết định cuối cùng"
  ];

  // Mock participants data
  final List<Map<String, dynamic>> _participantsData = [
    {
      "id": "player_001",
      "name": "Nguyễn Văn Minh",
      "avatar":
          "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
      "rank": "A",
      "elo": 1850,
      "registrationDate": "2024-09-10"
    },
    {
      "id": "player_002",
      "name": "Trần Thị Hương",
      "avatar":
          "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
      "rank": "B",
      "elo": 1720,
      "registrationDate": "2024-09-11"
    },
    {
      "id": "player_003",
      "name": "Lê Hoàng Nam",
      "avatar":
          "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
      "rank": "A",
      "elo": 1890,
      "registrationDate": "2024-09-12"
    },
    {
      "id": "player_004",
      "name": "Phạm Thị Lan",
      "avatar":
          "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
      "rank": "B",
      "elo": 1680,
      "registrationDate": "2024-09-12"
    },
    {
      "id": "player_005",
      "name": "Võ Minh Tuấn",
      "avatar":
          "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
      "rank": "C",
      "elo": 1520,
      "registrationDate": "2024-09-13"
    },
    {
      "id": "player_006",
      "name": "Đặng Thị Mai",
      "avatar":
          "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
      "rank": "B",
      "elo": 1750,
      "registrationDate": "2024-09-13"
    },
    {
      "id": "player_007",
      "name": "Bùi Văn Đức",
      "avatar":
          "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
      "rank": "A",
      "elo": 1920,
      "registrationDate": "2024-09-14"
    },
    {
      "id": "player_008",
      "name": "Ngô Thị Linh",
      "avatar":
          "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
      "rank": "C",
      "elo": 1480,
      "registrationDate": "2024-09-14"
    }
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_tournamentId == null) {
      final String? id = ModalRoute.of(context)?.settings.arguments as String?;
      if (id != null) {
        _tournamentId = id;
        _loadTournamentData();
      }
    }
  }

  Future<void> _loadTournamentData() async {
    if (_tournamentId == null) return;
    
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Load tournament details
      _tournament = await _tournamentService.getTournamentById(_tournamentId!);
      
      // Load participants
      _participants = await _tournamentService.getTournamentParticipants(_tournamentId!);
      
      // Load matches
      _matches = await _tournamentService.getTournamentMatches(_tournamentId!);
      
      // Check if user is already registered
      _isRegistered = await _tournamentService.isRegisteredForTournament(_tournamentId!);
      
      // Convert tournament model to UI data format
      _convertTournamentToUIData();
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  void _convertTournamentToUIData() {
    if (_tournament == null) return;
    
    _tournamentData = {
      "id": _tournament!.id,
      "title": _tournament!.title,
      "format": _tournament!.tournamentType,
      "coverImage": _tournament!.coverImageUrl ?? 
          "https://images.unsplash.com/photo-1578662996442-48f60103fc96?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "location": "Từ dữ liệu CLB", // TODO: Get from club data
      "startDate": _formatDate(_tournament!.startDate),
      "endDate": _tournament!.endDate != null ? _formatDate(_tournament!.endDate!) : null,
      "registrationDeadline": _formatDate(_tournament!.registrationDeadline),
      "currentParticipants": _tournament!.currentParticipants,
      "maxParticipants": _tournament!.maxParticipants,
      "eliminationType": _tournament!.tournamentType,
      "status": _getStatusText(_tournament!.status),
      "entryFee": _tournament!.entryFee > 0 ? "${_tournament!.entryFee.toStringAsFixed(0)} VNĐ" : "Miễn phí",
      "rankRequirement": _tournament!.skillLevelRequired ?? "Tất cả",
      "description": _tournament!.description,
      "prizePool": {
        "total": "${_tournament!.prizePool.toStringAsFixed(0)} VNĐ",
        // TODO: Parse prize distribution if available
        "first": "${(_tournament!.prizePool * 0.5).toStringAsFixed(0)} VNĐ",
        "second": "${(_tournament!.prizePool * 0.3).toStringAsFixed(0)} VNĐ",
        "third": "${(_tournament!.prizePool * 0.2).toStringAsFixed(0)} VNĐ"
      }
    };
  }

  List<Map<String, dynamic>> _convertParticipantsToUIData() {
    return _participants.map((participant) {
      return {
        "id": participant.id,
        "name": participant.fullName,
        "avatar": participant.avatarUrl ?? 
            "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
        "rank": participant.rank ?? participant.skillLevel,
        "elo": participant.eloRating,
        "registrationDate": _formatDate(participant.createdAt)
      };
    }).toList();
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'upcoming':
        return 'Sắp diễn ra';
      case 'registration_open':
        return 'Đang mở đăng ký';
      case 'ongoing':
        return 'Đang diễn ra';
      case 'completed':
        return 'Đã kết thúc';
      default:
        return status;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Không thể tải thông tin giải đấu',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTournamentData,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_tournament == null) {
      return const Center(
        child: Text('Không tìm thấy giải đấu'),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            TournamentHeaderWidget(
              tournament: _tournamentData,
              scrollController: _scrollController,
              onShareTap: _handleShareTournament,
              onMenuAction: _handleMenuAction,
            ),
          ];
        },
        body: Column(
          children: [
            Container(
              color: AppTheme.lightTheme.colorScheme.surface,
              child: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Tổng quan'),
                  Tab(text: 'Bảng đấu'),
                  Tab(text: 'Thành viên'),
                  Tab(text: 'Luật thi đấu'),
                ],
                labelColor: AppTheme.lightTheme.colorScheme.primary,
                unselectedLabelColor:
                    AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                indicatorColor: AppTheme.lightTheme.colorScheme.primary,
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(),
                  _buildBracketTab(),
                  _buildParticipantsTab(),
                  _buildRulesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentRoute: '/tournament-detail-screen',
        onTap: _handleBottomNavTap,
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
  padding: const EdgeInsets.only(bottom: Gaps.lg),
      child: Column(
        children: [
          const SizedBox(height: Gaps.lg),
          TournamentInfoWidget(tournament: _tournamentData),
          const SizedBox(height: Gaps.lg),
          PrizePoolWidget(tournament: _tournamentData),
          const SizedBox(height: Gaps.lg),
          RegistrationWidget(
            tournament: _tournamentData,
            isRegistered: _isRegistered,
            onRegisterTap: _handleRegistration,
            onWithdrawTap: _handleWithdrawal,
          ),
        ],
      ),
    );
  }

  Widget _buildBracketTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: Gaps.lg),
      child: Column(
        children: [
          const SizedBox(height: Gaps.lg),
          TournamentBracketWidget(
            tournament: _tournamentData,
            bracketData: _matches.isNotEmpty ? _matches : _getDefaultBracketData(),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getDefaultBracketData() {
    // Return empty or placeholder bracket data when no matches exist
    if (_participants.isEmpty) {
      return [];
    }
    
    // Generate placeholder matches from participants if tournament hasn't started
    return [
      {
        "matchId": "placeholder_001",
        "round": 1,
        "player1": null,
        "player2": null,
        "winner": null,
        "status": "pending"
      }
    ];
  }

  Widget _buildParticipantsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: Gaps.lg),
      child: Column(
        children: [
          const SizedBox(height: Gaps.lg),
          ParticipantsListWidget(
            participants: _convertParticipantsToUIData(),
            onViewAllTap: _handleViewAllParticipants,
          ),
        ],
      ),
    );
  }

  Widget _buildRulesTab() {
    List<String> rules = [];
    if (_tournament?.rules != null && _tournament!.rules!.isNotEmpty) {
      // Split rules if they're in a single string
      rules = _tournament!.rules!.split('\n').where((rule) => rule.trim().isNotEmpty).toList();
    } else {
      rules = _tournamentRules; // Fallback to default rules
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: Gaps.lg),
      child: Column(
        children: [
          const SizedBox(height: Gaps.lg),
          TournamentRulesWidget(rules: rules),
        ],
      ),
    );
  }

  void _handleShareTournament() {
    // Handle tournament sharing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Đã sao chép link giải đấu',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onInverseSurface,
          ),
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.inverseSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _handleRegistration() {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    // Show payment options dialog
    showDialog(
      context: context,
      builder: (dialogContext) => PaymentOptionsDialog(
        tournamentId: _tournamentData['id'],
        tournamentName: _tournamentData['title'],
        entryFee: double.parse(_tournamentData['entryFee'].toString().replaceAll(',', '').replaceAll(' VNĐ', '')),
        onPaymentConfirmed: (paymentMethod) async {
          // Close dialog first
          Navigator.of(dialogContext).pop();
          
          try {
            // Show loading
            scaffoldMessenger.showSnackBar(
              const SnackBar(
                content: Text('Đang xử lý đăng ký...'),
                duration: Duration(seconds: 1),
              ),
            );
            
            // Call actual registration service with selected payment method
            await _tournamentService.registerForTournament(
              _tournamentData['id'],
              paymentMethod: paymentMethod,
            );
            
            // Update UI state
            if (mounted) {
              setState(() {
                _isRegistered = true;
              });
              
              // Reload tournament data to get updated participant count
              await _loadTournamentData();
              
              // Show success message
              scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: Text(
                    paymentMethod == '0' 
                      ? 'Đăng ký thành công! Vui lòng thanh toán tại quán.'
                      : 'Đăng ký thành công! Vui lòng chuyển khoản theo QR code.',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (error) {
            if (mounted) {
              scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: Text('Đăng ký thất bại: $error'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _handleWithdrawal() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Xác nhận rút lui',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Bạn có chắc chắn muốn rút lui khỏi giải đấu này? Lệ phí đã đóng sẽ được hoàn trả 80%.',
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Hủy',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              Navigator.pop(context);
              if (mounted) {
                setState(() {
                  _isRegistered = false;
                });
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      'Đã rút lui khỏi giải đấu thành công',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onInverseSurface,
                      ),
                    ),
                    backgroundColor:
                        AppTheme.lightTheme.colorScheme.inverseSurface,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.error,
            ),
            child: Text(
              'Rút lui',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onError,
              ),
            ),
          ),
        ],
      ),
    );
  }



  void _handleViewAllParticipants() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
  height: 600,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(Gaps.xl),
              child: Column(
                children: [
                  Container(
                    width: 70,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: Gaps.lg),
                  Text(
                    'Danh sách tham gia (${_participantsData.length})',
                    style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: Gaps.xl),
                itemCount: _participantsData.length,
                itemBuilder: (context, index) {
                  final participant = _participantsData[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: Gaps.sm),
                    padding: const EdgeInsets.all(Gaps.lg),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '${index + 1}',
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.lightTheme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: Gaps.md),
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(27),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(27),
                            child: CustomImageWidget(
                              imageUrl: participant["avatar"] as String,
                              width: 54,
                              height: 54,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: Gaps.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                participant["name"] as String,
                                style: AppTheme.lightTheme.textTheme.bodyLarge
                                    ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Rank ${participant["rank"]} • ${participant["elo"]} ELO',
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleBottomNavTap(String route) {
    if (route != '/tournament-detail-screen') {
      Navigator.pushNamedAndRemoveUntil(
        context,
        route,
        (route) => false,
      );
    }
  }

  void _showBracketView() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TournamentBracketView(
        tournamentId: _tournamentData['id'] as String,
        format: _tournamentData['format'] as String,
        totalParticipants: _tournamentData['currentParticipants'] as int,
        isEditable: _canManageTournament(),
      ),
    );
  }

  void _showParticipantManagement() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ParticipantManagementView(
        tournamentId: _tournamentData['id'] as String,
        tournamentStatus: _tournamentData['status'] as String,
        maxParticipants: _tournamentData['maxParticipants'] as int,
        canManage: _canManageTournament(),
      ),
    );
  }

  void _showManagementPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TournamentManagementPanel(
        tournamentId: _tournamentData['id'] as String,
        tournamentStatus: _tournamentData['status'] as String,
        onStatusChanged: () {
          // Reload tournament data if needed
          setState(() {});
        },
      ),
    );
  }

  void _showMatchManagement() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MatchManagementView(
        tournamentId: _tournamentData['id'] as String,
        tournamentStatus: _tournamentData['status'] as String,
        canManage: _canManageTournament(),
      ),
    );
  }

  void _showTournamentStats() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TournamentStatsView(
        tournamentId: _tournamentData['id'] as String,
        tournamentStatus: _tournamentData['status'] as String,
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'participants':
        _showParticipantManagement();
        break;
      case 'bracket':
        _showBracketView();
        break;
      case 'matches':
        _showMatchManagement();
        break;
      case 'stats':
        _showTournamentStats();
        break;
      case 'manage':
        if (_canManageTournament()) {
          _showManagementPanel();
        }
        break;
      case 'share':
        _shareTournament();
        break;
    }
  }

  bool _canManageTournament() {
    // Add logic to check if current user can manage this tournament
    // For now, return true for demo
    return true;
  }

  void _shareTournament() {
    // Implementation for sharing tournament
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Tính năng chia sẻ đang được phát triển"),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );
  }
}
