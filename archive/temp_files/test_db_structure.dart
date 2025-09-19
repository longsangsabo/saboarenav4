import 'dart:io';
import 'dart:convert';

void main() async {
  print('🔍 CHECKING CURRENT DATABASE STRUCTURE...\n');
  
  const supabaseUrl = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
  const serviceRoleKey = 'sb_secret_07Grp_TTwr21BjtBKc_gtw_5qx7UPFE';
  
  final client = HttpClient();
  
  try {
    // Check current tournaments table structure by getting all column names
    print('1. TOURNAMENTS TABLE STRUCTURE:');
    final tournamentsRequest = await client.getUrl(Uri.parse(
        '$supabaseUrl/rest/v1/tournaments?limit=1'));
    tournamentsRequest.headers.set('Authorization', 'Bearer $serviceRoleKey');
    tournamentsRequest.headers.set('apikey', serviceRoleKey);
    
    final tournamentsResponse = await tournamentsRequest.close();
    final tournamentsBody = await tournamentsResponse.transform(utf8.decoder).join();
    
    if (tournamentsResponse.statusCode == 200) {
      final List<dynamic> tournaments = json.decode(tournamentsBody);
      if (tournaments.isNotEmpty) {
        print('Tournament columns: ${tournaments[0].keys.toList()}');
        print('Sample tournament data: ${tournaments[0]}');
      } else {
        print('No tournaments found');
      }
    } else {
      print('❌ Error: ${tournamentsResponse.statusCode} - $tournamentsBody');
    }
    
    print('\n2. USERS TABLE STRUCTURE:');
    final usersRequest = await client.getUrl(Uri.parse(
        '$supabaseUrl/rest/v1/users?limit=1'));
    usersRequest.headers.set('Authorization', 'Bearer $serviceRoleKey');
    usersRequest.headers.set('apikey', serviceRoleKey);
    
    final usersResponse = await usersRequest.close();
    final usersBody = await usersResponse.transform(utf8.decoder).join();
    
    if (usersResponse.statusCode == 200) {
      final List<dynamic> users = json.decode(usersBody);
      if (users.isNotEmpty) {
        print('User columns: ${users[0].keys.toList()}');
        print('Sample user data: ${users[0]}');
      } else {
        print('No users found');
      }
    } else {
      print('❌ Error: ${usersResponse.statusCode} - $usersBody');
    }

    print('\n3. TESTING TOURNAMENT CREATION WITH VIETNAMESE RANK:');
    // Try to create a test tournament with Vietnamese rank
    final testTournamentData = {
      'title': 'Test Vietnamese Rank Tournament',
      'description': 'Testing Vietnamese ranking system',
      'skill_level_required': 'K',  // Vietnamese rank
      'start_date': '2025-01-01T00:00:00Z',
      'end_date': '2025-01-02T00:00:00Z',
      'prize_pool': 1000000,
      'max_participants': 16,
      'tournament_format': 'single_elimination',
      'status': 'draft'
    };

    final createRequest = await client.postUrl(Uri.parse(
        '$supabaseUrl/rest/v1/tournaments'));
    createRequest.headers.set('Authorization', 'Bearer $serviceRoleKey');
    createRequest.headers.set('apikey', serviceRoleKey);
    createRequest.headers.set('Content-Type', 'application/json');
    createRequest.headers.set('Prefer', 'return=representation');
    
    createRequest.write(json.encode(testTournamentData));
    
    final createResponse = await createRequest.close();
    final createBody = await createResponse.transform(utf8.decoder).join();
    
    if (createResponse.statusCode == 201) {
      print('✅ SUCCESS: Tournament created with Vietnamese rank "K"');
      print('Created tournament: $createBody');
    } else {
      print('❌ FAILED: ${createResponse.statusCode} - $createBody');
      print('This confirms we need to run the migration script');
    }
    
  } catch (e) {
    print('❌ Error: $e');
  } finally {
    client.close();
  }
}