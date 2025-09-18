/// Debug test for challenge system - isolated test without full Flutter context
/// Run this in browser console to test challenge flow

console.log('🧪 Debug Challenge System Test');

// Mock test data
const mockChallengeData = {
  challenger_id: 'test-user-1',
  challenged_id: 'test-user-2',
  challenge_type: 'thach_dau',
  game_type: '8-ball',
  scheduled_time: new Date(Date.now() + 2 * 60 * 60 * 1000).toISOString(),
  location: 'Billiards Club Sài Gòn',
  handicap: 0,
  spa_points: 200,
  message: 'Test challenge from debug',
  status: 'pending',
  expires_at: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString(),
  created_at: new Date().toISOString(),
};

console.log('📊 Mock challenge data:', mockChallengeData);

// Check 1: Flutter app detection
function checkFlutterApp() {
  console.log('🔍 Check 1: Flutter app detection');
  
  if (window.flutterWebRenderer) {
    console.log('✅ Flutter web renderer found');
  } else {
    console.log('❌ Flutter web renderer not found');
  }
  
  // Check for Flutter-specific DOM elements
  const flutterView = document.querySelector('flt-scene-host') || 
                     document.querySelector('flt-glass-pane') ||
                     document.querySelector('[flt-renderer]');
  
  if (flutterView) {
    console.log('✅ Flutter DOM elements found');
  } else {
    console.log('❌ No Flutter DOM elements found');
  }
}

// Check 2: Supabase client detection
function checkSupabaseConnection() {
  console.log('🔍 Check 2: Supabase connection');
  
  // Look for network requests to Supabase
  const observer = new PerformanceObserver((list) => {
    for (const entry of list.getEntries()) {
      if (entry.name.includes('supabase.co')) {
        console.log('✅ Supabase request detected:', entry.name);
      }
    }
  });
  observer.observe({entryTypes: ['resource']});
  
  // Check for Supabase in network requests
  const navigationEntries = performance.getEntriesByType('navigation');
  const resourceEntries = performance.getEntriesByType('resource');
  
  const supabaseRequests = resourceEntries.filter(entry => 
    entry.name.includes('supabase.co')
  );
  
  console.log(`📡 Found ${supabaseRequests.length} Supabase requests`);
  supabaseRequests.forEach((req, i) => {
    console.log(`   ${i + 1}. ${req.name} (${req.responseStatus || 'pending'})`);
  });
}

// Check 3: Authentication status
function checkAuthentication() {
  console.log('🔍 Check 3: Authentication');
  
  // Look for auth tokens in localStorage/sessionStorage
  const localStorage_keys = Object.keys(localStorage);
  const sessionStorage_keys = Object.keys(sessionStorage);
  
  const authKeys = [...localStorage_keys, ...sessionStorage_keys].filter(key => 
    key.includes('supabase') || key.includes('auth') || key.includes('token')
  );
  
  if (authKeys.length > 0) {
    console.log('✅ Auth-related storage found:', authKeys);
  } else {
    console.log('❌ No auth-related storage found');
  }
  
  // Check for auth-related cookies
  const cookies = document.cookie.split(';').map(c => c.trim());
  const authCookies = cookies.filter(cookie => 
    cookie.includes('supabase') || cookie.includes('auth')
  );
  
  if (authCookies.length > 0) {
    console.log('✅ Auth cookies found:', authCookies);
  } else {
    console.log('❌ No auth cookies found');
  }
}

// Check 4: Network monitoring for challenge requests
function monitorChallengeRequests() {
  console.log('🔍 Check 4: Monitoring challenge requests');
  
  // Monitor fetch requests
  const originalFetch = window.fetch;
  window.fetch = function(...args) {
    const [resource, config] = args;
    
    if (resource.toString().includes('challenges') || 
        (config && config.body && config.body.includes('challenges'))) {
      console.log('🎯 Challenge request detected:', resource, config);
    }
    
    return originalFetch.apply(this, args);
  };
  
  console.log('📡 Network monitoring enabled - try sending a challenge now');
}

// Check 5: Console error monitoring
function monitorConsoleErrors() {
  console.log('🔍 Check 5: Console error monitoring');
  
  const originalError = console.error;
  console.error = function(...args) {
    if (args.some(arg => 
      typeof arg === 'string' && 
      (arg.includes('challenge') || arg.includes('SimpleChallengeService'))
    )) {
      console.log('🚨 Challenge-related error:', args);
    }
    return originalError.apply(this, args);
  };
  
  console.log('🎯 Error monitoring enabled');
}

// Run all checks
function runDebugChecks() {
  console.log('🚀 Running debug checks for challenge system...\n');
  
  checkFlutterApp();
  console.log('');
  
  checkSupabaseConnection();
  console.log('');
  
  checkAuthentication();
  console.log('');
  
  monitorChallengeRequests();
  console.log('');
  
  monitorConsoleErrors();
  
  console.log('\n✅ Debug setup complete!');
  console.log('📋 Next steps:');
  console.log('1. Navigate to "Tìm đối" tab in the app');
  console.log('2. Try sending a challenge');
  console.log('3. Check console for detailed logs');
  console.log('4. Monitor Network tab for requests');
}

// Auto-run when script loads
runDebugChecks();