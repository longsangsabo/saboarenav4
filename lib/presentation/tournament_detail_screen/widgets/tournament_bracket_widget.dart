import 'package:flutter/material.dart';
// Removed Sizer dependency
import '../../../core/layout/responsive.dart';

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
      margin: const EdgeInsets.symmetric(horizontal: Gaps.xl),
      padding: const EdgeInsets.all(Gaps.xl),
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
              const SizedBox(width: Gaps.md),
              Text(
                'Bảng đấu',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Gaps.lg,
                  vertical: Gaps.sm,
                ),
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
          const SizedBox(height: Gaps.lg),
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
        padding: const EdgeInsets.all(Gaps.md),
        child: Column(
          children: [
            _buildRoundHeader(),
            const SizedBox(height: Gaps.lg),
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
                width: 260,
                margin: const EdgeInsets.only(right: Gaps.xl),
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
      width: 260,
      margin: const EdgeInsets.only(right: Gaps.xl),
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
  margin: const EdgeInsets.only(bottom: Gaps.lg),
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
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.3),
            ),
          if (player2 != null)
            _buildPlayerRow(player2, winner == "player2", false)
          else
            _buildEmptyPlayerRow(),
          if (status == "live")
            Container(
              padding: const EdgeInsets.symmetric(vertical: Gaps.sm),
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
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.error,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(width: Gaps.md),
                  const SizedBox(width: Gaps.md),
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
  padding: const EdgeInsets.all(Gaps.lg),
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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isWinner
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: CustomImageWidget(
                imageUrl: player["avatar"] as String,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: Gaps.md),
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
              margin: const EdgeInsets.only(left: Gaps.md),
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
      padding: const EdgeInsets.all(Gaps.lg),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(24),
            ),
            child: CustomIconWidget(
              iconName: 'person',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 16,
            ),
          ),
          const SizedBox(width: Gaps.md),
          const SizedBox(width: Gaps.md),
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
      padding: const EdgeInsets.all(Gaps.xxl),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: 'account_tree',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 48,
          ),
          const SizedBox(height: Gaps.lg),
          Text(
            'Bảng đấu chưa được tạo',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: Gaps.sm),
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
