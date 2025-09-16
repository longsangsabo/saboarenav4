import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/achievements_section_widget.dart';
import './widgets/profile_header_widget.dart';
import './widgets/qr_code_widget.dart';
import './widgets/settings_menu_widget.dart';
import './widgets/social_features_widget.dart';
import './widgets/statistics_cards_widget.dart';

// Backend imports
import '../../services/auth_service.dart';
import '../../repositories/user_repository.dart';
import '../../repositories/achievement_repository.dart';
import '../../repositories/social_repository.dart';

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

  // Repositories
  final UserRepository _userRepository = UserRepository();
  final AchievementRepository _achievementRepository = AchievementRepository();
  final SocialRepository _socialRepository = SocialRepository();

  // Dynamic data from backend
  Map<String, dynamic> userData = {
    "userId": "SABO123456",
    "displayName": "Nguyễn Văn An",
    "bio": "Billiards enthusiast • Tournament player • Rank B",
    "avatar":
        "https://images.pexels.com/photos/1043471/pexels-photo-1043471.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
    "coverPhoto":
        "https://images.pexels.com/photos/1040473/pexels-photo-1040473.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
    "rank": "B",
    "eloRating": 1450,
    "totalMatches": 156,
    "wins": 106,
    "losses": 50,
    "winRate": 68,
    "tournaments": 23,
    "tournamentWins": 5,
    "spaPoints": 2450,
    "favoriteGame": "8-Ball",
    "favoriteGameWins": 78,
    "winStreak": 7,
    "joinDate": "2023-03-15",
    "lastActive": "2025-01-15T06:42:40.084357",
  };

  // Dynamic achievements data from backend
  List<Map<String, dynamic>> achievements = [
    {
      "id": 1,
      "title": "First Win",
      "description": "Giành chiến thắng đầu tiên trong trận đấu",
      "icon": "emoji_events",
      "rarity": "common",
      "isUnlocked": true,
      "unlockedDate": "2023-03-20",
    },
    {
      "id": 2,
      "title": "Tournament Champion",
      "description": "Vô địch giải đấu lần đầu tiên",
      "icon": "military_tech",
      "rarity": "epic",
      "isUnlocked": true,
      "unlockedDate": "2023-06-15",
    },
    {
      "id": 3,
      "title": "Win Streak Master",
      "description": "Thắng 10 trận liên tiếp",
      "icon": "local_fire_department",
      "rarity": "rare",
      "isUnlocked": true,
      "unlockedDate": "2023-08-22",
    },
    {
      "id": 4,
      "title": "Social Butterfly",
      "description": "Kết bạn với 100 người chơi",
      "icon": "people",
      "rarity": "uncommon",
      "isUnlocked": true,
      "unlockedDate": "2023-11-10",
    },
    {
      "id": 5,
      "title": "Legendary Player",
      "description": "Đạt rank A trong hệ thống ELO",
      "icon": "stars",
      "rarity": "legendary",
      "isUnlocked": false,
      "requiredElo": 2200,
    },
    {
      "id": 6,
      "title": "Perfect Game",
      "description": "Hoàn thành trận đấu không để đối thủ ghi điểm",
      "icon": "verified",
      "rarity": "epic",
      "isUnlocked": false,
      "requiredCondition": "Win without opponent scoring",
    },
  ];

  // Dynamic social data from backend
  Map<String, dynamic> socialData = {
    "friendsCount": 127,
    "challengesCount": 45,
    "tournamentsCount": 23,
    "recentFriends": [
      {
        "id": 1,
        "name": "Trần Minh",
        "avatar":
            "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
        "isOnline": true,
        "lastSeen": "2025-01-15T06:30:00.000Z",
      },
      {
        "id": 2,
        "name": "Lê Hương",
        "avatar":
            "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
        "isOnline": false,
        "lastSeen": "2025-01-15T05:15:00.000Z",
      },
      {
        "id": 3,
        "name": "Phạm Đức",
        "avatar":
            "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
        "isOnline": true,
        "lastSeen": "2025-01-15T06:40:00.000Z",
      },
      {
        "id": 4,
        "name": "Ngô Lan",
        "avatar":
            "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
        "isOnline": false,
        "lastSeen": "2025-01-14T22:30:00.000Z",
      },
      {
        "id": 5,
        "name": "Vũ Hải",
        "avatar":
            "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
        "isOnline": true,
        "lastSeen": "2025-01-15T06:35:00.000Z",
      },
    ],
    "recentChallenges": [
      {
        "id": 1,
        "opponentName": "Trần Minh Đức",
        "opponentAvatar":
            "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
        "gameType": "8-Ball",
        "status": "won",
        "date": "Hôm nay",
        "score": "7-3",
      },
      {
        "id": 2,
        "opponentName": "Lê Thị Hương",
        "opponentAvatar":
            "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
        "gameType": "9-Ball",
        "status": "lost",
        "date": "Hôm qua",
        "score": "4-9",
      },
      {
        "id": 3,
        "opponentName": "Phạm Văn Đức",
        "opponentAvatar":
            "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
        "gameType": "10-Ball",
        "status": "pending",
        "date": "2 ngày trước",
        "scheduledTime": "19:00",
      },
    ],
  };

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
      });

      print('🚀 Profile: Loading user data from backend...');
      
      // Get current authenticated user
      final currentUser = AuthService.instance.currentUser;
      
      if (currentUser != null) {
        // Load user profile from repository
        final userProfile = await _userRepository.getCurrentUser();
        
        if (userProfile != null) {
          // Convert UserModel to Map for widgets compatibility
          setState(() {
            userData = {
              "userId": userProfile.id,
              "displayName": userProfile.displayName,
              "bio": userProfile.bio ?? "Billiards enthusiast • Tournament player",
              "avatar": userProfile.avatarUrl ?? "https://images.pexels.com/photos/1043471/pexels-photo-1043471.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
              "coverPhoto": "https://images.pexels.com/photos/1040473/pexels-photo-1040473.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
              "rank": userProfile.rank,
              "eloRating": userProfile.eloRating,
              "totalMatches": 0, // Will be calculated from match history
              "wins": 0, // Will be calculated from match history
              "losses": 0, // Will be calculated from match history  
              "winRate": 0, // Will be calculated from match history
              "tournaments": 0, // Will be loaded separately
              "tournamentWins": 0, // Will be loaded separately
              "spaPoints": userProfile.spaPoints,
              "favoriteGame": "8-Ball", // Default for now
              "favoriteGameWins": 0,
              "winStreak": 0, // Will be calculated from match history
              "joinDate": userProfile.createdAt.toString(),
              "lastActive": userProfile.lastSeen.toString(),
            };
          });
        } else {
          // Fallback to Supabase auth data
          setState(() {
            userData = {
              "userId": currentUser.id,
              "displayName": currentUser.userMetadata?['full_name'] ?? currentUser.userMetadata?['name'] ?? "Player",
              "bio": "New player • Just joined SABO Arena",
              "avatar": currentUser.userMetadata?['avatar_url'] ?? "https://images.pexels.com/photos/1043471/pexels-photo-1043471.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
              "coverPhoto": "https://images.pexels.com/photos/1040473/pexels-photo-1040473.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
              "rank": "E",
              "eloRating": 1200,
              "totalMatches": 0,
              "wins": 0,
              "losses": 0,
              "winRate": 0,
              "tournaments": 0,
              "tournamentWins": 0,
              "spaPoints": 0,
              "favoriteGame": "8-Ball",
              "favoriteGameWins": 0,
              "winStreak": 0,
              "joinDate": currentUser.createdAt,
              "lastActive": DateTime.now().toString(),
            };
          });
        }

        // Load additional data
        await _loadProfileData(currentUser.id);
      } else {
        // No user logged in - use demo data
        print('⚠️ Profile: No authenticated user, using demo data');
        // Keep existing mock data as fallback
      }

      print('✅ Profile: User data loaded successfully');
    } catch (e) {
      print('❌ Profile error: $e');
      // Keep existing mock data on error
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
      print('🚀 Profile: Loading achievements and social data...');
      
      // Load achievements
      final userAchievements = await _achievementRepository.getUserAchievements(userId);
      
      // Load social data
      final friends = await _socialRepository.getFriends(userId);
      final recentChallenges = await _socialRepository.getRecentChallenges(userId);
      final userStats = await _socialRepository.getUserStats(userId);
      
      if (mounted) {
        setState(() {
          // Convert achievements to Map format for widgets
          achievements = userAchievements.map((achievement) => {
            "id": achievement.id,
            "title": achievement.title,
            "description": achievement.description,
            "icon": "emoji_events", // Default icon for now
            "rarity": achievement.rarity,
            "isUnlocked": achievement.isUnlocked,
            "unlockedDate": achievement.unlockedAt?.toString(),
          }).toList();
          
          // Update social data
          socialData = {
            "friendsCount": friends.length,
            "challengesCount": recentChallenges.length,
            "tournamentsCount": userStats['tournaments'] ?? 0,
            "recentFriends": friends.take(5).map((friend) => {
              "id": friend['id'],
              "name": friend['name'],
              "avatar": friend['avatar_url'] ?? "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
              "isOnline": friend['is_online'] ?? false,
              "lastSeen": friend['last_seen'] ?? DateTime.now().toString(),
            }).toList(),
            "recentChallenges": recentChallenges.take(3).map((challenge) => {
              "id": challenge['id'],
              "opponentName": challenge['opponent_name'] ?? "Unknown",
              "opponentAvatar": challenge['opponent_avatar'] ?? "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
              "gameType": challenge['game_type'] ?? "8-Ball",
              "status": challenge['status'] ?? "pending",
              "date": challenge['created_at'] ?? "Recently",
              "score": challenge['score'] ?? "0-0",
            }).toList(),
          };
        });
      }
      
      print('✅ Profile: Additional data loaded successfully');
    } catch (e) {
      print('❌ Profile data error: $e');
      // Keep existing mock data on error
    }
  }

  Future<void> _refreshProfile() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    HapticFeedback.lightImpact();

    try {
      // Reload data from backend
      await _loadUserProfile();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Đã cập nhật thông tin profile từ backend'),
            backgroundColor: AppTheme.lightTheme.colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Lỗi cập nhật: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading spinner while loading data from backend
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
              SizedBox(height: 2.h),
              Text(
                'Đang tải thông tin profile...',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

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
                  // Profile Header
                  ProfileHeaderWidget(
                    userData: userData,
                    onEditProfile: _showEditProfileModal,
                    onCoverPhotoTap: _changeCoverPhoto,
                    onAvatarTap: _changeAvatar,
                  ),

                  SizedBox(height: 3.h),

                  // Statistics Cards
                  StatisticsCardsWidget(userData: userData),

                  SizedBox(height: 4.h),

                  // Achievements Section
                  AchievementsSectionWidget(
                    achievements: achievements,
                    onViewAll: _viewAllAchievements,
                  ),

                  SizedBox(height: 4.h),

                  // Social Features
                  SocialFeaturesWidget(
                    socialData: socialData,
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
      ),
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
          onPressed: _showQRCode,
          icon: CustomIconWidget(
            iconName: 'qr_code',
            color: AppTheme.lightTheme.colorScheme.primary,
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
                    // Edit form would go here
                    Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.primary
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'info',
                            color: AppTheme.lightTheme.colorScheme.primary,
                            size: 24,
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Text(
                              'Chức năng chỉnh sửa hồ sơ sẽ được triển khai trong phiên bản tiếp theo',
                              style: AppTheme.lightTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.primary,
                              ),
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QRCodeWidget(
        userData: userData,
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đang chia sẻ hồ sơ...'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
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

    // Simulate logout process
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đang đăng xuất...'),
        backgroundColor: Colors.red,
      ),
    );

    // In real app, clear user session and navigate to login
    Future.delayed(Duration(seconds: 1), () {
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home-feed-screen',
          (route) => false,
        );
      }
    });
  }
}