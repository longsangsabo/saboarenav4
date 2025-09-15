import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ParticipantsListWidget extends StatelessWidget {
  final List<Map<String, dynamic>> participants;
  final VoidCallback? onViewAllTap;

  const ParticipantsListWidget({
    super.key,
    required this.participants,
    this.onViewAllTap,
  });

  @override
  Widget build(BuildContext context) {
    final displayParticipants = participants.take(6).toList();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'people',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 24,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Danh sách tham gia',
                    style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (participants.length > 6)
                TextButton(
                  onPressed: onViewAllTap,
                  child: Text(
                    'Xem tất cả',
                    style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 2.h),
          ...displayParticipants
              .map((participant) => _buildParticipantItem(participant)),
          if (participants.length > 6)
            Container(
              margin: EdgeInsets.only(top: 1.h),
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '+${participants.length - 6} người khác',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildParticipantItem(Map<String, dynamic> participant) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.5.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6.w),
              border: Border.all(
                color: _getRankColor(participant["rank"] as String),
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6.w),
              child: CustomImageWidget(
                imageUrl: participant["avatar"] as String,
                width: 12.w,
                height: 12.w,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  participant["name"] as String,
                  style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 0.5.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 2.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: _getRankColor(participant["rank"] as String),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Rank ${participant["rank"]}',
                        style:
                            AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      '${participant["elo"]} ELO',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          CustomIconWidget(
            iconName: 'chevron_right',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 20,
          ),
        ],
      ),
    );
  }

  Color _getRankColor(String rank) {
    switch (rank.toUpperCase()) {
      case 'A':
        return const Color(0xFFFF6B6B);
      case 'B':
        return const Color(0xFFFF9F43);
      case 'C':
        return const Color(0xFFFFD93D);
      case 'D':
        return const Color(0xFF6BCF7F);
      case 'E':
        return const Color(0xFF4ECDC4);
      case 'F':
        return const Color(0xFF45B7D1);
      case 'G':
        return const Color(0xFF96CEB4);
      case 'H':
        return const Color(0xFFA8E6CF);
      case 'I':
        return const Color(0xFFDDA0DD);
      case 'J':
        return const Color(0xFFB19CD9);
      case 'K':
        return const Color(0xFF95A5A6);
      default:
        return AppTheme.lightTheme.colorScheme.primary;
    }
  }
}
