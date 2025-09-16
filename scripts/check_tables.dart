import 'dart:io';
import 'package:supabase/supabase.dart';

Future<void> main() async {
  print('🔍 KIỂM TRA TABLES...\n');

  const supabaseUrl = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
  const serviceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo';

  try {
    final supabase = SupabaseClient(supabaseUrl, serviceKey);
    
    final tables = ['post_likes', 'comments', 'user_follows', 'notifications', 'user_achievements', 'achievements'];
    
    for (var table in tables) {
      try {
        final result = await supabase.from(table).select('count').limit(1);
        print('✅ Table $table exists');
      } catch (e) {
        print('❌ Table $table missing: $e');
      }
    }
    
  } catch (e) {
    print('❌ ERROR: $e');
    exit(1);
  }

  exit(0);
}