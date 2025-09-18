import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math';

/// Referral System Service for SABO Arena
/// Handles referral code generation, validation, and reward distribution
class ReferralService {
  static final _supabase = Supabase.instance.client;
  
  /// Generate a unique referral code for a user
  static Future<String?> generateReferralCode(
    String userId, {
    String codeType = 'general',
    int? maxUses,
    DateTime? expiresAt,
    Map<String, dynamic>? customRewards,
  }) async {
    try {
      // Get user info for code generation
      final userResponse = await _supabase
          .from('users')
          .select('username, full_name')
          .eq('id', userId)
          .single();
      
      if (userResponse == null) {
        print('❌ User not found for referral code generation');
        return null;
      }
      
      // Generate unique code
      String baseCode = _generateCodeFromUser(userResponse, codeType);
      String finalCode = await _ensureUniqueCode(baseCode);
      
      // Default rewards based on type
      Map<String, dynamic> rewards = customRewards ?? _getDefaultRewards(codeType);
      
      // Insert referral code
      final response = await _supabase
          .from('referral_codes')
          .insert({
            'user_id': userId,
            'code': finalCode,
            'code_type': codeType,
            'max_uses': maxUses,
            'rewards': rewards,
            'expires_at': expiresAt?.toIso8601String(),
          })
          .select()
          .single();
      
      if (response != null) {
        print('✅ Referral code generated: $finalCode');
        await _updateUserReferralStats(userId, 'codes_created', 1);
        return finalCode;
      }
      
      return null;
    } catch (e) {
      print('💥 Error generating referral code: $e');
      return null;
    }
  }
  
  /// Validate and apply referral code for new user
  static Future<Map<String, dynamic>?> applyReferralCode(
    String code, 
    String newUserId
  ) async {
    try {
      print('🔍 Validating referral code: $code');
      
      // Get referral code info
      final codeResponse = await _supabase
          .from('referral_codes')
          .select('''
            id,
            user_id,
            code,
            code_type,
            max_uses,
            current_uses,
            rewards,
            expires_at,
            is_active
          ''')
          .eq('code', code)
          .eq('is_active', true)
          .single();
      
      if (codeResponse == null) {
        print('❌ Referral code not found or inactive');
        return {'success': false, 'error': 'Invalid referral code'};
      }
      
      // Validate expiration
      if (codeResponse['expires_at'] != null) {
        final expiresAt = DateTime.parse(codeResponse['expires_at']);
        if (DateTime.now().isAfter(expiresAt)) {
          print('❌ Referral code expired');
          return {'success': false, 'error': 'Referral code has expired'};
        }
      }
      
      // Validate usage limit
      if (codeResponse['max_uses'] != null) {
        if (codeResponse['current_uses'] >= codeResponse['max_uses']) {
          print('❌ Referral code usage limit reached');
          return {'success': false, 'error': 'Referral code usage limit reached'};
        }
      }
      
      // Check if user was already referred
      final userCheck = await _supabase
          .from('users')
          .select('referred_by')
          .eq('id', newUserId)
          .single();
      
      if (userCheck?['referred_by'] != null) {
        print('❌ User already referred by someone else');
        return {'success': false, 'error': 'User already has a referrer'};
      }
      
      // Apply referral bonuses
      final referrerId = codeResponse['user_id'];
      final rewards = codeResponse['rewards'] as Map<String, dynamic>;
      
      await _applyReferralBonuses(referrerId, newUserId, rewards);
      
      // Update referral code usage
      await _supabase
          .from('referral_codes')
          .update({'current_uses': codeResponse['current_uses'] + 1})
          .eq('id', codeResponse['id']);
      
      // Update new user's referred_by field
      await _supabase
          .from('users')
          .update({'referred_by': referrerId})
          .eq('id', newUserId);
      
      // Record usage
      await _supabase
          .from('referral_usage')
          .insert({
            'referral_code_id': codeResponse['id'],
            'referrer_id': referrerId,
            'referred_user_id': newUserId,
            'bonus_awarded': rewards,
            'status': 'completed'
          });
      
      print('✅ Referral code applied successfully');
      return {
        'success': true,
        'referrer_id': referrerId,
        'rewards': rewards,
        'code_type': codeResponse['code_type']
      };
      
    } catch (e) {
      print('💥 Error applying referral code: $e');
      return {'success': false, 'error': 'Failed to apply referral code'};
    }
  }
  
