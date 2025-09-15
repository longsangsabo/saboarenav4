import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/challenge_modal_widget.dart';
import './widgets/filter_bottom_sheet.dart';
import './widgets/map_view_widget.dart';
import './widgets/player_card_widget.dart';

class FindOpponentsScreen extends StatefulWidget {
  const FindOpponentsScreen({super.key});

  @override
  State<FindOpponentsScreen> createState() => _FindOpponentsScreenState();
}

class _FindOpponentsScreenState extends State<FindOpponentsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isMapView = false;
  bool _isSearching = false;
  String _searchQuery = '';
  Map<String, dynamic> _currentFilters = {
    'gameTypes': <String>[],
    'skillLevels': <String>[],
    'distance': 10.0,
    'availability': <String>[],
  };

  final List<Map<String, dynamic>> _allPlayers = [
    {
      "id": 1,
      "name": "Nguyễn Văn Minh",
      "avatar":
          "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
      "rank": "A",
      "distance": 1.2,
      "club": "Billiards Club Sài Gòn",
      "isOnline": true,
      "gameTypes": ["8-ball", "9-ball"],
      "latitude": 10.7769,
      "longitude": 106.7009,
      "lastSeen": DateTime.now().subtract(const Duration(minutes: 5)),
    },
    {
      "id": 2,
      "name": "Trần Thị Hương",
      "avatar":
          "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
      "rank": "B",
      "distance": 2.8,
      "club": "Pool House Thủ Đức",
      "isOnline": true,
      "gameTypes": ["9-ball", "10-ball"],
      "latitude": 10.7829,
      "longitude": 106.7019,
      "lastSeen": DateTime.now().subtract(const Duration(minutes: 12)),
    },
    {
      "id": 3,
      "name": "Lê Hoàng Nam",
      "avatar":
          "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
      "rank": "C",
      "distance": 0.5,
      "club": "Champion Billiards",
      "isOnline": false,
      "gameTypes": ["8-ball"],
      "latitude": 10.7749,
      "longitude": 106.6989,
      "lastSeen": DateTime.now().subtract(const Duration(hours: 2)),
    },
    {
      "id": 4,
      "name": "Phạm Minh Tuấn",
      "avatar":
          "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
      "rank": "D",
      "distance": 3.2,
      "club": "Golden Ball Club",
      "isOnline": true,
      "gameTypes": ["8-ball", "9-ball", "10-ball"],
      "latitude": 10.7889,
      "longitude": 106.7089,
      "lastSeen": DateTime.now().subtract(const Duration(minutes: 1)),
    },
    {
      "id": 5,
      "name": "Võ Thị Lan",
      "avatar":
          "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
      "rank": "E",
      "distance": 4.1,
      "club": "Star Billiards",
      "isOnline": false,
      "gameTypes": ["9-ball"],
      "latitude": 10.7709,
      "longitude": 106.6949,
      "lastSeen": DateTime.now().subtract(const Duration(hours: 1)),
    },
    {
      "id": 6,
      "name": "Đặng Văn Hải",
      "avatar":
          "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
      "rank": "F",
      "distance": 1.8,
      "club": "Royal Pool",
      "isOnline": true,
      "gameTypes": ["8-ball", "10-ball"],
      "latitude": 10.7799,
      "longitude": 106.7029,
      "lastSeen": DateTime.now().subtract(const Duration(minutes: 8)),
    },
  ];

  List<Map<String, dynamic>> _filteredPlayers = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _filteredPlayers = List.from(_allPlayers);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _filterPlayers() {
    setState(() {
      _filteredPlayers = _allPlayers.where((player) {
        // Search query filter
        if (_searchQuery.isNotEmpty) {
          final name = (player["name"] as String).toLowerCase();
          final club = (player["club"] as String).toLowerCase();
          final query = _searchQuery.toLowerCase();
          if (!name.contains(query) && !club.contains(query)) {
            return false;
          }
        }

        // Game type filter
        final gameTypes = _currentFilters['gameTypes'] as List<String>;
        if (gameTypes.isNotEmpty) {
          final playerGameTypes = player["gameTypes"] as List<String>;
          if (!gameTypes.any((type) => playerGameTypes.contains(type))) {
            return false;
          }
        }

        // Skill level filter
        final skillLevels = _currentFilters['skillLevels'] as List<String>;
        if (skillLevels.isNotEmpty) {
          if (!skillLevels.contains(player["rank"])) {
            return false;
          }
        }

        // Distance filter
        final maxDistance = _currentFilters['distance'] as double;
        if ((player["distance"] as double) > maxDistance) {
          return false;
        }

        // Availability filter
        final availability = _currentFilters['availability'] as List<String>;
        if (availability.isNotEmpty) {
          if (availability.contains('online') &&
              !(player["isOnline"] as bool)) {
            return false;
          }
        }

        return true;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: theme.appBarTheme.elevation,
        title: _isSearching ? _buildSearchField() : _buildTitle(),
        actions: [
          if (!_isSearching) ...[
            IconButton(
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
              icon: CustomIconWidget(
                iconName: 'search',
                color:
                    theme.appBarTheme.foregroundColor ?? colorScheme.onSurface,
                size: 24,
              ),
              tooltip: 'Tìm kiếm',
            ),
            IconButton(
              onPressed: _showQRScanner,
              icon: CustomIconWidget(
                iconName: 'qr_code_scanner',
                color:
                    theme.appBarTheme.foregroundColor ?? colorScheme.onSurface,
                size: 24,
              ),
              tooltip: 'Quét QR',
            ),
            IconButton(
              onPressed: _showFilterBottomSheet,
              icon: CustomIconWidget(
                iconName: 'filter_list',
                color:
                    theme.appBarTheme.foregroundColor ?? colorScheme.onSurface,
                size: 24,
              ),
              tooltip: 'Bộ lọc',
            ),
          ] else ...[
            IconButton(
              onPressed: () {
                setState(() {
                  _isSearching = false;
                  _searchQuery = '';
                  _filterPlayers();
                });
              },
              icon: CustomIconWidget(
                iconName: 'close',
                color:
                    theme.appBarTheme.foregroundColor ?? colorScheme.onSurface,
                size: 24,
              ),
            ),
          ],
          SizedBox(width: 2.w),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(6.h),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              children: [
                Expanded(
                  child: TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: 'Gần đây'),
                      Tab(text: 'Theo dõi'),
                    ],
                  ),
                ),
                SizedBox(width: 4.w),
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildViewToggleButton(
                        icon: 'list',
                        isSelected: !_isMapView,
                        onTap: () => setState(() => _isMapView = false),
                      ),
                      _buildViewToggleButton(
                        icon: 'map',
                        isSelected: _isMapView,
                        onTap: () => setState(() => _isMapView = true),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNearbyTab(),
          _buildFollowingTab(),
        ],
      ),
      bottomNavigationBar: CustomBottomBar(
        currentRoute: '/find-opponents-screen',
        onTap: (route) {
          if (route != '/find-opponents-screen') {
            Navigator.pushReplacementNamed(context, route);
          }
        },
      ),
    );
  }

  Widget _buildTitle() {
    final theme = Theme.of(context);
    return Row(
      children: [
        CustomIconWidget(
          iconName: 'people',
          color: theme.colorScheme.primary,
          size: 28,
        ),
        SizedBox(width: 3.w),
        Text(
          'Tìm đối thủ',
          style: theme.appBarTheme.titleTextStyle?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    final theme = Theme.of(context);
    return TextField(
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'Tìm kiếm người chơi...',
        border: InputBorder.none,
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      style: theme.textTheme.bodyMedium,
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
        _filterPlayers();
      },
    );
  }

  Widget _buildViewToggleButton({
    required String icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary.withValues(alpha: 0.1) : null,
          borderRadius: BorderRadius.circular(6),
        ),
        child: CustomIconWidget(
          iconName: icon,
          color:
              isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildNearbyTab() {
    if (_isMapView) {
      return MapViewWidget(
        players: _filteredPlayers,
        onPlayerTap: _showPlayerDetails,
      );
    }

    return _buildPlayersList();
  }

  Widget _buildFollowingTab() {
    final followingPlayers = _filteredPlayers
        .where((player) => [1, 2, 4].contains(player["id"]))
        .toList();

    if (_isMapView) {
      return MapViewWidget(
        players: followingPlayers,
        onPlayerTap: _showPlayerDetails,
      );
    }

    return _buildPlayersList(players: followingPlayers);
  }

  Widget _buildPlayersList({List<Map<String, dynamic>>? players}) {
    final playersToShow = players ?? _filteredPlayers;

    if (playersToShow.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _refreshPlayers,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 1.h),
        itemCount: playersToShow.length,
        itemBuilder: (context, index) {
          final player = playersToShow[index];
          return Slidable(
            key: ValueKey(player["id"]),
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                  onPressed: (_) => _viewProfile(player),
                  backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  icon: Icons.person,
                  label: 'Hồ sơ',
                ),
                SlidableAction(
                  onPressed: (_) => _sendMessage(player),
                  backgroundColor: AppTheme.successLight,
                  foregroundColor: Colors.white,
                  icon: Icons.message,
                  label: 'Nhắn tin',
                ),
                SlidableAction(
                  onPressed: (_) => _addFriend(player),
                  backgroundColor: AppTheme.warningLight,
                  foregroundColor: Colors.white,
                  icon: Icons.person_add,
                  label: 'Kết bạn',
                ),
              ],
            ),
            child: PlayerCardWidget(
              player: player,
              onThachDau: () => _showChallengeModal(player, 'thach_dau'),
              onGiaoLuu: () => _showChallengeModal(player, 'giao_luu'),
              onViewProfile: () => _viewProfile(player),
              onSendMessage: () => _sendMessage(player),
              onAddFriend: () => _addFriend(player),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'search_off',
            color: theme.colorScheme.onSurfaceVariant,
            size: 64,
          ),
          SizedBox(height: 2.h),
          Text(
            'Không tìm thấy người chơi',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Thử mở rộng bán kính tìm kiếm hoặc thay đổi bộ lọc',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 3.h),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _currentFilters = {
                  'gameTypes': <String>[],
                  'skillLevels': <String>[],
                  'distance': 10.0,
                  'availability': <String>[],
                };
                _searchQuery = '';
              });
              _filterPlayers();
            },
            child: Text('Đặt lại bộ lọc'),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        currentFilters: _currentFilters,
        onFiltersChanged: (filters) {
          setState(() {
            _currentFilters = filters;
          });
          _filterPlayers();
        },
      ),
    );
  }

  void _showChallengeModal(Map<String, dynamic> player, String challengeType) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ChallengeModalWidget(
        player: player,
        challengeType: challengeType,
        onSendChallenge: () {
          // Handle challenge sending
        },
      ),
    );
  }

  void _showPlayerDetails(Map<String, dynamic> player) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).bottomSheetTheme.backgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant
                    .withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 2.h),
            PlayerCardWidget(
              player: player,
              onThachDau: () {
                Navigator.pop(context);
                _showChallengeModal(player, 'thach_dau');
              },
              onGiaoLuu: () {
                Navigator.pop(context);
                _showChallengeModal(player, 'giao_luu');
              },
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  void _showQRScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text('Quét mã QR'),
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          body: MobileScanner(
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đã quét: ${barcode.rawValue}'),
                    ),
                  );
                  break;
                }
              }
            },
          ),
        ),
      ),
    );
  }

  void _viewProfile(Map<String, dynamic> player) {
    Navigator.pushNamed(context, '/user-profile-screen');
  }

  void _sendMessage(Map<String, dynamic> player) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã mở cuộc trò chuyện với ${player["name"]}'),
        backgroundColor: AppTheme.successLight,
      ),
    );
  }

  void _addFriend(Map<String, dynamic> player) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã gửi lời mời kết bạn đến ${player["name"]}'),
        backgroundColor: AppTheme.successLight,
      ),
    );
  }

  Future<void> _refreshPlayers() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      // Simulate refreshing data
    });
  }
}
