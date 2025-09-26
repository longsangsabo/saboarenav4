// 🏆 SABO ARENA - Production Bracket Management Widget
// Widget quản lý bảng đấu tích hợp với database thật

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/app_export.dart';
import '../../../services/bracket_integration_service.dart';

class ProductionBracketManagementTab extends StatefulWidget {
  final String tournamentId;

  const ProductionBracketManagementTab({
    super.key,
    required this.tournamentId,
  });

  @override
  State<ProductionBracketManagementTab> createState() => _ProductionBracketManagementTabState();
}

class _ProductionBracketManagementTabState extends State<ProductionBracketManagementTab> {
  bool _isLoading = true;
  bool _isGenerating = false;
  String? _error;
  
  // Tournament data
  Map<String, dynamic>? _tournamentData;
  Map<String, dynamic>? _bracketData;
  List<Map<String, dynamic>> _participants = [];
  
  // UI state
  String _selectedFormat = 'single_elimination';
  String _selectedSeeding = 'elo_rating';

  @override
  void initState() {
    super.initState();
    _loadTournamentData();
  }

  Future<void> _loadTournamentData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final supabase = Supabase.instance.client;

      // Load tournament info
      final tournamentResponse = await supabase
          .from('tournaments')
          .select('*')
          .eq('id', widget.tournamentId)
          .single();
      
      _tournamentData = tournamentResponse;

      // Load existing bracket if available
      _bracketData = await BracketIntegrationService.loadTournamentBracket(widget.tournamentId);
      
      // Load participants with user profile data
      final participantsResponse = await supabase
          .from('tournament_participants')
          .select('''
            *,
            users:user_id (
              id,
              email,
              full_name,
              elo_rating,
              current_rank
            )
          ''')
          .eq('tournament_id', widget.tournamentId)
          .eq('status', 'registered');

      _participants = participantsResponse.map((p) => {
        ...p,
        'full_name': p['users']?['full_name'] ?? p['users']?['email'] ?? 'Unknown',
        'elo_rating': p['users']?['elo_rating'] ?? 1000,
        'current_rank': p['users']?['current_rank'],
      }).toList();
      
      // Set format from tournament data
      _selectedFormat = _tournamentData!['format'] ?? 'single_elimination';

