import 'dart:convert';
import 'dart:io';

const String SUPABASE_URL = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
const String SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ';

Future<void> main() async {
  print('🔍 Debugging admin clubs query...\n');
  
  try {
    // Test the exact query from admin service
    final client = HttpClient();
    final request = await client.getUrl(Uri.parse(
      '$SUPABASE_URL/rest/v1/clubs?select=*,owner:users!clubs_owner_id_fkey(id,display_name,email,avatar_url,phone)&approval_status=eq.pending&order=created_at.desc&limit=50'
    ));
    
    request.headers.set('apikey', SUPABASE_ANON_KEY);
    request.headers.set('Authorization', 'Bearer $SUPABASE_ANON_KEY');
    request.headers.set('Content-Type', 'application/json');
    
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    print('Response Status: ${response.statusCode}');
    print('Response Body: $responseBody\n');
    
    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody);
      print('Data type: ${data.runtimeType}');
      
      if (data is List) {
        print('Number of clubs: ${data.length}');
        if (data.isNotEmpty) {
          print('First club structure:');
          final firstClub = data[0];
          print('Club type: ${firstClub.runtimeType}');
          if (firstClub is Map) {
            print('Club keys: ${firstClub.keys.toList()}');
            print('Owner data type: ${firstClub['owner']?.runtimeType}');
            print('Owner content: ${firstClub['owner']}');
          }
        }
      }
    } else {
      print('❌ Query failed with status ${response.statusCode}');
    }
    
    client.close();
    
  } catch (e, stackTrace) {
    print('❌ Error: $e');
    print('Stack trace: $stackTrace');
  }
  
  // Also check if the clubs table has the required columns
  print('\n🔍 Checking clubs table structure...');
  try {
    final client = HttpClient();
    final request = await client.getUrl(Uri.parse(
      '$SUPABASE_URL/rest/v1/clubs?select=*&limit=1'
    ));
    
    request.headers.set('apikey', SUPABASE_ANON_KEY);
    request.headers.set('Authorization', 'Bearer $SUPABASE_ANON_KEY');
    request.headers.set('Content-Type', 'application/json');
    
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody);
      if (data is List && data.isNotEmpty) {
        final sample = data[0] as Map<String, dynamic>;
        print('Available columns in clubs table:');
        sample.keys.forEach((key) {
          print('  - $key: ${sample[key]?.runtimeType}');
        });
      }
    }
    
    client.close();
  } catch (e) {
    print('❌ Error checking table structure: $e');
  }
}