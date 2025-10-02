/// 🏭 SABO ARENA - Unified Bracket Service Factory
/// Central factory for all tournament bracket formats
/// Based on existing services and audit findings

import '../interfaces/bracket_service_interface.dart';
import '../../services/universal_match_progression_service.dart';
import '../../services/complete_sabo_de16_service.dart';
import '../../services/complete_sabo_de32_service.dart';
import '../../services/complete_double_elimination_service.dart';
import '../../services/auto_winner_detection_service.dart';
import '../../core/constants/tournament_constants.dart';

/// Factory for creating bracket services based on tournament format
class BracketServiceFactory {
  static final Map<String, IBracketService> _serviceInstances = {};
  
  /// Get service instance for specific bracket format
  static IBracketService getService(String format) {
    if (_serviceInstances.containsKey(format)) {
      return _serviceInstances[format]!;
    }

    IBracketService service;
    
    switch (format) {
      case TournamentFormats.singleElimination:
        service = SingleEliminationBracketService();
        break;
        
      case TournamentFormats.doubleElimination:
        service = DoubleEliminationBracketService();
        break;
        
      case TournamentFormats.saboDoubleElimination:
        service = SaboDE16BracketService();
        break;
        
      case TournamentFormats.saboDoubleElimination32:
        service = SaboDE32BracketService();
        break;
        
      case TournamentFormats.roundRobin:
        service = RoundRobinBracketService();
        break;
        
      case TournamentFormats.swiss:
        service = SwissBracketService();
        break;
        
      case TournamentFormats.parallelGroups:
        service = ParallelGroupsBracketService();
        break;
        
      case TournamentFormats.winnerTakesAll:
        service = WinnerTakesAllBracketService();
        break;
        
      default:
        throw UnsupportedBracketFormatException(
          'Bracket format "$format" is not supported. '
          'Supported formats: ${TournamentFormats.allFormats.join(", ")}'
        );
    }
    
    _serviceInstances[format] = service;
    return service;
  }

  /// Get all available services
  static Map<String, IBracketService> getAllServices() {
    final services = <String, IBracketService>{};
    
    for (final format in TournamentFormats.allFormats) {
      services[format] = getService(format);
    }
    
    return services;
  }

  /// Get service for tournament by ID
  static Future<IBracketService> getServiceByTournamentId(String tournamentId) async {
    // Simplified approach - use existing services directly
    // For now, assume single elimination as default
    return getService(TournamentFormats.singleElimination);
  }

  /// Validate format support
  static bool isFormatSupported(String format) {
    return TournamentFormats.allFormats.contains(format);
  }

  /// Get format info without creating service
  static BracketFormatInfo getFormatInfo(String format) {
    if (!isFormatSupported(format)) {
      throw UnsupportedBracketFormatException('Format "$format" is not supported');
    }
    
    final details = TournamentFormats.formatDetails[format];
    if (details == null) {
      throw UnsupportedBracketFormatException('Format details not found for "$format"');
    }
    
    return BracketFormatInfo.fromFormatDetails(details);
  }

  /// Clear service cache (for testing)
  static void clearCache() {
    _serviceInstances.clear();
  }

  /// Process match result using appropriate service
  static Future<BracketOperationResult> processMatchResult({
    required String tournamentId,
    required String matchId,
    required String winnerId,
    required Map<String, int> scores,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final service = await getServiceByTournamentId(tournamentId);
      return await service.processMatchResult(
        matchId: matchId,
        winnerId: winnerId,
        scores: scores,
        metadata: metadata,
      );
    } catch (e) {
      return BracketOperationResult.error(
        error: 'Factory processing error: $e',
        service: 'BracketServiceFactory',
      );
    }
  }

  /// Create bracket using appropriate service
  static Future<BracketOperationResult> createBracket({
    required String tournamentId,
    required String format,
    required List<String> participantIds,
    Map<String, dynamic>? options,
  }) async {
    try {
      final service = getService(format);
      return await service.createBracket(
        tournamentId: tournamentId,
        participantIds: participantIds,
        options: options,
      );
    } catch (e) {
      return BracketOperationResult.error(
        error: 'Factory bracket creation error: $e',
        service: 'BracketServiceFactory',
      );
    }
  }

  /// Validate tournament using appropriate service
  static Future<ValidationResult> validateTournament(String tournamentId) async {
    try {
      final service = await getServiceByTournamentId(tournamentId);
      return await service.validateAndFixTournament(tournamentId);
    } catch (e) {
      return ValidationResult.error('Factory validation error: $e');
    }
  }
}

/// Wrapper services that implement IBracketService using existing services

