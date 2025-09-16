import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'dart:io';

import '../../../core/app_export.dart';
import '../../../core/utils/sabo_rank_system.dart';

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

          // Edit Profile Button
          Positioned(
            bottom: 1.h,
            right: 4.w,
            child: _buildEditButton(context),
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

  Widget _buildEditButton(BuildContext context) {
    return GestureDetector(
      onTap: onEditProfile,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.primary,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.lightTheme.colorScheme.primary
                  .withValues(alpha: 0.3),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: 'edit',
              color: AppTheme.lightTheme.colorScheme.onPrimary,
              size: 16,
            ),
            SizedBox(width: 2.w),
            Text(
              'Chỉnh sửa',
              style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
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
        ],
      ),
    );
  }

  Widget _buildRankBadge(BuildContext context) {
    // Lấy ELO từ userData (ranking_points)
    final currentElo = userData["ranking_points"] as int? ?? 1000;
    final rank = SaboRankSystem.getRankFromElo(currentElo);
    final rankColor = SaboRankSystem.getRankColor(rank);
    final skillDescription = SaboRankSystem.getRankSkillDescription(rank);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: rankColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: rankColor, width: 2),
      ),
      child: Column(
        children: [
          Text(
            'RANK',
            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
              color: rankColor,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          Text(
            rank,
            style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
              color: rankColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEloSection(BuildContext context) {
    // Lấy ELO từ ranking_points
    final currentElo = userData["ranking_points"] as int? ?? 1000;
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
