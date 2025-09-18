import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sabo_arena/models/user_profile.dart';
import 'package:sabo_arena/services/share_service.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/services.dart';

class UserQRCodeWidget extends StatelessWidget {
  final UserProfile user;
  final bool showShareButton;
  final VoidCallback? onClose;

  const UserQRCodeWidget({
    Key? key,
    required this.user,
    this.showShareButton = true,
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final qrData = ShareService.generateUserQRData(user);
    final userCode = ShareService.generateUserCode(user.id);

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mã QR của tôi',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (onClose != null)
                IconButton(
                  onPressed: onClose,
                  icon: Icon(Icons.close),
                ),
            ],
          ),
          
          SizedBox(height: 2.h),
          
          // User Info
          Row(
            children: [
              CircleAvatar(
                radius: 6.w,
                backgroundImage: user.avatarUrl != null
                    ? NetworkImage(user.avatarUrl!)
                    : null,
                backgroundColor: Colors.grey[300],
                child: user.avatarUrl == null
                    ? Icon(Icons.person, size: 6.w, color: Colors.grey[600])
                    : null,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'ID: $userCode',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      'ELO: ${user.eloRating} • Rank: ${user.rank ?? 'Chưa xếp hạng'}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: 3.h),
          
          // QR Code
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(2.w),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 50.w,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              errorCorrectionLevel: QrErrorCorrectLevel.M,
              padding: EdgeInsets.all(2.w),
            ),
          ),
          
          SizedBox(height: 2.h),
          
          // Instructions
          Text(
            'Để người khác quét mã này để xem hồ sơ và thách đấu với bạn',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[600],
            ),
          ),
          
          SizedBox(height: 3.h),
          
          // Action Buttons
          Row(
            children: [
              // Copy Link Button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _copyLink(context, qrData),
                  icon: Icon(Icons.copy, size: 4.w),
                  label: Text('Sao chép link'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 3.w),
                  ),
                ),
              ),
              
              SizedBox(width: 3.w),
              
              // Share Button
              if (showShareButton)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _shareProfile(context),
                    icon: Icon(Icons.share, size: 4.w, color: Colors.white),
                    label: Text('Chia sẻ', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(vertical: 3.w),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
  
  void _copyLink(BuildContext context, String qrData) async {
    try {
      await Clipboard.setData(ClipboardData(text: qrData));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã sao chép link vào clipboard'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi sao chép: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  void _shareProfile(BuildContext context) async {
    try {
      await ShareService.shareUserProfile(user);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi chia sẻ: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

/// Modal để hiển thị QR Code
class UserQRCodeModal extends StatelessWidget {
  final UserProfile user;

  const UserQRCodeModal({
    Key? key,
    required this.user,
  }) : super(key: key);

  static void show(BuildContext context, UserProfile user) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: UserQRCodeModal(user: user),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return UserQRCodeWidget(
      user: user,
      onClose: () => Navigator.of(context).pop(),
    );
  }
}

/// Bottom Sheet để hiển thị QR Code
class UserQRCodeBottomSheet extends StatelessWidget {
  final UserProfile user;

  const UserQRCodeBottomSheet({
    Key? key,
    required this.user,
  }) : super(key: key);

  static void show(BuildContext context, UserProfile user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UserQRCodeBottomSheet(user: user),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(5.w),
          topRight: Radius.circular(5.w),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: UserQRCodeWidget(
            user: user,
            onClose: () => Navigator.of(context).pop(),
          ),
        ),
      ),
    );
  }
}