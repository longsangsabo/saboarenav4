import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PlayerCardWidget extends StatelessWidget {
  final Map<String, dynamic> player;
  final VoidCallback? onThachDau;
  final VoidCallback? onGiaoLuu;
  final VoidCallback? onViewProfile;
  final VoidCallback? onSendMessage;
  final VoidCallback? onAddFriend;

  const PlayerCardWidget({
    super.key,
    required this.player,
    this.onThachDau,
    this.onGiaoLuu,
    this.onViewProfile,
    this.onSendMessage,
    this.onAddFriend,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            Row(
              children: [
                // Avatar with online status
                Stack(
                  children: [
                    Container(
                      width: 15.w,
                      height: 15.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _getRankColor(player["rank"] as String),
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: CustomImageWidget(
                          imageUrl: player["avatar"] as String,
                          width: 15.w,
                          height: 15.w,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // Online status indicator
                    if (player["isOnline"] as bool)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 4.w,
                          height: 4.w,
                          decoration: BoxDecoration(
                            color: AppTheme.successLight,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.cardColor,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                SizedBox(width: 3.w),

                // Player info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              player["name"] as String,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _buildRankBadge(player["rank"] as String),
                        ],
                      ),

                      SizedBox(height: 0.5.h),

                      Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'location_on',
                            color: colorScheme.onSurfaceVariant,
                            size: 16,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            "${player["distance"]} km",
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          CustomIconWidget(
                            iconName: 'business',
                            color: colorScheme.onSurfaceVariant,
                            size: 16,
                          ),
                          SizedBox(width: 1.w),
                          Expanded(
                            child: Text(
                              player["club"] as String,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 0.5.h),

                      // Game preferences
                      Wrap(
                        spacing: 2.w,
                        children: (player["gameTypes"] as List<String>)
                            .map((gameType) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 2.w, vertical: 0.5.h),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              gameType,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 2.h),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onGiaoLuu,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                      side: BorderSide(color: colorScheme.primary),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'handshake',
                          color: colorScheme.primary,
                          size: 18,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Giao lưu',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onThachDau,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'sports_bar',
                          color: colorScheme.onPrimary,
                          size: 18,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Thách đấu',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: colorScheme.onPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankBadge(String rank) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: _getRankColor(rank),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        rank,
        style: TextStyle(
          color: Colors.white,
          fontSize: 10.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getRankColor(String rank) {
    switch (rank.toUpperCase()) {
      case 'A':
        return const Color(0xFFD4AF37); // Gold
      case 'B':
        return const Color(0xFFC0C0C0); // Silver
      case 'C':
        return const Color(0xFFCD7F32); // Bronze
      case 'D':
        return const Color(0xFF4CAF50); // Green
      case 'E':
        return const Color(0xFF2196F3); // Blue
      case 'F':
        return const Color(0xFF9C27B0); // Purple
      case 'G':
        return const Color(0xFFFF9800); // Orange
      case 'H':
        return const Color(0xFFE91E63); // Pink
      case 'I':
        return const Color(0xFF795548); // Brown
      case 'J':
        return const Color(0xFF607D8B); // Blue Grey
      default: // K
        return const Color(0xFF9E9E9E); // Grey
    }
  }
}
