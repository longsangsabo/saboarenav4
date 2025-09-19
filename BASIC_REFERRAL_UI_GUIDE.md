# 🎁 Basic Referral System UI Components

Complete Flutter UI implementation for the simplified SABO Arena referral system.

## 📱 Available Components

### 1. BasicReferralCard
**Purpose**: Display and manage user's referral code with sharing functionality
- **File**: `lib/presentation/widgets/basic_referral_card.dart`
- **Features**:
  - Auto-generates SABO-USERNAME referral codes
  - Copy to clipboard functionality
  - Social sharing integration
  - Benefits display (100/50 SPA rewards)
  - Loading and error states

```dart
BasicReferralCard(
  userId: 'user-123',
  onStatsUpdate: () => print('Stats updated'),
)
```

### 2. BasicReferralCodeInput
**Purpose**: Input field for entering referral codes during registration
- **File**: `lib/presentation/widgets/basic_referral_code_input.dart`
- **Features**:
  - Real-time validation
  - Auto-uppercase input
  - Success/error feedback
  - Benefits information display
  - Compact version available

```dart
BasicReferralCodeInput(
  userId: 'user-123',
  onResult: (success, message) => print('$success: $message'),
)

// Compact version
CompactReferralCodeInput(
  userId: 'user-123',
  onResult: (success, message) => handleResult(success, message),
)
```

### 3. BasicReferralStatsWidget
**Purpose**: Dashboard showing referral statistics and SPA earned
- **File**: `lib/presentation/widgets/basic_referral_stats_widget.dart`
- **Features**:
  - Real-time statistics display
  - SPA earnings breakdown
  - Referral count tracking
  - Status indicators
  - Refresh functionality

```dart
BasicReferralStatsWidget(
  userId: 'user-123',
  showTitle: true,
)

// Compact version
CompactReferralStats(
  userId: 'user-123',
)
```

### 4. BasicReferralDashboard
**Purpose**: Complete referral system interface combining all components
- **File**: `lib/presentation/widgets/basic_referral_dashboard.dart`
- **Features**:
  - Complete referral workflow
  - How-it-works section
  - Configurable sections (code input, stats)
  - Mini widget for quick access

```dart
BasicReferralDashboard(
  userId: 'user-123',
  allowCodeInput: true,
  showStats: true,
)

// Mini widget for navigation
MiniReferralWidget(
  userId: 'user-123',
  onTapExpand: () => navigateToFullDashboard(),
)
```

## 🚀 Integration Examples

### Complete Example Page
**File**: `lib/presentation/pages/basic_referral_example_page.dart`
- Tabbed interface showing all components
- Different usage patterns
- Integration examples

### Quick Access Components
```dart
// Floating action button
ReferralFloatingActionButton(
  userId: 'user-123',
  onPressed: () => Navigator.push(...),
)

// Status indicator
ReferralStatusIndicator(
  userId: 'user-123',
)
```

## 🔧 Backend Integration

### Required Service
**File**: `lib/services/basic_referral_service.dart`
- `generateReferralCode(userId)` - Create new referral code
- `applyReferralCode(userId, code)` - Apply referral code
- `getUserReferralStats(userId)` - Get user statistics

### Database Schema
**File**: `BASIC_REFERRAL_MIGRATION.sql`
- `referral_codes` - Store referral codes and rewards
- `referral_usage` - Track usage and SPA distribution

## 📋 Usage Guidelines

### 1. Complete Referral Page
```dart
// Full-screen referral management
Scaffold(
  appBar: AppBar(title: Text('Referral System')),
  body: BasicReferralDashboard(
    userId: currentUserId,
    allowCodeInput: true,
    showStats: true,
  ),
)
```

### 2. Registration Flow Integration
```dart
// During user registration
Column(
  children: [
    // ... other registration fields
    BasicReferralCodeInput(
      userId: newUserId,
      showTitle: false,
      onResult: (success, message) {
        if (success) {
          // User gets 50 SPA bonus
          showSuccessMessage(message);
        }
      },
    ),
  ],
)
```

### 3. Profile Page Integration
```dart
// In user profile/dashboard
Column(
  children: [
    // ... other profile sections
    BasicReferralCard(
      userId: currentUserId,
      onStatsUpdate: refreshProfileData,
    ),
    
    // Or compact stats display
    CompactReferralStats(userId: currentUserId),
  ],
)
```

### 4. Home Screen Quick Access
```dart
// Mini widget in home screen
MiniReferralWidget(
  userId: currentUserId,
  onTapExpand: () {
    Navigator.pushNamed(context, '/referral');
  },
)
```

## 🎨 Theming

All components use `AppTheme.primaryLight` and follow the existing design system:
- Consistent spacing using `Sizer` (w/h percentages)
- Material Design 3 components
- Vietnamese text and placeholders
- Billiards green color scheme

## 🔄 State Management

### Auto-refresh Integration
```dart
// Components automatically refresh when:
// 1. User generates new referral code
// 2. User applies referral code successfully
// 3. Manual refresh triggered

// Manual refresh example
final GlobalKey<State<BasicReferralStatsWidget>> statsKey = GlobalKey();

void refreshStats() {
  statsKey.currentState?.setState(() {});
}
```

## 📊 Rewards System

### Fixed Reward Structure
- **Referrer**: +100 SPA per successful referral
- **Referred**: +50 SPA when using valid code
- **Code Format**: SABO-USERNAME (e.g., SABO-JOHN123)

### Validation Rules
- Code must exist and be active
- User cannot use their own code
- One-time use per user pair
- Case-insensitive matching

## 🧪 Testing

### Component Testing
```dart
// Test individual components
testWidgets('BasicReferralCard displays code', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: BasicReferralCard(userId: 'test-user'),
    ),
  );
  
  expect(find.byType(BasicReferralCard), findsOneWidget);
});
```

### Integration Testing
Run `BasicReferralExamplePage` for manual testing of all components and interactions.

## 📱 Platform Support

- ✅ **Android**: Full functionality
- ✅ **iOS**: Full functionality  
- ✅ **Web**: Full functionality (share_plus supported)
- ⚠️ **Desktop**: Limited sharing functionality

## 🚀 Deployment Notes

### Required Dependencies
```yaml
dependencies:
  share_plus: ^10.0.3  # Already in pubspec.yaml
  sizer: ^2.0.15       # Already in pubspec.yaml
  supabase_flutter: ^2.8.0  # Already in pubspec.yaml
```

### Database Setup
1. Run `BASIC_REFERRAL_MIGRATION.sql` on Supabase
2. Verify `BasicReferralService` connection
3. Test with demo user accounts

### Performance Optimization
- Components use `setState()` for local updates
- Backend calls are cached for 30 seconds
- Loading states prevent multiple API calls
- Error handling with user-friendly messages

---

**Created**: January 2025  
**Version**: 1.0.0  
**Status**: ✅ Ready for Production  
**Backend**: ✅ Fully Operational  
**UI**: ✅ Complete Implementation