  /// Get user's referral statistics and codes
  static Future<Map<String, dynamic>?> getUserReferralStats(String userId) async {
    try {
      // Get user's referral codes
      final codesResponse = await _supabase
          .from('referral_codes')
          .select('code, code_type, current_uses, max_uses, is_active, created_at')
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      // Get referral usage history (as referrer)
      final usageResponse = await _supabase
          .from('referral_usage')
          .select('''
            bonus_awarded,
            used_at,
            referred_user_id,
            users!referral_usage_referred_user_id_fkey(full_name, username)
          ''')
          .eq('referrer_id', userId)
          .order('used_at', ascending: false);
      
      // Get user's referral stats
      final userResponse = await _supabase
          .from('users')
          .select('referral_stats, referred_by')
          .eq('id', userId)
          .single();
      
      return {
        'user_codes': codesResponse ?? [],
        'referral_history': usageResponse ?? [],
        'stats': userResponse?['referral_stats'] ?? {},
        'referred_by': userResponse?['referred_by'],
      };
      
    } catch (e) {
      print('💥 Error getting referral stats: $e');
      return null;
    }
  }
  
  /// Check if a string is a valid referral code format
  static bool isReferralCode(String code) {
    // Format: SABO-[USERNAME]-[TYPE] or SABO-[NAME]-[NUMBER]
    final referralPattern = RegExp(r'^SABO-[A-Z0-9]+-[A-Z0-9]+$');
    return referralPattern.hasMatch(code.toUpperCase());
  }
  
  /// Get referral code info for QR scanner
  static Future<Map<String, dynamic>?> getReferralCodeInfo(String code) async {
    try {
      final response = await _supabase
          .from('referral_codes')
          .select('''
            code,
            code_type,
            rewards,
            expires_at,
            is_active,
            users!referral_codes_user_id_fkey(full_name, username, avatar_url)
          ''')
          .eq('code', code)
          .eq('is_active', true)
          .single();
      
      if (response == null) return null;
      
      // Check expiration
      if (response['expires_at'] != null) {
        final expiresAt = DateTime.parse(response['expires_at']);
        if (DateTime.now().isAfter(expiresAt)) {
          return null; // Expired
        }
      }
      
      return {
        'code': response['code'],
        'type': response['code_type'],
        'rewards': response['rewards'],
        'referrer': response['users'],
        'is_valid': true,
      };
      
    } catch (e) {
      print('💥 Error getting referral code info: $e');
      return null;
    }
  }
  
  // Private helper methods
  
  static String _generateCodeFromUser(Map<String, dynamic> user, String codeType) {
    String username = user['username']?.toString().toUpperCase() ?? '';
    String fullName = user['full_name']?.toString().toUpperCase() ?? '';
    
    // Extract meaningful part from username or name
    String baseName = '';
    if (username.isNotEmpty && username != 'NULL') {
      baseName = username.replaceAll(RegExp(r'[^A-Z0-9]'), '').substring(0, min(8, username.length));
    } else if (fullName.isNotEmpty) {
      // Use first name from full name
      baseName = fullName.split(' ')[0].replaceAll(RegExp(r'[^A-Z0-9]'), '').substring(0, min(8, fullName.length));
    } else {
      baseName = 'USER${Random().nextInt(9999).toString().padLeft(4, '0')}';
    }
    
    String typeCode = codeType.toUpperCase().substring(0, min(3, codeType.length));
    return 'SABO-$baseName-$typeCode';
  }
  
