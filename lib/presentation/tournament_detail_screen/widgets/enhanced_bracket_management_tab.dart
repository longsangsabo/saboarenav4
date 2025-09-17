// 🏗️ SABO ARENA - Enhanced Bracket Management Tab
// Tích hợp BracketGeneratorService vào Tournament Management Panel

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';
import '../../../services/bracket_generator_service.dart';

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
    Key? key,
    required this.tournamentId,
  }) : super(key: key);

  @override
  _EnhancedBracketManagementTabState createState() => _EnhancedBracketManagementTabState();
}

class _EnhancedBracketManagementTabState extends State<EnhancedBracketManagementTab> {
  bool _isGenerating = false;
  String _selectedFormat = TournamentFormats.singleElimination;
  String _selectedSeeding = SeedingMethods.eloRating;
  TournamentBracket? _generatedBracket;
  
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
                      ? "Chưa tạo bảng đấu • 16 người chơi đã đăng ký"
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

  void _generateBracket() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      // Mock participants for demo
      final participants = _generateMockParticipants(16);
      
      // Use BracketGeneratorService to generate bracket
      final bracket = await BracketGeneratorService.generateBracket(
        tournamentId: widget.tournamentId,
        format: _selectedFormat,
        participants: participants,
        seedingMethod: _selectedSeeding,
      );
      
      setState(() {
        _generatedBracket = bracket;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Đã tạo bảng đấu ${_getFormatName(_selectedFormat)} thành công!'),
            backgroundColor: AppTheme.successLight,
          ),
        );
      }
    } catch (e) {
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

  List<TournamentParticipant> _generateMockParticipants(int count) {
    final ranks = ['E+', 'E', 'F+', 'F', 'G+', 'G', 'H+', 'H'];
    final names = ['Nguyễn Văn A', 'Trần Thị B', 'Lê Văn C', 'Phạm Thị D', 
                   'Hoàng Văn E', 'Vũ Thị F', 'Đặng Văn G', 'Bùi Thị H',
                   'Đỗ Văn I', 'Ngô Thị J', 'Dương Văn K', 'Mai Thị L',
                   'Vương Văn M', 'Đinh Thị N', 'Phan Văn O', 'Tôn Thị P'];
    
    return List.generate(count, (i) {
      return TournamentParticipant(
        id: 'player_${i + 1}',
        name: names[i % names.length],
        rank: ranks[i % ranks.length],
        elo: 2000 - (i * 50),
        seed: i + 1,
      );
    });
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
            Text('Đây sẽ là demo cho bảng đấu ${_selectedFormat} với seeding ${_selectedSeeding}'),
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
              Container(
                height: 300,
                child: ListView.builder(
                  itemCount: 16,
                  itemBuilder: (context, index) {
                    final participant = _generateMockParticipants(16)[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text('${index + 1}'),
                        backgroundColor: AppTheme.primaryLight,
                        foregroundColor: Colors.white,
                      ),
                      title: Text(participant.name),
                      subtitle: Text('Rank: ${participant.rank} • ELO: ${participant.elo}'),
                      trailing: Text('Seed ${participant.seed}'),
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
}