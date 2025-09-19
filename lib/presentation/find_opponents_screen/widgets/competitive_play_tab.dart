import 'package:flutter/material.dart';

import '../../../models/user_profile.dart';
import '../../../services/user_service.dart';
import '../../../core/app_export.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import './map_view_widget.dart';
import './player_card_widget.dart';
import '../../widgets/rank_change_request_dialog.dart';


class CompetitivePlayTab extends StatefulWidget {
  final bool isLoading;
  final String? errorMessage;
  final List<UserProfile> players;
  final bool isMapView;
  final VoidCallback onRefresh;

  const CompetitivePlayTab({
    super.key,
    required this.isLoading,
    required this.errorMessage,
    required this.players,
    required this.isMapView,
    required this.onRefresh,
  });

  @override
  State<CompetitivePlayTab> createState() => _CompetitivePlayTabState();
}

class _CompetitivePlayTabState extends State<CompetitivePlayTab> {
  final UserService _userService = UserService.instance;
  UserProfile? _currentUser;
  bool _isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final userProfile = await _userService.getCurrentUserProfile();
        if (mounted) {
          setState(() {
            _currentUser = userProfile;
            _isLoadingUser = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoadingUser = false;
          });
        }
      }
    } catch (e) {
      print('Error loading current user: $e');
      if (mounted) {
        setState(() {
          _isLoadingUser = false;
        });
      }
    }
  }

  bool get _hasRank {
    if (_currentUser == null) return false;
    final userRank = _currentUser!.rank;
    return userRank != null && userRank.isNotEmpty && userRank != 'unranked';
  }

  Widget _buildRankRequiredPrompt(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.orange.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.emoji_events,
                    size: 48,
                    color: Colors.orange.shade600,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Đăng ký xếp hạng để tham gia',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Bạn cần có hạng đấu để tham gia thách đấu xếp hạng. Đăng ký ngay để:',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: [
                      _buildBenefitRow('🏆', 'Tham gia thách đấu xếp hạng'),
                      const SizedBox(height: 8),
                      _buildBenefitRow('📊', 'Theo dõi tiến bộ qua ELO'),
                      const SizedBox(height: 8),
                      _buildBenefitRow('🎯', 'Gặp đối thủ cùng trình độ'),
                      const SizedBox(height: 8),
                      _buildBenefitRow('🏅', 'Tranh tài trong giải đấu'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _navigateToRankRegistration(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Đăng ký xếp hạng ngay',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      // Navigate to social play instead
                      DefaultTabController.of(context).animateTo(1);
                    },
                    child: Text(
                      'Hoặc chơi giao lưu không tính điểm',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitRow(String emoji, String text) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  void _navigateToRankRegistration(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.clubSelectionScreen);
  }

  Widget _buildRankInfoBanner(BuildContext context) {
    if (_currentUser == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.verified, color: Colors.green.shade600, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hạng hiện tại: ${_currentUser!.rank}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Bạn có thể tham gia thách đấu xếp hạng',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: () => _showRankChangeRequestDialog(context),
            icon: Icon(Icons.swap_vert, size: 18, color: Colors.blue.shade600),
            label: Text(
              'Thay đổi hạng',
              style: TextStyle(color: Colors.blue.shade600),
            ),
            style: TextButton.styleFrom(
              backgroundColor: Colors.blue.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRankChangeRequestDialog(BuildContext context) {
    if (_currentUser == null) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return RankChangeRequestDialog(
          userProfile: _currentUser!,
          onRequestSubmitted: () {
            // Optional: Refresh data or show confirmation
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingUser) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Đang tải thông tin người dùng...'),
          ],
        ),
      );
    }

    // Check if user has rank - if not, show rank registration prompt
    if (!_hasRank) {
      return _buildRankRequiredPrompt(context);
    }

    return Column(
      children: [
        // Rank info banner for users with rank
        _buildRankInfoBanner(context),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => widget.onRefresh(),
            child: _buildBody(context),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    if (widget.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Đang tìm đối thủ xứng tầm...'),
          ],
        ),
      );
    }

    if (widget.errorMessage != null) {
      return _buildErrorState(context);
    }

    if (widget.players.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      children: [
        // Info banner for competitive play
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),  
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.emoji_events, color: Colors.orange[600]),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thách đấu xếp hạng',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.orange[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Đấu ranked để tăng ELO và leo hạng',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Ranking filters
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _buildRankingFilter('Tương đương', Icons.balance, Colors.green),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildRankingFilter('Cao hơn', Icons.trending_up, Colors.red),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildRankingFilter('Thấp hơn', Icons.trending_down, Colors.blue),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Players list/map
        Expanded(
          child: widget.isMapView
              ? MapViewWidget(players: widget.players.map((p) => p.toJson()).toList())
              : ListView.builder(
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 80),
                  itemCount: widget.players.length,
                  itemBuilder: (context, index) {
                    return PlayerCardWidget(
                      player: widget.players[index],
                      mode: 'thach_dau',
                      challengeInfo: _getChallengeInfo(widget.players[index]),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildRankingFilter(String title, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'Đã xảy ra lỗi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              widget.errorMessage ?? 'Không thể tải danh sách đối thủ. Vui lòng thử lại.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: widget.onRefresh,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sports_esports,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Không có đối thủ xứng tầm',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Thử mở rộng phạm vi ELO hoặc khoảng cách',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: widget.onRefresh,
              child: const Text('Tải lại'),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getChallengeInfo(UserProfile player) {
    // Generate dynamic challenge info based on player stats
    final spaBet = _calculateSpaBet(player.eloRating);
    final raceTo = _calculateRaceTo(player.eloRating);
    final playTime = _getAvailablePlayTime();
    final availability = _getPlayerAvailability();

    return {
      'spaBet': spaBet,
      'raceTo': raceTo,
      'playTime': playTime,
      'availability': availability,
    };
  }

  int _calculateSpaBet(int eloRating) {
    // SPA bet based on ELO rating
    if (eloRating >= 2000) return 1000;
    if (eloRating >= 1800) return 800;
    if (eloRating >= 1600) return 600;
    if (eloRating >= 1400) return 500;
    return 300;
  }

  int _calculateRaceTo(int eloRating) {
    // Race to based on skill level
    if (eloRating >= 2000) return 9;
    if (eloRating >= 1800) return 8;
    if (eloRating >= 1600) return 7;
    return 5;
  }

  String _getAvailablePlayTime() {
    final hour = DateTime.now().hour;
    if (hour < 12) return '14:00-16:00';
    if (hour < 17) return '19:00-21:00';
    return '21:00-23:00';
  }

  String _getPlayerAvailability() {
    final availabilities = ['Rảnh', 'Bận', 'Có thể', 'Hẹn sau'];
    return availabilities[DateTime.now().millisecond % availabilities.length];
  }
}