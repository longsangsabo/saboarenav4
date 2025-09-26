import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../services/production_bracket_service.dart';

/// Production bracket management with database integration
class ProductionBracketWidget extends StatefulWidget {
  final String tournamentId;
  
  const ProductionBracketWidget({
    super.key,
    required this.tournamentId,
  });

  @override
  State<ProductionBracketWidget> createState() => _ProductionBracketWidgetState();
}

class _ProductionBracketWidgetState extends State<ProductionBracketWidget> {
  final ProductionBracketService _bracketService = ProductionBracketService();
  
  bool _isLoading = false;
  Map<String, dynamic>? _existingBracket;
  List<Map<String, dynamic>> _participants = [];
  String _selectedFormat = 'single_elimination';
  
  @override
  void initState() {
    super.initState();
    _loadTournamentData();
  }

  Future<void> _loadTournamentData() async {
    setState(() => _isLoading = true);
    
    try {
      // Load existing bracket if any
      final bracketData = await _bracketService.loadTournamentBracket(widget.tournamentId);
      
      if (bracketData != null) {
        _existingBracket = bracketData;
        _participants = (bracketData['participants'] as List? ?? []).cast<Map<String, dynamic>>();
      } else {
        // Load participants for new bracket
        _participants = await _bracketService.getTournamentParticipants(widget.tournamentId);
      }
      
    } catch (e) {
      _showError('Lỗi tải dữ liệu: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createBracket() async {
    if (_participants.length < 4) {
      _showError('Cần ít nhất 4 người chơi để tạo bảng đấu');
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final result = await _bracketService.createTournamentBracket(
        tournamentId: widget.tournamentId,
        format: _selectedFormat,
      );

      if (result?['success'] == true) {
        _showSuccess(result!['message']);
        await _loadTournamentData(); // Reload to show created bracket
      } else {
        _showError(result?['message'] ?? 'Lỗi không xác định');
      }
      
    } catch (e) {
      _showError('Lỗi tạo bảng đấu: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Card(
          elevation: 2,
          child: Padding(
            padding: EdgeInsets.all(12.sp),
            child: Row(
              children: [
                Icon(Icons.storage, color: Colors.blue),
                SizedBox(width: 8.sp),
                Text(
                  'Production Mode - Database Integration',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
                Spacer(),
                if (_isLoading)
                  SizedBox(
                    width: 16.sp,
                    height: 16.sp,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ),
        ),
        
        SizedBox(height: 12.sp),

        // Participants Info
        Card(
          child: Padding(
            padding: EdgeInsets.all(12.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.people, color: Colors.blue),
                    SizedBox(width: 8.sp),
                    Text(
                      'Người chơi đã đăng ký',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 4.sp),
                      decoration: BoxDecoration(
                        color: _participants.length >= 4 ? Colors.green : Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_participants.length} người',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                
                if (_participants.isNotEmpty) ...[
                  SizedBox(height: 8.sp),
                  SizedBox(
                    height: 60.sp,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _participants.length,
                      itemBuilder: (context, index) {
                        final participant = _participants[index];
                        final profile = participant['user_profiles'];
                        
                        return Container(
                          width: 50.sp,
                          margin: EdgeInsets.only(right: 8.sp),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 20.sp,
                                backgroundImage: profile['avatar_url'] != null
                                    ? NetworkImage(profile['avatar_url'])
                                    : null,
                                child: profile['avatar_url'] == null
                                    ? Icon(Icons.person)
                                    : null,
                              ),
                              SizedBox(height: 4.sp),
                              Text(
                                profile['full_name'] ?? 'N/A',
                                style: TextStyle(fontSize: 8.sp),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        SizedBox(height: 12.sp),

        // Existing Bracket or Create New
        if (_existingBracket?['hasExistingBracket'] == true) ...[
          // Show existing bracket
          Card(
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
                        'Bảng đấu đã tồn tại',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.sp),
                  Text(
                    'Tournament này đã có bảng đấu. Bạn có thể xem kết quả và cập nhật tỷ số.',
                    style: TextStyle(fontSize: 11.sp),
                  ),
                  SizedBox(height: 8.sp),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Show bracket management interface
                      _showSuccess('Tính năng quản lý bảng đấu đang phát triển');
                    },
                    icon: Icon(Icons.visibility),
                    label: Text('Xem bảng đấu'),
                  ),
                ],
              ),
            ),
          ),
        ] else ...[
          // Create new bracket
          Card(
            child: Padding(
              padding: EdgeInsets.all(12.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.add_circle, color: Colors.blue),
                      SizedBox(width: 8.sp),
                      Text(
                        'Tạo bảng đấu mới',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 12.sp),
                  
                  // Format selection
                  Text(
                    'Chọn thể thức thi đấu:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8.sp),
                  
                  DropdownButtonFormField<String>(
                    initialValue: _selectedFormat,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 8.sp),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'single_elimination',
                        child: Text('🏆 Single Elimination'),
                      ),
                      DropdownMenuItem(
                        value: 'double_elimination',
                        child: Text('🔄 Double Elimination'),
                      ),
                      DropdownMenuItem(
                        value: 'round_robin',
                        child: Text('🔄 Round Robin'),
                      ),
                      DropdownMenuItem(
                        value: 'swiss_system',
                        child: Text('🇨🇭 Swiss System'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedFormat = value);
                      }
                    },
                  ),
                  
                  SizedBox(height: 12.sp),
                  
                  // Create button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _participants.length >= 4 && !_isLoading
                          ? _createBracket
                          : null,
                      icon: _isLoading
                          ? SizedBox(
                              width: 16.sp,
                              height: 16.sp,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(Icons.create),
                      label: Text(_isLoading ? 'Đang tạo...' : 'Tạo bảng đấu'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.sp),
                      ),
                    ),
                  ),
                  
                  if (_participants.length < 4)
                    Padding(
                      padding: EdgeInsets.only(top: 8.sp),
                      child: Text(
                        '⚠️ Cần ít nhất 4 người chơi để tạo bảng đấu',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 10.sp,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
        
        SizedBox(height: 12.sp),
        
        // Tournament Stats (if bracket exists)
        if (_existingBracket?['hasExistingBracket'] == true)
          FutureBuilder<Map<String, dynamic>>(
            future: _bracketService.getTournamentStats(widget.tournamentId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return SizedBox.shrink();
              
              final stats = snapshot.data!;
              return Card(
                child: Padding(
                  padding: EdgeInsets.all(12.sp),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.analytics, color: Colors.blue),
                          SizedBox(width: 8.sp),
                          Text(
                            'Thống kê giải đấu',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.sp),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatItem(
                            label: 'Tổng trận',
                            value: stats['total_matches'].toString(),
                            color: Colors.blue,
                          ),
                          _StatItem(
                            label: 'Hoàn thành',
                            value: stats['completed_matches'].toString(),
                            color: Colors.green,
                          ),
                          _StatItem(
                            label: 'Còn lại',
                            value: stats['pending_matches'].toString(),
                            color: Colors.orange,
                          ),
                          _StatItem(
                            label: 'Tiến độ',
                            value: '${stats['completion_percentage']}%',
                            color: Colors.blue,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 9.sp,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}