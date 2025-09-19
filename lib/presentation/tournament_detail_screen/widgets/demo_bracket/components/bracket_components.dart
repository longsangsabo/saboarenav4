// 🎯 SABO ARENA - Shared Bracket Components
// Reusable UI components for all tournament formats

import 'package:flutter/material.dart';

/// Shared header component for all bracket types
class BracketHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onFullscreenTap;
  final VoidCallback? onInfoTap;

  const BracketHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onFullscreenTap,
    this.onInfoTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF2E86AB), const Color(0xFF2E86AB).withOpacity(0.8)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.account_tree,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 6),
                  Text(
                    'Dữ liệu demo để xem trước cấu trúc bảng đấu',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onInfoTap != null) ...[
            IconButton(
              onPressed: onInfoTap,
              icon: const Icon(
                Icons.info_outline,
                color: Colors.white,
                size: 24,
              ),
              tooltip: 'Thông tin chi tiết',
            ),
            const SizedBox(width: 8),
          ],
          if (onFullscreenTap != null) ...[
            IconButton(
              onPressed: onFullscreenTap,
              icon: const Icon(
                Icons.fullscreen,
                color: Colors.white,
                size: 24,
              ),
              tooltip: 'Xem toàn màn hình',
            ),
            const SizedBox(width: 8),
          ],
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'DEMO',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual match card component
class MatchCard extends StatelessWidget {
  final Map<String, String> match;

  const MatchCard({
    super.key,
    required this.match,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160, // Giảm width từ 200 xuống 160
      margin: const EdgeInsets.only(bottom: 8), // Giảm margin từ 16 xuống 8
      padding: const EdgeInsets.all(8), // Giảm padding từ 12 xuống 8
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6), // Giảm border radius
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2, // Giảm blur
            offset: const Offset(0, 1), // Giảm offset
          ),
        ],
      ),
      child: Column(
        children: [
          // Match ID header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), // Giảm padding
            decoration: BoxDecoration(
              color: const Color(0xFF2E86AB).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8), // Giảm border radius
            ),
            child: Text(
              match['matchId'] ?? '',
              style: const TextStyle(
                fontSize: 9, // Giảm font size từ 10 xuống 9
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E86AB),
              ),
            ),
          ),
          const SizedBox(height: 4), // Giảm spacing từ 8 xuống 4
          PlayerRow(
            playerName: match['player1']!,
            score: match['score1'],
          ),
          const Divider(height: 8), // Giảm height từ 16 xuống 8
          PlayerRow(
            playerName: match['player2']!,
            score: match['score2'],
          ),
        ],
      ),
    );
  }
}

/// Player row within a match card
class PlayerRow extends StatelessWidget {
  final String playerName;
  final String? score;

  const PlayerRow({
    super.key,
    required this.playerName,
    this.score,
  });

  @override
  Widget build(BuildContext context) {
    final hasScore = score != null && score!.isNotEmpty;
    final isWinner = hasScore && score == '2';

    return Row(
      children: [
        CircleAvatar(
          radius: 12, // Giảm radius từ 16 xuống 12
          backgroundColor: const Color(0xFF2E86AB).withOpacity(0.1),
          child: Text(
            playerName.substring(0, 1).toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF2E86AB),
              fontWeight: FontWeight.bold,
              fontSize: 10, // Giảm font size
            ),
          ),
        ),
        const SizedBox(width: 6), // Giảm width từ 8 xuống 6
        Expanded(
          child: Text(
            playerName,
            style: TextStyle(
              fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
              color: isWinner ? const Color(0xFF2E86AB) : Colors.black87,
              fontSize: 11, // Giảm font size
            ),
            overflow: TextOverflow.ellipsis, // Thêm ellipsis
          ),
        ),
        if (hasScore)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), // Giảm padding
            decoration: BoxDecoration(
              color: isWinner ? Colors.green : Colors.grey[200],
              borderRadius: BorderRadius.circular(8), // Giảm border radius
            ),
            child: Text(
              score!,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isWinner ? Colors.white : Colors.grey[600],
                fontSize: 10, // Giảm font size
              ),
            ),
          ),
      ],
    );
  }
}

/// Round column header
class RoundColumn extends StatelessWidget {
  final String title;
  final List<Map<String, String>> matches;
  final int? roundIndex;
  final int? totalRounds;
  final bool? isFullscreen;

  const RoundColumn({
    super.key,
    required this.title,
    required this.matches,
    this.roundIndex,
    this.totalRounds,
    this.isFullscreen,
  });

