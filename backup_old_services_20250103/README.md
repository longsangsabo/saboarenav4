# Backup Old Services - 2025-01-03

## Files Backed Up

These files were replaced by new hardcoded services with standardized schema:

1. **complete_sabo_de32_service.dart**
   - Old: Modified DE16 structure (26 matches per group)
   - Replaced by: hardcoded_sabo_de32_service.dart (SABO DE16 structure, 24 matches per group)
   - Reason: New structure is more balanced (4 qualifiers per group instead of 2)

2. **complete_sabo_de16_service.dart**
   - Old: 27 matches with custom logic
   - Replaced by: hardcoded_sabo_de16_service.dart
   - Reason: Standardized schema with bracket_type, display_order, stage_round

3. **complete_double_elimination_service.dart**
   - Old: 31 matches (had incorrect LB structure)
   - Replaced by: hardcoded_double_elimination_service.dart (30 matches)
   - Reason: Correct LB R1 structure (4 matches, not 8) + standardized schema

## New Services Location

- lib/services/hardcoded_sabo_de32_service.dart
- lib/services/hardcoded_sabo_de16_service.dart
- lib/services/hardcoded_double_elimination_service.dart

## Backup Date

2025-01-03

## Commit Reference

Last commit before replacement: b665f4c
First commit with new services: bfa73c2
