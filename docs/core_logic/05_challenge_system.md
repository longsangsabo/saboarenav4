# ⚔️ Challenge System - SPA Betting & SABO Handicap

## 📋 Overview
The Challenge System allows verified players to engage in ranked matches with SPA point betting and the official SABO handicap system for fair competition across skill levels.

## 🛡️ Challenge Eligibility Rules

### **1. Verification Requirement:**
- ✅ **Verified Players Only**: Must have `is_verified = true` and valid rank
- ❌ **Unranked Players**: Can only play Friendly matches (no SPA/ELO stakes)
- 🎯 **Rank Difference Limit**: Maximum ±4 sub-ranks (±2 main ranks)

### **2. Match Types:**
| Type | Verification Required | SPA Betting | Handicap | ELO Impact | Rank Impact |
|------|----------------------|-------------|----------|------------|-------------|
| **Challenge** | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Full | ✅ Yes |
| **Friendly** | ❌ No | ❌ No | ❌ No | ❌ None | ❌ No |
| **Tournament** | ✅ Yes | ❌ No | ❌ No | ✅ Full | ✅ Yes |
| **Practice** | ❌ No | ❌ No | ❌ No | ✅ 50% | ❌ No |

## 💰 SPA Betting System

### **Betting Levels & Configuration:**
```javascript
const CHALLENGE_BETS = {
  100: { raceTo: 8,  handicap1: 1.0, handicap05: 0.5 },
  200: { raceTo: 12, handicap1: 1.5, handicap05: 1.0 },
  300: { raceTo: 14, handicap1: 2.0, handicap05: 1.5 },
  400: { raceTo: 16, handicap1: 2.5, handicap05: 1.5 },
  500: { raceTo: 18, handicap1: 3.0, handicap05: 2.0 },
  600: { raceTo: 22, handicap1: 3.5, handicap05: 2.5 },
}
```

### **SPA Transaction Flow:**
1. **Bet Placement**: Both players stake SPA points
2. **Escrow**: Platform holds stakes during match
3. **Winner Takes All**: Victor receives both stakes
4. **Platform Commission**: 5% house edge deducted
5. **Refund Policy**: Stakes returned if match cancelled

### **SPA Balance Requirements:**
- **Minimum Balance**: Must have sufficient SPA for bet amount
- **Overdraft Protection**: Cannot bet more than available balance
- **Starting Balance**: New users get 1000 SPA points

## ⚖️ SABO Handicap System (Official)

### **Rank Value Mapping:**
```dart
Map<String, int> RANK_VALUES = {
  'K': 1,   'K+': 2,   'I': 3,   'I+': 4,
  'H': 5,   'H+': 6,   'G': 7,   'G+': 8,
  'F': 9,   'F+': 10,  'E': 11,  'E+': 12,
};
```

### **Handicap Calculation Logic:**
```dart
int calculateSubRankDifference(String rank1, String rank2) {
  return RANK_VALUES[rank2]! - RANK_VALUES[rank1]!; // Positive = rank2 stronger
}

double calculateHandicap(String challengerRank, String opponentRank, int betPoints) {
  int subRankDiff = calculateSubRankDifference(challengerRank, opponentRank);
  var config = CHALLENGE_BETS[betPoints]!;
  
  switch (subRankDiff.abs()) {
    case 0: return 0.0;                                        // Same rank
    case 1: return config['handicap05'];                       // 1 sub-rank
    case 2: return config['handicap1'];                        // 1 main rank  
    case 3: return config['handicap1'] + config['handicap05']; // 1 main + 1 sub
    case 4: return config['handicap1'] * 2;                    // 2 main ranks
    default: throw 'Invalid rank difference'; // > 4 not allowed
  }
}
```

### **Handicap Examples:**

#### **300 SPA Bet (handicap1=2.0, handicap05=1.5):**
- **K vs K** (diff=0): No handicap → Race to 14
- **K vs K+** (diff=1): K gets +1.5 → K starts 1.5-0, race to 14
- **K vs I** (diff=2): K gets +2.0 → K starts 2-0, race to 14  
- **K vs I+** (diff=3): K gets +3.5 → K starts 3.5-0, race to 14
- **K vs H** (diff=4): K gets +4.0 → K starts 4-0, race to 14

#### **600 SPA Bet (handicap1=3.5, handicap05=2.5):**
- **G vs E** (diff=4): G gets +7.0 → G starts 7-0, race to 22
- **H vs G+** (diff=3): H gets +6.0 → H starts 6-0, race to 22

