# ≡ƒÄ▒ SABO ARENA - Core Logic Storage Architecture

## ≡ƒôï Overview
This document defines where and how to store core business logic, ranking definitions, and platform rules for the Sabo Arena billiards platform.

## ≡ƒÅù∩╕Å Recommended Architecture: HYBRID APPROACH

### 1. ≡ƒÆ╛ Database Tables (Dynamic Business Logic)

#### `ranking_definitions` table
```sql
CREATE TABLE ranking_definitions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  rank_code VARCHAR(5) NOT NULL UNIQUE, -- 'K', 'K+', 'I', etc.
  rank_name VARCHAR(50) NOT NULL,
  min_elo INTEGER NOT NULL,
  max_elo INTEGER,
  skill_description TEXT NOT NULL,
  skill_description_en TEXT,
  color_hex VARCHAR(7) NOT NULL,
  display_order INTEGER NOT NULL,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Insert Vietnamese billiards ranks
INSERT INTO ranking_definitions (rank_code, rank_name, min_elo, max_elo, skill_description, color_hex, display_order) VALUES
('K', 'Tß║¡p Sß╗▒', 1000, 1099, '2-4 bi khi h├¼nh dß╗à; mß╗¢i tß║¡p', '#8B4513', 1),
('K+', 'Tß║¡p Sß╗▒+', 1100, 1199, 'S├ít ng╞░ß╗íng l├¬n I', '#A0522D', 2),
('I', 'S╞í Cß║Ñp', 1200, 1299, '3-5 bi; ch╞░a ─æiß╗üu ─æ╞░ß╗úc chß║Ñm', '#CD853F', 3),
('I+', 'S╞í Cß║Ñp+', 1300, 1399, 'S├ít ng╞░ß╗íng l├¬n H', '#DEB887', 4),
('H', 'Trung Cß║Ñp', 1400, 1499, '5-8 bi; c├│ thß╗â "r├╣a" 1 chß║Ñm h├¼nh dß╗à', '#C0C0C0', 5),
('H+', 'Trung Cß║Ñp+', 1500, 1599, 'Chuß║⌐n bß╗ï l├¬n G', '#B0B0B0', 6),
('G', 'Kh├í', 1600, 1699, 'Clear 1 chß║Ñm + 3-7 bi kß║┐; bß║»t ─æß║ºu ─æiß╗üu bi 3 b─âng', '#FFD700', 7),
('G+', 'Kh├í+', 1700, 1799, 'Tr├¼nh phong tr├áo "ngon"; s├ít ng╞░ß╗íng l├¬n F', '#FFA500', 8),
('F', 'Giß╗Åi', 1800, 1899, '60-80% clear 1 chß║Ñm, ─æ├┤i khi ph├í 2 chß║Ñm', '#FF6347', 9),
('F+', 'Giß╗Åi+', 1900, 1999, 'Safety & spin control kh├í chß║»c; s├ít ng╞░ß╗íng l├¬n E', '#FF4500', 10),
('E', 'Xuß║Ñt Sß║»c', 2000, 2099, '90-100% clear 1 chß║Ñm, 70% ph├í 2 chß║Ñm', '#DC143C', 11),
('E+', 'Chuy├¬n Gia', 2100, 9999, '─Éiß╗üu bi phß╗⌐c tß║íp, safety chß╗º ─æß╗Öng; s├ít ng╞░ß╗íng l├¬n D', '#B22222', 12);
```

#### `platform_settings` table
```sql
CREATE TABLE platform_settings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  setting_key VARCHAR(100) NOT NULL UNIQUE,
  setting_value JSONB NOT NULL,
  description TEXT,
  category VARCHAR(50) DEFAULT 'general',
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Insert core settings
INSERT INTO platform_settings (setting_key, setting_value, description, category) VALUES
('elo_k_factor_default', '32', 'Default K-factor for ELO calculations', 'elo'),
('elo_k_factor_new_player', '40', 'K-factor for players with <30 games', 'elo'),
('elo_k_factor_high_elo', '24', 'K-factor for players with ELO >1800', 'elo'),
('elo_starting_rating', '1200', 'Starting ELO for new players', 'elo'),
('verification_min_matches', '3', 'Minimum matches for rank verification', 'verification'),
('verification_win_rate_threshold', '0.4', 'Minimum win rate for rank verification', 'verification'),
('tournament_max_participants', '64', 'Maximum participants per tournament', 'tournament'),
('match_timeout_minutes', '60', 'Default match timeout in minutes', 'match');
```

#### `game_formats` table
```sql
CREATE TABLE game_formats (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  format_code VARCHAR(20) NOT NULL UNIQUE,
  format_name VARCHAR(100) NOT NULL,
  description TEXT,
  game_type VARCHAR(20) NOT NULL, -- '8-ball', '9-ball', 'straight-pool'
  scoring_system VARCHAR(20) NOT NULL, -- 'race-to-x', 'best-of-x', 'time-limited'
  target_score INTEGER,
  time_limit_minutes INTEGER,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Insert game formats
INSERT INTO game_formats (format_code, format_name, description, game_type, scoring_system, target_score) VALUES
('8ball_race5', '8-Ball Race to 5', 'First to win 5 games', '8-ball', 'race-to-x', 5),
('8ball_race7', '8-Ball Race to 7', 'First to win 7 games', '8-ball', 'race-to-x', 7),
('9ball_race7', '9-Ball Race to 7', 'First to win 7 games', '9-ball', 'race-to-x', 7),
('straight_100', 'Straight Pool to 100', 'First to 100 points', 'straight-pool', 'race-to-x', 100);
```

