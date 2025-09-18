import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'dart:io';

import '../../../core/app_export.dart';
import '../../../core/utils/sabo_rank_system.dart';
import '../../../models/user_profile.dart';
import '../../../services/share_service.dart';
import '../../../widgets/user_qr_code_widget.dart';

import './rank_registration_info_modal.dart';

class ProfileHeaderWidget extends StatelessWidget {
  final Map<String, dynamic> userData;
  final VoidCallback? onEditProfile;
  final VoidCallback? onCoverPhotoTap;
  final VoidCallback? onAvatarTap;

  const ProfileHeaderWidget({
    super.key,
    required this.userData,
    this.onEditProfile,
    this.onCoverPhotoTap,
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Cover Photo Section
          _buildCoverPhotoSection(context),

          // Profile Info Section
          _buildProfileInfoSection(context),

          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildCoverPhotoSection(BuildContext context) {
    return SizedBox(
      height: 25.h,
      width: double.infinity,
      child: Stack(
        children: [
          // Cover Photo
          GestureDetector(
            onTap: onCoverPhotoTap,
            child: Container(
              height: 20.h,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: _buildImageWidget(
                  imageUrl: userData["coverPhoto"] as String? ??
                      "https://images.pexels.com/photos/1040473/pexels-photo-1040473.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
                  width: double.infinity,
                  height: 20.h,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Cover Photo Edit Button
          Positioned(
            top: 2.h,
            right: 4.w,
            child: GestureDetector(
              onTap: onCoverPhotoTap,
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface
                      .withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: CustomIconWidget(
                  iconName: 'camera_alt',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 20,
                ),
              ),
            ),
          ),

          // Avatar Section
          Positioned(
            bottom: 0,
            left: 6.w,
            child: _buildAvatarSection(context),
          ),

          // Action Buttons (QR, Share, Edit)
          Positioned(
            bottom: 1.h,
            right: 4.w,
            child: _buildActionButtons(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarSection(BuildContext context) {
    return GestureDetector(
      onTap: onAvatarTap,
      child: Container(
        width: 20.w,
        height: 20.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppTheme.lightTheme.colorScheme.surface,
            width: 4,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            ClipOval(
              child: _buildImageWidget(
                imageUrl: userData["avatar"] as String? ??
                    "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
                width: 20.w,
                height: 20.w,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.lightTheme.colorScheme.surface,
                    width: 2,
                  ),
                ),
                child: CustomIconWidget(
                  iconName: 'camera_alt',
                  color: AppTheme.lightTheme.colorScheme.onPrimary,
                  size: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // QR Code Button
        _buildActionButton(
          context: context,
          icon: 'qr_code',
          label: 'QR',
          onTap: () => _showQRCode(context),
          backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
        ),
        
        SizedBox(width: 2.w),
        
        // Share Button
        _buildActionButton(
          context: context,
          icon: 'share',
          label: 'Chia sẻ',
          onTap: () => _shareProfile(context),
          backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
        ),
        
        SizedBox(width: 2.w),
        
        // Edit Button
        _buildActionButton(
          context: context,
          icon: 'edit',
          label: 'Sửa',
          onTap: onEditProfile,
          backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String icon,
    required String label,
    required VoidCallback? onTap,
    required Color backgroundColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: icon,
              color: AppTheme.lightTheme.colorScheme.onPrimary,
              size: 16,
            ),
            SizedBox(width: 1.w),
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showQRCode(BuildContext context) {
    try {
      // Convert userData to UserProfile
      final userProfile = UserProfile(
        id: userData['id'] ?? '',
        email: userData['email'] ?? '',
        fullName: userData['displayName'] ?? userData['full_name'] ?? 'Unknown User',
        username: userData['username'],
        bio: userData['bio'],
        avatarUrl: userData['avatar'],
        coverPhotoUrl: userData['coverPhoto'],
        phone: userData['phone'],
        dateOfBirth: userData['dateOfBirth'] != null 
            ? DateTime.tryParse(userData['dateOfBirth']) 
            : null,
        role: userData['role'] ?? 'player',
        skillLevel: userData['skillLevel'] ?? 'beginner',
        rank: userData['rank'],
        totalWins: userData['totalWins'] ?? 0,
        totalLosses: userData['totalLosses'] ?? 0,
        totalTournaments: userData['totalTournaments'] ?? 0,
        eloRating: userData['eloRating'] ?? 1200,
        spaPoints: userData['spaPoints'] ?? 0,
        totalPrizePool: (userData['totalPrizePool'] ?? 0.0).toDouble(),
        isVerified: userData['isVerified'] ?? false,
        isActive: userData['isActive'] ?? true,
        location: userData['location'],
        createdAt: userData['createdAt'] != null 
            ? DateTime.tryParse(userData['createdAt']) ?? DateTime.now()
            : DateTime.now(),
        updatedAt: userData['updatedAt'] != null 
            ? DateTime.tryParse(userData['updatedAt']) ?? DateTime.now()
            : DateTime.now(),
      );

      // Show QR Code bottom sheet
      UserQRCodeBottomSheet.show(context, userProfile);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi hiển thị QR Code: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _shareProfile(BuildContext context) async {
    try {
      // Convert userData to UserProfile for sharing
      final userProfile = UserProfile(
        id: userData['id'] ?? '',
        email: userData['email'] ?? '',
        fullName: userData['displayName'] ?? userData['full_name'] ?? 'Unknown User',
        username: userData['username'],
        bio: userData['bio'],
        avatarUrl: userData['avatar'],
        coverPhotoUrl: userData['coverPhoto'],
        phone: userData['phone'],
        dateOfBirth: userData['dateOfBirth'] != null 
            ? DateTime.tryParse(userData['dateOfBirth']) 
            : null,
        role: userData['role'] ?? 'player',
        skillLevel: userData['skillLevel'] ?? 'beginner',
        rank: userData['rank'],
        totalWins: userData['totalWins'] ?? 0,
        totalLosses: userData['totalLosses'] ?? 0,
        totalTournaments: userData['totalTournaments'] ?? 0,
        eloRating: userData['eloRating'] ?? 1200,
        spaPoints: userData['spaPoints'] ?? 0,
        totalPrizePool: (userData['totalPrizePool'] ?? 0.0).toDouble(),
        isVerified: userData['isVerified'] ?? false,
        isActive: userData['isActive'] ?? true,
        location: userData['location'],
        createdAt: userData['createdAt'] != null 
            ? DateTime.tryParse(userData['createdAt']) ?? DateTime.now()
            : DateTime.now(),
        updatedAt: userData['updatedAt'] != null 
            ? DateTime.tryParse(userData['updatedAt']) ?? DateTime.now()
            : DateTime.now(),
      );

      // Share user profile
      await ShareService.shareUserProfile(userProfile);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi chia sẻ hồ sơ: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildProfileInfoSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name and Rank
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userData["displayName"] as String? ?? "Nguyễn Văn An",
                      style:
                          AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      userData["bio"] as String? ??
                          "Billiards enthusiast • Tournament player",
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 4.w),
              _buildRankBadge(context),
            ],
          ),

          SizedBox(height: 2.h),

          // ELO Rating with Progress
          _buildEloSection(context),

          SizedBox(height: 2.h),

          // SPA Points and Prize Pool Section
          _buildSpaAndPrizeSection(context),
        ],
      ),
    );
  }

  Widget _buildRankBadge(BuildContext context) {
    final userRank = userData["rank"] as String?;
    final hasRank = userRank != null && userRank.isNotEmpty && userRank != 'unranked';

    // Bọc toàn bộ widget bằng GestureDetector để có thể nhấn vào
    return GestureDetector(
      onTap: () {
        if (hasRank) {
          // Người dùng đã có rank, có thể hiển thị thông tin chi tiết về rank
          _showRankDetails(context);
        } else {
          // Người dùng chưa có rank, hiển thị modal đăng ký
          _showRankInfoModal(context);
        }
      },
      child: _buildRankContent(context, hasRank, userRank),
    );
  }

  // Tách riêng nội dung của rank badge để dễ quản lý
  Widget _buildRankContent(BuildContext context, bool hasRank, String? userRank) {
    if (!hasRank) {
      // Giao diện khi người dùng CHƯA CÓ RANK
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.lightTheme.colorScheme.primary.withOpacity(0.7), 
            width: 1.5,
          ),
           boxShadow: [
            BoxShadow(
              color: AppTheme.lightTheme.colorScheme.primary.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'RANK',
              style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.primary,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 0.5.h),
            Text(
              '?',
              style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    // Giao diện khi người dùng ĐÃ CÓ RANK
    final currentElo = userData["elo_rating"] as int? ?? 1200;
    final rank = SaboRankSystem.getRankFromElo(currentElo);
    final rankColor = SaboRankSystem.getRankColor(rank);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color: rankColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: rankColor, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'RANK',
            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
              color: rankColor,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            userRank!, // an toàn vì đã check hasRank
            style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
              color: rankColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showRankInfoModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RankRegistrationInfoModal(
        onStartRegistration: () {
          Navigator.pop(context); // Đóng modal trước khi điều hướng
          Navigator.pushNamed(context, AppRoutes.clubSelectionScreen);
        },
      ),
    );
  }

  void _showRankDetails(BuildContext context) {
    // Sẽ triển khai sau nếu cần
    print("TODO: Show Rank Details");
  }

  Widget _buildEloSection(BuildContext context) {
    // Lấy ELO từ elo_rating
    final currentElo = userData["elo_rating"] as int? ?? 1200;
    final nextRankInfo = SaboRankSystem.getNextRankInfo(currentElo);
    final progress = SaboRankSystem.getRankProgress(currentElo);
    final currentRank = SaboRankSystem.getRankFromElo(currentElo);
    final skillDescription = SaboRankSystem.getRankSkillDescription(currentRank);

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ELO Rating',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                SaboRankSystem.formatElo(currentElo),
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          SizedBox(height: 0.5.h),

          // Skill description
          Text(
            skillDescription,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          SizedBox(height: 1.h),

          // Progress Bar
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),

          SizedBox(height: 0.5.h),

          Text(
            nextRankInfo['pointsNeeded'] > 0 
              ? 'Next rank ${nextRankInfo['nextRank']}: ${nextRankInfo['pointsNeeded']} points to go'
              : 'Đã đạt rank cao nhất!',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpaAndPrizeSection(BuildContext context) {
    final spaPoints = userData["spa_points"] as int? ?? 0;
    final totalPrizePool = userData["total_prize_pool"] as double? ?? 0.0;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primaryContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // SPA Points
          Expanded(
            child: _buildStatItem(
              context,
              icon: 'star',
              label: 'SPA Points',
              value: _formatNumber(spaPoints),
              iconColor: Colors.amber[600]!,
            ),
          ),
          
          SizedBox(width: 4.w),
          
          // Prize Pool
          Expanded(
            child: _buildStatItem(
              context,
              icon: 'monetization_on',
              label: 'Prize Pool',
              value: '\$${_formatCurrency(totalPrizePool)}',
              iconColor: Colors.green[600]!,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required String icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Column(
      children: [
        CustomIconWidget(
          iconName: icon,
          color: iconColor,
          size: 24,
        ),
        SizedBox(height: 0.5.h),
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface.withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 0.2.h),
        Text(
          value,
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toString();
    }
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    } else if (amount == amount.toInt()) {
      return amount.toInt().toString();
    } else {
      return amount.toStringAsFixed(2);
    }
  }

  Widget _buildImageWidget({
    required String imageUrl,
    required double width,
    required double height,
    BoxFit fit = BoxFit.cover,
  }) {
    // Check if it's a local file path
    if (imageUrl.startsWith('/') || imageUrl.contains('\\')) {
      // Local file path
      return Image.file(
        File(imageUrl),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          // Fallback to network image if file doesn't exist
          return CustomImageWidget(
            imageUrl: "https://images.pexels.com/photos/1040473/pexels-photo-1040473.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
            width: width,
            height: height,
            fit: fit,
          );
        },
      );
    } else {
      // Network URL
      return CustomImageWidget(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
      );
    }
  }
}
