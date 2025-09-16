import 'package:flutter/material.dart';

import '../../models/user_profile.dart';
import '../../services/user_service.dart';
import '../../services/location_service.dart';
import '../../routes/app_routes.dart';

import './widgets/filter_bottom_sheet.dart';
import './widgets/map_view_widget.dart';
import './widgets/player_card_widget.dart';

class FindOpponentsScreen extends StatefulWidget {
  const FindOpponentsScreen({super.key});

  @override
  State<FindOpponentsScreen> createState() => _FindOpponentsScreenState();
}

class _FindOpponentsScreenState extends State<FindOpponentsScreen> {
  final UserService _userService = UserService.instance;
  final LocationService _locationService = LocationService.instance;

  List<UserProfile> _players = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _isMapView = false;
  String _selectedSkillLevel = 'all';
  double _radiusKm = 10.0;

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  Future<void> _loadPlayers() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // 1. Get current user's position
      final position = await _locationService.getCurrentPosition();

      // 2. Find nearby opponents using the new service method
      final players = await _userService.findOpponentsNearby(
        latitude: position.latitude,
        longitude: position.longitude,
        radiusInKm: _radiusKm,
      );

      // 3. Filter by skill level if selected
      final filteredPlayers = _selectedSkillLevel == 'all'
          ? players
          : players.where((p) => p.skillLevel == _selectedSkillLevel).toList();

      setState(() {
        _players = filteredPlayers;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
        _errorMessage = error.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải danh sách đối thủ: $_errorMessage')),
      );
    }
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => FilterBottomSheet(
        currentFilters: {
          'skillLevel': _selectedSkillLevel,
          'distance': _radiusKm,
        },
        onFiltersChanged: (filters) {
          setState(() {
            _selectedSkillLevel = filters['skillLevel'] ?? 'all';
            _radiusKm = filters['distance'] ?? 10.0;
          });
          _loadPlayers();
        },
      ),
    );
  }

  void _handleNavigation(String route) {
    if (route != AppRoutes.findOpponentsScreen) {
      Navigator.pushReplacementNamed(context, route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tìm đối thủ',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showFilterSheet,
            icon: const Icon(Icons.tune),
          ),
          IconButton(
            onPressed: () => setState(() => _isMapView = !_isMapView),
            icon: Icon(_isMapView ? Icons.list : Icons.map),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadPlayers,
        child: _buildBody(),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: 1, // Find opponents tab
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
                  // Already on find opponents
                  break;
                case 2:
                  _handleNavigation(AppRoutes.tournamentListScreen);
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
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Đang tìm đối thủ ở gần...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_players.isEmpty) {
      return _buildEmptyState();
    }

    return _isMapView
        ? MapViewWidget(players: _players.map((p) => p.toJson()).toList())
        : ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: _players.length,
            itemBuilder: (context, index) {
              return PlayerCardWidget(
                player: _players[index],
              );
            },
          );
  }

  Widget _buildErrorState() {
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
            Text(
              'Đã xảy ra lỗi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Không thể tải danh sách đối thủ. Vui lòng thử lại.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadPlayers,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_search,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Không tìm thấy đối thủ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Thử thay đổi bộ lọc để tìm thêm người chơi',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadPlayers,
              child: const Text('Tải lại'),
            ),
          ],
        ),
      ),
    );
  }
}