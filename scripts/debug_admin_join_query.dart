import 'dart:convert';
import 'dart:io';

const String SUPABASE_URL = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
const String SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ';

Future<void> main() async {
  print('🔍 Testing admin clubs query with join...\n');
  
  try {
    // First, let's add a test club if none exists
    print('1. Adding a test club...');
    final client = HttpClient();
    
    final createRequest = await client.postUrl(Uri.parse('$SUPABASE_URL/rest/v1/clubs'));
    createRequest.headers.set('apikey', SUPABASE_ANON_KEY);
    createRequest.headers.set('Authorization', 'Bearer $SUPABASE_ANON_KEY');
    createRequest.headers.set('Content-Type', 'application/json');
    
    final testClub = {
      'name': 'Test Admin Club',
      'description': 'Test club for admin debugging',
      'approval_status': 'pending',
      'total_tables': 5,
      'is_active': true,
      'is_verified': false,
    };
    
    createRequest.add(utf8.encode(jsonEncode(testClub)));
    final createResponse = await createRequest.close();
    final createBody = await createResponse.transform(utf8.decoder).join();
    
    print('Create club response: ${createResponse.statusCode}');
    if (createResponse.statusCode != 201) {
      print('Create response body: $createBody');
    }
    
    client.close();
    
    // Now test the admin query with join
    print('\n2. Testing admin query with join...');
    final queryClient = HttpClient();
    
    final request = await queryClient.getUrl(Uri.parse(
      '$SUPABASE_URL/rest/v1/clubs?select=*,owner:users!clubs_owner_id_fkey(id,display_name,email,avatar_url,phone)&order=created_at.desc&limit=10'
    ));
    
    request.headers.set('apikey', SUPABASE_ANON_KEY);
    request.headers.set('Authorization', 'Bearer $SUPABASE_ANON_KEY');
    request.headers.set('Content-Type', 'application/json');
    
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    print('Query Response Status: ${response.statusCode}');
    print('Query Response Body: $responseBody\n');
    
    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody);
      if (data is List && data.isNotEmpty) {
        print('✅ Query successful, found ${data.length} clubs');
        final firstClub = data[0];
        print('First club type: ${firstClub.runtimeType}');
        if (firstClub is Map) {
          print('Club keys: ${firstClub.keys.toList()}');
          print('Owner field type: ${firstClub['owner']?.runtimeType}');
          print('Owner content: ${firstClub['owner']}');
          
          // Try to create Club object from this data
          try {
            print('\n3. Testing Club.fromJson conversion...');
            // Simulate what happens in the code
            final clubData = firstClub as Map<String, dynamic>;
            print('Club data parsed successfully');
            
            // Check specific fields that might cause issues
            print('approval_status: ${clubData['approval_status']} (${clubData['approval_status']?.runtimeType})');
            print('created_at: ${clubData['created_at']} (${clubData['created_at']?.runtimeType})');
            print('updated_at: ${clubData['updated_at']} (${clubData['updated_at']?.runtimeType})');
            
          } catch (e, stackTrace) {
            print('❌ Error converting to Club: $e');
            print('Stack trace: $stackTrace');
          }
        }
      } else {
        print('No clubs found in response');
      }
    }
    
    queryClient.close();
    
  } catch (e, stackTrace) {
    print('❌ Error: $e');
    print('Stack trace: $stackTrace');
  }
}