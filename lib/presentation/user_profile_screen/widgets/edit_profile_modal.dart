import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../models/user_profile.dart';

class EditProfileModal extends StatefulWidget {
  final UserProfile userProfile;
  final Function(UserProfile) onSave;
  final VoidCallback onCancel;

  const EditProfileModal({
    super.key,
    required this.userProfile,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<EditProfileModal> createState() => _EditProfileModalState();
}

class _EditProfileModalState extends State<EditProfileModal> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _locationController = TextEditingController();

  bool _isLoading = false;
  String? _selectedAvatarPath;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _displayNameController.text = widget.userProfile.fullName;
    _phoneController.text = widget.userProfile.phone ?? '';
    _bioController.text = widget.userProfile.bio ?? '';
    _locationController.text = widget.userProfile.location ?? '';
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    HapticFeedback.lightImpact();

    try {
      // Sử dụng copyWith để cập nhật thông tin
      final updatedProfile = widget.userProfile.copyWith(
        fullName: _displayNameController.text.trim().isEmpty ? widget.userProfile.fullName : _displayNameController.text.trim(),
        bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
        avatarUrl: _selectedAvatarPath ?? widget.userProfile.avatarUrl,
      );

      await widget.onSave(updatedProfile);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
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





  void _changeAvatar() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Thay đổi ảnh đại diện'),
        content: Text('Chức năng thay đổi avatar sẽ được cập nhật sớm'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _selectedAvatarPath = 'mock_new_avatar_path';
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('� Đã cập nhật ảnh đại diện'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text('Cập nhật demo'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Đóng'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _isLoading ? null : widget.onCancel,
                  child: Text(
                    'Hủy',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  ),
                ),
                Text(
                  'Chỉnh sửa hồ sơ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: _isLoading ? null : _handleSave,
                  child: _isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          'Lưu',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ],
            ),
          ),
          
          // Form
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar section
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: widget.userProfile.avatarUrl != null
                                ? NetworkImage(widget.userProfile.avatarUrl!)
                                : null,
                            child: widget.userProfile.avatarUrl == null
                                ? Icon(Icons.person, size: 50, color: Colors.grey)
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: Icon(Icons.camera_alt, color: Colors.white, size: 18),
                                onPressed: _changeAvatar,
                                constraints: BoxConstraints(minWidth: 36, minHeight: 36),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 4.h),
                    
                    // Họ và tên - có thể chỉnh sửa
                    _buildTextField(
                      controller: _displayNameController,
                      label: 'Họ và tên',
                      icon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Tên hiển thị không được để trống';
                        }
                        if (value.trim().length < 2) {
                          return 'Tên phải có ít nhất 2 ký tự';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 3.h),
                    
                    _buildInfoDisplay('Email', widget.userProfile.email, Icons.email_outlined),
                    SizedBox(height: 3.h),
                    
                    // Số điện thoại
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Số điện thoại',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value != null && value.trim().isNotEmpty) {
                          if (!RegExp(r'^[0-9+\-\s\(\)\.]+$').hasMatch(value.trim())) {
                            return 'Số điện thoại không hợp lệ';
                          }
                          if (value.trim().length < 10) {
                            return 'Số điện thoại phải có ít nhất 10 số';
                          }
                        }
                        return null;
                      },
                    ),
                    
                    SizedBox(height: 3.h),
                    
                    // Địa điểm
                    _buildTextField(
                      controller: _locationController,
                      label: 'Địa điểm',
                      icon: Icons.location_on_outlined,
                    ),
                    
                    SizedBox(height: 3.h),
                    
                    // Giới thiệu bản thân
                    _buildTextField(
                      controller: _bioController,
                      label: 'Giới thiệu bản thân',
                      icon: Icons.edit_outlined,
                      maxLines: 4,
                      maxLength: 200,
                      validator: (value) {
                        if (value != null && value.length > 200) {
                          return 'Giới thiệu không được quá 200 ký tự';
                        }
                        return null;
                      },
                    ),
                    
                    SizedBox(height: 2.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          maxLength: maxLength,
          validator: validator,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey.shade600),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.green, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoDisplay(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 1.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey.shade100,
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.grey.shade600),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              Icon(Icons.lock_outlined, color: Colors.grey.shade400, size: 18),
            ],
          ),
        ),
      ],
    );
  }


}