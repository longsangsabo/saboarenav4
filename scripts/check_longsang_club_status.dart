import 'dart:convert';
import 'dart:io';

const String SUPABASE_URL = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
const String SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ';

Future<void> main() async {
  print('🔍 Checking longsang063@gmail.com club status...\n');
  
  try {
    // First, find the user ID for longsang063@gmail.com
    print('1. Finding user ID for longsang063@gmail.com...');
    final client = HttpClient();
    
    final userRequest = await client.getUrl(Uri.parse(
      '$SUPABASE_URL/rest/v1/users?select=id,email,role&email=eq.longsang063@gmail.com'
    ));
    
    userRequest.headers.set('apikey', SUPABASE_ANON_KEY);
    userRequest.headers.set('Authorization', 'Bearer $SUPABASE_ANON_KEY');
    userRequest.headers.set('Content-Type', 'application/json');
    
    final userResponse = await userRequest.close();
    final userBody = await userResponse.transform(utf8.decoder).join();
    
    print('User query response: ${userResponse.statusCode}');
    print('User data: $userBody\n');
    
    if (userResponse.statusCode == 200) {
      final userData = jsonDecode(userBody) as List;
      if (userData.isNotEmpty) {
        final user = userData[0] as Map<String, dynamic>;
        final userId = user['id'];
        final userRole = user['role'];
        
        print('✅ Found user: $userId');
        print('Current role: $userRole\n');
        
        // Now check clubs owned by this user
        print('2. Checking clubs owned by this user...');
        final clubRequest = await client.getUrl(Uri.parse(
          '$SUPABASE_URL/rest/v1/clubs?select=id,name,approval_status,is_active,created_at&owner_id=eq.$userId'
        ));
        
        clubRequest.headers.set('apikey', SUPABASE_ANON_KEY);
        clubRequest.headers.set('Authorization', 'Bearer $SUPABASE_ANON_KEY');
        clubRequest.headers.set('Content-Type', 'application/json');
        
        final clubResponse = await clubRequest.close();
        final clubBody = await clubResponse.transform(utf8.decoder).join();
        
        print('Club query response: ${clubResponse.statusCode}');
        print('Club data: $clubBody\n');
        
        if (clubResponse.statusCode == 200) {
          final clubData = jsonDecode(clubBody) as List;
          print('Found ${clubData.length} clubs owned by this user:');
          
          for (var club in clubData) {
            print('  - Club: ${club['name']}');
            print('    ID: ${club['id']}');
            print('    Status: ${club['approval_status']}');
            print('    Active: ${club['is_active']}');
            print('    Created: ${club['created_at']}');
            print('');
          }
          
          // Check if any club is approved
          final approvedClubs = clubData.where((club) => club['approval_status'] == 'approved').toList();
          if (approvedClubs.isNotEmpty) {
            print('✅ User has ${approvedClubs.length} approved clubs');
            
            // Check if user role should be updated
            if (userRole != 'club_owner') {
              print('❌ User role should be "club_owner" but is currently "$userRole"');
            } else {
              print('✅ User role is correctly set to "club_owner"');
            }
          } else {
            print('❌ No approved clubs found for this user');
          }
        }
      } else {
        print('❌ User not found in database');
      }
    }
    
    client.close();
    
    // Also check what clubs are returned by the public API
    print('\\n3. Checking public clubs API (what users see in app)...');
    final publicClient = HttpClient();
    
    final publicRequest = await publicClient.getUrl(Uri.parse(
      '$SUPABASE_URL/rest/v1/clubs?select=id,name,approval_status,is_active&is_active=eq.true&approval_status=eq.approved&order=rating.desc&limit=20'
    ));
    
    publicRequest.headers.set('apikey', SUPABASE_ANON_KEY);
    publicRequest.headers.set('Authorization', 'Bearer $SUPABASE_ANON_KEY');
    publicRequest.headers.set('Content-Type', 'application/json');
    
    final publicResponse = await publicRequest.close();
    final publicBody = await publicResponse.transform(utf8.decoder).join();
    
    print('Public clubs response: ${publicResponse.statusCode}');
    if (publicResponse.statusCode == 200) {
      final publicData = jsonDecode(publicBody) as List;
      print('Found ${publicData.length} clubs in public listing:');
      
      for (var club in publicData) {
        print('  - ${club['name']} (${club['id']})');
      }
    }
    
    publicClient.close();
    
  } catch (e, stackTrace) {
    print('❌ Error: $e');
    print('Stack trace: $stackTrace');
  }
}