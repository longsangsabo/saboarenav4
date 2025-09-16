import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://mogjjvscxjwvhtpkrlqr.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo'
  );
  
  try {
    final user = await supabase.from('users').select('elo_rating, ranking_points, email').eq('email', 'longsang063@gmail.com').single();
    print('Database fields for longsang063:');
    print('elo_rating: ${user['elo_rating']}');
    print('ranking_points: ${user['ranking_points']}');
  } catch (e) {
    print('Error: $e');
  }
}