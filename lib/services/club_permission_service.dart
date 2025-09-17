import 'package:supabase_flutter/supabase_flutter.dart';

enum ClubRole {
  owner,
  admin,
  member,
  none, // Not a member
}

enum ClubPermission {
  // Tournament permissions
  createTournament,
  editTournament,
  deleteTournament,
  manageTournamentParticipants,
  
  // Member permissions
  inviteMembers,
  removeMembers,
  manageMembers,
  viewMemberProfiles,
  
  // Club management permissions
  editClubInfo,
  deleteClub,
  manageClubSettings,
  viewClubReports,
  manageClubFinances,
  
  // Content permissions
  createPosts,
  moderatePosts,
  deleteAnyPost,
  pinPosts,
  
  // Admin permissions
  promoteToAdmin,
  demoteFromAdmin,
  transferOwnership,
  
  // Activity permissions
  viewActivityHistory,
  moderateComments,
}

class ClubPermissionService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Cache for user's club roles
  final Map<String, ClubRole> _roleCache = {};

  /// Get user's role in a specific club
  Future<ClubRole> getUserRoleInClub(String clubId, {String? userId}) async {
    try {
      userId ??= _supabase.auth.currentUser?.id;
      if (userId == null) return ClubRole.none;

      // Check cache first
      final cacheKey = '${clubId}_$userId';
      if (_roleCache.containsKey(cacheKey)) {
        return _roleCache[cacheKey]!;
      }

      // Query database for user's role in this club
      final response = await _supabase
          .from('club_members')
          .select('role, status')
          .eq('club_id', clubId)
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) {
        _roleCache[cacheKey] = ClubRole.none;
        return ClubRole.none;
      }

      // Check if membership is active
      if (response['status'] != 'active') {
        _roleCache[cacheKey] = ClubRole.none;
        return ClubRole.none;
      }

      // Parse role
      ClubRole role;
      switch (response['role']?.toString().toLowerCase()) {
        case 'owner':
          role = ClubRole.owner;
          break;
        case 'admin':
          role = ClubRole.admin;
          break;
        case 'member':
          role = ClubRole.member;
          break;
        default:
          role = ClubRole.none;
      }

      // Cache the result
      _roleCache[cacheKey] = role;
      return role;
    } catch (e) {
      print('Error getting user role in club: $e');
      return ClubRole.none;
    }
  }

  /// Check if user has specific permission in a club
  Future<bool> hasPermission(
    String clubId,
    ClubPermission permission, {
    String? userId,
  }) async {
    final role = await getUserRoleInClub(clubId, userId: userId);
    return _roleHasPermission(role, permission);
  }

  /// Check if role has specific permission
  bool _roleHasPermission(ClubRole role, ClubPermission permission) {
    switch (role) {
      case ClubRole.owner:
        return true; // Owner has all permissions

      case ClubRole.admin:
        return _adminPermissions.contains(permission);

      case ClubRole.member:
        return _memberPermissions.contains(permission);

      case ClubRole.none:
        return false;
    }
  }

  /// Permissions for admin role
  static const Set<ClubPermission> _adminPermissions = {
    // Tournament permissions
    ClubPermission.createTournament,
    ClubPermission.editTournament,
    ClubPermission.deleteTournament,
    ClubPermission.manageTournamentParticipants,
    
    // Member permissions
    ClubPermission.inviteMembers,
    ClubPermission.removeMembers,
    ClubPermission.manageMembers,
    ClubPermission.viewMemberProfiles,
    
    // Club management permissions (limited)
    ClubPermission.editClubInfo,
    ClubPermission.manageClubSettings,
    ClubPermission.viewClubReports,
    
    // Content permissions
    ClubPermission.createPosts,
    ClubPermission.moderatePosts,
    ClubPermission.deleteAnyPost,
    ClubPermission.pinPosts,
    
    // Activity permissions
    ClubPermission.viewActivityHistory,
    ClubPermission.moderateComments,
  };

  /// Permissions for member role
  static const Set<ClubPermission> _memberPermissions = {
    // Basic tournament permissions
    ClubPermission.createTournament, // Members can create tournaments
    
    // Basic member permissions
    ClubPermission.viewMemberProfiles,
    
    // Basic content permissions
    ClubPermission.createPosts,
  };

  /// Check if user can manage tournaments in club
  Future<bool> canManageTournaments(String clubId, {String? userId}) async {
    return await hasPermission(
      clubId,
      ClubPermission.createTournament,
      userId: userId,
    );
  }

  /// Check if user is club admin or owner
  Future<bool> isClubAdmin(String clubId, {String? userId}) async {
    final role = await getUserRoleInClub(clubId, userId: userId);
    return role == ClubRole.admin || role == ClubRole.owner;
  }

  /// Check if user is club owner
  Future<bool> isClubOwner(String clubId, {String? userId}) async {
    final role = await getUserRoleInClub(clubId, userId: userId);
    return role == ClubRole.owner;
  }

  /// Promote user to admin (only owner can do this)
  Future<bool> promoteToAdmin(String clubId, String targetUserId) async {
    if (!await isClubOwner(clubId)) {
      return false;
    }

    try {
      await _supabase
          .from('club_members')
          .update({'role': 'admin'})
          .eq('club_id', clubId)
          .eq('user_id', targetUserId);

      // Clear cache for the promoted user
      _roleCache.remove('${clubId}_$targetUserId');
      return true;
    } catch (e) {
      print('Error promoting user to admin: $e');
      return false;
    }
  }

  /// Demote admin to member (only owner can do this)
  Future<bool> demoteFromAdmin(String clubId, String targetUserId) async {
    if (!await isClubOwner(clubId)) {
      return false;
    }

    try {
      await _supabase
          .from('club_members')
          .update({'role': 'member'})
          .eq('club_id', clubId)
          .eq('user_id', targetUserId);

      // Clear cache for the demoted user
      _roleCache.remove('${clubId}_$targetUserId');
      return true;
    } catch (e) {
      print('Error demoting admin: $e');
      return false;
    }
  }

  /// Remove member from club (admin or owner can do this)
  Future<bool> removeMember(String clubId, String targetUserId) async {
    if (!await hasPermission(clubId, ClubPermission.removeMembers)) {
      return false;
    }

    try {
      await _supabase
          .from('club_members')
          .update({'status': 'removed'})
          .eq('club_id', clubId)
          .eq('user_id', targetUserId);

      // Clear cache for the removed user
      _roleCache.remove('${clubId}_$targetUserId');
      return true;
    } catch (e) {
      print('Error removing member: $e');
      return false;
    }
  }

  /// Get all members with their roles for a club
  Future<List<Map<String, dynamic>>> getClubMembersWithRoles(String clubId) async {
    try {
      final response = await _supabase
          .from('club_members')
          .select('''
            user_id,
            role,
            status,
            joined_at,
            profiles:user_id (
              id,
              username,
              full_name,
              avatar_url
            )
          ''')
          .eq('club_id', clubId)
          .eq('status', 'active')
          .order('joined_at');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting club members with roles: $e');
      return [];
    }
  }

  /// Clear role cache (useful when user roles change)
  void clearRoleCache({String? clubId, String? userId}) {
    if (clubId != null && userId != null) {
      _roleCache.remove('${clubId}_$userId');
    } else if (clubId != null) {
      _roleCache.removeWhere((key, value) => key.startsWith('${clubId}_'));
    } else {
      _roleCache.clear();
    }
  }

  /// Get role display name
  String getRoleDisplayName(ClubRole role) {
    switch (role) {
      case ClubRole.owner:
        return 'Owner';
      case ClubRole.admin:
        return 'Admin';
      case ClubRole.member:
        return 'Member';
      case ClubRole.none:
        return 'Not a member';
    }
  }

  /// Get role color for UI
  String getRoleColor(ClubRole role) {
    switch (role) {
      case ClubRole.owner:
        return '#FFD700'; // Gold
      case ClubRole.admin:
        return '#FF6B6B'; // Red
      case ClubRole.member:
        return '#4ECDC4'; // Teal
      case ClubRole.none:
        return '#95A5A6'; // Gray
    }
  }
}