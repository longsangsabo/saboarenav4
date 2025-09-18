import 'lib/services/test_user_service.dart';
import 'lib/services/simple_challenge_service.dart';
import 'dart:convert';

void main() async {
  print('🧪 CHALLENGE SYSTEM COMPLETE TEST');
  print('================================\n');
  
  // Initialize services
  final testUserService = TestUserService.instance;
  final challengeService = SimpleChallengeService.instance;
  
  try {
    // Test 1: Get test user
    print('📝 Test 1: Get test user...');
    final testUser = await testUserService.getOrCreateTestUser();
    print('✅ Test user: ${testUser?.toJson()}\n');
    
    if (testUser == null) {
      print('❌ FAILED: Could not get test user');
      return;
    }
    
    // Test 2: Create mock challenged player data
    print('📝 Test 2: Create mock challenged player...');
    final challengedPlayer = {
      'id': '00000000-0000-0000-0000-000000000002',
      'user_id': '00000000-0000-0000-0000-000000000002',
      'full_name': 'Test Player 2',
      'username': 'testplayer2',
      'elo_rating': 1200,
      'current_rank': 'Intermediate',
    };
    print('✅ Challenged player: ${jsonEncode(challengedPlayer)}\n');
    
    // Test 3: Prepare challenge data
    print('📝 Test 3: Prepare challenge data...');
    final challengeData = {
      'challengeType': 'thach_dau',
      'gameType': '8-ball',
      'scheduledTime': DateTime.now().add(Duration(hours: 2)).toIso8601String(),
      'location': 'Test Billiards Club',
      'handicap': 0,
      'spaPoints': 100,
      'message': 'Complete system test challenge - ${DateTime.now().toIso8601String()}',
    };
    print('✅ Challenge data: ${jsonEncode(challengeData)}\n');
    
    // Test 4: Send challenge
    print('📝 Test 4: Send challenge...');
    print('Calling challengeService.sendChallenge...');
    final result = await challengeService.sendChallenge(
      challengedUserId: challengedPlayer['id'] as String,
      challengeType: challengeData['challengeType'] as String,
      gameType: challengeData['gameType'] as String,
      scheduledTime: DateTime.parse(challengeData['scheduledTime'] as String),
      location: challengeData['location'] as String,
      handicap: challengeData['handicap'] as int,
      spaPoints: challengeData['spaPoints'] as int,
      message: challengeData['message'] as String,
    );
    
    print('Raw result: $result');
    print('Result type: ${result.runtimeType}');
    
    if (result != null) {
      print('✅ SUCCESS: Challenge sent successfully!');
      print('Challenge data: ${jsonEncode(result)}');
    } else {
      print('❌ FAILED: Challenge sending failed');
      print('Result: $result');
    }
    
    print('\n🎯 COMPLETE TEST SUMMARY');
    print('======================');
    print('Test User Service: ✅ Working');
    print('Challenge Service: ${result != null ? "✅ Working" : "❌ Failed"}');
    print('Database Integration: ${result != null ? "✅ Working" : "❌ Failed"}');
    
  } catch (e, stackTrace) {
    print('❌ ERROR in challenge system test:');
    print('Error: $e');
    print('Stack trace: $stackTrace');
  }
  
  print('\n🔍 Additional Debug Info:');
  print('========================');
  print('Current time: ${DateTime.now()}');
  print('Test completed at: ${DateTime.now().toIso8601String()}');
}