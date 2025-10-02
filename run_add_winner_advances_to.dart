import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  print('🚀 Starting migration to add winner_advances_to column...');
  
  try {
    // Initialize Supabase
    await Supabase.initialize(
      url: 'https://mogjjvscxjwvhtpkrlqr.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo',
    );
    
    final supabase = Supabase.instance.client;
    print('✅ Supabase initialized');
    
    // Step 1: Add winner_advances_to column
    print('\n📝 Step 1: Adding winner_advances_to column...');
    await supabase.rpc('exec_sql', params: {
      'sql': 'ALTER TABLE matches ADD COLUMN IF NOT EXISTS winner_advances_to INTEGER;'
    });
    print('✅ Column added successfully');
    
    // Step 2: Create index
    print('\n📝 Step 2: Creating index on winner_advances_to...');
    await supabase.rpc('exec_sql', params: {
      'sql': 'CREATE INDEX IF NOT EXISTS idx_matches_winner_advances_to ON matches(winner_advances_to);'
    });
    print('✅ Index created successfully');
    
    // Step 3: Verify
    print('\n📝 Step 3: Verifying column exists...');
    final result = await supabase.rpc('exec_sql', params: {
      'sql': '''
        SELECT column_name, data_type 
        FROM information_schema.columns 
        WHERE table_name = 'matches' 
        AND column_name = 'winner_advances_to';
      '''
    });
    print('✅ Verification result: $result');
    
    print('\n✅ Migration completed successfully!');
    print('🎯 Now you can delete old matches and create new bracket with hardcoded advancement.');
    
  } catch (e, stackTrace) {
    print('❌ Migration failed: $e');
    print('Stack trace: $stackTrace');
  }
}
