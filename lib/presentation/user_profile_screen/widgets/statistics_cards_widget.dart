import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class StatisticsCardsWidget extends StatelessWidget {
  final Map<String, dynamic> userData;

  const StatisticsCardsWidget({
    super.key,
    required this.userData,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Text(
            'Thống kê',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
        ),

        SizedBox(height: 2.h),

        // First Row - Matches and Win Rate
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  title: 'Trận đấu',
                  value: '${userData["totalMatches"] ?? 156}',
                  subtitle: 'Tổng số trận',
                  icon: 'sports_billiards',
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildStatCard(
                  context,
                  title: 'Tỷ lệ thắng',
                  value: '${userData["winRate"] ?? 68}%',
                  subtitle: '${userData["wins"] ?? 106} thắng',
                  icon: 'trending_up',
                  color: AppTheme.lightTheme.colorScheme.tertiary,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 3.w),

        // Second Row - Tournaments and SPA Points
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  title: 'Giải đấu',
                  value: '${userData["tournaments"] ?? 23}',
                  subtitle: '${userData["tournamentWins"] ?? 5} chiến thắng',
                  icon: 'emoji_events',
                  color: Colors.amber[700]!,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildStatCard(
                  context,
                  title: 'SPA Points',
                  value: '${userData["spaPoints"] ?? 2450}',
                  subtitle: 'Điểm tích lũy',
                  icon: 'stars',
                  color: Colors.purple,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 3.w),

        // Third Row - Favorite Game and Streak
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  title: 'Game yêu thích',
                  value: userData["favoriteGame"] as String? ?? '8-Ball',
                  subtitle: '${userData["favoriteGameWins"] ?? 78} thắng',
                  icon: 'sports_esports',
                  color: Colors.green,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildStatCard(
                  context,
                  title: 'Chuỗi thắng',
                  value: '${userData["winStreak"] ?? 7}',
                  subtitle: 'Trận liên tiếp',
                  icon: 'local_fire_department',
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required String icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon and Title Row
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: icon,
                  color: color,
                  size: 20,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  title,
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Value
          Text(
            value,
            style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          SizedBox(height: 0.5.h),

          // Subtitle
          Text(
            subtitle,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
