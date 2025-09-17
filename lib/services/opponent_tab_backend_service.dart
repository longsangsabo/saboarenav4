import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for testing opponent tab backend integration
class OpponentTabBackendService {
  final _supabase = Supabase.instance.client;

  /// Test get_nearby_players function
  Future<List<Map<String, dynamic>>> testGetNearbyPlayers({
    required double latitude,
    required double longitude,
    int radiusKm = 10,
  }) async {
    try {
      final response = await _supabase.rpc(
        'get_nearby_players',
        params: {
          'center_lat': latitude,
          'center_lng': longitude,
          'radius_km': radiusKm,
        },
      );

      print('✅ get_nearby_players response: $response');
      
      if (response is List) {
        return List<Map<String, dynamic>>.from(response);
      }
      return [];
    } catch (e) {
      print('❌ get_nearby_players error: $e');
      return [];
    }
  }

  /// Test create_challenge function
  Future<String?> testCreateChallenge({
    required String challengedUserId,
    required String challengeType, // 'giao_luu' or 'thach_dau'
    String? message,
    String stakesType = 'none',
    int stakesAmount = 0,
    Map<String, dynamic>? matchConditions,
  }) async {
    try {
      final response = await _supabase.rpc(
        'create_challenge',
        params: {
          'challenged_user_id': challengedUserId,
          'challenge_type_param': challengeType,
          'message_param': message,
          'stakes_type_param': stakesType,
          'stakes_amount_param': stakesAmount,
          'match_conditions_param': matchConditions ?? {},
        },
      );

      print('✅ create_challenge response: $response');
      return response?.toString();
    } catch (e) {
      print('❌ create_challenge error: $e');
      return null;
    }
  }

  /// Test get_user_challenges function
  Future<List<Map<String, dynamic>>> testGetUserChallenges({
    String? statusFilter,
  }) async {
    try {
      final response = await _supabase.rpc(
        'get_user_challenges',
        params: {
          'user_uuid': _supabase.auth.currentUser?.id,
          'status_filter': statusFilter,
        },
      );

      print('✅ get_user_challenges response: $response');
      
      if (response is List) {
        return List<Map<String, dynamic>>.from(response);
      }
      return [];
    } catch (e) {
      print('❌ get_user_challenges error: $e');
      return [];
    }
  }

  /// Test accept_challenge function
  Future<String?> testAcceptChallenge({
    required String challengeId,
    String? responseMessage,
  }) async {
    try {
      final response = await _supabase.rpc(
        'accept_challenge',
        params: {
          'challenge_id_param': challengeId,
          'response_message_param': responseMessage,
        },
      );

      print('✅ accept_challenge response: $response');
      return response?.toString();
    } catch (e) {
      print('❌ accept_challenge error: $e');
      return null;
    }
  }

  /// Test decline_challenge function
  Future<bool> testDeclineChallenge({
    required String challengeId,
    String? responseMessage,
  }) async {
    try {
      final response = await _supabase.rpc(
        'decline_challenge',
        params: {
          'challenge_id_param': challengeId,
          'response_message_param': responseMessage,
        },
      );

      print('✅ decline_challenge response: $response');
      return response == true;
    } catch (e) {
      print('❌ decline_challenge error: $e');
      return false;
    }
  }

  /// Check if backend tables have required columns
  Future<void> checkBackendSchema() async {
    try {
      print('🔍 Checking backend schema...');

      // Check matches table columns
      final matchesSchema = await _supabase
          .from('matches')
          .select('match_type,challenger_id,stakes_type')
          .limit(1);
      print('✅ matches table has challenge columns: ${matchesSchema.isNotEmpty}');

      // Check users table columns  
      final usersSchema = await _supabase
          .from('users')
          .select('latitude,longitude,spa_points,is_available_for_challenges')
          .limit(1);
      print('✅ users table has location/challenge columns: ${usersSchema.isNotEmpty}');

      // Check challenges table exists
      final challengesExists = await _supabase
          .from('challenges')
          .select('id')
          .limit(1);
      print('✅ challenges table exists: ${challengesExists.isNotEmpty}');

    } catch (e) {
      print('❌ Backend schema check failed: $e');
      print('📋 Please run the SQL scripts in Supabase Dashboard:');
      print('   1. backend_setup_complete.sql');
      print('   2. create_test_data.sql');
    }
  }

  /// Get current user's location (for testing nearby players)
  Future<Map<String, double>?> getCurrentUserLocation() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      final response = await _supabase
          .from('users')
          .select('latitude,longitude')
          .eq('id', user.id)
          .single();

      if (response['latitude'] != null && response['longitude'] != null) {
        return {
          'latitude': double.parse(response['latitude'].toString()),
          'longitude': double.parse(response['longitude'].toString()),
        };
      }
    } catch (e) {
      print('❌ Could not get user location: $e');
    }
    return null;
  }

  /// Run comprehensive backend tests
  Future<void> runComprehensiveTest() async {
    print('🧪 Starting comprehensive backend test...\n');
    
    // 1. Check schema
    await checkBackendSchema();
    print('');

    // 2. Test nearby players
    print('🔍 Testing nearby players...');
    final location = await getCurrentUserLocation();
    if (location != null) {
      final nearbyPlayers = await testGetNearbyPlayers(
        latitude: location['latitude']!,
        longitude: location['longitude']!,
        radiusKm: 20,
      );
      print('Found ${nearbyPlayers.length} nearby players');
    } else {
      print('⚠️ User location not set, using default Hanoi coordinates');
      final nearbyPlayers = await testGetNearbyPlayers(
        latitude: 21.028511,
        longitude: 105.804817,
        radiusKm: 20,
      );
      print('Found ${nearbyPlayers.length} nearby players');
    }
    print('');

    // 3. Test user challenges
    print('📋 Testing user challenges...');
    final userChallenges = await testGetUserChallenges();
    print('Found ${userChallenges.length} challenges for current user');
    print('');

    // 4. Test creating challenge (if we have nearby players)
    final nearbyPlayers = await testGetNearbyPlayers(
      latitude: 21.028511,
      longitude: 105.804817,
      radiusKm: 20,
    );
    
    if (nearbyPlayers.isNotEmpty) {
      print('💪 Testing create challenge...');
      final targetUser = nearbyPlayers.first;
      final challengeId = await testCreateChallenge(
        challengedUserId: targetUser['user_id'],
        challengeType: 'giao_luu',
        message: 'Test challenge from Flutter app!',
        stakesType: 'none',
      );
      
      if (challengeId != null) {
        print('✅ Created challenge: $challengeId');
      }
    }

    print('\n🎉 Backend test completed!');
  }
}
