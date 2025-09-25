import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';

import '../../models/post_model.dart';
import '../../services/post_repository.dart';
import '../../widgets/comments_modal.dart';
import '../../widgets/share_bottom_sheet.dart';
import './widgets/create_post_modal_widget.dart';
import './widgets/empty_feed_widget.dart';
import './widgets/feed_tab_widget.dart';
import './widgets/feed_post_card_widget.dart';

class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen>
    with TickerProviderStateMixin {
  int _selectedTabIndex = 0;
  bool _isLoading = true;
  final ScrollController _scrollController = ScrollController();
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  // Real Supabase data
  final PostRepository _postRepository = PostRepository();
  List<PostModel> _nearbyPosts = [];
  List<PostModel> _followingPosts = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPosts();
    _scrollController.addListener(_onScroll);
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeInOut),
    );

    _fabAnimationController.forward();
  }

  Future<void> _loadPosts() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Load posts for both tabs using getFeedPosts
      final posts = await _postRepository.getPosts(limit: 20);
      
      setState(() {
        _nearbyPosts = posts;
        _followingPosts = posts; // Use same posts for both tabs for now
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Lỗi tải bài đăng: $e';
      });
    }
  }

  // Convert PostModel to Map for backwards compatibility
  Map<String, dynamic> _postToMap(PostModel post) {
    return {
      'id': post.id,
      'userName': post.authorName, // Use authorName from PostModel
      'userAvatar': post.authorAvatarUrl ?? 'https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png',
      'userRank': null, // TODO: Get user rank
      'content': post.content,
      'imageUrl': post.imageUrl, // Use imageUrl from PostModel
      'location': '', // PostModel doesn't have location
      'hashtags': post.tags ?? [], // Use tags from PostModel
      'timestamp': post.createdAt,
      'likeCount': post.likeCount,
      'commentCount': post.commentCount,
      'shareCount': post.shareCount,
      'isLiked': post.isLiked, // Use isLiked from PostModel
    };
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMorePosts();
    }
  }

  Future<void> _loadMorePosts() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      // Load more posts using getFeedPosts
      final currentList = _selectedTabIndex == 0 ? _nearbyPosts : _followingPosts;
      final morePosts = await _postRepository.getPosts(
        offset: currentList.length,
        limit: 5,
      );
      
      if (_selectedTabIndex == 0) {
        _nearbyPosts.addAll(morePosts);
      } else {
        _followingPosts.addAll(morePosts);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải thêm bài đăng: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshFeed() async {
    setState(() => _isLoading = true);

    try {
      await _loadPosts();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã cập nhật bảng tin'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi cập nhật: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showCreatePostModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreatePostModalWidget(
        onPostCreated: () {
          _refreshFeed();
        },
      ),
    );
  }

  Future<void> _handlePostAction(String action, Map<String, dynamic> post) async {
    switch (action) {
      case 'like':
        await _handleLikeToggle(post);
        break;
      case 'comment':
        _showCommentsModal(post);
        break;
      case 'share':
        await _handleSharePost(post);
        break;
    }
  }

  Future<void> _handleLikeToggle(Map<String, dynamic> post) async {
    try {
      final postId = post['id'];
      final currentlyLiked = post['isLiked'] ?? false;
      
      // Optimistic update
      setState(() {
        post['isLiked'] = !currentlyLiked;
        post['likeCount'] = (post['likeCount'] ?? 0) + (!currentlyLiked ? 1 : -1);
      });

      // Call backend
      if (!currentlyLiked) {
        await _postRepository.likePost(postId);
      } else {
        await _postRepository.unlikePost(postId);
      }
      
    } catch (e) {
      // Revert optimistic update on error
      setState(() {
        post['isLiked'] = !post['isLiked'];
        post['likeCount'] = (post['likeCount'] ?? 0) + (post['isLiked'] ? -1 : 1);
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  void _showCommentsModal(Map<String, dynamic> post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentsModal(
        postId: post['id'],
        postTitle: post['content'] ?? 'Bài viết',
        onCommentAdded: () {
          // Update comment count when new comment is added
          setState(() {
            post['commentCount'] = (post['commentCount'] ?? 0) + 1;
          });
        },
        onCommentDeleted: () {
          // Update comment count when comment is deleted
          setState(() {
            post['commentCount'] = ((post['commentCount'] ?? 0) - 1).clamp(0, double.infinity).toInt();
          });
        },
      ),
    );
  }

  Future<void> _handleSharePost(Map<String, dynamic> post) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ShareBottomSheet(
        postId: post['id'],
        postTitle: post['content'] ?? 'Bài viết',
        postContent: post['content'],
        postImageUrl: post['imageUrl'],
      ),
    );
  }

  void _handleUserTap(Map<String, dynamic> post) {
    Navigator.pushNamed(context, AppRoutes.userProfileScreen);
  }

  void _handleNavigation(String route) {
    if (route != AppRoutes.homeFeedScreen) {
      Navigator.pushReplacementNamed(context, route);
    }
  }

  List<Map<String, dynamic>> get _currentPosts {
    final postModels = _selectedTabIndex == 0 ? _nearbyPosts : _followingPosts;
    return postModels.map((post) => _postToMap(post)).toList();
  }

  bool get _isEmpty {
    return _currentPosts.isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar.homeFeed(
        onNotificationTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mở trang thông báo')),
          );
        },
        onSearchTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mở trang tìm kiếm')),
          );
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Feed tabs
            FeedTabWidget(
              selectedIndex: _selectedTabIndex,
              onTabChanged: (index) {
                setState(() => _selectedTabIndex = index);
              },
            ),

            // Feed content
            Expanded(
              child: _isLoading && _currentPosts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Simple Logo Loading
                          Container(
                            width: 60,
                            height: 60,
                            padding: const EdgeInsets.all(8.0),
                            child: SvgPicture.asset(
                              'assets/images/logo.svg',
                              width: 44,
                              height: 44,
                              fit: BoxFit.contain,
                            ),
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            'Đang tải bảng tin...',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            'Vui lòng đợi một chút',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : _errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 48,
                                color: Colors.red[400],
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                _errorMessage!,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.red[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 3.h),
                              ElevatedButton(
                                onPressed: _loadPosts,
                                child: Text('Thử lại'),
                              ),
                            ],
                          ),
                        )
                      : _isEmpty
                          ? EmptyFeedWidget(
                              isNearbyTab: _selectedTabIndex == 0,
                              onCreatePost: _showCreatePostModal,
                              onFindFriends: () {
                                Navigator.pushNamed(context, AppRoutes.findOpponentsScreen);
                              },
                            )
                          : RefreshIndicator(
                      onRefresh: _refreshFeed,
                      child: ListView.builder(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                        itemCount: _currentPosts.length + (_isLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _currentPosts.length) {
                            return Container(
                              padding: EdgeInsets.all(4.w),
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          final post = _currentPosts[index];
                          return FeedPostCardWidget(
                            post: post,
                            onLike: () => _handlePostAction('like', post),
                            onComment: () => _handlePostAction('comment', post),
                            onShare: () => _handlePostAction('share', post),
                            onUserTap: () => _handleUserTap(post),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _fabAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _fabAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: FloatingActionButton(
                onPressed: _showCreatePostModal,
                tooltip: 'Tạo bài viết',
                backgroundColor: Colors.transparent,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.add,
                  color: theme.colorScheme.onPrimary,
                  size: 28,
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 0,
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: 0, // Home tab
              selectedItemColor: theme.colorScheme.primary,
              unselectedItemColor: Colors.grey[500],
              backgroundColor: Colors.white,
              elevation: 0,
              selectedFontSize: 12,
              unselectedFontSize: 11,
            onTap: (index) {
              switch (index) {
                case 0:
                  // Already on home
                  break;
                case 1:
                  _handleNavigation(AppRoutes.findOpponentsScreen);
                  break;
                case 2:
                  _handleNavigation(AppRoutes.tournamentListScreen);
                  break;
                case 3:
                  _handleNavigation(AppRoutes.clubMainScreen);
                  break;
                case 4:
                  _handleNavigation(AppRoutes.userProfileScreen);
                  break;
              }
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined, size: 24),
                activeIcon: Icon(Icons.home_rounded, size: 26),
                label: 'Trang chủ',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.sports_outlined, size: 24),
                activeIcon: Icon(Icons.sports_rounded, size: 26),
                label: 'Đối thủ',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.emoji_events_outlined, size: 24),
                activeIcon: Icon(Icons.emoji_events_rounded, size: 26),
                label: 'Giải đấu',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.groups_outlined, size: 24),
                activeIcon: Icon(Icons.groups_rounded, size: 26),
                label: 'Câu lạc bộ',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_rounded, size: 24),
                activeIcon: Icon(Icons.person_rounded, size: 26),
                label: 'Cá nhân',
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }
}
