import 'package:flutter/material.dart';
// import '../../../core/app_export.dart';
import '../../member_management_screen/member_management_screen.dart';

class MemberOverviewTab extends StatefulWidget {
  final MemberData memberData;

  const MemberOverviewTab({
    super.key,
    required this.memberData,
  });

  @override
  _MemberOverviewTabState createState() => _MemberOverviewTabState();
}

class _MemberOverviewTabState extends State<MemberOverviewTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPersonalInfoSection(),
          SizedBox(height: 24),
          _buildMembershipDetailsSection(),
          SizedBox(height: 24),
          _buildContactInfoSection(),
          SizedBox(height: 24),
          _buildNotesSection(),
          SizedBox(height: 24),
          _buildQuickStatsSection(),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return _buildSection(
      title: 'Thông tin cá nhân',
      icon: Icons.person,
      children: [
        _buildInfoRow('Họ và tên', widget.memberData.user.name),
        _buildInfoRow('Tên đăng nhập', '@${widget.memberData.user.username}'),
        _buildInfoRow('Xếp hạng', _getRankLabel(widget.memberData.user.rank)),
        _buildInfoRow('Điểm ELO', '${widget.memberData.user.elo}'),
        _buildInfoRow(
          'Trạng thái',
          widget.memberData.user.isOnline ? 'Đang trực tuyến' : 'Ngoại tuyến',
          valueColor: widget.memberData.user.isOnline ? Colors.green : Colors.grey,
        ),
      ],
    );
  }

  Widget _buildMembershipDetailsSection() {
    return _buildSection(
      title: 'Chi tiết thành viên',
      icon: Icons.card_membership,
      children: [
        _buildInfoRow('ID thành viên', widget.memberData.membershipInfo.membershipId),
        _buildInfoRow('Loại thành viên', _getMembershipTypeLabel(widget.memberData.membershipInfo.type)),
        _buildInfoRow('Trạng thái', _getMembershipStatusLabel(widget.memberData.membershipInfo.status)),
        _buildInfoRow('Ngày tham gia', _formatDate(widget.memberData.membershipInfo.joinDate)),
        if (widget.memberData.membershipInfo.expiryDate != null)
          _buildInfoRow('Ngày hết hạn', _formatDate(widget.memberData.membershipInfo.expiryDate!)),
        _buildInfoRow(
          'Tự động gia hạn',
          widget.memberData.membershipInfo.autoRenewal ? 'Có' : 'Không',
          valueColor: widget.memberData.membershipInfo.autoRenewal ? Colors.green : Colors.orange,
        ),
      ],
    );
  }

  Widget _buildContactInfoSection() {
    return _buildSection(
      title: 'Thông tin liên hệ',
      icon: Icons.contact_mail,
      children: [
        _buildInfoRow('Email', 'user@example.com'), // Mock data
        _buildInfoRow('Số điện thoại', '+84 123 456 789'), // Mock data
        _buildInfoRow('Địa chỉ', '123 Đường ABC, Quận 1, TP.HCM'), // Mock data
        _buildInfoRow('Ngày sinh', '01/01/1990'), // Mock data
      ],
    );
  }

  Widget _buildNotesSection() {
    return _buildSection(
      title: 'Ghi chú',
      icon: Icons.note,
      action: TextButton.icon(
        onPressed: _editNotes,
        icon: Icon(Icons.edit, size: 16),
        label: Text('Chỉnh sửa'),
      ),
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Text(
            'Thành viên tích cực, thường xuyên tham gia các hoạt động của CLB. Có kỹ năng chơi tốt và thái độ thân thiện.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStatsSection() {
    return _buildSection(
      title: 'Thống kê tổng quan',
      icon: Icons.analytics,
      children: [
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary.withOpacity(0.1),
                Theme.of(context).colorScheme.secondary.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Tổng trận đấu',
                      '${widget.memberData.activityStats.totalMatches}',
                      Icons.sports_esports,
                      Colors.blue,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Tỷ lệ thắng',
                      '${(widget.memberData.activityStats.winRate * 100).toInt()}%',
                      Icons.emoji_events,
                      Colors.green,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Giải đấu',
                      '${widget.memberData.activityStats.tournamentsJoined}',
                      Icons.military_tech,
                      Colors.orange,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Điểm hoạt động',
                      '${widget.memberData.activityStats.activityScore}',
                      Icons.local_fire_department,
                      Colors.red,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Bài đăng',
                      '${widget.memberData.engagement.postsCount}',
                      Icons.article,
                      Colors.purple,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Điểm tương tác',
                      '${widget.memberData.engagement.socialScore}',
                      Icons.favorite,
                      Colors.pink,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
    Widget? action,
  }) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (action != null) action,
              ],
            ),
            SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: valueColor ?? Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getRankLabel(RankType rank) {
    switch (rank) {
      case RankType.beginner:
        return 'Mới bắt đầu';
      case RankType.amateur:
        return 'Nghiệp dư';
      case RankType.intermediate:
        return 'Trung bình';
      case RankType.advanced:
        return 'Nâng cao';
      case RankType.professional:
        return 'Chuyên nghiệp';
    }
  }

  String _getMembershipTypeLabel(MembershipType type) {
    switch (type) {
      case MembershipType.regular:
        return 'Thường';
      case MembershipType.vip:
        return 'VIP';
      case MembershipType.premium:
        return 'Premium';
    }
  }

  String _getMembershipStatusLabel(MemberStatus status) {
    switch (status) {
      case MemberStatus.active:
        return 'Hoạt động';
      case MemberStatus.inactive:
        return 'Không hoạt động';
      case MemberStatus.suspended:
        return 'Tạm khóa';
      case MemberStatus.pending:
        return 'Chờ duyệt';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _editNotes() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chỉnh sửa ghi chú',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Nhập ghi chú về thành viên...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                maxLines: 5,
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Hủy'),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Lưu'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
