# ✅ CORRECT SABO DE32 Structure - 55 Matches (V2)

## 📊 Overview - Two-Group SABO System
- **Group A**: 24 matches (SABO DE16 for 16 players)
- **Group B**: 24 matches (SABO DE16 for 16 players)
- **Cross-Bracket Finals**: 7 matches (4 semis + 2 finals + 1 grand final)
- **Total**: 55 matches

---

## 🎯 Key Concept: Two-Group SABO System

SABO DE32 **CHIA 32 PLAYERS THÀNH 2 GROUPS**, mỗi group chạy **SABO DE16 structure**!

**Group A (P1-P16)**: Chạy SABO DE16 → produces **4 qualifiers**:
- WB Winner (stops at R3, no WB final)
- WB Runner-up (stops at R3, no WB final)
- LB-A Champion (winner of LB-A branch)
- LB-B Champion (winner of LB-B branch)

**Group B (P17-P32)**: Chạy SABO DE16 → produces **4 qualifiers**:
- WB Winner (stops at R3, no WB final)
- WB Runner-up (stops at R3, no WB final)
- LB-A Champion (winner of LB-A branch)
- LB-B Champion (winner of LB-B branch)

**Cross-Bracket Finals**: 8 qualifiers cross-match:
- **Semi-Finals (4 matches)**: Cross-group matchups
- **Finals (2 matches)**: SF winners compete
- **Grand Final (1 match)**: Final winners compete for championship

---

## 🎯 Why This Structure is Better

| Aspect | Old (Modified DE16) | New (SABO DE16) |
|--------|---------------------|-----------------|
| **Qualifiers per Group** | 2 (Winner + Runner-up) | **4 (2 WB + 1 LB-A + 1 LB-B)** |
| **LB Representation** | Only LB Final winner | **Both LB-A and LB-B champions** |
| **Fairness** | Only top 2 advance | **Balanced across all branches** |
| **Matches per Group** | 26 | **24 (no internal finals)** |
| **Cross Finals** | 3 matches (4 players) | **7 matches (8 players)** |

**Advantage**: Mỗi loser branch (LB-A, LB-B) đều có cơ hội vào finals, không chỉ riêng WB!

---

## 🏆 GROUP A - SABO DE16 (24 matches)

### Display Order: 11xxx (Group A prefix)

**Structure**: SABO DE16 format (NO internal finals)
- **Winner Bracket**: 14 matches (8+4+2, stops at 2 players)
- **Loser Branch A**: 7 matches (4+2+1)
- **Loser Branch B**: 3 matches (2+1)
- **NO SABO Finals** - 4 players qualify directly to Cross-Bracket

### Winner Bracket (14 matches) - Display Order: 11101-11302

**WB Round 1** (8 matches): 11101-11108
```
M1:  P1  vs P16  → Winner to M9,  Loser to M17 (LB-A R1)
M2:  P8  vs P9   → Winner to M9,  Loser to M17 (LB-A R1)
M3:  P4  vs P13  → Winner to M10, Loser to M18 (LB-A R1)
M4:  P5  vs P12  → Winner to M10, Loser to M18 (LB-A R1)
M5:  P2  vs P15  → Winner to M11, Loser to M19 (LB-A R1)
M6:  P7  vs P10  → Winner to M11, Loser to M19 (LB-A R1)
M7:  P3  vs P14  → Winner to M12, Loser to M20 (LB-A R1)
M8:  P6  vs P11  → Winner to M12, Loser to M20 (LB-A R1)
```

**WB Round 2** (4 matches): 11201-11204
```
M9:  M1W vs M2W  → Winner to M13, Loser to M21 (LB-B R1)
M10: M3W vs M4W  → Winner to M13, Loser to M21 (LB-B R1)
M11: M5W vs M6W  → Winner to M14, Loser to M22 (LB-B R1)
M12: M7W vs M8W  → Winner to M14, Loser to M22 (LB-B R1)
```

**WB Round 3** (2 matches): 11301-11302 → **QUALIFIERS**
```
M13: M9W  vs M10W → Winner = WB Winner (to Cross SF1), NO LOSER ADVANCEMENT
M14: M11W vs M12W → Winner = WB Runner-up (to Cross SF2), NO LOSER ADVANCEMENT
```

**⚠️ CRITICAL**: WB R3 has **NO loser advancement** (loser_advances_to = null)!

### Loser Branch A (7 matches) - Display Order: 12101-12301

**LB-A Round 1** (4 matches): 12101-12104
```
M17: M1L vs M2L → Winner to M23
M18: M3L vs M4L → Winner to M23
M19: M5L vs M6L → Winner to M24
M20: M7L vs M8L → Winner to M24
```

**LB-A Round 2** (2 matches): 12201-12202
```
M23: M17W vs M18W → Winner to M25
M24: M19W vs M20W → Winner to M25
```

