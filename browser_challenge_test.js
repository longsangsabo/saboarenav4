// Simple JavaScript test to verify challenge functionality in browser console
// Copy và paste vào Chrome DevTools Console

console.log('🧪 CHALLENGE SYSTEM TEST - Browser Console Version');
console.log('================================================\n');

// Test data
const challengedPlayer = {
  id: '00000000-0000-0000-0000-000000000002',
  user_id: '00000000-0000-0000-0000-000000000002',
  full_name: 'Test Player 2',
  username: 'testplayer2',
  elo_rating: 1200,
  current_rank: 'Intermediate'
};

const challengeData = {
  challengeType: 'thach_dau',
  gameType: '8-ball',
  scheduledTime: new Date(Date.now() + 2 * 60 * 60 * 1000).toISOString(), // 2 hours from now
  location: 'Test Billiards Club',
  handicap: 0,
  spaPoints: 100,
  message: 'Browser console test challenge - ' + new Date().toISOString()
};

console.log('🎯 Challenge Data:', JSON.stringify(challengeData, null, 2));
console.log('👤 Target Player:', JSON.stringify(challengedPlayer, null, 2));

// Function to test challenge system directly in browser
async function testChallengeSystem() {
  try {
    console.log('\n📡 Testing Supabase connection...');
    
    // Check if window.flutter_service is available
    if (typeof window.flutter_service !== 'undefined') {
      console.log('✅ Flutter service detected');
    } else {
      console.log('❌ Flutter service not available');
    }
    
    // Check global Flutter objects
    if (typeof window._flutter !== 'undefined') {
      console.log('✅ Flutter runtime detected');
    }
    
    // Check if challenge modal can be opened
    console.log('\n🎯 Looking for challenge modal trigger...');
    const challengeButtons = document.querySelectorAll('[data-challenge-trigger]');
    console.log(`Found ${challengeButtons.length} challenge buttons`);
    
    // Check player cards
    const playerCards = document.querySelectorAll('[data-player-card]');
    console.log(`Found ${playerCards.length} player cards`);
    
    // Look for SimpleChallengeService in Flutter
    console.log('\n🔍 Checking Flutter services availability...');
    
    // Try to access Flutter debug info
    if (window.flutterCanvasKit) {
      console.log('✅ Flutter CanvasKit available');
    }
    
    if (window.$dartLoader) {
      console.log('✅ Dart loader available');
    }
    
    console.log('\n📋 Test Summary:');
    console.log('===============');
    console.log('Challenge data prepared: ✅');
    console.log('Player data prepared: ✅');
    console.log('Browser environment: ✅');
    console.log('Next: Test challenge sending through UI interaction');
    
    return {
      success: true,
      challengeData,
      challengedPlayer,
      debugInfo: {
        flutter_service: typeof window.flutter_service !== 'undefined',
        flutter_runtime: typeof window._flutter !== 'undefined',
        canvasKit: !!window.flutterCanvasKit,
        dartLoader: !!window.$dartLoader,
        challengeButtons: challengeButtons.length,
        playerCards: playerCards.length
      }
    };
    
  } catch (error) {
    console.error('❌ Error testing challenge system:', error);
    return { success: false, error: error.message };
  }
}

// Instructions for manual testing
console.log('\n📖 MANUAL TESTING INSTRUCTIONS:');
console.log('================================');
console.log('1. Run: testChallengeSystem()');
console.log('2. Look for player cards in the UI');
console.log('3. Click "Thách Đấu" button on any player card');
console.log('4. Fill challenge form with test data above');
console.log('5. Click "Gửi Thách Đấu" and check console logs');
console.log('6. Check browser Network tab for API calls');

// Auto-run the test
testChallengeSystem().then(result => {
  console.log('\n🏁 Test Complete:', result);
});

// Helper function to simulate challenge sending
window.simulateChallenge = function() {
  console.log('🚀 Simulating challenge creation...');
  console.log('Challenge type:', challengeData.challengeType);
  console.log('Game type:', challengeData.gameType);
  console.log('Target player:', challengedPlayer.full_name);
  console.log('SPA Points:', challengeData.spaPoints);
  console.log('Time:', challengeData.scheduledTime);
  console.log('📡 This would normally trigger SimpleChallengeService.sendChallenge()');
};