import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> main() async {
  print('🚀 RUNNING SPA SYSTEM MIGRATION...\n');

  const supabaseUrl = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
  const serviceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo';

  final migrations = [
    // 1. EXTEND MATCHES TABLE
    "ALTER TABLE matches ADD COLUMN IF NOT EXISTS match_type VARCHAR(50) DEFAULT 'tournament'",
    "ALTER TABLE matches ADD COLUMN IF NOT EXISTS invitation_type VARCHAR(50) DEFAULT 'none'",
    "ALTER TABLE matches ADD COLUMN IF NOT EXISTS stakes_type VARCHAR(50) DEFAULT 'none'",
    "ALTER TABLE matches ADD COLUMN IF NOT EXISTS spa_stakes_amount INTEGER DEFAULT 0",
    "ALTER TABLE matches ADD COLUMN IF NOT EXISTS challenger_id UUID",
    "ALTER TABLE matches ADD COLUMN IF NOT EXISTS challenge_message TEXT",
    "ALTER TABLE matches ADD COLUMN IF NOT EXISTS response_message TEXT",
    "ALTER TABLE matches ADD COLUMN IF NOT EXISTS match_conditions JSONB DEFAULT '{}'",
    "ALTER TABLE matches ADD COLUMN IF NOT EXISTS is_public_challenge BOOLEAN DEFAULT false",
    "ALTER TABLE matches ADD COLUMN IF NOT EXISTS expires_at TIMESTAMP WITH TIME ZONE",
    "ALTER TABLE matches ADD COLUMN IF NOT EXISTS accepted_at TIMESTAMP WITH TIME ZONE",
    "ALTER TABLE matches ADD COLUMN IF NOT EXISTS spa_payout_processed BOOLEAN DEFAULT false",
    
    // 2. EXTEND USERS TABLE
    "ALTER TABLE users ADD COLUMN IF NOT EXISTS spa_points INTEGER DEFAULT 1000",
    "ALTER TABLE users ADD COLUMN IF NOT EXISTS spa_points_won INTEGER DEFAULT 0", 
    "ALTER TABLE users ADD COLUMN IF NOT EXISTS spa_points_lost INTEGER DEFAULT 0",
    "ALTER TABLE users ADD COLUMN IF NOT EXISTS challenge_win_streak INTEGER DEFAULT 0",
  ];

  try {
    print('📊 Running ${migrations.length} migration statements...\n');
    
    for (int i = 0; i < migrations.length; i++) {
      final sql = migrations[i];
      print('${i + 1}. ${sql.split('ADD COLUMN IF NOT EXISTS').last.split(' ').first}...');
      
      try {
        final response = await http.post(
          Uri.parse('$supabaseUrl/rest/v1/rpc/exec'),
          headers: {
            'apikey': serviceKey,
            'Authorization': 'Bearer $serviceKey',
            'Content-Type': 'application/json',
            'Prefer': 'return=minimal',
          },
          body: json.encode({'sql': sql}),
        );
        
        if (response.statusCode == 200 || response.statusCode == 204) {
          print('   ✅ Success');
        } else {
          print('   ⚠️ Response: ${response.statusCode} - ${response.body}');
        }
      } catch (e) {
        print('   ❌ Error: $e');
      }
      
      // Small delay to avoid overwhelming the server
      await Future.delayed(Duration(milliseconds: 100));
    }
    
    print('\n💰 Creating spa_transactions table...');
    
    final createTableSQL = '''
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
      final response = await http.post(
        Uri.parse('$supabaseUrl/rest/v1/rpc/exec'),
        headers: {
          'apikey': serviceKey,
          'Authorization': 'Bearer $serviceKey',
          'Content-Type': 'application/json',
          'Prefer': 'return=minimal',
        },
        body: json.encode({'sql': createTableSQL}),
      );
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        print('   ✅ spa_transactions table created');
      } else {
        print('   ⚠️ Table creation response: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('   ❌ Table creation error: $e');
    }
    
    print('\n🎉 MIGRATION ATTEMPT COMPLETE!');
    print('Let me verify if the columns were added...');
    
  } catch (e) {
    print('❌ CRITICAL ERROR: $e');
    exit(1);
  }

  exit(0);
}