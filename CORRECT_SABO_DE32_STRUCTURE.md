# ✅ CORRECT SABO DE32 Structure - 55 Matches

## 📊 Overview - Two-Group System
- **Group A**: 26 matches (Modified DE16 for 16 players)
- **Group B**: 26 matches (Modified DE16 for 16 players)
- **Cross-Bracket Finals**: 3 matches (2 semifinals + 1 final)
- **Total**: 55 matches (no bracket reset)

---

## 🎯 Key Concept: Two-Group System

SABO DE32 **CHIA 32 PLAYERS THÀNH 2 GROUPS** (không phải single bracket)!

**Group A (P1-P16)**: Chạy Modified DE16 → produces 2 qualifiers:
- 1st place (Group A Winner)
- 2nd place (Group A Runner-up)

**Group B (P17-P32)**: Chạy Modified DE16 → produces 2 qualifiers:
- 1st place (Group B Winner)
- 2nd place (Group B Runner-up)

**Cross-Bracket Finals**: 4 qualifiers cross-match:
- SF1: Group A Winner vs Group B Runner-up
- SF2: Group A Runner-up vs Group B Winner
- Final: SF1 Winner vs SF2 Winner

---

## 🎯 Key Differences from SABO DE16

| Feature | SABO DE16 | SABO DE32 |
|---------|-----------|-----------|
| **System** | Single Bracket | **Two-Group System** |
| Total Matches | 27 | 55 |
| Structure | WB + LB-A + LB-B + Finals | Group A + Group B + Cross Finals |
| Players per Group | 16 (all) | 16 (split into 2 groups) |
| Group Format | SABO DE16 | Modified DE16 (26 matches) |
| Finals Source | 2 WB + 2 LB | 2 from Group A + 2 from Group B |
| Finals Matches | 3 (2 semis + final) | 3 (2 semis + final) |

**Critical Difference**: SABO DE32 uses **parallel group tournaments**, not a single larger bracket!

---

## 🏆 GROUP A - Modified DE16 (26 matches)

### Display Order: 1xxx (Group A prefix)

**Structure**: Same as regular DE16 but modified finals
- Winners Bracket: 15 matches (8+4+2+1)
- Losers Bracket: 11 matches
- **NO SABO-style finals** - just regular DE16 finals

**Winners Bracket** (Display Order: 1101-1401):
- WB R1: M1-M8 (1101-1108)
- WB R2: M9-M12 (1201-1204)
- WB R3: M13-M14 (1301-1302)
- WB R4 Final: M15 (1401)

**Losers Bracket** (Display Order: 1501-1606):
- LB R1: M16-M19 (1501-1504)
- LB R2: M20-M23 (1505-1508)
- LB R3: M24-M25 (1601-1602)
- LB R4: M26 (1701)

**Grand Final** (Display Order: 1801):
- GF: M27 (1801) - WB winner vs LB winner
  - Winner → Cross-Bracket SF (as Group A Winner)
  - Loser → Cross-Bracket SF (as Group A Runner-up)

**Total Group A**: 15 + 11 + 1 = **27 matches**

⚠️ Wait, service says 26 matches per group, not 27! Let me check...

Actually, looking at the service comment:
```
Each Group Structure (26 matches):
- Winners Bracket: 15 matches (8+4+2+1)
- Losers Bracket: 11 matches
```

So it's: 15 + 11 = 26 (no separate GF, the "final" is WB R4!)

**Corrected**: Group A produces winner (from WB R4) + runner-up (from LB final)

---

## 🏆 GROUP B - Modified DE16 (26 matches)

### Display Order: 2xxx (Group B prefix)

**Structure**: Identical to Group A but with different players
- Winners Bracket: 15 matches (8+4+2+1)
- Losers Bracket: 11 matches
- Produces: 1 winner + 1 runner-up

**Winners Bracket** (Display Order: 2101-2401):
- WB R1: M28-M35 (2101-2108)
- WB R2: M36-M39 (2201-2204)
- WB R3: M40-M41 (2301-2302)
- WB R4 Final: M42 (2401) → Group B Winner

**Losers Bracket** (Display Order: 2501-2701):
- LB R1: M43-M46 (2501-2504)
- LB R2: M47-M50 (2505-2508)
- LB R3: M51-M52 (2601-2602)
- LB R4 Final: M53 (2701) → Group B Runner-up

**Total Group B**: 15 + 11 = **26 matches**

---

## 🏅 CROSS-BRACKET FINALS (3 matches)

### Display Order: 3xxx (Finals prefix)

**4 Qualifiers**:
- Group A Winner (from M15 WB R4)
- Group A Runner-up (from M26 LB R4)
- Group B Winner (from M42 WB R4)
- Group B Runner-up (from M53 LB R4)

