# Match Schema Standardization Proposal

## 🎯 Mục tiêu
Chuẩn hóa cấu trúc matches table để hỗ trợ tất cả format giải đấu, dễ query, dễ scale.

## 📊 Schema Mới Đề Xuất

### Thêm Columns:

```sql
ALTER TABLE matches ADD COLUMN IF NOT EXISTS bracket_type VARCHAR(10);  -- 'WB', 'LB', 'GF'
ALTER TABLE matches ADD COLUMN IF NOT EXISTS bracket_group VARCHAR(5);  -- 'A', 'B', 'C', 'D' (cho DE32+)
ALTER TABLE matches ADD COLUMN IF NOT EXISTS stage_round INT;           -- Round trong stage đó (1, 2, 3...)
ALTER TABLE matches ADD COLUMN IF NOT EXISTS display_order INT;         -- Thứ tự hiển thị
```

### Giải thích các trường:

#### 1. `bracket_type` (VARCHAR(10))
- **WB**: Winner Bracket
- **LB**: Loser Bracket  
- **GF**: Grand Final
- **SE**: Single Elimination (không có loser bracket)
- **RR**: Round Robin

#### 2. `bracket_group` (VARCHAR(5))
- **NULL**: Cho DE16 và nhỏ hơn (không chia group)
- **'A', 'B', 'C', 'D'**: Cho DE32+ chia nhiều nhóm
- Ví dụ DE32:
  - WB có 2 groups: A, B
  - LB có 4 groups: A1, A2, B1, B2

#### 3. `stage_round` (INT)
- Round number TRONG stage/bracket đó
- **Winner Bracket**: 1, 2, 3, 4 (R1, R2, R3, R4)
- **Loser Bracket**: 1, 2, 3, 4, 5, 6 (LB R1 đến LB R6)
- **Grand Final**: 1

#### 4. `display_order` (INT)
- Thứ tự hiển thị từ trái sang phải, trên xuống dưới
- Dùng để render bracket UI theo đúng vị trí
- Tự động tính toán dựa trên bracket_type + stage_round + match_number

## 🔄 Migration Plan

### Step 1: Add Columns
```sql
-- Add new columns with default values
ALTER TABLE matches 
ADD COLUMN IF NOT EXISTS bracket_type VARCHAR(10) DEFAULT 'WB',
ADD COLUMN IF NOT EXISTS bracket_group VARCHAR(5),
ADD COLUMN IF NOT EXISTS stage_round INT DEFAULT 1,
ADD COLUMN IF NOT EXISTS display_order INT DEFAULT 0;
```

### Step 2: Update Existing Data

```sql
-- Update DE16 matches
UPDATE matches 
SET 
  bracket_type = CASE
    WHEN round_number BETWEEN 1 AND 4 THEN 'WB'
    WHEN round_number BETWEEN 101 AND 106 THEN 'LB'
    WHEN round_number = 999 THEN 'GF'
    ELSE 'WB'
  END,
  stage_round = CASE
    WHEN round_number BETWEEN 1 AND 4 THEN round_number
    WHEN round_number BETWEEN 101 AND 106 THEN round_number - 100
    WHEN round_number = 999 THEN 1
    ELSE round_number
  END,
  bracket_group = NULL  -- DE16 không cần group
WHERE bracket_format = 'double_elimination';
```

### Step 3: Update display_order
```sql
-- Calculate display_order for rendering
-- Formula: (bracket_priority * 1000) + (stage_round * 100) + match_number_in_round

UPDATE matches 
SET display_order = 
  CASE bracket_type
    WHEN 'WB' THEN (1 * 1000) + (stage_round * 100) + (match_number % 100)
    WHEN 'LB' THEN (2 * 1000) + (stage_round * 100) + (match_number % 100)
    WHEN 'GF' THEN (3 * 1000) + (stage_round * 100) + (match_number % 100)
    ELSE match_number
  END
WHERE bracket_format = 'double_elimination';
```

## 📋 Ví Dụ DE16 Sau Khi Migrate:

| match_number | round_number | bracket_type | bracket_group | stage_round | display_order | Notes |
|--------------|--------------|--------------|---------------|-------------|---------------|-------|
| 1 | 1 | WB | NULL | 1 | 1101 | WB R1 M1 |
| 8 | 1 | WB | NULL | 1 | 1108 | WB R1 M8 |
| 9 | 2 | WB | NULL | 2 | 1201 | WB R2 M1 |
| 15 | 4 | WB | NULL | 4 | 1401 | WB R4 Final |
| 16 | 101 | LB | NULL | 1 | 2101 | LB R1 M1 |
| 23 | 101 | LB | NULL | 1 | 2108 | LB R1 M8 |
| 30 | 104 | LB | NULL | 4 | 2401 | LB R4 Final |
| 31 | 999 | GF | NULL | 1 | 3101 | Grand Final |

## 📋 Ví Dụ DE32 Structure:

