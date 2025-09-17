import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


import '../../../core/app_export.dart';

class QRCodeWidget extends StatelessWidget {
  final Map<String, dynamic> userData;
  final VoidCallback? onClose;

  const QRCodeWidget({
    super.key,
    required this.userData,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle Bar
          Container(
            margin: EdgeInsets.only(top: 2),
            width: 12.w,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mã QR của tôi',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  onPressed: onClose,
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),

          // QR Code Section
          Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.lightTheme.colorScheme.shadow
                      .withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // User Info
                Row(
                  children: [
                    Container(
                      width: 15.w,
                      height: 15.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.lightTheme.colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: CustomImageWidget(
                          imageUrl: userData["avatar"] as String? ??
                              "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
                          width: 15.w,
                          height: 15.w,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userData["displayName"] as String? ??
                                "Nguyễn Văn An",
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.lightTheme.colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Rank ${userData["rank"] as String? ?? "B"} • ELO ${userData["eloRating"] ?? 1450}',
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 4),

                // QR Code Placeholder (In real app, use qr_flutter package)
                Container(
                  width: 50.w,
                  height: 50.w,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Container(
                      width: 45.w,
                      height: 45.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _buildQRPattern(),
                    ),
                  ),
                ),

                SizedBox(height: 3),

                // User ID
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.primary
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'ID: ${userData["userId"] as String? ?? "SABO123456"}',
                    style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 3),

          // Action Buttons
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _shareQRCode(context),
                    icon: CustomIconWidget(
                      iconName: 'share',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 20,
                    ),
                    label: Text('Chia sẻ'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _saveQRCode(context),
                    icon: CustomIconWidget(
                      iconName: 'download',
                      color: AppTheme.lightTheme.colorScheme.onPrimary,
                      size: 20,
                    ),
                    label: Text('Lưu ảnh'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 2),

          // Instructions
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Text(
              'Bạn bè có thể quét mã QR này để thêm bạn vào danh sách bạn bè',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildQRPattern() {
    // Simple QR-like pattern for demonstration
    return GridView.builder(
      padding: EdgeInsets.all(2.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 21,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
      ),
      itemCount: 441, // 21x21
      itemBuilder: (context, index) {
        // Create a simple pattern that looks like QR code
        final row = index ~/ 21;
        final col = index % 21;

        // Corner squares
        final isCornerSquare = (row < 7 && col < 7) ||
            (row < 7 && col > 13) ||
            (row > 13 && col < 7);

        // Random pattern for middle area
        final isBlack =
            isCornerSquare || (row + col) % 3 == 0 || (row * col) % 7 == 0;

        return Container(
          decoration: BoxDecoration(
            color: isBlack ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(0.5),
          ),
        );
      },
    );
  }

  void _shareQRCode(BuildContext context) {
    // In real app, implement sharing functionality
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đang chia sẻ mã QR...'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );
  }

  void _saveQRCode(BuildContext context) {
    // In real app, implement save to gallery functionality
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã lưu mã QR vào thư viện ảnh'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
