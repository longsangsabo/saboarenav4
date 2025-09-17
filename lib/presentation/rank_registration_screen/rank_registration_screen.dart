import 'package:flutter/material.dart';
import 'package:sabo_arena/services/user_service.dart';
import 'package:sabo_arena/models/club.dart';
import 'package:sabo_arena/services/club_service.dart';

class RankRegistrationScreen extends StatefulWidget {
  final String clubId;

  const RankRegistrationScreen({
    super.key,
    required this.clubId,
  });

  @override
  State<RankRegistrationScreen> createState() => _RankRegistrationScreenState();
}

class _RankRegistrationScreenState extends State<RankRegistrationScreen> {
  final UserService _userService = UserService.instance;
  final ClubService _clubService = ClubService.instance;
  
  Club? _club;
  bool _isLoading = true;
  String? _currentRank;
  bool _hasRankRequest = false;
  
  final _formKey = GlobalKey<FormState>();
  String _selectedRank = 'C';
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _achievementsController = TextEditingController();
  final TextEditingController _commentsController = TextEditingController();

  final List<String> _rankOptions = ['C', 'B', 'A', 'AA', 'AAA'];
  final Map<String, String> _rankDescriptions = {
    'C': 'Người mới bắt đầu - 0-6 tháng kinh nghiệm',
    'B': 'Cơ bản - 6-18 tháng kinh nghiệm',
    'A': 'Trung cấp - 1.5-3 năm kinh nghiệm',
    'AA': 'Khá - 3-5 năm kinh nghiệm',
    'AAA': 'Giỏi - Trên 5 năm kinh nghiệm',
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _experienceController.dispose();
    _achievementsController.dispose();
    _commentsController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final club = await _clubService.getClubById(widget.clubId);
      
      // TODO: Load user's current rank and rank request status
      // For now using mock data
      final currentRank = null; // await _userService.getUserRankInClub(widget.clubId);
      final hasRequest = false; // await _userService.hasRankRequest(widget.clubId);
      
      setState(() {
        _club = club;
        _currentRank = currentRank;
        _hasRankRequest = hasRequest;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi tải thông tin: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _submitRankRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Combine all info into notes
      final notes = '''
Rank mong muốn: $_selectedRank
Kinh nghiệm: ${_experienceController.text}
Thành tích: ${_achievementsController.text}
Ghi chú: ${_commentsController.text}
'''.trim();

      final result = await _userService.requestRankRegistration(
        clubId: widget.clubId,
        notes: notes,
      );

      setState(() => _isLoading = false);

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Yêu cầu đăng ký rank đã được gửi thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Có lỗi xảy ra'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi gửi yêu cầu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Đăng ký Rank'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey[900],
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _hasRankRequest
              ? _buildExistingRequestView()
              : _currentRank != null
                  ? _buildHasRankView()
                  : _buildRegistrationForm(),
    );
  }

  Widget _buildExistingRequestView() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.hourglass_empty,
              size: 64,
              color: Colors.orange,
            ),
            SizedBox(height: 16),
            Text(
              'Yêu cầu đang chờ xử lý',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Bạn đã gửi yêu cầu đăng ký rank tại club này. Vui lòng chờ admin xét duyệt.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Đóng'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHasRankView() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _currentRank!,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Rank hiện tại của bạn',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Bạn đã có rank $_currentRank tại club ${_club?.name}.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Đóng'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegistrationForm() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Club info
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: _club?.coverImageUrl != null
                        ? NetworkImage(_club!.coverImageUrl!)
                        : null,
                    child: _club?.coverImageUrl == null
                        ? Icon(Icons.sports, size: 30)
                        : null,
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _club?.name ?? 'Club',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Đăng ký rank tại club này',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Rank selection
            Text(
              'Chọn rank mong muốn',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                children: _rankOptions.map((rank) {
                  return RadioListTile<String>(
                    title: Text(
                      'Rank $rank',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(_rankDescriptions[rank]!),
                    value: rank,
                    groupValue: _selectedRank,
                    onChanged: (value) {
                      setState(() => _selectedRank = value!);
                    },
                  );
                }).toList(),
              ),
            ),

            SizedBox(height: 24),

            // Experience
            Text(
              'Kinh nghiệm chơi billiards',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            TextFormField(
              controller: _experienceController,
              decoration: InputDecoration(
                hintText: 'Mô tả về kinh nghiệm chơi billiards của bạn...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng mô tả kinh nghiệm của bạn';
                }
                return null;
              },
            ),

            SizedBox(height: 16),

            // Achievements
            Text(
              'Thành tích đạt được (nếu có)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            TextFormField(
              controller: _achievementsController,
              decoration: InputDecoration(
                hintText: 'Các giải thưởng, thành tích nổi bật...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              maxLines: 2,
            ),

            SizedBox(height: 16),

            // Comments
            Text(
              'Ghi chú thêm',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            TextFormField(
              controller: _commentsController,
              decoration: InputDecoration(
                hintText: 'Thông tin bổ sung khác...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              maxLines: 2,
            ),

            SizedBox(height: 32),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitRankRequest,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        'Gửi yêu cầu đăng ký',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),

            SizedBox(height: 16),

            // Info note
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue[600],
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Yêu cầu đăng ký rank sẽ được admin của club xem xét và phê duyệt. Bạn sẽ nhận được thông báo khi có kết quả.',
                      style: TextStyle(
                        color: Colors.blue[800],
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}