import 'package:flutter/material.dart';
import 'package:sabo_arena/widgets/custom_app_bar.dart';
import 'package:sabo_arena/theme/app_theme.dart';
import '../club_profile_edit_screen/club_profile_edit_screen_simple.dart';

class ClubSettingsScreen extends StatefulWidget {
  final String clubId;

  const ClubSettingsScreen({
    super.key,
    required this.clubId,
  });

  @override
  State<ClubSettingsScreen> createState() => _ClubSettingsScreenState();
}

class _ClubSettingsScreenState extends State<ClubSettingsScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Cài đặt CLB'),
      backgroundColor: AppTheme.backgroundLight,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cài đặt chung',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.textPrimaryLight,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            _buildSettingsCard([
              _buildSettingItem(
                Icons.edit,
                'Chỉnh sửa thông tin CLB',
                'Tên, mô tả, địa chỉ, số điện thoại',
                () => _navigateToProfileEdit(),
              ),
              _buildSettingItem(
                Icons.access_time,
                'Giờ hoạt động',
                'Thiết lập giờ mở cửa và đóng cửa',
                () => _showOperatingHours(),
              ),
              _buildSettingItem(
                Icons.rule,
                'Quy định CLB',
                'Thiết lập các quy định và điều khoản',
                () => _showClubRules(),
              ),
            ]),
            const SizedBox(height: 32),
            Text(
              'Tài chính',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.textPrimaryLight,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            _buildSettingsCard([
              _buildSettingItem(
                Icons.monetization_on,
                'Bảng giá dịch vụ',
                'Thiết lập giá các dịch vụ và sân chơi',
                () => _showPricingSettings(),
              ),
              _buildSettingItem(
                Icons.payment,
                'Phương thức thanh toán',
                'Thiết lập các phương thức thanh toán',
                () => _showPaymentSettings(),
              ),
              _buildSettingItem(
                Icons.receipt,
                'Hóa đơn và biên lai',
                'Cài đặt thông tin xuất hóa đơn',
                () => _showInvoiceSettings(),
              ),
            ]),
            const SizedBox(height: 32),
            Text(
              'Thành viên',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.textPrimaryLight,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            _buildSettingsCard([
              _buildSettingItem(
                Icons.person_add,
                'Chính sách thành viên',
                'Thiết lập quy định cho thành viên mới',
                () => _showMembershipPolicy(),
              ),
              _buildSettingItem(
                Icons.card_membership,
                'Loại thành viên',
                'Thiết lập các loại thành viên và quyền lợi',
                () => _showMembershipTypes(),
              ),
              _buildSettingItem(
                Icons.loyalty,
                'Chương trình loyalty',
                'Thiết lập điểm thưởng và ưu đãi',
                () => _showLoyaltyProgram(),
              ),
            ]),
            const SizedBox(height: 24),
            const Text(
              'Hệ thống',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSettingsCard([
              _buildSettingItem(
                Icons.notifications,
                'Cài đặt thông báo',
                'Thiết lập thông báo tự động',
                () => _showNotificationSettings(),
              ),
              _buildSettingItem(
                Icons.backup,
                'Sao lưu dữ liệu',
                'Sao lưu và khôi phục dữ liệu CLB',
                () => _showBackupSettings(),
              ),
              _buildSettingItem(
                Icons.security,
                'Bảo mật',
                'Cài đặt bảo mật và quyền truy cập',
                () => _showSecuritySettings(),
              ),
            ]),
            const SizedBox(height: 80), // Space for bottom navigation
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight,
            offset: const Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingItem(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.primaryLight.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppTheme.primaryLight, size: 24),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: AppTheme.textPrimaryLight,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppTheme.textSecondaryLight,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: AppTheme.textSecondaryLight,
        size: 20,
      ),
      onTap: onTap,
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppTheme.primaryLight,
      unselectedItemColor: Colors.grey[600],
      backgroundColor: Colors.white,
      elevation: 8,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'Thành viên',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.emoji_events),
          label: 'Giải đấu',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Cài đặt',
        ),
      ],
      currentIndex: 3,
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pop(context);
            break;
          case 1:
            Navigator.pop(context);
            // Will navigate to member management from dashboard
            break;
          case 2:
            Navigator.pop(context);
            // Will navigate to tournament create from dashboard
            break;
          case 3:
            // Already on settings
            break;
        }
      },
    );
  }

  // Navigation methods
  void _navigateToProfileEdit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClubProfileEditScreenSimple(clubId: widget.clubId),
      ),
    );
  }

  void _showOperatingHours() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tính năng giờ hoạt động đang được phát triển')),
    );
  }

  void _showClubRules() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tính năng quy định CLB đang được phát triển')),
    );
  }

  void _showPricingSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tính năng bảng giá đang được phát triển')),
    );
  }

  void _showPaymentSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tính năng thanh toán đang được phát triển')),
    );
  }

  void _showInvoiceSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tính năng hóa đơn đang được phát triển')),
    );
  }

  void _showMembershipPolicy() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tính năng chính sách thành viên đang được phát triển')),
    );
  }

  void _showMembershipTypes() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tính năng loại thành viên đang được phát triển')),
    );
  }

  void _showLoyaltyProgram() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tính năng loyalty đang được phát triển')),
    );
  }

  void _showNotificationSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tính năng cài đặt thông báo đang được phát triển')),
    );
  }

  void _showBackupSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tính năng sao lưu đang được phát triển')),
    );
  }

  void _showSecuritySettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tính năng bảo mật đang được phát triển')),
    );
  }
}