**LB-A Round 3** (1 match): 12301 → **QUALIFIER**
```
M25: M23W vs M24W → Winner = LB-A Champion (to Cross SF2)
```

### Loser Branch B (3 matches) - Display Order: 13101-13201

**LB-B Round 1** (2 matches): 13101-13102
```
M21: M9L  vs M10L → Winner to M26
M22: M11L vs M12L → Winner to M26
```

**LB-B Round 2** (1 match): 13201 → **QUALIFIER**
```
M26: M21W vs M22W → Winner = LB-B Champion (to Cross SF1)
```

### Group A Qualifiers Summary
1. **M13 Winner** → WB Winner (to Cross SF1)
2. **M14 Winner** → WB Runner-up (to Cross SF2)
3. **M25 Winner** → LB-A Champion (to Cross SF2)
4. **M26 Winner** → LB-B Champion (to Cross SF1)

---

## 🏆 GROUP B - SABO DE16 (24 matches)

### Display Order: 21xxx (Group B prefix)

**Structure**: Identical to Group A, but for players P17-P32
- **Winner Bracket**: 14 matches (21101-21302)
- **Loser Branch A**: 7 matches (22101-22301)
- **Loser Branch B**: 3 matches (23101-23201)

### Winner Bracket (14 matches) - Display Order: 21101-21302

**WB Round 1** (8 matches): 21101-21108
```
M27: P17 vs P32 → Winner to M35, Loser to M43 (LB-A R1)
M28: P24 vs P25 → Winner to M35, Loser to M43 (LB-A R1)
M29: P20 vs P29 → Winner to M36, Loser to M44 (LB-A R1)
M30: P21 vs P28 → Winner to M36, Loser to M44 (LB-A R1)
M31: P18 vs P31 → Winner to M37, Loser to M45 (LB-A R1)
M32: P23 vs P26 → Winner to M37, Loser to M45 (LB-A R1)
M33: P19 vs P30 → Winner to M38, Loser to M46 (LB-A R1)
M34: P22 vs P27 → Winner to M38, Loser to M46 (LB-A R1)
```

**WB Round 2** (4 matches): 21201-21204
```
M35: M27W vs M28W → Winner to M39, Loser to M47 (LB-B R1)
M36: M29W vs M30W → Winner to M39, Loser to M47 (LB-B R1)
M37: M31W vs M32W → Winner to M40, Loser to M48 (LB-B R1)
M38: M33W vs M34W → Winner to M40, Loser to M48 (LB-B R1)
```

**WB Round 3** (2 matches): 21301-21302 → **QUALIFIERS**
```
M39: M35W vs M36W → Winner = WB Winner (to Cross SF3), NO LOSER ADVANCEMENT
M40: M37W vs M38W → Winner = WB Runner-up (to Cross SF4), NO LOSER ADVANCEMENT
```

### Loser Branch A (7 matches) - Display Order: 22101-22301

**LB-A Round 1** (4 matches): 22101-22104
```
M43: M27L vs M28L → Winner to M49
M44: M29L vs M30L → Winner to M49
M45: M31L vs M32L → Winner to M50
M46: M33L vs M34L → Winner to M50
```

**LB-A Round 2** (2 matches): 22201-22202
```
M49: M43W vs M44W → Winner to M51
M50: M45W vs M46W → Winner to M51
```

**LB-A Round 3** (1 match): 22301 → **QUALIFIER**
```
M51: M49W vs M50W → Winner = LB-A Champion (to Cross SF4)
```

### Loser Branch B (3 matches) - Display Order: 23101-23201

**LB-B Round 1** (2 matches): 23101-23102
```
M47: M35L vs M36L → Winner to M52
M48: M37L vs M38L → Winner to M52
```

**LB-B Round 2** (1 match): 23201 → **QUALIFIER**
```
M52: M47W vs M48W → Winner = LB-B Champion (to Cross SF3)
```

### Group B Qualifiers Summary
1. **M39 Winner** → WB Winner (to Cross SF3)
2. **M40 Winner** → WB Runner-up (to Cross SF4)
3. **M51 Winner** → LB-A Champion (to Cross SF4)
4. **M52 Winner** → LB-B Champion (to Cross SF3)

---

## 🏆 CROSS-BRACKET FINALS (7 matches)

### Display Order: 31xxx-32xxx (Cross-Bracket prefix)

### Semi-Finals (4 matches) - Display Order: 31101-31104

**Cross-matching ensures WB vs LB balance:**

