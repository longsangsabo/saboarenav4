import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../models/user_profile.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../widgets/custom_bottom_bar.dart';
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

  // Real user data from database
  UserProfile? _userProfile;
  Map<String, dynamic>? _userData;
  Map<String, dynamic> _socialData = {};
  String? _errorMessage;

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
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Check if user is authenticated
      if (!AuthService.instance.isAuthenticated) {
        setState(() {
          _errorMessage = 'User not authenticated';
          _isLoading = false;
        });
        return;
      }

      // Get current user profile from database
      final userProfile = await UserService.instance.getCurrentUserProfile();

      if (userProfile != null) {
        final followCounts =
            await UserService.instance.getUserFollowCounts(userProfile.id);
        final userStats =
            await UserService.instance.getUserStats(userProfile.id);
        final ranking =
            await UserService.instance.getUserRanking(userProfile.id);

        setState(() {
          _userProfile = userProfile;
          _userData = {
            "userId": userProfile.id,
            "displayName": userProfile.username ?? userProfile.fullName,
            "fullName": userProfile.fullName,
            "bio": userProfile.bio ??
                "SABO Arena player • ${userProfile.skillLevelDisplay}",
            "avatar": userProfile.avatarUrl,
            "coverPhoto": null, // Can be added to database schema later
            "rank": 'N/A', // Default rank value since not available in UserProfile
            "eloRating": userProfile.rankingPoints, // Use rankingPoints as elo rating
            "totalMatches": userStats['total_matches'] ?? 0,
            "wins": userProfile.totalWins,
            "losses": userProfile.totalLosses,
            "winRate": userProfile.winRate.round(),
            "tournaments": userProfile.totalTournaments,
            "tournamentWins": 0, // Default value since not available in UserProfile
            "spaPoints": userProfile.rankingPoints, // Use rankingPoints as spa points
            "favoriteGame": 'Pool', // Default value since not available in UserProfile
            "favoriteGameWins": userProfile.totalWins, // Simplified for now
            "winStreak": 0, // Default value since not available in UserProfile
            "joinDate": userProfile.createdAt.toIso8601String(),
            "lastActive": userProfile.updatedAt.toIso8601String(),
            "ranking": ranking,
          };

          _socialData = {
            "friendsCount": followCounts['followers'] ?? 0,
            "followingCount": followCounts['following'] ?? 0,
            "challengesCount": userStats['total_matches'] ?? 0,
            "tournamentsCount": userProfile.totalTournaments,
            "recentFriends": [], // Will be loaded separately
            "recentChallenges": [], // Will be loaded separately
          };

          _isLoading = false;
        });

        // Load additional social data
        _loadSocialData();
      } else {
        setState(() {
          _errorMessage = 'User profile not found';
          _isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'Failed to load user profile: $error';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadSocialData() async {
    try {
      if (_userProfile == null) return;

      final followers = await UserService.instance
          .getUserFollowers(_userProfile!.id, limit: 5);
      final following = await UserService.instance
          .getUserFollowing(_userProfile!.id, limit: 5);

      setState(() {
        _socialData['recentFriends'] = followers
            .map((user) => {
                  "id": user.id,
                  "name": user.username ?? user.fullName,
                  "avatar": user.avatarUrl,
                  "isOnline": false, // Default value since not available in UserProfile
                  "lastSeen": user.updatedAt.toIso8601String(), // Use updatedAt as lastSeen
                })
            .toList();

        // Mock recent challenges for now - can be implemented with matches table
        _socialData['recentChallenges'] = [];
      });
    } catch (error) {
      print('Failed to load social data: $error');
    }
  }

  Future<void> _refreshProfile() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    HapticFeedback.lightImpact();

    try {
      await _loadUserProfile();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã cập nhật thông tin profile'),
          backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi cập nhật: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: CustomBottomBar(
        currentRoute: '/user-profile-screen',
        onTap: (route) {
          if (route != '/user-profile-screen') {
            Navigator.pushNamedAndRemoveUntil(
              context,
              route,
              (route) => false,
            );
          }
        },
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
            SizedBox(height: 2.h),
            Text(
              'Đang tải thông tin profile...',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'error_outline',
              color: Colors.red,
              size: 48,
            ),
            SizedBox(height: 2.h),
            Text(
              'Lỗi tải dữ liệu',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: Colors.red,
              ),
            ),
            SizedBox(height: 3.h),
            ElevatedButton.icon(
              onPressed: _loadUserProfile,
              icon: CustomIconWidget(
                iconName: 'refresh',
                color: Colors.white,
                size: 20,
              ),
              label: Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                foregroundColor: Colors.white,
              ),
            ),
            if (!AuthService.instance.isAuthenticated) ...[
              SizedBox(height: 2.h),
              TextButton.icon(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login-screen',
                    (route) => false,
                  );
                },
                icon: CustomIconWidget(
                  iconName: 'login',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 20,
                ),
                label: Text('Đăng nhập'),
              ),
            ],
          ],
        ),
      );
    }

    if (_userData == null) {
      return Center(
        child: Text(
          'Không có dữ liệu profile',
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshProfile,
      color: AppTheme.lightTheme.colorScheme.primary,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header
                ProfileHeaderWidget(
                  userData: _userData!,
                  onEditProfile: _showEditProfileModal,
                  onCoverPhotoTap: _changeCoverPhoto,
                  onAvatarTap: _changeAvatar,
                ),

                SizedBox(height: 3.h),

                // Statistics Cards
                StatisticsCardsWidget(userId: _userData!["userId"] as String),

                SizedBox(height: 4.h),

                // Achievements Section
                AchievementsSectionWidget(
                  userId: _userData!["userId"] as String,
                  onViewAll: _viewAllAchievements,
                ),

                SizedBox(height: 4.h),

                // Social Features
                SocialFeaturesWidget(
                  socialData: _socialData,
                  onFriendsListTap: _viewFriendsList,
                  onRecentChallengesTap: _viewRecentChallenges,
                  onTournamentHistoryTap: _viewTournamentHistory,
                ),

                SizedBox(height: 4.h),

                // Settings Menu
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

                SizedBox(height: 10.h), // Bottom padding for navigation
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      elevation: 0,
      title: Text(
        'Hồ sơ cá nhân',
        style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppTheme.lightTheme.colorScheme.onSurface,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: _userData != null ? _showQRCode : null,
          icon: CustomIconWidget(
            iconName: 'qr_code',
            color: _userData != null
                ? AppTheme.lightTheme.colorScheme.primary
                : AppTheme.lightTheme.colorScheme.outline,
            size: 24,
          ),
          tooltip: 'Mã QR',
        ),
        IconButton(
          onPressed: _showMoreOptions,
          icon: CustomIconWidget(
            iconName: 'more_vert',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 24,
          ),
          tooltip: 'Tùy chọn khác',
        ),
      ],
    );
  }

  void _showEditProfileModal() {
    if (_userData == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 80.h,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle Bar
            Container(
              margin: EdgeInsets.only(top: 2.h),
              width: 12.w,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Chỉnh sửa hồ sơ',
                    style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: CustomIconWidget(
                      iconName: 'close',
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Column(
                  children: [
                    // Show current user info
                    Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Thông tin hiện tại:',
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text('Tên: ${_userProfile?.fullName ?? 'N/A'}'),
                          Text(
                              'Username: ${_userProfile?.username ?? 'Chưa đặt'}'),
                          Text('Email: ${_userProfile?.email ?? 'N/A'}'),
                          Text(
                              'Skill Level: ${_userProfile?.skillLevelDisplay ?? 'N/A'}'),
                          Text('Rank: ${'N/A'}'), // Default rank display
                          Text('Bio: ${_userProfile?.bio ?? 'Chưa có'}'),
                          SizedBox(height: 2.h),
                          Text(
                            'Chức năng chỉnh sửa sẽ được cập nhật trong phiên bản tiếp theo',
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              fontStyle: FontStyle.italic,
                              color: AppTheme
                                  .lightTheme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _changeCoverPhoto() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Chức năng thay đổi ảnh bìa sẽ được cập nhật sớm'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );
  }

  void _changeAvatar() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Chức năng thay đổi avatar sẽ được cập nhật sớm'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );
  }

  void _showQRCode() {
    if (_userData == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QRCodeWidget(
        userData: _userData!,
        onClose: () => Navigator.pop(context),
      ),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.only(top: 2.h),
              width: 12.w,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'share',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: Text('Chia sẻ hồ sơ'),
              onTap: () {
                Navigator.pop(context);
                _shareProfile();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'refresh',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: Text('Làm mới dữ liệu'),
              onTap: () {
                Navigator.pop(context);
                _refreshProfile();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'report',
                color: Colors.red,
                size: 24,
              ),
              title: Text('Báo cáo vấn đề'),
              onTap: () {
                Navigator.pop(context);
                _reportIssue();
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  void _shareProfile() {
    HapticFeedback.lightImpact();
    final profileUrl = 'sabo://user/${_userProfile?.id}';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Profile URL: $profileUrl'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        action: SnackBarAction(
          label: 'Copy',
          onPressed: () {
            Clipboard.setData(ClipboardData(text: profileUrl));
          },
        ),
      ),
    );
  }

  void _reportIssue() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Chức năng báo cáo sẽ được cập nhật sớm'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _viewAllAchievements() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đang mở danh sách thành tích...'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );
  }

  void _viewFriendsList() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đang mở danh sách bạn bè...'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );
  }

  void _viewRecentChallenges() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đang mở lịch sử thách đấu...'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );
  }

  void _viewTournamentHistory() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đang mở lịch sử giải đấu...'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );
  }

  void _openAccountSettings() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đang mở cài đặt tài khoản...'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );
  }

  void _openPrivacySettings() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đang mở cài đặt quyền riêng tư...'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );
  }

  void _openNotificationSettings() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đang mở cài đặt thông báo...'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );
  }

  void _openLanguageSettings() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đang mở cài đặt ngôn ngữ...'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );
  }

  void _openPaymentHistory() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đang mở lịch sử thanh toán...'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );
  }

  void _openHelpSupport() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đang mở trợ giúp & hỗ trợ...'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );
  }

  void _openAbout() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('SABO Arena v1.0.0 - Billiards Social Network'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );
  }

  void _handleLogout() {
    HapticFeedback.mediumImpact();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Xác nhận đăng xuất'),
          content: Text('Bạn có chắc muốn đăng xuất khỏi tài khoản?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);

                try {
                  await AuthService.instance.signOut();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đã đăng xuất thành công'),
                      backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                    ),
                  );

                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login-screen',
                    (route) => false,
                  );
                } catch (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Lỗi đăng xuất: $error'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('Đăng xuất'),
            ),
          ],
        );
      },
    );
  }
}