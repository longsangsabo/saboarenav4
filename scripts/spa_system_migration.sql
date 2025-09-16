-- SPA CHALLENGE SYSTEM DATABASE MIGRATION
-- Run this SQL in Supabase SQL Editor

-- 1. EXTEND MATCHES TABLE
ALTER TABLE matches ADD COLUMN IF NOT EXISTS match_type VARCHAR(50) DEFAULT 'tournament';
ALTER TABLE matches ADD COLUMN IF NOT EXISTS invitation_type VARCHAR(50) DEFAULT 'none';
ALTER TABLE matches ADD COLUMN IF NOT EXISTS stakes_type VARCHAR(50) DEFAULT 'none';
ALTER TABLE matches ADD COLUMN IF NOT EXISTS spa_stakes_amount INTEGER DEFAULT 0;
ALTER TABLE matches ADD COLUMN IF NOT EXISTS challenger_id UUID REFERENCES users(id);
ALTER TABLE matches ADD COLUMN IF NOT EXISTS challenge_message TEXT;
ALTER TABLE matches ADD COLUMN IF NOT EXISTS response_message TEXT;
ALTER TABLE matches ADD COLUMN IF NOT EXISTS match_conditions JSONB DEFAULT '{}';
ALTER TABLE matches ADD COLUMN IF NOT EXISTS is_public_challenge BOOLEAN DEFAULT false;
ALTER TABLE matches ADD COLUMN IF NOT EXISTS expires_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE matches ADD COLUMN IF NOT EXISTS accepted_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE matches ADD COLUMN IF NOT EXISTS spa_payout_processed BOOLEAN DEFAULT false;

-- 2. EXTEND USERS TABLE
ALTER TABLE users ADD COLUMN IF NOT EXISTS spa_points INTEGER DEFAULT 1000;
ALTER TABLE users ADD COLUMN IF NOT EXISTS spa_points_won INTEGER DEFAULT 0;
ALTER TABLE users ADD COLUMN IF NOT EXISTS spa_points_lost INTEGER DEFAULT 0;
ALTER TABLE users ADD COLUMN IF NOT EXISTS challenge_win_streak INTEGER DEFAULT 0;

-- 3. CREATE SPA TRANSACTIONS TABLE
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
);

-- 4. CREATE INDEXES FOR PERFORMANCE
CREATE INDEX IF NOT EXISTS idx_matches_match_type ON matches(match_type);
CREATE INDEX IF NOT EXISTS idx_matches_challenger_id ON matches(challenger_id);
CREATE INDEX IF NOT EXISTS idx_matches_stakes ON matches(stakes_type, spa_stakes_amount);
CREATE INDEX IF NOT EXISTS idx_spa_transactions_user_id ON spa_transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_spa_transactions_match_id ON spa_transactions(match_id);

-- 5. COMMENTS FOR DOCUMENTATION
COMMENT ON COLUMN matches.match_type IS 'tournament, friendly, challenge, spa_challenge, practice';
COMMENT ON COLUMN matches.invitation_type IS 'none, challenge_sent, challenge_received, friend_invite, auto_match';
COMMENT ON COLUMN matches.stakes_type IS 'none, spa_points, tournament_prize, bragging_rights';
COMMENT ON COLUMN matches.spa_stakes_amount IS 'SPA bonus points at stake (100, 500, 1000, etc.)';
COMMENT ON COLUMN matches.challenger_id IS 'Who sent the challenge (might be different from player1)';
COMMENT ON COLUMN matches.match_conditions IS 'Custom rules: {"format": "8ball", "race_to": 7, "time_limit": 30}';
COMMENT ON COLUMN matches.is_public_challenge IS 'Can others see this challenge?';
COMMENT ON COLUMN matches.expires_at IS 'Challenge expires if not accepted within timeframe';
COMMENT ON COLUMN matches.accepted_at IS 'When challenge was accepted';
COMMENT ON COLUMN matches.spa_payout_processed IS 'Track if SPA points were transferred to winner';

COMMENT ON COLUMN users.spa_points IS 'Current SPA bonus points balance';
COMMENT ON COLUMN users.spa_points_won IS 'Total SPA points won from challenges';
COMMENT ON COLUMN users.spa_points_lost IS 'Total SPA points lost in challenges';
COMMENT ON COLUMN users.challenge_win_streak IS 'Current winning streak in SPA challenges';

COMMENT ON TABLE spa_transactions IS 'Log of all SPA points transactions';
COMMENT ON COLUMN spa_transactions.transaction_type IS 'challenge_win, challenge_loss, tournament_prize, daily_bonus, purchase';
COMMENT ON COLUMN spa_transactions.amount IS 'Positive for gain, negative for loss';