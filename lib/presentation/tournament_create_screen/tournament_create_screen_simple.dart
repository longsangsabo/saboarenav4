import 'package:flutter/material.dart';
import 'package:sabo_arena/theme/app_theme.dart';
import 'package:sabo_arena/widgets/custom_app_bar.dart';
import '../member_management_screen/member_management_screen.dart';
import '../club_settings_screen/club_settings_screen.dart';

class TournamentCreateScreenSimple extends StatefulWidget {
  final String? clubId;

  const TournamentCreateScreenSimple({
    super.key,
    this.clubId,
  });

  @override
  State<TournamentCreateScreenSimple> createState() => _TournamentCreateScreenSimpleState();
}

class _TournamentCreateScreenSimpleState extends State<TournamentCreateScreenSimple> {
  final _formKey = GlobalKey<FormState>();
  
  // Form Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _maxParticipantsController = TextEditingController();
  final TextEditingController _entryFeeController = TextEditingController();
  
  // Form State
  DateTime? _startDate;
  DateTime? _endDate;
  String _tournamentType = 'single_elimination';
  bool _isPublic = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _maxParticipantsController.dispose();
    _entryFeeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Tạo giải đấu'),
      backgroundColor: AppTheme.backgroundLight,
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryLight,
                strokeWidth: 3,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBasicInfoSection(),
                    const SizedBox(height: 32),
                    _buildDateTimeSection(),
                    const SizedBox(height: 32),
                    _buildSettingsSection(),
                    const SizedBox(height: 40),
                    _buildCreateButton(),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: _buildClubBottomNavigationBar(),
    );
  }

  Widget _buildBasicInfoSection() {
    return Container(
      padding: const EdgeInsets.all(24),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thông tin cơ bản',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.textPrimaryLight,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _nameController,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textPrimaryLight,
            ),
            decoration: InputDecoration(
              labelText: 'Tên giải đấu',
              hintText: 'Nhập tên giải đấu',
              labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondaryLight,
              ),
              hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondaryLight.withOpacity(0.7),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.dividerLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.primaryLight, width: 2),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập tên giải đấu';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _descriptionController,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textPrimaryLight,
            ),
            decoration: InputDecoration(
              labelText: 'Mô tả',
              hintText: 'Mô tả về giải đấu',
              labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondaryLight,
              ),
              hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondaryLight.withOpacity(0.7),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.dividerLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.primaryLight, width: 2),
              ),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _maxParticipantsController,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textPrimaryLight,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Số người tối đa',
                    hintText: '16',
                    labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondaryLight,
                    ),
                    hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondaryLight.withOpacity(0.7),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppTheme.dividerLight),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppTheme.primaryLight, width: 2),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập số người';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: TextFormField(
                  controller: _entryFeeController,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textPrimaryLight,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Phí tham gia (VND)',
                    hintText: '50000',
                    labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondaryLight,
                    ),
                    hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondaryLight.withOpacity(0.7),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppTheme.dividerLight),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppTheme.primaryLight, width: 2),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeSection() {
    return Container(
      padding: const EdgeInsets.all(24),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thời gian tổ chức',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.textPrimaryLight,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _selectStartDate(),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ngày bắt đầu',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _startDate != null
                              ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                              : 'Chọn ngày bắt đầu',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: InkWell(
                  onTap: () => _selectEndDate(),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ngày kết thúc',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _endDate != null
                              ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                              : 'Chọn ngày kết thúc',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
            spreadRadius: -2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cài đặt giải đấu',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          // Tournament Type
          const Text(
            'Loại giải đấu',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildTypeChip('single_elimination', 'Loại trực tiếp'),
              _buildTypeChip('round_robin', 'Vòng tròn'),
              _buildTypeChip('swiss', 'Swiss'),
            ],
          ),
          const SizedBox(height: 16),
          // Public/Private
          SwitchListTile(
            title: const Text('Giải đấu công khai'),
            subtitle: const Text('Cho phép người khác tìm thấy và tham gia'),
            value: _isPublic,
            onChanged: (value) {
              setState(() {
                _isPublic = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(String value, String label) {
    final isSelected = _tournamentType == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _tournamentType = value;
        });
      },
      selectedColor: AppTheme.primaryLight.withOpacity(0.2),
      checkmarkColor: AppTheme.primaryLight,
    );
  }

  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _createTournament,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryLight,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Tạo giải đấu',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<void> _createTournament() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ngày bắt đầu và kết thúc')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implement actual tournament creation
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tạo giải đấu thành công!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tạo giải đấu: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildClubBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.blue[600],
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
      currentIndex: 2, // Current tab is "Giải đấu"
      onTap: (index) {
        final clubId = widget.clubId;
        if (clubId == null) return;
        
        switch (index) {
          case 0:
            Navigator.pop(context); // Go back to dashboard
            break;
          case 1:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MemberManagementScreen(clubId: clubId),
              ),
            );
            break;
          case 2:
            // Already on tournament create
            break;
          case 3:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ClubSettingsScreen(clubId: clubId),
              ),
            );
            break;
        }
      },
    );
  }
}
