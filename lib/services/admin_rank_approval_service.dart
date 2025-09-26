import 'package:supabase_flutter/supabase_flutter.dart';

class AdminRankApprovalService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Direct rank request approval without using RPC function
  /// This bypasses the problematic club_review_rank_change_request function
  Future<Map<String, dynamic>> approveRankRequest({
    required String requestId,
    required bool approved,
    String? comments,
  }) async {
    try {
      // Step 1: Get the rank request details
      final rankRequestResponse = await _supabase
          .from('rank_requests')
          .select('*')
          .eq('id', requestId)
          .single();

      if (rankRequestResponse.isEmpty) {
        return {
          'success': false,
          'error': 'Request not found'
        };
      }

      final request = rankRequestResponse;
      final userId = request['user_id'];
      final currentUserId = _supabase.auth.currentUser?.id;

      // Step 2: Check authorization (club admin)
      if (currentUserId != null) {
        final clubMemberResponse = await _supabase
            .from('club_members')
            .select('role')
            .eq('user_id', currentUserId)
            .eq('club_id', request['club_id'])
            .eq('role', 'admin')
            .maybeSingle();

        if (clubMemberResponse == null) {
          return {
            'success': false,
            'error': 'Not authorized - user is not club admin'
          };
        }
      }

      // Step 3: Update the rank request status
      final statusToSet = approved ? 'approved' : 'rejected';
      final reviewedBy = currentUserId ?? userId; // Use current user or fallback to request user

      await _supabase
          .from('rank_requests')
          .update({
            'status': statusToSet,
            'reviewed_at': DateTime.now().toIso8601String(),
            'reviewed_by': reviewedBy,
            'rejection_reason': approved ? null : comments, // Use rejection_reason for rejected requests
          })
          .eq('id', requestId);

      // Step 4: If approved, update user rank
      if (approved) {
        // Extract rank from notes
        String newRank = 'K'; // default
        final notes = request['notes'] as String? ?? '';
        
        // Try to extract rank from notes
        final rankMatch = RegExp(r'Rank mong muốn: ([A-Z+]+)').firstMatch(notes);
        if (rankMatch != null) {
          newRank = rankMatch.group(1)!;
        }

        // Update user rank
        await _supabase
            .from('users')
            .update({
              'rank': newRank,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', userId);

        return {
          'success': true,
          'message': 'Request approved successfully',
          'user_id': userId,
          'new_rank': newRank,
        };
      } else {
        return {
          'success': true,
          'message': 'Request rejected successfully',
        };
      }

    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Get pending rank requests for the current club admin
  Future<List<Map<String, dynamic>>> getPendingRankRequests() async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Get user's club
      final clubMemberResponse = await _supabase
          .from('club_members')
          .select('club_id')
          .eq('user_id', currentUserId)
          .eq('role', 'admin')
          .maybeSingle();

      if (clubMemberResponse == null) {
        return []; // Not a club admin
      }

      final clubId = clubMemberResponse['club_id'];

      // Get pending requests for this club
      final response = await _supabase
          .from('rank_requests')
          .select('''
            id,
            user_id,
            club_id,
            status,
            notes,
            evidence_urls,
            requested_at,
            users!inner(
              display_name,
              rank
            ),
            clubs!inner(
              name
            )
          ''')
          .eq('club_id', clubId)
          .eq('status', 'pending')
          .order('requested_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);

    } catch (e) {
      throw Exception('Failed to load rank requests: $e');
    }
  }

  /// Get the current user's club information
  Future<Map<String, dynamic>?> getCurrentUserClub() async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == null) return null;

      final response = await _supabase
          .from('club_members')
          .select('''
            role,
            clubs!inner(
              id,
              name,
              description
            )
          ''')
          .eq('user_id', currentUserId)
          .eq('role', 'admin')
          .maybeSingle();

      return response;
    } catch (e) {
      return null;
    }
  }
}