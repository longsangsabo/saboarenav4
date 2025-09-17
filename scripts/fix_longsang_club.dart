import 'dart:convert';
import 'dart:io';

const String SUPABASE_URL = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
const String SUPABASE_SERVICE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo';

Future<void> main() async {
  print('🔧 Fixing longsang063@gmail.com club to test approval workflow...\n');
  
  try {
    final client = HttpClient();
    
    // Step 1: Activate the club
    print('1. Activating SABO Billiards club...');
    final clubUpdateRequest = await client.patchUrl(Uri.parse(
      '$SUPABASE_URL/rest/v1/clubs?id=eq.4efdd198-c2b7-4428-a6f8-3cf132fc71f7'
    ));
    
    clubUpdateRequest.headers.set('apikey', SUPABASE_SERVICE_KEY);
    clubUpdateRequest.headers.set('Authorization', 'Bearer $SUPABASE_SERVICE_KEY');
    clubUpdateRequest.headers.set('Content-Type', 'application/json');
    clubUpdateRequest.headers.set('Prefer', 'return=representation');
    
    final clubUpdateData = jsonEncode({
      'is_active': true,
      'updated_at': DateTime.now().toIso8601String(),
    });
    
    clubUpdateRequest.write(clubUpdateData);
    final clubUpdateResponse = await clubUpdateRequest.close();
    final clubUpdateBody = await clubUpdateResponse.transform(utf8.decoder).join();
    
    print('Club update status: ${clubUpdateResponse.statusCode}');
    if (clubUpdateResponse.statusCode == 200) {
      print('✅ Club activated successfully');
    } else {
      print('❌ Failed to activate club: $clubUpdateBody');
    }
    
    // Step 2: Update user role to club_owner
    print('\\n2. Updating user role to club_owner...');
    final userUpdateRequest = await client.patchUrl(Uri.parse(
      '$SUPABASE_URL/rest/v1/users?id=eq.8dc68b2e-8c94-47d7-a2d7-a70b218c32a8'
    ));
    
    userUpdateRequest.headers.set('apikey', SUPABASE_SERVICE_KEY);
    userUpdateRequest.headers.set('Authorization', 'Bearer $SUPABASE_SERVICE_KEY');
    userUpdateRequest.headers.set('Content-Type', 'application/json');
    userUpdateRequest.headers.set('Prefer', 'return=representation');
    
    final userUpdateData = jsonEncode({
      'role': 'club_owner',
      'updated_at': DateTime.now().toIso8601String(),
    });
    
    userUpdateRequest.write(userUpdateData);
    final userUpdateResponse = await userUpdateRequest.close();
    final userUpdateBody = await userUpdateResponse.transform(utf8.decoder).join();
    
    print('User update status: ${userUpdateResponse.statusCode}');
    if (userUpdateResponse.statusCode == 200) {
      print('✅ User role updated successfully');
    } else {
      print('❌ Failed to update user role: $userUpdateBody');
    }
    
    // Step 3: Verify the changes
    print('\\n3. Verifying changes...');
    
    // Check club
    final clubCheckRequest = await client.getUrl(Uri.parse(
      '$SUPABASE_URL/rest/v1/clubs?select=id,name,owner_id,approval_status,is_active&id=eq.4efdd198-c2b7-4428-a6f8-3cf132fc71f7'
    ));
    
    clubCheckRequest.headers.set('apikey', SUPABASE_SERVICE_KEY);
    clubCheckRequest.headers.set('Authorization', 'Bearer $SUPABASE_SERVICE_KEY');
    clubCheckRequest.headers.set('Content-Type', 'application/json');
    
    final clubCheckResponse = await clubCheckRequest.close();
    final clubCheckBody = await clubCheckResponse.transform(utf8.decoder).join();
    
    if (clubCheckResponse.statusCode == 200) {
      final clubCheckData = jsonDecode(clubCheckBody) as List;
      if (clubCheckData.isNotEmpty) {
        final club = clubCheckData[0] as Map<String, dynamic>;
        print('Club status:');
        print('  - Name: ${club['name']}');
        print('  - Approval Status: ${club['approval_status']}');
        print('  - Is Active: ${club['is_active']}');
      }
    }
    
    // Check user
    final userCheckRequest = await client.getUrl(Uri.parse(
      '$SUPABASE_URL/rest/v1/users?select=id,email,role,display_name&id=eq.8dc68b2e-8c94-47d7-a2d7-a70b218c32a8'
    ));
    
    userCheckRequest.headers.set('apikey', SUPABASE_SERVICE_KEY);
    userCheckRequest.headers.set('Authorization', 'Bearer $SUPABASE_SERVICE_KEY');
    userCheckRequest.headers.set('Content-Type', 'application/json');
    
    final userCheckResponse = await userCheckRequest.close();
    final userCheckBody = await userCheckResponse.transform(utf8.decoder).join();
    
    if (userCheckResponse.statusCode == 200) {
      final userCheckData = jsonDecode(userCheckBody) as List;
      if (userCheckData.isNotEmpty) {
        final user = userCheckData[0] as Map<String, dynamic>;
        print('User status:');
        print('  - Email: ${user['email']}');
        print('  - Role: ${user['role']}');
        print('  - Display Name: ${user['display_name']}');
      }
    }
    
    // Step 4: Test public API call (similar to what app uses)
    print('\\n4. Testing public club API (what app sees)...');
    final publicApiRequest = await client.getUrl(Uri.parse(
      '$SUPABASE_URL/rest/v1/clubs?select=*&approval_status=eq.approved&is_active=eq.true'
    ));
    
    publicApiRequest.headers.set('apikey', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ');
    publicApiRequest.headers.set('Content-Type', 'application/json');
    
    final publicApiResponse = await publicApiRequest.close();
    final publicApiBody = await publicApiResponse.transform(utf8.decoder).join();
    
    if (publicApiResponse.statusCode == 200) {
      final publicApiData = jsonDecode(publicApiBody) as List;
      print('Public API returned ${publicApiData.length} active clubs:');
      for (var club in publicApiData) {
        print('  - ${club['name']} | Owner: ${club['owner_id']} | Active: ${club['is_active']}');
      }
    }
    
    client.close();
    print('\\n🎉 Fix completed! Now longsang063@gmail.com should see their club in the app.');
    
  } catch (e, stackTrace) {
    print('❌ Error: $e');
    print('Stack trace: $stackTrace');
  }
}