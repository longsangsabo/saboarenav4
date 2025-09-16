import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../models/user_profile.dart';
import '../../../services/user_service.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class StatisticsCardsWidget extends StatefulWidget {
  final String userId;

  const StatisticsCardsWidget({
    super.key,
    required this.userId,
  });

  @override
  State<StatisticsCardsWidget> createState() => _StatisticsCardsWidgetState();
}

class _StatisticsCardsWidgetState extends State<StatisticsCardsWidget> {
  bool _isLoading = true;
  UserProfile? _userProfile;
  Map<String, int> _userStats = {};
  int _userRanking = 0;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final userProfile =
          await UserService.instance.getUserProfileById(widget.userId);
      final userStats = await UserService.instance.getUserStats(widget.userId);
      final ranking = await UserService.instance.getUserRanking(widget.userId);

      setState(() {
        _userProfile = userProfile;
        _userStats = userStats;
        _userRanking = ranking;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      print('Failed to load statistics: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        padding: EdgeInsets.all(4.w),
        child: Center(
          child: CircularProgressIndicator(
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
        ),
      );
    }

    if (_userProfile == null) {
      return Container(
        padding: EdgeInsets.all(4.w),
        child: Text(
          'Không thể tải thống kê',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: Colors.red,
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thống kê',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Thắng',
                  value: '${_userProfile!.totalWins}',
                  subtitle:
                      '${_userProfile!.winRate.toStringAsFixed(1)}% tỷ lệ',
                  color: Colors.green,
                  icon: 'emoji_events',
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildStatCard(
                  title: 'Thua',
                  value: '${_userProfile!.totalLosses}',
                  subtitle: '${_userStats['total_matches'] ?? 0} trận',
                  color: Colors.red,
                  icon: 'trending_down',
                ),
              ),
            ],
          ),
          SizedBox(height: 3.w),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Giải đấu',
                  value: '${_userProfile!.totalTournaments}',
                  subtitle: '0 chiến thắng',
                  color: Colors.orange,
                  icon: 'military_tech',
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildStatCard(
                  title: 'Xếp hạng',
                  value: '#${_userRanking > 0 ? _userRanking : 'N/A'}',
                  subtitle: '${_userProfile!.rankingPoints} điểm',
                  color: Colors.purple,
                  icon: 'leaderboard',
                ),
              ),
            ],
          ),
          SizedBox(height: 3.w),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'ELO Rating',
                  value: '${_userProfile!.rankingPoints}',
                  subtitle: 'Ranking Points',
                  color: Colors.blue,
                  icon: 'trending_up',
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildStatCard(
                  title: 'Win Streak',
                  value: '0',
                  subtitle: 'Liên tiếp',
                  color: Colors.amber,
                  icon: 'local_fire_department',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required String icon,
  }) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.shadowColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              CustomIconWidget(
                iconName: icon,
                color: color,
                size: 20,
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            value,
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            subtitle,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}