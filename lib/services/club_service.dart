import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/club.dart';
import '../models/user_profile.dart';

class ClubService {
  static ClubService? _instance;
  static ClubService get instance => _instance ??= ClubService._();
  ClubService._();

  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Club>> getClubs({
    double? latitude,
    double? longitude,
    double? radiusKm,
    int limit = 50,
  }) async {
    try {
      var query = _supabase.from('clubs').select();

      // Add location-based filtering if coordinates provided
      if (latitude != null && longitude != null && radiusKm != null) {
        // Note: This is a simplified distance check
        // In production, you'd want to use PostGIS functions for accurate distance calculation
        query = query
            .gte('latitude', latitude - (radiusKm / 111.0))
            .lte('latitude', latitude + (radiusKm / 111.0))
            .gte('longitude', longitude - (radiusKm / 111.0))
            .lte('longitude', longitude + (radiusKm / 111.0));
      }

      final response = await query
          .eq('is_active', true)
          .eq('approval_status', 'approved')
          .order('rating', ascending: false)
          .limit(limit);

      return response.map<Club>((json) => Club.fromJson(json)).toList();
    } catch (error) {
      throw Exception('Failed to get clubs: $error');
    }
  }

  Future<Club> getClubById(String clubId) async {
    try {
      final response =
          await _supabase.from('clubs').select().eq('id', clubId).single();

      return Club.fromJson(response);
    } catch (error) {
      throw Exception('Failed to get club: $error');
    }
  }

  Future<List<Club>> getAllClubs({int limit = 100}) async {
    try {
      final response = await _supabase
          .from('clubs')
          .select()
          .eq('is_active', true)
          .eq('approval_status', 'approved')
          .order('name', ascending: true)
          .limit(limit);

      return response.map<Club>((json) => Club.fromJson(json)).toList();
    } catch (error) {
      throw Exception('Failed to get all clubs: $error');
    }
  }

  Future<List<UserProfile>> getClubMembers(String clubId) async {
    try {
      final response = await _supabase.from('club_members').select('''
            club_id,
            user_id,
            joined_at,
            is_favorite,
            users!inner (
              id,
              email,
              full_name,
              username,
              bio,
              avatar_url,
              phone,
              role,
              skill_level,
              ranking_points,
              is_verified,
              is_active,
              display_name,
              rank,
              elo_rating,
              spa_points
            )
          ''').eq('club_id', clubId).order('joined_at');

      return response
          .map<UserProfile>((json) => UserProfile.fromJson(json['users']))
          .toList();
    } catch (error) {
      throw Exception('Failed to get club members: $error');
    }
  }

  Future<bool> joinClub(String clubId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _supabase.from('club_members').insert({
        'club_id': clubId,
        'user_id': user.id,
      });

      return true;
    } catch (error) {
      throw Exception('Failed to join club: $error');
    }
  }

  Future<bool> leaveClub(String clubId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _supabase
          .from('club_members')
          .delete()
          .eq('club_id', clubId)
          .eq('user_id', user.id);

      return true;
    } catch (error) {
      throw Exception('Failed to leave club: $error');
    }
  }

  Future<bool> isClubMember(String clubId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      final response = await _supabase
          .from('club_members')
          .select('id')
          .eq('club_id', clubId)
          .eq('user_id', user.id)
          .maybeSingle();

      return response != null;
    } catch (error) {
      throw Exception('Failed to check club membership: $error');
    }
  }

  Future<bool> toggleFavoriteClub(String clubId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Check if already a member
      final membership = await _supabase
          .from('club_members')
          .select()
          .eq('club_id', clubId)
          .eq('user_id', user.id)
          .maybeSingle();

      if (membership != null) {
        // Toggle favorite status
        await _supabase
            .from('club_members')
            .update({'is_favorite': !membership['is_favorite']}).eq(
                'id', membership['id']);
      } else {
        // Join club as favorite
        await _supabase.from('club_members').insert({
          'club_id': clubId,
          'user_id': user.id,
          'is_favorite': true,
        });
      }

      return true;
    } catch (error) {
      throw Exception('Failed to toggle favorite club: $error');
    }
  }

  Future<List<Club>> getUserFavoriteClubs() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _supabase
          .from('club_members')
          .select('''
            clubs (*)
          ''')
          .eq('user_id', user.id)
          .eq('is_favorite', true)
          .order('joined_at', ascending: false);

      return response
          .map<Club>((json) => Club.fromJson(json['clubs']))
          .toList();
    } catch (error) {
      throw Exception('Failed to get favorite clubs: $error');
    }
  }

  Future<List<Club>> searchClubs(String query) async {
    try {
      final response = await _supabase
          .from('clubs')
          .select()
          .or('name.ilike.%$query%,description.ilike.%$query%,address.ilike.%$query%')
          .eq('is_active', true)
          .order('rating', ascending: false)
          .limit(20);

      return response.map<Club>((json) => Club.fromJson(json)).toList();
    } catch (error) {
      throw Exception('Failed to search clubs: $error');
    }
  }

  Future<Club> createClub({
    required String name,
    required String description,
    required String address,
    String? phone,
    String? email,
    int totalTables = 1,
    double? pricePerHour,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final clubData = {
        'owner_id': user.id,
        'name': name,
        'description': description,
        'address': address,
        'phone': phone,
        'email': email,
        'total_tables': totalTables,
        'price_per_hour': pricePerHour,
        'latitude': latitude,
        'longitude': longitude,
        'approval_status': 'pending', // New clubs need admin approval
        'is_verified': false,
        'is_active': false, // Inactive until approved
      };

      final response =
          await _supabase.from('clubs').insert(clubData).select().single();

      return Club.fromJson(response);
    } catch (error) {
      throw Exception('Failed to create club: $error');
    }
  }

  /// Get clubs owned by current user
  Future<List<Club>> getMyClubs() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _supabase
          .from('clubs')
          .select('*')
          .eq('owner_id', user.id)
          .order('created_at', ascending: false);

      return response.map<Club>((json) => Club.fromJson(json)).toList();
    } catch (error) {
      throw Exception('Failed to get user clubs: $error');
    }
  }

  /// Check if current user is owner of a specific club
  Future<bool> isClubOwner(String clubId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      final response = await _supabase
          .from('clubs')
          .select('owner_id')
          .eq('id', clubId)
          .maybeSingle();

      return response != null && response['owner_id'] == user.id;
    } catch (error) {
      print('Error checking club ownership: $error');
      return false;
    }
  }

  /// Get current user's primary club (first approved club they own)
  Future<Club?> getCurrentUserClub() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      final response = await _supabase
          .from('clubs')
          .select('*')
          .eq('owner_id', user.id)
          .eq('approval_status', 'approved')
          .eq('is_active', true)
          .order('created_at', ascending: true)
          .limit(1)
          .maybeSingle();

      return response != null ? Club.fromJson(response) : null;
    } catch (error) {
      print('Error getting current user club: $error');
      return null;
    }
  }
}
