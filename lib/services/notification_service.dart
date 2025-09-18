import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  static NotificationService? _instance;
  static NotificationService get instance => _instance ??= NotificationService._();
  NotificationService._();

  final SupabaseClient _supabase = Supabase.instance.client;

  /// Send notification to club admin when user registers for tournament
  Future<void> sendRegistrationNotification({
    required String tournamentId,
    required String userId,
    required String paymentMethod,
  }) async {
    try {
      // Get tournament details
      final tournamentResponse = await _supabase
          .from('tournaments')
          .select('title, club_id, clubs!inner(name)')
          .eq('id', tournamentId)
          .single();

      // Get user details
      final userResponse = await _supabase
          .from('users')
          .select('display_name, email')
          .eq('id', userId)
          .single();

      // Get club admin
      final clubAdminResponse = await _supabase
          .from('club_members')
          .select('user_id, users!inner(display_name)')
          .eq('club_id', tournamentResponse['club_id'])
          .eq('role', 'admin')
          .limit(1)
          .maybeSingle();

      if (clubAdminResponse == null) {
        print('⚠️ No club admin found for tournament registration notification');
        return;
      }

      // Create notification message
      final message = '''
🎱 Đăng ký giải đấu mới!

Giải đấu: ${tournamentResponse['title']}
Người đăng ký: ${userResponse['display_name']}
Phương thức thanh toán: ${paymentMethod == '0' ? 'Đóng tại quán' : 'Chuyển khoản QR'}
Email: ${userResponse['email'] ?? 'Chưa cập nhật'}

Vui lòng xác nhận thanh toán khi thành viên đến thi đấu.
      ''';

      // Insert notification to database
      await _supabase.from('notifications').insert({
        'user_id': clubAdminResponse['user_id'],
        'title': 'Đăng ký giải đấu mới',
        'message': message,
        'type': 'tournament_registration',
        'data': {'tournament_id': tournamentId, 'user_id': userId},
        'created_at': DateTime.now().toIso8601String(),
        'is_read': false,
      });

      print('✅ Registration notification sent successfully');
    } catch (error) {
      print('❌ Failed to send registration notification: $error');
    }
  }

  /// Get notifications for current user
  Future<List<Map<String, dynamic>>> getNotifications({
    bool? isRead,
    int limit = 20,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      var query = _supabase
          .from('notifications')
          .select('*')
          .eq('user_id', user.id);

      if (isRead != null) {
        query = query.eq('is_read', isRead);
      }

      return await query
          .order('created_at', ascending: false)
          .limit(limit);
    } catch (error) {
      throw Exception('Failed to get notifications: $error');
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);
    } catch (error) {
      throw Exception('Failed to mark notification as read: $error');
    }
  }

  /// Send a general notification to a user
  Future<void> sendNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _supabase.from('notifications').insert({
        'user_id': userId,
        'title': title,
        'message': message,
        'type': type,
        'data': data,
        'created_at': DateTime.now().toIso8601String(),
        'is_read': false,
      });

      print('✅ Notification sent successfully to user: $userId');
    } catch (error) {
      print('❌ Failed to send notification: $error');
      throw Exception('Failed to send notification: $error');
    }
  }
}