## 🎮 Challenge Flow

### **1. Challenge Creation:**
```dart
class ChallengeRequest {
  String challengerId;
  String challengedId;
  int spaBetAmount;
  String gameType;        // '8ball', '9ball', '10ball'
  DateTime expiresAt;     // 24 hours default
}
```

### **2. Validation Rules:**
- Both players must be verified
- Rank difference ≤ 4 sub-ranks
- Sufficient SPA balance
- Not already in active challenge

### **3. Handicap Application:**
```dart
class HandicapResult {
  bool isValid;
  String errorMessage;
  int subRankDifference;
  double handicapChallenger;
  double handicapOpponent;
  int raceToTarget;
  String explanation;
}
```

### **4. Match Execution:**
- **Initial Scores**: Apply handicap as starting scores
- **Target Score**: Race to value from bet configuration
- **Winner Determination**: First to reach race-to target
- **SPA Payout**: Winner gets both stakes minus 5% commission

## 🗄️ Database Schema

### **challenge_configurations table:**
```sql
CREATE TABLE challenge_configurations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  bet_amount INTEGER NOT NULL UNIQUE,
  race_to INTEGER NOT NULL,
  handicap_full DECIMAL(3,1) NOT NULL,
  handicap_sub DECIMAL(3,1) NOT NULL,
  description VARCHAR(100),
  is_active BOOLEAN DEFAULT true
);
```

### **challenge_matches table:**
```sql
CREATE TABLE challenge_matches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  challenger_id UUID NOT NULL REFERENCES users(id),
  challenged_id UUID NOT NULL REFERENCES users(id),
  challenge_config_id UUID REFERENCES challenge_configurations(id),
  spa_bet_amount INTEGER DEFAULT 0,
  handicap_applied DECIMAL(3,1) DEFAULT 0.0,
  handicap_recipient UUID REFERENCES users(id),
  challenger_score INTEGER DEFAULT 0,
  challenged_score INTEGER DEFAULT 0,
  winner_id UUID REFERENCES users(id),
  match_status VARCHAR(20) DEFAULT 'PENDING',
  spa_payout INTEGER DEFAULT 0,
  platform_commission INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW(),
  completed_at TIMESTAMP
);
```

### **spa_transactions table:**
```sql
CREATE TABLE spa_transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id),
  transaction_type VARCHAR(20) NOT NULL,
  amount INTEGER NOT NULL,
  balance_before INTEGER NOT NULL,
  balance_after INTEGER NOT NULL,
  challenge_match_id UUID REFERENCES challenge_matches(id),
  description TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);
```

## 🧪 Testing Examples

### **Handicap Calculation Tests:**
```dart
void testHandicapCalculations() {
  // Same rank - no handicap
  assert(calculateHandicap('H', 'H', 300) == 0.0);
  
  // 1 sub-rank difference
  assert(calculateHandicap('K', 'K+', 300) == 1.5);
  
  // 1 main rank difference  
  assert(calculateHandicap('K', 'I', 300) == 2.0);
  
  // 1 main + 1 sub rank
  assert(calculateHandicap('K', 'I+', 300) == 3.5);
  
  // 2 main ranks (maximum)
  assert(calculateHandicap('K', 'H', 300) == 4.0);
  
  // Invalid - too large difference
  assertThrows(() => calculateHandicap('K', 'G', 300));
}
```

### **Challenge Eligibility Tests:**
```dart
void testChallengeEligibility() {
  // Valid challenge
  assert(canChallenge('H', 'G+', true, true) == true);
  
  // Invalid - unverified player
  assert(canChallenge('H', 'G', false, true) == false);
  
  // Invalid - rank difference too large
  assert(canChallenge('K', 'G', true, true) == false);
}
```

## 📊 SPA Economy Balance

### **SPA Earning Sources:**
- Tournament participation rewards
- Challenge match victories
- Daily login bonuses
- Achievement unlocks

### **SPA Spending Sinks:**
- Challenge match betting
- Premium features
- Cosmetic items
- Tournament entry fees

### **Economic Controls:**
- 5% platform commission on bets
- Maximum bet limits by rank
- Daily betting limits
- Anti-gambling measures

## 🔄 Update History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | Sep 2025 | Initial challenge system with SABO handicap |
| 1.1 | Sep 2025 | Added SPA economy and transaction tracking |

---

*This challenge system ensures fair competition through official SABO handicap calculations and maintains platform economy through SPA point management.*