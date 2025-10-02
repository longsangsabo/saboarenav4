import 'package:supabase_flutter/supabase_flutter.dart';

/// Run migration to add loser_advances_to column to matches table
/// 
/// Usage: dart run add_loser_advances_to_migration.dart
Future<void> main() async {
  print('🚀 Starting migration: Add loser_advances_to column...');
  
  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://mogjjvscxjwvhtpkrlqr.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ',
  );

  final supabase = Supabase.instance.client;

  try {
    // Note: This requires database admin privileges
    // You may need to run this SQL directly in Supabase Dashboard SQL Editor:
    
    print('');
    print('⚠️  MIGRATION SQL:');
    print('═══════════════════════════════════════════════════════════════');
    print('ALTER TABLE matches ADD COLUMN IF NOT EXISTS loser_advances_to INTEGER;');
    print('');
    print('CREATE INDEX IF NOT EXISTS idx_matches_loser_advances_to ');
    print('ON matches(loser_advances_to);');
    print('═══════════════════════════════════════════════════════════════');
    print('');
    print('📋 Please run the above SQL in Supabase Dashboard -> SQL Editor');
    print('');
    
    // Test if column exists by querying
    print('🔍 Testing if column exists...');
    final testResult = await supabase
        .from('matches')
        .select('loser_advances_to')
        .limit(1);
    
    print('✅ Column loser_advances_to exists! Test query successful.');
    print('📊 Result: $testResult');
    
  } catch (e) {
    print('❌ Error: $e');
    print('');
    print('This is expected if the column doesn\'t exist yet.');
    print('Please run the SQL migration in Supabase Dashboard.');
  }
}
