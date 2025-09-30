import 'package:flutter/material.dart';
import 'package:sabo_arena/widgets/custom_app_bar.dart';
import 'package:sabo_arena/theme/app_theme.dart';

class PaymentSettingsScreen extends StatefulWidget {
  final String clubId;

  const PaymentSettingsScreen({
    super.key,
    required this.clubId,
  });

  @override
  State<PaymentSettingsScreen> createState() => _PaymentSettingsScreenState();
}

class _PaymentSettingsScreenState extends State<PaymentSettingsScreen> {
  bool cashPaymentEnabled = true;
  bool bankTransferEnabled = true;
  bool eWalletEnabled = true;
  bool cardPaymentEnabled = false;

  List<Map<String, dynamic>> bankAccounts = [
    {
      'id': '1',
      'bankName': 'Vietcombank',
      'accountNumber': '1234567890',
      'accountName': 'SABO BILLIARDS',
      'qrCodeUrl': '',
      'isActive': true,
    },
    {
      'id': '2',
      'bankName': 'Techcombank',
      'accountNumber': '0987654321',
      'accountName': 'SABO BILLIARDS',
      'qrCodeUrl': '',
      'isActive': true,
    },
  ];

  List<Map<String, dynamic>> eWallets = [
    {
      'id': '1',
      'name': 'MoMo',
      'phoneNumber': '0901234567',
      'qrCodeUrl': '',
      'isActive': true,
    },
    {
      'id': '2',
      'name': 'ZaloPay',
      'phoneNumber': '0901234567',
      'qrCodeUrl': '',
      'isActive': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Phương thức thanh toán'),
      backgroundColor: AppTheme.backgroundLight,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildPaymentMethods(),
            const SizedBox(height: 32),
            _buildBankAccounts(),
            const SizedBox(height: 32),
            _buildEWallets(),
            const SizedBox(height: 32),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryLight.withOpacity(0.1),
            AppTheme.primaryLight.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryLight.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.payment, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cài đặt thanh toán',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.textPrimaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Thiết lập các phương thức thanh toán cho CLB',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phương thức thanh toán',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppTheme.textPrimaryLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Container(
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
          child: Column(
            children: [
              _buildPaymentMethodItem(
                icon: Icons.money,
                title: 'Tiền mặt',
                subtitle: 'Thanh toán trực tiếp tại quầy',
                isEnabled: cashPaymentEnabled,
                onChanged: (value) {
                  setState(() {
                    cashPaymentEnabled = value;
                  });
                },
              ),
              _buildPaymentMethodItem(
                icon: Icons.account_balance,
                title: 'Chuyển khoản ngân hàng',
                subtitle: 'Chuyển khoản qua tài khoản ngân hàng',
                isEnabled: bankTransferEnabled,
                onChanged: (value) {
                  setState(() {
                    bankTransferEnabled = value;
                  });
                },
              ),
              _buildPaymentMethodItem(
                icon: Icons.phone_android,
                title: 'Ví điện tử',
                subtitle: 'MoMo, ZaloPay, ViettelPay...',
                isEnabled: eWalletEnabled,
                onChanged: (value) {
                  setState(() {
                    eWalletEnabled = value;
                  });
                },
              ),
              _buildPaymentMethodItem(
                icon: Icons.credit_card,
                title: 'Thẻ tín dụng/ghi nợ',
                subtitle: 'Visa, MasterCard (sắp có)',
                isEnabled: cardPaymentEnabled,
                onChanged: (value) {
                  setState(() {
                    cardPaymentEnabled = value;
                  });
                },
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isEnabled,
    required Function(bool) onChanged,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: !isLast
            ? Border(
                bottom: BorderSide(
                  color: AppTheme.dividerLight.withOpacity(0.3),
                  width: 1,
                ),
              )
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isEnabled
                  ? AppTheme.primaryLight.withOpacity(0.12)
                  : Colors.grey.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: isEnabled ? AppTheme.primaryLight : Colors.grey,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppTheme.textPrimaryLight,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppTheme.textSecondaryLight,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isEnabled,
            onChanged: onChanged,
            activeThumbColor: AppTheme.primaryLight,
          ),
        ],
      ),
    );
  }

