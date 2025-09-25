# 🎯 ELO Rating System

## 📋 Overview
Sabo Arena uses a sophisticated ELO rating system adapted for Vietnamese billiards, with dynamic K-factors, bonuses, and rank integration.

## ⚡ Core ELO Parameters

### **Starting Values:**
- **Starting ELO**: 1200 (I rank)
- **Minimum ELO**: 1000 (K rank floor)
- **Maximum ELO**: No ceiling (E+ can exceed 2100)

### **K-Factor System:**
```dart
class EloKFactors {
  static const int DEFAULT = 32;           // Standard players
  static const int NEW_PLAYER = 40;        // < 30 games played
  static const int HIGH_ELO = 24;          // ELO > 1800 (F+ and above)  
  static const int PROVISIONAL = 50;       // Unranked/unverified players
  static const int TOURNAMENT = 40;        // Tournament matches
}
```

### **K-Factor Selection Logic:**
```dart
int getKFactor(UserProfile user, MatchType matchType) {
  if (matchType == MatchType.TOURNAMENT) return EloKFactors.TOURNAMENT;
  if (!user.isVerified) return EloKFactors.PROVISIONAL;
  if (user.totalMatches < 30) return EloKFactors.NEW_PLAYER;
  if (user.eloRating > 1800) return EloKFactors.HIGH_ELO;
  return EloKFactors.DEFAULT;
}
```

## 🧮 ELO Calculation Formula

### **Standard ELO Formula:**
```dart
double calculateExpectedScore(int playerElo, int opponentElo) {
  return 1.0 / (1.0 + pow(10, (opponentElo - playerElo) / 400.0));
}

int calculateEloChange(int playerElo, int opponentElo, double actualScore, int kFactor) {
  double expectedScore = calculateExpectedScore(playerElo, opponentElo);
  return (kFactor * (actualScore - expectedScore)).round();
}
```

### **Match Result Scoring:**
- **Win**: actualScore = 1.0
- **Loss**: actualScore = 0.0  
- **Draw**: actualScore = 0.5 (rare in billiards)

### **Example Calculations:**
```dart
// Example: H rank (1450 ELO) vs G rank (1650 ELO)
int playerElo = 1450;
int opponentElo = 1650;
int kFactor = 32;

// If H rank wins (upset victory):
double expectedScore = calculateExpectedScore(1450, 1650); // ≈ 0.24
int eloGain = calculateEloChange(1450, 1650, 1.0, 32);      // ≈ +24 ELO

// If H rank loses (expected result):
int eloLoss = calculateEloChange(1450, 1650, 0.0, 32);      // ≈ -8 ELO
```

## 🏆 ELO Bonuses & Modifiers

### **Match Type Modifiers:**
```dart
class EloModifiers {
  static const double TOURNAMENT = 1.0;        // No modifier
  static const double CHALLENGE = 1.0;         // No modifier
  static const double FRIENDLY = 0.0;          // No ELO change
  static const double PRACTICE = 0.5;          // Half ELO impact
}
```

### **Bonus Calculations:**
```dart
class EloBonuses {
  // Upset Victory Bonus
  static int calculateUpsetBonus(int playerElo, int opponentElo) {
    int eloDiff = opponentElo - playerElo;
    if (eloDiff >= 200) {
      return (eloDiff / 100).floor() * 2; // +2 per 100 ELO difference
    }
    return 0;
  }
  
  // Win Streak Bonus
  static int calculateStreakBonus(int currentStreak) {
    if (currentStreak >= 10) return 5;
    if (currentStreak >= 5) return 3;
    return 0;
  }
  
  // Perfect Game Bonus (applicable in tournaments)
  static int calculatePerfectGameBonus(bool isPerfectGame) {
    return isPerfectGame ? 5 : 0;
  }
}
```

### **Combined ELO Change:**
```dart
int calculateFinalEloChange(
  int baseEloChange,
  int upsetBonus,
  int streakBonus,
  int perfectGameBonus,
  double matchTypeModifier
) {
  int totalChange = baseEloChange + upsetBonus + streakBonus + perfectGameBonus;
  return (totalChange * matchTypeModifier).round();
}
```

## 🎯 Tournament ELO Rewards

### **Tournament Position Rewards:**
```dart
Map<int, int> TOURNAMENT_ELO_REWARDS = {
  1: 75,   // Champion
  2: 60,   // Runner-up  
  3: 50,   // Third place
  4: 40,   // Fourth place
  // Ranges
  // 5-8: 30,     Quarter-finals
  // 9-16: 20,    Round of 16
  // 17-32: 15,   First round+
  // 33+: 10,     Early exit
};

int getTournamentEloReward(int position, int totalPlayers) {
  if (position == 1) return 75;
  if (position == 2) return 60;
  if (position == 3) return 50;
  if (position == 4) return 40;
  if (position <= 8) return 30;
  if (position <= 16) return 20;
  if (position <= 32) return 15;
  return 10; // Participation reward
}
```

### **Tournament Bonuses:**
- **Large Tournament**: +5 ELO for 32+ participants
- **Perfect Run**: +5 ELO for winning without losing a match
- **Upset Run**: +10 ELO for beating multiple higher-ranked opponents

