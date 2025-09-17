import 'package:flutter/material.dart';
// import 'package:sabo_arena/core/app_export.dart';


class ReviewStep extends StatefulWidget {
  final Map<String, dynamic> data;
  final Function(Map<String, dynamic>) onDataChanged;
  final VoidCallback onPublish;

  const ReviewStep({
    super.key,
    required this.data,
    required this.onDataChanged,
    required this.onPublish,
  });

  @override
  _ReviewStepState createState() => _ReviewStepState();
}

class _ReviewStepState extends State<ReviewStep>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  bool _isPublishing = false;
  String _publishOption = 'public'; // public, private, draft
  bool _notifyMembers = true;
  bool _allowEarlyRegistration = false;
  String _additionalNotes = '';

  final Map<String, String> _publishOptions = {
    'public': 'Công khai',
    'private': 'Riêng tư',
    'draft': 'Bản nháp',
  };

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _initializeData();
    _animationController.forward();
  }

  void _initializeData() {
    _publishOption = widget.data['publishOption'] ?? 'public';
    _notifyMembers = widget.data['notifyMembers'] ?? true;
    _allowEarlyRegistration = widget.data['allowEarlyRegistration'] ?? false;
    _additionalNotes = widget.data['additionalNotes'] ?? '';
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTournamentSummary(),
                
                SizedBox(height: 24),
                _buildSectionTitle("Thông tin cơ bản", Icons.info_outline),
                SizedBox(height: 16),
                _buildBasicInfoSummary(),
                
                SizedBox(height: 24),
                _buildSectionTitle("Lịch trình", Icons.schedule_outlined),
                SizedBox(height: 16),
                _buildScheduleSummary(),
                
                SizedBox(height: 24),
                _buildSectionTitle("Yêu cầu tham gia", Icons.rule_outlined),
                SizedBox(height: 16),
                _buildRequirementsSummary(),
                
                SizedBox(height: 24),
                _buildSectionTitle("Giải thưởng", Icons.emoji_events_outlined),
                SizedBox(height: 16),
                _buildPrizesSummary(),
                
                SizedBox(height: 24),
                _buildSectionTitle("Tùy chọn xuất bản", Icons.publish_outlined),
                SizedBox(height: 16),
                _buildPublishOptions(),
                
                SizedBox(height: 32),
                _buildPublishButton(),
                
                SizedBox(height: 100), // Space for navigation buttons
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue[50] ?? Colors.blue,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.blue[600] ?? Colors.blue,
            size: 20,
          ),
        ),
        SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[900] ?? Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildTournamentSummary() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[600] ?? Colors.green, Colors.green[800] ?? Colors.green],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green[600] ?? Colors.green.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.emoji_events,
                color: Colors.white,
                size: 32,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Giải đấu sẵn sàng!",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    Text(
                      widget.data['tournamentName'] ?? 'Tên giải đấu',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16),
          
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    "Người chơi",
                    "${widget.data['maxParticipants'] ?? 16}",
                    Icons.people_outline,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    "Phí tham gia",
                    "${((widget.data['entryFee'] ?? 0) / 1000).toStringAsFixed(0)}K",
                    Icons.attach_money,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    "Giải thưởng",
                    "${((widget.data['totalPrizePool'] ?? 0) / 1000).toStringAsFixed(0)}K",
                    Icons.star_outline,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.8), size: 20),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoSummary() {
    return _buildSummaryCard([
      _buildInfoRow("Tên giải đấu", widget.data['tournamentName'] ?? 'Chưa đặt tên'),
      _buildInfoRow("Loại bi", _getGameTypeLabel(widget.data['gameType'] ?? '8-ball')),
      _buildInfoRow("Thể thức", _getTournamentTypeLabel(widget.data['tournamentType'] ?? 'single-elimination')),
      _buildInfoRow("Số người", "${widget.data['maxParticipants'] ?? 16} người"),
      _buildInfoRow("Phí tham gia", "${((widget.data['entryFee'] ?? 0) / 1000).toStringAsFixed(0)}K VNĐ"),
    ]);
  }

  Widget _buildScheduleSummary() {
    final registrationStart = widget.data['registrationStartDate'] as DateTime?;
    final registrationEnd = widget.data['registrationEndDate'] as DateTime?;
    final tournamentStart = widget.data['tournamentStartDate'] as DateTime?;
    final tournamentEnd = widget.data['tournamentEndDate'] as DateTime?;

    return _buildSummaryCard([
      _buildInfoRow(
        "Đăng ký",
        "${_formatDate(registrationStart)} - ${_formatDate(registrationEnd)}",
      ),
      _buildInfoRow(
        "Thi đấu",
        "${_formatDate(tournamentStart)} - ${_formatDate(tournamentEnd)}",
      ),
      _buildInfoRow("Lịch trình", _getSchedulingLabel(widget.data['matchScheduling'] ?? 'flexible')),
      _buildInfoRow("Thời gian/trận", "${widget.data['matchDuration'] ?? 60} phút"),
      _buildInfoRow("Trận/ngày", "${widget.data['dailyMatches'] ?? 3} trận"),
    ]);
  }

  Widget _buildRequirementsSummary() {
    List<Widget> requirements = [];

    if (widget.data['hasRankRequirement'] == true) {
      final minRank = widget.data['minRank'] ?? 'beginner';
      final maxRank = widget.data['maxRank'] ?? 'pro';
      requirements.add(_buildInfoRow("Xếp hạng", "$minRank - $maxRank"));
    }

    if (widget.data['hasAgeRequirement'] == true) {
      final minAge = widget.data['minAge'] ?? 16;
      final maxAge = widget.data['maxAge'] ?? 99;
      requirements.add(_buildInfoRow("Độ tuổi", "$minAge - $maxAge tuổi"));
    }

    if (widget.data['clubMembersOnly'] == true) {
      requirements.add(_buildInfoRow("Thành viên", "Chỉ thành viên club"));
    }

    if (widget.data['requireVerification'] == true) {
      requirements.add(_buildInfoRow("Xác minh", "Bắt buộc xác minh tài khoản"));
    }

    if (widget.data['requireDeposit'] == true) {
      final deposit = widget.data['depositAmount'] ?? 100000;
      requirements.add(_buildInfoRow("Đặt cọc", "${(deposit / 1000).toStringAsFixed(0)}K VNĐ"));
    }

    if (requirements.isEmpty) {
      requirements.add(_buildInfoRow("Yêu cầu", "Không có yêu cầu đặc biệt"));
    }

    return _buildSummaryCard(requirements);
  }

  Widget _buildPrizesSummary() {
    final totalPrize = widget.data['totalPrizePool'] ?? 0.0;
    final prizeSource = widget.data['prizeSource'] ?? 'entry_fees';
    final distribution = widget.data['distributionTemplate'] ?? 'winner_takes_all';

    List<Widget> prizeInfo = [
      _buildInfoRow("Tổng giải thưởng", "${(totalPrize / 1000).toStringAsFixed(0)}K VNĐ"),
      _buildInfoRow("Nguồn", _getPrizeSourceLabel(prizeSource)),
      _buildInfoRow("Phân chia", _getDistributionLabel(distribution)),
    ];

    if (widget.data['organizerFee'] != null && widget.data['organizerFee'] > 0) {
      prizeInfo.add(_buildInfoRow("Phí tổ chức", "${widget.data['organizerFee'].toInt()}%"));
    }

    final additionalPrizes = widget.data['additionalPrizes'] as List<dynamic>? ?? [];
    if (additionalPrizes.isNotEmpty) {
      prizeInfo.add(_buildInfoRow("Giải phụ", "${additionalPrizes.length} giải thưởng"));
    }

    final sponsors = widget.data['sponsors'] as List<dynamic>? ?? [];
    if (sponsors.isNotEmpty) {
      prizeInfo.add(_buildInfoRow("Nhà tài trợ", "${sponsors.length} tài trợ"));
    }

    return _buildSummaryCard(prizeInfo);
  }

  Widget _buildSummaryCard(List<Widget> children) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[900] ?? Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600] ?? Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey[900] ?? Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPublishOptions() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[900] ?? Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Chế độ xuất bản:",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700] ?? Colors.grey,
            ),
          ),
          SizedBox(height: 16),
          
          ...(_publishOptions.entries.map((entry) {
            return _buildPublishOption(entry.key, entry.value);
          })),
          
          SizedBox(height: 20),
          
          _buildToggleOption(
            title: "Thông báo cho thành viên",
            subtitle: "Gửi thông báo đến tất cả thành viên club",
            value: _notifyMembers,
            onChanged: (value) {
              setState(() {
                _notifyMembers = value;
              });
              _updateData();
            },
          ),
          
          SizedBox(height: 16),
          
          _buildToggleOption(
            title: "Cho phép đăng ký sớm",
            subtitle: "Thành viên có thể đăng ký trước ngày mở đăng ký",
            value: _allowEarlyRegistration,
            onChanged: (value) {
              setState(() {
                _allowEarlyRegistration = value;
              });
              _updateData();
            },
          ),
          
          SizedBox(height: 20),
          
          TextField(
            decoration: InputDecoration(
              labelText: "Ghi chú thêm",
              hintText: "Thông tin bổ sung cho người tham gia...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              alignLabelWithHint: true,
            ),
            maxLines: 3,
            controller: TextEditingController(text: _additionalNotes),
            onChanged: (value) {
              _additionalNotes = value;
              _updateData();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPublishOption(String value, String label) {
    final isSelected = _publishOption == value;
    
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          setState(() {
            _publishOption = value;
          });
          _updateData();
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.green[50] ?? Colors.green : Colors.grey[50] ?? Colors.grey,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? Colors.green[600] ?? Colors.green : Colors.grey[200] ?? Colors.grey,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.green[600] ?? Colors.green : Colors.grey[300] ?? Colors.grey,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 12,
                ),
              ),
              
              SizedBox(width: 12),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.green[800] ?? Colors.green : Colors.grey[700] ?? Colors.grey,
                      ),
                    ),
                    Text(
                      _getPublishOptionDescription(value),
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected ? Colors.green[600] ?? Colors.green : Colors.grey[500] ?? Colors.grey,
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

  Widget _buildToggleOption({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[900] ?? Colors.black,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600] ?? Colors.grey,
                ),
              ),
            ],
          ),
        ),
        
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: Colors.blue[600] ?? Colors.blue,
        ),
      ],
    );
  }

  Widget _buildPublishButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isPublishing ? null : _handlePublish,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[600] ?? Colors.green,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 8,
        ),
        child: _isPublishing
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    "Đang xuất bản...",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.publish, size: 24),
                  SizedBox(width: 12),
                  Text(
                    _getPublishButtonText(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "Chưa đặt";
    return "${date.day}/${date.month}/${date.year}";
  }

  String _getGameTypeLabel(String gameType) {
    switch (gameType) {
      case '8-ball': return '8-Ball Pool';
      case '9-ball': return '9-Ball Pool';
      case '10-ball': return '10-Ball Pool';
      default: return gameType;
    }
  }

  String _getTournamentTypeLabel(String tournamentType) {
    switch (tournamentType) {
      case 'single-elimination': return 'Loại trực tiếp';
      case 'double-elimination': return 'Loại kép';
      case 'round-robin': return 'Vòng tròn';
      default: return tournamentType;
    }
  }

  String _getSchedulingLabel(String scheduling) {
    switch (scheduling) {
      case 'flexible': return 'Linh hoạt';
      case 'fixed': return 'Cố định';
      default: return scheduling;
    }
  }

  String _getPrizeSourceLabel(String source) {
    switch (source) {
      case 'entry_fees': return 'Từ phí tham gia';
      case 'sponsor': return 'Từ nhà tài trợ';
      case 'hybrid': return 'Kết hợp cả hai';
      default: return source;
    }
  }

  String _getDistributionLabel(String distribution) {
    switch (distribution) {
      case 'winner_takes_all': return 'Người thắng nhận tất cả';
      case 'top_3': return 'Top 3 (50%-30%-20%)';
      case 'top_5': return 'Top 5';
      case 'equal_split': return 'Chia đều Top 8';
      case 'custom': return 'Tùy chỉnh';
      default: return distribution;
    }
  }

  String _getPublishOptionDescription(String option) {
    switch (option) {
      case 'public': return 'Mọi người đều có thể xem và tham gia';
      case 'private': return 'Chỉ những người được mời mới tham gia được';
      case 'draft': return 'Lưu bản nháp, chưa công bố';
      default: return '';
    }
  }

  String _getPublishButtonText() {
    switch (_publishOption) {
      case 'public': return 'Xuất bản giải đấu';
      case 'private': return 'Tạo giải đấu riêng tư';
      case 'draft': return 'Lưu bản nháp';
      default: return 'Xuất bản';
    }
  }

  Future<void> _handlePublish() async {
    setState(() {
      _isPublishing = true;
    });

    try {
      // Simulate publishing process
      await Future.delayed(Duration(seconds: 2));
      
      // Call the publish callback
      widget.onPublish();
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text(_getSuccessMessage()),
              ],
            ),
            backgroundColor: Colors.green[600] ?? Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (error) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Text("Có lỗi xảy ra khi xuất bản giải đấu"),
              ],
            ),
            backgroundColor: Colors.red[600] ?? Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPublishing = false;
        });
      }
    }
  }

  String _getSuccessMessage() {
    switch (_publishOption) {
      case 'public': return 'Giải đấu đã được xuất bản thành công!';
      case 'private': return 'Giải đấu riêng tư đã được tạo!';
      case 'draft': return 'Bản nháp đã được lưu!';
      default: return 'Thành công!';
    }
  }

  void _updateData() {
    widget.onDataChanged({
      'publishOption': _publishOption,
      'notifyMembers': _notifyMembers,
      'allowEarlyRegistration': _allowEarlyRegistration,
      'additionalNotes': _additionalNotes,
    });
  }
}
