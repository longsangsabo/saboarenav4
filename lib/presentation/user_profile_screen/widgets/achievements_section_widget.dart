import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AchievementsSectionWidget extends StatelessWidget {
  final List<Map<String, dynamic>> achievements;
  final VoidCallback? onViewAll;

  const AchievementsSectionWidget({
    super.key,
    required this.achievements,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Thành tích',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
              GestureDetector(
                onTap: onViewAll,
                child: Text(
                  'Xem tất cả',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 2.h),

        // Achievements Grid
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 3.w,
              mainAxisSpacing: 3.w,
              childAspectRatio: 0.85,
            ),
            itemCount: achievements.length > 6 ? 6 : achievements.length,
            itemBuilder: (context, index) {
              final achievement = achievements[index];
              return _buildAchievementCard(context, achievement);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementCard(
      BuildContext context, Map<String, dynamic> achievement) {
    final isUnlocked = achievement["isUnlocked"] as bool? ?? false;
    final title = achievement["title"] as String? ?? "";
    final description = achievement["description"] as String? ?? "";
    final icon = achievement["icon"] as String? ?? "emoji_events";
    final rarity = achievement["rarity"] as String? ?? "common";

    final rarityColor = _getRarityColor(rarity);

    return GestureDetector(
      onTap: () => _showAchievementDetail(context, achievement),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: isUnlocked
              ? AppTheme.lightTheme.colorScheme.surface
              : AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnlocked
                ? rarityColor.withValues(alpha: 0.3)
                : AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.2),
            width: isUnlocked ? 2 : 1,
          ),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: rarityColor.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Achievement Icon
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: isUnlocked
                    ? rarityColor.withValues(alpha: 0.1)
                    : AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: icon,
                color: isUnlocked
                    ? rarityColor
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.5),
                size: 24,
              ),
            ),

            SizedBox(height: 2.w),

            // Achievement Title
            Text(
              title,
              style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                color: isUnlocked
                    ? AppTheme.lightTheme.colorScheme.onSurface
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.6),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            SizedBox(height: 1.w),

            // Rarity Indicator
            Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.w),
              decoration: BoxDecoration(
                color: isUnlocked
                    ? rarityColor.withValues(alpha: 0.2)
                    : AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _getRarityText(rarity),
                style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                  color: isUnlocked
                      ? rarityColor
                      : AppTheme.lightTheme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.5),
                  fontWeight: FontWeight.w500,
                  fontSize: 8.sp,
                ),
              ),
            ),

            // Lock Overlay for Locked Achievements
            if (!isUnlocked)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.surface
                        .withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: 'lock',
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.5),
                      size: 20,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getRarityColor(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'legendary':
        return Colors.amber;
      case 'epic':
        return Colors.purple;
      case 'rare':
        return Colors.blue;
      case 'uncommon':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getRarityText(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'legendary':
        return 'Huyền thoại';
      case 'epic':
        return 'Sử thi';
      case 'rare':
        return 'Hiếm';
      case 'uncommon':
        return 'Không phổ biến';
      default:
        return 'Phổ biến';
    }
  }

  void _showAchievementDetail(
      BuildContext context, Map<String, dynamic> achievement) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Achievement Icon
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: _getRarityColor(
                          achievement["rarity"] as String? ?? "common")
                      .withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: CustomIconWidget(
                  iconName: achievement["icon"] as String? ?? "emoji_events",
                  color: _getRarityColor(
                      achievement["rarity"] as String? ?? "common"),
                  size: 40,
                ),
              ),

              SizedBox(height: 3.h),

              // Achievement Title
              Text(
                achievement["title"] as String? ?? "",
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 1.h),

              // Achievement Description
              Text(
                achievement["description"] as String? ?? "",
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 2.h),

              // Rarity Badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: _getRarityColor(
                          achievement["rarity"] as String? ?? "common")
                      .withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getRarityText(achievement["rarity"] as String? ?? "common"),
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    color: _getRarityColor(
                        achievement["rarity"] as String? ?? "common"),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              SizedBox(height: 3.h),

              // Close Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Đóng'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
