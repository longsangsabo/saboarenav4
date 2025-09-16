import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../models/user_profile.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';

import './widgets/achievements_section_widget.dart';
import './widgets/profile_header_widget.dart';
import './widgets/qr_code_widget.dart';
import './widgets/settings_menu_widget.dart';
import './widgets/social_features_widget.dart';
import './widgets/statistics_cards_widget.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  bool _isRefreshing = false;
  bool _isLoading = true;

  // Services
  final UserService _userService = UserService.instance;
  final AuthService _authService = AuthService.instance;

  // Dynamic data from backend
  UserProfile? _userProfile;
  Map<String, dynamic> _socialData = {};

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    try {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
      });

      print('🚀 Profile: Loading user data from backend...');
      final currentUser = _authService.currentUser;

      if (currentUser != null) {
        final userProfile = await _userService.getUserProfileById(currentUser.id);

        if (mounted) {
          setState(() {
            _userProfile = userProfile;
          });
        }

        await _loadProfileData(userProfile.id);
      } else {
        print('⚠️ Profile: No authenticated user.');
      }

      print('✅ Profile: User data loaded successfully');
    } catch (e) {
      print('❌ Profile error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể tải hồ sơ người dùng: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadProfileData(String userId) async {
    try {
      print('🚀 Profile: Loading social data...');

      final friends = await _userService.getUserFollowers(userId);
      // final recentChallenges = await _socialService.fetchRecentChallenges(userId); // This method doesn't exist
      final userStats = await _userService.getUserStats(userId);

      if (mounted) {
        setState(() {
          _socialData = {
            "friendsCount": friends.length,
            "challengesCount": 0, // Placeholder
            "tournamentsCount": userStats['total_tournaments'] ?? 0,
            "recentFriends": friends.take(5).toList(),
            "recentChallenges": [], // Placeholder
          };
        });
      }
      print('✅ Profile: Additional data loaded successfully');
    } catch (e) {
      print('❌ Profile data error: $e');
    }
  }

  Future<void> _refreshProfile() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    HapticFeedback.lightImpact();
    await _loadUserProfile();
    if (mounted) {
      setState(() {
        _isRefreshing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Đã cập nhật thông tin profile'),
          backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
        ),
      );
    }

    if (_userProfile == null) {
      return Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        appBar: _buildAppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_off_outlined, size: 80, color: Colors.grey),
              SizedBox(height: 2.h),
              Text('Không thể tải hồ sơ', style: AppTheme.lightTheme.textTheme.titleLarge),
              SizedBox(height: 1.h),
              Text('Vui lòng đăng nhập hoặc thử lại.', style: AppTheme.lightTheme.textTheme.bodyMedium),
              SizedBox(height: 4.h),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.loginScreen),
                child: Text('Đăng nhập'),
              )
            ],
          ),
        ),
      );
    }

    final userDataMap = _userProfile!.toJson();

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _refreshProfile,
        color: AppTheme.lightTheme.colorScheme.primary,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProfileHeaderWidget(
                    userData: userDataMap,
                    onEditProfile: _showEditProfileModal,
                    onCoverPhotoTap: _changeCoverPhoto,
                    onAvatarTap: _changeAvatar,
                  ),
                  SizedBox(height: 3.h),
                  StatisticsCardsWidget(userId: _userProfile!.id),
                  SizedBox(height: 4.h),
                  AchievementsSectionWidget(
                    userId: _userProfile!.id,
                    onViewAll: _viewAllAchievements,
                  ),
                  SizedBox(height: 4.h),
                  SocialFeaturesWidget(
                    socialData: _socialData,
                    onFriendsListTap: _viewFriendsList,
                    onRecentChallengesTap: _viewRecentChallenges,
                    onTournamentHistoryTap: _viewTournamentHistory,
                  ),
                  SizedBox(height: 4.h),
                  SettingsMenuWidget(
                    onAccountSettings: _openAccountSettings,
                    onPrivacySettings: _openPrivacySettings,
                    onNotificationSettings: _openNotificationSettings,
                    onLanguageSettings: _openLanguageSettings,
                    onPaymentHistory: _openPaymentHistory,
                    onHelpSupport: _openHelpSupport,
                    onAbout: _openAbout,
                    onLogout: _handleLogout,
                  ),
                  SizedBox(height: 10.h),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: 4, // Profile tab
            selectedItemColor: Colors.green,
            unselectedItemColor: Colors.grey,
            elevation: 0,
            backgroundColor: Colors.transparent,
            onTap: (index) {
              switch (index) {
                case 0:
                  Navigator.pushReplacementNamed(context, AppRoutes.homeFeedScreen);
                  break;
                case 1:
                  Navigator.pushReplacementNamed(context, AppRoutes.findOpponentsScreen);
                  break;
                case 2:
                  Navigator.pushReplacementNamed(context, AppRoutes.tournamentListScreen);
                  break;
                case 3:
                  Navigator.pushReplacementNamed(context, AppRoutes.clubProfileScreen);
                  break;
                case 4:
                  // Already on profile
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

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      elevation: 0,
      title: Text('Hồ sơ cá nhân', style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: _showQRCode,
          icon: CustomIconWidget(iconName: 'qr_code', color: AppTheme.lightTheme.colorScheme.primary),
          tooltip: 'Mã QR',
        ),
        IconButton(
          onPressed: _showMoreOptions,
          icon: CustomIconWidget(iconName: 'more_vert'),
          tooltip: 'Tùy chọn khác',
        ),
      ],
    );
  }

  void _showEditProfileModal() {
     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Chức năng sẽ sớm được cập nhật')));
  }

  void _changeCoverPhoto() {
     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Chức năng sẽ sớm được cập nhật')));
  }

  void _changeAvatar() {
     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Chức năng sẽ sớm được cập nhật')));
  }

  void _showQRCode() {
    if (_userProfile == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QRCodeWidget(
        userData: _userProfile!.toJson(),
        onClose: () => Navigator.pop(context),
      ),
    );
  }

  void _showMoreOptions() {
     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Chức năng sẽ sớm được cập nhật')));
  }

  void _viewAllAchievements() {
     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Chức năng sẽ sớm được cập nhật')));
  }

  void _viewFriendsList() {
     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Chức năng sẽ sớm được cập nhật')));
  }

  void _viewRecentChallenges() {
     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Chức năng sẽ sớm được cập nhật')));
  }

  void _viewTournamentHistory() {
     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Chức năng sẽ sớm được cập nhật')));
  }

  void _openAccountSettings() {
     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Chức năng sẽ sớm được cập nhật')));
  }

  void _openPrivacySettings() {
     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Chức năng sẽ sớm được cập nhật')));
  }

  void _openNotificationSettings() {
     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Chức năng sẽ sớm được cập nhật')));
  }

  void _openLanguageSettings() {
     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Chức năng sẽ sớm được cập nhật')));
  }

  void _openPaymentHistory() {
     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Chức năng sẽ sớm được cập nhật')));
  }

  void _openHelpSupport() {
     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Chức năng sẽ sớm được cập nhật')));
  }

  void _openAbout() {
     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('SABO Arena v1.0.0')));
  }

  void _handleLogout() async {
    HapticFeedback.mediumImpact();
    try {
      await _authService.signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.loginScreen, (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi đăng xuất: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}