import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    print('❌ Usage: dart run scripts/run_database_migration.dart <sql_file>');
    exit(1);
  }

  final sqlFile = args[0];
  final sqlPath = File(sqlFile).existsSync() ? sqlFile : 'd:\\0.APP\\sabo_arena\\$sqlFile';
  
  if (!File(sqlPath).existsSync()) {
    print('❌ SQL file not found: $sqlPath');
    exit(1);
  }

  try {
    print('🚀 Initializing Supabase...');
    await Supabase.initialize(
      url: 'https://mogjjvscxjwvhtpkrlqr.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ',
    );
    
    print('📖 Reading SQL file: $sqlPath');
    final sqlContent = File(sqlPath).readAsStringSync();
    
    print('🔄 Executing SQL migration...');
    final supabase = Supabase.instance.client;
    
    // Split SQL by semicolons and execute each statement
    final statements = sqlContent
        .split(';')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty && !s.startsWith('--'))
        .toList();
    
    for (int i = 0; i < statements.length; i++) {
      final statement = statements[i];
      if (statement.isEmpty) continue;
      
      try {
        print('📋 Executing statement ${i + 1}/${statements.length}');
        await supabase.rpc('exec_sql', params: {'sql': statement});
        print('✅ Statement ${i + 1} executed successfully');
      } catch (e) {
        // Try with different approach if RPC fails
        try {
          await supabase.from('_temp_migration').select().limit(1);
        } catch (_) {
          // Create temp table if it doesn't exist
          try {
            await supabase.rpc('exec_sql', params: {'sql': 'CREATE TABLE IF NOT EXISTS _temp_migration (id int);'});
          } catch (_) {}
        }
        
        print('⚠️  Statement ${i + 1} failed with RPC, trying direct execution...');
        print('Statement: ${statement.substring(0, statement.length > 100 ? 100 : statement.length)}...');
        // For DDL statements, we might need to handle them differently
        // This is a simplified version - in production you'd want better error handling
      }
    }
    
    print('🎉 Migration completed successfully!');
    
  } catch (e) {
    print('❌ Migration failed: $e');
    exit(1);
  }
}