  Widget _buildBankAccounts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tài khoản ngân hàng',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.textPrimaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Thông tin tài khoản để nhận chuyển khoản',
                  style: TextStyle(
                    color: AppTheme.textSecondaryLight,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            IconButton(
              onPressed: _addBankAccount,
              icon: Icon(Icons.add, color: AppTheme.primaryLight),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
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
          child: Column(
            children: bankAccounts.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, dynamic> account = entry.value;
              
              return _buildBankAccountItem(account, index);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildBankAccountItem(Map<String, dynamic> account, int index) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: index < bankAccounts.length - 1
            ? Border(
                bottom: BorderSide(
                  color: AppTheme.dividerLight.withOpacity(0.3),
                  width: 1,
                ),
              )
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: account['isActive']
                  ? AppTheme.primaryLight.withOpacity(0.12)
                  : Colors.grey.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.account_balance,
              color: account['isActive'] ? AppTheme.primaryLight : Colors.grey,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account['bankName'],
                  style: TextStyle(
                    color: AppTheme.textPrimaryLight,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'STK: ${account['accountNumber']}',
                  style: TextStyle(
                    color: AppTheme.primaryLight,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  account['accountName'],
                  style: TextStyle(
                    color: AppTheme.textSecondaryLight,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: account['isActive'],
            onChanged: (value) {
              setState(() {
                account['isActive'] = value;
              });
            },
            activeThumbColor: AppTheme.primaryLight,
          ),
          PopupMenuButton(
            icon: Icon(Icons.more_vert, color: AppTheme.textSecondaryLight),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, color: AppTheme.primaryLight),
                    const SizedBox(width: 12),
                    const Text('Chỉnh sửa'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'qr',
                child: Row(
                  children: [
                    Icon(Icons.qr_code, color: AppTheme.primaryLight),
                    const SizedBox(width: 12),
                    const Text('Tạo QR Code'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete, color: Colors.red),
                    const SizedBox(width: 12),
                    Text('Xóa', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'edit') {
                _editBankAccount(account, index);
              } else if (value == 'qr') {
                _generateQRCode(account);
              } else if (value == 'delete') {
                _deleteBankAccount(index);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEWallets() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ví điện tử',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.textPrimaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Thông tin ví điện tử để nhận thanh toán',
                  style: TextStyle(
                    color: AppTheme.textSecondaryLight,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            IconButton(
              onPressed: _addEWallet,
              icon: Icon(Icons.add, color: AppTheme.primaryLight),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
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
          child: Column(
            children: eWallets.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, dynamic> wallet = entry.value;
              
              return _buildEWalletItem(wallet, index);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildEWalletItem(Map<String, dynamic> wallet, int index) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: index < eWallets.length - 1
            ? Border(
                bottom: BorderSide(
                  color: AppTheme.dividerLight.withOpacity(0.3),
                  width: 1,
                ),
              )
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: wallet['isActive']
                  ? AppTheme.primaryLight.withOpacity(0.12)
                  : Colors.grey.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.phone_android,
              color: wallet['isActive'] ? AppTheme.primaryLight : Colors.grey,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  wallet['name'],
                  style: TextStyle(
                    color: AppTheme.textPrimaryLight,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'SĐT: ${wallet['phoneNumber']}',
                  style: TextStyle(
                    color: AppTheme.primaryLight,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: wallet['isActive'],
            onChanged: (value) {
              setState(() {
                wallet['isActive'] = value;
              });
            },
            activeThumbColor: AppTheme.primaryLight,
          ),
          PopupMenuButton(
            icon: Icon(Icons.more_vert, color: AppTheme.textSecondaryLight),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, color: AppTheme.primaryLight),
                    const SizedBox(width: 12),
                    const Text('Chỉnh sửa'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'qr',
                child: Row(
                  children: [
                    Icon(Icons.qr_code, color: AppTheme.primaryLight),
                    const SizedBox(width: 12),
                    const Text('Tạo QR Code'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete, color: Colors.red),
                    const SizedBox(width: 12),
                    Text('Xóa', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'edit') {
                _editEWallet(wallet, index);
              } else if (value == 'qr') {
                _generateQRCode(wallet);
              } else if (value == 'delete') {
                _deleteEWallet(index);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryLight,
            AppTheme.primaryLight.withOpacity(0.8),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryLight.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _savePaymentSettings,
          child: const Center(
            child: Text(
              'Lưu cài đặt thanh toán',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _addBankAccount() {
    _showBankAccountDialog();
  }

  void _editBankAccount(Map<String, dynamic> account, int index) {
    _showBankAccountDialog(account: account, index: index);
  }

  void _showBankAccountDialog({Map<String, dynamic>? account, int? index}) {
    final bankNameController = TextEditingController(text: account?['bankName'] ?? '');
    final accountNumberController = TextEditingController(text: account?['accountNumber'] ?? '');
    final accountNameController = TextEditingController(text: account?['accountName'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(account == null ? 'Thêm tài khoản ngân hàng' : 'Chỉnh sửa tài khoản'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: bankNameController,
                decoration: const InputDecoration(
                  labelText: 'Tên ngân hàng',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: accountNumberController,
                decoration: const InputDecoration(
                  labelText: 'Số tài khoản',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: accountNameController,
                decoration: const InputDecoration(
                  labelText: 'Tên chủ tài khoản',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (bankNameController.text.isNotEmpty && accountNumberController.text.isNotEmpty) {
                setState(() {
                  if (account == null) {
                    bankAccounts.add({
                      'id': DateTime.now().millisecondsSinceEpoch.toString(),
                      'bankName': bankNameController.text,
                      'accountNumber': accountNumberController.text,
                      'accountName': accountNameController.text,
                      'qrCodeUrl': '',
                      'isActive': true,
                    });
                  } else {
                    bankAccounts[index!]['bankName'] = bankNameController.text;
                    bankAccounts[index]['accountNumber'] = accountNumberController.text;
                    bankAccounts[index]['accountName'] = accountNameController.text;
                  }
                });
                Navigator.pop(context);
              }
            },
            child: Text(account == null ? 'Thêm' : 'Cập nhật'),
          ),
        ],
      ),
    );
  }

  void _addEWallet() {
    _showEWalletDialog();
  }

  void _editEWallet(Map<String, dynamic> wallet, int index) {
    _showEWalletDialog(wallet: wallet, index: index);
  }

  void _showEWalletDialog({Map<String, dynamic>? wallet, int? index}) {
    final nameController = TextEditingController(text: wallet?['name'] ?? '');
    final phoneController = TextEditingController(text: wallet?['phoneNumber'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(wallet == null ? 'Thêm ví điện tử' : 'Chỉnh sửa ví điện tử'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Tên ví (MoMo, ZaloPay...)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Số điện thoại',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && phoneController.text.isNotEmpty) {
                setState(() {
                  if (wallet == null) {
                    eWallets.add({
                      'id': DateTime.now().millisecondsSinceEpoch.toString(),
                      'name': nameController.text,
                      'phoneNumber': phoneController.text,
                      'qrCodeUrl': '',
                      'isActive': true,
                    });
                  } else {
                    eWallets[index!]['name'] = nameController.text;
                    eWallets[index]['phoneNumber'] = phoneController.text;
                  }
                });
                Navigator.pop(context);
              }
            },
            child: Text(wallet == null ? 'Thêm' : 'Cập nhật'),
          ),
        ],
      ),
    );
  }

  void _generateQRCode(Map<String, dynamic> paymentMethod) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tạo QR Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'QR Code\n(Sắp có)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tính năng tạo QR Code đang được phát triển',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _deleteBankAccount(int index) {
    _showDeleteDialog('tài khoản ngân hàng này', () {
      setState(() {
        bankAccounts.removeAt(index);
      });
    });
  }

  void _deleteEWallet(int index) {
    _showDeleteDialog('ví điện tử này', () {
      setState(() {
        eWallets.removeAt(index);
      });
    });
  }

  void _showDeleteDialog(String itemName, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa $itemName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              onConfirm();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Đã xóa thành công'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _savePaymentSettings() {
    // TODO: Save to database
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Đã lưu cài đặt thanh toán'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
    Navigator.pop(context);
  }
}