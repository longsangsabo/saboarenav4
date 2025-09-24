import 'package:flutter/material.dart';
import 'package:sabo_arena/services/user_service.dart';
import 'package:sabo_arena/models/club.dart';
import 'package:sabo_arena/services/club_service.dart';
import 'package:sabo_arena/core/constants/ranking_constants.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

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
  String _selectedRank = 'K'; // Default to first available rank
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _achievementsController = TextEditingController();
  final TextEditingController _commentsController = TextEditingController();
  
  // Image upload for tournament evidence
  final List<File> _evidenceImages = [];
  final ImagePicker _imagePicker = ImagePicker();
  bool _isUploadingImages = false;

  final List<String> _rankOptions = RankingConstants.RANK_ORDER;
  final Map<String, String> _rankDescriptions = {
    'K': 'Người mới - 1000-1099 ELO',
    'K+': 'Học việc - 1100-1199 ELO',
    'I': 'Thợ 3 - 1200-1299 ELO',
    'I+': 'Thợ 2 - 1300-1399 ELO',
    'H': 'Thợ 1 - 1400-1499 ELO',
    'H+': 'Thợ chính - 1500-1599 ELO',
    'G': 'Thợ giỏi - 1600-1699 ELO',
    'G+': 'Cao thủ - 1700-1799 ELO',
    'F': 'Chuyên gia - 1800-1899 ELO',
    'F+': 'Đại cao thủ - 1900-1999 ELO',
    'E': 'Huyền thoại - 2000-2099 ELO',
    'E+': 'Vô địch - 2100-9999 ELO',
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

  // Image picker methods for tournament evidence
  Future<void> _pickImages() async {
    try {
      final List<XFile> pickedFiles = await _imagePicker.pickMultiImage(
        imageQuality: 70,
      );
      
      if (pickedFiles.isNotEmpty) {
        setState(() {
          _evidenceImages.addAll(
            pickedFiles.map((xFile) => File(xFile.path)).toList()
          );
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi chọn ảnh: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _evidenceImages.removeAt(index);
    });
  }

  Future<void> _submitRankRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Upload evidence images first if any
      List<String> imageUrls = [];
      if (_evidenceImages.isNotEmpty) {
        setState(() => _isUploadingImages = true);
        
        for (File image in _evidenceImages) {
          try {
            final String fileName = 'rank_evidence_${DateTime.now().millisecondsSinceEpoch}_${path.basename(image.path)}';
            final result = await _userService.uploadImage(image, fileName);
            if (result['success'] == true && result['url'] != null) {
              imageUrls.add(result['url']);
            }
          } catch (e) {
            print('Error uploading image: $e');
          }
        }
        
        setState(() => _isUploadingImages = false);
      }

      // Combine all info into notes
      final notes = '''
Rank mong muốn: $_selectedRank
Kinh nghiệm: ${_experienceController.text}
Thành tích: ${_achievementsController.text}
Ghi chú: ${_commentsController.text}
${imageUrls.isNotEmpty ? '\nHình ảnh bằng chứng: ${imageUrls.length} ảnh đã tải lên' : ''}
'''.trim();

      final result = await _userService.requestRankRegistration(
        clubId: widget.clubId,
        notes: notes,
        evidenceUrls: imageUrls,
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

            SizedBox(height: 24),

            // Evidence Images Section
            Text(
              'Hình ảnh bằng chứng',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tải lên hình ảnh kết quả giải đấu trong 3 tháng gần đây để xác thực rank của bạn',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 12),
            
            // Upload Images Container
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                children: [
                  // Add Images Button
                  OutlinedButton.icon(
                    onPressed: _pickImages,
                    icon: Icon(Icons.add_photo_alternate_outlined),
                    label: Text('Thêm hình ảnh'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                  
                  if (_evidenceImages.isNotEmpty) ...[
                    SizedBox(height: 16),
                    Text(
                      '${_evidenceImages.length} hình ảnh đã chọn',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 12),
                    
                    // Image Grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: _evidenceImages.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  _evidenceImages[index],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => _removeImage(index),
                                child: Container(
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                  
                  if (_isUploadingImages) ...[
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text('Đang tải hình ảnh...'),
                      ],
                    ),
                  ],
                ],
              ),
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