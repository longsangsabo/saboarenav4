import 'dart:io';
import 'dart:convert';

void main() async {
  print('🧪 TESTING TOURNAMENT CREATION WITHOUT SKILL LEVEL...\n');
  
  const supabaseUrl = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
  const serviceRoleKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo';
  
  final client = HttpClient();
  
  try {
    print('🧪 TESTING: Creating tournament without skill_level_required...');
    
    final testData = {
      'title': 'Test Tournament No Skill Level ${DateTime.now().millisecondsSinceEpoch}',
      'description': 'Testing tournament creation without skill level requirement',
      'start_date': '2025-01-01T00:00:00Z',
      'end_date': '2025-01-02T00:00:00Z',
      'registration_deadline': '2024-12-31T00:00:00Z',
      'prize_pool': 1000000,
      'max_participants': 16,
      'format': 'single_elimination',
      'status': 'upcoming',
      'entry_fee': 50000,
      'current_participants': 0,
      // No skill_level_required field
    };

    final createRequest = await client.postUrl(Uri.parse('$supabaseUrl/rest/v1/tournaments'));
    createRequest.headers.set('Authorization', 'Bearer $serviceRoleKey');
    createRequest.headers.set('apikey', serviceRoleKey);
    createRequest.headers.set('Content-Type', 'application/json');
    createRequest.headers.set('Prefer', 'return=representation');
    
    createRequest.write(json.encode(testData));
    
    final createResponse = await createRequest.close();
    final createBody = await createResponse.transform(utf8.decoder).join();
    
    if (createResponse.statusCode == 201) {
      print('🎉 ✅ SUCCESS: Tournament created without skill level!');
      final tournament = json.decode(createBody)[0];
      print('Tournament ID: ${tournament['id']}');
      print('Title: ${tournament['title']}');
      print('Skill Level Required: ${tournament['skill_level_required']} (should be null)');
      print('\n✅ SOLUTION WORKED: No more skill level constraint errors!');
    } else {
      print('❌ Failed: ${createResponse.statusCode}');
      print('Error details: $createBody');
    }
    
  } catch (e) {
    print('❌ Error: $e');
  } finally {
    client.close();
  }
}