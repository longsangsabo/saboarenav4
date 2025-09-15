import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/create_post_modal_widget.dart';
import './widgets/empty_feed_widget.dart';
import './widgets/feed_tab_widget.dart';
import './widgets/post_card_widget.dart';

class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen>
    with TickerProviderStateMixin {
  int _selectedTabIndex = 0;
  bool _isLoading = false;
  bool _isRefreshing = false;
  final ScrollController _scrollController = ScrollController();
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  // Mock data for posts
  final List<Map<String, dynamic>> _nearbyPosts = [
    {
      "id": 1,
      "userName": "Trần Minh Hoàng",
      "userAvatar":
          "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
      "userRank": "A",
      "content":
          "Vừa có trận đấu 8-ball tuyệt vời tại CLB Billiards Sài Gòn! Cảm ơn anh Dũng đã cho một trận đấu hay. Hẹn gặp lại lần sau! 🎱",
      "imageUrl":
          "https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800&q=80",
      "location": "CLB Billiards Sài Gòn, Quận 1",
      "hashtags": ["8ball", "billiards", "saigon"],
      "timestamp": DateTime.now().subtract(const Duration(hours: 2)),
      "likeCount": 24,
      "commentCount": 8,
      "shareCount": 3,
      "isLiked": false,
    },
    {
      "id": 2,
      "userName": "Nguyễn Thị Mai",
      "userAvatar":
          "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
      "userRank": "B",
      "content":
          "Hôm nay luyện tập kỹ thuật cơ bản. Ai có tips gì cho việc cầm cơ chuẩn không? Mình đang gặp khó khăn với độ chính xác 🤔",
      "location": "Billiards Club Thủ Đức",
      "hashtags": ["practice", "tips", "beginner"],
      "timestamp": DateTime.now().subtract(const Duration(hours: 5)),
      "likeCount": 18,
      "commentCount": 12,
      "shareCount": 2,
      "isLiked": true,
    },
    {
      "id": 3,
      "userName": "Lê Văn Đức",
      "userAvatar":
          "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
      "userRank": "A",
      "content":
          "Giải đấu 9-ball cuối tuần này tại CLB Diamond. Ai muốn tham gia thì inbox mình nhé! Prize pool 5 triệu VNĐ 💰",
      "imageUrl":
          "https://images.unsplash.com/photo-1551698618-1dfe5d97d256?w=800&q=80",
      "location": "Diamond Billiards Club",
      "hashtags": ["tournament", "9ball", "prize"],
      "timestamp": DateTime.now().subtract(const Duration(days: 1)),
      "likeCount": 45,
      "commentCount": 23,
      "shareCount": 15,
      "isLiked": false,
    },
  ];

  final List<Map<String, dynamic>> _followingPosts = [
    {
      "id": 4,
      "userName": "Phạm Quang Huy",
      "userAvatar":
          "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
      "userRank": "A",
      "content":
          "Cú break shot hoàn hảo! 9 bi vào túi trong lần đầu tiên 🔥 Cảm giác thật tuyệt vời!",
      "imageUrl":
          "https://images.unsplash.com/photo-1594736797933-d0401ba2fe65?w=800&q=80",
      "location": "Royal Billiards",
      "hashtags": ["breakshot", "perfect", "9ball"],
      "timestamp": DateTime.now().subtract(const Duration(hours: 3)),
      "likeCount": 67,
      "commentCount": 19,
      "shareCount": 8,
      "isLiked": true,
    },
    {
      "id": 5,
      "userName": "Võ Thị Lan",
      "userAvatar":
          "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
      "userRank": "B",
      "content":
          "Tham gia giải đấu nữ lần đầu tiên. Hồi hộp quá! Chúc mình may mắn nhé các bạn 🍀",
      "location": "Women's Billiards Championship",
      "hashtags": ["women", "tournament", "firsttime"],
      "timestamp": DateTime.now().subtract(const Duration(hours: 8)),
      "likeCount": 89,
      "commentCount": 34,
      "shareCount": 12,
      "isLiked": false,
    },
  ];

  @override
  void initState() {
    super.initState();
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

    // Simulate loading more posts
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isLoading = false);
  }

  Future<void> _refreshFeed() async {
    setState(() => _isRefreshing = true);

    // Simulate refresh
    await Future.delayed(const Duration(seconds: 1));

    setState(() => _isRefreshing = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã cập nhật bảng tin'),
          duration: Duration(seconds: 2),
        ),
      );
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

  void _handlePostAction(String action, Map<String, dynamic> post) {
    switch (action) {
      case 'like':
        setState(() {
          post['isLiked'] = !(post['isLiked'] ?? false);
          post['likeCount'] =
              (post['likeCount'] ?? 0) + (post['isLiked'] ? 1 : -1);
        });
        break;
      case 'comment':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mở trang bình luận')),
        );
        break;
      case 'share':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã chia sẻ bài viết')),
        );
        break;
    }
  }

  void _handleUserTap(Map<String, dynamic> post) {
    Navigator.pushNamed(context, '/user-profile-screen');
  }

  void _handleNavigation(String route) {
    if (route != '/home-feed-screen') {
      Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);
    }
  }

  List<Map<String, dynamic>> get _currentPosts {
    return _selectedTabIndex == 0 ? _nearbyPosts : _followingPosts;
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
              child: _isEmpty
                  ? EmptyFeedWidget(
                      isNearbyTab: _selectedTabIndex == 0,
                      onCreatePost: _showCreatePostModal,
                      onFindFriends: () {
                        Navigator.pushNamed(context, '/find-opponents-screen');
                      },
                    )
                  : RefreshIndicator(
                      onRefresh: _refreshFeed,
                      child: ListView.builder(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
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
                          return PostCardWidget(
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
            child: FloatingActionButton(
              onPressed: _showCreatePostModal,
              tooltip: 'Tạo bài viết',
              child: CustomIconWidget(
                iconName: 'add',
                color: theme.colorScheme.onPrimary,
                size: 28,
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: CustomBottomBar(
        currentRoute: '/home-feed-screen',
        onTap: _handleNavigation,
        badgeCounts: const {
          '/tournament-list-screen': 2,
        },
      ),
    );
  }
}
