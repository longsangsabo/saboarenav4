import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/post_model.dart';

class PostRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Lấy danh sách bài viết từ feed
  Future<List<PostModel>> getPosts({int limit = 20, int offset = 0}) async {
    try {
      final response = await _supabase
          .from('posts')
          .select('''
            id,
            content,
            image_urls,
            location,
            hashtags,
            created_at,
            user_id,
            users!posts_user_id_fkey(username, display_name, avatar_url),
            like_count,
            comment_count,
            share_count
          ''')
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final List<PostModel> posts = [];
      for (final item in response) {
        final user = item['users'];
        final imageUrls = item['image_urls'] as List?;
        final hashtags = item['hashtags'] as List?;
        
        posts.add(PostModel(
          id: item['id'],
          title: '', // No title in schema
          content: item['content'] ?? '',
          imageUrl: imageUrls?.isNotEmpty == true ? imageUrls!.first : null,
          authorId: item['user_id'],
          authorName: user?['display_name'] ?? user?['username'] ?? 'Anonymous',
          authorAvatarUrl: user?['avatar_url'],
          createdAt: DateTime.parse(item['created_at']),
          likeCount: item['like_count'] ?? 0,
          commentCount: item['comment_count'] ?? 0,
          shareCount: item['share_count'] ?? 0,
          tags: hashtags?.cast<String>(),
        ));
      }

      return posts;
    } catch (e) {
      print('Error fetching posts: $e');
      return [];
    }
  }

  // Tạo bài viết mới
  Future<PostModel?> createPost({
    String? title, // Optional since not in schema
    required String content,
    String? imageUrl,
    List<String>? inputImageUrls,
    List<String>? hashtags,
    String? locationName,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      // Prepare image URLs array
      List<String>? finalImageUrls;
      if (inputImageUrls != null && inputImageUrls.isNotEmpty) {
        finalImageUrls = inputImageUrls;
      } else if (imageUrl != null) {
        finalImageUrls = [imageUrl];
      }

      final response = await _supabase.from('posts').insert({
        'content': content,
        'image_urls': finalImageUrls,
        'hashtags': hashtags,
        'location': locationName,
        'user_id': user.id,
      }).select('''
        id,
        content,
        image_urls,
        location,
        hashtags,
        created_at,
        user_id,
        users!posts_user_id_fkey(username, display_name, avatar_url),
        like_count,
        comment_count,
        share_count
      ''').single();

      final userInfo = response['users'];
      final responseImageUrls = response['image_urls'] as List?;
      final responseHashtags = response['hashtags'] as List?;

      return PostModel(
        id: response['id'],
        title: title ?? '',
        content: response['content'] ?? '',
        imageUrl: responseImageUrls?.isNotEmpty == true ? responseImageUrls!.first : null,
        authorId: response['user_id'],
        authorName: userInfo?['display_name'] ?? userInfo?['username'] ?? 'Anonymous',
        authorAvatarUrl: userInfo?['avatar_url'],
        createdAt: DateTime.parse(response['created_at']),
        likeCount: response['like_count'] ?? 0,
        commentCount: response['comment_count'] ?? 0,
        shareCount: response['share_count'] ?? 0,
        tags: responseHashtags?.cast<String>(),
      );
    } catch (e) {
      print('Error creating post: $e');
      return null;
    }
  }

  // Like/Unlike bài viết
  Future<bool> toggleLike(String postId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      // Kiểm tra xem đã like chưa
      final existingLike = await _supabase
          .from('post_likes')
          .select()
          .eq('post_id', postId)
          .eq('user_id', user.id)
          .maybeSingle();

      if (existingLike != null) {
        // Unlike
        await _supabase
            .from('post_likes')
            .delete()
            .eq('post_id', postId)
            .eq('user_id', user.id);
        
        // Giảm like count
        await _supabase.rpc('decrement_like_count', params: {'post_id': postId});
      } else {
        // Like
        await _supabase.from('post_likes').insert({
          'post_id': postId,
          'user_id': user.id,
        });
        
        // Tăng like count
        await _supabase.rpc('increment_like_count', params: {'post_id': postId});
      }

      return true;
    } catch (e) {
      print('Error toggling like: $e');
      return false;
    }
  }

  // Lấy bài viết theo ID
  Future<PostModel?> getPostById(String postId) async {
    try {
      final response = await _supabase
          .from('posts')
          .select('''
            id,
            content,
            image_urls,
            location,
            hashtags,
            created_at,
            user_id,
            users!posts_user_id_fkey(username, display_name, avatar_url),
            like_count,
            comment_count,
            share_count
          ''')
          .eq('id', postId)
          .single();

      final user = response['users'];
      final imageUrls = response['image_urls'] as List?;
      final hashtags = response['hashtags'] as List?;
      
      return PostModel(
        id: response['id'],
        title: '',
        content: response['content'] ?? '',
        imageUrl: imageUrls?.isNotEmpty == true ? imageUrls!.first : null,
        authorId: response['user_id'],
        authorName: user?['display_name'] ?? user?['username'] ?? 'Anonymous',
        authorAvatarUrl: user?['avatar_url'],
        createdAt: DateTime.parse(response['created_at']),
        likeCount: response['like_count'] ?? 0,
        commentCount: response['comment_count'] ?? 0,
        shareCount: response['share_count'] ?? 0,
        tags: hashtags?.cast<String>(),
      );
    } catch (e) {
      print('Error fetching post by ID: $e');
      return null;
    }
  }

  // Xóa bài viết
  Future<bool> deletePost(String postId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      await _supabase
          .from('posts')
          .delete()
          .eq('id', postId)
          .eq('user_id', user.id);

      return true;
    } catch (e) {
      print('Error deleting post: $e');
      return false;
    }
  }

  // Tìm kiếm bài viết
  Future<List<PostModel>> searchPosts(String query) async {
    try {
      final response = await _supabase
          .from('posts')
          .select('''
            id,
            content,
            image_urls,
            location,
            hashtags,
            created_at,
            user_id,
            users!posts_user_id_fkey(username, display_name, avatar_url),
            like_count,
            comment_count,
            share_count
          ''')
          .ilike('content', '%$query%')
          .order('created_at', ascending: false);

      final List<PostModel> posts = [];
      for (final item in response) {
        final user = item['users'];
        final imageUrls = item['image_urls'] as List?;
        final hashtags = item['hashtags'] as List?;
        
        posts.add(PostModel(
          id: item['id'],
          title: '',
          content: item['content'] ?? '',
          imageUrl: imageUrls?.isNotEmpty == true ? imageUrls!.first : null,
          authorId: item['user_id'],
          authorName: user?['display_name'] ?? user?['username'] ?? 'Anonymous',
          authorAvatarUrl: user?['avatar_url'],
          createdAt: DateTime.parse(item['created_at']),
          likeCount: item['like_count'] ?? 0,
          commentCount: item['comment_count'] ?? 0,
          shareCount: item['share_count'] ?? 0,
          tags: hashtags?.cast<String>(),
        ));
      }

      return posts;
    } catch (e) {
      print('Error searching posts: $e');
      return [];
    }
  }
}