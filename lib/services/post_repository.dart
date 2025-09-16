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
            title,
            content,
            image_url,
            created_at,
            author_id,
            profiles!posts_author_id_fkey(username, avatar_url),
            like_count,
            comment_count,
            share_count
          ''')
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final List<PostModel> posts = [];
      for (final item in response) {
        final profile = item['profiles'];
        posts.add(PostModel(
          id: item['id'],
          title: item['title'] ?? '',
          content: item['content'] ?? '',
          imageUrl: item['image_url'],
          authorId: item['author_id'],
          authorName: profile?['username'] ?? 'Anonymous',
          authorAvatarUrl: profile?['avatar_url'],
          createdAt: DateTime.parse(item['created_at']),
          likeCount: item['like_count'] ?? 0,
          commentCount: item['comment_count'] ?? 0,
          shareCount: item['share_count'] ?? 0,
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
    required String title,
    required String content,
    String? imageUrl,
    List<String>? tags,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final response = await _supabase.from('posts').insert({
        'title': title,
        'content': content,
        'image_url': imageUrl,
        'author_id': user.id,
        'tags': tags,
      }).select().single();

      return PostModel.fromJson(response);
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
            title,
            content,
            image_url,
            created_at,
            author_id,
            profiles!posts_author_id_fkey(username, avatar_url),
            like_count,
            comment_count,
            share_count
          ''')
          .eq('id', postId)
          .single();

      final profile = response['profiles'];
      return PostModel(
        id: response['id'],
        title: response['title'] ?? '',
        content: response['content'] ?? '',
        imageUrl: response['image_url'],
        authorId: response['author_id'],
        authorName: profile?['username'] ?? 'Anonymous',
        authorAvatarUrl: profile?['avatar_url'],
        createdAt: DateTime.parse(response['created_at']),
        likeCount: response['like_count'] ?? 0,
        commentCount: response['comment_count'] ?? 0,
        shareCount: response['share_count'] ?? 0,
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
          .eq('author_id', user.id);

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
            title,
            content,
            image_url,
            created_at,
            author_id,
            profiles!posts_author_id_fkey(username, avatar_url),
            like_count,
            comment_count,
            share_count
          ''')
          .or('title.ilike.%$query%,content.ilike.%$query%')
          .order('created_at', ascending: false);

      final List<PostModel> posts = [];
      for (final item in response) {
        final profile = item['profiles'];
        posts.add(PostModel(
          id: item['id'],
          title: item['title'] ?? '',
          content: item['content'] ?? '',
          imageUrl: item['image_url'],
          authorId: item['author_id'],
          authorName: profile?['username'] ?? 'Anonymous',
          authorAvatarUrl: profile?['avatar_url'],
          createdAt: DateTime.parse(item['created_at']),
          likeCount: item['like_count'] ?? 0,
          commentCount: item['comment_count'] ?? 0,
          shareCount: item['share_count'] ?? 0,
        ));
      }

      return posts;
    } catch (e) {
      print('Error searching posts: $e');
      return [];
    }
  }
}