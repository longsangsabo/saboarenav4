import 'dart:io';
import 'package:supabase/supabase.dart';

Future<void> main() async {
  print('🎯 OPTIMIZED DESIGN - EXTEND MATCHES TABLE...\n');

  const supabaseUrl = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
  const serviceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo';

  try {
    final supabase = SupabaseClient(supabaseUrl, serviceKey);
    
    print('🔍 1. CURRENT MATCHES TABLE STRUCTURE:');
    
    // Check current matches table
    final existingMatches = await supabase
        .from('matches')
        .select('*')
        .limit(1);
    
    if (existingMatches.isNotEmpty) {
      final match = existingMatches.first;
      print('   Current columns:');
      match.keys.forEach((key) {
        print('   • $key: ${match[key]?.runtimeType ?? 'null'}');
      });
    }
    
    print('\n🚀 2. ENHANCED MATCHES TABLE DESIGN:');
    print('═══════════════════════════════════════');
    
    final enhancedMatchesSchema = '''
-- EXTEND MATCHES TABLE FOR OPPONENT TAB
ALTER TABLE matches ADD COLUMN IF NOT EXISTS match_type VARCHAR(50) DEFAULT 'tournament';
-- Values: tournament, friendly, challenge, ranked, practice, betting

ALTER TABLE matches ADD COLUMN IF NOT EXISTS match_subtype VARCHAR(50) DEFAULT 'standard';
-- Values: standard, quick_match, custom_rules, high_stakes

ALTER TABLE matches ADD COLUMN IF NOT EXISTS invitation_type VARCHAR(50) DEFAULT 'none';
-- Values: none, sent, received, public_room, auto_matched

ALTER TABLE matches ADD COLUMN IF NOT EXISTS stakes_type VARCHAR(50) DEFAULT 'none';
-- Values: none, points, money, virtual_currency, custom

ALTER TABLE matches ADD COLUMN IF NOT EXISTS stakes_amount INTEGER DEFAULT 0;
ALTER TABLE matches ADD COLUMN IF NOT EXISTS stakes_currency VARCHAR(10) DEFAULT 'VND';
ALTER TABLE matches ADD COLUMN IF NOT EXISTS stakes_description TEXT;

ALTER TABLE matches ADD COLUMN IF NOT EXISTS challenger_id UUID REFERENCES users(id);
-- Who initiated the challenge/invitation (could be different from player1)

ALTER TABLE matches ADD COLUMN IF NOT EXISTS match_conditions JSONB DEFAULT '{}';
-- Custom rules, time limits, special conditions

ALTER TABLE matches ADD COLUMN IF NOT EXISTS invitation_message TEXT;
ALTER TABLE matches ADD COLUMN IF NOT EXISTS response_message TEXT;

ALTER TABLE matches ADD COLUMN IF NOT EXISTS location_type VARCHAR(50) DEFAULT 'online';
-- Values: online, venue, home, public_hall

ALTER TABLE matches ADD COLUMN IF NOT EXISTS venue_address TEXT;
ALTER TABLE matches ADD COLUMN IF NOT EXISTS scheduled_time TIMESTAMP WITH TIME ZONE;

ALTER TABLE matches ADD COLUMN IF NOT EXISTS is_public BOOLEAN DEFAULT false;
-- Can others join/spectate?

ALTER TABLE matches ADD COLUMN IF NOT EXISTS max_spectators INTEGER DEFAULT 0;

ALTER TABLE matches ADD COLUMN IF NOT EXISTS bet_odds_player1 DECIMAL(5,2) DEFAULT 1.0;
ALTER TABLE matches ADD COLUMN IF NOT EXISTS bet_odds_player2 DECIMAL(5,2) DEFAULT 1.0;

ALTER TABLE matches ADD COLUMN IF NOT EXISTS match_finder_request_id UUID;
-- Link to how this match was found/created

ALTER TABLE matches ADD COLUMN IF NOT EXISTS expires_at TIMESTAMP WITH TIME ZONE;
-- For pending invitations/challenges
''';
    
    print(enhancedMatchesSchema);
    
    print('\n📊 3. MINIMAL ADDITIONAL TABLES (Only 2!):');
    print('═══════════════════════════════════════════');
    
    print('\n📋 A) MATCH_BETS TABLE - For betting system:');
    final betsTableSchema = '''
CREATE TABLE IF NOT EXISTS match_bets (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  match_id UUID REFERENCES matches(id) ON DELETE CASCADE,
  bettor_id UUID REFERENCES users(id) ON DELETE CASCADE,
  bet_amount DECIMAL(10,2) DEFAULT 0,
  predicted_winner_id UUID REFERENCES users(id),
  odds DECIMAL(5,2) DEFAULT 1.0,
  potential_payout DECIMAL(10,2),
  status VARCHAR(50) DEFAULT 'pending',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);''';
    print(betsTableSchema);
    
    print('\n📋 B) PLAYER_PREFERENCES TABLE - User settings:');
    final preferencesTableSchema = '''
CREATE TABLE IF NOT EXISTS player_preferences (
  user_id UUID REFERENCES users(id) ON DELETE CASCADE PRIMARY KEY,
  auto_accept_friends BOOLEAN DEFAULT false,
  accept_challenges_from VARCHAR(50) DEFAULT 'friends',
  max_stakes_willing INTEGER DEFAULT 100000,
  preferred_game_formats TEXT[] DEFAULT ARRAY['8ball'],
  availability_schedule JSONB DEFAULT '{}',
  notification_preferences JSONB DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);''';
    print(preferencesTableSchema);
    
    print('\n🎯 4. MATCH_TYPE EXAMPLES:');
    print('═══════════════════════════');
    print('• tournament + standard = Regular tournament match');
    print('• friendly + quick_match = Quick casual game');
    print('• challenge + high_stakes = Challenge with stakes');
    print('• ranked + standard = Competitive ranking match');
    print('• betting + custom_rules = Betting match với rules đặc biệt');
    print('• practice + standard = Practice match');
    
    print('\n📱 5. UI FEATURES ENABLED:');
    print('═══════════════════════════');
    print('✅ Thách đấu (match_type: challenge)');
    print('✅ Giao lưu (match_type: friendly)');
    print('✅ Cược đặt (match_type: betting + match_bets table)');
    print('✅ Tìm đối thủ (invitation_type: auto_matched)');
    print('✅ Lời mời đấu (invitation_type: sent/received)');
    print('✅ Phòng công khai (is_public: true)');
    print('✅ Custom rules (match_conditions JSONB)');
    print('✅ Stakes system (stakes_type, amount, description)');
    
    print('\n💡 6. BENEFITS OF THIS APPROACH:');
    print('═══════════════════════════════════');
    print('✅ Tái sử dụng matches table hiện có');
    print('✅ Chỉ cần 2 tables bổ sung thay vì 6');
    print('✅ Unified match history cho tất cả types');
    print('✅ Easier querying và statistics');
    print('✅ Consistent data structure');
    print('✅ Less database overhead');
    
    print('\n🚀 READY TO IMPLEMENT?');
    print('This approach is much cleaner và efficient!');
    
  } catch (e) {
    print('❌ ERROR: $e');
    exit(1);
  }

  exit(0);
}