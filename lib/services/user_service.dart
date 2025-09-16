import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import 'dart:typed_data';

class UserService {
  static UserService? _instance;
  static UserService get instance => _instance ??= UserService._();
  UserService._();

  final SupabaseClient _supabase = Supabase.instance.client;

  Future<UserProfile?> getCurrentUserProfile() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      final response =
          await _supabase.from('users').select().eq('id', user.id).single();

      return UserProfile.fromJson(response);
    } catch (error) {
      throw Exception('Failed to get current user profile: $error');
    }
  }

  Future<UserProfile> getUserProfileById(String userId) async {
    try {
      final response =
          await _supabase.from('users').select().eq('id', userId).single();

      return UserProfile.fromJson(response);
    } catch (error) {
      throw Exception('Failed to get user profile: $error');
    }
  }

  Future<List<UserProfile>> getTopRankedPlayers({int limit = 10}) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('is_active', true)
          .order('ranking_points', ascending: false)
          .limit(limit);

      return response
          .map<UserProfile>((json) => UserProfile.fromJson(json))
          .toList();
    } catch (error) {
      throw Exception('Failed to get top ranked players: $error');
    }
  }

  Future<List<UserProfile>> searchUsers(String query, {int limit = 20}) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .or('full_name.ilike.%$query%,username.ilike.%$query%')
          .eq('is_active', true)
          .order('ranking_points', ascending: false)
          .limit(limit);

      return response
          .map<UserProfile>((json) => UserProfile.fromJson(json))
          .toList();
    } catch (error) {
      throw Exception('Failed to search users: $error');
    }
  }

  Future<List<UserProfile>> getNearbyPlayers({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
    int limit = 20,
  }) async {
    try {
      // This is a simplified location search
      // In production, you'd want to use PostGIS functions for accurate distance calculation
      final response = await _supabase
          .from('users')
          .select()
          .not('location', 'is', null)
          .eq('is_active', true)
          .order('ranking_points', ascending: false)
          .limit(limit);

      return response
          .map<UserProfile>((json) => UserProfile.fromJson(json))
          .toList();
    } catch (error) {
      throw Exception('Failed to get nearby players: $error');
    }
  }

  Future<UserProfile> updateUserProfile({
    String? username,
    String? bio,
    String? phone,
    DateTime? dateOfBirth,
    String? skillLevel,
    String? location,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final updateData = <String, dynamic>{};
      if (username != null) updateData['username'] = username;
      if (bio != null) updateData['bio'] = bio;
      if (phone != null) updateData['phone'] = phone;
      if (dateOfBirth != null) {
        updateData['date_of_birth'] = dateOfBirth.toIso8601String();
      }
      if (skillLevel != null) updateData['skill_level'] = skillLevel;
      if (location != null) updateData['location'] = location;

      updateData['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from('users')
          .update(updateData)
          .eq('id', user.id)
          .select()
          .single();

      return UserProfile.fromJson(response);
    } catch (error) {
      throw Exception('Failed to update user profile: $error');
    }
  }

  Future<String?> uploadAvatar(List<int> imageBytes, String fileName) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final filePath =
          'avatars/${user.id}/${DateTime.now().millisecondsSinceEpoch}_$fileName';

      await _supabase.storage
          .from('user-content')
          .uploadBinary(filePath, Uint8List.fromList(imageBytes));

      final publicUrl =
          _supabase.storage.from('user-content').getPublicUrl(filePath);

      // Update user profile with new avatar URL
      await _supabase
          .from('users')
          .update({'avatar_url': publicUrl}).eq('id', user.id);

      return publicUrl;
    } catch (error) {
      throw Exception('Failed to upload avatar: $error');
    }
  }

  Future<Map<String, int>> getUserStats(String userId) async {
    try {
      final userProfile = await getUserProfileById(userId);

      // Get additional stats from matches
      final matchesAsPlayer1 = await _supabase
          .from('matches')
          .select()
          .eq('player1_id', userId)
          .eq('status', 'completed');

      final matchesAsPlayer2 = await _supabase
          .from('matches')
          .select()
          .eq('player2_id', userId)
          .eq('status', 'completed');

      final totalMatches = matchesAsPlayer1.length + matchesAsPlayer2.length;

      return {
        'total_wins': userProfile.totalWins,
        'total_losses': userProfile.totalLosses,
        'total_tournaments': userProfile.totalTournaments,
        'total_matches': totalMatches,
        'ranking_points': userProfile.rankingPoints,
      };
    } catch (error) {
      throw Exception('Failed to get user stats: $error');
    }
  }

  Future<int> getUserRanking(String userId) async {
    try {
      final response = await _supabase.rpc('get_user_ranking', params: {
        'user_id': userId,
      });

      return response ?? 0;
    } catch (error) {
      // Fallback: calculate ranking manually
      try {
        final allUsers = await _supabase
            .from('users')
            .select('id, ranking_points')
            .eq('is_active', true)
            .order('ranking_points', ascending: false);

        for (int i = 0; i < allUsers.length; i++) {
          if (allUsers[i]['id'] == userId) {
            return i + 1;
          }
        }
        return 0;
      } catch (fallbackError) {
        throw Exception('Failed to get user ranking: $fallbackError');
      }
    }
  }

  Future<List<UserProfile>> getUserFollowers(String userId,
      {int limit = 20}) async {
    try {
      final response = await _supabase.from('user_follows').select('''
            follower:users!user_follows_follower_id_fkey (*)
          ''').eq('following_id', userId).limit(limit);

      return response
          .map<UserProfile>((json) => UserProfile.fromJson(json['follower']))
          .toList();
    } catch (error) {
      throw Exception('Failed to get user followers: $error');
    }
  }

  Future<List<UserProfile>> getUserFollowing(String userId,
      {int limit = 20}) async {
    try {
      final response = await _supabase.from('user_follows').select('''
            following:users!user_follows_following_id_fkey (*)
          ''').eq('follower_id', userId).limit(limit);

      return response
          .map<UserProfile>((json) => UserProfile.fromJson(json['following']))
          .toList();
    } catch (error) {
      throw Exception('Failed to get user following: $error');
    }
  }

  Future<Map<String, int>> getUserFollowCounts(String userId) async {
    try {
      final followersCount = await _supabase
          .from('user_follows')
          .select('*')
          .eq('following_id', userId)
          .count(CountOption.exact);

      final followingCount = await _supabase
          .from('user_follows')
          .select('*')
          .eq('follower_id', userId)
          .count(CountOption.exact);

      return {
        'followers': followersCount.count,
        'following': followingCount.count,
      };
    } catch (error) {
      throw Exception('Failed to get user follow counts: $error');
    }
  }

  Future<bool> followUser(String targetUserId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      if (user.id == targetUserId) {
        throw Exception('Cannot follow yourself');
      }

      await _supabase.from('user_follows').insert({
        'follower_id': user.id,
        'following_id': targetUserId,
      });

      return true;
    } catch (error) {
      throw Exception('Failed to follow user: $error');
    }
  }

  Future<bool> unfollowUser(String targetUserId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _supabase
          .from('user_follows')
          .delete()
          .eq('follower_id', user.id)
          .eq('following_id', targetUserId);

      return true;
    } catch (error) {
      throw Exception('Failed to unfollow user: $error');
    }
  }

  Future<bool> isFollowingUser(String targetUserId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      final response = await _supabase
          .from('user_follows')
          .select('id')
          .eq('follower_id', user.id)
          .eq('following_id', targetUserId)
          .maybeSingle();

      return response != null;
    } catch (error) {
      throw Exception('Failed to check follow status: $error');
    }
  }

  Future<List<UserProfile>> findOpponentsNearby({
    required double latitude,
    required double longitude,
    required double radiusInKm,
  }) async {
    try {
      final response = await _supabase.rpc(
        'find_nearby_users',
        params: {
          'current_user_id': _supabase.auth.currentUser!.id,
          'user_lat': latitude,
          'user_lon': longitude,
          'radius_km': radiusInKm,
        },
      );

      if (response is List) {
        return response
            .map<UserProfile>((json) => UserProfile.fromJson(json))
            .toList();
      }
      return [];
    } catch (error) {
      // It's good practice to log the error for debugging
      print('Error finding nearby opponents: $error');
      throw Exception('Failed to find nearby opponents: $error');
    }
  }
}
