# 🎱 Vietnamese Billiards Ranking System

## 📋 Overview
Sabo Arena uses a comprehensive Vietnamese billiards ranking system with 12 skill tiers, each with specific skill descriptions and ELO thresholds.

## 🏆 Rank Definitions

### **Rank Progression: K → K+ → I → I+ → H → H+ → G → G+ → F → F+ → E → E+**

| Rank | Vietnamese Name | ELO Range | Skill Description (Vietnamese) | Skill Description (English) |
|------|-----------------|-----------|--------------------------------|----------------------------|
| **K** | Tập Sự | 1000-1099 | 2-4 bi khi hình dễ; mới tập | 2-4 balls on easy layouts; beginner |
| **K+** | Tập Sự+ | 1100-1199 | Sát ngưỡng lên I | Close to advancing to I rank |
| **I** | Sơ Cấp | 1200-1299 | 3-5 bi; chưa điều được chấm | 3-5 balls; can't control cue ball yet |
| **I+** | Sơ Cấp+ | 1300-1399 | Sát ngưỡng lên H | Close to advancing to H rank |
| **H** | Trung Cấp | 1400-1499 | 5-8 bi; có thể "rùa" 1 chấm hình dễ | 5-8 balls; can play safe on easy layouts |
| **H+** | Trung Cấp+ | 1500-1599 | Chuẩn bị lên G | Preparing to advance to G rank |
| **G** | Khá | 1600-1699 | Clear 1 chấm + 3-7 bi kế; bắt đầu điều bi 3 băng | Clear 1 rack + 3-7 balls; starting 3-cushion control |
| **G+** | Khá+ | 1700-1799 | Trình phong trào "ngon"; sát ngưỡng lên F | Good amateur level; close to F rank |
| **F** | Giỏi | 1800-1899 | 60-80% clear 1 chấm, đôi khi phá 2 chấm | 60-80% clear 1 rack, sometimes break 2 racks |
| **F+** | Giỏi+ | 1900-1999 | Safety & spin control khá chắc; sát ngưỡng lên E | Solid safety & spin control; close to E rank |
| **E** | Xuất Sắc | 2000-2099 | 90-100% clear 1 chấm, 70% phá 2 chấm | 90-100% clear 1 rack, 70% break 2 racks |
| **E+** | Chuyên Gia | 2100+ | Điều bi phức tạp, safety chủ động; sát ngưỡng lên D | Complex cue ball control, proactive safety; close to D rank |

## 🎯 Rank Calculation Logic

### **ELO to Rank Conversion:**
```dart
String calculateRankFromElo(int eloRating) {
  if (eloRating >= 2100) return 'E+';
  if (eloRating >= 2000) return 'E';
  if (eloRating >= 1900) return 'F+';
  if (eloRating >= 1800) return 'F';
  if (eloRating >= 1700) return 'G+';
  if (eloRating >= 1600) return 'G';
  if (eloRating >= 1500) return 'H+';
  if (eloRating >= 1400) return 'H';
  if (eloRating >= 1300) return 'I+';
  if (eloRating >= 1200) return 'I';
  if (eloRating >= 1100) return 'K+';
  return 'K'; // 1000-1099
}
```

### **Rank to ELO Range:**
```dart
Map<String, Map<String, int>> getRankEloRanges() {
  return {
    'K': {'min': 1000, 'max': 1099},
    'K+': {'min': 1100, 'max': 1199},
    'I': {'min': 1200, 'max': 1299},
    'I+': {'min': 1300, 'max': 1399},
    'H': {'min': 1400, 'max': 1499},
    'H+': {'min': 1500, 'max': 1599},
    'G': {'min': 1600, 'max': 1699},
    'G+': {'min': 1700, 'max': 1799},
    'F': {'min': 1800, 'max': 1899},
    'F+': {'min': 1900, 'max': 1999},
    'E': {'min': 2000, 'max': 2099},
    'E+': {'min': 2100, 'max': 9999},
  };
}
```

## 🔢 Rank Values (For Calculations)

