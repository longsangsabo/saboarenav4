import 'dart:convert';
import 'dart:io';

const String SUPABASE_URL = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
const String SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ';

Future<void> main() async {
  print('🔍 Testing all admin query statuses...\n');
  
  final statuses = ['pending', 'approved', 'rejected'];
  
  for (final status in statuses) {
    try {
      print('Testing status: $status');
      final client = HttpClient();
      
      final request = await client.getUrl(Uri.parse(
        '$SUPABASE_URL/rest/v1/clubs?select=*,owner:users!clubs_owner_id_fkey(id,display_name,email,avatar_url,phone)&approval_status=eq.$status&order=created_at.desc&limit=50'
      ));
      
      request.headers.set('apikey', SUPABASE_ANON_KEY);
      request.headers.set('Authorization', 'Bearer $SUPABASE_ANON_KEY');
      request.headers.set('Content-Type', 'application/json');
      
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      
      print('  Status Code: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        print('  Response Type: ${data.runtimeType}');
        print('  Count: ${data is List ? data.length : 'Not a list'}');
        
        if (data is List && data.isNotEmpty) {
          final firstItem = data[0];
          print('  First item type: ${firstItem.runtimeType}');
          if (firstItem is Map) {
            print('  Has approval_status: ${firstItem.containsKey('approval_status')}');
            print('  Approval status value: ${firstItem['approval_status']}');
          }
        }
      } else {
        print('  Error response: $responseBody');
      }
      
      client.close();
      print('');
      
    } catch (e, stackTrace) {
      print('  ❌ Error for status $status: $e');
      print('  Stack trace: $stackTrace\n');
    }
  }
}