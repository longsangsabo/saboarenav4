import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ClubMembersWidget extends StatelessWidget {
  final List<Map<String, dynamic>> members;
  final bool isOwner;
  final VoidCallback? onViewAll;
  final Function(Map<String, dynamic>)? onMemberTap;

  const ClubMembersWidget({
    super.key,
    required this.members,
    required this.isOwner,
    this.onViewAll,
    this.onMemberTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (members.isEmpty) {
      return _buildEmptyState(context);
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Thành viên (${members.length})',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (members.length > 8)
                TextButton(
                  onPressed: onViewAll,
                  child: Text(
                    'Xem tất cả',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 2.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 0.8,
              crossAxisSpacing: 2.w,
              mainAxisSpacing: 2.h,
            ),
            itemCount: members.length > 8 ? 8 : members.length,
            itemBuilder: (context, index) {
              final member = members[index];
              return _buildMemberCard(context, member);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(BuildContext context, Map<String, dynamic> member) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isOnline = member["isOnline"] as bool? ?? false;
    final role = member["role"] as String? ?? "member";

    return InkWell(
      onTap: () => onMemberTap?.call(member),
      borderRadius: BorderRadius.circular(3.w),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 15.w,
                height: 15.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isOnline
                        ? colorScheme.primary
                        : colorScheme.outline.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: CustomImageWidget(
                    imageUrl: member["avatar"] as String,
                    width: 15.w,
                    height: 15.w,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // Online Indicator
              if (isOnline)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 4.w,
                    height: 4.w,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colorScheme.surface,
                        width: 1,
                      ),
                    ),
                  ),
                ),

              // Role Badge
              if (role == "owner" || role == "admin")
                Positioned(
                  top: -1,
                  right: -1,
                  child: Container(
                    padding: EdgeInsets.all(1.w),
                    decoration: BoxDecoration(
                      color: role == "owner"
                          ? Colors.amber
                          : colorScheme.secondary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colorScheme.surface,
                        width: 1,
                      ),
                    ),
                    child: CustomIconWidget(
                      iconName:
                          role == "owner" ? 'star' : 'admin_panel_settings',
                      color: Colors.white,
                      size: 2.5.w,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            member["name"] as String,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          if (member["rank"] != null)
            Text(
              member["rank"] as String,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: 'people_outline',
            color: colorScheme.onSurfaceVariant,
            size: 12.w,
          ),
          SizedBox(height: 2.h),
          Text(
            'Chưa có thành viên',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            isOwner
                ? 'Hãy mời bạn bè tham gia câu lạc bộ của bạn'
                : 'Hãy là người đầu tiên tham gia câu lạc bộ này',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          if (isOwner) ...[
            SizedBox(height: 3.h),
            ElevatedButton.icon(
              onPressed: () {
                // Invite members
              },
              icon: CustomIconWidget(
                iconName: 'person_add',
                color: colorScheme.onPrimary,
                size: 5.w,
              ),
              label: const Text('Mời thành viên'),
            ),
          ],
        ],
      ),
    );
  }
}