  @override
  Widget build(BuildContext context) {
    final isLast = roundIndex != null && totalRounds != null && roundIndex == totalRounds! - 1;
    final spacing = isFullscreen == true ? 8.0 : 4.0; // Giảm spacing hơn nữa
    
    return Container(
      width: 140, // Giảm width từ 180 xuống 140
      margin: EdgeInsets.only(right: isLast ? 0 : 12), // Giảm margin
      child: isFullscreen == true 
        ? SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header của round
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // Giảm padding
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E86AB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10, // Giảm font size
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: spacing),
                // Matches - không dùng spread operator
                for (int i = 0; i < matches.length; i++) ...[
                  MatchCard(match: matches[i]),
                  if (i < matches.length - 1) SizedBox(height: spacing),
                ],
              ],
            ),
          )
        : SizedBox(
            height: matches.length > 4 ? 250 : 160, // Dynamic height based on matches count
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Header của round
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), // Giảm padding
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E86AB),
                      borderRadius: BorderRadius.circular(10), // Giảm border radius
                    ),
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 9, // Giảm font size
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: spacing),
                  // Matches - không dùng spread operator
                  for (int i = 0; i < matches.length; i++) ...[
                    MatchCard(match: matches[i]),
                    if (i < matches.length - 1) SizedBox(height: spacing),
                  ],
                ],
              ),
            ),
          ),
    );
  }
}

/// Container wrapper for bracket displays
class BracketContainer extends StatelessWidget {
  final Widget child;
  final String? title;
  final String? subtitle;
  final VoidCallback? onFullscreenTap;
  final VoidCallback? onInfoTap;
  final double? height; // Thêm optional height parameter

  const BracketContainer({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.onFullscreenTap,
    this.onInfoTap,
    this.height, // Thêm vào constructor
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      height: height ?? 400, // Sử dụng height parameter hoặc default 400
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          if (title != null) ...[
            BracketHeader(
              title: title!,
              subtitle: subtitle,
              onFullscreenTap: onFullscreenTap,
              onInfoTap: onInfoTap,
            ),
            const Divider(height: 1),
          ],
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tournament bracket connector widget
/// Draws connecting lines between matches to show progression flow
class BracketConnector extends StatelessWidget {
  final int fromMatchCount;
  final int toMatchCount;
  final bool isLastRound;

  const BracketConnector({
    super.key,
    required this.fromMatchCount,
    required this.toMatchCount,
    this.isLastRound = false,
  });

  @override
  Widget build(BuildContext context) {
    // Temporarily disable connectors to fix layout issues
    return const SizedBox(width: 30, height: 100);
  }
}

/// Custom painter for drawing bracket connectors
class ConnectorPainter extends CustomPainter {
  final int fromMatchCount;
  final int toMatchCount;

  ConnectorPainter({
    required this.fromMatchCount,
    required this.toMatchCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2E86AB).withOpacity(0.6)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final matchHeight = 80.0; // Approximate height of MatchCard
    final spacing = 4.0; // Spacing between matches
    final headerHeight = 25.0; // Round header height

    // Calculate positions for "from" matches (left side)
    final fromStartY = headerHeight;
    final fromSpacing = (matchHeight + spacing);
    
    // Calculate positions for "to" matches (right side)
    final toStartY = headerHeight;
    final toSpacing = fromSpacing * 2; // Double spacing for next round

    // Draw horizontal lines from each "from" match
    for (int i = 0; i < fromMatchCount; i++) {
      final fromY = fromStartY + (i * fromSpacing) + (matchHeight / 2);
      
      // Horizontal line to the right
      canvas.drawLine(
        Offset(0, fromY),
        Offset(15, fromY),
        paint,
      );
    }

    // Draw connecting vertical and horizontal lines to "to" matches
    for (int i = 0; i < toMatchCount; i++) {
      final toY = toStartY + (i * toSpacing) + (matchHeight / 2);
      
      // Calculate which "from" matches connect to this "to" match
      final fromMatch1Index = i * 2;
      final fromMatch2Index = i * 2 + 1;
      
      if (fromMatch1Index < fromMatchCount && fromMatch2Index < fromMatchCount) {
        final fromY1 = fromStartY + (fromMatch1Index * fromSpacing) + (matchHeight / 2);
        final fromY2 = fromStartY + (fromMatch2Index * fromSpacing) + (matchHeight / 2);
        
        // Vertical connector line
        canvas.drawLine(
          Offset(15, fromY1),
          Offset(15, fromY2),
          paint,
        );
        
        // Horizontal line to "to" match
        canvas.drawLine(
          Offset(15, toY),
          Offset(30, toY),
          paint,
        );
        
        // Vertical line from mid-point to "to" match
        final midY = (fromY1 + fromY2) / 2;
        canvas.drawLine(
          Offset(15, midY),
          Offset(15, toY),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}