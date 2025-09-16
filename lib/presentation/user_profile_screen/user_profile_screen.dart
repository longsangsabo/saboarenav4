import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/app_export.dart';
import '../../models/user_profile.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../services/storage_service.dart';
import '../../services/permission_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import './widgets/achievements_section_widget.dart';
import './widgets/edit_profile_modal.dart';
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
  final ImagePicker _imagePicker = ImagePicker();

  // Dynamic data from backend
  UserProfile? _userProfile;
  Map<String, dynamic> _socialData = {};
  
  // Temporary image states for immediate UI update
  String? _tempCoverPhotoPath;
  String? _tempAvatarPath;

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


}  @override
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
    
    // Merge with temporary images for immediate UI update
    final displayUserData = Map<String, dynamic>.from(userDataMap);
    
    // Map database fields to widget expected keys
    displayUserData['avatar'] = _tempAvatarPath ?? _userProfile!.avatarUrl;
    displayUserData['coverPhoto'] = _tempCoverPhotoPath ?? _userProfile!.coverPhotoUrl;
    displayUserData['displayName'] = _userProfile!.fullName;

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
                    userData: displayUserData,
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
                  Navigator.pushReplacementNamed(context, AppRoutes.clubMainScreen);
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
    if (_userProfile == null) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditProfileModal(
        userProfile: _userProfile!,
        onSave: (updatedProfile) async {
          try {
            // Cập nhật profile qua API
            await _userService.updateUserProfile(
              fullName: updatedProfile.fullName,
              bio: updatedProfile.bio,
              phone: updatedProfile.phone,
              location: updatedProfile.location,
              avatarUrl: updatedProfile.avatarUrl,
            );
            
            // Refresh local data
            await _loadUserProfile();
            
            if (mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('✅ Cập nhật hồ sơ thành công'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('❌ Lỗi cập nhật hồ sơ: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  void _changeCoverPhoto() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Thay đổi ảnh bìa',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImageSourceOption(
                  icon: Icons.camera_alt,
                  label: 'Chụp ảnh',
                  onTap: () => _pickCoverPhotoFromCamera(),
                ),
                _buildImageSourceOption(
                  icon: Icons.photo_library,
                  label: 'Chọn ảnh',
                  onTap: () => _pickCoverPhotoFromGallery(),
                ),
              ],
            ),
            SizedBox(height: 30),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Hủy',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _changeAvatar() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Thay đổi ảnh đại diện',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImageSourceOption(
                  icon: Icons.camera_alt,
                  label: 'Chụp ảnh',
                  onTap: () => _pickAvatarFromCamera(),
                ),
                _buildImageSourceOption(
                  icon: Icons.photo_library,
                  label: 'Chọn ảnh',
                  onTap: () => _pickAvatarFromGallery(),
                ),
                if (_userProfile?.avatarUrl != null)
                  _buildImageSourceOption(
                    icon: Icons.delete,
                    label: 'Xóa ảnh',
                    onTap: () => _removeAvatar(),
                    color: Colors.red,
                  ),
              ],
            ),
            SizedBox(height: 30),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Hủy',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // Cover Photo Functions
  Future<void> _pickCoverPhotoFromCamera() async {
    Navigator.pop(context); // Đóng bottom sheet
    
    try {
      // Kiểm tra quyền camera
      final cameraGranted = await PermissionService.checkCameraPermission();
      if (!cameraGranted) {
        _showErrorMessage('Cần cấp quyền truy cập camera để chụp ảnh');
        return;
      }

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _tempCoverPhotoPath = image.path;
        });
        _showSuccessMessage('✅ Đã chọn ảnh bìa từ camera');
        // TODO: Upload to Supabase and update user profile
        _uploadCoverPhoto(image.path);
      }
    } catch (e) {
      _showErrorMessage('Lỗi khi chụp ảnh: $e');
    }
  }

  Future<void> _pickCoverPhotoFromGallery() async {
    Navigator.pop(context); // Đóng bottom sheet
    
    try {
      // Kiểm tra quyền truy cập thư viện ảnh
      final photosGranted = await PermissionService.checkPhotosPermission();
      if (!photosGranted) {
        _showPermissionDialog();
        return;
      }

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _tempCoverPhotoPath = image.path;
        });
        _showSuccessMessage('✅ Đã chọn ảnh bìa từ thư viện');
        // TODO: Upload to Supabase and update user profile
        _uploadCoverPhoto(image.path);
      }
    } catch (e) {
      _showErrorMessage('Lỗi khi chọn ảnh: $e');
    }
  }

  // Avatar Functions
  Future<void> _pickAvatarFromCamera() async {
    Navigator.pop(context); // Đóng bottom sheet
    
    try {
      // Kiểm tra quyền camera
      final cameraGranted = await PermissionService.checkCameraPermission();
      if (!cameraGranted) {
        _showErrorMessage('Cần cấp quyền truy cập camera để chụp ảnh');
        return;
      }

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _tempAvatarPath = image.path;
        });
        _showSuccessMessage('✅ Đã chọn ảnh đại diện từ camera');
        // TODO: Upload to Supabase and update user profile
        _uploadAvatar(image.path);
      }
    } catch (e) {
      _showErrorMessage('Lỗi khi chụp ảnh: $e');
    }
  }

  Future<void> _pickAvatarFromGallery() async {
    Navigator.pop(context); // Đóng bottom sheet
    
    try {
      // Kiểm tra quyền truy cập thư viện ảnh
      final photosGranted = await PermissionService.checkPhotosPermission();
      if (!photosGranted) {
        _showPermissionDialog();
        return;
      }

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _tempAvatarPath = image.path;
        });
        _showSuccessMessage('✅ Đã chọn ảnh đại diện từ thư viện');
        // TODO: Upload to Supabase and update user profile
        _uploadAvatar(image.path);
      }
    } catch (e) {
      _showErrorMessage('Lỗi khi chọn ảnh: $e');
    }
  }

  void _removeAvatar() {
    Navigator.pop(context); // Đóng bottom sheet
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xóa ảnh đại diện'),
        content: Text('Bạn có chắc chắn muốn xóa ảnh đại diện không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _tempAvatarPath = null;
              });
              _showSuccessMessage('✅ Đã xóa ảnh đại diện');
              // TODO: Remove from Supabase and update user profile
              _removeAvatarFromServer();
            },
            child: Text(
              'Xóa',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  // Upload functions
  Future<void> _uploadCoverPhoto(String imagePath) async {
    try {
      print('🚀 Uploading cover photo: $imagePath');
      
      // Get old cover photo URL to delete later
      final oldCoverUrl = _userProfile?.coverPhotoUrl ?? '';
      
      // Upload to Supabase Storage and update database
      final newCoverUrl = await StorageService.uploadCoverPhoto(File(imagePath));
      
      if (newCoverUrl != null) {
        // Delete old cover photo if exists
        if (oldCoverUrl.isNotEmpty) {
          StorageService.deleteOldCoverPhoto(oldCoverUrl);
        }
        
        // Update local state with new URL
        setState(() {
          _tempCoverPhotoPath = null; // Clear temp path
          if (_userProfile != null) {
            _userProfile = _userProfile!.copyWith(coverPhotoUrl: newCoverUrl);
          }
        });
        
        _showSuccessMessage('✅ Ảnh bìa đã được lưu thành công!');
      } else {
        _showErrorMessage('❌ Không thể tải lên ảnh bìa. Vui lòng thử lại.');
      }
    } catch (e) {
      print('❌ Cover photo upload error: $e');
      _showErrorMessage('Lỗi khi tải ảnh bìa: $e');
    }
  }

  Future<void> _uploadAvatar(String imagePath) async {
    try {
      print('🚀 Uploading avatar: $imagePath');
      
      // Get old avatar URL to delete later
      final oldAvatarUrl = _userProfile?.avatarUrl ?? '';
      
      // Upload to Supabase Storage and update database
      final newAvatarUrl = await StorageService.uploadAvatar(File(imagePath));
      
      if (newAvatarUrl != null) {
        // Delete old avatar if exists
        if (oldAvatarUrl.isNotEmpty) {
          StorageService.deleteOldAvatar(oldAvatarUrl);
        }
        
        // Update local state with new URL
        setState(() {
          _tempAvatarPath = null; // Clear temp path
          if (_userProfile != null) {
            _userProfile = _userProfile!.copyWith(avatarUrl: newAvatarUrl);
          }
        });
        
        _showSuccessMessage('✅ Ảnh đại diện đã được lưu thành công!');
      } else {
        _showErrorMessage('❌ Không thể tải lên ảnh đại diện. Vui lòng thử lại.');
      }
    } catch (e) {
      print('❌ Avatar upload error: $e');
      _showErrorMessage('Lỗi khi tải ảnh đại diện: $e');
    }
  }

  Future<void> _removeAvatarFromServer() async {
    try {
      print('🚀 Removing avatar from server');
      
      final oldAvatarUrl = _userProfile?.avatarUrl ?? '';
      
      if (oldAvatarUrl.isNotEmpty) {
        // Delete from storage
        await StorageService.deleteOldAvatar(oldAvatarUrl);
        
        // Update user profile in database to remove avatar URL
        final user = Supabase.instance.client.auth.currentUser;
        if (user != null) {
          await Supabase.instance.client
              .from('users')
              .update({'avatar_url': null, 'updated_at': DateTime.now().toIso8601String()})
              .eq('id', user.id);
        }
        
        // Update local state
        setState(() {
          _tempAvatarPath = null;
          if (_userProfile != null) {
            _userProfile = _userProfile!.copyWith(avatarUrl: null);
          }
        });
        
        _showSuccessMessage('✅ Đã xóa ảnh đại diện');
      }
    } catch (e) {
      print('❌ Avatar removal error: $e');
      _showErrorMessage('Lỗi khi xóa ảnh đại diện: $e');
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cần cấp quyền truy cập'),
          content: const Text(
            'Ứng dụng cần quyền truy cập thư viện ảnh để bạn có thể chọn ảnh.\n\n'
            'Vui lòng vào:\n'
            'Cài đặt > Ứng dụng > SABO Arena > Quyền\n'
            'và bật quyền "Ảnh và phương tiện"',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                PermissionService.openDeviceAppSettings(); // Mở cài đặt ứng dụng
              },
              child: const Text('Mở cài đặt'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }



  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (color ?? Colors.green).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color ?? Colors.green, size: 30),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: color ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
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
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Tùy chọn khác',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            _buildOptionItem(
              icon: Icons.share,
              title: 'Chia sẻ hồ sơ',
              subtitle: 'Chia sẻ hồ sơ của bạn với bạn bè',
              onTap: () {
                Navigator.pop(context);
                _shareProfile();
              },
            ),
            _buildOptionItem(
              icon: Icons.bookmark,
              title: 'Lưu hồ sơ',
              subtitle: 'Lưu hồ sơ vào danh sách yêu thích',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('✅ Đã lưu hồ sơ')),
                );
              },
            ),
            _buildOptionItem(
              icon: Icons.copy,
              title: 'Sao chép liên kết',
              subtitle: 'Sao chép đường dẫn đến hồ sơ',
              onTap: () {
                Navigator.pop(context);
                _copyProfileLink();
              },
            ),
            _buildOptionItem(
              icon: Icons.print,
              title: 'In hồ sơ',
              subtitle: 'In thông tin hồ sơ ra giấy',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('🖨️ Chức năng in sẽ sớm được cập nhật')),
                );
              },
            ),
            _buildOptionItem(
              icon: Icons.backup,
              title: 'Sao lưu dữ liệu',
              subtitle: 'Sao lưu thông tin cá nhân',
              onTap: () {
                Navigator.pop(context);
                _backupData();
              },
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? Colors.blue).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor ?? Colors.blue, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  void _shareProfile() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Chia sẻ hồ sơ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Chọn cách thức chia sẻ hồ sơ của bạn:'),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShareOption(Icons.message, 'Tin nhắn', () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('📱 Chia sẻ qua tin nhắn')),
                  );
                }),
                _buildShareOption(Icons.email, 'Email', () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('📧 Chia sẻ qua email')),
                  );
                }),
                _buildShareOption(Icons.link, 'Liên kết', () {
                  Navigator.pop(context);
                  _copyProfileLink();
                }),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy'),
          ),
        ],
      ),
    );
  }

  Widget _buildShareOption(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.blue, size: 24),
          ),
          SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  void _copyProfileLink() {
    // In a real app, you would use Clipboard.setData()
    // Clipboard.setData(ClipboardData(text: 'https://saboarena.com/profile/${_userProfile?.id}'));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check, color: Colors.white),
            SizedBox(width: 8),
            Text('Đã sao chép liên kết hồ sơ'),
          ],
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _backupData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.backup, color: Colors.blue),
            SizedBox(width: 8),
            Text('Sao lưu dữ liệu'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dữ liệu sẽ được sao lưu bao gồm:'),
            SizedBox(height: 8),
            Text('• Thông tin cá nhân'),
            Text('• Lịch sử thách đấu'),
            Text('• Thành tích đạt được'),
            Text('• Danh sách bạn bè'),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Dữ liệu sẽ được mã hóa và lưu trữ an toàn',
                      style: TextStyle(fontSize: 13, color: Colors.blue.shade700),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('✅ Đã bắt đầu sao lưu dữ liệu'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text('Sao lưu'),
          ),
        ],
      ),
    );
  }

  void _viewAllAchievements() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAchievementsModal(),
    );
  }

  Widget _buildAchievementsModal() {
    // Mock data for achievements
    final achievements = [
      {'title': 'Người mới', 'description': 'Hoàn thành 5 trận đấu đầu tiên', 'icon': '🏆', 'completed': true},
      {'title': 'Chiến thắng đầu tiên', 'description': 'Thắng trận đấu đầu tiên', 'icon': '🥇', 'completed': true},
      {'title': 'Streak Master', 'description': 'Thắng liên tiếp 5 trận', 'icon': '🔥', 'completed': true},
      {'title': 'Tournament Player', 'description': 'Tham gia 10 giải đấu', 'icon': '🏟️', 'completed': false},
      {'title': 'Social Player', 'description': 'Kết bạn với 50 người chơi', 'icon': '👥', 'completed': false},
      {'title': 'Champion', 'description': 'Thắng một giải đấu', 'icon': '👑', 'completed': false},
    ];

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.emoji_events, color: Colors.amber, size: 24),
                Text(
                  'Thành tích của tôi',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close),
                ),
              ],
            ),
          ),
          
          // Achievements List
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: achievements.length,
              itemBuilder: (context, index) {
                final achievement = achievements[index];
                final isCompleted = achievement['completed'] as bool;
                
                return Container(
                  margin: EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isCompleted ? Colors.green.shade50 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isCompleted ? Colors.green.shade200 : Colors.grey.shade300,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: isCompleted ? Colors.green.shade100 : Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            achievement['icon'] as String,
                            style: TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              achievement['title'] as String,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isCompleted ? Colors.green.shade700 : Colors.grey.shade600,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              achievement['description'] as String,
                              style: TextStyle(
                                fontSize: 14,
                                color: isCompleted ? Colors.green.shade600 : Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isCompleted)
                        Icon(Icons.check_circle, color: Colors.green, size: 24),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _viewFriendsList() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFriendsListModal(),
    );
  }

  Widget _buildFriendsListModal() {
    // Mock data for friends list
    final friends = List.generate(15, (index) => {
      'id': 'friend_$index',
      'name': 'Người chơi ${index + 1}',
      'avatar': null,
      'status': index % 3 == 0 ? 'online' : (index % 3 == 1 ? 'offline' : 'in_game'),
      'level': 'Trung bình',
      'lastSeen': index % 3 == 0 ? 'Đang online' : '${index + 1} phút trước',
    });

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.people, color: Colors.blue, size: 24),
                Text(
                  'Bạn bè (${friends.length})',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close),
                ),
              ],
            ),
          ),
          
          // Search bar
          Container(
            padding: EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm bạn bè...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
          ),
          
          // Friends List
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: friends.length,
              itemBuilder: (context, index) {
                final friend = friends[index];
                final status = friend['status'] as String;
                Color statusColor = status == 'online' ? Colors.green : 
                                  status == 'in_game' ? Colors.orange : Colors.grey;
                
                return Container(
                  margin: EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.grey.shade300,
                            child: Icon(Icons.person, color: Colors.white, size: 30),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: statusColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              friend['name'] as String,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              friend['level'] as String,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Text(
                              friend['lastSeen'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton(
                        icon: Icon(Icons.more_vert, color: Colors.grey),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'message',
                            child: Row(
                              children: [
                                Icon(Icons.message, size: 18),
                                SizedBox(width: 8),
                                Text('Nhắn tin'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'challenge',
                            child: Row(
                              children: [
                                Icon(Icons.sports_esports, size: 18),
                                SizedBox(width: 8),
                                Text('Thách đấu'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'profile',
                            child: Row(
                              children: [
                                Icon(Icons.person, size: 18),
                                SizedBox(width: 8),
                                Text('Xem hồ sơ'),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (value) {
                          String action = '';
                          switch (value) {
                            case 'message':
                              action = 'Nhắn tin với ${friend['name']}';
                              break;
                            case 'challenge':
                              action = 'Thách đấu với ${friend['name']}';
                              break;
                            case 'profile':
                              action = 'Xem hồ sơ ${friend['name']}';
                              break;
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(action)),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _viewRecentChallenges() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildChallengesHistoryModal(),
    );
  }

  void _viewTournamentHistory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildTournamentHistoryModal(),
    );
  }

  Widget _buildChallengesHistoryModal() {
    // Mock data for challenges
    final challenges = List.generate(10, (index) => {
      'id': 'challenge_$index',
      'opponent': 'Đối thủ ${index + 1}',
      'result': index % 3 == 0 ? 'won' : (index % 3 == 1 ? 'lost' : 'draw'),
      'score': '${(index % 3) + 1}-${(index % 2) + 1}',
      'date': DateTime.now().subtract(Duration(days: index)),
      'duration': '${15 + (index * 2)} phút',
    });

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.sports_esports, color: Colors.purple, size: 24),
                Text(
                  'Lịch sử thách đấu',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close),
                ),
              ],
            ),
          ),
          
          // Statistics
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.grey.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem('Thắng', challenges.where((c) => c['result'] == 'won').length.toString(), Colors.green),
                _buildStatItem('Hòa', challenges.where((c) => c['result'] == 'draw').length.toString(), Colors.orange),
                _buildStatItem('Thua', challenges.where((c) => c['result'] == 'lost').length.toString(), Colors.red),
              ],
            ),
          ),
          
          // Challenges List
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: challenges.length,
              itemBuilder: (context, index) {
                final challenge = challenges[index];
                final result = challenge['result'] as String;
                final date = challenge['date'] as DateTime;
                
                Color resultColor = result == 'won' ? Colors.green : 
                                   result == 'lost' ? Colors.red : Colors.orange;
                IconData resultIcon = result == 'won' ? Icons.trending_up : 
                                     result == 'lost' ? Icons.trending_down : Icons.trending_flat;
                
                return Container(
                  margin: EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: resultColor.withOpacity(0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: resultColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(resultIcon, color: resultColor, size: 20),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'vs ${challenge['opponent']}',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Tỷ số: ${challenge['score']} • ${challenge['duration']}',
                              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                            ),
                            Text(
                              '${date.day}/${date.month}/${date.year}',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: resultColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          result == 'won' ? 'Thắng' : result == 'lost' ? 'Thua' : 'Hòa',
                          style: TextStyle(
                            color: resultColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
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
    );
  }

  Widget _buildTournamentHistoryModal() {
    // Mock data for tournaments
    final tournaments = List.generate(8, (index) => {
      'id': 'tournament_$index',
      'name': 'Giải đấu ${index + 1}',
      'position': index % 4 + 1,
      'participants': (index + 1) * 8,
      'date': DateTime.now().subtract(Duration(days: index * 7)),
      'prize': index == 0 ? '1.000.000 VND' : index == 1 ? '500.000 VND' : index == 2 ? '250.000 VND' : null,
    });

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.emoji_events, color: Colors.amber, size: 24),
                Text(
                  'Lịch sử giải đấu',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close),
                ),
              ],
            ),
          ),
          
          // Tournaments List
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: tournaments.length,
              itemBuilder: (context, index) {
                final tournament = tournaments[index];
                final position = tournament['position'] as int;
                final date = tournament['date'] as DateTime;
                final prize = tournament['prize'] as String?;
                
                Color positionColor = position == 1 ? Colors.amber : 
                                     position == 2 ? Colors.grey : 
                                     position == 3 ? Colors.brown : 
                                     Colors.grey.shade400;
                IconData positionIcon = position <= 3 ? Icons.emoji_events : Icons.sports_esports;
                
                return Container(
                  margin: EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: positionColor.withOpacity(0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: positionColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(positionIcon, color: positionColor, size: 20),
                            Text(
                              '#$position',
                              style: TextStyle(
                                color: positionColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tournament['name'] as String,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '${tournament['participants']} người tham gia',
                              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                            ),
                            Text(
                              '${date.day}/${date.month}/${date.year}',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                            ),
                            if (prize != null)
                              Container(
                                margin: EdgeInsets.only(top: 4),
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Giải thưởng: $prize',
                                  style: TextStyle(
                                    color: Colors.green.shade700,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
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
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  void _openAccountSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Mở cài đặt tài khoản'))
    );
  }

  void _openPrivacySettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Mở cài đặt quyền riêng tư'))
    );
  }

  void _openNotificationSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Mở cài đặt thông báo'))
    );
  }

  void _openLanguageSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildLanguageSelector(),
    );
  }

  void _openPaymentHistory() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Mở lịch sử thanh toán'))
    );
  }

  void _openHelpSupport() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Mở trợ giúp & hỗ trợ'))
    );
  }

  Widget _buildLanguageSelector() {
    final languages = [
      {'code': 'vi', 'name': 'Tiếng Việt', 'flag': '🇻🇳'},
      {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
      {'code': 'ko', 'name': '한국어', 'flag': '🇰🇷'},
      {'code': 'ja', 'name': '日本語', 'flag': '🇯🇵'},
    ];

    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Chọn ngôn ngữ',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          ...languages.map((lang) => ListTile(
            leading: Text(lang['flag']!, style: TextStyle(fontSize: 24)),
            title: Text(lang['name']!),
            trailing: lang['code'] == 'vi' ? Icon(Icons.check, color: Colors.green) : null,
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('✅ Đã chuyển sang ${lang['name']}')),
              );
            },
          )),
          SizedBox(height: 10),
        ],
      ),
    );
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