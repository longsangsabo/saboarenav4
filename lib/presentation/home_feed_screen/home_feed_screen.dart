import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../models/post.dart';
import '../../services/social_service.dart';
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
  final SocialService _socialService = SocialService.instance;
  late TabController _tabController;

  List<Post> _allPosts = [];
  List<Post> _followingPosts = [];
  bool _isLoading = true;
  int _currentPage = 0;
  final int _postsPerPage = 20;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFeedPosts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFeedPosts() async {
    try {
      setState(() => _isLoading = true);

      final posts = await _socialService.getFeedPosts(
        limit: _postsPerPage,
        offset: _currentPage * _postsPerPage,
      );

      setState(() {
        if (_currentPage == 0) {
          _allPosts = posts;
        } else {
          _allPosts.addAll(posts);
        }
        _followingPosts = _allPosts; // For now, same as all posts
        _isLoading = false;
      });
    } catch (error) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải bài viết: $error')),
      );
    }
  }

  Future<void> _refreshFeed() async {
    _currentPage = 0;
    await _loadFeedPosts();
  }

  Future<void> _loadMorePosts() async {
    if (!_isLoading) {
      _currentPage++;
      await _loadFeedPosts();
    }
  }

  void _showCreatePostModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => CreatePostModalWidget(
        onPostCreated: () {
          setState(() {
            // Refresh feed after post creation
            _refreshFeed();
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SABO Arena',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48.h),
          child: FeedTabWidget(
            selectedIndex: _tabController.index,
            onTabChanged: (index) {
              _tabController.animateTo(index);
            },
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showCreatePostModal,
            icon: const Icon(Icons.add_box_outlined),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // All Posts Tab
          _buildPostsList(_allPosts),
          // Following Posts Tab
          _buildPostsList(_followingPosts),
        ],
      ),
    );
  }

  Widget _buildPostsList(List<Post> posts) {
    if (_isLoading && posts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (posts.isEmpty) {
      return EmptyFeedWidget(
        isNearbyTab: _tabController.index == 0,
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshFeed,
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            _loadMorePosts();
          }
          return false;
        },
        child: ListView.builder(
          padding: EdgeInsets.only(top: 8.h, bottom: 80.h),
          itemCount: posts.length + (_isLoading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == posts.length) {
              return Container(
                padding: EdgeInsets.all(16.w),
                alignment: Alignment.center,
                child: const CircularProgressIndicator(),
              );
            }

            return PostCardWidget(
              post: posts[index],
            );
          },
        ),
      ),
    );
  }
}