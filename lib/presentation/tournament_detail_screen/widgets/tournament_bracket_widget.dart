import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TournamentBracketWidget extends StatelessWidget {
  final Map<String, dynamic> tournament;
  final List<Map<String, dynamic>> bracketData;

  const TournamentBracketWidget({
    super.key,
    required this.tournament,
    required this.bracketData,
  });

  @override
  Widget build(BuildContext context) {
    final eliminationType = tournament["eliminationType"] as String;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'account_tree',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Text(
                'Bảng đấu',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  eliminationType,
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          if (bracketData.isNotEmpty)
            _buildBracketTree()
          else
            _buildEmptyBracket(),
        ],
      ),
    );
  }

  Widget _buildBracketTree() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        padding: EdgeInsets.all(2.w),
        child: Column(
          children: [
            _buildRoundHeader(),
            SizedBox(height: 2.h),
            _buildBracketRounds(),
          ],
        ),
      ),
    );
  }

  Widget _buildRoundHeader() {
    final rounds = ['Vòng 1/8', 'Tứ kết', 'Bán kết', 'Chung kết'];

    return Row(
      children: rounds
          .map((round) => Container(
                width: 45.w,
                margin: EdgeInsets.only(right: 4.w),
                child: Text(
                  round,
                  textAlign: TextAlign.center,
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.lightTheme.colorScheme.primary,
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildBracketRounds() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRound(bracketData.take(8).toList(), 0),
        _buildRound(bracketData.skip(8).take(4).toList(), 1),
        _buildRound(bracketData.skip(12).take(2).toList(), 2),
        _buildRound(bracketData.skip(14).take(1).toList(), 3),
      ],
    );
  }

  Widget _buildRound(List<Map<String, dynamic>> matches, int roundIndex) {
    return Container(
      width: 45.w,
      margin: EdgeInsets.only(right: 4.w),
      child: Column(
        children:
            matches.map((match) => _buildMatchCard(match, roundIndex)).toList(),
      ),
    );
  }

  Widget _buildMatchCard(Map<String, dynamic> match, int roundIndex) {
    final player1 = match["player1"] as Map<String, dynamic>?;
    final player2 = match["player2"] as Map<String, dynamic>?;
    final winner = match["winner"] as String?;
    final status = match["status"] as String;

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getMatchStatusColor(status),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          if (player1 != null)
            _buildPlayerRow(player1, winner == "player1", true),
          Container(
            height: 1,
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
          ),
          if (player2 != null)
            _buildPlayerRow(player2, winner == "player2", false)
          else
            _buildEmptyPlayerRow(),
          if (status == "live")
            Container(
              padding: EdgeInsets.symmetric(vertical: 1.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.error
                    .withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(6),
                  bottomRight: Radius.circular(6),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 2.w,
                    height: 2.w,
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.error,
                      borderRadius: BorderRadius.circular(1.w),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'ĐANG DIỄN RA',
                    style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlayerRow(
      Map<String, dynamic> player, bool isWinner, bool isTop) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: isWinner
            ? AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: isTop
            ? const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              )
            : const BorderRadius.only(
                bottomLeft: Radius.circular(6),
                bottomRight: Radius.circular(6),
              ),
      ),
      child: Row(
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.w),
              border: Border.all(
                color: isWinner
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4.w),
              child: CustomImageWidget(
                imageUrl: player["avatar"] as String,
                width: 8.w,
                height: 8.w,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player["name"] as String,
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    fontWeight: isWinner ? FontWeight.bold : FontWeight.w500,
                    color: isWinner
                        ? AppTheme.lightTheme.colorScheme.primary
                        : AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Rank ${player["rank"]}',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (player["score"] != null)
            Text(
              '${player["score"]}',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isWinner
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
          if (isWinner)
            Container(
              margin: EdgeInsets.only(left: 2.w),
              child: CustomIconWidget(
                iconName: 'emoji_events',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 16,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyPlayerRow() {
    return Container(
      padding: EdgeInsets.all(3.w),
      child: Row(
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4.w),
            ),
            child: CustomIconWidget(
              iconName: 'person',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 16,
            ),
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              'Chờ đối thủ',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyBracket() {
    return Container(
      padding: EdgeInsets.all(8.w),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: 'account_tree',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 48,
          ),
          SizedBox(height: 2.h),
          Text(
            'Bảng đấu chưa được tạo',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Bảng đấu sẽ được tạo sau khi hết hạn đăng ký',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getMatchStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'live':
        return AppTheme.lightTheme.colorScheme.error;
      case 'completed':
        return AppTheme.lightTheme.colorScheme.primary;
      case 'upcoming':
        return AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3);
      default:
        return AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3);
    }
  }
}
