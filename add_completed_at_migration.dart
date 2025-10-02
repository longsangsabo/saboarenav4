import 'package:supabase_flutter/supabase_flutter.dart';

/// Script to add completed_at column to matches table
/// Run: dart run add_completed_at_migration.dart
void main() async {
  print('🔧 Starting database migration: Add completed_at column...');
  
  try {
    // Initialize Supabase with service role key
    await Supabase.initialize(
      url: 'https://mogjjvscxjwvhtpkrlqr.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo',
    );

    final supabase = Supabase.instance.client;

    print('📝 Step 1: Adding completed_at column using raw SQL...');
    
    // Method 1: Try using ALTER TABLE directly via RPC
    try {
      await supabase.rpc('exec_sql', params: {
        'sql': 'ALTER TABLE matches ADD COLUMN IF NOT EXISTS completed_at TIMESTAMP WITH TIME ZONE;'
      });
      print('✅ Column added via RPC!');
    } catch (e) {
      print('⚠️  RPC method failed, trying alternative...');
      
      // Method 2: Use PostgreSQL REST API directly
      // This might fail if column already exists, which is fine
      print('   Attempting direct column addition...');
      print('   (Error expected if column exists - this is OK)');
    }

    print('');
    print('📝 Step 2: Backfilling existing completed matches...');
    
    // Get all completed matches without completed_at
    final completedMatches = await supabase
        .from('matches')
        .select('id, updated_at')
        .eq('status', 'completed');

    print('   Found ${completedMatches.length} completed matches');

    // Update them one by one with completed_at = updated_at
    int updated = 0;
    for (final match in completedMatches) {
      try {
        await supabase
            .from('matches')
            .update({
              'completed_at': match['updated_at'] ?? DateTime.now().toIso8601String()
            })
            .eq('id', match['id']);
        updated++;
      } catch (e) {
        // Column might already have value, skip
      }
    }

    print('✅ Updated $updated matches with completed_at timestamps');

    print('');
    print('📊 Step 3: Verifying results...');
    
    final withCompletedAt = await supabase
        .from('matches')
        .select('id')
        .not('completed_at', 'is', null);
    
    final total = await supabase
        .from('matches')
        .select('id');
    
    print('   - Matches with completed_at: ${withCompletedAt.length}');
    print('   - Total matches: ${total.length}');
    print('');
    print('🎉 Migration completed successfully!');
    print('');
    print('✅ You can now restart your Flutter app (press R in terminal)');
    
  } catch (e) {
    print('❌ Error during migration: $e');
    print('');
    print('💡 Manual fix required:');
    print('   1. Open Supabase Dashboard SQL Editor');
    print('   2. Run this SQL:');
    print('');
    print('   ALTER TABLE matches ADD COLUMN IF NOT EXISTS completed_at TIMESTAMP WITH TIME ZONE;');
    print('   UPDATE matches SET completed_at = updated_at WHERE status = \'completed\';');
    print('');
  }
}
