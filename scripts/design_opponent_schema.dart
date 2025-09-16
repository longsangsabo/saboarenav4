import 'dart:io';
import 'package:supabase/supabase.dart';

Future<void> main() async {
  print('🏗️ DESIGNING OPPONENT TAB DATABASE SCHEMA...\n');

  const supabaseUrl = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
  const serviceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo';

  try {
    final supabase = SupabaseClient(supabaseUrl, serviceKey);
    
    print('📋 1. CHALLENGES TABLE - Thách đấu system');
    print('═══════════════════════════════════════');
    
    final challengesSchema = '''
CREATE TABLE challenges (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  challenger_id UUID REFERENCES users(id) ON DELETE CASCADE,
  challenged_id UUID REFERENCES users(id) ON DELETE CASCADE,
  challenge_type VARCHAR(50) DEFAULT 'standard', -- standard, ranking, custom
  stakes_type VARCHAR(50) DEFAULT 'none', -- none, points, money, custom
  stakes_amount INTEGER DEFAULT 0,
  stakes_description TEXT,
  message TEXT,
  status VARCHAR(50) DEFAULT 'pending', -- pending, accepted, declined, expired, completed
  conditions JSONB DEFAULT '{}', -- custom rules, time limits, etc
  match_id UUID REFERENCES matches(id) ON DELETE SET NULL,
  expires_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);''';
    
    print(challengesSchema);
    
    print('\n📋 2. FRIENDLY_MATCHES TABLE - Giao lưu matches');
    print('═══════════════════════════════════════════════');
    
    final friendlySchema = '''
CREATE TABLE friendly_matches (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  host_id UUID REFERENCES users(id) ON DELETE CASCADE,
  guest_id UUID REFERENCES users(id) ON DELETE SET NULL,
  match_type VARCHAR(50) DEFAULT 'casual', -- casual, practice, exhibition
  location_type VARCHAR(50) DEFAULT 'online', -- online, venue, home
  venue_address TEXT,
  scheduled_time TIMESTAMP WITH TIME ZONE,
  custom_rules JSONB DEFAULT '{}',
  max_participants INTEGER DEFAULT 2,
  is_public BOOLEAN DEFAULT false,
  status VARCHAR(50) DEFAULT 'open', -- open, full, in_progress, completed, cancelled
  match_id UUID REFERENCES matches(id) ON DELETE SET NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);''';
    
    print(friendlySchema);
    
    print('\n📋 3. MATCH_BETS TABLE - Cược đặt system');
    print('═══════════════════════════════════════');
    
    final betsSchema = '''
CREATE TABLE match_bets (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  match_id UUID REFERENCES matches(id) ON DELETE CASCADE,
  bettor_id UUID REFERENCES users(id) ON DELETE CASCADE,
  bet_type VARCHAR(50) DEFAULT 'winner', -- winner, score_exact, score_range, handicap
  bet_amount DECIMAL(10,2) DEFAULT 0,
  currency VARCHAR(10) DEFAULT 'VND',
  predicted_winner_id UUID REFERENCES users(id) ON DELETE SET NULL,
  predicted_score VARCHAR(20), -- "7-3", "7-4", etc
  odds DECIMAL(5,2) DEFAULT 1.0,
  potential_payout DECIMAL(10,2),
  status VARCHAR(50) DEFAULT 'pending', -- pending, won, lost, cancelled, refunded
  settled_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);''';
    
    print(betsSchema);
    
    print('\n📋 4. MATCH_INVITATIONS TABLE - Lời mời đấu');
    print('═══════════════════════════════════════════');
    
    final invitationsSchema = '''
CREATE TABLE match_invitations (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  sender_id UUID REFERENCES users(id) ON DELETE CASCADE,
  recipient_id UUID REFERENCES users(id) ON DELETE CASCADE,
  invitation_type VARCHAR(50) DEFAULT 'friendly', -- friendly, challenge, tournament
  match_format VARCHAR(50) DEFAULT '8ball', -- 8ball, 9ball, 10ball, straight
  proposed_time TIMESTAMP WITH TIME ZONE,
  location_preference VARCHAR(100),
  message TEXT,
  stakes JSONB DEFAULT '{}', -- if any stakes involved
  status VARCHAR(50) DEFAULT 'sent', -- sent, viewed, accepted, declined, expired
  response_message TEXT,
  expires_at TIMESTAMP WITH TIME ZONE,
  responded_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);''';
    
    print(invitationsSchema);
    
    print('\n📋 5. MATCH_FINDER_REQUESTS TABLE - Tìm đối thủ');
    print('═══════════════════════════════════════════════');
    
    final finderSchema = '''
CREATE TABLE match_finder_requests (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  skill_level_min INTEGER DEFAULT 800, -- ELO range min
  skill_level_max INTEGER DEFAULT 2000, -- ELO range max  
  preferred_format VARCHAR(50) DEFAULT 'any', -- 8ball, 9ball, 10ball, any
  location_radius_km INTEGER DEFAULT 50,
  preferred_location VARCHAR(100),
  available_times JSONB DEFAULT '[]', -- array of time slots
  match_type VARCHAR(50) DEFAULT 'casual', -- casual, competitive, practice
  stakes_willing BOOLEAN DEFAULT false,
  max_stakes_amount INTEGER DEFAULT 0,
  status VARCHAR(50) DEFAULT 'active', -- active, matched, paused, expired
  matched_with_user_id UUID REFERENCES users(id) ON DELETE SET NULL,
  matched_at TIMESTAMP WITH TIME ZONE,
  expires_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);''';
    
    print(finderSchema);
    
    print('\n📋 6. PLAYER_PREFERENCES TABLE - User preferences');
    print('═══════════════════════════════════════════════════');
    
    final preferencesSchema = '''
CREATE TABLE player_preferences (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE UNIQUE,
  auto_accept_friends BOOLEAN DEFAULT false,
  accept_challenges_from VARCHAR(50) DEFAULT 'friends', -- anyone, friends, none
  preferred_stakes_range JSONB DEFAULT '{"min": 0, "max": 100000}',
  preferred_game_formats TEXT[] DEFAULT ARRAY['8ball'],
  notification_preferences JSONB DEFAULT '{}',
  availability_schedule JSONB DEFAULT '{}', -- weekly schedule
  skill_display_preference VARCHAR(50) DEFAULT 'public', -- public, friends, private
  location_sharing BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);''';
    
    print(preferencesSchema);
    
    print('\n🔗 RELATIONSHIPS & INDEXES:');
    print('═══════════════════════════');
    print('• challenges ↔ users (challenger/challenged)');
    print('• challenges ↔ matches (result reference)');
    print('• friendly_matches ↔ users (host/guest)');
    print('• match_bets ↔ matches & users');
    print('• match_invitations ↔ users (sender/recipient)');
    print('• match_finder_requests ↔ users');
    print('• player_preferences ↔ users (1:1)');
    
    print('\n📱 UI FEATURES ENABLED:');
    print('═════════════════════════');
    print('✅ Challenge friends to matches');
    print('✅ Accept/decline challenges');
    print('✅ Create friendly match rooms');
    print('✅ Join public friendly matches');  
    print('✅ Place bets on matches');
    print('✅ Send/receive match invitations');
    print('✅ Find opponents by skill/location');
    print('✅ Set matching preferences');
    print('✅ Manage availability schedule');
    print('✅ Track challenge/bet history');
    
    print('\n🚀 READY TO CREATE THESE TABLES?');
    print('This will give longsang063@gmail.com complete');
    print('opponent management features for testing!');
    
  } catch (e) {
    print('❌ ERROR: $e');
    exit(1);
  }

  exit(0);
}