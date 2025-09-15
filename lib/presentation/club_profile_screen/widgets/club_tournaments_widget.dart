import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class ClubTournamentsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> tournaments;
  final bool isOwner;
  final VoidCallback? onViewAll;
  final VoidCallback? onCreateTournament;
  final Function(Map<String, dynamic>)? onTournamentTap;

  const ClubTournamentsWidget({
    super.key,
    required this.tournaments,
    required this.isOwner,
    this.onViewAll,
    this.onCreateTournament,
    this.onTournamentTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Giải đấu (${tournaments.length})',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  if (isOwner)
                    TextButton.icon(
                      onPressed: onCreateTournament,
                      icon: CustomIconWidget(
                        iconName: 'add',
                        color: colorScheme.primary,
                        size: 4.w,
                      ),
                      label: Text(
                        'Tạo mới',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  if (tournaments.length > 3)
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
            ],
          ),
          SizedBox(height: 2.h),
          tournaments.isEmpty
              ? _buildEmptyState(context)
              : _buildTournamentsList(context),
        ],
      ),
    );
  }

  Widget _buildTournamentsList(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tournaments.length > 3 ? 3 : tournaments.length,
      itemBuilder: (context, index) {
        final tournament = tournaments[index];
        return _buildTournamentCard(context, tournament);
      },
    );
  }

  Widget _buildTournamentCard(
      BuildContext context, Map<String, dynamic> tournament) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final status = tournament["status"] as String;
    final startDate = DateTime.parse(tournament["startDate"] as String);
    final prizePool = tournament["prizePool"] as String?;

    return Container(
      margin: EdgeInsets.only(bottom: 3.h),
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
      child: InkWell(
        onTap: () => onTournamentTap?.call(tournament),
        borderRadius: BorderRadius.circular(3.w),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tournament["name"] as String,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          tournament["format"] as String,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(context, status),
                ],
              ),
              SizedBox(height: 2.h),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      context,
                      'calendar_today',
                      _formatDate(startDate),
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      context,
                      'people',
                      '${tournament["participants"]}/${tournament["maxParticipants"]}',
                    ),
                  ),
                ],
              ),
              if (prizePool != null) ...[
                SizedBox(height: 1.h),
                _buildInfoItem(
                  context,
                  'emoji_events',
                  'Giải thưởng: $prizePool',
                ),
              ],
              SizedBox(height: 2.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (status == "upcoming")
                    ElevatedButton(
                      onPressed: () {
                        // Register for tournament
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        padding: EdgeInsets.symmetric(
                            horizontal: 4.w, vertical: 1.h),
                      ),
                      child: Text(
                        'Đăng ký',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    )
                  else if (status == "ongoing")
                    OutlinedButton(
                      onPressed: () => onTournamentTap?.call(tournament),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: colorScheme.primary),
                        padding: EdgeInsets.symmetric(
                            horizontal: 4.w, vertical: 1.h),
                      ),
                      child: Text(
                        'Xem bảng đấu',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.primary,
                        ),
                      ),
                    )
                  else
                    OutlinedButton(
                      onPressed: () => onTournamentTap?.call(tournament),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: colorScheme.onSurfaceVariant),
                        padding: EdgeInsets.symmetric(
                            horizontal: 4.w, vertical: 1.h),
                      ),
                      child: Text(
                        'Xem kết quả',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  TextButton(
                    onPressed: () => onTournamentTap?.call(tournament),
                    child: Text(
                      'Chi tiết',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, String status) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color backgroundColor;
    Color textColor;
    String text;

    switch (status) {
      case "upcoming":
        backgroundColor = colorScheme.primary.withValues(alpha: 0.1);
        textColor = colorScheme.primary;
        text = "Sắp diễn ra";
        break;
      case "ongoing":
        backgroundColor = Colors.orange.withValues(alpha: 0.1);
        textColor = Colors.orange;
        text = "Đang diễn ra";
        break;
      case "completed":
        backgroundColor = colorScheme.onSurfaceVariant.withValues(alpha: 0.1);
        textColor = colorScheme.onSurfaceVariant;
        text = "Đã kết thúc";
        break;
      default:
        backgroundColor = colorScheme.surface;
        textColor = colorScheme.onSurface;
        text = status;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(2.w),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, String iconName, String text) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        CustomIconWidget(
          iconName: iconName,
          color: colorScheme.onSurfaceVariant,
          size: 4.w,
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
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
            iconName: 'emoji_events_outlined',
            color: colorScheme.onSurfaceVariant,
            size: 12.w,
          ),
          SizedBox(height: 2.h),
          Text(
            'Chưa có giải đấu',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            isOwner
                ? 'Tạo giải đấu đầu tiên cho câu lạc bộ của bạn'
                : 'Câu lạc bộ chưa tổ chức giải đấu nào',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          if (isOwner) ...[
            SizedBox(height: 3.h),
            ElevatedButton.icon(
              onPressed: onCreateTournament,
              icon: CustomIconWidget(
                iconName: 'add',
                color: colorScheme.onPrimary,
                size: 5.w,
              ),
              label: const Text('Tạo giải đấu'),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }
}
