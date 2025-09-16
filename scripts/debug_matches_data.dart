import 'dart:io';
import 'package:supabase/supabase.dart';

Future<void> main() async {
  print('🔍 DEBUG MATCHES DATA...\n');

  const supabaseUrl = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
  const serviceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo';

  try {
    final supabase = SupabaseClient(supabaseUrl, serviceKey);
    
    print('1. Matches data:');
    final matches = await supabase.from('matches').select('id, player1_id, player2_id, status').limit(2);
    for (var match in matches) {
      print('   - Match ${match['id']}: ${match['player1_id']} vs ${match['player2_id']} (${match['status']})');
    }
    
    print('\n2. Users data:');
    final users = await supabase.from('users').select('id, display_name').limit(3);
    for (var user in users) {
      print('   - User ${user['id']}: ${user['display_name']}');
    }
    
  } catch (e) {
    print('❌ ERROR: $e');
    exit(1);
  }

  exit(0);
}