```
M53: Group A WB Winner (M13W) vs Group B LB-B Champion (M52W)
     → Winner to M57 (Final 1)
     Display Order: 31101

M54: Group A WB Runner-up (M14W) vs Group B LB-A Champion (M51W)
     → Winner to M57 (Final 1)
     Display Order: 31102

M55: Group B WB Winner (M39W) vs Group A LB-B Champion (M26W)
     → Winner to M58 (Final 2)
     Display Order: 31103

M56: Group B WB Runner-up (M40W) vs Group A LB-A Champion (M25W)
     → Winner to M58 (Final 2)
     Display Order: 31104
```

### Finals (2 matches) - Display Order: 32101-32102

```
M57: M53 Winner vs M54 Winner → Winner to M59 (Grand Final)
     Display Order: 32101

M58: M55 Winner vs M56 Winner → Winner to M59 (Grand Final)
     Display Order: 32102
```

### Grand Final (1 match) - Display Order: 33101

```
M59: M57 Winner vs M58 Winner → CHAMPION
     Display Order: 33101
```

---

## 📋 Display Order System

**Formula**: `(group × 10000) + (bracket_type × 1000) + (round × 100) + position`

**Group Priority**:
- Group A: 1xxxx (11xxx WB, 12xxx LB-A, 13xxx LB-B)
- Group B: 2xxxx (21xxx WB, 22xxx LB-A, 23xxx LB-B)
- Cross Finals: 3xxxx (31xxx Semis, 32xxx Finals, 33xxx GF)

**Examples**:
- Group A WB R1 M1: 11101
- Group A LB-A R2 M2: 12202
- Group B WB R3 M1: 21301
- Cross SF1: 31101
- Grand Final: 33101

---

## 🎯 Standardized Match Fields

Each match must have:

```dart
{
  'tournament_id': tournamentId,
  'match_number': sequentialNumber,  // 1-55
  'bracket_type': 'WB' | 'LB-A' | 'LB-B' | 'CROSS' | 'GF',
  'bracket_group': 'A' | 'B' | null,
  'stage_round': roundNumber,
  'display_order': calculatedDisplayOrder,
  'winner_advances_to': displayOrderValue | null,
  'loser_advances_to': displayOrderValue | null,
  'player1_id': playerId | null,
  'player2_id': playerId | null,
  'status': 'pending',
}
```

**Bracket Types**:
- `WB` - Winner Bracket (Groups A & B)
- `LB-A` - Loser Branch A (from WB R1 losers)
- `LB-B` - Loser Branch B (from WB R2 losers)
- `CROSS` - Cross-Bracket Semi-Finals
- `GF` - Grand Final

**Bracket Groups**:
- `A` - Group A matches
- `B` - Group B matches
- `null` - Cross-Bracket Finals (applies to both groups)

---

## 🔄 Complete Advancement Map

### Group A (M1-M26)

**Winner Bracket**:
- M1-M8 (WB R1): winner → M9-M12, loser → M17-M20 (LB-A R1)
- M9-M12 (WB R2): winner → M13-M14, loser → M21-M22 (LB-B R1)
- M13-M14 (WB R3): winner → Cross Finals, **loser → null**

**Loser Branch A**:
- M17-M20 (LB-A R1): winner → M23-M24
- M23-M24 (LB-A R2): winner → M25
- M25 (LB-A R3): winner → Cross SF2 (M54 or M56)

**Loser Branch B**:
- M21-M22 (LB-B R1): winner → M26
- M26 (LB-B R2): winner → Cross SF1 (M53 or M55)

### Group B (M27-M52)

**Winner Bracket**:
- M27-M34 (WB R1): winner → M35-M38, loser → M43-M46 (LB-A R1)
- M35-M38 (WB R2): winner → M39-M40, loser → M47-M48 (LB-B R1)
- M39-M40 (WB R3): winner → Cross Finals, **loser → null**

**Loser Branch A**:
- M43-M46 (LB-A R1): winner → M49-M50
- M49-M50 (LB-A R2): winner → M51
- M51 (LB-A R3): winner → Cross SF4 (M56 or M54)

**Loser Branch B**:
- M47-M48 (LB-B R1): winner → M52
- M52 (LB-B R2): winner → Cross SF3 (M55 or M53)

### Cross-Bracket Finals (M53-M59)

**Semi-Finals**:
- M53-M56: winner → M57 or M58

**Finals**:
- M57-M58: winner → M59

**Grand Final**:
- M59: winner → Champion (no advancement)

---

## ✅ Summary

**Total Structure**:
- Group A: 24 matches (14 WB + 7 LB-A + 3 LB-B)
- Group B: 24 matches (14 WB + 7 LB-A + 3 LB-B)
- Cross Finals: 7 matches (4 semis + 2 finals + 1 GF)
- **Total: 55 matches**

**Qualifiers**: 8 players (4 from each group)
- Each group: 2 WB + 1 LB-A + 1 LB-B

**Fairness**: Every branch (WB, LB-A, LB-B) gets representation in finals!
