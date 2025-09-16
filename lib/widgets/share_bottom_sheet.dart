import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class ShareBottomSheet extends StatelessWidget {
  final String postId;
  final String postTitle;
  final String? postContent;
  final String? postImageUrl;

  const ShareBottomSheet({
    Key? key,
    required this.postId,
    required this.postTitle,
    this.postContent,
    this.postImageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Chia sẻ bài viết',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // Share options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _buildShareOption(
                  context,
                  icon: Icons.share,
                  title: 'Chia sẻ chung',
                  subtitle: 'Chia sẻ qua các ứng dụng khác',
                  onTap: () => _shareGeneric(context),
                ),
                
                _buildShareOption(
                  context,
                  icon: Icons.copy,
                  title: 'Sao chép liên kết',
                  subtitle: 'Sao chép link bài viết vào clipboard',
                  onTap: () => _copyLink(context),
                ),

                _buildShareOption(
                  context,
                  icon: Icons.message,
                  title: 'Chia sẻ dưới dạng text',
                  subtitle: 'Chia sẻ nội dung bài viết',
                  onTap: () => _shareAsText(context),
                ),

                if (postImageUrl != null)
                  _buildShareOption(
                    context,
                    icon: Icons.image,
                    title: 'Chia sẻ hình ảnh',
                    subtitle: 'Chia sẻ hình ảnh từ bài viết',
                    onTap: () => _shareImage(context),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildShareOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.grey.shade700,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  void _shareGeneric(BuildContext context) async {
    try {
      final shareText = _buildShareText();
      await Share.share(
        shareText,
        subject: 'Bài viết từ Sabo Arena',
      );
      Navigator.pop(context);
    } catch (e) {
      _showError(context, 'Lỗi chia sẻ: $e');
    }
  }

  void _copyLink(BuildContext context) async {
    try {
      final link = 'https://saboarena.app/post/$postId';
      await Clipboard.setData(ClipboardData(text: link));
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã sao chép liên kết vào clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      _showError(context, 'Lỗi sao chép: $e');
    }
  }

  void _shareAsText(BuildContext context) async {
    try {
      final shareText = _buildShareText();
      await Share.share(shareText);
      Navigator.pop(context);
    } catch (e) {
      _showError(context, 'Lỗi chia sẻ text: $e');
    }
  }

  void _shareImage(BuildContext context) async {
    if (postImageUrl == null) return;

    try {
      final shareText = _buildShareText();
      // Note: To share image from URL, we would need to download it first
      // For now, we'll share the URL with the text
      await Share.share('$shareText\n\nHình ảnh: $postImageUrl');
      Navigator.pop(context);
    } catch (e) {
      _showError(context, 'Lỗi chia sẻ hình ảnh: $e');
    }
  }

  String _buildShareText() {
    final buffer = StringBuffer();
    buffer.writeln('📌 $postTitle');
    
    if (postContent != null && postContent!.isNotEmpty) {
      buffer.writeln();
      buffer.writeln(postContent);
    }
    
    buffer.writeln();
    buffer.writeln('🎯 Từ Sabo Arena - Cộng đồng Billiards Việt Nam');
    buffer.writeln('Xem chi tiết: https://saboarena.app/post/$postId');
    
    return buffer.toString();
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}