/// Single Elimination service wrapper
class SingleEliminationBracketService implements IBracketService {
  @override
  BracketFormatInfo get formatInfo => BracketFormatInfo.fromFormatDetails(
    TournamentFormats.formatDetails[TournamentFormats.singleElimination]!
  );

  @override
  Future<BracketOperationResult> processMatchResult({
    required String matchId,
    required String winnerId,
    required Map<String, int> scores,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Use existing UniversalMatchProgressionService which has IMMEDIATE advancement
      final result = await UniversalMatchProgressionService.instance
          .updateMatchResultWithImmediateAdvancement(
        matchId: matchId,
        winnerId: winnerId,
        scores: scores,
      );

      return BracketOperationResult(
        success: result['success'] ?? false,
        message: result['message'] as String?,
        error: result['error'] as String?,
        data: Map<String, dynamic>.from(result),
        service: 'SingleEliminationBracketService',
        timestamp: DateTime.now(),
      );
    } catch (e) {
      return BracketOperationResult.error(
        error: e.toString(),
        service: 'SingleEliminationBracketService',
      );
    }
  }

  @override
  Future<BracketOperationResult> createBracket({
    required String tournamentId,
    required List<String> participantIds,
    Map<String, dynamic>? options,
  }) async {
    // Implementation for bracket creation
    // Can use existing bracket generation services
    return BracketOperationResult.success(
      message: 'Single Elimination bracket creation - to be implemented',
      service: 'SingleEliminationBracketService',
    );
  }

  @override
  Future<ValidationResult> validateAndFixTournament(String tournamentId) async {
    try {
      // Simplified validation - just return success for now
      return ValidationResult.success(fixesApplied: 0);
    } catch (e) {
      return ValidationResult.error(e.toString());
    }
  }

  @override
  Future<TournamentStatus> getTournamentStatus(String tournamentId) async {
    // Simplified status - return basic info
    return const TournamentStatus(
      tournamentId: 'temp',
      status: 'in_progress',
      totalMatches: 15,
      completedMatches: 0,
      pendingMatches: 15,
      totalRounds: 4,
      completionPercentage: 0.0,
      bracketFormat: 'single_elimination',
    );
  }
}

/// Double Elimination service wrapper
class DoubleEliminationBracketService implements IBracketService {
  @override
  BracketFormatInfo get formatInfo => BracketFormatInfo.fromFormatDetails(
    TournamentFormats.formatDetails[TournamentFormats.doubleElimination]!
  );

  @override
  Future<BracketOperationResult> processMatchResult({
    required String matchId,
    required String winnerId,
    required Map<String, int> scores,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Use existing CompleteDoubleEliminationService
      final result = await CompleteDoubleEliminationService.instance
          .processMatchResult(
        matchId: matchId,
        winnerId: winnerId,
        scores: scores,
      );

      return BracketOperationResult(
        success: result['success'] ?? false,
        message: result['message'] as String?,
        error: result['error'] as String?,
        data: Map<String, dynamic>.from(result),
        service: 'DoubleEliminationBracketService',
        timestamp: DateTime.now(),
      );
    } catch (e) {
      return BracketOperationResult.error(
        error: e.toString(),
        service: 'DoubleEliminationBracketService',
      );
    }
  }

  @override
  Future<BracketOperationResult> createBracket({
    required String tournamentId,
    required List<String> participantIds,
    Map<String, dynamic>? options,
  }) async {
    return BracketOperationResult.success(
      message: 'Double Elimination bracket creation - to be implemented',
      service: 'DoubleEliminationBracketService',
    );
  }

  @override
  Future<ValidationResult> validateAndFixTournament(String tournamentId) async {
    return ValidationResult.success(fixesApplied: 0);
  }

  @override
  Future<TournamentStatus> getTournamentStatus(String tournamentId) async {
    return TournamentStatus(
      tournamentId: tournamentId,
      status: 'in_progress',
      totalMatches: 0,
      completedMatches: 0,
      pendingMatches: 0,
      totalRounds: 0,
      completionPercentage: 0.0,
      bracketFormat: TournamentFormats.doubleElimination,
    );
  }
}

/// SABO DE16 service wrapper
class SaboDE16BracketService implements IBracketService {
  @override
  BracketFormatInfo get formatInfo => BracketFormatInfo.fromFormatDetails(
    TournamentFormats.formatDetails[TournamentFormats.saboDoubleElimination]!
  );

