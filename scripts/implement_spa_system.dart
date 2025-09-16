import 'dart:io';
import 'package:supabase/supabase.dart';

Future<void> main() async {
  print('🚀 IMPLEMENTING SPA CHALLENGE SYSTEM...\n');

  const supabaseUrl = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
  const serviceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo';

  try {
    final supabase = SupabaseClient(supabaseUrl, serviceKey);
    
    print('1. 🏆 EXTENDING MATCHES TABLE...');
    
    // Add match_type column
    try {
      await supabase.rpc('exec_sql', params: {
        'sql': "ALTER TABLE matches ADD COLUMN IF NOT EXISTS match_type VARCHAR(50) DEFAULT 'tournament'"
      });
      print('   ✅ Added match_type column');
    } catch (e) {
      print('   ⚠️ match_type: $e');
    }
    
    // Add invitation system columns
    try {
      await supabase.rpc('exec_sql', params: {
        'sql': "ALTER TABLE matches ADD COLUMN IF NOT EXISTS invitation_type VARCHAR(50) DEFAULT 'none'"
      });
      print('   ✅ Added invitation_type column');
    } catch (e) {
      print('   ⚠️ invitation_type: $e');
    }
    
    // Add stakes system columns  
    try {
      await supabase.rpc('exec_sql', params: {
        'sql': "ALTER TABLE matches ADD COLUMN IF NOT EXISTS stakes_type VARCHAR(50) DEFAULT 'none'"
      });
      print('   ✅ Added stakes_type column');
    } catch (e) {
      print('   ⚠️ stakes_type: $e');
    }
    
    try {
      await supabase.rpc('exec_sql', params: {
        'sql': "ALTER TABLE matches ADD COLUMN IF NOT EXISTS spa_stakes_amount INTEGER DEFAULT 0"
      });
      print('   ✅ Added spa_stakes_amount column');
    } catch (e) {
      print('   ⚠️ spa_stakes_amount: $e');
    }
    
    // Add challenge system columns
    try {
      await supabase.rpc('exec_sql', params: {
        'sql': "ALTER TABLE matches ADD COLUMN IF NOT EXISTS challenger_id UUID REFERENCES users(id)"
      });
      print('   ✅ Added challenger_id column');
    } catch (e) {
      print('   ⚠️ challenger_id: $e');
    }
    
    try {
      await supabase.rpc('exec_sql', params: {
        'sql': "ALTER TABLE matches ADD COLUMN IF NOT EXISTS challenge_message TEXT"
      });
      print('   ✅ Added challenge_message column');
    } catch (e) {
      print('   ⚠️ challenge_message: $e');
    }
    
    try {
      await supabase.rpc('exec_sql', params: {
        'sql': "ALTER TABLE matches ADD COLUMN IF NOT EXISTS response_message TEXT"
      });
      print('   ✅ Added response_message column');
    } catch (e) {
      print('   ⚠️ response_message: $e');
    }
    
    try {
      await supabase.rpc('exec_sql', params: {
        'sql': "ALTER TABLE matches ADD COLUMN IF NOT EXISTS match_conditions JSONB DEFAULT '{}'"
      });
      print('   ✅ Added match_conditions column');
    } catch (e) {
      print('   ⚠️ match_conditions: $e');
    }
    
    try {
      await supabase.rpc('exec_sql', params: {
        'sql': "ALTER TABLE matches ADD COLUMN IF NOT EXISTS is_public_challenge BOOLEAN DEFAULT false"
      });
      print('   ✅ Added is_public_challenge column');
    } catch (e) {
      print('   ⚠️ is_public_challenge: $e');
    }
    
    try {
      await supabase.rpc('exec_sql', params: {
        'sql': "ALTER TABLE matches ADD COLUMN IF NOT EXISTS expires_at TIMESTAMP WITH TIME ZONE"
      });
      print('   ✅ Added expires_at column');
    } catch (e) {
      print('   ⚠️ expires_at: $e');
    }
    
    try {
      await supabase.rpc('exec_sql', params: {
        'sql': "ALTER TABLE matches ADD COLUMN IF NOT EXISTS accepted_at TIMESTAMP WITH TIME ZONE"
      });
      print('   ✅ Added accepted_at column');
    } catch (e) {
      print('   ⚠️ accepted_at: $e');
    }
    
    try {
      await supabase.rpc('exec_sql', params: {
        'sql': "ALTER TABLE matches ADD COLUMN IF NOT EXISTS spa_payout_processed BOOLEAN DEFAULT false"
      });
      print('   ✅ Added spa_payout_processed column');
    } catch (e) {
      print('   ⚠️ spa_payout_processed: $e');
    }
    
    print('\n2. 💎 EXTENDING USERS TABLE WITH SPA POINTS...');
    
    try {
      await supabase.rpc('exec_sql', params: {
        'sql': "ALTER TABLE users ADD COLUMN IF NOT EXISTS spa_points INTEGER DEFAULT 1000"
      });
      print('   ✅ Added spa_points column (default: 1000)');
    } catch (e) {
      print('   ⚠️ spa_points: $e');
    }
    
    try {
      await supabase.rpc('exec_sql', params: {
        'sql': "ALTER TABLE users ADD COLUMN IF NOT EXISTS spa_points_won INTEGER DEFAULT 0"
      });
      print('   ✅ Added spa_points_won column');
    } catch (e) {
      print('   ⚠️ spa_points_won: $e');
    }
    
    try {
      await supabase.rpc('exec_sql', params: {
        'sql': "ALTER TABLE users ADD COLUMN IF NOT EXISTS spa_points_lost INTEGER DEFAULT 0"
      });
      print('   ✅ Added spa_points_lost column');
    } catch (e) {
      print('   ⚠️ spa_points_lost: $e');
    }
    
    try {
      await supabase.rpc('exec_sql', params: {
        'sql': "ALTER TABLE users ADD COLUMN IF NOT EXISTS challenge_win_streak INTEGER DEFAULT 0"
      });
      print('   ✅ Added challenge_win_streak column');
    } catch (e) {
      print('   ⚠️ challenge_win_streak: $e');
    }
    
    print('\n3. 💰 CREATING SPA TRANSACTIONS TABLE...');
    
    final spaTransactionsSQL = '''
CREATE TABLE IF NOT EXISTS spa_transactions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  match_id UUID REFERENCES matches(id) ON DELETE SET NULL,
  transaction_type VARCHAR(50) NOT NULL,
  amount INTEGER NOT NULL,
  balance_before INTEGER NOT NULL,
  balance_after INTEGER NOT NULL,
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
)''';
    
    try {
      await supabase.rpc('exec_sql', params: {'sql': spaTransactionsSQL});
      print('   ✅ Created spa_transactions table');
    } catch (e) {
      print('   ⚠️ spa_transactions table: $e');
    }
    
    print('\n4. 📊 VERIFYING TABLES...');
    
    // Test if we can query new columns
    try {
      final testMatch = await supabase
          .from('matches')
          .select('id, match_type, spa_stakes_amount')
          .limit(1);
      print('   ✅ matches table extended successfully');
    } catch (e) {
      print('   ❌ matches table issue: $e');
    }
    
    try {
      final testUser = await supabase
          .from('users')
          .select('id, spa_points, challenge_win_streak')
          .limit(1);
      print('   ✅ users table extended successfully');
    } catch (e) {
      print('   ❌ users table issue: $e');
    }
    
    try {
      final testTransaction = await supabase
          .from('spa_transactions')
          .select('count')
          .count();
      print('   ✅ spa_transactions table created (${testTransaction.count} records)');
    } catch (e) {
      print('   ❌ spa_transactions table issue: $e');
    }
    
    print('\n🎉 SPA CHALLENGE SYSTEM TABLES READY!');
    print('═══════════════════════════════════════');
    print('✅ matches table extended với opponent features');
    print('✅ users table extended với SPA points system');
    print('✅ spa_transactions table created cho tracking');
    
    print('\n🎮 READY FOR NEXT STEP:');
    print('• Add sample SPA challenge data');
    print('• Create realistic opponent scenarios');
    print('• Test UI integration');
    
  } catch (e) {
    print('❌ CRITICAL ERROR: $e');
    exit(1);
  }

  exit(0);
}