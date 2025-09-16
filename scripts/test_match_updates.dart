import 'dart:io';
import 'package:supabase/supabase.dart';

Future<void> main() async {
  print('🔍 CHECKING DATABASE STRUCTURE...\n');

  const supabaseUrl = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
  const serviceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo';

  try {
    final supabase = SupabaseClient(supabaseUrl, serviceKey);
    
    print('1. Checking if we can read matches table directly...');
    
    final simpleQuery = await supabase
        .from('matches')
        .select('id, status')
        .limit(1);
    
    print('   ✅ Can read matches: ${simpleQuery.length} rows');
    
    print('\n2. Try simple update on one match...');
    
    // Just try to update status only
    await supabase
        .from('matches')
        .update({'status': 'completed'})
        .eq('id', '277e68fa-daf7-4f3d-91fd-cd23a06c9603');
    
    print('   ✅ Status update worked!');
    
    print('\n3. Try adding score fields...');
    
    await supabase
        .from('matches')
        .update({
          'status': 'completed',
          'player1_score': 7
        })
        .eq('id', '277e68fa-daf7-4f3d-91fd-cd23a06c9603');
    
    print('   ✅ Score field update worked!');
    
    print('\n4. Try adding winner_id...');
    
    await supabase
        .from('matches')
        .update({
          'status': 'completed',
          'player1_score': 7,
          'player2_score': 4,
          'winner_id': 'ca23e628-d2bb-4174-b4b8-d1cc2ff8335f'
        })
        .eq('id', '277e68fa-daf7-4f3d-91fd-cd23a06c9603');
    
    print('   ✅ Winner ID update worked!');
    
    print('\n🎯 All updates successful! No user_profiles issue with direct updates.');
    
  } catch (e) {
    print('❌ ERROR at step: $e');
    
    // Try to identify where the error happens
    if (e.toString().contains('user_profiles')) {
      print('\n🔍 The user_profiles error happens when updating matches.');
      print('   This suggests there\'s a trigger or RLS policy referencing user_profiles.');
      print('   Let\'s check the matches table schema...');
    }
  }

  exit(0);
}