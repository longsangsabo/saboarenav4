# 🎱 SABO ARENA - Core Logic Documentation System

## 📋 Overview
This documentation system centralizes all business logic, rules, and calculations for the Sabo Arena platform. When referencing "core logic", this is the single source of truth.

## 🗂️ Documentation Structure

```
docs/core_logic/
├── README.md                           # This file - navigation guide
├── 01_ranking_system.md               # Vietnamese billiards ranking (K→E+)
├── 02_elo_system.md                   # ELO calculations and K-factors
├── 03_match_game_logic.md             # Game types, scoring, match results
├── 04_tournament_logic.md             # Tournament formats, seeding, prizes
├── 05_challenge_system.md             # SPA betting, handicap calculations
├── 06_spa_points_system.md            # SPA earning, spending, transactions
├── 07_verification_system.md          # Rank verification workflows
├── 08_platform_rules.md              # Conduct, time limits, restrictions
├── 09_calculation_formulas.md         # Mathematical formulas reference
└── 10_implementation_guide.md         # How to implement core logic
```

## 🎯 How to Use This System

### **For Development:**
When implementing features, always reference the appropriate core logic document:
- **Ranking updates** → `01_ranking_system.md`
- **ELO calculations** → `02_elo_system.md` + `09_calculation_formulas.md`
- **Tournament creation** → `04_tournament_logic.md`
- **Challenge matching** → `05_challenge_system.md`

### **For Business Logic Changes:**
1. Update the relevant documentation first
2. Update database schema if needed
3. Update code constants/functions
4. Test implementations
5. Update API documentation

### **For Reference:**
- Each document contains **Vietnamese** and **English** versions
- **Examples** and **test cases** included
- **Database schema** references provided
- **Implementation notes** for developers

## 🔍 Quick Reference

### **Core Components:**
- **Vietnamese Billiards Ranks**: K, K+, I, I+, H, H+, G, G+, F, F+, E, E+
- **ELO Range**: 1000-2100+ with rank thresholds
- **Game Types**: 8-ball, 9-ball, 10-ball
- **Match Types**: Challenge, Friendly, Tournament, Practice
- **SPA Betting**: 100-600 points with handicap system
- **Tournament Formats**: Single elimination, Double elimination, Song Tô, Winner-takes-all

### **Key Constants:**
```dart
// Reference these from lib/core/constants/
- RankingConstants: Rank codes, thresholds, progression
- EloConstants: K-factors, bonuses, calculations
- ChallengeConstants: SPA betting levels, handicap rules
- TournamentConstants: Formats, prize distribution, ELO rewards
```

### **Database Tables:**
```sql
-- Core logic storage
- ranking_definitions: Rank definitions and thresholds
- challenge_configurations: SPA betting and handicap rules
- tournament_formats: Tournament types and settings
- platform_settings: Configurable business rules
```

## 🚀 Implementation Workflow

1. **Read** relevant core logic documentation
2. **Reference** database schema and constants
3. **Implement** using provided formulas and rules
4. **Test** against documented examples
5. **Update** documentation if logic changes

## 📖 Document Status

| Document | Status | Last Updated | Coverage |
|----------|--------|--------------|----------|
| 01_ranking_system.md | ✅ Complete | Sep 2025 | Vietnamese ranks, ELO thresholds |
| 02_elo_system.md | ✅ Complete | Sep 2025 | K-factors, calculations, bonuses |
| 03_match_game_logic.md | ✅ Complete | Sep 2025 | Game types, scoring systems |
| 04_tournament_logic.md | ✅ Complete | Sep 2025 | Formats, seeding, prizes, SPA/ELO rewards |
| 05_challenge_system.md | ✅ Complete | Sep 2025 | SPA betting, SABO handicap system |
| 06_spa_points_system.md | 🔄 In Progress | Sep 2025 | SPA transactions, earning, spending |
| 07_verification_system.md | ✅ Complete | Sep 2025 | Rank verification workflows |
| 08_platform_rules.md | 📝 Planned | Sep 2025 | Conduct rules, time limits |
| 09_calculation_formulas.md | 📝 Planned | Sep 2025 | Mathematical reference |
| 10_implementation_guide.md | 📝 Planned | Sep 2025 | Developer guidelines |

## 🎯 Next Steps

1. Complete all core logic documents
2. Create implementation constants and functions
3. Build validation test suites
4. Establish change management process

---

*This documentation system ensures consistency, maintainability, and serves as the single source of truth for all Sabo Arena business logic.*