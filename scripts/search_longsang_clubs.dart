import 'dart:convert';
import 'dart:io';

const String SUPABASE_URL = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
const String SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ';

Future<void> main() async {
  print('🔍 Searching for clubs related to longsang063@gmail.com...\n');
  
  try {
    final client = HttpClient();
    
    // Search all clubs that might be related to this email
    print('1. Searching all clubs for potential matches...');
    final allClubsRequest = await client.getUrl(Uri.parse(
      '$SUPABASE_URL/rest/v1/clubs?select=*,owner:users!clubs_owner_id_fkey(id,email,display_name)&order=created_at.desc'
    ));
    
    allClubsRequest.headers.set('apikey', SUPABASE_ANON_KEY);
    allClubsRequest.headers.set('Authorization', 'Bearer $SUPABASE_ANON_KEY');
    allClubsRequest.headers.set('Content-Type', 'application/json');
    
    final allClubsResponse = await allClubsRequest.close();
    final allClubsBody = await allClubsResponse.transform(utf8.decoder).join();
    
    print('All clubs response: ${allClubsResponse.statusCode}');
    
    if (allClubsResponse.statusCode == 200) {
      final allClubsData = jsonDecode(allClubsBody) as List;
      print('Found ${allClubsData.length} total clubs:');
      
      for (var club in allClubsData) {
        final owner = club['owner'];
        final ownerEmail = owner?['email'] ?? 'No email';
        print('  - Club: ${club['name']}');
        print('    ID: ${club['id']}');
        print('    Owner ID: ${club['owner_id']}');
        print('    Owner Email: $ownerEmail');
        print('    Status: ${club['approval_status']}');
        print('    Active: ${club['is_active']}');
        print('    Created: ${club['created_at']}');
        
        if (ownerEmail.contains('longsang063')) {
          print('    ✅ MATCH FOUND! This club belongs to longsang063@gmail.com');
        }
        print('');
      }
      
      // Look for any club that might be associated with longsang063
      final matchingClubs = allClubsData.where((club) {
        final owner = club['owner'];
        final ownerEmail = owner?['email'] ?? '';
        return ownerEmail.contains('longsang063') || 
               club['name'].toString().toLowerCase().contains('longsang') ||
               club['description'].toString().toLowerCase().contains('longsang');
      }).toList();
      
      if (matchingClubs.isNotEmpty) {
        print('✅ Found ${matchingClubs.length} potential matches for longsang063:');
        for (var club in matchingClubs) {
          print('  - ${club['name']} (${club['approval_status']})');
        }
      } else {
        print('❌ No clubs found matching longsang063');
      }
    }
    
    client.close();
    
    // Also check if there are any recent club registrations
    print('\n2. Checking recent club registrations...');
    final recentClient = HttpClient();
    
    final recentRequest = await recentClient.getUrl(Uri.parse(
      '$SUPABASE_URL/rest/v1/clubs?select=*,owner:users!clubs_owner_id_fkey(id,email,display_name)&order=created_at.desc&limit=10'
    ));
    
    recentRequest.headers.set('apikey', SUPABASE_ANON_KEY);
    recentRequest.headers.set('Authorization', 'Bearer $SUPABASE_ANON_KEY');
    recentRequest.headers.set('Content-Type', 'application/json');
    
    final recentResponse = await recentRequest.close();
    final recentBody = await recentResponse.transform(utf8.decoder).join();
    
    if (recentResponse.statusCode == 200) {
      final recentData = jsonDecode(recentBody) as List;
      print('Most recent ${recentData.length} clubs:');
      
      for (var club in recentData) {
        final owner = club['owner'];
        final ownerEmail = owner?['email'] ?? 'No email';
        print('  - ${club['name']} by $ownerEmail (${club['approval_status']}) - ${club['created_at']}');
      }
    }
    
    recentClient.close();
    
  } catch (e, stackTrace) {
    print('❌ Error: $e');
    print('Stack trace: $stackTrace');
  }
}