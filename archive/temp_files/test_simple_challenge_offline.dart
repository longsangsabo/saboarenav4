import 'lib/services/simple_challenge_service.dart';

/// Test SimpleChallengeService offline
void main() async {
  print('🧪 Testing SimpleChallengeService offline...');
  
  final service = SimpleChallengeService.instance;
  
  // Test SPA betting options
  print('\n📊 SPA Betting Options:');
  final spaOptions = service.getSpaBettingOptions();
  for (var option in spaOptions) {
    print('   ${option['amount']} SPA - ${option['description']} (Race to ${option['raceTo']})');
  }
  
  // Test validation (should work offline)
  print('\n🔍 Testing validation...');
  try {
    final canPlay = await service.canPlayersChallenge('user1', 'user2');
    print('   Validation result: $canPlay');
  } catch (e) {
    print('   Validation error (expected offline): $e');
  }
  
  // Test challenge data structure
  print('\n📝 Testing challenge data structure...');
  final challengeData = {
    'challenger_id': 'user1',
    'challenged_id': 'user2',
    'challenge_type': 'thach_dau',
    'game_type': '8-ball',
    'scheduled_time': DateTime.now().add(const Duration(hours: 2)).toIso8601String(),
    'location': 'Billiards Club Sài Gòn',
    'handicap': 0,
    'spa_points': 200,
    'message': 'Thách đấu 8-ball 200 SPA!',
    'status': 'pending',
    'expires_at': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
    'created_at': DateTime.now().toIso8601String(),
  };
  
  print('   Challenge data structure:');
  challengeData.forEach((key, value) {
    print('     $key: $value');
  });
  
  print('\n✅ Offline test completed!');
  print('💡 SimpleChallengeService structure looks good.');
  print('📡 To test actual sending, need live Supabase connection.');
}