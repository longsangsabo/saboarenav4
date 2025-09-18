import 'package:supabase_flutter/supabase_flutter.dart';
import 'referral_service.dart';

class QRScanService {
  static final SupabaseClient _supabase = Supabase.instance.client;
  
  /// Scan QR code and return user data or referral code info
  static Future<Map<String, dynamic>?> scanQRCode(String qrData) async {
    try {
      print('🔍 Scanning QR data: $qrData');
      
      // NEW: Check if it's a referral code first
      if (ReferralService.isReferralCode(qrData)) {
        print('🎁 Detected referral code: $qrData');
        final referralInfo = await ReferralService.getReferralCodeInfo(qrData);
        
        if (referralInfo != null) {
          return {
            'type': 'referral_code',
            'code': qrData,
            'referral_info': referralInfo,
            'action': 'show_referral_signup'
          };
        } else {
          print('❌ Invalid or expired referral code');
          return null;
        }
      }
      
      // Try to parse as JSON first (for our QR format)
      Map<String, dynamic>? userData;
      
      try {
        // Try parsing as JSON (direct user data)
        final parsed = Map<String, dynamic>.from(
          Uri.decodeFull(qrData).split('&').fold<Map<String, dynamic>>(
            {}, 
            (map, param) {
              final parts = param.split('=');
              if (parts.length == 2) {
                map[parts[0]] = parts[1];
              }
              return map;
            }
          )
        );
        
        if (parsed.containsKey('id') && parsed.containsKey('fullName')) {
          userData = parsed;
        }
      } catch (e) {
        print('Not a direct user data QR');
      }
      
      // If direct JSON parsing failed, try extracting user_code
      if (userData == null) {
        String? userCode;
        
        // Check if it's a saboarena.com URL format
        if (qrData.contains('saboarena.com')) {
          try {
            final uri = Uri.parse(qrData);
            
            // Handle different URL formats:
            // https://saboarena.com/user/SABO123456
            // https://saboarena.com/profile/SABO123456  
            // https://saboarena.com/?user_code=SABO123456
            
            if (uri.pathSegments.isNotEmpty) {
              // Extract from path: /user/SABO123456 or /profile/SABO123456
              if (uri.pathSegments.length >= 2 && 
                  (uri.pathSegments[0] == 'user' || uri.pathSegments[0] == 'profile')) {
                userCode = uri.pathSegments[1];
              }
            }
            
            // Check query parameters: ?user_code=SABO123456
            if (userCode == null && uri.queryParameters.containsKey('user_code')) {
              userCode = uri.queryParameters['user_code'];
            }
            
            // Check query parameters: ?code=SABO123456
            if (userCode == null && uri.queryParameters.containsKey('code')) {
              userCode = uri.queryParameters['code'];
            }
            
          } catch (e) {
            print('⚠️ Error parsing saboarena.com URL: $e');
          }
        }
        // Check if it's a direct SABO user code format (SABO123456)
        else if (qrData.startsWith('SABO') && qrData.length >= 8) {
          userCode = qrData;
        }
        // Check if it's just an ID
        else if (qrData.length < 50 && !qrData.contains('http')) {
          userCode = qrData;
        }
        
        if (userCode != null) {
          userData = await _findUserByCode(userCode);
        }
      }
      
      // If still no user data, try finding by ID
      if (userData == null && qrData.length > 10 && qrData.length < 50) {
        userData = await _findUserById(qrData);
      }
      
      if (userData != null) {
        print('✅ QR scan successful: ${userData['fullName']}');
        return userData;
      } else {
        print('❌ No user found for QR data: $qrData');
        return null;
      }
      
    } catch (e) {
      print('❌ Error scanning QR code: $e');
      return null;
    }
  }
  
