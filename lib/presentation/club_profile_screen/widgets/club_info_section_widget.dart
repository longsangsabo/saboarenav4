import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class ClubInfoSectionWidget extends StatelessWidget {
  final Map<String, dynamic> clubData;

  const ClubInfoSectionWidget({
    super.key,
    required this.clubData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.all(4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(3.w),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description Section
          if (clubData["description"] != null &&
              (clubData["description"] as String).isNotEmpty) ...[
            Text(
              'Giới thiệu',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              clubData["description"] as String,
              style: theme.textTheme.bodyMedium,
            ),
            SizedBox(height: 3.h),
          ],

          // Amenities Section
          Text(
            'Tiện ích',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 2.h),
          _buildAmenitiesGrid(context),

          SizedBox(height: 3.h),

          // Operating Hours Section
          Text(
            'Giờ hoạt động',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 2.h),
          _buildOperatingHours(context),

          SizedBox(height: 3.h),

          // Contact Info Section
          Text(
            'Thông tin liên hệ',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 2.h),
          _buildContactInfo(context),
        ],
      ),
    );
  }

  Widget _buildAmenitiesGrid(BuildContext context) {
    final theme = Theme.of(context);
    final amenities = clubData["amenities"] as List<dynamic>? ?? [];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 4,
        crossAxisSpacing: 2.w,
        mainAxisSpacing: 1.h,
      ),
      itemCount: amenities.length,
      itemBuilder: (context, index) {
        final amenity = amenities[index] as Map<String, dynamic>;
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(2.w),
          ),
          child: Row(
            children: [
              CustomIconWidget(
                iconName: amenity["icon"] as String,
                color: theme.colorScheme.primary,
                size: 5.w,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  amenity["name"] as String,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOperatingHours(BuildContext context) {
    final theme = Theme.of(context);
    final operatingHours =
        clubData["operatingHours"] as Map<String, dynamic>? ?? {};

    return Column(
      children: operatingHours.entries.map((entry) {
        return Padding(
          padding: EdgeInsets.only(bottom: 1.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                entry.key,
                style: theme.textTheme.bodyMedium,
              ),
              Text(
                entry.value as String,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildContactInfo(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        if (clubData["phone"] != null) ...[
          InkWell(
            onTap: () {
              // Make phone call
            },
            borderRadius: BorderRadius.circular(2.w),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 1.h),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'phone',
                    color: colorScheme.primary,
                    size: 5.w,
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    clubData["phone"] as String,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        if (clubData["email"] != null) ...[
          InkWell(
            onTap: () {
              // Send email
            },
            borderRadius: BorderRadius.circular(2.w),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 1.h),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'email',
                    color: colorScheme.primary,
                    size: 5.w,
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    clubData["email"] as String,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        InkWell(
          onTap: () {
            // Open map
          },
          borderRadius: BorderRadius.circular(2.w),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 1.h),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'location_on',
                  color: colorScheme.primary,
                  size: 5.w,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    clubData["address"] as String? ??
                        clubData["location"] as String,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
