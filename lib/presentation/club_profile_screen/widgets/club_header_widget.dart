import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ClubHeaderWidget extends StatelessWidget {
  final Map<String, dynamic> clubData;
  final bool isOwner;
  final VoidCallback? onEditPressed;
  final VoidCallback? onJoinTogglePressed;

  const ClubHeaderWidget({
    super.key,
    required this.clubData,
    required this.isOwner,
    this.onEditPressed,
    this.onJoinTogglePressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SliverAppBar(
      expandedHeight: 35.h,
      floating: false,
      pinned: true,
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Cover Image
            CustomImageWidget(
              imageUrl: clubData["coverImage"] as String,
              width: double.infinity,
              height: 35.h,
              fit: BoxFit.cover,
            ),

            // Gradient Overlay
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

            // Club Info Overlay
            Positioned(
              bottom: 2.h,
              left: 4.w,
              right: 4.w,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Club Logo
                  Container(
                    width: 20.w,
                    height: 20.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3.w),
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2.5.w),
                      child: CustomImageWidget(
                        imageUrl: clubData["logo"] as String,
                        width: 20.w,
                        height: 20.w,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  SizedBox(width: 3.w),

                  // Club Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          clubData["name"] as String,
                          style: theme.textTheme.headlineSmall?.copyWith(
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
                              size: 4.w,
                            ),
                            SizedBox(width: 1.w),
                            Expanded(
                              child: Text(
                                clubData["location"] as String,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 0.5.h),
                        Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'people',
                              color: Colors.white.withValues(alpha: 0.8),
                              size: 4.w,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              "${clubData["memberCount"]} thành viên",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Action Button
                  _buildActionButton(context),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: CustomIconWidget(
            iconName: 'share',
            color: Colors.white,
            size: 6.w,
          ),
          onPressed: () => _showShareOptions(context),
        ),
        IconButton(
          icon: CustomIconWidget(
            iconName: 'more_vert',
            color: Colors.white,
            size: 6.w,
          ),
          onPressed: () => _showMoreOptions(context),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context) {
    final theme = Theme.of(context);

    if (isOwner) {
      return ElevatedButton.icon(
        onPressed: onEditPressed,
        icon: CustomIconWidget(
          iconName: 'edit',
          color: theme.colorScheme.onPrimary,
          size: 4.w,
        ),
        label: Text(
          'Chỉnh sửa',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onPrimary,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2.w),
          ),
        ),
      );
    } else {
      final isMember = clubData["isMember"] as bool? ?? false;
      return ElevatedButton.icon(
        onPressed: onJoinTogglePressed,
        icon: CustomIconWidget(
          iconName: isMember ? 'exit_to_app' : 'person_add',
          color:
              isMember ? theme.colorScheme.error : theme.colorScheme.onPrimary,
          size: 4.w,
        ),
        label: Text(
          isMember ? 'Rời khỏi' : 'Tham gia',
          style: theme.textTheme.labelLarge?.copyWith(
            color: isMember
                ? theme.colorScheme.error
                : theme.colorScheme.onPrimary,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isMember ? theme.colorScheme.surface : theme.colorScheme.primary,
          side: isMember ? BorderSide(color: theme.colorScheme.error) : null,
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2.w),
          ),
        ),
      );
    }
  }

  void _showShareOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CustomIconWidget(
                iconName: 'qr_code',
                color: Theme.of(context).colorScheme.primary,
                size: 6.w,
              ),
              title: const Text('Mã QR'),
              onTap: () {
                Navigator.pop(context);
                // Show QR code
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'link',
                color: Theme.of(context).colorScheme.primary,
                size: 6.w,
              ),
              title: const Text('Sao chép liên kết'),
              onTap: () {
                Navigator.pop(context);
                // Copy link
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CustomIconWidget(
                iconName: 'report',
                color: Theme.of(context).colorScheme.error,
                size: 6.w,
              ),
              title: const Text('Báo cáo'),
              onTap: () {
                Navigator.pop(context);
                // Report club
              },
            ),
            if (!isOwner)
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'block',
                  color: Theme.of(context).colorScheme.error,
                  size: 6.w,
                ),
                title: const Text('Chặn'),
                onTap: () {
                  Navigator.pop(context);
                  // Block club
                },
              ),
          ],
        ),
      ),
    );
  }
}
