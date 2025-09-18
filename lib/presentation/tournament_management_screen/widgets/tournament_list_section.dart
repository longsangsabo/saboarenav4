import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/app_export.dart';
import '../../../models/tournament.dart';

class TournamentListSection extends StatelessWidget {
  final List<Tournament> tournaments;
  final Function(Tournament) onTournamentTap;
  final bool canManage;

  const TournamentListSection({
    Key? key,
    required this.tournaments,
    required this.onTournamentTap,
    this.canManage = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (tournaments.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: tournaments.length,
      itemBuilder: (context, index) {
        final tournament = tournaments[index];
        return _buildTournamentCard(context, tournament);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'Chưa có giải đấu nào',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tạo giải đấu đầu tiên cho câu lạc bộ của bạn',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTournamentCard(BuildContext context, Tournament tournament) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => onTournamentTap(tournament),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and status
              Row(
                children: [
                  Expanded(
                    child: Text(
                      tournament.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 8),
                  _buildStatusChip(tournament.status),
                ],
              ),
              
              if (tournament.description.isNotEmpty) ...[
                SizedBox(height: 8),
                Text(
                  tournament.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondaryLight,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              SizedBox(height: 12),

              // Tournament details
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      Icons.calendar_today,
                      DateFormat('dd/MM/yyyy').format(tournament.startDate),
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      Icons.people,
                      '${tournament.currentParticipants}/${tournament.maxParticipants}',
                    ),
                  ),
                ],
              ),

              SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      Icons.payments,
                      _formatCurrency(tournament.entryFee),
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      Icons.emoji_events,
                      _formatCurrency(tournament.prizePool),
                    ),
                  ),
                ],
              ),

              // Management actions for admins
              if (canManage) ...[
                SizedBox(height: 12),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      context,
                      'Chỉnh sửa',
                      Icons.edit,
                      () => _editTournament(context, tournament),
                    ),
                    _buildActionButton(
                      context,
                      'Quản lý',
                      Icons.settings,
                      () => _manageTournament(context, tournament),
                    ),
                    _buildActionButton(
                      context,
                      'Thống kê',
                      Icons.bar_chart,
                      () => _viewStats(context, tournament),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    String label;

    switch (status.toLowerCase()) {
      case 'upcoming':
        backgroundColor = Colors.blue.withOpacity(0.1);
        textColor = Colors.blue;
        label = 'Sắp tới';
        break;
      case 'ongoing':
        backgroundColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green;
        label = 'Đang diễn ra';
        break;
      case 'completed':
        backgroundColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey[700]!;
        label = 'Đã kết thúc';
        break;
      default:
        backgroundColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange;
        label = status;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppTheme.textSecondaryLight,
        ),
        SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondaryLight,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(
        label,
        style: TextStyle(fontSize: 12),
      ),
      style: TextButton.styleFrom(
        foregroundColor: AppTheme.primaryLight,
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
    );
  }

  String _formatCurrency(double amount) {
    if (amount == 0) return 'Miễn phí';
    return NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(amount);
  }

  void _editTournament(BuildContext context, Tournament tournament) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Chỉnh sửa giải đấu: ${tournament.title}')),
    );
  }

  void _manageTournament(BuildContext context, Tournament tournament) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Quản lý giải đấu: ${tournament.title}')),
    );
  }

  void _viewStats(BuildContext context, Tournament tournament) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Thống kê giải đấu: ${tournament.title}')),
    );
  }
}