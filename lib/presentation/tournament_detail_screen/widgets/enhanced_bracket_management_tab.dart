// 🏗️ SABO ARENA - Enhanced Bracket Management Tab
// Tích hợp BracketGeneratorService vào Tournament Management Panel

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';
import '../../../models/user_profile.dart';
import '../../../services/bracket_generator_service.dart';
import '../../../services/tournament_service.dart' as TournamentSvc;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/utils/rank_migration_helper.dart';
import 'demo_bracket/formats/single_elimination_bracket.dart';
import 'demo_bracket/formats/double_elimination_bracket.dart';
import 'demo_bracket/formats/round_robin_bracket.dart';
import 'demo_bracket/formats/swiss_system_bracket.dart';
import 'quick_match_input_widget.dart';

// Tournament format constants
class TournamentFormats {
  static const String singleElimination = 'single_elimination';
  static const String doubleElimination = 'double_elimination';
  static const String roundRobin = 'round_robin';
  static const String swiss = 'swiss_system';
  static const String parallelGroups = 'parallel_groups';
}

// Seeding method constants
class SeedingMethods {
  static const String eloRating = 'elo_rating';
  static const String ranking = 'ranking';
  static const String random = 'random';
  static const String manual = 'manual';
}

class EnhancedBracketManagementTab extends StatefulWidget {
  final String tournamentId;

  const EnhancedBracketManagementTab({
    super.key,
    required this.tournamentId,
  });

  @override
  _EnhancedBracketManagementTabState createState() => _EnhancedBracketManagementTabState();
}

class _EnhancedBracketManagementTabState extends State<EnhancedBracketManagementTab> {
  bool _isGenerating = false;
  String _selectedFormat = TournamentFormats.singleElimination;
  String _selectedSeeding = SeedingMethods.eloRating;
  TournamentBracket? _generatedBracket;
  List<UserProfile> _realParticipants = [];
  bool _isLoadingParticipants = false;
  final _tournamentService = TournamentSvc.TournamentService.instance;
  final SupabaseClient supabase = Supabase.instance.client;
  
  // Tournament progression state
  bool _canAdvanceTournament = false;
  bool _isAdvancing = false;
  String? _tournamentProgressInfo;
  Map<int, Map<String, dynamic>>? _roundsInfo;
  
  final List<Map<String, String>> _tournamentFormats = [
    {'key': TournamentFormats.singleElimination, 'label': 'Loại trực tiếp'},
    {'key': TournamentFormats.doubleElimination, 'label': 'Loại kép'},
    {'key': TournamentFormats.roundRobin, 'label': 'Vòng tròn'},
    {'key': TournamentFormats.swiss, 'label': 'Hệ thống Thụy Sĩ'},
    {'key': TournamentFormats.parallelGroups, 'label': 'Nhóm song song'},
  ];

  final List<Map<String, String>> _seedingMethods = [
    {'key': SeedingMethods.eloRating, 'label': 'Theo ELO'},
    {'key': SeedingMethods.ranking, 'label': 'Theo Rank'},
    {'key': SeedingMethods.random, 'label': 'Ngẫu nhiên'},
    {'key': SeedingMethods.manual, 'label': 'Thủ công'},
  ];

  @override
  void initState() {
    super.initState();
    _loadRealParticipants();
    _checkTournamentProgress();
  }

