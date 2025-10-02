# 🏟️ SABO ARENA V3 - PROJECT STRUCTURE

## 📁 **DIRECTORY ORGANIZATION**

### **📚 Core Application**
```
lib/                          # Flutter application code
├── core/                     # Core business logic
│   ├── interfaces/           # Service interfaces & contracts
│   └── factories/            # Factory patterns & service creation
├── services/                 # Business logic services
├── models/                   # Data models & entities
├── screens/                  # UI screens & pages
├── widgets/                  # Reusable UI components
├── utils/                    # Utility functions & helpers
│   ├── quick_test.dart       # Quick testing utilities
│   ├── simple_challenge_test.dart
│   └── simple_elo_test.dart
└── debug/                    # Debug & development tools
    ├── debug_all_participants.dart
    ├── debug_auth_types.dart
    ├── debug_participant_query.dart
    ├── debug_query_methods.dart
    ├── debug_rls_issue.dart
    └── debug_with_service_role.dart
```

### **📖 Documentation**
```
docs/                         # All project documentation
├── tournaments/              # Tournament system documentation
│   ├── BRACKET_IMPLEMENTATION_DETAILED_PLAN.md
│   ├── TOURNAMENT_SYSTEM_AUDIT_REPORT.md
│   ├── TOURNAMENT_BRACKET_SYSTEM_COMPLETE.md
│   ├── TOURNAMENT_COMPLETE_GUIDE.md
│   ├── TOURNAMENT_CORE_LOGIC_COMPLETION.md
│   ├── TOURNAMENT_ELO_INTEGRATION_COMPLETE.md
│   ├── TOURNAMENT_SYSTEM_FINAL_AUDIT.md
│   ├── TOURNAMENT_SYSTEM_PHASE1_COMPLETE.md
│   ├── TOURNAMENT_SYSTEM_USER_GUIDE.md
│   ├── TOURNAMENT_DUPLICATE_CLEANUP_REPORT.md
│   └── SABO_DE32_IMPLEMENTATION_COMPLETE.md
├── systems/                  # System architecture & features
│   ├── ADMIN_FEATURES_PROPOSAL.md
│   ├── ADMIN_LOGOUT_ACCOUNT_SWITCH.md
│   ├── CLUB_APPROVAL_SYSTEM_ANALYSIS.md
│   ├── COMMENT_SYSTEM_STATUS.md
│   └── HOME_TAB_FIX_STATUS.md
├── implementation/           # Implementation guides & completion reports
│   ├── FACTORY_PATTERN_IMPLEMENTATION_COMPLETE.md
│   ├── FACTORY_CLEANUP_PLAN.md
│   ├── BASIC_REFERRAL_IMPLEMENTATION.md
│   ├── MESSAGING_SYSTEM_COMPLETE.md
│   ├── NOTIFICATION_BUTTON_INTEGRATION_COMPLETE.md
│   ├── RANK_REGISTRATION_IMPLEMENTATION_COMPLETE.md
│   ├── PROJECT_SUMMARY_COMPLETE.md
│   ├── RELEASE_COMPLETE_SUMMARY.md
│   ├── INTEGRATED_QR_FINAL_DOCUMENTATION.md
│   ├── INTEGRATED_QR_REFERRAL_SOLUTION.md
│   └── STORAGE_SOLUTION_COMPREHENSIVE.md
├── audits/                   # System audits & analysis reports
│   ├── EXPERT_TOURNAMENT_AUDIT_REPORT.md
│   ├── CRITICAL_AUDIT_FINDINGS.md
│   ├── ELO_RANK_SYSTEM_AUDIT_FINAL_REPORT.md
│   ├── HOME_TAB_AUDIT_COMPLETE.md
│   ├── MOCK_DATA_AUDIT_REPORT.md
│   └── SYSTEM_INTEGRATION_AUDIT_REPORT.md
├── guides/                   # Setup & usage guides
│   ├── MANUAL_TESTING_GUIDE.md
│   ├── GOOGLE_PLAY_SETUP_GUIDE.md
│   ├── IOS_RELEASE_GUIDE.md
│   ├── MIGRATION_INSTRUCTIONS.md
│   ├── NOTIFICATION_SYSTEM_INTEGRATION_GUIDE.md
│   ├── RELEASE_INSTRUCTIONS.md
│   ├── QUICK_REFERENCE.md
│   ├── SUPABASE_SETUP.md
│   ├── SUPABASE_POLICIES_SETUP.md
│   ├── SUPABASE_PHONE_AUTH_CHECKLIST.md
│   └── test_spa_challenge_guide.md
└── DOCUMENTATION_README.md   # Documentation navigation guide
```

