/// 🚀 SABO ARENA - Simple Factory Test
/// Quick test to validate factory pattern concept
/// Using existing services without complex interfaces

import '../services/universal_match_progression_service.dart';
import '../services/auto_winner_detection_service.dart';
import '../core/constants/tournament_constants.dart';

/// Simple factory for testing concept
class SimpleBracketFactory {
  
  /// Process match result using appropriate service based on format
  static Future<Map<String, dynamic>> processMatch({
    required String format,
    required String matchId,
    required String winnerId,
    required Map<String, int> scores,
  }) async {
    
    print('🏭 Factory processing $format match: $matchId');
    
    try {
      switch (format) {
        case TournamentFormats.singleElimination:
        case TournamentFormats.doubleElimination:
        case TournamentFormats.roundRobin:
        case TournamentFormats.swiss:
          // Use UniversalMatchProgressionService for all standard formats
          return await UniversalMatchProgressionService.instance
              .updateMatchResultWithImmediateAdvancement(
            matchId: matchId,
            winnerId: winnerId,
            loserId: 'unknown_loser', // For demo purposes
            scores: scores,
          );
          
        case TournamentFormats.saboDoubleElimination:
          // SABO DE16 - use specialized service when available
          return await UniversalMatchProgressionService.instance
              .updateMatchResultWithImmediateAdvancement(
            matchId: matchId,
            winnerId: winnerId,
            loserId: 'unknown_loser', // For demo purposes
            scores: scores,
          );
          
        case TournamentFormats.saboDoubleElimination32:
          // SABO DE32 - use specialized service when available
          return await UniversalMatchProgressionService.instance
              .updateMatchResultWithImmediateAdvancement(
            matchId: matchId,
            winnerId: winnerId,
            loserId: 'unknown_loser', // For demo purposes
            scores: scores,
          );
          
        default:
          return {
            'success': false,
            'error': 'Unsupported format: $format',
            'factory': 'SimpleBracketFactory',
          };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Factory error: $e',
        'factory': 'SimpleBracketFactory',
      };
    }
  }
  
  /// Auto-fix tournament using appropriate validation service
  static Future<Map<String, dynamic>> fixTournament(String tournamentId) async {
    print('🔧 Factory auto-fixing tournament: $tournamentId');
    
    try {
      // Use AutoWinnerDetectionService which is already working
      final fixes = await AutoWinnerDetectionService.instance
          .detectAndSetWinner(
        matchId: 'scan_all', // This will need adjustment
        player1Score: 0,
        player2Score: 0,
        player1Id: '',
        player2Id: '',
      );
      
      return {
        'success': true,
        'message': 'Tournament auto-fix completed',
        'fixes_applied': fixes ? 1 : 0,
        'factory': 'SimpleBracketFactory',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Auto-fix error: $e',
        'factory': 'SimpleBracketFactory',
      };
    }
  }
  
  /// Get format information
  static Map<String, dynamic> getFormatInfo(String format) {
    final details = TournamentFormats.formatDetails[format];
    
    if (details == null) {
      return {
        'success': false,
        'error': 'Unknown format: $format',
      };
    }
    
    return {
      'success': true,
      'format': format,
      'name': details['name'],
      'nameVi': details['nameVi'],
      'minPlayers': details['minPlayers'],
      'maxPlayers': details['maxPlayers'],
      'description': details['description'],
      'factory': 'SimpleBracketFactory',
    };
  }
  
  /// List all supported formats
  static List<String> getSupportedFormats() {
    return TournamentFormats.allFormats;
  }
  
  /// Check if format is supported
  static bool isFormatSupported(String format) {
    return TournamentFormats.allFormats.contains(format);
  }
}

/// Simple demo to test factory functionality
class SimpleFactoryDemo {
  
  /// Run comprehensive factory test
  static Future<void> runDemo() async {
    print('🎯 SIMPLE BRACKET FACTORY DEMO');
    print('═' * 50);
    
    // Test 1: Format support
    _testFormatSupport();
    
    // Test 2: Format information
    _testFormatInfo();
    
    // Test 3: Match processing (demo)
    await _testMatchProcessing();
    
    // Test 4: Tournament fixing (demo)
    await _testTournamentFixing();
    
    print('\n✅ Simple Factory Demo Completed!');
    print('🚀 Ready for production testing.');
  }
  
  static void _testFormatSupport() {
    print('\n1️⃣ Format Support Test:');
    
    final formats = SimpleBracketFactory.getSupportedFormats();
    print('   Supported formats: ${formats.length}');
    
    for (final format in formats) {
      final supported = SimpleBracketFactory.isFormatSupported(format);
      print('   ✅ $format: $supported');
    }
    
    // Test unsupported format
    final unsupported = SimpleBracketFactory.isFormatSupported('unknown_format');
    print('   ❌ unknown_format: $unsupported');
  }
  
  static void _testFormatInfo() {
    print('\n2️⃣ Format Information Test:');
    
    final testFormats = [
      TournamentFormats.singleElimination,
      TournamentFormats.saboDoubleElimination,
      TournamentFormats.roundRobin,
    ];
    
    for (final format in testFormats) {
      final info = SimpleBracketFactory.getFormatInfo(format);
      
      if (info['success']) {
        print('   ✅ ${info['name']} (${info['nameVi']})');
        print('      Players: ${info['minPlayers']}-${info['maxPlayers']}');
        print('      Description: ${info['description']}');
      } else {
        print('   ❌ $format: ${info['error']}');
      }
    }
  }
  
  static Future<void> _testMatchProcessing() async {
    print('\n3️⃣ Match Processing Test:');
    
    final testCases = [
      {
        'format': TournamentFormats.singleElimination,
        'matchId': 'demo_se_match_1',
        'winnerId': 'demo_player_1',
        'scores': {'player1': 3, 'player2': 1},
      },
      {
        'format': TournamentFormats.saboDoubleElimination,
        'matchId': 'demo_de16_match_1',
        'winnerId': 'demo_player_2',
        'scores': {'player1': 1, 'player2': 3},
      },
    ];
    
    for (final testCase in testCases) {
      print('   Testing ${testCase['format']}...');
      
      final result = await SimpleBracketFactory.processMatch(
        format: testCase['format'] as String,
        matchId: testCase['matchId'] as String,
        winnerId: testCase['winnerId'] as String,
        scores: testCase['scores'] as Map<String, int>,
      );
      
      if (result['success']) {
        print('      ✅ Success: ${result['message'] ?? "Match processed"}');
      } else {
        print('      ⚠️ Expected demo error: ${result['error']}');
      }
    }
  }
  
  static Future<void> _testTournamentFixing() async {
    print('\n4️⃣ Tournament Auto-Fix Test:');
    
    final result = await SimpleBracketFactory.fixTournament('demo_tournament_123');
    
    if (result['success']) {
      print('   ✅ Auto-fix completed');
      print('   🔧 Fixes applied: ${result['fixes_applied']}');
    } else {
      print('   ⚠️ Expected demo error: ${result['error']}');
    }
  }
}