  static Future<String> _ensureUniqueCode(String baseCode) async {
    String finalCode = baseCode;
    int counter = 1;
    
    while (true) {
      final existing = await _supabase
          .from('referral_codes')
          .select('id')
          .eq('code', finalCode)
          .maybeSingle();
      
      if (existing == null) break;
      
      // Add number suffix to make unique
      finalCode = '$baseCode${counter.toString().padLeft(2, '0')}';
      counter++;
      
      if (counter > 99) {
        // Fallback with random number
        finalCode = '$baseCode${Random().nextInt(999).toString().padLeft(3, '0')}';
        break;
      }
    }
    
    return finalCode;
  }
  
  static Map<String, dynamic> _getDefaultRewards(String codeType) {
    switch (codeType) {
      case 'vip':
        return {
          'referrer': {'spa_points': 200, 'premium_days': 7},
          'referred': {'spa_points': 100, 'premium_trial': 14}
        };
      case 'tournament':
        return {
          'referrer': {'free_entry_tickets': 2, 'spa_points': 150},
          'referred': {'free_entry_tickets': 1, 'practice_mode': true}
        };
      case 'club':
        return {
          'referrer': {'spa_points': 120, 'club_bonus': 50},
          'referred': {'spa_points': 60, 'club_welcome': true}
        };
      default: // general
        return {
          'referrer': {'spa_points': 100, 'elo_boost': 10},
          'referred': {'spa_points': 50, 'welcome_bonus': true}
        };
    }
  }
  
  static Future<void> _applyReferralBonuses(
    String referrerId, 
    String referredId, 
    Map<String, dynamic> rewards
  ) async {
    try {
      // Apply referrer bonuses
      if (rewards.containsKey('referrer')) {
        final referrerRewards = rewards['referrer'] as Map<String, dynamic>;
        await _applyUserBonus(referrerId, referrerRewards);
        await _updateUserReferralStats(referrerId, 'total_referred', 1);
        
        // Calculate total earned
        int spaPoints = referrerRewards['spa_points'] ?? 0;
        await _updateUserReferralStats(referrerId, 'total_earned', spaPoints);
      }
      
      // Apply referred user bonuses
      if (rewards.containsKey('referred')) {
        final referredRewards = rewards['referred'] as Map<String, dynamic>;
        await _applyUserBonus(referredId, referredRewards);
      }
      
    } catch (e) {
      print('💥 Error applying referral bonuses: $e');
    }
  }
  
  static Future<void> _applyUserBonus(String userId, Map<String, dynamic> bonus) async {
    // Apply SPA points bonus
    if (bonus.containsKey('spa_points')) {
      final currentUser = await _supabase
          .from('users')
          .select('spa_points')
          .eq('id', userId)
          .single();
      
      int currentPoints = currentUser?['spa_points'] ?? 0;
      int bonusPoints = bonus['spa_points'] ?? 0;
      
      await _supabase
          .from('users')
          .update({'spa_points': currentPoints + bonusPoints})
          .eq('id', userId);
    }
    
    // Apply ELO boost
    if (bonus.containsKey('elo_boost')) {
      final currentUser = await _supabase
          .from('users')
          .select('elo_rating')
          .eq('id', userId)
          .single();
      
      int currentElo = currentUser?['elo_rating'] ?? 1200;
      int eloBoost = bonus['elo_boost'] ?? 0;
      
      await _supabase
          .from('users')
          .update({'elo_rating': currentElo + eloBoost})
          .eq('id', userId);
    }
    
    // Mark referral bonus as claimed
    await _supabase
        .from('users')
        .update({'referral_bonus_claimed': true})
        .eq('id', userId);
  }
  
  static Future<void> _updateUserReferralStats(String userId, String field, int increment) async {
    final currentUser = await _supabase
        .from('users')
        .select('referral_stats')
        .eq('id', userId)
        .single();
    
    Map<String, dynamic> stats = Map<String, dynamic>.from(
      currentUser?['referral_stats'] ?? {'total_referred': 0, 'total_earned': 0, 'codes_created': 0}
    );
    
    stats[field] = (stats[field] ?? 0) + increment;
    
    await _supabase
        .from('users')
        .update({'referral_stats': stats})
        .eq('id', userId);
  }
}