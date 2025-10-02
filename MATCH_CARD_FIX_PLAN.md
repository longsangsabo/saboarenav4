# VẤN ĐỀ VÀ FIX PLAN

## 🔍 2 VẤN ĐỀ CHÍNH:

### 1. **Match Card hiển thị progression SAI** (Dòng 569)

**Hiện tại:**
```dart
'R${roundNumber}M$matchNumber → R${roundNumber + 1}M${(matchNumber + 1) ~/ 2}'
```

**Vấn đề:**
- Hardcode công thức cũ
- KHÔNG dùng `winner_advances_to` từ database
- Với Loser Bracket sẽ hiển thị sai hoàn toàn!

**Ví dụ sai:**
- Match 16 (LB R1) hiển thị: `R101M16 → R102M8` ❌
- Nhưng thực tế: `Match 16 → Match 24` (winner_advances_to = 24)

**Cần fix:**
```dart
// Đọc từ database
final winnerTo = match['winner_advances_to'];
final loserTo = match['loser_advances_to'];

// Hiển thị:
'Match $matchNumber → W:${winnerTo ?? 'END'}, L:${loserTo ?? 'OUT'}'
// Hoặc đơn giản hơn:
'Match $matchNumber'
```

---

### 2. **Filter Rounds có thể KHÔNG khớp với structure**

**Hiện tại:** Code filter dựa vào `round_number`:
```dart
Set<int> uniqueRounds = _matches
  .map((m) => (m['round'] ?? m['round_number'] ?? 1) as int)
  .toSet();
```

**Database structure:**
- WB R1: round_number = 1 → Tab "VÒNG 1" ✅
- WB R2: round_number = 2 → Tab "VÒNG 2" ✅  
- WB R3: round_number = 3 → Tab "VÒNG 3" ✅
- WB R4: round_number = 4 → Tab "VÒNG 4" ✅
- **LB R1**: round_number = 101 → Tab "BẢNG THUA A1" ✅
- **LB R2**: round_number = 102 → Tab "BẢNG THUA A2" ✅
- **LB R3**: round_number = 103 → Tab "BẢNG THUA A3" ✅
- **LB R4**: round_number = 104 → Tab "VÒNG 104" ❌
- **GF**: round_number = 999 → Tab "VÒNG 999" ❌

**Cần fix `_getRoundName`** để nhận diện:
```dart
case 104: return 'BẢNG THUA A4';
case 999: return 'CHUNG KẾT';
```

---

## 🛠️ ACTION PLAN:

### Fix 1: Match Card Display (HIGH PRIORITY)
**File:** `match_management_tab.dart` line 569

**Option A - Đơn giản (KHUYẾN NGHỊ):**
```dart
Text(
  'Match $matchNumber',
  style: TextStyle(
    fontSize: 11.sp,
    fontWeight: FontWeight.bold,
    color: AppTheme.primaryLight,
  ),
)
```

**Option B - Hiển thị đầy đủ:**
```dart
final winnerTo = match['winner_advances_to'];
final loserTo = match['loser_advances_to'];

String matchInfo = 'Match $matchNumber';
if (winnerTo != null) {
  matchInfo += ' → M$winnerTo';
}
if (loserTo != null) {
  matchInfo += ' (L→M$loserTo)';
}

Text(matchInfo, ...)
```

### Fix 2: Round Name Display  
**File:** `match_management_tab.dart` line 47-60

**Thêm:**
```dart
case 104: return 'BẢNG THUA A4';
case 999: return 'CHUNG KẾT';
```

---

## 🎯 KẾT QUẢ MONG ĐỢI:

### Trước fix:
```
Card: R101M16 → R102M8  ❌ SAI!
```

### Sau fix:
```
Card: Match 16  ✅ ĐƠN GIẢN, ĐÚNG!
hoặc
Card: Match 16 → M24  ✅ CHÍNH XÁC!
```

---

## 📋 TESTING CHECKLIST:

- [ ] Winner Bracket cards hiển thị đúng
- [ ] Loser Bracket cards hiển thị đúng  
- [ ] Grand Final card hiển thị đúng
- [ ] Tab names đúng cho tất cả rounds
- [ ] Match progression dễ hiểu
