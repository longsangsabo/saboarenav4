// 🏗️ SABO ARENA - Enhanced Bracket Management Tab
// Tích hợp BracketGeneratorService vào Tournament Management Panel

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';
import '../../../models/user_profile.dart';
import '../../../services/bracket_generator_service.dart';
import '../../../services/tournament_service.dart' as TournamentSvc;
import 'package:supabase_flutter/supabase_flutter.dart';

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
  }

  Future<void> _loadRealParticipants() async {
    setState(() => _isLoadingParticipants = true);
    
    try {
      print('🔍 Loading participants for tournament: ${widget.tournamentId}');
      final participants = await _tournamentService.getTournamentParticipants(widget.tournamentId);
      print('✅ Loaded ${participants.length} participants from database');
      for (int i = 0; i < participants.length; i++) {
        print('  ${i + 1}. ${participants[i].fullName} (ELO: ${participants[i].eloRating})');
      }
      
      setState(() {
        _realParticipants = participants;
        _isLoadingParticipants = false;
      });
    } catch (e) {
      print('❌ Error loading participants: $e');
      setState(() => _isLoadingParticipants = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBracketStatus(),
          SizedBox(height: 20.sp),
          _buildBracketGenerator(),
          SizedBox(height: 20.sp),
          _buildBracketPreview(),
          SizedBox(height: 20.sp),
          _buildBracketActions(),
          if (_generatedBracket != null) ...[
            SizedBox(height: 20.sp),
            _buildGeneratedBracketInfo(),
          ],
        ],
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
          Text(
            "📊 Xem trước cấu trúc",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryLight,
            ),
          ),
          SizedBox(height: 12.sp),
          
          _buildFormatInfo(),
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
      print('Error adding demo participants: $e');
    }
  }

  void _generateBracket() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      // Use real participants from database
      print('🔍 Bracket Generation: Found ${_realParticipants.length} participants');
      
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
      print('🚀 Generating bracket with ${participants.length} participants');
      final bracket = await BracketGeneratorService.generateBracket(
        tournamentId: widget.tournamentId,
        format: _selectedFormat,
        participants: participants,
        seedingMethod: _selectedSeeding,
      );
      
      print('✅ Bracket generated successfully: ${bracket.toString()}');
      setState(() {
        _generatedBracket = bracket;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Đã tạo bảng đấu ${_getFormatName(_selectedFormat)} với ${participants.length} người chơi thật!'),
            backgroundColor: AppTheme.successLight,
          ),
        );
      }
    } catch (e) {
      print('❌ Error generating bracket: $e');
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



  void _showBracketDemo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.visibility, color: AppTheme.primaryLight),
            SizedBox(width: 8.sp),
            Text('Demo: ${_getFormatName(_selectedFormat)}'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🏆 Thể thức: ${_getFormatName(_selectedFormat)}'),
            SizedBox(height: 8.sp),
            Text('👥 Số người chơi: 16'),
            SizedBox(height: 8.sp),
            Text('🎯 Seeding: ${_seedingMethods.firstWhere((m) => m['key'] == _selectedSeeding)['label']}'),
            SizedBox(height: 16.sp),
            Text('Đây sẽ là demo cho bảng đấu $_selectedFormat với seeding $_selectedSeeding'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Đóng'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _generateBracket();
            },
            child: Text('Tạo thật'),
          ),
        ],
      ),
    );
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
                            subtitle: Text('Rank: ${participant.rank ?? 'Unranked'} • ELO: ${participant.eloRating}'),
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('🚀 Giải đấu đã bắt đầu!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text('Bắt đầu', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
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
          print('Error adding ${userData['full_name']}: $e');
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
      print('❌ Error adding demo participants to database: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Lỗi thêm vào database: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}