import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ClubPhotoGalleryWidget extends StatelessWidget {
  final List<String> photos;
  final VoidCallback? onViewAll;

  const ClubPhotoGalleryWidget({
    super.key,
    required this.photos,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (photos.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Hình ảnh (${photos.length})',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (photos.length > 4)
                TextButton(
                  onPressed: onViewAll,
                  child: Text(
                    'Xem tất cả',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 2.h),
          SizedBox(
            height: 25.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: photos.length > 4 ? 4 : photos.length,
              itemBuilder: (context, index) {
                if (index == 3 && photos.length > 4) {
                  return _buildMorePhotosCard(context, photos.length - 3);
                }
                return _buildPhotoCard(context, photos[index], index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoCard(BuildContext context, String photoUrl, int index) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: 40.w,
      margin: EdgeInsets.only(right: 3.w),
      child: InkWell(
        onTap: () => _showPhotoViewer(context, index),
        borderRadius: BorderRadius.circular(3.w),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3.w),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3.w),
            child: CustomImageWidget(
              imageUrl: photoUrl,
              width: 40.w,
              height: 25.h,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMorePhotosCard(BuildContext context, int remainingCount) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: 40.w,
      margin: EdgeInsets.only(right: 3.w),
      child: InkWell(
        onTap: onViewAll,
        borderRadius: BorderRadius.circular(3.w),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3.w),
            color: colorScheme.surface,
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(3.w),
                child: CustomImageWidget(
                  imageUrl: photos[3],
                  width: 40.w,
                  height: 25.h,
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3.w),
                  color: Colors.black.withValues(alpha: 0.6),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: 'photo_library',
                        color: Colors.white,
                        size: 8.w,
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        '+$remainingCount',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'ảnh khác',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPhotoViewer(BuildContext context, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _PhotoViewerScreen(
          photos: photos,
          initialIndex: initialIndex,
        ),
      ),
    );
  }
}

class _PhotoViewerScreen extends StatefulWidget {
  final List<String> photos;
  final int initialIndex;

  const _PhotoViewerScreen({
    required this.photos,
    required this.initialIndex,
  });

  @override
  State<_PhotoViewerScreen> createState() => _PhotoViewerScreenState();
}

class _PhotoViewerScreenState extends State<_PhotoViewerScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          '${_currentIndex + 1} / ${widget.photos.length}',
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: 'share',
              color: Colors.white,
              size: 6.w,
            ),
            onPressed: () {
              // Share photo
            },
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemCount: widget.photos.length,
        itemBuilder: (context, index) {
          return InteractiveViewer(
            child: Center(
              child: CustomImageWidget(
                imageUrl: widget.photos[index],
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
          );
        },
      ),
    );
  }
}
