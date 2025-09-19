// Test challenge sending directly in Flutter app
// Paste this in Chrome DevTools Console when the app is running

console.log('🧪 Testing Challenge Sending...');

// Simulate a challenge being sent
function testChallengeFlow() {
  console.log('🎯 Starting challenge flow test...');
  
  // Check if we can see challenge-related logs
  console.log('📊 Looking for challenge system activity...');
  
  // You can monitor network requests to Supabase
  console.log('📡 Monitor Network tab for:');
  console.log('   - POST requests to challenges table');
  console.log('   - Authentication requests');
  console.log('   - Insert operations');
  
  // Check for Flutter app state
  if (window.flutterWebRenderer) {
    console.log('✅ Flutter web renderer detected');
  } else {
    console.log('❌ Flutter web renderer not found');
  }
  
  // Instructions for manual testing
  console.log('📋 Manual Test Steps:');
  console.log('1. Navigate to "Tìm đối" tab');
  console.log('2. Find a player card');
  console.log('3. Tap "Thách đấu" or "Giao lưu" button');
  console.log('4. Fill in challenge form');
  console.log('5. Tap "Gửi" button');
  console.log('6. Check browser console for logs');
  console.log('7. Check Network tab for Supabase requests');
}

testChallengeFlow();