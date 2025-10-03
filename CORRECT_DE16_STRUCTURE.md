# ✅ CORRECT DE16 Structure - 32 Matches

## 📊 Overview
- **Winner Bracket**: 15 matches (4 rounds)
- **Loser Bracket**: 15 matches (6 rounds) 
- **Grand Finals**: 2 matches (GF1 + GF2 Reset conditional)
- **Total**: 31-32 matches (depending on GF reset)

---

## 🏆 WINNER BRACKET (15 matches)

### WB Round 1 - 8 matches (Display Order: 1101-1108)
| Match | Display | Players | Winner → | Loser → |
|-------|---------|---------|----------|---------|
| 1 | 1101 | P1 vs P2 | 1201 (M9) | 2101 (M16) |
| 2 | 1102 | P3 vs P4 | 1201 (M9) | 2101 (M16) |
| 3 | 1103 | P5 vs P6 | 1202 (M10) | 2102 (M17) |
| 4 | 1104 | P7 vs P8 | 1202 (M10) | 2102 (M17) |
| 5 | 1105 | P9 vs P10 | 1203 (M11) | 2103 (M18) |
| 6 | 1106 | P11 vs P12 | 1203 (M11) | 2103 (M18) |
| 7 | 1107 | P13 vs P14 | 1204 (M12) | 2104 (M19) |
| 8 | 1108 | P15 vs P16 | 1204 (M12) | 2104 (M19) |

**Logic**: 8 losers → 4 LB R1 matches (2 losers per match)

### WB Round 2 - 4 matches (Display Order: 1201-1204)
| Match | Display | Winner → | Loser → |
|-------|---------|----------|---------|
| 9 | 1201 | 1301 (M13) | 2201 (M20) |
| 10 | 1202 | 1301 (M13) | 2202 (M21) |
| 11 | 1203 | 1302 (M14) | 2203 (M22) |
| 12 | 1204 | 1302 (M14) | 2204 (M23) |

### WB Round 3 - 2 matches (Display Order: 1301-1302)
| Match | Display | Winner → | Loser → |
|-------|---------|----------|---------|
| 13 | 1301 | 1401 (M15) | 2401 (M26) |
| 14 | 1302 | 1401 (M15) | 2402 (M27) |

### WB Round 4 / Final - 1 match (Display Order: 1401)
| Match | Display | Winner → | Loser → |
|-------|---------|----------|---------|
| 15 | 1401 | 3101 (GF) | 2601 (M29) |

---

## 💔 LOSER BRACKET (15 matches)

### LB Round 1 - 4 matches (Display Order: 2101-2104)
| Match | Display | Receives | Winner → | Loser → |
|-------|---------|----------|----------|---------|
| 16 | 2101 | Loser M1 vs Loser M2 | 2201 (M20) | ELIMINATED |
| 17 | 2102 | Loser M3 vs Loser M4 | 2202 (M21) | ELIMINATED |
| 18 | 2103 | Loser M5 vs Loser M6 | 2203 (M22) | ELIMINATED |
| 19 | 2104 | Loser M7 vs Loser M8 | 2204 (M23) | ELIMINATED |

**Logic**: 8 WB R1 losers → 4 matches (paired 1+2, 3+4, 5+6, 7+8)

### LB Round 2 - 4 matches (Display Order: 2201-2204)
| Match | Display | Receives | Winner → | Loser → |
|-------|---------|----------|----------|---------|
| 20 | 2201 | Winner M16 vs Loser M9 | 2301 (M24) | ELIMINATED |
| 21 | 2202 | Winner M17 vs Loser M10 | 2301 (M24) | ELIMINATED |
| 22 | 2203 | Winner M18 vs Loser M11 | 2302 (M25) | ELIMINATED |
| 23 | 2204 | Winner M19 vs Loser M12 | 2302 (M25) | ELIMINATED |

**Logic**: 4 LB R1 winners merge with 4 WB R2 losers

### LB Round 3 - 2 matches (Display Order: 2301-2302)
| Match | Display | Receives | Winner → | Loser → |
|-------|---------|----------|----------|---------|
| 24 | 2301 | Winner M20 vs Winner M21 | 2401 (M26) | ELIMINATED |
| 25 | 2302 | Winner M22 vs Winner M23 | 2402 (M27) | ELIMINATED |

**Logic**: 4 LB R2 winners → 2 matches

### LB Round 4 - 2 matches (Display Order: 2401-2402)
| Match | Display | Receives | Winner → | Loser → |
|-------|---------|----------|----------|---------|
| 26 | 2401 | Winner M24 vs Loser M13 | 2501 (M28) | ELIMINATED |
| 27 | 2402 | Winner M25 vs Loser M14 | 2501 (M28) | ELIMINATED |

**Logic**: 2 LB R3 winners merge with 2 WB R3 losers

### LB Round 5 - 1 match (Display Order: 2501)
| Match | Display | Receives | Winner → | Loser → |
|-------|---------|----------|----------|---------|
| 28 | 2501 | Winner M26 vs Winner M27 | 2601 (M29) | ELIMINATED |

**Logic**: 2 LB R4 winners → 1 match

### LB Round 6 / Final - 1 match (Display Order: 2601)
| Match | Display | Receives | Winner → | Loser → |
|-------|---------|----------|----------|---------|
| 29 | 2601 | Winner M28 vs Loser M15 (WB Final) | 3101 (GF) | ELIMINATED |

**Logic**: LB R5 winner merges with WB Final loser

---

## 🏅 GRAND FINALS (2 matches)

