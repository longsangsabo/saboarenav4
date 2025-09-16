import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/tournament.dart';
import '../models/user_profile.dart';

class TournamentService {
  static TournamentService? _instance;
  static TournamentService get instance => _instance ??= TournamentService._();
  TournamentService._();

  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Tournament>> getTournaments({
    String? status,
    String? clubId,
    String? skillLevel,
    int limit = 50,
  }) async {
    try {
      var query = _supabase.from('tournaments').select();

      if (status != null) {
        query = query.eq('status', status);
      }
      if (clubId != null) {
        query = query.eq('club_id', clubId);
      }
      if (skillLevel != null) {
        query = query.eq('skill_level_required', skillLevel);
      }

      final response = await query
          .eq('is_public', true)
          .order('start_date', ascending: true)
          .limit(limit);

      return response
          .map<Tournament>((json) => Tournament.fromJson(json))
          .toList();
    } catch (error) {
      throw Exception('Failed to get tournaments: $error');
    }
  }

  Future<Tournament> getTournamentById(String tournamentId) async {
    try {
      final response = await _supabase
          .from('tournaments')
          .select()
          .eq('id', tournamentId)
          .single();

      return Tournament.fromJson(response);
    } catch (error) {
      throw Exception('Failed to get tournament: $error');
    }
  }

  Future<List<UserProfile>> getTournamentParticipants(
      String tournamentId) async {
    try {
      final response =
          await _supabase.from('tournament_participants').select('''
            *,
            users (*)
          ''').eq('tournament_id', tournamentId).order('registered_at');

      return response
          .map<UserProfile>((json) => UserProfile.fromJson(json['users']))
          .toList();
    } catch (error) {
      throw Exception('Failed to get tournament participants: $error');
    }
  }

  Future<bool> registerForTournament(String tournamentId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Check if already registered
      final existingRegistration = await _supabase
          .from('tournament_participants')
          .select()
          .eq('tournament_id', tournamentId)
          .eq('user_id', user.id)
          .maybeSingle();

      if (existingRegistration != null) {
        throw Exception('Already registered for this tournament');
      }

      // Check if tournament is still accepting registrations
      final tournament = await getTournamentById(tournamentId);
      if (tournament.currentParticipants >= tournament.maxParticipants) {
        throw Exception('Tournament is full');
      }

      if (DateTime.now().isAfter(tournament.registrationDeadline)) {
        throw Exception('Registration deadline has passed');
      }

      // Register for tournament
      await _supabase.from('tournament_participants').insert({
        'tournament_id': tournamentId,
        'user_id': user.id,
        'payment_status': 'pending',
        'registered_at': DateTime.now().toIso8601String(),
      });

      // Update participant count
      await _supabase.rpc('increment_tournament_participants',
          params: {'tournament_id': tournamentId});

      return true;
    } catch (error) {
      throw Exception('Failed to register for tournament: $error');
    }
  }

  Future<bool> unregisterFromTournament(String tournamentId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _supabase
          .from('tournament_participants')
          .delete()
          .eq('tournament_id', tournamentId)
          .eq('user_id', user.id);

      // Update participant count
      await _supabase.rpc('decrement_tournament_participants',
          params: {'tournament_id': tournamentId});

      return true;
    } catch (error) {
      throw Exception('Failed to unregister from tournament: $error');
    }
  }

  Future<bool> isRegisteredForTournament(String tournamentId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      final response = await _supabase
          .from('tournament_participants')
          .select('id')
          .eq('tournament_id', tournamentId)
          .eq('user_id', user.id)
          .maybeSingle();

      return response != null;
    } catch (error) {
      throw Exception('Failed to check tournament registration: $error');
    }
  }

  Future<Tournament> createTournament({
    required String clubId,
    required String title,
    required String description,
    required DateTime startDate,
    required DateTime registrationDeadline,
    required int maxParticipants,
    required double entryFee,
    required double prizePool,
    String? skillLevelRequired,
    String? rules,
    String? requirements,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final tournamentData = {
        'club_id': clubId,
        'organizer_id': user.id,
        'title': title,
        'description': description,
        'start_date': startDate.toIso8601String(),
        'registration_deadline': registrationDeadline.toIso8601String(),
        'max_participants': maxParticipants,
        'entry_fee': entryFee,
        'prize_pool': prizePool,
        'skill_level_required': skillLevelRequired,
        'rules': rules,
        'requirements': requirements,
        'status': 'upcoming',
        'current_participants': 0,
      };

      final response = await _supabase
          .from('tournaments')
          .insert(tournamentData)
          .select()
          .single();

      return Tournament.fromJson(response);
    } catch (error) {
      throw Exception('Failed to create tournament: $error');
    }
  }

  Future<List<Tournament>> getUserTournaments() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response =
          await _supabase.from('tournament_participants').select('''
            tournaments (*)
          ''').eq('user_id', user.id).order('created_at', ascending: false);

      return response
          .map<Tournament>((json) => Tournament.fromJson(json['tournaments']))
          .toList();
    } catch (error) {
      throw Exception('Failed to get user tournaments: $error');
    }
  }

  Future<List<Tournament>> getUserOrganizedTournaments() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _supabase
          .from('tournaments')
          .select()
          .eq('organizer_id', user.id)
          .order('created_at', ascending: false);

      return response
          .map<Tournament>((json) => Tournament.fromJson(json))
          .toList();
    } catch (error) {
      throw Exception('Failed to get organized tournaments: $error');
    }
  }

  Future<List<Tournament>> searchTournaments(String query) async {
    try {
      final response = await _supabase
          .from('tournaments')
          .select()
          .or('title.ilike.%$query%,description.ilike.%$query%')
          .eq('is_public', true)
          .order('start_date', ascending: true)
          .limit(20);

      return response
          .map<Tournament>((json) => Tournament.fromJson(json))
          .toList();
    } catch (error) {
      throw Exception('Failed to search tournaments: $error');
    }
  }

  Future<Map<String, dynamic>> getTournamentStats(String tournamentId) async {
    try {
      final tournament = await getTournamentById(tournamentId);
      final participants = await getTournamentParticipants(tournamentId);

      // Get matches for this tournament
      final matches = await _supabase
          .from('matches')
          .select()
          .eq('tournament_id', tournamentId);

      final completedMatches =
          matches.where((match) => match['status'] == 'completed').length;
      final pendingMatches =
          matches.where((match) => match['status'] == 'pending').length;

      return {
        'total_participants': participants.length,
        'max_participants': tournament.maxParticipants,
        'total_matches': matches.length,
        'completed_matches': completedMatches,
        'pending_matches': pendingMatches,
        'entry_fee': tournament.entryFee,
        'prize_pool': tournament.prizePool,
        'status': tournament.status,
      };
    } catch (error) {
      throw Exception('Failed to get tournament stats: $error');
    }
  }
}
