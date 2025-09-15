import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TournamentHeaderWidget extends StatelessWidget {
  final Map<String, dynamic> tournament;
  final VoidCallback? onShareTap;
  final ScrollController scrollController;

  const TournamentHeaderWidget({
    super.key,
    required this.tournament,
    this.onShareTap,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 35.h,
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      leading: IconButton(
        icon: CustomIconWidget(
          iconName: 'arrow_back',
          color: AppTheme.lightTheme.colorScheme.onSurface,
          size: 24,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: CustomIconWidget(
            iconName: 'share',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 24,
          ),
          onPressed: onShareTap,
        ),
        SizedBox(width: 2.w),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            CustomImageWidget(
              imageUrl: tournament["coverImage"] as String,
              width: double.infinity,
              height: 35.h,
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 3.h,
              left: 4.w,
              right: 4.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: _getFormatColor(tournament["format"] as String),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      tournament["format"] as String,
                      style:
                          AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    tournament["title"] as String,
                    style:
                        AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 0.5.h),
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'location_on',
                        color: Colors.white.withValues(alpha: 0.8),
                        size: 16,
                      ),
                      SizedBox(width: 1.w),
                      Expanded(
                        child: Text(
                          tournament["location"] as String,
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getFormatColor(String format) {
    switch (format.toLowerCase()) {
      case '8-ball':
        return AppTheme.lightTheme.colorScheme.primary;
      case '9-ball':
        return AppTheme.lightTheme.colorScheme.secondary;
      case '10-ball':
        return AppTheme.lightTheme.colorScheme.tertiary;
      default:
        return AppTheme.lightTheme.colorScheme.primary;
    }
  }
}