### GF1 - 1 match (Display Order: 3101)
| Match | Display | Receives | Winner → | Loser → | Special |
|-------|---------|----------|----------|---------|---------|
| 30 | 3101 | WB Final winner vs LB Final winner | null/3102 | null | Conditional |

**Logic**:
- If **WB Champion wins** → TOURNAMENT ENDS (WB Champion = Champion, LB Champion = Runner-up)
- If **LB Champion wins** → CREATE Match 31 (Bracket Reset)

### GF2 - Reset (Display Order: 3102) - CONDITIONAL
| Match | Display | Receives | Winner → | Loser → | Special |
|-------|---------|----------|----------|---------|---------|
| 31 | 3102 | Same 2 players rematch | null | null | Reset match |

**Logic**: 
- Only created if LB Champion wins GF1
- Winner of this match = TOURNAMENT CHAMPION
- Both players have lost once (fair)

---

## 🎯 Display Order Formula

```
display_order = (bracket_priority × 1000) + (stage_round × 100) + match_position

Winner Bracket (priority = 1):
- WB R1 M1: (1 × 1000) + (1 × 100) + 1 = 1101
- WB R4 Final: (1 × 1000) + (4 × 100) + 1 = 1401

Loser Bracket (priority = 2):
- LB R1 M1: (2 × 1000) + (1 × 100) + 1 = 2101
- LB R6 Final: (2 × 1000) + (6 × 100) + 1 = 2601

Grand Final (priority = 3):
- GF1: (3 × 1000) + (1 × 100) + 1 = 3101
- GF2 Reset: (3 × 1000) + (1 × 100) + 2 = 3102
```

---

## ✅ Advancement Map Summary

```dart
// WB R1 (8 matches → display_order 1101-1108)
map[1] = {'winner': 1201, 'loser': 2101};
map[2] = {'winner': 1201, 'loser': 2101};
map[3] = {'winner': 1202, 'loser': 2102};
map[4] = {'winner': 1202, 'loser': 2102};
map[5] = {'winner': 1203, 'loser': 2103};
map[6] = {'winner': 1203, 'loser': 2103};
map[7] = {'winner': 1204, 'loser': 2104};
map[8] = {'winner': 1204, 'loser': 2104};

// WB R2 (4 matches → display_order 1201-1204)
map[9] = {'winner': 1301, 'loser': 2201};
map[10] = {'winner': 1301, 'loser': 2202};
map[11] = {'winner': 1302, 'loser': 2203};
map[12] = {'winner': 1302, 'loser': 2204};

// WB R3 (2 matches → display_order 1301-1302)
map[13] = {'winner': 1401, 'loser': 2401};
map[14] = {'winner': 1401, 'loser': 2402};

// WB R4 Final (1 match → display_order 1401)
map[15] = {'winner': 3101, 'loser': 2601};

// LB R1 (4 matches → display_order 2101-2104)
map[16] = {'winner': 2201, 'loser': null};
map[17] = {'winner': 2202, 'loser': null};
map[18] = {'winner': 2203, 'loser': null};
map[19] = {'winner': 2204, 'loser': null};

// LB R2 (4 matches → display_order 2201-2204)
map[20] = {'winner': 2301, 'loser': null};
map[21] = {'winner': 2301, 'loser': null};
map[22] = {'winner': 2302, 'loser': null};
map[23] = {'winner': 2302, 'loser': null};

// LB R3 (2 matches → display_order 2301-2302)
map[24] = {'winner': 2401, 'loser': null};
map[25] = {'winner': 2402, 'loser': null};

// LB R4 (2 matches → display_order 2401-2402)
map[26] = {'winner': 2501, 'loser': null};
map[27] = {'winner': 2501, 'loser': null};

// LB R5 (1 match → display_order 2501)
map[28] = {'winner': 2601, 'loser': null};

// LB R6 Final (1 match → display_order 2601)
map[29] = {'winner': 3101, 'loser': null};

// GF1 (1 match → display_order 3101)
map[30] = {'winner': null, 'loser': null};  // Conditional: check who wins

// GF2 Reset (1 match → display_order 3102) - ONLY IF CREATED
map[31] = {'winner': null, 'loser': null};  // Final match
```

---

## 🔧 Implementation Notes

1. **Match Creation**: Create 30 matches initially (M1-M30)
2. **Match 31 Creation**: Create dynamically when LB Champion wins GF1
3. **Advancement Logic**: Use `display_order` values for `winner_advances_to` and `loser_advances_to`
4. **UI Display**: Sort matches by `display_order` for correct bracket rendering
5. **Bracket Reset Detection**: When M30 completes, check winner:
   - If `winner_id` == WB Final winner (from M15) → Tournament ends
   - If `winner_id` == LB Final winner (from M29) → Create M31

---

## 📝 Round Tabs Display

Using `bracket_type` + `stage_round`:

**Winner Bracket**:
- VÒNG 1 (WB R1, stage_round=1)
- VÒNG 2 (WB R2, stage_round=2)
- VÒNG 3 (WB R3, stage_round=3)
- VÒNG 4 (WB R4, stage_round=4)

**Loser Bracket**:
- BẢNG THUA 1 (LB R1, stage_round=1)
- BẢNG THUA 2 (LB R2, stage_round=2)
- BẢNG THUA 3 (LB R3, stage_round=3)
- BẢNG THUA 4 (LB R4, stage_round=4)
- BẢNG THUA 5 (LB R5, stage_round=5)
- BẢNG THUA 6 (LB R6, stage_round=6)

**Grand Final**:
- CHUNG KẾT (GF, stage_round=1 or 2)

**Total**: 11 tabs (4 WB + 6 LB + 1 GF)
