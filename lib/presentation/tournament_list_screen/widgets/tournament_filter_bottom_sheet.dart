import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class TournamentFilterBottomSheet extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onFiltersApplied;

  const TournamentFilterBottomSheet({
    super.key,
    required this.currentFilters,
    required this.onFiltersApplied,
  });

  @override
  State<TournamentFilterBottomSheet> createState() =>
      _TournamentFilterBottomSheetState();
}

class _TournamentFilterBottomSheetState
    extends State<TournamentFilterBottomSheet> {
  late Map<String, dynamic> _filters;

  @override
  void initState() {
    super.initState();
    _filters = Map<String, dynamic>.from(widget.currentFilters);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 1.h),
            width: 10.w,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                Text(
                  'Bộ lọc giải đấu',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _resetFilters,
                  child: Text(
                    'Đặt lại',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: colorScheme.outline.withValues(alpha: 0.2)),

          // Filter content
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location radius
                  _buildLocationRadiusSection(context),

                  SizedBox(height: 3.h),

                  // Entry fee range
                  _buildEntryFeeSection(context),

                  SizedBox(height: 3.h),

                  // Tournament format
                  _buildFormatSection(context),

                  SizedBox(height: 3.h),

                  // Skill level
                  _buildSkillLevelSection(context),

                  SizedBox(height: 3.h),

                  // Additional filters
                  _buildAdditionalFiltersSection(context),
                ],
              ),
            ),
          ),

          // Apply button
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                  ),
                  child: Text(
                    'Áp dụng bộ lọc',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationRadiusSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomIconWidget(
              iconName: 'location_on',
              color: colorScheme.primary,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text(
              'Khoảng cách',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Text(
          'Trong vòng ${(_filters['locationRadius'] as double).toInt()} km',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        Slider(
          value: _filters['locationRadius'] as double,
          min: 1,
          max: 50,
          divisions: 49,
          onChanged: (value) {
            setState(() {
              _filters['locationRadius'] = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildEntryFeeSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomIconWidget(
              iconName: 'payments',
              color: colorScheme.primary,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text(
              'Phí tham gia',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: [
            _buildFeeChip(context, 'Miễn phí', 'free'),
            _buildFeeChip(context, 'Dưới 100k', 'under_100k'),
            _buildFeeChip(context, '100k - 500k', '100k_500k'),
            _buildFeeChip(context, '500k - 1M', '500k_1m'),
            _buildFeeChip(context, 'Trên 1M', 'over_1m'),
          ],
        ),
      ],
    );
  }

  Widget _buildFormatSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomIconWidget(
              iconName: 'sports_bar',
              color: colorScheme.primary,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text(
              'Thể thức',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: [
            _buildFormatChip(context, '8-Ball', '8-ball'),
            _buildFormatChip(context, '9-Ball', '9-ball'),
            _buildFormatChip(context, '10-Ball', '10-ball'),
          ],
        ),
      ],
    );
  }

  Widget _buildSkillLevelSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomIconWidget(
              iconName: 'military_tech',
              color: colorScheme.primary,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text(
              'Trình độ',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: [
            _buildSkillChip(context, 'Mới bắt đầu', 'beginner'),
            _buildSkillChip(context, 'Trung bình', 'intermediate'),
            _buildSkillChip(context, 'Cao cấp', 'advanced'),
            _buildSkillChip(context, 'Chuyên nghiệp', 'professional'),
          ],
        ),
      ],
    );
  }

  Widget _buildAdditionalFiltersSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tùy chọn khác',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        CheckboxListTile(
          title: Text(
            'Chỉ giải đấu có live stream',
            style: theme.textTheme.bodyMedium,
          ),
          value: _filters['hasLiveStream'] as bool? ?? false,
          onChanged: (value) {
            setState(() {
              _filters['hasLiveStream'] = value ?? false;
            });
          },
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
        ),
        CheckboxListTile(
          title: Text(
            'Chỉ giải đấu còn chỗ',
            style: theme.textTheme.bodyMedium,
          ),
          value: _filters['hasAvailableSlots'] as bool? ?? false,
          onChanged: (value) {
            setState(() {
              _filters['hasAvailableSlots'] = value ?? false;
            });
          },
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
        ),
        CheckboxListTile(
          title: Text(
            'Chỉ giải đấu có giải thưởng',
            style: theme.textTheme.bodyMedium,
          ),
          value: _filters['hasPrizePool'] as bool? ?? false,
          onChanged: (value) {
            setState(() {
              _filters['hasPrizePool'] = value ?? false;
            });
          },
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
        ),
      ],
    );
  }

  Widget _buildFeeChip(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected =
        (_filters['entryFeeRange'] as List<String>? ?? []).contains(value);

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          final feeRanges =
              (_filters['entryFeeRange'] as List<String>? ?? <String>[])
                  .toList();
          if (selected) {
            feeRanges.add(value);
          } else {
            feeRanges.remove(value);
          }
          _filters['entryFeeRange'] = feeRanges;
        });
      },
      selectedColor: colorScheme.primary.withValues(alpha: 0.2),
      checkmarkColor: colorScheme.primary,
      labelStyle: theme.textTheme.labelMedium?.copyWith(
        color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildFormatChip(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected =
        (_filters['formats'] as List<String>? ?? []).contains(value);

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          final formats =
              (_filters['formats'] as List<String>? ?? <String>[]).toList();
          if (selected) {
            formats.add(value);
          } else {
            formats.remove(value);
          }
          _filters['formats'] = formats;
        });
      },
      selectedColor: colorScheme.primary.withValues(alpha: 0.2),
      checkmarkColor: colorScheme.primary,
      labelStyle: theme.textTheme.labelMedium?.copyWith(
        color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildSkillChip(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected =
        (_filters['skillLevels'] as List<String>? ?? []).contains(value);

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          final skillLevels =
              (_filters['skillLevels'] as List<String>? ?? <String>[]).toList();
          if (selected) {
            skillLevels.add(value);
          } else {
            skillLevels.remove(value);
          }
          _filters['skillLevels'] = skillLevels;
        });
      },
      selectedColor: colorScheme.primary.withValues(alpha: 0.2),
      checkmarkColor: colorScheme.primary,
      labelStyle: theme.textTheme.labelMedium?.copyWith(
        color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      _filters = {
        'locationRadius': 10.0,
        'entryFeeRange': <String>[],
        'formats': <String>[],
        'skillLevels': <String>[],
        'hasLiveStream': false,
        'hasAvailableSlots': false,
        'hasPrizePool': false,
      };
    });
  }

  void _applyFilters() {
    widget.onFiltersApplied(_filters);
    Navigator.of(context).pop();
  }
}
