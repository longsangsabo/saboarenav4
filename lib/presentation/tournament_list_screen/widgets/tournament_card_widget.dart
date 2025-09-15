import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TournamentCardWidget extends StatelessWidget {
  final Map<String, dynamic> tournament;
  final VoidCallback? onTap;
  final VoidCallback? onBookmark;

  const TournamentCardWidget({
    super.key,
    required this.tournament,
    this.onTap,
    this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final status = tournament['status'] as String;
    final isLive = status == 'live';
    final isCompleted = status == 'completed';
    final isRegistered = tournament['isRegistered'] as bool? ?? false;
    final isFull = (tournament['currentParticipants'] as int) >=
        (tournament['maxParticipants'] as int);
    final isBookmarked = tournament['isBookmarked'] as bool? ?? false;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tournament Image with Status Badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: CustomImageWidget(
                    imageUrl: tournament['coverImage'] as String,
                    width: double.infinity,
                    height: 20.h,
                    fit: BoxFit.cover,
                  ),
                ),

                // Live indicator
                if (isLive)
                  Positioned(
                    top: 2.h,
                    left: 3.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 2.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            'LIVE',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Bookmark button
                Positioned(
                  top: 2.h,
                  right: 3.w,
                  child: GestureDetector(
                    onTap: onBookmark,
                    child: Container(
                      padding: EdgeInsets.all(1.w),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: CustomIconWidget(
                        iconName: isBookmarked ? 'bookmark' : 'bookmark_border',
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),

                // Prize pool badge
                if (tournament['prizePool'] != null)
                  Positioned(
                    bottom: 1.h,
                    right: 3.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 2.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.tertiary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Giải thưởng: ${tournament['prizePool']}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Tournament Details
            Padding(
              padding: EdgeInsets.all(3.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Format
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          tournament['title'] as String,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      _buildFormatBadge(
                          context, tournament['format'] as String),
                    ],
                  ),

                  SizedBox(height: 1.h),

                  // Club info
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'business',
                        color: colorScheme.onSurfaceVariant,
                        size: 16,
                      ),
                      SizedBox(width: 1.w),
                      Expanded(
                        child: Text(
                          tournament['clubName'] as String,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 1.h),

                  // Date and time
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'schedule',
                        color: colorScheme.onSurfaceVariant,
                        size: 16,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        tournament['startDate'] as String,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      CustomIconWidget(
                        iconName: 'access_time',
                        color: colorScheme.onSurfaceVariant,
                        size: 16,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        tournament['startTime'] as String,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 1.h),

                  // Participants and Entry Fee
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'people',
                              color: colorScheme.onSurfaceVariant,
                              size: 16,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              '${tournament['currentParticipants']}/${tournament['maxParticipants']}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            if (isLive) ...[
                              SizedBox(width: 2.w),
                              CustomIconWidget(
                                iconName: 'videocam',
                                color: Colors.red,
                                size: 16,
                              ),
                            ],
                          ],
                        ),
                      ),
                      Text(
                        tournament['entryFee'] as String,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 2.h),

                  // Registration button
                  SizedBox(
                    width: double.infinity,
                    child: _buildRegistrationButton(
                        context, status, isRegistered, isFull),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormatBadge(BuildContext context, String format) {
    final theme = Theme.of(context);
    Color badgeColor;

    switch (format.toLowerCase()) {
      case '8-ball':
        badgeColor = Colors.blue;
        break;
      case '9-ball':
        badgeColor = Colors.orange;
        break;
      case '10-ball':
        badgeColor = Colors.purple;
        break;
      default:
        badgeColor = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        format,
        style: theme.textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildRegistrationButton(
      BuildContext context, String status, bool isRegistered, bool isFull) {
    final theme = Theme.of(context);

    String buttonText;
    Color buttonColor;
    Color textColor;
    bool isEnabled = true;

    if (status == 'completed') {
      buttonText = 'Đã kết thúc';
      buttonColor = Colors.grey;
      textColor = Colors.white;
      isEnabled = false;
    } else if (isRegistered) {
      buttonText = 'Đã đăng ký';
      buttonColor = Colors.blue;
      textColor = Colors.white;
      isEnabled = true;
    } else if (isFull) {
      buttonText = 'Đã đầy';
      buttonColor = Colors.grey;
      textColor = Colors.white;
      isEnabled = false;
    } else if (status == 'live') {
      buttonText = 'Đang diễn ra';
      buttonColor = Colors.red;
      textColor = Colors.white;
      isEnabled = false;
    } else {
      buttonText = 'Đăng ký';
      buttonColor = AppTheme.lightTheme.colorScheme.primary;
      textColor = Colors.white;
      isEnabled = true;
    }

    return ElevatedButton(
      onPressed: isEnabled
          ? () {
              // Handle registration logic
            }
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        foregroundColor: textColor,
        padding: EdgeInsets.symmetric(vertical: 1.5.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: isEnabled ? 2 : 0,
      ),
      child: Text(
        buttonText,
        style: theme.textTheme.labelLarge?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