**Match Structure**:

### Semifinal 1 (Display Order: 3101)
| Match | Display | Receives | Winner → |
|-------|---------|----------|----------|
| 54 | 3101 | Group A Winner vs Group B Runner-up | 3201 (Final) |

### Semifinal 2 (Display Order: 3102)
| Match | Display | Receives | Winner → |
|-------|---------|----------|----------|
| 55 | 3102 | Group A Runner-up vs Group B Winner | 3201 (Final) |

### SABO DE32 Final (Display Order: 3201)
| Match | Display | Receives | Winner → |
|-------|---------|----------|----------|
| 56 | 3201 | SF1 Winner vs SF2 Winner | null (CHAMPION!) |

**Total Finals**: 3 matches

---

## 🎯 Display Order Formula

```
display_order = (group_priority × 10000) + (bracket_priority × 1000) + (stage_round × 100) + match_position

Group A (priority = 1):
- WB R1 M1: (1 × 10000) + (1 × 1000) + (1 × 100) + 1 = 11101
- LB R4 M1: (1 × 10000) + (2 × 1000) + (4 × 100) + 1 = 12401

Group B (priority = 2):
- WB R1 M1: (2 × 10000) + (1 × 1000) + (1 × 100) + 1 = 21101
- LB R4 M1: (2 × 10000) + (2 × 1000) + (4 × 100) + 1 = 22401

Cross-Bracket Finals (priority = 3):
- SF1: (3 × 10000) + (1 × 1000) + (1 × 100) + 1 = 31101
- SF2: (3 × 10000) + (1 × 1000) + (1 × 100) + 2 = 31102
- Final: (3 × 10000) + (2 × 1000) + (1 × 100) + 1 = 32101
```

---

## ✅ Match Count Breakdown

```
Group A:
  WB: 8 + 4 + 2 + 1 = 15
  LB: 4 + 4 + 2 + 1 = 11
  Total: 26 matches

Group B:
  WB: 8 + 4 + 2 + 1 = 15
  LB: 4 + 4 + 2 + 1 = 11
  Total: 26 matches

Cross-Bracket Finals:
  SF1 + SF2 + Final = 3 matches

TOTAL: 26 + 26 + 3 = 55 matches
```

---

## 🔧 Implementation Notes

1. **Group Separation**: Players 1-16 go to Group A, 17-32 go to Group B
2. **Parallel Execution**: Both groups run simultaneously
3. **No Inter-Group Matches**: Until cross-bracket finals
4. **Qualification**: Top 2 from each group advance to finals
5. **Cross-Matching**: Winner from one group plays runner-up from other
6. **No Bracket Reset**: Finals is single elimination

---

## 📝 Bracket Type Values

Using `bracket_type` + `bracket_group` fields:

**Group A Matches**:
- `bracket_type: 'WB', bracket_group: 'A'` - Winner Bracket Group A
- `bracket_type: 'LB', bracket_group: 'A'` - Loser Bracket Group A

**Group B Matches**:
- `bracket_type: 'WB', bracket_group: 'B'` - Winner Bracket Group B
- `bracket_type: 'LB', bracket_group: 'B'` - Loser Bracket Group B

**Finals Matches**:
- `bracket_type: 'CROSS', bracket_group: 'SF'` - Cross-Bracket Semifinals
- `bracket_type: 'CROSS', bracket_group: 'FINAL'` - Cross-Bracket Final

---

## 🎮 Tournament Flow

```
32 Players
    ↓
Split into 2 Groups
    ↓
┌──────────────────┬──────────────────┐
│   Group A (16)   │   Group B (16)   │
│                  │                  │
│  Modified DE16   │  Modified DE16   │
│   (26 matches)   │   (26 matches)   │
│                  │                  │
│  → Winner        │  → Winner        │
│  → Runner-up     │  → Runner-up     │
└──────────────────┴──────────────────┘
          ↓                ↓
    4 Qualifiers Total
          ↓
  Cross-Bracket Finals
          ↓
   ┌─────────────┐
   │ SF1: A1 v B2│
   │ SF2: A2 v B1│
   └─────────────┘
          ↓
     SABO Final
          ↓
      CHAMPION
```

---

## ⚠️ Critical Differences from SABO DE16

1. **TWO SEPARATE GROUPS**: Not a single large bracket
2. **Modified DE16 per group**: Each group is essentially DE16 without SABO finals
3. **Cross-matching**: Winners/runners-up from different groups face each other
4. **Fair competition**: Ensures groups mix at finals stage
5. **Shorter per group**: 26 matches per group vs 31 in full DE16

This format balances competition time while ensuring fair cross-group finals!

