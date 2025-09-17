import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/club.dart';
import '../models/user_profile.dart';

class AdminService {
  static AdminService? _instance;
  static AdminService get instance => _instance ??= AdminService._();
  AdminService._();

  final SupabaseClient _supabase = Supabase.instance.client;

  // ==========================================
  // CLUB MANAGEMENT
  // ==========================================

  /// Get all clubs pending approval
  Future<List<Club>> getPendingClubs() async {
    try {
      final response = await _supabase
          .from('clubs')
          .select('''
            *,
            owner:users!clubs_owner_id_fkey (
              id,
              display_name,
              email,
              avatar_url
            )
          ''')
          .eq('approval_status', 'pending')
          .order('created_at', ascending: false);

      return response.map<Club>((json) => Club.fromJson(json)).toList();
    } catch (error) {
      throw Exception('Failed to get pending clubs: $error');
    }
  }

  /// Get all clubs (with filters)
  Future<List<Club>> getClubsForAdmin({
    String? status, // 'pending', 'approved', 'rejected'
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      var query = _supabase
          .from('clubs')
          .select('''
            *,
            owner:users!clubs_owner_id_fkey (
              id,
              display_name,
              email,
              avatar_url,
              phone
            )
          ''');

      if (status != null) {
        query = query.eq('approval_status', status);
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      // Ensure response is a List and handle type safety
      if (response is! List) {
        throw Exception('Unexpected response type: ${response.runtimeType}');
      }
      
      return (response as List).map<Club>((json) {
        if (json is! Map<String, dynamic>) {
          throw Exception('Invalid club data type: ${json.runtimeType}');
        }
        return Club.fromJson(json);
      }).toList();
    } catch (error, stackTrace) {
      print('AdminService.getClubsForAdmin error: $error');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to get clubs for admin: $error');
    }
  }

  /// Approve a club
  Future<Club> approveClub(String clubId, {String? adminNotes}) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('Admin not authenticated');

      // First, get the club to find the owner_id
      final clubData = await _supabase
          .from('clubs')
          .select('owner_id')
          .eq('id', clubId)
          .single();

      final ownerId = clubData['owner_id'];
      if (ownerId == null) {
        throw Exception('Club owner not found');
      }

      // Update club status and activate it
      final clubResponse = await _supabase
          .from('clubs')
          .update({
            'approval_status': 'approved',
            'is_active': true, // Auto-activate when approved
            'approved_at': DateTime.now().toIso8601String(),
            'approved_by': user.id,
            'rejection_reason': null, // Clear any previous rejection reason
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', clubId)
          .select()
          .single();

      // Update user role to club_owner
      await _supabase
          .from('users')
          .update({
            'role': 'club_owner',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', ownerId);

      // Log admin action
      await _logAdminAction(
        adminId: user.id,
        action: 'approve_club',
        targetId: clubId,
        details: {
          'admin_notes': adminNotes,
          'owner_id': ownerId,
          'auto_activated': true,
          'role_updated': 'club_owner',
        },
      );

      print('✅ Club approved successfully:');
      print('  - Club ID: $clubId');
      print('  - Owner ID: $ownerId');
      print('  - Auto-activated: true');
      print('  - Role updated to: club_owner');

      return Club.fromJson(clubResponse);
    } catch (error) {
      print('❌ Failed to approve club: $error');
      throw Exception('Failed to approve club: $error');
    }
  }

  /// Reject a club
  Future<Club> rejectClub(String clubId, String reason, {String? adminNotes}) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('Admin not authenticated');

      final response = await _supabase
          .from('clubs')
          .update({
            'approval_status': 'rejected',
            'rejection_reason': reason,
            'approved_at': null,
            'approved_by': null,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', clubId)
          .select()
          .single();

      // Log admin action
      await _logAdminAction(
        adminId: user.id,
        action: 'reject_club',
        targetId: clubId,
        details: {
          'rejection_reason': reason,
          'admin_notes': adminNotes,
        },
      );

      return Club.fromJson(response);
    } catch (error) {
      throw Exception('Failed to reject club: $error');
    }
  }

  // ==========================================
  // ADMIN DASHBOARD STATS
  // ==========================================

  /// Get admin dashboard statistics
  Future<Map<String, dynamic>> getAdminStats() async {
    try {
      final results = await Future.wait([
        // Clubs stats
        _supabase.from('clubs').select('count').eq('approval_status', 'pending').count(),
        _supabase.from('clubs').select('count').eq('approval_status', 'approved').count(),
        _supabase.from('clubs').select('count').eq('approval_status', 'rejected').count(),
        
        // Users stats
        _supabase.from('users').select('count').count(),
        
        // Tournaments stats
        _supabase.from('tournaments').select('count').count(),
        
        // Matches stats
        _supabase.from('matches').select('count').eq('status', 'completed').count(),
      ]);

      return {
        'clubs': {
          'pending': results[0].count,
          'approved': results[1].count,
          'rejected': results[2].count,
          'total': results[0].count + results[1].count + results[2].count,
        },
        'users': {
          'total': results[3].count,
        },
        'tournaments': {
          'total': results[4].count,
        },
        'matches': {
          'completed': results[5].count,
        },
      };
    } catch (error) {
      throw Exception('Failed to get admin stats: $error');
    }
  }

  /// Get recent activities for admin dashboard
  Future<List<Map<String, dynamic>>> getRecentActivities({int limit = 20}) async {
    try {
      // Get recent club registrations
      final clubActivities = await _supabase
          .from('clubs')
          .select('''
            id,
            name,
            approval_status,
            created_at,
            owner:users!clubs_owner_id_fkey (display_name)
          ''')
          .order('created_at', ascending: false)
          .limit(limit);

      // Convert to activity format
      List<Map<String, dynamic>> activities = [];
      
      for (final club in clubActivities) {
        activities.add({
          'id': club['id'],
          'type': 'club_registration',
          'title': 'Đăng ký CLB mới',
          'description': '${club['owner']['display_name']} đăng ký CLB "${club['name']}"',
          'status': club['approval_status'],
          'timestamp': DateTime.parse(club['created_at']),
          'target_id': club['id'],
        });
      }

      // Sort by timestamp descending
      activities.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
      
      return activities.take(limit).toList();
    } catch (error) {
      throw Exception('Failed to get recent activities: $error');
    }
  }

  // ==========================================
  // USER MANAGEMENT (FUTURE)
  // ==========================================

  /// Get users for admin management
  Future<List<UserProfile>> getUsersForAdmin({
    String? search,
    String? role,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      var query = _supabase.from('users').select();

      if (search != null && search.isNotEmpty) {
        query = query.or('display_name.ilike.%$search%,email.ilike.%$search%');
      }

      if (role != null) {
        query = query.eq('role', role);
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return response.map<UserProfile>((json) => UserProfile.fromJson(json)).toList();
    } catch (error) {
      throw Exception('Failed to get users for admin: $error');
    }
  }

  // ==========================================
  // ADMIN UTILITIES
  // ==========================================

  /// Check if current user is admin
  Future<bool> isCurrentUserAdmin() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      final response = await _supabase
          .from('users')
          .select('role')
          .eq('id', user.id)
          .single();

      return response['role'] == 'admin';
    } catch (error) {
      return false;
    }
  }

  /// Log admin actions for audit trail
  Future<void> _logAdminAction({
    required String adminId,
    required String action,
    required String targetId,
    Map<String, dynamic>? details,
  }) async {
    try {
      await _supabase.from('admin_logs').insert({
        'admin_id': adminId,
        'action': action,
        'target_id': targetId,
        'details': details,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (error) {
      // Log error but don't throw - logging failure shouldn't break main action
      print('Failed to log admin action: $error');
    }
  }
}