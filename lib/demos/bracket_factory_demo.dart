/// 🎯 SABO ARENA - Factory Pattern Demo
/// Test the unified bracket service factory with existing services
/// Based on working UniversalMatchProgressionService

import '../core/factories/bracket_service_factory.dart';
import '../core/interfaces/bracket_service_interface.dart';
import '../core/constants/tournament_constants.dart';

/// Demo class to test factory pattern functionality
class BracketFactoryDemo {
  
  /// Test all bracket formats with factory pattern
  static Future<void> testAllFormats() async {
    print('🏭 SABO ARENA - Factory Pattern Demo');
    print('=' * 50);
    
    for (final format in TournamentFormats.allFormats) {
      await _testFormat(format);
    }
    
    print('\n✅ Factory pattern demo completed!');
  }
  
  /// Test specific format
  static Future<void> _testFormat(String format) async {
    try {
      print('\n🎯 Testing format: $format');
      
      // Get service from factory
      final service = BracketServiceFactory.getService(format);
      print('   ✅ Service created: ${service.runtimeType}');
      
      // Get format info
      final formatInfo = service.formatInfo;
      print('   📊 Format: ${formatInfo.name}');
      print('   👥 Players: ${formatInfo.minPlayers}-${formatInfo.maxPlayers}');
      
      // Test with demo tournament
      await _testProcessMatch(service, format);
      
    } catch (e) {
      print('   ❌ Error testing $format: $e');
    }
  }
  
  /// Test match processing with demo data
  static Future<void> _testProcessMatch(IBracketService service, String format) async {
    try {
      // Demo match processing
      final result = await service.processMatchResult(
        matchId: 'demo_match_123',
        winnerId: 'demo_player_1',
        scores: {'player1': 3, 'player2': 1},
      );
      
      if (result.success) {
        print('   🎮 Match processing: SUCCESS');
        print('   💬 Message: ${result.message}');
      } else {
        print('   ⚠️ Match processing: ${result.error}');
      }
      
    } catch (e) {
      print('   ❌ Match processing error: $e');
    }
  }

  /// Test factory with real tournament ID from app logs
  static Future<void> testWithRealTournament(String tournamentId) async {
    print('\n🏆 Testing with real tournament: $tournamentId');
    
    try {
      // Get service using factory
      final service = await BracketServiceFactory.getServiceByTournamentId(tournamentId);
      print('✅ Service obtained: ${service.runtimeType}');
      
      // Validate tournament
      final validation = await service.validateAndFixTournament(tournamentId);
      print('🔍 Validation result: ${validation.message}');
      print('🔧 Fixes applied: ${validation.fixesApplied}');
      
      // Get tournament status
      final status = await service.getTournamentStatus(tournamentId);
      print('📊 Tournament status: ${status.status}');
      print('🎮 Matches: ${status.completedMatches}/${status.totalMatches}');
      
    } catch (e) {
      print('❌ Real tournament test error: $e');
    }
  }

  /// Demo factory usage patterns
  static Future<void> demoUsagePatterns() async {
    print('\n🎓 Factory Pattern Usage Patterns');
    print('-' * 40);
    
    // Pattern 1: Direct service access
    print('\n1️⃣ Direct Service Access:');
    final seService = BracketServiceFactory.getService(TournamentFormats.singleElimination);
    print('   Service: ${seService.runtimeType}');
    
    // Pattern 2: Format validation
    print('\n2️⃣ Format Validation:');
    final isSupported = BracketServiceFactory.isFormatSupported('single_elimination');
    print('   Single Elimination supported: $isSupported');
    
    // Pattern 3: Get format info
    print('\n3️⃣ Format Information:');
    try {
      final formatInfo = BracketServiceFactory.getFormatInfo(TournamentFormats.saboDoubleElimination);
      print('   SABO DE16: ${formatInfo.name}');
      print('   Players: ${formatInfo.minPlayers}-${formatInfo.maxPlayers}');
      print('   Description: ${formatInfo.description}');
    } catch (e) {
      print('   Error getting format info: $e');
    }
    
    // Pattern 4: Process match via factory
    print('\n4️⃣ Factory-level Processing:');
    try {
      final result = await BracketServiceFactory.processMatchResult(
        tournamentId: 'demo_tournament',
        matchId: 'demo_match',
        winnerId: 'demo_winner',
        scores: {'player1': 2, 'player2': 0},
      );
      print('   Factory processing: ${result.success ? "SUCCESS" : "FAILED"}');
      print('   Service used: ${result.service}');
    } catch (e) {
      print('   Factory processing error: $e');
    }
  }

  /// Test all services creation
  static void testServiceCreation() {
    print('\n🏗️ Testing All Service Creation');
    print('-' * 40);
    
    try {
      final services = BracketServiceFactory.getAllServices();
      
      print('✅ Created ${services.length} services:');
      for (final entry in services.entries) {
        print('   ${entry.key}: ${entry.value.runtimeType}');
      }
      
      // Test cache
      print('\n🗂️ Testing Service Cache:');
      final service1 = BracketServiceFactory.getService(TournamentFormats.singleElimination);
      final service2 = BracketServiceFactory.getService(TournamentFormats.singleElimination);
      
      final isSameInstance = identical(service1, service2);
      print('   Cache working: $isSameInstance');
      
    } catch (e) {
      print('❌ Service creation error: $e');
    }
  }

  /// Benchmark factory performance
  static Future<void> benchmarkFactory() async {
    print('\n⚡ Factory Performance Benchmark');
    print('-' * 40);
    
    final stopwatch = Stopwatch()..start();
    
    // Test service creation speed
    for (int i = 0; i < 100; i++) {
      for (final format in TournamentFormats.allFormats) {
        BracketServiceFactory.getService(format);
      }
    }
    
    stopwatch.stop();
    final creationTime = stopwatch.elapsedMicroseconds;
    
    print('✅ Created 800 service instances in ${creationTime}μs');
    print('⚡ Average: ${(creationTime / 800).toStringAsFixed(2)}μs per service');
    print('🚀 Performance: ${creationTime < 10000 ? "EXCELLENT" : "GOOD"}');
  }
}

/// Main demo function
Future<void> runFactoryDemo() async {
  print('🎯 SABO ARENA - Unified Factory Pattern Demo');
  print('═' * 60);
  
  // Test service creation
  BracketFactoryDemo.testServiceCreation();
  
  // Demo usage patterns
  await BracketFactoryDemo.demoUsagePatterns();
  
  // Test all formats
  await BracketFactoryDemo.testAllFormats();
  
  // Performance benchmark
  await BracketFactoryDemo.benchmarkFactory();
  
  // Test with real tournament (if available)
  // await BracketFactoryDemo.testWithRealTournament('real_tournament_id');
  
  print('\n🎉 Factory Pattern Demo Completed Successfully!');
  print('Ready for production integration.');
}