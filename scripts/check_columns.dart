import 'package:supabase/supabase.dart';

Future<void> main() async {
  const supabaseUrl = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
  const serviceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo';

  final supabase = SupabaseClient(supabaseUrl, serviceKey);
  
  try {
    final result = await supabase.from('tournament_participants').select('*').limit(1);
    if (result.isNotEmpty) {
      print('Columns: ${result[0].keys.join(', ')}');
    } else {
      print('No data in tournament_participants');
    }
  } catch (e) {
    print('Error: $e');
  }
}