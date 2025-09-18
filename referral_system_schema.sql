-- SABO Arena Referral System Database Schema
-- Created: September 19, 2025

-- Referral Codes Table
CREATE TABLE IF NOT EXISTS referral_codes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    code TEXT UNIQUE NOT NULL,
    code_type TEXT DEFAULT 'general' CHECK (code_type IN ('general', 'vip', 'tournament', 'club')),
    max_uses INTEGER DEFAULT NULL, -- NULL means unlimited
    current_uses INTEGER DEFAULT 0,
    rewards JSONB DEFAULT '{"referrer": {"spa_points": 100, "elo_boost": 10}, "referred": {"spa_points": 50, "welcome_bonus": true}}',
    expires_at TIMESTAMP NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Referral Usage History
CREATE TABLE IF NOT EXISTS referral_usage (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    referral_code_id UUID REFERENCES referral_codes(id) ON DELETE CASCADE,
    referrer_id UUID REFERENCES users(id) ON DELETE CASCADE,
    referred_user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    bonus_awarded JSONB NOT NULL, -- {"referrer": 100, "referred": 50, "type": "spa_points"}
    status TEXT DEFAULT 'completed' CHECK (status IN ('pending', 'completed', 'failed')),
    used_at TIMESTAMP DEFAULT NOW()
);

-- Add referral fields to existing users table
ALTER TABLE users ADD COLUMN IF NOT EXISTS referral_stats JSONB DEFAULT '{"total_referred": 0, "total_earned": 0, "codes_created": 0}';
ALTER TABLE users ADD COLUMN IF NOT EXISTS referred_by UUID REFERENCES users(id);
ALTER TABLE users ADD COLUMN IF NOT EXISTS referral_bonus_claimed BOOLEAN DEFAULT false;

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_referral_codes_user_id ON referral_codes(user_id);
CREATE INDEX IF NOT EXISTS idx_referral_codes_code ON referral_codes(code);
CREATE INDEX IF NOT EXISTS idx_referral_codes_active ON referral_codes(is_active, expires_at);
CREATE INDEX IF NOT EXISTS idx_referral_usage_referrer ON referral_usage(referrer_id);
CREATE INDEX IF NOT EXISTS idx_referral_usage_referred ON referral_usage(referred_user_id);
CREATE INDEX IF NOT EXISTS idx_users_referred_by ON users(referred_by);

-- Update trigger for referral_codes
CREATE OR REPLACE FUNCTION update_referral_codes_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_referral_codes_updated_at
    BEFORE UPDATE ON referral_codes
    FOR EACH ROW
    EXECUTE FUNCTION update_referral_codes_updated_at();

-- Sample referral codes for testing
INSERT INTO referral_codes (user_id, code, code_type, rewards) VALUES
(
    (SELECT id FROM users LIMIT 1), -- Use existing user
    'SABO-GIANG-VIP',
    'vip',
    '{"referrer": {"spa_points": 200, "premium_days": 7}, "referred": {"spa_points": 100, "premium_trial": 14}}'
),
(
    (SELECT id FROM users LIMIT 1),
    'SABO-WELCOME-2025',
    'general',
    '{"referrer": {"spa_points": 100, "elo_boost": 10}, "referred": {"spa_points": 50, "welcome_bonus": true}}'
);

-- Comments for documentation
COMMENT ON TABLE referral_codes IS 'Stores user-generated referral codes with rewards and usage limits';
COMMENT ON TABLE referral_usage IS 'Tracks each use of referral codes and rewards awarded';
COMMENT ON COLUMN referral_codes.code IS 'Unique referral code in format SABO-[USERNAME]-[TYPE]';
COMMENT ON COLUMN referral_codes.rewards IS 'JSON structure defining rewards for referrer and referred user';
COMMENT ON COLUMN users.referral_stats IS 'JSON tracking user referral statistics and earnings';