      setState(() {
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _generateBracket() async {
    try {
      setState(() {
        _isGenerating = true;
      });

      final result = await BracketIntegrationService.createTournamentBracket(
        tournamentId: widget.tournamentId,
        format: _selectedFormat,
        seedingMethod: _selectedSeeding,
      );

      if (result['success'] == true) {
        // Reload bracket data
        await _loadTournamentData();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '✅ Đã tạo bảng đấu ${_getFormatName(_selectedFormat)}!\n'
                '📊 ${result['totalMatches']} trận đấu, ${result['totalRounds']} vòng'
              ),
              backgroundColor: AppTheme.successLight,
              duration: const Duration(seconds: 4),
            ),
          );
        }
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

  String _getFormatName(String format) {
    switch (format) {
      case 'single_elimination': return 'Single Elimination';
      case 'double_elimination': return 'Double Elimination';
      case 'round_robin': return 'Round Robin';
      case 'swiss_system': return 'Swiss System';
      default: return format;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48.sp, color: AppTheme.errorLight),
            SizedBox(height: 16.sp),
            Text('Lỗi tải dữ liệu: $_error'),
            SizedBox(height: 16.sp),
            ElevatedButton(
              onPressed: _loadTournamentData,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(12.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTournamentHeader(),
            SizedBox(height: 16.sp),
            _buildParticipantsSection(),
            SizedBox(height: 16.sp),
            _buildBracketSection(),
            SizedBox(height: 100.sp), // Bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildTournamentHeader() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(12.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.emoji_events, color: AppTheme.primaryLight),
                SizedBox(width: 8.sp),
                Expanded(
                  child: Text(
                    _tournamentData!['title'] ?? 'Tournament',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.sp),
            Text(
              'Format: ${_getFormatName(_selectedFormat)}',
              style: TextStyle(color: AppTheme.textSecondaryLight),
            ),
            Text(
              'Trạng thái: ${_tournamentData!['status']}',
              style: TextStyle(color: AppTheme.textSecondaryLight),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantsSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(12.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.people, color: AppTheme.primaryLight),
                SizedBox(width: 8.sp),
                Text(
                  'Người chơi (${_participants.length})',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.sp),
            if (_participants.isEmpty)
              Text(
                'Chưa có người đăng ký',
                style: TextStyle(color: AppTheme.textSecondaryLight),
              )
            else
              ..._participants.take(5).map((participant) => Padding(
                padding: EdgeInsets.symmetric(vertical: 2.sp),
                child: Row(
                  children: [
                    Text('• ${participant['full_name'] ?? 'Unknown'}'),
                    const Spacer(),
                    if (participant['elo_rating'] != null)
                      Text(
                        'ELO: ${participant['elo_rating']}',
                        style: TextStyle(
                          color: AppTheme.textSecondaryLight,
                          fontSize: 12.sp,
                        ),
                      ),
                  ],
                ),
              )),
            if (_participants.length > 5)
              Text(
                '... và ${_participants.length - 5} người khác',
                style: TextStyle(
                  color: AppTheme.textSecondaryLight,
                  fontSize: 12.sp,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBracketSection() {
    if (_bracketData != null) {
      return _buildExistingBracket();
    } else {
      return _buildBracketCreation();
    }
  }

  Widget _buildExistingBracket() {
    final bracketInfo = _bracketData!['bracketData'] as Map<String, dynamic>;
    final matches = _bracketData!['matches'] as List;

    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(12.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_tree, color: Colors.green),
                SizedBox(width: 8.sp),
                Text(
                  'Bảng đấu đã tạo',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.sp),
            Text('Format: ${_getFormatName(bracketInfo['format'])}'),
            Text('Tổng số trận: ${bracketInfo['totalMatches']}'),
            Text('Số vòng: ${bracketInfo['totalRounds']}'),
            Text('Tạo lúc: ${bracketInfo['generatedAt']}'),
            SizedBox(height: 12.sp),
            
            // Show some match results
            Text(
              'Trận đấu gần đây:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4.sp),
            ...matches.take(3).map((match) => Padding(
              padding: EdgeInsets.symmetric(vertical: 2.sp),
              child: Text(
                'Vòng ${match['round_number']}: ${match['player1']?['full_name'] ?? 'TBD'} vs ${match['player2']?['full_name'] ?? 'TBD'}',
                style: TextStyle(fontSize: 12.sp),
              ),
            )),
            
            SizedBox(height: 12.sp),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Navigate to bracket visualization
                  },
                  icon: Icon(Icons.visibility),
                  label: Text('Xem bảng đấu'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryLight,
                    foregroundColor: Colors.white,
                  ),
                ),
                SizedBox(width: 8.sp),
                OutlinedButton.icon(
                  onPressed: _showRegenerateBracketDialog,
                  icon: Icon(Icons.refresh),
                  label: Text('Tạo lại'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBracketCreation() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(12.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_fix_high, color: AppTheme.primaryLight),
                SizedBox(width: 8.sp),
                Text(
                  'Tạo bảng đấu',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.sp),
            
            // Format selection
            Text('Thể thức thi đấu:'),
            SizedBox(height: 4.sp),
            DropdownButtonFormField<String>(
              initialValue: _selectedFormat,
              onChanged: (value) {
                setState(() {
                  _selectedFormat = value!;
                });
              },
              items: const [
                DropdownMenuItem(value: 'single_elimination', child: Text('Single Elimination')),
                DropdownMenuItem(value: 'double_elimination', child: Text('Double Elimination')),
                DropdownMenuItem(value: 'round_robin', child: Text('Round Robin')),
                DropdownMenuItem(value: 'swiss_system', child: Text('Swiss System')),
              ],
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
            
            SizedBox(height: 12.sp),
            
            // Seeding method
            Text('Phương thức xếp hạt giống:'),
            SizedBox(height: 4.sp),
            DropdownButtonFormField<String>(
              initialValue: _selectedSeeding,
              onChanged: (value) {
                setState(() {
                  _selectedSeeding = value!;
                });
              },
              items: const [
                DropdownMenuItem(value: 'elo_rating', child: Text('Theo ELO')),
                DropdownMenuItem(value: 'ranking', child: Text('Theo Rank')),
                DropdownMenuItem(value: 'random', child: Text('Ngẫu nhiên')),
              ],
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
            
            SizedBox(height: 16.sp),
            
            // Generate button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _participants.isEmpty || _isGenerating ? null : _generateBracket,
                icon: _isGenerating 
                    ? SizedBox(
                        width: 16.sp,
                        height: 16.sp,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(Icons.create),
                label: Text(_isGenerating ? 'Đang tạo...' : 'Tạo bảng đấu'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryLight,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12.sp),
                ),
              ),
            ),
            
            if (_participants.isEmpty)
              Padding(
                padding: EdgeInsets.only(top: 8.sp),
                child: Text(
                  'Cần có ít nhất 2 người chơi để tạo bảng đấu',
                  style: TextStyle(
                    color: AppTheme.errorLight,
                    fontSize: 12.sp,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showRegenerateBracketDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tạo lại bảng đấu'),
        content: const Text(
          'Việc này sẽ xóa bảng đấu hiện tại và tạo lại từ đầu. '
          'Tất cả kết quả trận đấu sẽ bị mất. Bạn có chắc chắn?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement bracket regeneration
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorLight),
            child: const Text('Tạo lại'),
          ),
        ],
      ),
    );
  }
}