import 'dart:io';
import 'package:supabase/supabase.dart';

Future<void> main() async {
  print('🔍 KIỂM TRA COLUMNS CỦA TOURNAMENT_PARTICIPANTS...\n');

  const supabaseUrl = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
  const serviceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo';

  try {
    final supabase = SupabaseClient(supabaseUrl, serviceKey);
    
    final result = await supabase
        .from('tournament_participants')
        .select('*')
        .limit(1);
    
    if (result.isNotEmpty) {
      print('✅ Columns tìm thấy:');
      final columns = result[0].keys.toList();
      for (var column in columns) {
        print('   - $column');
      }
    } else {
      print('❌ Không có data trong tournament_participants');
    }
    
  } catch (e) {
    print('❌ ERROR: $e');
    exit(1);
  }

  exit(0);
}