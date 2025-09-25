import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../services/tournament_service.dart';

class TournamentRankingsWidget extends StatefulWidget {
  final String tournamentId;
  final String tournamentStatus;

  const TournamentRankingsWidget({
    super.key,
    required this.tournamentId,
    required this.tournamentStatus,
  });

  @override
  State<TournamentRankingsWidget> createState() => _TournamentRankingsWidgetState();
}

class _TournamentRankingsWidgetState extends State<TournamentRankingsWidget> {
  final TournamentService _tournamentService = TournamentService();
  List<Map<String, dynamic>> _rankings = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRankings();
  }

  Future<void> _loadRankings() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final rankings = await _tournamentService.getTournamentRankings(widget.tournamentId);
      
      if (mounted) {
        setState(() {
          _rankings = rankings;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16.sp),
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.sp),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.leaderboard,
                color: Colors.orange,
                size: 24.sp,
              ),
              SizedBox(width: 8.sp),
              Text(
                'Bảng xếp hạng',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              Spacer(),
              if (!_isLoading)
                IconButton(
                  onPressed: _loadRankings,
                  icon: Icon(Icons.refresh, size: 20.sp),
                  tooltip: 'Làm mới',
                ),
            ],
          ),
          SizedBox(height: 16.sp),

          // Content
          if (_isLoading)
            _buildLoadingState()
          else if (_error != null)
            _buildErrorState()
          else if (_rankings.isEmpty)
            _buildEmptyState()
          else
            _buildRankingsList(),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16.sp),
          Text(
            'Đang tải bảng xếp hạng...',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 48.sp,
            color: Colors.red[300],
          ),
          SizedBox(height: 16.sp),
          Text(
            'Lỗi khi tải bảng xếp hạng',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.red[600],
            ),
          ),
          SizedBox(height: 8.sp),
          Text(
            _error!,
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.sp),
          ElevatedButton.icon(
            onPressed: _loadRankings,
            icon: Icon(Icons.refresh),
            label: Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 48.sp,
            color: Colors.grey[300],
          ),
          SizedBox(height: 16.sp),
          Text(
            'Chưa có bảng xếp hạng',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8.sp),
          Text(
            widget.tournamentStatus == 'completed' 
                ? 'Bảng xếp hạng sẽ được tạo sau khi hoàn thành giải đấu'
                : 'Bảng xếp hạng sẽ được cập nhật khi có kết quả trận đấu',
            style: TextStyle(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRankingsList() {
    return Column(
      children: [
        // Header Row
        Container(
          padding: EdgeInsets.symmetric(vertical: 8.sp, horizontal: 12.sp),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8.sp),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 40.sp,
                child: Text(
                  'Hạng',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12.sp,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  'Người chơi',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12.sp,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              SizedBox(
                width: 60.sp,
                child: Text(
                  'Điểm',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12.sp,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              SizedBox(
                width: 70.sp,
                child: Text(
                  'T-B-H',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12.sp,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8.sp),

        // Rankings List
        ...List.generate(_rankings.length, (index) {
          final ranking = _rankings[index];
          return _buildRankingItem(ranking, index + 1);
        }),
      ],
    );
  }

  Widget _buildRankingItem(Map<String, dynamic> ranking, int position) {
    final isTopThree = position <= 3;
    final bgColor = isTopThree ? _getTopThreeColor(position) : Colors.transparent;
    final textColor = isTopThree ? Colors.white : Colors.grey[800];

    return Container(
      margin: EdgeInsets.only(bottom: 4.sp),
      padding: EdgeInsets.symmetric(vertical: 12.sp, horizontal: 12.sp),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8.sp),
        border: !isTopThree ? Border.all(color: Colors.grey[200]!) : null,
      ),
      child: Row(
        children: [
          // Position
          SizedBox(
            width: 40.sp,
            child: Row(
              children: [
                if (isTopThree)
                  Icon(
                    _getPositionIcon(position),
                    size: 16.sp,
                    color: Colors.white,
                  )
                else
                  Text(
                    '$position',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                      color: textColor,
                    ),
                  ),
                if (isTopThree) SizedBox(width: 4.sp),
                if (isTopThree)
                  Text(
                    '$position',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ),

          // Player Info
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ranking['player_name'] ?? 'N/A',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                    color: textColor,
                  ),
                ),
                if (ranking['club_name'] != null)
                  Text(
                    ranking['club_name'],
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: isTopThree ? Colors.white70 : Colors.grey[500],
                    ),
                  ),
              ],
            ),
          ),

          // Points
          SizedBox(
            width: 60.sp,
            child: Text(
              '${ranking['total_points'] ?? 0}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
                color: textColor,
              ),
            ),
          ),

          // Win-Loss-Draw Record
          SizedBox(
            width: 70.sp,
            child: Text(
              '${ranking['wins'] ?? 0}-${ranking['losses'] ?? 0}-${ranking['draws'] ?? 0}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                color: isTopThree ? Colors.white70 : Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTopThreeColor(int position) {
    switch (position) {
      case 1:
        return Colors.amber[600]!; // Gold
      case 2:
        return Colors.grey[600]!; // Silver
      case 3:
        return Colors.brown[400]!; // Bronze
      default:
        return Colors.transparent;
    }
  }

  IconData _getPositionIcon(int position) {
    switch (position) {
      case 1:
        return Icons.emoji_events; // Trophy
      case 2:
        return Icons.military_tech; // Medal
      case 3:
        return Icons.military_tech; // Medal
      default:
        return Icons.circle;
    }
  }
}