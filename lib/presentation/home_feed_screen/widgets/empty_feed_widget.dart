import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class EmptyFeedWidget extends StatelessWidget {
  final bool isNearbyTab;
  final VoidCallback? onCreatePost;
  final VoidCallback? onFindFriends;

  const EmptyFeedWidget({
    super.key,
    required this.isNearbyTab,
    this.onCreatePost,
    this.onFindFriends,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Billiards themed illustration
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'sports_bar',
                    color: colorScheme.primary,
                    size: 60,
                  ),
                  Positioned(
                    top: 8.w,
                    right: 8.w,
                    child: Container(
                      width: 6.w,
                      height: 6.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                      child: Center(
                        child: Text(
                          '8',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8.w,
                    left: 8.w,
                    child: Container(
                      width: 5.w,
                      height: 5.w,
                      decoration: const BoxDecoration(
                        color: Colors.yellow,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '9',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 8.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 4.h),

            // Title
            Text(
              isNearbyTab
                  ? 'Chưa có bài viết gần đây'
                  : 'Chưa có bài viết từ bạn bè',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 2.h),

            // Description
            Text(
              isNearbyTab
                  ? 'Hãy là người đầu tiên chia sẻ trải nghiệm billiards của bạn trong khu vực này!'
                  : 'Kết nối với những người chơi billiards khác để xem các bài viết thú vị.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 4.h),

            // Action buttons
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onCreatePost,
                    icon: CustomIconWidget(
                      iconName: 'add',
                      color: colorScheme.onPrimary,
                      size: 20,
                    ),
                    label: const Text('Tạo bài viết đầu tiên'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                if (!isNearbyTab) ...[
                  SizedBox(height: 2.h),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: onFindFriends,
                      icon: CustomIconWidget(
                        iconName: 'people',
                        color: colorScheme.primary,
                        size: 20,
                      ),
                      label: const Text('Tìm bạn bè'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),

            SizedBox(height: 4.h),

            // Tips section
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'lightbulb',
                        color: colorScheme.primary,
                        size: 20,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Gợi ý',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  ...(_getTips(isNearbyTab).map((tip) => Padding(
                        padding: EdgeInsets.only(bottom: 1.h),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 1.w,
                              height: 1.w,
                              margin: EdgeInsets.only(top: 1.5.h, right: 3.w),
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                tip,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getTips(bool isNearbyTab) {
    if (isNearbyTab) {
      return [
        'Chia sẻ ảnh từ các trận đấu billiards của bạn',
        'Đăng video những cú đánh đẹp',
        'Thảo luận về kỹ thuật và chiến thuật',
        'Giới thiệu các câu lạc bộ billiards địa phương',
      ];
    } else {
      return [
        'Theo dõi những người chơi billiards khác',
        'Tham gia các nhóm billiards',
        'Kết bạn với đối thủ sau các trận đấu',
        'Chia sẻ bài viết để thu hút bạn bè mới',
      ];
    }
  }
}
