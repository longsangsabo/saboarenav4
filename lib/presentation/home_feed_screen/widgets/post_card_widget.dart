import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PostCardWidget extends StatefulWidget {
  final Map<String, dynamic> post;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onUserTap;

  const PostCardWidget({
    super.key,
    required this.post,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onUserTap,
  });

  @override
  State<PostCardWidget> createState() => _PostCardWidgetState();
}

class _PostCardWidgetState extends State<PostCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _isLiked = widget.post['isLiked'] ?? false;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleLike() {
    setState(() {
      _isLiked = !_isLiked;
    });
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
    widget.onLike?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User header
          _buildUserHeader(context, theme, colorScheme),

          // Post content
          if (widget.post['content'] != null) _buildPostContent(context, theme),

          // Post image/video
          if (widget.post['imageUrl'] != null) _buildPostMedia(context),

          // Location and hashtags
          if (widget.post['location'] != null ||
              (widget.post['hashtags'] as List?)?.isNotEmpty == true)
            _buildLocationAndHashtags(context, theme),

          // Engagement section
          _buildEngagementSection(context, theme, colorScheme),
        ],
      ),
    );
  }

  Widget _buildUserHeader(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Row(
        children: [
          GestureDetector(
            onTap: widget.onUserTap,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 6.w,
                  child: CustomImageWidget(
                    imageUrl: widget.post['userAvatar'] ??
                        'https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png',
                    width: 12.w,
                    height: 12.w,
                    fit: BoxFit.cover,
                  ),
                ),
                // Rank badge
                if (widget.post['userRank'] != null)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 4.w,
                      height: 4.w,
                      decoration: BoxDecoration(
                        color: _getRankColor(widget.post['userRank']),
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: colorScheme.surface, width: 1),
                      ),
                      child: Center(
                        child: Text(
                          widget.post['userRank'],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: widget.onUserTap,
                  child: Text(
                    widget.post['userName'] ?? 'Unknown User',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  _formatTimestamp(widget.post['timestamp']),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: CustomIconWidget(
              iconName: 'more_vert',
              color: colorScheme.onSurfaceVariant,
              size: 20,
            ),
            onSelected: (value) => _handleMenuAction(value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'save', child: Text('Lưu bài viết')),
              const PopupMenuItem(value: 'report', child: Text('Báo cáo')),
              const PopupMenuItem(value: 'hide', child: Text('Ẩn người dùng')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPostContent(BuildContext context, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Text(
        widget.post['content'],
        style: theme.textTheme.bodyMedium,
        maxLines: 10,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildPostMedia(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 2.h),
      width: double.infinity,
      constraints: BoxConstraints(maxHeight: 50.h),
      child: CustomImageWidget(
        imageUrl: widget.post['imageUrl'],
        width: double.infinity,
        height: 40.h,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildLocationAndHashtags(BuildContext context, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.post['location'] != null)
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'location_on',
                  color: theme.colorScheme.primary,
                  size: 16,
                ),
                SizedBox(width: 1.w),
                Expanded(
                  child: Text(
                    widget.post['location'],
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          if ((widget.post['hashtags'] as List?)?.isNotEmpty == true)
            Padding(
              padding: EdgeInsets.only(top: 1.h),
              child: Wrap(
                spacing: 2.w,
                runSpacing: 0.5.h,
                children: (widget.post['hashtags'] as List).map((hashtag) {
                  return Text(
                    '#$hashtag',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEngagementSection(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          // Engagement stats
          Row(
            children: [
              Text(
                '${widget.post['likeCount'] ?? 0} lượt thích',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Text(
                '${widget.post['commentCount'] ?? 0} bình luận',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(width: 4.w),
              Text(
                '${widget.post['shareCount'] ?? 0} chia sẻ',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionButton(
                context,
                icon: _isLiked ? 'favorite' : 'favorite_border',
                label: 'Thích',
                color: _isLiked ? Colors.red : colorScheme.onSurfaceVariant,
                onTap: _handleLike,
              ),
              _buildActionButton(
                context,
                icon: 'chat_bubble_outline',
                label: 'Bình luận',
                color: colorScheme.onSurfaceVariant,
                onTap: widget.onComment,
              ),
              _buildActionButton(
                context,
                icon: 'share',
                label: 'Chia sẻ',
                color: colorScheme.onSurfaceVariant,
                onTap: widget.onShare,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: icon == 'favorite' && _isLiked ? _scaleAnimation.value : 1.0,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: icon,
                    color: color,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getRankColor(String rank) {
    switch (rank.toUpperCase()) {
      case 'A':
        return Colors.red;
      case 'B':
        return Colors.orange;
      case 'C':
        return Colors.yellow[700]!;
      case 'D':
        return Colors.green;
      case 'E':
        return Colors.blue;
      case 'F':
        return Colors.indigo;
      case 'G':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Vừa xong';

    DateTime dateTime;
    if (timestamp is DateTime) {
      dateTime = timestamp;
    } else if (timestamp is String) {
      dateTime = DateTime.tryParse(timestamp) ?? DateTime.now();
    } else {
      return 'Vừa xong';
    }

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Vừa xong';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'save':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã lưu bài viết')),
        );
        break;
      case 'report':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã báo cáo bài viết')),
        );
        break;
      case 'hide':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã ẩn người dùng')),
        );
        break;
    }
  }
}
