import 'dart:convert';
import 'dart:io';

const String SUPABASE_URL = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
// Service role key - có quyền cao hơn để xem toàn bộ data
const String SUPABASE_SERVICE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo';

Future<void> main() async {
  print('🔍 Checking database with service key...\n');
  
  try {
    final client = HttpClient();
    
    // 1. Check users table - tìm user longsang063@gmail.com
    print('1. Checking users table for longsang063@gmail.com...');
    final userRequest = await client.getUrl(Uri.parse(
      '$SUPABASE_URL/rest/v1/users?select=*&email=eq.longsang063@gmail.com'
    ));
    
    userRequest.headers.set('apikey', SUPABASE_SERVICE_KEY);
    userRequest.headers.set('Authorization', 'Bearer $SUPABASE_SERVICE_KEY');
    userRequest.headers.set('Content-Type', 'application/json');
    
    final userResponse = await userRequest.close();
    final userBody = await userResponse.transform(utf8.decoder).join();
    
    print('User query status: ${userResponse.statusCode}');
    if (userResponse.statusCode == 200) {
      final userData = jsonDecode(userBody) as List;
      if (userData.isNotEmpty) {
        final user = userData[0] as Map<String, dynamic>;
        print('✅ Found user:');
        print('  - ID: ${user['id']}');
        print('  - Email: ${user['email']}');
        print('  - Role: ${user['role']}');
        print('  - Display Name: ${user['display_name']}');
        print('  - Created: ${user['created_at']}');
        
        final userId = user['id'];
        
        // 2. Check clubs table với owner_id = user ID này
        print('\\n2. Checking clubs table for owner_id = $userId...');
        final clubRequest = await client.getUrl(Uri.parse(
          '$SUPABASE_URL/rest/v1/clubs?select=*&owner_id=eq.$userId'
        ));
        
        clubRequest.headers.set('apikey', SUPABASE_SERVICE_KEY);
        clubRequest.headers.set('Authorization', 'Bearer $SUPABASE_SERVICE_KEY');
        clubRequest.headers.set('Content-Type', 'application/json');
        
        final clubResponse = await clubRequest.close();
        final clubBody = await clubResponse.transform(utf8.decoder).join();
        
        print('Club query status: ${clubResponse.statusCode}');
        if (clubResponse.statusCode == 200) {
          final clubData = jsonDecode(clubBody) as List;
          print('Found ${clubData.length} clubs owned by this user:');
          
          if (clubData.isNotEmpty) {
            for (var club in clubData) {
              print('  Club Details:');
              print('    - ID: ${club['id']}');
              print('    - Name: ${club['name']}');
              print('    - Owner ID: ${club['owner_id']}');
              print('    - Approval Status: ${club['approval_status']}');
              print('    - Is Active: ${club['is_active']}');
              print('    - Created: ${club['created_at']}');
              print('    - Updated: ${club['updated_at']}');
              print('');
            }
          } else {
            print('  ❌ No clubs found for this user');
          }
        }
        
        // 3. Check tất cả clubs để xem có pattern gì không
        print('\\n3. Checking all clubs in database...');
        final allClubsRequest = await client.getUrl(Uri.parse(
          '$SUPABASE_URL/rest/v1/clubs?select=id,name,owner_id,approval_status,is_active,created_at&order=created_at.desc'
        ));
        
        allClubsRequest.headers.set('apikey', SUPABASE_SERVICE_KEY);
        allClubsRequest.headers.set('Authorization', 'Bearer $SUPABASE_SERVICE_KEY');
        allClubsRequest.headers.set('Content-Type', 'application/json');
        
        final allClubsResponse = await allClubsRequest.close();
        final allClubsBody = await allClubsResponse.transform(utf8.decoder).join();
        
        if (allClubsResponse.statusCode == 200) {
          final allClubsData = jsonDecode(allClubsBody) as List;
          print('All clubs in database (${allClubsData.length} total):');
          
          for (var club in allClubsData) {
            print('  - ${club['name']} | Owner: ${club['owner_id']} | Status: ${club['approval_status']} | Active: ${club['is_active']}');
          }
        }
        
        // 4. Check tất cả users để xem có ai khác không
        print('\\n4. Checking all users...');
        final allUsersRequest = await client.getUrl(Uri.parse(
          '$SUPABASE_URL/rest/v1/users?select=id,email,role,display_name&order=created_at.desc'
        ));
        
        allUsersRequest.headers.set('apikey', SUPABASE_SERVICE_KEY);
        allUsersRequest.headers.set('Authorization', 'Bearer $SUPABASE_SERVICE_KEY');
        allUsersRequest.headers.set('Content-Type', 'application/json');
        
        final allUsersResponse = await allUsersRequest.close();
        final allUsersBody = await allUsersResponse.transform(utf8.decoder).join();
        
        if (allUsersResponse.statusCode == 200) {
          final allUsersData = jsonDecode(allUsersBody) as List;
          print('All users in database (${allUsersData.length} total):');
          
          for (var user in allUsersData) {
            print('  - ${user['email']} | ID: ${user['id']} | Role: ${user['role']} | Name: ${user['display_name'] ?? 'N/A'}');
          }
        }
        
      } else {
        print('❌ User not found in database');
      }
    } else {
      print('❌ Error querying users: ${userResponse.statusCode}');
      print('Response: $userBody');
    }
    
    client.close();
    
  } catch (e, stackTrace) {
    print('❌ Error: $e');
    print('Stack trace: $stackTrace');
  }
}