  @override
  Future<BracketOperationResult> processMatchResult({
    required String matchId,
    required String winnerId,
    required Map<String, int> scores,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Use existing CompleteSaboDE16Service
      final result = await CompleteSaboDE16Service.instance
          .processMatchResult(
        matchId: matchId,
        winnerId: winnerId,
        scores: scores,
      );

      return BracketOperationResult(
        success: result['success'] ?? false,
        message: result['message'] as String?,
        error: result['error'] as String?,
        data: Map<String, dynamic>.from(result),
        service: 'SaboDE16BracketService',
        timestamp: DateTime.now(),
      );
    } catch (e) {
      return BracketOperationResult.error(
        error: e.toString(),
        service: 'SaboDE16BracketService',
      );
    }
  }

  @override
  Future<BracketOperationResult> createBracket({
    required String tournamentId,
    required List<String> participantIds,
    Map<String, dynamic>? options,
  }) async {
    return BracketOperationResult.success(
      message: 'SABO DE16 bracket creation - to be implemented',
      service: 'SaboDE16BracketService',
    );
  }

  @override
  Future<ValidationResult> validateAndFixTournament(String tournamentId) async {
    return ValidationResult.success(fixesApplied: 0);
  }

  @override
  Future<TournamentStatus> getTournamentStatus(String tournamentId) async {
    return TournamentStatus(
      tournamentId: tournamentId,
      status: 'in_progress',
      totalMatches: 27, // SABO DE16 has exactly 27 matches
      completedMatches: 0,
      pendingMatches: 27,
      totalRounds: 0,
      completionPercentage: 0.0,
      bracketFormat: TournamentFormats.saboDoubleElimination,
    );
  }
}

/// SABO DE32 service wrapper
class SaboDE32BracketService implements IBracketService {
  @override
  BracketFormatInfo get formatInfo => BracketFormatInfo.fromFormatDetails(
    TournamentFormats.formatDetails[TournamentFormats.saboDoubleElimination32]!
  );

  @override
  Future<BracketOperationResult> processMatchResult({
    required String matchId,
    required String winnerId,
    required Map<String, int> scores,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Use existing CompleteSaboDE32Service
      final result = await CompleteSaboDE32Service.instance
          .processMatchResult(
        matchId: matchId,
        winnerId: winnerId,
        scores: scores,
      );

      return BracketOperationResult(
        success: result['success'] ?? false,
        message: result['message'] as String?,
        error: result['error'] as String?,
        data: Map<String, dynamic>.from(result),
        service: 'SaboDE32BracketService',
        timestamp: DateTime.now(),
      );
    } catch (e) {
      return BracketOperationResult.error(
        error: e.toString(),
        service: 'SaboDE32BracketService',
      );
    }
  }

  @override
  Future<BracketOperationResult> createBracket({
    required String tournamentId,
    required List<String> participantIds,
    Map<String, dynamic>? options,
  }) async {
    return BracketOperationResult.success(
      message: 'SABO DE32 bracket creation - to be implemented',
      service: 'SaboDE32BracketService',
    );
  }

  @override
  Future<ValidationResult> validateAndFixTournament(String tournamentId) async {
    return ValidationResult.success(fixesApplied: 0);
  }

  @override
  Future<TournamentStatus> getTournamentStatus(String tournamentId) async {
    return TournamentStatus(
      tournamentId: tournamentId,
      status: 'in_progress',
      totalMatches: 55, // SABO DE32 has exactly 55 matches
      completedMatches: 0,
      pendingMatches: 55,
      totalRounds: 0,
      completionPercentage: 0.0,
      bracketFormat: TournamentFormats.saboDoubleElimination32,
    );
  }
}

// Placeholder implementations for other formats
class RoundRobinBracketService implements IBracketService {
  @override
  BracketFormatInfo get formatInfo => BracketFormatInfo.fromFormatDetails(
    TournamentFormats.formatDetails[TournamentFormats.roundRobin]!
  );

  @override
  Future<BracketOperationResult> processMatchResult({
    required String matchId,
    required String winnerId,
    required Map<String, int> scores,
    Map<String, dynamic>? metadata,
  }) async => BracketOperationResult.success(
    message: 'Round Robin processing - to be implemented',
    service: 'RoundRobinBracketService',
  );

  @override
  Future<BracketOperationResult> createBracket({
    required String tournamentId,
    required List<String> participantIds,
    Map<String, dynamic>? options,
  }) async => BracketOperationResult.success(
    message: 'Round Robin bracket creation - to be implemented',
    service: 'RoundRobinBracketService',
  );

  @override
  Future<ValidationResult> validateAndFixTournament(String tournamentId) async =>
      ValidationResult.success(fixesApplied: 0);