### **🐍 Scripts & Automation**
```
scripts/                      # Python scripts & automation tools
├── test_scripts/             # Testing & validation scripts
│   ├── check_database_matches.py
│   ├── check_matches_schema.py
│   ├── check_sabo1_hardcore.py
│   ├── check_sabo1_tournament.py
│   ├── check_tournament_notifications.py
│   ├── check_tournament_rewards.py
│   ├── check_tournament_structure.py
│   ├── complete_test_final.py
│   ├── test_auto_completion.py
│   ├── test_auto_progression.py
│   ├── test_hardcore_advancement.py
│   ├── test_integrated_completion.py
│   └── test_tournament_notifications.py
├── tournament_utils/         # Tournament management utilities
│   ├── apply_tournament_rewards.py
│   ├── auto_tournament_progression.py
│   ├── sabo_auto_tournament_complete.py
│   └── tournament_analyzer.py
├── database_utils/           # Database management scripts
│   ├── add_winner_columns.py
│   ├── clear_matches.py
│   ├── clear_tournament.py
│   ├── create_hardcore_directly.py
│   └── create_notification_test_tournament.py
└── maintenance/              # System maintenance scripts
    ├── set_finals_winner.py
    └── update_tournament_status.py
```

### **🧪 Testing**
```
test/                         # Flutter test files
├── widget_test.dart          # Widget tests
├── test_advance_tournament.dart
├── test_bracket_logic.dart
├── test_elo_rank_consistency.dart
├── test_frontend_backend_consistency.dart
├── test_losers_bracket_logic.dart
├── test_losers_bracket_logic_v2.dart
├── test_production_bracket_system.dart
├── test_rls_policies.dart
├── test_rpc_functions.dart
├── test_spa_challenge_integration.dart
└── test_tournament_rank_promotion.dart
```

### **🗄️ Archive & Legacy**
```
archive/                      # Archived files & legacy code
archive_scripts/              # Archived scripts
archive_services/             # Archived services
```

## 🎯 **KEY FEATURES IMPLEMENTED**

### **🏆 Tournament System**
- **8 Bracket Formats**: Single Elimination, Double Elimination, SABO DE16, SABO DE32, Round Robin, Swiss System, Parallel Groups, Winner Takes All
- **Factory Pattern**: Unified interface via `BracketServiceFactory`
- **Auto Progression**: Automated tournament advancement
- **ELO Integration**: Ranking system integration

### **🏛️ Admin System**
- **Multi-role Support**: Admin, Owner, Member permissions
- **Club Management**: Club creation, member management
- **Tournament Administration**: Tournament creation and management

### **💬 Social Features**
- **Messaging System**: In-app messaging
- **Comment System**: Match and tournament comments
- **Referral System**: QR-based referrals
- **Notification System**: Real-time notifications

### **📱 Technical Stack**
- **Frontend**: Flutter (Dart)
- **Backend**: Supabase (PostgreSQL + Auth + Storage)
- **State Management**: Provider/Riverpod
- **Real-time**: Supabase Realtime subscriptions

## 🚀 **QUICK START**

1. **Setup Environment**: Follow `docs/guides/SUPABASE_SETUP.md`
2. **Run Application**: Use VS Code tasks or `flutter run`
3. **Testing**: See `docs/guides/MANUAL_TESTING_GUIDE.md`
4. **Development**: Check `docs/DOCUMENTATION_README.md`

## 📞 **SUPPORT & MAINTENANCE**

- **Bug Reports**: Use test scripts in `scripts/test_scripts/`
- **Database Issues**: Use utilities in `scripts/database_utils/`
- **Tournament Problems**: Check `scripts/tournament_utils/`
- **System Maintenance**: Use `scripts/maintenance/`

---
**Last Updated**: October 2025  
**Version**: 3.0 - Factory Pattern Implementation Complete  
**Status**: Production Ready ✅