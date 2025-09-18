import 'package:flutter/material.dart';
import '../../../core/app_export.dart';

class TournamentQuickActions extends StatelessWidget {
  final VoidCallback onCreateTournament;
  final VoidCallback onManageSchedule;
  final VoidCallback onViewReports;

  const TournamentQuickActions({
    Key? key,
    required this.onCreateTournament,
    required this.onManageSchedule,
    required this.onViewReports,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thao tác nhanh',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimaryLight,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  context,
                  'Tạo giải đấu mới',
                  Icons.add_circle_outline,
                  AppTheme.primaryLight,
                  onCreateTournament,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  context,
                  'Quản lý lịch',
                  Icons.schedule,
                  Colors.blue,
                  onManageSchedule,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  context,
                  'Báo cáo',
                  Icons.analytics,
                  Colors.green,
                  onViewReports,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: color,
                size: 24,
              ),
              SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}