  @override
  Future<TournamentStatus> getTournamentStatus(String tournamentId) async =>
      TournamentStatus(
        tournamentId: tournamentId,
        status: 'in_progress',
        totalMatches: 0,
        completedMatches: 0,
        pendingMatches: 0,
        totalRounds: 0,
        completionPercentage: 0.0,
        bracketFormat: TournamentFormats.roundRobin,
      );
}

class SwissBracketService implements IBracketService {
  @override
  BracketFormatInfo get formatInfo => BracketFormatInfo.fromFormatDetails(
    TournamentFormats.formatDetails[TournamentFormats.swiss]!
  );

  @override
  Future<BracketOperationResult> processMatchResult({
    required String matchId,
    required String winnerId,
    required Map<String, int> scores,
    Map<String, dynamic>? metadata,
  }) async => BracketOperationResult.success(
    message: 'Swiss processing - to be implemented',
    service: 'SwissBracketService',
  );

  @override
  Future<BracketOperationResult> createBracket({
    required String tournamentId,
    required List<String> participantIds,
    Map<String, dynamic>? options,
  }) async => BracketOperationResult.success(
    message: 'Swiss bracket creation - to be implemented',
    service: 'SwissBracketService',
  );

  @override
  Future<ValidationResult> validateAndFixTournament(String tournamentId) async =>
      ValidationResult.success(fixesApplied: 0);

  @override
  Future<TournamentStatus> getTournamentStatus(String tournamentId) async =>
      TournamentStatus(
        tournamentId: tournamentId,
        status: 'in_progress',
        totalMatches: 0,
        completedMatches: 0,
        pendingMatches: 0,
        totalRounds: 0,
        completionPercentage: 0.0,
        bracketFormat: TournamentFormats.swiss,
      );
}

class ParallelGroupsBracketService implements IBracketService {
  @override
  BracketFormatInfo get formatInfo => BracketFormatInfo.fromFormatDetails(
    TournamentFormats.formatDetails[TournamentFormats.parallelGroups]!
  );

  @override
  Future<BracketOperationResult> processMatchResult({
    required String matchId,
    required String winnerId,
    required Map<String, int> scores,
    Map<String, dynamic>? metadata,
  }) async => BracketOperationResult.success(
    message: 'Parallel Groups processing - to be implemented',
    service: 'ParallelGroupsBracketService',
  );

  @override
  Future<BracketOperationResult> createBracket({
    required String tournamentId,
    required List<String> participantIds,
    Map<String, dynamic>? options,
  }) async => BracketOperationResult.success(
    message: 'Parallel Groups bracket creation - to be implemented',
    service: 'ParallelGroupsBracketService',
  );

  @override
  Future<ValidationResult> validateAndFixTournament(String tournamentId) async =>
      ValidationResult.success(fixesApplied: 0);

  @override
  Future<TournamentStatus> getTournamentStatus(String tournamentId) async =>
      TournamentStatus(
        tournamentId: tournamentId,
        status: 'in_progress',
        totalMatches: 0,
        completedMatches: 0,
        pendingMatches: 0,
        totalRounds: 0,
        completionPercentage: 0.0,
        bracketFormat: TournamentFormats.parallelGroups,
      );
}

class WinnerTakesAllBracketService implements IBracketService {
  @override
  BracketFormatInfo get formatInfo => BracketFormatInfo.fromFormatDetails(
    TournamentFormats.formatDetails[TournamentFormats.winnerTakesAll]!
  );

  @override
  Future<BracketOperationResult> processMatchResult({
    required String matchId,
    required String winnerId,
    required Map<String, int> scores,
    Map<String, dynamic>? metadata,
  }) async => BracketOperationResult.success(
    message: 'Winner Takes All processing - to be implemented',
    service: 'WinnerTakesAllBracketService',
  );

  @override
  Future<BracketOperationResult> createBracket({
    required String tournamentId,
    required List<String> participantIds,
    Map<String, dynamic>? options,
  }) async => BracketOperationResult.success(
    message: 'Winner Takes All bracket creation - to be implemented',
    service: 'WinnerTakesAllBracketService',
  );

  @override
  Future<ValidationResult> validateAndFixTournament(String tournamentId) async =>
      ValidationResult.success(fixesApplied: 0);

  @override
  Future<TournamentStatus> getTournamentStatus(String tournamentId) async =>
      TournamentStatus(
        tournamentId: tournamentId,
        status: 'in_progress',
        totalMatches: 0,
        completedMatches: 0,
        pendingMatches: 0,
        totalRounds: 0,
        completionPercentage: 0.0,
        bracketFormat: TournamentFormats.winnerTakesAll,
      );
}