## 🔄 ELO-Rank Integration

### **Automatic Rank Updates:**
```dart
void updatePlayerRank(UserProfile player) {
  String newRank = calculateRankFromElo(player.eloRating);
  
  if (newRank != player.currentRank) {
    // Rank up: requires verification
    if (isRankUp(player.currentRank, newRank)) {
      if (player.isVerified) {
        player.currentRank = newRank;
        player.rankUpdatedAt = DateTime.now();
      }
      // Else: ELO increases but rank stays (pending verification)
    }
    
    // Rank down: immediate (no verification needed)
    else {
      player.currentRank = newRank;
      player.rankUpdatedAt = DateTime.now();
    }
  }
}
```

### **Rank Protection:**
- **Grace Period**: 7 days after rank up before demotion possible
- **Minimum Games**: 10 games at current rank before demotion
- **Verification Barrier**: Cannot exceed verified rank ceiling

## 📊 ELO Statistics & Analytics

### **Key Metrics:**
```dart
class EloStatistics {
  double averageElo;
  int highestElo;
  int lowestElo;
  double eloGainPerMonth;
  int longestWinStreak;
  int biggestUpset;       // Largest ELO difference overcome
  double tournamentEloAvg;
  double challengeEloAvg;
}
```

### **Performance Tracking:**
- **ELO History**: Track daily/weekly/monthly changes
- **Peak ELO**: Highest ELO ever achieved
- **ELO Volatility**: Standard deviation of recent ELO changes
- **Head-to-Head**: ELO changes against specific opponents

## 🗄️ Database Schema

### **elo_history table:**
```sql
CREATE TABLE elo_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id),
  match_id UUID REFERENCES matches(id),
  tournament_id UUID REFERENCES tournaments(id),
  elo_before INTEGER NOT NULL,
  elo_after INTEGER NOT NULL,
  elo_change INTEGER NOT NULL,
  k_factor INTEGER NOT NULL,
  base_change INTEGER NOT NULL,
  bonuses JSONB, -- {upset: 5, streak: 3, perfect: 5}
  match_type VARCHAR(20) NOT NULL,
  opponent_id UUID REFERENCES users(id),
  created_at TIMESTAMP DEFAULT NOW()
);
```

### **elo_statistics table:**
```sql
CREATE TABLE elo_statistics (
  user_id UUID PRIMARY KEY REFERENCES users(id),
  current_elo INTEGER NOT NULL,
  peak_elo INTEGER NOT NULL,
  peak_elo_date TIMESTAMP,
  total_elo_gained INTEGER DEFAULT 0,
  total_elo_lost INTEGER DEFAULT 0,
  avg_elo_change DECIMAL(5,2) DEFAULT 0,
  win_streak INTEGER DEFAULT 0,
  loss_streak INTEGER DEFAULT 0,
  biggest_upset INTEGER DEFAULT 0, -- ELO difference overcome
  tournament_elo_total INTEGER DEFAULT 0,
  challenge_elo_total INTEGER DEFAULT 0,
  updated_at TIMESTAMP DEFAULT NOW()
);
```

## 🧪 Testing Examples

### **ELO Calculation Tests:**
```dart
void testEloCalculations() {
  // Standard match: equal players
  assert(calculateEloChange(1500, 1500, 1.0, 32) == 16);
  assert(calculateEloChange(1500, 1500, 0.0, 32) == -16);
  
  // Upset victory
  assert(calculateEloChange(1400, 1600, 1.0, 32) == 24);
  assert(calculateEloChange(1600, 1400, 0.0, 32) == -24);
  
  // High ELO player (lower K-factor)
  assert(calculateEloChange(1900, 1700, 1.0, 24) == 18);
  
  // New player (higher K-factor)
  assert(calculateEloChange(1200, 1400, 1.0, 40) == 30);
}
```

### **Bonus Calculation Tests:**
```dart
void testEloBonuses() {
  // Upset bonus
  assert(calculateUpsetBonus(1400, 1600) == 4); // 200 ELO diff = +4
  assert(calculateUpsetBonus(1400, 1500) == 0); // <200 diff = no bonus
  
  // Streak bonus
  assert(calculateStreakBonus(10) == 5);
  assert(calculateStreakBonus(5) == 3);
  assert(calculateStreakBonus(3) == 0);
}
```

## 📈 ELO Distribution Analysis

### **Target Distribution:**
- **K ranks (1000-1199)**: ~20% of players
- **I ranks (1200-1399)**: ~25% of players  
- **H ranks (1400-1599)**: ~25% of players
- **G ranks (1600-1799)**: ~20% of players
- **F ranks (1800-1999)**: ~8% of players
- **E ranks (2000+)**: ~2% of players

### **Distribution Monitoring:**
Monitor ELO inflation/deflation and adjust K-factors if needed to maintain healthy distribution.

## 🔄 Update History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | Sep 2025 | Initial ELO system with dynamic K-factors |
| 1.1 | Sep 2025 | Added tournament rewards and bonus calculations |
| 1.2 | Sep 2025 | Integrated rank-ELO relationship and protection rules |

---

*This ELO system balances competitive integrity with player progression, adapted specifically for Vietnamese billiards competition.*