### Winner Bracket (16 matches):
```
WB R1: 16 matches (8 group A, 8 group B)
  - Match 1-8: bracket_type='WB', bracket_group='A', stage_round=1
  - Match 9-16: bracket_type='WB', bracket_group='B', stage_round=1
  
WB R2: 8 matches (4 group A, 4 group B)
  - Match 17-20: bracket_type='WB', bracket_group='A', stage_round=2
  - Match 21-24: bracket_type='WB', bracket_group='B', stage_round=2
  
WB R3: 4 matches (2 group A, 2 group B)
WB R4: 2 matches (Semi-finals)
WB R5: 1 match (Finals)
```

### Loser Bracket (32 matches):
```
LB R1: 16 matches (4 per group A1, A2, B1, B2)
LB R2: 8 matches (merge with WB losers)
LB R3-R6: Progressive elimination
```

## 🎨 UI Benefits:

### 1. Dễ dàng render tabs:
```dart
// Get unique stages
final stages = matches
  .map((m) => '${m['bracket_type']} R${m['stage_round']}')
  .toSet()
  .toList()
  ..sort();

// Result: ['WB R1', 'WB R2', 'WB R3', 'WB R4', 'LB R1', 'LB R2', 'LB R3', 'LB R4', 'GF R1']
```

### 2. Dễ query matches theo bracket:
```dart
// Get all Winner Bracket matches
final wbMatches = matches.where((m) => m['bracket_type'] == 'WB').toList();

// Get Loser Bracket Round 2
final lbR2 = matches.where((m) => 
  m['bracket_type'] == 'LB' && m['stage_round'] == 2
).toList();
```

### 3. Dễ display tên round:
```dart
String getRoundName(String bracketType, int stageRound, String? group) {
  if (bracketType == 'WB') {
    return 'VÒNG $stageRound${group != null ? ' ($group)' : ''}';
  } else if (bracketType == 'LB') {
    return 'BẢNG THUA R$stageRound${group != null ? ' ($group)' : ''}';
  } else if (bracketType == 'GF') {
    return 'CHUNG KẾT';
  }
  return 'VÒNG $stageRound';
}
```

## 🔧 Code Changes Required:

### 1. Update HardcodedDoubleEliminationService:
```dart
// Add bracket metadata to each match
allMatches.add({
  'tournament_id': tournamentId,
  'round_number': 1,        // Keep for backward compatibility
  'match_number': i,
  'bracket_type': 'WB',     // NEW
  'bracket_group': null,    // NEW - null for DE16
  'stage_round': 1,         // NEW
  'display_order': 1100 + i, // NEW
  'player1_id': participantIds[(i-1) * 2],
  'player2_id': participantIds[(i-1) * 2 + 1],
  // ... rest of fields
});
```

### 2. Update TournamentService.getTournamentMatches():
```dart
return matches.map<Map<String, dynamic>>((match) {
  return {
    "matchId": match['id'],
    "round_number": match['round_number'] ?? 1,
    "bracket_type": match['bracket_type'],      // NEW
    "bracket_group": match['bracket_group'],    // NEW
    "stage_round": match['stage_round'],        // NEW
    "display_order": match['display_order'],    // NEW
    // ... rest of fields
  };
}).toList();
```

### 3. Update UI to use new fields:
```dart
// Group matches by bracket_type + stage_round
Map<String, List<Map>> groupMatchesByStage(List<Map> matches) {
  final grouped = <String, List<Map>>{};
  
  for (var match in matches) {
    final key = '${match['bracket_type']}_R${match['stage_round']}';
    grouped.putIfAbsent(key, () => []).add(match);
  }
  
  return grouped;
}
```

## ✅ Advantages:

1. **Chuẩn hóa**: Tất cả format dùng chung cấu trúc
2. **Scalable**: Dễ mở rộng cho DE32, DE64, DE128
3. **Query hiệu quả**: Filter theo bracket_type, stage_round
4. **UI rõ ràng**: Hiển thị tên round và group chính xác
5. **Backward compatible**: Giữ lại round_number cũ
6. **Display order**: Render bracket theo thứ tự đúng

## ⚠️ Trade-offs:

1. **Migration effort**: Phải update existing matches
2. **More columns**: Database schema phức tạp hơn
3. **Code changes**: Phải update nhiều service và UI

## 🚀 Implementation Priority:

1. **Phase 1**: Add columns và migrate existing data
2. **Phase 2**: Update HardcodedDoubleEliminationService
3. **Phase 3**: Update UI to use new fields
4. **Phase 4**: Deprecate round_number logic
5. **Phase 5**: Implement DE32 with groups

## 📝 Notes:

- Giữ lại `round_number` cho backward compatibility
- `bracket_type` + `stage_round` là primary way to identify rounds
- `display_order` giúp render bracket UI không cần logic phức tạp
- `bracket_group` chỉ dùng cho DE32+ (NULL cho DE16)

---

**Kết luận**: Schema này chuẩn hóa và mở rộng tốt cho mọi format giải đấu. Bạn nghĩ sao về đề xuất này? Có cần điều chỉnh gì không?