  Future<void> _loadRealParticipants() async {
    setState(() => _isLoadingParticipants = true);
    
    try {
      debugPrint('🔍 Loading participants for tournament: ${widget.tournamentId}');
      final participants = await _tournamentService.getTournamentParticipants(widget.tournamentId);
      debugPrint('✅ Loaded ${participants.length} participants from database');
      for (int i = 0; i < participants.length; i++) {
        debugPrint('  ${i + 1}. ${participants[i].fullName} (ELO: ${participants[i].eloRating})');
      }
      
      setState(() {
        _realParticipants = participants;
        _isLoadingParticipants = false;
      });
    } catch (e) {
      debugPrint('❌ Error loading participants: $e');
      setState(() => _isLoadingParticipants = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(12.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            
            // Main bracket management content
            _buildBracketStatus(),
            SizedBox(height: 16.sp),
            _buildTournamentProgress(),
            SizedBox(height: 16.sp),
            _buildBracketGenerator(),
            SizedBox(height: 16.sp),
            _buildCurrentMatches(),
            SizedBox(height: 16.sp), 
            _buildBracketPreview(),
            SizedBox(height: 16.sp),
            _buildBracketActions(),
            if (_generatedBracket != null) ...[
              SizedBox(height: 16.sp),
              _buildGeneratedBracketInfo(),
            ],
            // Debug actions for development
            if (_realParticipants.isEmpty) ...[
              SizedBox(height: 16.sp),
              _buildDebugActions(),
            ],
            // Bottom padding for better scrolling
            SizedBox(height: 100.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildBracketStatus() {
    return Container(
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade400, Colors.deepOrange.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.sp),
      ),
      child: Row(
        children: [
          Icon(Icons.account_tree, color: Colors.white, size: 24.sp),
          SizedBox(width: 12.sp),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "🏗️ Trạng thái bảng đấu",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.sp),
                Text(
                  _generatedBracket == null
                      ? "Chưa tạo bảng đấu • ${_realParticipants.length} người chơi đã đăng ký"
                      : "Đã tạo bảng đấu ${_getFormatName(_generatedBracket!.format)} • ${_generatedBracket!.participants.length} người chơi",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          if (_generatedBracket != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 4.sp),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12.sp),
              ),
              child: Text(
                "✅ Hoàn thành",
                style: TextStyle(
                  fontSize: 10.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTournamentProgress() {
    if (_tournamentProgressInfo == null && _roundsInfo == null) {
      return SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _canAdvanceTournament 
            ? [Colors.green.shade400, Colors.teal.shade500]
            : [Colors.blue.shade400, Colors.indigo.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.sp),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _canAdvanceTournament ? Icons.rocket_launch : Icons.hourglass_empty,
                color: Colors.white,
                size: 20.sp,
              ),
              SizedBox(width: 8.sp),
              Text(
                "Tournament Progress",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.sp),
          
          if (_tournamentProgressInfo != null)
            Text(
              _tournamentProgressInfo!,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          
          if (_roundsInfo != null) ...[
            SizedBox(height: 12.sp),
            ...(_roundsInfo!.entries.map((entry) {
              final roundNum = entry.key;
              final info = entry.value;
              final isComplete = info['isComplete'] as bool;
              
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 2.sp),
                child: Row(
                  children: [
                    Icon(
                      isComplete ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: Colors.white70,
                      size: 16.sp,
                    ),
                    SizedBox(width: 8.sp),
                    Text(
                      'Round $roundNum: ${info['completed']}/${info['total']} matches',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              );
            })),
          ],
          
          if (_canAdvanceTournament) ...[
            SizedBox(height: 16.sp),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isAdvancing ? null : _advanceTournament,
                icon: _isAdvancing 
                  ? SizedBox(
                      width: 16.sp,
                      height: 16.sp,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(Icons.arrow_forward),
                label: Text(_isAdvancing ? "Creating Next Round..." : "🚀 Advance Tournament"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.green.shade600,
                  padding: EdgeInsets.symmetric(vertical: 12.sp),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.sp),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBracketGenerator() {
    return Container(
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.sp),
        border: Border.all(color: AppTheme.dividerLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "🎯 Tạo bảng đấu mới",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryLight,
            ),
          ),
          SizedBox(height: 16.sp),

          // Format Selection
          Text(
            "Chọn thể thức thi đấu",
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimaryLight,
            ),
          ),
          SizedBox(height: 8.sp),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.dividerLight),
              borderRadius: BorderRadius.circular(8.sp),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedFormat,
                isExpanded: true,
                padding: EdgeInsets.symmetric(horizontal: 12.sp),
                items: _tournamentFormats.map((format) {
                  return DropdownMenuItem<String>(
                    value: format['key'],
                    child: Text(format['label']!),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedFormat = value!;
                  });
                },
              ),
            ),
          ),

          SizedBox(height: 16.sp),

          // Seeding Method Selection
          Text(
            "Phương thức xếp hạng (Seeding)",
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimaryLight,
            ),
          ),
          SizedBox(height: 8.sp),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.dividerLight),
              borderRadius: BorderRadius.circular(8.sp),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedSeeding,
                isExpanded: true,
                padding: EdgeInsets.symmetric(horizontal: 12.sp),
                items: _seedingMethods.map((method) {
                  return DropdownMenuItem<String>(
                    value: method['key'],
                    child: Text(method['label']!),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSeeding = value!;
                  });
                },
              ),
            ),
          ),

          SizedBox(height: 20.sp),

          // Generate Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isGenerating ? null : _generateBracket,
              icon: _isGenerating 
                ? SizedBox(
                    width: 16.sp,
                    height: 16.sp,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Icon(Icons.auto_fix_high),
              label: Text(_isGenerating ? "Đang tạo bảng đấu..." : "🚀 Tạo bảng đấu"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryLight,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12.sp),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.sp),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBracketPreview() {
    return Container(
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.sp),
        border: Border.all(color: AppTheme.dividerLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "📊 Xem trước cấu trúc",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryLight,
                ),
              ),
              TextButton.icon(
                onPressed: () => _showBracketVisualPreview(),
                icon: Icon(Icons.visibility, size: 16.sp),
                label: Text("Xem bracket"),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.primaryLight,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.sp),
          
          _buildFormatInfo(),
          
          SizedBox(height: 16.sp),
          
          // Participants preview
          Container(
            padding: EdgeInsets.all(12.sp),
            decoration: BoxDecoration(
              color: AppTheme.backgroundLight,
              borderRadius: BorderRadius.circular(8.sp),
              border: Border.all(color: AppTheme.dividerLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.people, color: AppTheme.primaryLight, size: 18.sp),
                    SizedBox(width: 8.sp),
                    Text(
                      "Người tham gia (${_realParticipants.length})",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.sp),
                if (_realParticipants.isEmpty) 
                  Text(
                    "Chưa có người tham gia nào. Hãy thêm demo users để test.",
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppTheme.textSecondaryLight,
                      fontStyle: FontStyle.italic,
                    ),
                  )
                else
                  SizedBox(
                    height: 60.sp,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _realParticipants.length > 5 ? 5 : _realParticipants.length,
                      itemBuilder: (context, index) {
                        if (index == 4 && _realParticipants.length > 5) {
                          return Container(
                            width: 50.sp,
                            margin: EdgeInsets.only(right: 8.sp),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryLight.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.sp),
                              border: Border.all(color: AppTheme.primaryLight.withOpacity(0.3)),
                            ),
                            child: Center(
                              child: Text(
                                '+${_realParticipants.length - 4}',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryLight,
                                ),
                              ),
                            ),
                          );
                        }
                        
                        final participant = _realParticipants[index];
                        return Container(
                          width: 50.sp,
                          margin: EdgeInsets.only(right: 8.sp),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryLight.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.sp),
                            border: Border.all(color: AppTheme.primaryLight.withOpacity(0.3)),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 12.sp,
                                backgroundColor: AppTheme.primaryLight,
                                child: Text(
                                  participant.fullName.isNotEmpty 
                                    ? participant.fullName[0].toUpperCase()
                                    : 'U',
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(height: 4.sp),
                              Text(
                                participant.fullName.length > 8 
                                  ? '${participant.fullName.substring(0, 8)}...'
                                  : participant.fullName,
                                style: TextStyle(
                                  fontSize: 8.sp,
                                  color: AppTheme.textSecondaryLight,
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatInfo() {
    final formatInfo = _getFormatInfo(_selectedFormat);
    
    return Container(
      padding: EdgeInsets.all(12.sp),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(8.sp),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(formatInfo['icon'], color: AppTheme.primaryLight, size: 20.sp),
              SizedBox(width: 8.sp),
              Text(
                formatInfo['name'],
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryLight,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.sp),
          Text(
            formatInfo['description'],
            style: TextStyle(
              fontSize: 12.sp,
              color: AppTheme.textSecondaryLight,
            ),
          ),
          SizedBox(height: 8.sp),
          Wrap(
            spacing: 8.sp,
            runSpacing: 4.sp,
            children: [
              _buildInfoChip("Vòng đấu", formatInfo['rounds']),
              _buildInfoChip("Trận đấu", formatInfo['matches']),
              _buildInfoChip("Thời gian", formatInfo['duration']),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 4.sp),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4.sp),
        border: Border.all(color: AppTheme.primaryLight.withOpacity(0.3)),
      ),
      child: Text(
        "$label: $value",
        style: TextStyle(
          fontSize: 10.sp,
          color: AppTheme.primaryLight,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Build current matches section with Quick Match Input
  Widget _buildCurrentMatches() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _loadCurrentMatches(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: EdgeInsets.all(16.sp),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Container(
            padding: EdgeInsets.all(16.sp),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12.sp),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Text(
              'Error loading matches: ${snapshot.error}',
              style: TextStyle(color: Colors.red.shade700),
            ),
          );
        }

        final matches = snapshot.data ?? [];
        final pendingMatches = matches.where((m) => m['status'] == 'pending').toList();

        return QuickMatchInputWidget(
          tournamentId: widget.tournamentId,
          pendingMatches: pendingMatches,
          onMatchUpdated: () {
            setState(() {}); // Trigger rebuild
            _checkTournamentProgress(); // Check for auto-advancement
          },
        );
      },
    );
  }

  /// Load current matches from database
  Future<List<Map<String, dynamic>>> _loadCurrentMatches() async {
    try {
      final response = await supabase
          .from('matches')
          .select('''
            id,
            round_number,
            match_number, 
            player1_id,
            player2_id,
            winner_id,
            player1_score,
            player2_score,
            status,
            player1:player1_id(full_name),
            player2:player2_id(full_name)
          ''')
          .eq('tournament_id', widget.tournamentId)
          .order('round_number, match_number');

      return response.map<Map<String, dynamic>>((match) {
        return {
          ...match,
          'player1_name': match['player1']?['full_name'] ?? 'Player 1',
          'player2_name': match['player2']?['full_name'] ?? 'Player 2',
        };
      }).toList();

    } catch (e) {
      debugPrint('❌ Error loading matches: $e');
      return [];
    }
  }

  Widget _buildBracketActions() {
    return Container(
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.sp),
        border: Border.all(color: AppTheme.dividerLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "⚡ Thao tác nhanh",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryLight,
            ),
          ),
          SizedBox(height: 12.sp),
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showBracketDemo(),
                  icon: Icon(Icons.visibility, size: 16.sp),
                  label: Text("Xem demo"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryLight,
                    side: BorderSide(color: AppTheme.primaryLight),
                  ),
                ),
              ),
              SizedBox(width: 12.sp),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showSeededParticipants(),
                  icon: Icon(Icons.people, size: 16.sp),
                  label: Text("Xem seeding"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.warningLight,
                    side: BorderSide(color: AppTheme.warningLight),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGeneratedBracketInfo() {
    if (_generatedBracket == null) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade400, Colors.teal.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.sp),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 24.sp),
              SizedBox(width: 12.sp),
              Text(
                "✅ Bảng đấu đã được tạo",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.sp),
          
          Row(
            children: [
              Expanded(
                child: _buildBracketStat("Thể thức", _getFormatName(_generatedBracket!.format)),
              ),
              Expanded(
                child: _buildBracketStat("Người chơi", "${_generatedBracket!.participants.length}"),
              ),
            ],
          ),
          SizedBox(height: 8.sp),
          Row(
            children: [
              Expanded(
                child: _buildBracketStat("Vòng đấu", "${_generatedBracket!.rounds}"),
              ),
              Expanded(
                child: _buildBracketStat("Trận đấu", "${_calculateTotalMatches(_generatedBracket!)}"),
              ),
            ],
          ),
          
          SizedBox(height: 16.sp),
          
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showFullBracket(),
                  icon: Icon(Icons.fullscreen, size: 16.sp),
                  label: Text("Xem toàn bộ"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.green.shade600,
                  ),
                ),
              ),
              SizedBox(width: 12.sp),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _startTournament(),
                  icon: Icon(Icons.play_arrow, size: 16.sp),  
                  label: Text("Bắt đầu"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.green.shade600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBracketStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Map<String, dynamic> _getFormatInfo(String format) {
    switch (format) {
      case TournamentFormats.singleElimination:
        return {
          'name': 'Loại trực tiếp',
          'description': 'Người chơi bị loại sau khi thua 1 trận. Nhanh gọn, phù hợp với số lượng người chơi lớn.',
          'icon': Icons.account_tree,
          'rounds': '4',
          'matches': '15',
          'duration': '3-4 giờ',
        };
      case TournamentFormats.doubleElimination:
        return {
          'name': 'Loại kép',
          'description': 'Người chơi phải thua 2 lần mới bị loại. Công bằng hơn, có cơ hội phục hồi.',
          'icon': Icons.account_tree_outlined,
          'rounds': '7',
          'matches': '30',
          'duration': '6-8 giờ',
        };
      case TournamentFormats.roundRobin:
        return {
          'name': 'Vòng tròn',
          'description': 'Mọi người chơi đấu với nhau 1 lần. Công bằng nhất, phù hợp với số người ít.',
          'icon': Icons.refresh,
          'rounds': '15',
          'matches': '120',
          'duration': '1-2 ngày',
        };
      case TournamentFormats.swiss:
        return {
          'name': 'Hệ thống Thụy Sĩ',
          'description': 'Ghép cặp theo điểm số hiện tại. Cân bằng giữa tính công bằng và thời gian.',
          'icon': Icons.shuffle,
          'rounds': '4',
          'matches': '64',
          'duration': '4-5 giờ',
        };
      case TournamentFormats.parallelGroups:
        return {
          'name': 'Nhóm song song',
          'description': 'Chia thành nhiều nhóm thi đấu song song, sau đó knockout với những người xuất sắc nhất.',
          'icon': Icons.group_work,
          'rounds': '6',
          'matches': '48',
          'duration': '5-6 giờ',
        };
      default:
        return {
          'name': 'Chưa chọn',
          'description': 'Vui lòng chọn thể thức thi đấu',
          'icon': Icons.help_outline,
          'rounds': '?',
          'matches': '?',
          'duration': '?',
        };
    }
  }

  String _getFormatName(String format) {
    return _getFormatInfo(format)['name'];
  }

  Widget _buildDebugActions() {
    return Container(
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: Colors.yellow.shade50,
        borderRadius: BorderRadius.circular(12.sp),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "🛠️ Debug Actions",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade700,
            ),
          ),
          SizedBox(height: 12.sp),
          Text(
            "Số người tham gia hiện tại: ${_realParticipants.length}",
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.orange.shade600,
            ),
          ),
          SizedBox(height: 8.sp),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _addDemoParticipants,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade600,
                    foregroundColor: Colors.white,
                  ),
                  child: Text("Demo (Local)"),
                ),
              ),
              SizedBox(width: 8.sp),
              Expanded(
                child: ElevatedButton(
                  onPressed: _addDemoParticipantsToDatabase,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                  ),
                  child: Text("Add to DB"),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.sp),
          ElevatedButton(
            onPressed: _loadRealParticipants,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
            ),
            child: Text("🔄 Reload từ Database"),
          ),
        ],
      ),
    );
  }

  void _addDemoParticipants() async {
    try {
      // Add some demo participants for testing
      final demoUsers = [
        {'full_name': 'Nguyễn Văn A', 'elo_rating': 1500, 'rank': 'intermediate'},
        {'full_name': 'Trần Thị B', 'elo_rating': 1400, 'rank': 'beginner'},
        {'full_name': 'Lê Văn C', 'elo_rating': 1600, 'rank': 'advanced'},
        {'full_name': 'Phạm Thị D', 'elo_rating': 1350, 'rank': 'beginner'},
      ];

      for (final user in demoUsers) {
        final demoParticipant = UserProfile(
          id: 'demo_${DateTime.now().millisecondsSinceEpoch}_${user['full_name']?.hashCode}',
          email: 'demo@example.com',
          fullName: user['full_name'] as String,
          displayName: user['full_name'] as String,
          role: 'player',
          skillLevel: user['rank'] as String,
          rank: user['rank'] as String,
          totalWins: 0,
          totalLosses: 0,
          totalTournaments: 0,
          eloRating: user['elo_rating'] as int,
          spaPoints: 0,
          totalPrizePool: 0.0,
          isVerified: false,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        _realParticipants.add(demoParticipant);
      }

      setState(() {});
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Đã thêm ${demoUsers.length} người tham gia demo!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint('Error adding demo participants: $e');
    }
  }

  void _generateBracket() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      // Use real participants from database
      debugPrint('🔍 Bracket Generation: Found ${_realParticipants.length} participants');
      
      if (_realParticipants.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Không có người tham gia nào!'),
            backgroundColor: AppTheme.warningLight,
          ),
        );
        setState(() {
          _isGenerating = false;
        });
        return;
      }

      if (_realParticipants.length < 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Cần ít nhất 2 người tham gia để tạo bảng đấu!'),
            backgroundColor: AppTheme.warningLight,
          ),
        );
        setState(() {
          _isGenerating = false;
        });
        return;
      }

      // Convert real participants to tournament participants
      final participants = _realParticipants.map((user) => TournamentParticipant(
        id: user.id,
        name: user.fullName,
        rank: user.rank ?? 'Unranked',
        elo: user.eloRating,
        seed: 1, // Will be updated by seeding method
      )).toList();
      
      // Use BracketGeneratorService to generate bracket
      debugPrint('🚀 Generating bracket with ${participants.length} participants');
      final bracket = await BracketGeneratorService.generateBracket(
        tournamentId: widget.tournamentId,
        format: _selectedFormat,
        participants: participants,
        seedingMethod: _selectedSeeding,
      );
      
      debugPrint('✅ Bracket generated successfully');
      
      // Save bracket to database
      await _saveBracketToDatabase(bracket);
      
      setState(() {
        _generatedBracket = bracket;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Đã tạo và lưu bảng đấu ${_getFormatName(_selectedFormat)} với ${participants.length} người chơi!'),
            backgroundColor: AppTheme.successLight,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error generating bracket: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Lỗi tạo bảng đấu: $e'),
            backgroundColor: AppTheme.errorLight,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }



  void _showBracketVisualPreview() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.sp),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(16.sp),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryLight, AppTheme.primaryLight.withOpacity(0.8)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.sp),
                    topRight: Radius.circular(16.sp),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.visibility, color: Colors.white, size: 24.sp),
                    SizedBox(width: 12.sp),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Xem trước: ${_getFormatName(_selectedFormat)}',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '${_realParticipants.length} người chơi • ${_seedingMethods.firstWhere((m) => m['key'] == _selectedSeeding)['label']}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              
              // Bracket Preview Content
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(16.sp),
                  child: _buildVisualBracketPreview(),
                ),
              ),
              
              // Actions
              Container(
                padding: EdgeInsets.all(16.sp),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundLight,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16.sp),
                    bottomRight: Radius.circular(16.sp),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Đóng'),
                      ),
                    ),
                    SizedBox(width: 12.sp),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _generateBracket();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryLight,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('🚀 Tạo bảng đấu'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVisualBracketPreview() {
    if (_realParticipants.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64.sp,
              color: AppTheme.textSecondaryLight,
            ),
            SizedBox(height: 16.sp),
            Text(
              'Chưa có người tham gia',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.textSecondaryLight,
              ),
            ),
            SizedBox(height: 8.sp),
            Text(
              'Hãy thêm người chơi để xem preview bảng đấu',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppTheme.textSecondaryLight,
              ),
            ),
            SizedBox(height: 20.sp),
            ElevatedButton.icon(
              onPressed: _addDemoParticipantsToDatabase,
              icon: Icon(Icons.add, size: 16.sp),
              label: Text('Thêm demo players'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryLight,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    // Determine player count for demo (use actual or simulate with 8/16)
    int demoPlayerCount = _realParticipants.length;
    if (demoPlayerCount < 4) demoPlayerCount = 8;
    if (demoPlayerCount > 32) demoPlayerCount = 32;
    
    // Adjust to next power of 2 for single/double elimination
    if (_selectedFormat == TournamentFormats.singleElimination || 
        _selectedFormat == TournamentFormats.doubleElimination) {
      final powers = [4, 8, 16, 32];
      demoPlayerCount = powers.firstWhere((p) => p >= demoPlayerCount, orElse: () => 16);
    }

    return _buildFormatSpecificPreview(demoPlayerCount);
  }

  Widget _buildFormatSpecificPreview(int playerCount) {
    switch (_selectedFormat) {
      case TournamentFormats.singleElimination:
        return SingleEliminationBracket(
          playerCount: playerCount,
          onFullscreenTap: null, // Disable fullscreen in preview
        );
      case TournamentFormats.doubleElimination:
        return DoubleEliminationBracket(
          playerCount: playerCount,
          onFullscreenTap: null,
        );
      case TournamentFormats.roundRobin:
        return RoundRobinBracket(
          playerCount: playerCount,
          onFullscreenTap: null,
        );
      case TournamentFormats.swiss:
        return SwissSystemBracket(
          playerCount: playerCount,
          onFullscreenTap: null,
        );
      default:
        return Container(
          padding: EdgeInsets.all(20.sp),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.construction,
                  size: 48.sp,
                  color: AppTheme.textSecondaryLight,
                ),
                SizedBox(height: 16.sp),
                Text(
                  'Preview chưa sẵn sàng',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textSecondaryLight,
                  ),
                ),
                SizedBox(height: 8.sp),
                Text(
                  'Format ${_getFormatName(_selectedFormat)} đang được phát triển',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppTheme.textSecondaryLight,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
    }
  }

  void _showBracketDemo() {
    _showBracketVisualPreview();
  }

  void _showSeededParticipants() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.people, color: AppTheme.warningLight),
            SizedBox(width: 8.sp),
            Text('Xem trước Seeding'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Danh sách người chơi sau khi seeding theo ${_seedingMethods.firstWhere((m) => m['key'] == _selectedSeeding)['label']}:'),
              SizedBox(height: 16.sp),
              SizedBox(
                height: 300,
                child: _isLoadingParticipants 
                  ? Center(child: CircularProgressIndicator())
                  : _realParticipants.isEmpty
                    ? Center(child: Text('Chưa có người tham gia nào'))
                    : ListView.builder(
                        itemCount: _realParticipants.length,
                        itemBuilder: (context, index) {
                          final participant = _realParticipants[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppTheme.primaryLight,
                              foregroundColor: Colors.white,
                              child: Text('${index + 1}'),
                            ),
                            title: Text(participant.fullName),
                            subtitle: Text('Rank: ${RankMigrationHelper.getNewDisplayName(participant.rank)} • ELO: ${participant.eloRating}'),
                            trailing: Text('Seed ${index + 1}'),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showFullBracket() {
    // Navigate to full bracket view
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🏆 Mở bảng đấu đầy đủ...'),
        backgroundColor: AppTheme.successLight,
      ),
    );
  }

  void _startTournament() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.play_arrow, color: Colors.green),
            SizedBox(width: 8.sp),
            Text('Bắt đầu giải đấu'),
          ],
        ),
        content: Text('Bạn có chắc chắn muốn bắt đầu giải đấu này? Sau khi bắt đầu, bảng đấu sẽ không thể chỉnh sửa.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _actuallyStartTournament();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text('Bắt đầu', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _actuallyStartTournament() async {
    debugPrint('� SIMPLE: Starting tournament directly');
    
    try {
      final supabase = Supabase.instance.client;
      
      // Get tournament participants
      debugPrint('👥 SIMPLE: Getting participants...');
      final participantsResponse = await supabase
          .from('tournament_participants')
          .select('user_id')
          .eq('tournament_id', widget.tournamentId)
          .eq('status', 'registered');

      final participantIds = participantsResponse
          .map<String>((p) => p['user_id'] as String)
          .toList();

      debugPrint('� SIMPLE: Found ${participantIds.length} participants');

      if (participantIds.length < 2) {
        throw Exception('Cần ít nhất 2 người chơi để bắt đầu giải đấu');
      }

      // Create simple first round matches
      final List<Map<String, dynamic>> matches = [];
      int matchCounter = 1;

      // Pair participants for first round
      for (int i = 0; i < participantIds.length - 1; i += 2) {
        final player1Id = participantIds[i];
        final player2Id = i + 1 < participantIds.length ? participantIds[i + 1] : null;

        matches.add({
          'tournament_id': widget.tournamentId,
          'player1_id': player1Id,
          'player2_id': player2Id,
          'round_number': 1,
          'match_number': matchCounter++,
          'status': player2Id == null ? 'completed' : 'pending',
          'winner_id': player2Id == null ? player1Id : null,
          'player1_score': player2Id == null ? 2 : 0,
          'player2_score': 0,
        });

        debugPrint('⚔️ SIMPLE: Match ${matchCounter - 1}: $player1Id vs ${player2Id ?? "BYE"}');
      }

      // Insert matches
      debugPrint('� SIMPLE: Inserting ${matches.length} matches...');
      await supabase.from('matches').insert(matches);
      debugPrint('✅ SIMPLE: Matches inserted successfully');

      // Update tournament status
      await supabase
          .from('tournaments')
          .update({'status': 'in_progress'})
          .eq('id', widget.tournamentId);

      debugPrint('✅ SIMPLE: Tournament started successfully');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 Giải đấu đã bắt đầu! Tạo ${matches.length} trận đấu thành công!'),
          backgroundColor: Colors.green,
        ),
      );
      
    } catch (e, stackTrace) {
      debugPrint('❌ SIMPLE: Error starting tournament: $e');
      debugPrint('❌ SIMPLE: Stack trace: $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Lỗi: $e'),
          backgroundColor: AppTheme.errorLight,
        ),
      );
    }
  }

  int _calculateTotalMatches(TournamentBracket bracket) {
    return bracket.rounds.fold<int>(0, (sum, round) => sum + round.matches.length);
  }

  void _addDemoParticipantsToDatabase() async {
    try {
      // Add demo participants directly to database
      final demoUsers = [
        {'full_name': 'Demo Player 1', 'email': 'demo1@test.com', 'elo_rating': 1500},
        {'full_name': 'Demo Player 2', 'email': 'demo2@test.com', 'elo_rating': 1400},
        {'full_name': 'Demo Player 3', 'email': 'demo3@test.com', 'elo_rating': 1600},
        {'full_name': 'Demo Player 4', 'email': 'demo4@test.com', 'elo_rating': 1350},
        {'full_name': 'Demo Player 5', 'email': 'demo5@test.com', 'elo_rating': 1450},
      ];

      for (final userData in demoUsers) {
        try {
          // Insert into users table first (if not exists)
          final userResult = await Supabase.instance.client
              .from('users')
              .upsert({
                'id': 'demo_${userData['email']?.hashCode}',
                'email': userData['email'],
                'full_name': userData['full_name'],
                'role': 'player',
                'skill_level': 'intermediate',
                'rank': 'intermediate',
                'total_wins': 0,
                'total_losses': 0,
                'total_tournaments': 0,
                'elo_rating': userData['elo_rating'],
                'spa_points': 0,
                'total_prize_pool': 0.0,
                'is_verified': false,
                'is_active': true,
                'created_at': DateTime.now().toIso8601String(),
                'updated_at': DateTime.now().toIso8601String(),
              })
              .select();

          if (userResult.isNotEmpty) {
            final userId = userResult[0]['id'];
            
            // Insert into tournament_participants
            await Supabase.instance.client
                .from('tournament_participants')
                .upsert({
                  'id': 'tp_${widget.tournamentId}_$userId',
                  'tournament_id': widget.tournamentId,
                  'user_id': userId,
                  'status': 'confirmed',
                  'registered_at': DateTime.now().toIso8601String(),
                  'payment_status': 'paid',
                })
                .select();
          }
        } catch (e) {
          debugPrint('Error adding ${userData['full_name']}: $e');
        }
      }

      // Reload participants
      await _loadRealParticipants();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Đã thêm ${demoUsers.length} demo users vào database!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint('❌ Error adding demo participants to database: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Lỗi thêm vào database: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Save bracket to database - store all matches with tournament info
  Future<void> _saveBracketToDatabase(TournamentBracket bracket) async {
    try {
      debugPrint('💾 Saving bracket to database...');
      
      final List<Map<String, dynamic>> matchesToInsert = [];
      
      // Process all rounds and matches
      for (final round in bracket.rounds) {
        for (final match in round.matches) {
          matchesToInsert.add({
            'tournament_id': widget.tournamentId,
            'round_number': match.roundNumber,
            'match_number': match.matchNumber,
            'player1_id': match.player1?.id,
            'player2_id': match.player2?.id,
            'player1_score': null,
            'player2_score': null,
            'winner_id': null,
            'status': 'pending',
            'scheduled_time': null,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          });
        }
      }
      
      if (matchesToInsert.isNotEmpty) {
        // Delete existing matches for this tournament first
        await supabase
            .from('matches')
            .delete()
            .eq('tournament_id', widget.tournamentId);
            
        // Insert new matches
        await supabase.from('matches').insert(matchesToInsert);
        
        debugPrint('✅ Saved ${matchesToInsert.length} matches to database');
      }
      
      // Update tournament status to indicate bracket is created
      await supabase
          .from('tournaments')
          .update({
            'status': 'bracket_created',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', widget.tournamentId);
          
      debugPrint('✅ Tournament status updated to bracket_created');
      
      // Refresh tournament progress after saving
      await _checkTournamentProgress();
      
    } catch (e) {
      debugPrint('❌ Error saving bracket to database: $e');
      rethrow;
    }
  }

  /// Check tournament progress and determine if advancement is possible
  Future<void> _checkTournamentProgress() async {
    try {
      debugPrint('🔍 Checking tournament progress...');
      
      // Get current matches
      final matchesResponse = await supabase
          .from('matches')
          .select('*')
          .eq('tournament_id', widget.tournamentId)
          .order('round_number, match_number');
      
      if (matchesResponse.isEmpty) {
        setState(() {
          _canAdvanceTournament = false;
          _tournamentProgressInfo = 'No matches found - Generate bracket first';
          _roundsInfo = null;
        });
        return;
      }

      // Group matches by round
      final roundsMap = <int, List<Map<String, dynamic>>>{};
      for (final match in matchesResponse) {
        final roundNum = match['round_number'] as int;
        if (!roundsMap.containsKey(roundNum)) {
          roundsMap[roundNum] = [];
        }
        roundsMap[roundNum]!.add(match);
      }

      // Analyze each round
      final roundsInfo = <int, Map<String, dynamic>>{};
      bool canAdvance = false;
      String progressInfo = '';
      
      final sortedRounds = roundsMap.keys.toList()..sort();
      
      for (final roundNum in sortedRounds) {
        final roundMatches = roundsMap[roundNum]!;
        final completedCount = roundMatches.where((m) => m['status'] == 'completed').length;
        final pendingCount = roundMatches.where((m) => m['status'] == 'pending').length;
        
        roundsInfo[roundNum] = {
          'total': roundMatches.length,
          'completed': completedCount,
          'pending': pendingCount,
          'isComplete': completedCount == roundMatches.length,
        };
      }

      // Find the highest completed round
      int? completedRound;
      for (final roundNum in sortedRounds.reversed) {
        if (roundsInfo[roundNum]!['isComplete'] == true) {
          completedRound = roundNum;
          break;
        }
      }

      if (completedRound != null) {
        final nextRoundNum = completedRound + 1;
        final hasNextRound = roundsMap.containsKey(nextRoundNum);
        
        if (!hasNextRound) {
          // Check if tournament is finished (only 1 winner)
          final completedMatches = roundsMap[completedRound]!;
          final winners = completedMatches.where((m) => m['winner_id'] != null).length;
          
          if (winners == 1) {
            progressInfo = 'Tournament completed! 🏆';
            canAdvance = false;
          } else {
            final roundName = _getRoundName(winners);
            progressInfo = 'Round $completedRound completed - Ready to create $roundName!';
            canAdvance = true;
          }
        } else {
          progressInfo = 'All rounds created - Tournament in progress';
          canAdvance = false;
        }
      } else {
        final currentRound = sortedRounds.first;
        final currentInfo = roundsInfo[currentRound]!;
        progressInfo = 'Round $currentRound: ${currentInfo['completed']}/${currentInfo['total']} matches completed';
        canAdvance = false;
      }

      setState(() {
        _canAdvanceTournament = canAdvance;
        _tournamentProgressInfo = progressInfo;
        _roundsInfo = roundsInfo;
      });

      debugPrint('✅ Tournament progress checked: $progressInfo');
      
      // 🚀 AUTO-ADVANCE: Tự động tiến hành tournament khi ready
      if (canAdvance && !_isAdvancing) {
        debugPrint('🚀 Auto-advancing tournament...');
        await _advanceTournament();
      }
      
    } catch (e) {
      debugPrint('❌ Error checking tournament progress: $e');
      setState(() {
        _canAdvanceTournament = false;
        _tournamentProgressInfo = 'Error checking progress';
        _roundsInfo = null;
      });
    }
  }

  /// Get Vietnamese round name based on number of winners
  String _getRoundName(int winnerCount) {
    switch (winnerCount) {
      case 1:
        return 'Chung kết';
      case 2:
        return 'Bán kết';
      case 4:
        return 'Tứ kết';
      case 8:
        return 'Vòng 16';
      default:
        return 'Vòng tiếp theo';
    }
  }

  /// Advance tournament to next round
  Future<void> _advanceTournament() async {
    if (!_canAdvanceTournament || _isAdvancing) return;

    setState(() => _isAdvancing = true);

    try {
      debugPrint('🚀 Advancing tournament...');
      
      // Get participants as TournamentParticipant objects
      final participants = _realParticipants.map((p) => TournamentParticipant(
        id: p.id,
        name: p.fullName,
        seed: p.eloRating,
      )).toList();

      // Get current matches
      final matchesResponse = await supabase
          .from('matches')
          .select('*')
          .eq('tournament_id', widget.tournamentId)
          .order('round_number, match_number');

      final currentMatches = matchesResponse.map((m) {
        TournamentParticipant? player1, player2, winner;
        
        if (m['player1_id'] != null) {
          player1 = participants.firstWhere(
            (p) => p.id == m['player1_id'],
            orElse: () => TournamentParticipant(id: m['player1_id'], name: 'Unknown'),
          );
        }
        
        if (m['player2_id'] != null) {
          player2 = participants.firstWhere(
            (p) => p.id == m['player2_id'],
            orElse: () => TournamentParticipant(id: m['player2_id'], name: 'Unknown'),
          );
        }
        
        if (m['winner_id'] != null) {
          winner = participants.firstWhere(
            (p) => p.id == m['winner_id'],
            orElse: () => TournamentParticipant(id: m['winner_id'], name: 'Winner'),
          );
        }
        
        return TournamentMatch(
          id: m['id'],
          roundId: 'round_${m['round_number']}',
          roundNumber: m['round_number'],
          matchNumber: m['match_number'],
          player1: player1,
          player2: player2,
          winner: winner,
          status: m['status'] ?? 'pending',
        );
      }).toList();

      // Use BracketGeneratorService to advance tournament
      final bracketService = BracketGeneratorService();
      final result = await bracketService.advanceTournament(
        tournamentId: widget.tournamentId,
        participants: participants,
        currentMatches: currentMatches,
        format: _selectedFormat,
      );

      if (result['success'] == true) {
        final newMatches = result['newMatches'] as List<TournamentMatch>;
        final roundName = result['roundName'] ?? 'Next Round';
        
        debugPrint('✅ Generated ${newMatches.length} new matches for $roundName');

        // Save new matches to database
        for (final match in newMatches) {
          await supabase.from('matches').insert({
            'id': match.id,
            'tournament_id': widget.tournamentId,
            'round_number': match.roundNumber,
            'match_number': match.matchNumber,
            'player1_id': match.player1?.id,
            'player2_id': match.player2?.id,
            'status': match.status,
            'created_at': DateTime.now().toIso8601String(),
          });
        }

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('🎉 $roundName created with ${newMatches.length} matches!'),
              backgroundColor: Colors.green,
            ),
          );
        }

        // Refresh tournament progress
        await _checkTournamentProgress();
        
      } else {
        final message = result['message'] ?? 'Failed to advance tournament';
        debugPrint('❌ Tournament advancement failed: $message');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ $message'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }

    } catch (e) {
      debugPrint('❌ Error advancing tournament: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error advancing tournament: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isAdvancing = false);
    }
  }
}