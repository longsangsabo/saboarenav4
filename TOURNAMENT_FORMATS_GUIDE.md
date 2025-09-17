# 📚 SƠ ĐỒ GIẢI ĐẤU - HƯỚNG DẪN TOÀN DIỆN
## Tournament Bracket Guide - Comprehensive Documentation

### 📋 Mục lục / Table of Contents

1. [**Single Elimination** - Loại trực tiếp](#1-single-elimination---loại-trực-tiếp)
2. [**Winner Takes All** - Người thắng nhận tất cả](#2-winner-takes-all---người-thắng-nhận-tất-cả)
3. [**Traditional Double Elimination** - Loại kép truyền thống](#3-traditional-double-elimination---loại-kép-truyền-thống)
4. [**Sabo Double Elimination DE16** - Loại kép Sabo 16 người](#4-sabo-double-elimination-de16---loại-kép-sabo-16-người)
5. [**Sabo Double Elimination DE32** - Loại kép Sabo 32 người](#5-sabo-double-elimination-de32---loại-kép-sabo-32-người)
6. [**Round Robin** - Vòng tròn](#6-round-robin---vòng-tròn)
7. [**Swiss System** - Hệ thống Swiss](#7-swiss-system---hệ-thống-swiss)
8. [**Parallel Groups** - Nhóm song song](#8-parallel-groups---nhóm-song-song)

---

## 1. Single Elimination - Loại trực tiếp

### 🎯 Khái niệm
**Single Elimination** là format giải đấu đơn giản nhất, mỗi người chơi chỉ cần **thua 1 trận là bị loại** khỏi giải đấu.

### 📊 Thông số kỹ thuật
- **Số người chơi**: 4-64 người
- **Loại**: Loại trực tiếp (single elimination)
- **Số vòng**: log₂(số người chơi)
- **Tốc độ**: Nhanh nhất (ít trận đấu)

### 🏗️ Cấu trúc sơ đồ

#### Ví dụ 8 người chơi:
```
Vòng 1 (Tứ kết)     Vòng 2 (Bán kết)    Vòng 3 (Chung kết)
Player1 ─┐
         ├─ W1 ─┐
Player2 ─┘      │
                ├─ W5 ─┐
Player3 ─┐      │      │
         ├─ W2 ─┘      │
Player4 ─┘             │
                       ├─ Champion
Player5 ─┐             │
         ├─ W3 ─┐      │
Player6 ─┘      │      │
                ├─ W6 ─┘
Player7 ─┐      │
         ├─ W4 ─┘
Player8 ─┘
```

### ⚖️ Ưu & Nhược điểm

#### ✅ Ưu điểm:
- **Nhanh gọn**: Ít trận đấu nhất
- **Dễ hiểu**: Cấu trúc đơn giản
- **Dễ tổ chức**: Không phức tạp
- **Thời gian ngắn**: Kết thúc nhanh

#### ❌ Nhược điểm:
- **Ít cơ hội**: Thua 1 trận là hết
- **Không công bằng**: May mắn ảnh hưởng lớn
- **Ít trận đấu**: Người chơi chơi ít

### 🏆 Phân chia giải thưởng
```
Vị trí 1 (Champion): 60%
Vị trí 2 (Runner-up): 40%
(Các vị trí khác không có giải)
```

### 📈 Khi nào sử dụng?
- **Giải đấu nhanh**: Thời gian hạn chế
- **Số người ít**: 4-16 người
- **Giải đấu đơn giản**: Không cần phức tạp
- **Test format**: Thử nghiệm hệ thống

---

## 2. Winner Takes All - Người thắng nhận tất cả

### 🎯 Khái niệm
**Winner Takes All** là biến thể của Single Elimination, nhưng **chỉ có người thắng cuối cùng nhận giải thưởng**, tất cả các vị trí khác không có gì.

### 📊 Thông số kỹ thuật
- **Số người chơi**: 4-32 người
- **Loại**: Loại trực tiếp (single elimination)
- **Bracket**: Winner only
- **Giải thưởng**: 100% cho champion

### 🏗️ Cấu trúc sơ đồ
Giống hệt **Single Elimination** nhưng chỉ có **Champion nhận 100% giải thưởng**.

#### Sơ đồ 16 người:
```
Round 1        Round 2       Round 3      Round 4
P1 ─┐
    ├─ W1 ─┐
P2 ─┘      │
           ├─ W9 ─┐
P3 ─┐      │      │
    ├─ W2 ─┘      │
P4 ─┘             │
                  ├─ W13 ─┐
P5 ─┐             │       │
    ├─ W3 ─┐      │       │
P6 ─┘      │      │       │
           ├─ W10 ─┘       │
P7 ─┐      │               │
    ├─ W4 ─┘               │
P8 ─┘                      │
                           ├─ 👑 WINNER
P9 ─┐                      │   (100% Prize)
    ├─ W5 ─┐               │
P10─┘      │               │
           ├─ W11 ─┐       │
P11─┐      │       │       │
    ├─ W6 ─┘       │       │
P12─┘              │       │
                   ├─ W14 ─┘
P13─┐              │
    ├─ W7 ─┐       │
P14─┘      │       │
           ├─ W12 ─┘
P15─┐      │
    ├─ W8 ─┘
P16─┘
```

### ⚖️ Ưu & Nhược điểm

#### ✅ Ưu điểm:
- **Động lực cao**: All-or-nothing tạo hứng thú
- **Giải thưởng lớn**: Winner nhận toàn bộ
- **Cạnh tranh khốc liệt**: Mọi trận đều quan trọng
- **Đơn giản**: Chỉ 1 người thắng

#### ❌ Nhược điểm:
- **Rủi ro cao**: 15/16 người về tay trắng
- **Không khuyến khích**: Thua sớm = mất hết
- **Bất công**: May mắn quyết định quá nhiều
- **Demotivating**: Đa số người chơi thất vọng

### 🏆 Phân chia giải thưởng
```
🥇 Champion: 100% 
🥈 Runner-up: 0%
🥉 3rd place: 0%
... All others: 0%
```

### 📈 Khi nào sử dụng?
- **High-stakes tournament**: Giải đấu có tính cạnh tranh cao
- **Jackpot events**: Sự kiện giải thưởng lớn
- **Quick tournaments**: Giải đấu nhanh với động lực cao
- **Special events**: Sự kiện đặc biệt

---

## 3. Traditional Double Elimination - Loại kép truyền thống

### 🎯 Khái niệm
**Traditional Double Elimination** cho phép mỗi người chơi **thua tối đa 2 trận** mới bị loại. Có 2 nhánh: **Winners Bracket** (nhánh thắng) và **Losers Bracket** (nhánh thua).

### 📊 Thông số kỹ thuật
- **Số người chơi**: 4-32 người
- **Loại**: Loại kép (double elimination)
- **Số vòng**: log₂(players) + log₂(players/2)
- **Nhánh**: 2 (Winners + Losers)
- **Grand Final**: Có thể có reset bracket

### 🏗️ Cấu trúc sơ đồ

#### Sơ đồ 8 người chơi:

```
WINNERS BRACKET (Nhánh thắng)
=================

WR1:    P1 ──┐
             ├── W1 ──┐
        P2 ──┘        │
                      ├── W5 ──┐
        P3 ──┐        │        │
             ├── W2 ──┘        │
        P4 ──┘                 │
                               ├── WF ──┐
        P5 ──┐                 │        │
             ├── W3 ──┐        │        │
        P6 ──┘        │        │        │
                      ├── W6 ──┘        │
        P7 ──┐        │                 │
             ├── W4 ──┘                 │
        P8 ──┘                          │
                                        │
LOSERS BRACKET (Nhánh thua)              │
================                        │
                                        │
LR1:    [P2,P4] ──┐                     │
                  ├── L1 ──┐             │
        [P6,P8] ──┘       │             │
                          │             │
LR2:    W2_loser ─────────┼── L3 ──┐    │
                          │        │    │
        [P1,P3] ──┐       │        │    │
                  ├── L2 ──┘        │    │
        [P5,P7] ──┘                 │    │
                                    │    │
LR3:    W6_loser ──────────────────┼── L4 ──┐
                                   │        │
                                   │        │
LR4:    WF_loser ──────────────────┼────────┼── LF
                                   │        │     │
                                   └────────┘     │
                                                  │
GRAND FINAL                                       │
===========                                       │
                                                  │
GF:     WF_winner ────────────────────────────────┼── CHAMPION
        LF_winner ────────────────────────────────┘
```

### 🔄 Luật Grand Final đặc biệt
1. **Nếu WF Winner thắng GF**: Champion ngay lập tức
2. **Nếu LF Winner thắng GF**: **Bracket Reset** - đấu thêm 1 trận nữa
3. Lý do: WF Winner chưa thua trận nào, cần thua 2 lần mới bị loại

### ⚖️ Ưu & Nhược điểm

#### ✅ Ưu điểm:
- **Công bằng hơn**: Cơ hội thứ 2 cho mọi người
- **Nhiều trận đấu**: Người chơi được chơi nhiều hơn
- **Ít may mắn**: Kỹ năng quan trọng hơn
- **Comeback story**: Có thể lội ngược từ Losers

#### ❌ Nhược điểm:
- **Phức tạp**: Khó hiểu cho người mới
- **Thời gian dài**: Nhiều trận đấu hơn
- **Tổ chức khó**: Cần quản lý 2 nhánh
- **Bracket reset**: Grand Final có thể rất dài

### 🏆 Phân chia giải thưởng
```
🥇 Champion: 50%
🥈 Runner-up: 30% 
🥉 3rd place: 15%
4th place: 5%
```

### 📈 Khi nào sử dụng?
- **Tournament chính thức**: Giải đấu quan trọng
- **Skill-based**: Muốn winner thực sự xứng đáng
- **Community events**: Sự kiện cộng đồng lớn
- **Championship**: Giải vô địch

---

## 4. Sabo Double Elimination DE16 - Loại kép Sabo 16 người

### 🎯 Khái niệm
**Sabo DE16** là format đặc biệt của SABO Arena, cải tiến từ Traditional Double Elimination với **2 Losers Branch** riêng biệt và **SABO Finals** độc đáo.

### 📊 Thông số kỹ thuật
- **Số người chơi**: Chính xác 16 người
- **Tổng số trận**: 27 trận
- **Cấu trúc**: WB(14) + LA(7) + LB(3) + Finals(3)
- **Losers Branch**: 2 nhánh A & B

### 🏗️ Cấu trúc sơ đồ chi tiết

#### SABO DE16 Architecture:
```
WINNERS BRACKET - 14 matches
==============

WR1: 8 matches (16→8)
P1──┐  P3──┐  P5──┐  P7──┐   P9──┐  P11─┐  P13─┐  P15─┐
    W1     W2     W3     W4      W5     W6     W7     W8
P2──┘  P4──┘  P6──┘  P8──┘  P10──┘  P12─┘  P14─┘  P16─┘

WR2: 4 matches (8→4)  
W1──┐     W3──┐     W5──┐     W7──┐
    W9        W10        W11        W12
W2──┘     W4──┘     W6──┘     W8──┘

WR3: 2 matches (4→2) - NO WINNERS FINAL!
W9──┐           W11──┐
    W13              W14
W10─┘           W12──┘

LOSERS BRANCH A - 7 matches
===============
(Nhận losers từ WR1)

LAR1: 4 matches (8→4)
[WR1 losers] ──→ L1, L2, L3, L4

LAR2: 2 matches (4→2)  
L1+L2 ──→ L5
L3+L4 ──→ L6

LAR3: 1 match (2→1)
L5+L6 ──→ L7 (LA Champion)

LOSERS BRANCH B - 3 matches  
===============
(Nhận losers từ WR2)

LBR1: 2 matches (4→2)
[WR2 losers] ──→ L8, L9

LBR2: 1 match (2→1)
L8+L9 ──→ L10 (LB Champion)

SABO FINALS - 3 matches
===========

SF1: W13 vs L7 (LA Champion) 
SF2: W14 vs L10 (LB Champion)
GF:  SF1_winner vs SF2_winner ──→ 🏆 CHAMPION
```

### 🔑 Đặc điểm độc đáo của Sabo DE16

#### 1. **Không có Winners Final**
- Traditional DE: WR3 → Winners Final
- Sabo DE16: WR3 tạo ra **2 winners** để vào SABO Finals

#### 2. **2 Losers Branch riêng biệt**
- **Branch A**: Xử lý losers từ WR1 (8 người)
- **Branch B**: Xử lý losers từ WR2 (4 người) 
- Mỗi branch tạo ra 1 champion riêng

#### 3. **SABO Finals đặc biệt**
- **4 qualifiers**: 2 từ WB + 2 từ LB
- **Semifinals**: Cross-matching
- **Grand Final**: Pure 1v1, không bracket reset

### ⚖️ Ưu & Nhược điểm

#### ✅ Ưu điểm:
- **Cân bằng hoàn hảo**: 2 WB vs 2 LB trong finals
- **Không bracket reset**: Grand Final luôn 1 trận
- **Fair distribution**: Cơ hội đều cho mọi người
- **Sabo signature**: Độc đáo của SABO Arena

#### ❌ Nhược điểm:
- **Phức tạp**: Cần hiểu 2 Losers Branch
- **Fixed 16**: Chỉ dành cho đúng 16 người
- **Learning curve**: Người mới khó hiểu

### 🏆 Phân chia giải thưởng Sabo DE16
```
🥇 Champion: 40%
🥈 Runner-up: 25%
🥉 3rd place: 15% 
4th place: 10%
5th-8th place: 2.5% each
```

### 📈 Khi nào sử dụng?
- **16 người chính xác**: Số lượng cố định
- **SABO Arena signature events**: Sự kiện đặc trưng
- **Advanced players**: Người chơi am hiểu format
- **Balanced competition**: Muốn cân bằng tuyệt đối

---

## 5. Sabo Double Elimination DE32 - Loại kép Sabo 32 người

### 🎯 Khái niệm
**Sabo DE32** là format cao cấp nhất, sử dụng **Two-Group System** với 32 người chơi chia thành **2 nhóm 16 người**, mỗi nhóm chạy Modified DE16, sau đó **Cross-Bracket Finals**.

### 📊 Thông số kỹ thuật
- **Số người chơi**: Chính xác 32 người
- **Tổng số trận**: 55 trận
- **Cấu trúc**: Group A(26) + Group B(26) + Cross-Bracket(3)
- **Hệ thống**: Two-Group Architecture

### 🏗️ Cấu trúc sơ đồ Two-Group System

#### DE32 Architecture Overview:
```
32 PLAYERS
    ↓
Split into 2 Groups
    ↓
┌─────────────────┐         ┌─────────────────┐
│   GROUP A (16)  │         │   GROUP B (16)  │
│                 │         │                 │
│ Modified DE16   │         │ Modified DE16   │  
│ 26 matches      │         │ 26 matches      │
│                 │         │                 │
│ Produces:       │         │ Produces:       │
│ • 1st Qualifier │         │ • 1st Qualifier │
│ • 2nd Qualifier │         │ • 2nd Qualifier │
└─────────────────┘         └─────────────────┘
    ↓                           ↓
    └───────────┬───────────────┘
                ↓
    CROSS-BRACKET FINALS (3 matches)
    ════════════════════════════════
    
    Semi 1: A1st vs B2nd
    Semi 2: B1st vs A2nd
             ↓
    Final: Semi winners → 🏆 CHAMPION
```

#### Group Structure (Modified DE16 - 26 matches):
```
WINNERS BRACKET (15 matches)
==============

WR1: 8 matches (16→8)
WR2: 4 matches (8→4)
WR3: 2 matches (4→2)
WF:  1 match (2→1) ──→ 1st Qualifier

LOSERS BRACKET (11 matches)
=============

LR1: 4 matches (initial losers)
LR2: 4 matches (with WR2 losers)
LR3: 2 matches (consolidation)
LF:  1 match (2→1) ──→ 2nd Qualifier
```

#### Cross-Bracket Finals Detail:
```
CROSS-BRACKET FINALS
==================

Qualifiers:
• A1: Group A Winner (từ A-WF)
• A2: Group A Runner-up (từ A-LF)  
• B1: Group B Winner (từ B-WF)
• B2: Group B Runner-up (từ B-LF)

Semifinals:
┌─────────────────────────────────────┐
│ SF1: A1 vs B2                       │
│ SF2: B1 vs A2                       │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│ GF: SF1_Winner vs SF2_Winner        │
│     ↓                               │
│ 🏆 DE32 CHAMPION                    │
└─────────────────────────────────────┘
```

### 🔑 Đặc điểm độc đáo của Sabo DE32

#### 1. **Two-Group Parallel Processing**
- 32 người → 2 nhóm 16 người
- Mỗi nhóm chạy **Modified DE16** độc lập
- Parallel processing tăng tốc độ tổ chức

#### 2. **Modified DE16 Structure** 
- **26 matches** thay vì 27 (Sabo DE16)
- **Winners Bracket**: 15 matches (thêm Winners Final)
- **Losers Bracket**: 11 matches (đơn giản hóa)
- Mỗi nhóm tạo **2 qualifiers**

#### 3. **Cross-Bracket Finals**
- **4 qualifiers** từ 2 nhóm
- **Cross-matching**: A1 vs B2, B1 vs A2
- **Pure Finals**: Không bracket reset
- **Champion**: Thắng 2 nhóm → xứng đáng tuyệt đối

#### 4. **Scalability Architecture**
- Foundation cho DE64 (4 groups)
- Foundation cho DE128 (8 groups)
- Modular design cho tương lai

### ⚖️ Ưu & Nhược điểm

#### ✅ Ưu điểm:
- **Scalable**: Xử lý được nhiều người
- **Balanced**: Cross-group cân bằng hoàn hảo
- **Parallel**: Tổ chức nhanh với 2 nhóm
- **Fair**: Mọi nhóm đều có cơ hội
- **Advanced**: Format cao cấp nhất

#### ❌ Nhược điểm:
- **Phức tạp**: Cần hiểu Two-Group system
- **Fixed 32**: Chỉ dành cho đúng 32 người  
- **Resources**: Cần nhiều bàn/trọng tài
- **Understanding**: Khó giải thích cho người mới

### 🏆 Phân chia giải thưởng Sabo DE32
```
🥇 Champion: 35%
🥈 Runner-up: 20%
🥉 3rd place: 15%
4th place: 10%
5th-8th: 5% each (group winners & runner-ups không vào finals)
9th-16th: 1.25% each
```

### 📈 Khi nào sử dụng?
- **Major tournaments**: Giải đấu lớn 32 người
- **Championship events**: Giải vô địch
- **SABO Arena finals**: Sự kiện cao cấp nhất  
- **Pro competitions**: Giải đấu chuyên nghiệp

---

## 6. Round Robin - Vòng tròn

### 🎯 Khái niệm
**Round Robin** là format mà **mỗi người chơi đấu với tất cả các đối thủ khác** trong giải đấu. Không có loại trực tiếp, xếp hạng dựa trên tổng điểm.

### 📊 Thông số kỹ thuật
- **Số người chơi**: 3-12 người (tối ưu 6-8)
- **Số trận**: n×(n-1)/2 (n = số người chơi)
- **Số vòng**: n-1 vòng
- **Loại**: Không loại ai (non-elimination)

### 🏗️ Cấu trúc sơ đồ

#### Ví dụ 6 người chơi (15 trận):
```
     P1  P2  P3  P4  P5  P6
P1   --  ✓   ✓   ✓   ✓   ✓   (5 matches)
P2   ✓   --  ✓   ✓   ✓   ✓   (5 matches)  
P3   ✓   ✓   --  ✓   ✓   ✓   (5 matches)
P4   ✓   ✓   ✓   --  ✓   ✓   (5 matches)
P5   ✓   ✓   ✓   ✓   --  ✓   (5 matches)
P6   ✓   ✓   ✓   ✓   ✓   --  (5 matches)

Tổng: 15 trận (6×5/2)
```

#### Schedule 5 vòng:
```
Vòng 1: P1-P6, P2-P5, P3-P4
Vòng 2: P1-P5, P6-P4, P2-P3  
Vòng 3: P1-P4, P5-P3, P6-P2
Vòng 4: P1-P3, P4-P2, P5-P6
Vòng 5: P1-P2, P3-P6, P4-P5
```

### 📊 Hệ thống tính điểm
```
Thắng: 3 điểm
Hòa: 1 điểm (nếu có)
Thua: 0 điểm

Xếp hạng theo:
1. Tổng điểm
2. Head-to-head (nếu bằng điểm)
3. Goal difference (nếu áp dụng)
```

### ⚖️ Ưu & Nhược điểm

#### ✅ Ưu điểm:
- **Công bằng tuyệt đối**: Mọi người đấu với nhau
- **Nhiều trận đấu**: Người chơi chơi nhiều nhất
- **Xếp hạng chính xác**: Thực lực thể hiện rõ
- **Không may mắn**: Kết quả dựa trên kỹ năng

#### ❌ Nhược điểm:
- **Thời gian dài**: Rất nhiều trận đấu
- **Giới hạn người**: Chỉ phù hợp ≤12 người
- **Có thể nhàm chán**: Không có dramatic elimination
- **Tổ chức phức tạp**: Cần schedule cẩn thận

### 🏆 Phân chia giải thưởng
```
🥇 1st place: 40%
🥈 2nd place: 25%  
🥉 3rd place: 15%
4th place: 10%
5th place: 5%
6th place: 5%
```

### 📈 Khi nào sử dụng?
- **Small groups**: 6-8 người chơi
- **Skill assessment**: Muốn xếp hạng chính xác
- **League format**: Giải đấu kiểu league
- **Fair play**: Muốn công bằng tuyệt đối

---

## 7. Swiss System - Hệ thống Swiss

### 🎯 Khái niệm
**Swiss System** là format lai giữa Round Robin và Single Elimination. Người chơi **không bị loại**, nhưng chỉ đấu với **đối thủ có điểm tương đương** trong mỗi vòng.

### 📊 Thông số kỹ thuật
- **Số người chơi**: 6-128 người
- **Số vòng**: Thường log₂(n) vòng
- **Pairing**: Dựa trên điểm số Swiss
- **Loại**: Không loại (non-elimination)

### 🏗️ Cấu trúc Swiss Pairing

#### Ví dụ 8 người, 3 vòng:
```
VÒNG 1 (Random pairing):
P1 vs P2 (P1 wins - 1pt, P2 - 0pt)
P3 vs P4 (P3 wins - 1pt, P4 - 0pt)  
P5 vs P6 (P5 wins - 1pt, P6 - 0pt)
P7 vs P8 (P7 wins - 1pt, P8 - 0pt)

VÒNG 2 (1pt group vs 1pt group, 0pt vs 0pt):
P1 vs P3 (P1 wins - 2pt, P3 - 1pt)
P5 vs P7 (P5 wins - 2pt, P7 - 1pt)
P2 vs P4 (P2 wins - 1pt, P4 - 0pt)
P6 vs P8 (P6 wins - 1pt, P8 - 0pt)

VÒNG 3 (Pair by current points):
P1 vs P5 (2pt vs 2pt) → Winner = Champion
P3 vs P7 (1pt vs 1pt)
P2 vs P6 (1pt vs 1pt)  
P4 vs P8 (0pt vs 0pt)
```

### 🎯 Swiss Pairing Rules
```
1. Không đấu lại người đã đấu
2. Pairing theo điểm số gần bằng nhau
3. Avoid same-region pairing (nếu có)
4. Color balance (chess-style)
```

### ⚖️ Ưu & Nhược điểm

#### ✅ Ưu điểm:
- **Scalable**: Xử lý được nhiều người
- **Fair matching**: Đấu với người cùng trình độ
- **No elimination**: Mọi người chơi hết giải
- **Accurate ranking**: Xếp hạng tương đối chính xác

#### ❌ Nhược điểm:
- **Phức tạp pairing**: Cần software hỗ trợ
- **Less dramatic**: Không có knockout drama
- **Time consuming**: Nhiều vòng đấu
- **Tie-breaking**: Phức tạp khi nhiều người bằng điểm

### 🏆 Phân chia giải thưởng Swiss
```
Top 25% nhận giải:
🥇 1st: 40%
🥈 2nd: 25%
🥉 3rd: 15%
4th-6th: 6.67% each
```

### 📈 Khi nào sử dụng?
- **Large tournaments**: 16+ người chơi
- **Skill-based pairing**: Muốn đấu cùng trình độ
- **Multiple rounds**: Có thời gian cho nhiều vòng
- **Ranking events**: Sự kiện xếp hạng

---

## 8. Parallel Groups - Nhóm song song

### 🎯 Khái niệm
**Parallel Groups** chia người chơi thành **nhiều nhóm nhỏ**, mỗi nhóm chạy **Round Robin**, sau đó **Top players từ mỗi nhóm** vào **Knockout Finals**.

### 📊 Thông số kỹ thuật
- **Số người chơi**: 8-64 người
- **Số nhóm**: 2-8 nhóm
- **Group stage**: Round Robin
- **Finals**: Single/Double Elimination

### 🏗️ Cấu trúc sơ đồ

#### Ví dụ 16 người, 4 nhóm:
```
GROUP STAGE (Round Robin in each group)
=====================================

Group A (4 people):     Group B (4 people):
P1, P2, P3, P4         P5, P6, P7, P8
6 matches              6 matches
Top 2 advance          Top 2 advance

Group C (4 people):     Group D (4 people):  
P9, P10, P11, P12      P13, P14, P15, P16
6 matches              6 matches
Top 2 advance          Top 2 advance

KNOCKOUT FINALS (8 qualifiers)
=============================

Quarterfinals:
A1 vs D2    |    B1 vs C2
A2 vs D1    |    B2 vs C1

Semifinals:
QF1 winner vs QF2 winner
QF3 winner vs QF4 winner

Final:
SF1 winner vs SF2 winner → Champion
```

### 🔄 Group → Finals Flow
```
Phase 1: GROUP STAGE
- Mỗi nhóm: Round Robin
- Xếp hạng trong nhóm
- Top 2 mỗi nhóm advance

Phase 2: KNOCKOUT FINALS  
- 8 qualifiers → Bracket
- Single Elimination
- Cross-group pairing
```

### ⚖️ Ưu & Nhược điểm

#### ✅ Ưu điểm:
- **Scalable**: Xử lý nhiều người hiệu quả
- **Fair groups**: Mọi người chơi ít nhất 3 trận
- **Exciting finals**: Knockout drama
- **Parallel play**: Tiết kiệm thời gian

#### ❌ Nhược điểm:
- **Group imbalance**: Nhóm mạnh/yếu
- **Limited finals**: Chỉ top players vào finals
- **Complex seeding**: Cần chia nhóm cẩn thận
- **Elimination**: Một số người chơi ít trận

### 🏆 Phân chia giải thưởng
```
🥇 Champion: 35%
🥈 Runner-up: 20%
🥉 3rd place: 15%
4th place: 10%
Group stage only: 5% pool chia đều
```

### 📈 Khi nào sử dụng?
- **Medium-large tournaments**: 16-32 người
- **Mixed format**: Muốn vừa Round Robin vừa Elimination
- **Time efficient**: Cần tổ chức nhanh
- **Community events**: Sự kiện cộng đồng

---

## 🎯 TỔNG KẾT - CHỌN FORMAT NÀO?

### 📊 So sánh nhanh các format:

| Format | Players | Matches | Time | Complexity | Fairness |
|--------|---------|---------|------|------------|----------|
| Single Elimination | 4-64 | Ít nhất | Nhanh | Đơn giản | Thấp |
| Winner Takes All | 4-32 | Ít nhất | Nhanh | Đơn giản | Thấp |
| Traditional DE | 4-32 | Trung bình | Trung bình | Trung bình | Cao |
| Sabo DE16 | 16 | 27 | Trung bình | Cao | Cao |
| Sabo DE32 | 32 | 55 | Dài | Rất cao | Rất cao |
| Round Robin | 3-12 | Nhiều nhất | Dài | Trung bình | Rất cao |
| Swiss | 6-128 | Nhiều | Dài | Cao | Cao |
| Parallel Groups | 8-64 | Trung bình | Trung bình | Cao | Trung bình |

### 🏆 Khuyến nghị sử dụng:

#### 🚀 **Giải đấu nhanh** (1-2 tiếng):
- **Single Elimination** hoặc **Winner Takes All**
- 4-16 người chơi

#### ⚖️ **Giải đấu cân bằng** (2-4 tiếng):
- **Traditional Double Elimination**
- **Sabo DE16** (nếu đúng 16 người)
- 8-16 người chơi

#### 🏅 **Giải đấu chuyên nghiệp** (4-6 tiếng):
- **Sabo DE32** (nếu đúng 32 người)
- **Swiss System** (16+ người)

#### 🎪 **Sự kiện cộng đồng** (cả ngày):
- **Round Robin** (≤12 người)  
- **Parallel Groups** (16-32 người)

### 💡 **Lời khuyên cuối:**

1. **Ít người + Nhanh**: Single Elimination
2. **Cân bằng + 16 người**: Sabo DE16  
3. **Chuyên nghiệp + 32 người**: Sabo DE32
4. **Nhiều người**: Swiss hoặc Parallel Groups
5. **Công bằng tuyệt đối**: Round Robin

---

*🏆 Hướng dẫn này bao gồm tất cả format mà SABO Arena hỗ trợ. Mỗi format có điểm mạnh riêng, hãy chọn format phù hợp với mục tiêu giải đấu của bạn!*