### **Sub-rank Value System:**
```dart
Map<String, int> getRankValues() {
  return {
    'K': 1,   'K+': 2,   // Beginner tier
    'I': 3,   'I+': 4,   // Basic tier  
    'H': 5,   'H+': 6,   // Intermediate tier
    'G': 7,   'G+': 8,   // Good tier
    'F': 9,   'F+': 10,  // Skilled tier
    'E': 11,  'E+': 12,  // Expert tier
  };
}
```

**Usage:** Rank differences calculated as `Math.abs(rank1_value - rank2_value)`
- Same rank: difference = 0
- Sub-rank difference: difference = 1 (K vs K+)
- Main rank difference: difference = 2 (K vs I)
- Max allowed: difference ≤ 4 (±2 main ranks)

## 📊 Rank Progression Rules

### **Automatic Rank Updates:**
1. **ELO Change** → Check new rank threshold
2. **Rank Up**: ELO crosses upper threshold + verification passed
3. **Rank Down**: ELO drops below lower threshold (immediate)
4. **Verification Required**: New users start UNRANKED until verified

### **Rank Protection:**
- **Grace Period**: 7 days after rank up before demotion possible
- **Minimum Games**: 10 games at current rank before demotion
- **Verification Lock**: Cannot rank up beyond verification level

## 🎮 Vietnamese Billiards Terminology

### **Core Terms:**
- **Chấm**: Rack (set of balls arranged for break)
- **Clear chấm**: Clear the entire rack
- **Phá chấm**: Break multiple racks in sequence  
- **Rùa**: Playing safe/defensive (literally "turtle")
- **Điều bi**: Cue ball control and positioning
- **3 băng**: 3-cushion billiards technique
- **Safety**: Defensive play to prevent opponent scoring

### **Skill Descriptions Context:**
- **"Ngon"**: Slang for "good/skilled" in Vietnamese gaming
- **"Phong trào"**: Amateur/recreational level
- **"Chủ động"**: Proactive/aggressive play style

## 🗄️ Database Schema

### **ranking_definitions table:**
```sql
CREATE TABLE ranking_definitions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  rank_code VARCHAR(5) NOT NULL UNIQUE,
  rank_name VARCHAR(50) NOT NULL,
  rank_name_vi VARCHAR(50) NOT NULL,
  min_elo INTEGER NOT NULL,
  max_elo INTEGER,
  skill_description TEXT NOT NULL,
  skill_description_vi TEXT NOT NULL,
  color_hex VARCHAR(7) NOT NULL,
  display_order INTEGER NOT NULL,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

### **Sample Data:**
```sql
INSERT INTO ranking_definitions VALUES
('K', 'Beginner', 'Tập Sự', 1000, 1099, '2-4 balls on easy layouts; beginner', '2-4 bi khi hình dễ; mới tập', '#8B4513', 1),
('K+', 'Beginner+', 'Tập Sự+', 1100, 1199, 'Close to advancing to I rank', 'Sát ngưỡng lên I', '#A0522D', 2),
-- ... (continue for all ranks)
```

## 🧪 Testing Examples

### **Rank Calculation Tests:**
```dart
void testRankCalculations() {
  assert(calculateRankFromElo(1050) == 'K');
  assert(calculateRankFromElo(1150) == 'K+');
  assert(calculateRankFromElo(1250) == 'I');
  assert(calculateRankFromElo(1850) == 'F');
  assert(calculateRankFromElo(2150) == 'E+');
}
```

### **Rank Difference Tests:**
```dart
void testRankDifferences() {
  assert(calculateRankDifference('K', 'K+') == 1);  // Sub-rank
  assert(calculateRankDifference('K', 'I') == 2);   // Main rank
  assert(calculateRankDifference('K', 'H') == 4);   // Max allowed
  assert(calculateRankDifference('K', 'G') == 6);   // Too large (invalid)
}
```

## 🔄 Update History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | Sep 2025 | Initial Vietnamese billiards ranking system |
| 1.1 | Sep 2025 | Added rank value calculations and progression rules |

---

*This ranking system reflects authentic Vietnamese billiards culture and skill progression.*