  /// Find user by username (QR code stored as username)
  static Future<Map<String, dynamic>?> _findUserByCode(String userCode) async {
    try {
      print('🔍 Looking up username: $userCode');
      
      // First try username lookup (primary method)
      var response = await _supabase
          .from('users')
          .select('''
            id,
            email,
            full_name,
            username,
            bio,
            avatar_url,
            phone,
            role,
            skill_level,
            rank,
            total_wins,
            total_losses,
            total_tournaments,
            elo_rating,
            spa_points,
            total_prize_pool,
            is_verified,
            is_active,
            location,
            created_at,
            updated_at
          ''')
          .eq('username', userCode)
          .maybeSingle();
      
      // If not found by username, try bio field
      if (response == null) {
        print('🔍 Trying bio field: $userCode');
        response = await _supabase
            .from('users')
            .select('''
              id,
              email,
              full_name,
              username,
              bio,
              avatar_url,
              phone,
              role,
              skill_level,
              rank,
              total_wins,
              total_losses,
              total_tournaments,
              elo_rating,
              spa_points,
              total_prize_pool,
              is_verified,
              is_active,
              location,
              created_at,
              updated_at
            ''')
            .eq('bio', userCode)
            .maybeSingle();
      }
      
      if (response != null) {
        // Convert to our expected format
        return {
          'id': response['id'],
          'fullName': response['full_name'],
          'email': response['email'] ?? '',
          'username': response['username'],
          'bio': response['bio'],
          'avatarUrl': response['avatar_url'],
          'phone': response['phone'],
          'skillLevel': response['skill_level'] ?? 'beginner',
          'rank': response['rank'],
          'eloRating': response['elo_rating'] ?? 1200,
          'spaPoints': response['spa_points'] ?? 0,
          'totalWins': response['total_wins'] ?? 0,
          'totalLosses': response['total_losses'] ?? 0,
          'totalTournaments': response['total_tournaments'] ?? 0,
          'totalPrizePool': response['total_prize_pool']?.toDouble() ?? 0.0,
          'isVerified': response['is_verified'] ?? false,
          'isActive': response['is_active'] ?? true,
          'location': response['location'],
          'userCode': response['user_code'],
          'role': response['role'] ?? 'player',
        };
      }
      
      return null;
    } catch (e) {
      print('❌ Error finding user by code: $e');
      return null;
    }
  }
  
  /// Find user by ID (fallback)
  static Future<Map<String, dynamic>?> _findUserById(String userId) async {
    try {
      print('🔍 Looking up user ID: $userId');
      
      final response = await _supabase
          .from('users')
          .select('''
            id,
            email,
            full_name,
            username,
            bio,
            avatar_url,
            phone,
            role,
            skill_level,
            rank,
            total_wins,
            total_losses,
            total_tournaments,
            elo_rating,
            spa_points,
            total_prize_pool,
            is_verified,
            is_active,
            location,
            user_code,
            created_at,
            updated_at
          ''')
          .eq('id', userId)
          .maybeSingle();
      
      if (response != null) {
        return {
          'id': response['id'],
          'fullName': response['full_name'],
          'email': response['email'] ?? '',
          'username': response['username'],
          'bio': response['bio'],
          'avatarUrl': response['avatar_url'],
          'phone': response['phone'],
          'skillLevel': response['skill_level'] ?? 'beginner',
          'rank': response['rank'],
          'eloRating': response['elo_rating'] ?? 1200,
          'spaPoints': response['spa_points'] ?? 0,
          'totalWins': response['total_wins'] ?? 0,
          'totalLosses': response['total_losses'] ?? 0,
          'totalTournaments': response['total_tournaments'] ?? 0,
          'totalPrizePool': response['total_prize_pool']?.toDouble() ?? 0.0,
          'isVerified': response['is_verified'] ?? false,
          'isActive': response['is_active'] ?? true,
          'location': response['location'],
          'userCode': response['user_code'],
          'role': response['role'] ?? 'player',
        };
      }
      
      return null;
    } catch (e) {
      print('❌ Error finding user by ID: $e');
      return null;
    }
  }
  
  /// Generate QR data for current user (for sharing)
  static Future<String?> generateQRDataForUser(String userId) async {
    try {
      final user = await _findUserById(userId);
      if (user != null) {
        // Generate QR data with user_code if available, otherwise use ID
        final userCode = user['userCode'] ?? userId;
        return userCode;
      }
      return null;
    } catch (e) {
      print('❌ Error generating QR data: $e');
      return null;
    }
  }
  
  /// Update user's QR code in database
  static Future<bool> updateUserQRCode(String userId, String qrData) async {
    try {
      await _supabase
          .from('users')
          .update({
            'qr_data': qrData,
            'qr_generated_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);
      
      return true;
    } catch (e) {
      print('❌ Error updating user QR code: $e');
      return false;
    }
  }
}