### 2. ≡ƒôä Code Constants (Stable System Logic)

#### `lib/core/constants/ranking_constants.dart`
```dart
class RankingConstants {
  // Rank codes
  static const String UNRANKED = 'UNRANKED';
  static const String RANK_K = 'K';
  static const String RANK_K_PLUS = 'K+';
  static const String RANK_I = 'I';
  static const String RANK_I_PLUS = 'I+';
  static const String RANK_H = 'H';
  static const String RANK_H_PLUS = 'H+';
  static const String RANK_G = 'G';
  static const String RANK_G_PLUS = 'G+';
  static const String RANK_F = 'F';
  static const String RANK_F_PLUS = 'F+';
  static const String RANK_E = 'E';
  static const String RANK_E_PLUS = 'E+';

  // Rank progression order
  static const List<String> RANK_ORDER = [
    RANK_K, RANK_K_PLUS, RANK_I, RANK_I_PLUS,
    RANK_H, RANK_H_PLUS, RANK_G, RANK_G_PLUS,
    RANK_F, RANK_F_PLUS, RANK_E, RANK_E_PLUS
  ];

  // Verification requirements
  static const int MIN_VERIFICATION_MATCHES = 3;
  static const double MIN_VERIFICATION_WIN_RATE = 0.40;
  static const int AUTO_VERIFY_MATCH_THRESHOLD = 10;
}
```

#### `lib/core/constants/elo_constants.dart`
```dart
class EloConstants {
  // K-factors
  static const int K_FACTOR_DEFAULT = 32;
  static const int K_FACTOR_NEW_PLAYER = 40;
  static const int K_FACTOR_HIGH_ELO = 24;
  static const int K_FACTOR_PROVISIONAL = 50;

  // ELO thresholds
  static const int STARTING_ELO = 1200;
  static const int HIGH_ELO_THRESHOLD = 1800;
  static const int NEW_PLAYER_GAME_THRESHOLD = 30;

  // Match type modifiers
  static const double TOURNAMENT_MODIFIER = 1.0;
  static const double CHALLENGE_MODIFIER = 1.0;
  static const double FRIENDLY_MODIFIER = 0.5;
  static const double PRACTICE_MODIFIER = 0.25;

  // Bonus calculations
  static const double UPSET_BONUS_THRESHOLD = 200; // ELO difference
  static const double UPSET_BONUS_MULTIPLIER = 1.25;
  static const int WIN_STREAK_THRESHOLD = 5;
  static const double WIN_STREAK_BONUS = 0.1;
}
```

### 3. ≡ƒô¥ Documentation (Human-readable specs)

#### `docs/ranking_system.md`
- Complete ranking system explanation
- Skill level descriptions in Vietnamese
- Progression requirements
- Verification process

#### `docs/business_rules.md`
- Platform rules and constraints
- User behavior guidelines
- Tournament regulations
- Match conduct rules

#### `docs/elo_calculation.md`
- Mathematical formulas
- Calculation examples
- Edge cases handling
- Testing scenarios

### 4. ≡ƒöº Configuration Management

#### Database-driven configs (Admin configurable):
```dart
class ConfigService {
  static Future<int> getEloKFactor(UserProfile user) async {
    if (user.totalMatches < 30) {
      return await _getSetting('elo_k_factor_new_player', 40);
    } else if (user.eloRating > 1800) {
      return await _getSetting('elo_k_factor_high_elo', 24);
    }
    return await _getSetting('elo_k_factor_default', 32);
  }

  static Future<RankDefinition> getRankByElo(int elo) async {
    // Query ranking_definitions table
    return await supabase
        .from('ranking_definitions')
        .select()
        .lte('min_elo', elo)
        .gt('max_elo', elo)
        .eq('is_active', true)
        .single();
  }
}
```

## ≡ƒÄ» Implementation Benefits

### Γ£à Advantages:
1. **Flexibility**: Admin can adjust ELO K-factors, rank thresholds without app updates
2. **Maintainability**: Clear separation between stable logic and dynamic configs
3. **Scalability**: Easy to add new ranks, game formats, rules
4. **Localization**: Support multiple languages for skill descriptions
5. **Auditability**: All changes tracked in database with timestamps
6. **Performance**: Stable constants cached in code, dynamic data queried as needed

### ΓÜí Performance Optimization:
1. **Cache frequently accessed data** (rank definitions, game formats)
2. **Use database views** for complex queries
3. **Index critical lookup fields** (elo ranges, rank codes)
4. **Implement cache invalidation** when configs change

## ≡ƒöä Migration Strategy

### Phase 1: Database Tables
1. Create core tables (`ranking_definitions`, `platform_settings`, `game_formats`)
2. Migrate existing hardcoded data to tables
3. Create admin interface for configuration management

### Phase 2: Code Constants
1. Extract stable constants to dedicated files
2. Replace magic numbers with named constants
3. Implement configuration service layer

### Phase 3: Documentation
1. Document all business rules and calculations
2. Create developer guides and API documentation
3. Establish change management processes

This architecture provides the perfect balance of flexibility, performance, and maintainability for Sabo Arena's core logic management.
