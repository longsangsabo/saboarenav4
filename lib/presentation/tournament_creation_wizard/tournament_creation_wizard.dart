import 'package:flutter/material.dart';
import 'package:sabo_arena/theme/theme_extensions.dart';
import 'package:sabo_arena/utils/size_extensions.dart';
import '../../services/tournament_service.dart';
import '../../core/constants/ranking_constants.dart';

class TournamentCreationWizard extends StatefulWidget {
  final String? clubId;

  const TournamentCreationWizard({
    super.key,
    this.clubId,
  });

  @override
  _TournamentCreationWizardState createState() => _TournamentCreationWizardState();
}

class _TournamentCreationWizardState extends State<TournamentCreationWizard>
    with TickerProviderStateMixin {
  
  late PageController _pageController;
  int _currentStep = 0;
  bool _isCreating = false;
  
  // Form keys for validation
  final _basicInfoFormKey = GlobalKey<FormState>();
  final _scheduleFormKey = GlobalKey<FormState>();
  final _financialFormKey = GlobalKey<FormState>();
  final _reviewFormKey = GlobalKey<FormState>();
  
  // Text controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _venueController = TextEditingController();
  final _entryFeeController = TextEditingController();
  final _prizePoolController = TextEditingController();
  final _rulesController = TextEditingController();
  final _contactInfoController = TextEditingController();
  
  // Services
  final _tournamentService = TournamentService.instance;
  
  // Bracket creation variables
  String _selectedBracketFormat = 'single_elimination';
  String _selectedSeedingMethod = 'elo_rating';
  bool _createBracketNow = false;
  String? _createdTournamentId;
  
  // Validation errors
  final Map<String, String> _errors = {};
  
  // Tournament data with comprehensive fields
  final Map<String, dynamic> _tournamentData = {
    // Basic Info
    'name': '',
    'description': '',
    'gameType': '8-ball', // 8-ball, 9-ball, 10-ball, straight-pool
    'format': 'single_elimination', // single_elimination, double_elimination, round_robin, swiss
    'maxParticipants': 16, // 4,6,8,12,16,24,32,64
    'hasThirdPlaceMatch': true,
    
    // Schedule & Venue  
    'registrationStartDate': null,
    'registrationEndDate': null,
    'tournamentStartDate': null,
    'tournamentEndDate': null,
    'venue': '', // Auto-fill from club or custom
    
    // Financial & Requirements
    'entryFee': 0.0,
    'prizePool': 0.0,
    'minRank': '', // K, J, I, H, G, F, E, D, C, B, A, E+
    'maxRank': '', // Empty = no limit
    
    // Additional Info
    'rules': '',
    'contactInfo': '', // Auto-fill from club
    'bannerUrl': '',
    
    // System fields (auto-filled)
    'clubId': '',
    'creatorId': '',
    'status': 'registration_open',
    'currentParticipants': 0,
    'isClubVerified': false,
  };

  final List<String> _stepTitles = [
    'Thông tin cơ bản',
    'Thời gian & Địa điểm',
    'Tài chính & Điều kiện', 
    'Quy định & Xem lại',
    'Tạo bảng đấu',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _initializeTournamentData();
  }

  void _initializeTournamentData() {
    // Auto-fill club information
    if (widget.clubId != null) {
      _tournamentData['clubId'] = widget.clubId!;
      // TODO: Load club data and auto-fill venue, contact info
      _loadClubData();
    }
    
    // Set default dates (registration starts tomorrow, tournament in 7 days)
    final now = DateTime.now();
    _tournamentData['registrationStartDate'] = now.add(Duration(days: 1));
    _tournamentData['registrationEndDate'] = now.add(Duration(days: 6));
    _tournamentData['tournamentStartDate'] = now.add(Duration(days: 7));
    _tournamentData['tournamentEndDate'] = now.add(Duration(days: 8));
  }

  void _loadClubData() async {
    // TODO: Load club data from service
    // _tournamentData['venue'] = club.address;
    // _tournamentData['contactInfo'] = club.phone;
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _venueController.dispose();
    _entryFeeController.dispose();
    _prizePoolController.dispose();
    _rulesController.dispose();
    _contactInfoController.dispose();
    super.dispose();
  }

  void _nextStep() {
    // Validate current step before proceeding
    if (!_validateCurrentStep()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng điền đầy đủ thông tin bắt buộc'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_currentStep < _stepTitles.length - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onDataChanged(Map<String, dynamic> data) {
    setState(() {
      _tournamentData.addAll(data);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Tạo giải đấu mới'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Step indicator
          Container(
            padding: EdgeInsets.all(20.h),
            child: Row(
              children: List.generate(_stepTitles.length, (index) {
                final isActive = index == _currentStep;
                final isCompleted = index < _currentStep;
                
                return Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 4.h,
                          decoration: BoxDecoration(
                            color: isCompleted || isActive
                                ? appTheme.green600
                                : appTheme.gray300,
                            borderRadius: BorderRadius.circular(2.h),
                          ),
                        ),
                      ),
                      if (index < _stepTitles.length - 1)
                        SizedBox(width: 8.w),
                    ],
                  ),
                );
              }),
            ),
          ),
          
          // Step title
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Text(
              _stepTitles[_currentStep],
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: appTheme.gray900,
              ),
            ),
          ),
          
          SizedBox(height: 20.h),
          
          // Step content
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentStep = index;
                });
              },
              children: [
                // Step 1: Basic Info 
                _buildBasicInfoStep(context),
                
                // Step 2: Schedule & Venue (Updated)
                _buildScheduleVenueStep(context),
                
                // Step 3: Financial & Requirements (Updated)  
                _buildFinancialRequirementsStep(context),
                
                // Step 4: Rules & Review (Updated)
                _buildRulesReviewStep(context),
                
                // Step 5: Bracket Creation (New)
                _buildBracketCreationStep(context),
              ],
            ),
          ),
          
          // Navigation buttons
          Container(
            padding: EdgeInsets.all(20.h),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousStep,
                      child: Text('Quay lại'),
                    ),
                  ),
                
                if (_currentStep > 0)
                  SizedBox(width: 16.w),
                
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isCreating 
                        ? null 
                        : (_currentStep < _stepTitles.length - 1
                            ? _nextStep
                            : _createTournament),
                    child: _isCreating
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 16.w,
                                height: 16.h,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text('Đang tạo...'),
                            ],
                          )
                        : Text(_currentStep < _stepTitles.length - 1
                            ? 'Tiếp theo'
                            : 'Tạo giải đấu'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoStep(BuildContext context) {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.h),
      child: Form(
        key: _basicInfoFormKey,
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thông tin cơ bản về giải đấu',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20.h),
          
          // Tournament name (3-100 chars, required)
          TextFormField(
            controller: _nameController,
            maxLength: 100,
            decoration: InputDecoration(
              labelText: 'Tên giải đấu *',
              hintText: 'Ví dụ: SABO Championship 2025',
              border: OutlineInputBorder(),
              helperText: 'Tối thiểu 3 ký tự, tối đa 100 ký tự',
            ),
            validator: (value) {
              if (value == null || value.length < 3) return 'Tên giải đấu phải có ít nhất 3 ký tự';
              return null;
            },
            onChanged: (value) {
              _onDataChanged({'name': value});
            },
          ),
          
          SizedBox(height: 16.h),
          
          // Description (10-1000 chars, optional)
          TextFormField(
            controller: _descriptionController,
            maxLines: 3,
            maxLength: 1000,
            decoration: InputDecoration(
              labelText: 'Mô tả giải đấu',
              hintText: 'Mô tả mục tiêu và đặc điểm của giải đấu...',
              border: OutlineInputBorder(),
              helperText: 'Tùy chọn - từ 10 đến 1000 ký tự',
            ),
            onChanged: (value) {
              _onDataChanged({'description': value});
            },
          ),
          
          SizedBox(height: 16.h),
          
          // Game Type
          DropdownButtonFormField<String>(
            initialValue: _tournamentData['gameType'],
            decoration: InputDecoration(
              labelText: 'Môn thi đấu *',
              border: OutlineInputBorder(),
            ),
            items: [
              DropdownMenuItem(value: '8-ball', child: Text('8-Ball')),
              DropdownMenuItem(value: '9-ball', child: Text('9-Ball')),
              DropdownMenuItem(value: '10-ball', child: Text('10-Ball')),
              DropdownMenuItem(value: 'straight-pool', child: Text('Straight Pool')),
            ],
            onChanged: (value) {
              _onDataChanged({'gameType': value});
            },
          ),
          
          SizedBox(height: 16.h),
          
          // Tournament Format
          DropdownButtonFormField<String>(
            initialValue: _tournamentData['format'],
            decoration: InputDecoration(
              labelText: 'Hình thức thi đấu *',
              border: OutlineInputBorder(),
            ),
            items: [
              DropdownMenuItem(value: 'single_elimination', child: Text('Single Elimination (Loại trực tiếp)')),
              DropdownMenuItem(value: 'double_elimination', child: Text('Double Elimination (Loại kép)')),
              DropdownMenuItem(value: 'round_robin', child: Text('Round Robin (Vòng tròn)')),
              DropdownMenuItem(value: 'swiss', child: Text('Swiss System')),
            ],
            onChanged: (value) {
              _onDataChanged({'format': value});
            },
          ),
          
          SizedBox(height: 16.h),
          
          // Max Participants
          DropdownButtonFormField<int>(
            initialValue: _tournamentData['maxParticipants'],
            decoration: InputDecoration(
              labelText: 'Số lượng tham gia *',
              border: OutlineInputBorder(),
            ),
            items: [4, 6, 8, 12, 16, 24, 32, 64].map((count) => 
              DropdownMenuItem(
                value: count,
                child: Text('$count người'),
              ),
            ).toList(),
            onChanged: (value) {
              _onDataChanged({'maxParticipants': value ?? 16});
            },
          ),
          
          SizedBox(height: 16.h),
          
          // Third Place Match Toggle
          Row(
            children: [
              Checkbox(
                value: _tournamentData['hasThirdPlaceMatch'] ?? true,
                onChanged: (value) {
                  _onDataChanged({'hasThirdPlaceMatch': value ?? true});
                },
              ),
              Text('Có trận tranh hạng 3'),
            ],
          ),
        ],
      ),
    ));
  }

  Widget _buildScheduleVenueStep(BuildContext context) {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.h),
      child: Form(
        key: _scheduleFormKey,
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thời gian & Địa điểm tổ chức',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20.h),
          
          // Registration Start Date
          _buildDateTimePicker(
            label: 'Thời gian mở đăng ký *',
            value: _tournamentData['registrationStartDate'],
            onChanged: (date) => _onDataChanged({'registrationStartDate': date}),
          ),
          
          SizedBox(height: 16.h),
          
          // Registration End Date
          _buildDateTimePicker(
            label: 'Thời gian đóng đăng ký *',
            value: _tournamentData['registrationEndDate'],
            onChanged: (date) => _onDataChanged({'registrationEndDate': date}),
          ),
          
          SizedBox(height: 16.h),
          
          // Tournament Start Date
          _buildDateTimePicker(
            label: 'Thời gian bắt đầu giải *',
            value: _tournamentData['tournamentStartDate'],
            onChanged: (date) => _onDataChanged({'tournamentStartDate': date}),
          ),
          
          SizedBox(height: 16.h),
          
          // Tournament End Date
          _buildDateTimePicker(
            label: 'Thời gian kết thúc giải *',
            value: _tournamentData['tournamentEndDate'],
            onChanged: (date) => _onDataChanged({'tournamentEndDate': date}),
          ),
          
          SizedBox(height: 16.h),
          
          // Venue Address
          TextFormField(
            controller: _venueController,
            maxLength: 200,
            decoration: InputDecoration(
              labelText: 'Địa chỉ tổ chức *',
              hintText: 'SABO Arena Central, 123 Nguyễn Huệ, Q1, TP.HCM',
              border: OutlineInputBorder(),
              helperText: 'Tối thiểu 5 ký tự',
            ),
            validator: (value) {
              if (value == null || value.length < 5) return 'Địa chỉ phải có ít nhất 5 ký tự';
              return null;
            },
            onChanged: (value) {
              _onDataChanged({'venue': value});
            },
          ),
        ],
      ),
    ));
  }

  Widget _buildFinancialRequirementsStep(BuildContext context) {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.h),
      child: Form(
        key: _financialFormKey,
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thông tin tài chính & Điều kiện tham gia',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20.h),
          
          // Entry Fee
          TextFormField(
            controller: _entryFeeController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Phí đăng ký (VNĐ) *',
              hintText: '100,000',
              border: OutlineInputBorder(),
              prefixText: '₫ ',
            ),
            onChanged: (value) {
              _onDataChanged({'entryFee': double.tryParse(value) ?? 0.0});
            },
          ),
          
          SizedBox(height: 16.h),
          
          // Prize Pool
          TextFormField(
            controller: _prizePoolController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Tổng giải thưởng (VNĐ) *',
              hintText: '1,000,000',
              border: OutlineInputBorder(),
              prefixText: '₫ ',
              helperText: 'Có thể để 0 nếu chưa xác định',
            ),
            onChanged: (value) {
              _onDataChanged({'prizePool': double.tryParse(value) ?? 0.0});
            },
          ),
          
          SizedBox(height: 20.h),
          
          Text(
            'Điều kiện tham gia',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          SizedBox(height: 16.h),
          
          // Min Rank
          DropdownButtonFormField<String>(
            initialValue: _tournamentData['minRank']?.isEmpty == true ? null : _tournamentData['minRank'],
            decoration: InputDecoration(
              labelText: 'Hạng tối thiểu',
              border: OutlineInputBorder(),
              helperText: 'Để trống = tất cả hạng',
            ),
            items: _getRankOptions(),
            onChanged: (value) {
              _onDataChanged({'minRank': value ?? ''});
            },
          ),
          
          SizedBox(height: 16.h),
          
          // Max Rank
          DropdownButtonFormField<String>(
            initialValue: _tournamentData['maxRank']?.isEmpty == true ? null : _tournamentData['maxRank'],
            decoration: InputDecoration(
              labelText: 'Hạng tối đa',
              border: OutlineInputBorder(),
              helperText: 'Để trống = không giới hạn',
            ),
            items: _getRankOptions(),
            onChanged: (value) {
              _onDataChanged({'maxRank': value ?? ''});
            },
          ),
        ],
      ),
    ));
  }

  Widget _buildRulesReviewStep(BuildContext context) {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.h),
      child: Form(
        key: _reviewFormKey,
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quy định giải đấu & Xem lại thông tin',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20.h),
          
          // Tournament Rules
          TextFormField(
            controller: _rulesController,
            maxLines: 5,
            maxLength: 2000,
            decoration: InputDecoration(
              labelText: 'Luật lệ giải đấu',
              hintText: 'Quy định cụ thể, penalty, hướng dẫn thi đấu...',
              border: OutlineInputBorder(),
              helperText: 'Tùy chọn - tối đa 2000 ký tự',
            ),
            onChanged: (value) {
              _onDataChanged({'rules': value});
            },
          ),
          
          SizedBox(height: 16.h),
          
          // Contact Info
          TextFormField(
            controller: _contactInfoController,
            maxLength: 200,
            decoration: InputDecoration(
              labelText: 'Thông tin liên hệ',
              hintText: 'SĐT, email, Zalo của BTC',
              border: OutlineInputBorder(),
              helperText: 'Tùy chọn - tối thiểu 5 ký tự',
            ),
            onChanged: (value) {
              _onDataChanged({'contactInfo': value});
            },
          ),
          
          SizedBox(height: 20.h),
          
          // Tournament Preview
          _buildTournamentPreview(context),
          
          SizedBox(height: 20.h),
          
          // Publish Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isCreating ? null : _validateAndPublish,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                backgroundColor: context.appTheme.primary,
              ),
              child: _isCreating
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Đang tạo giải đấu...',
                          style: TextStyle(
                            fontSize: 16.fSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      'Tạo giải đấu',
                      style: TextStyle(
                        fontSize: 16.fSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildDateTimePicker({
    required String label,
    required DateTime? value,
    required Function(DateTime) onChanged,
  }) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now().add(Duration(days: 1)),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(Duration(days: 365)),
        );
        
        if (date != null) {
          final time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(value ?? DateTime.now()),
          );
          
          if (time != null) {
            final dateTime = DateTime(
              date.year,
              date.month,
              date.day,
              time.hour,
              time.minute,
            );
            onChanged(dateTime);
          }
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.grey[600]),
            SizedBox(width: 12.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.fSize,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  value != null 
                    ? '${value.day}/${value.month}/${value.year} ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}'
                    : 'Chọn thời gian',
                  style: TextStyle(fontSize: 16.fSize),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> _getRankOptions() {
    // Vietnamese billiards ranking system (12 tiers) from RankingConstants
    final ranks = RankingConstants.RANK_ORDER;
    return ranks.map((rank) => 
      DropdownMenuItem(
        value: rank,
        child: Text('Rank $rank'),
      ),
    ).toList();
  }

  Widget _buildTournamentPreview(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Xem lại thông tin giải đấu',
              style: TextStyle(
                fontSize: 18.fSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),
            _buildPreviewRow('Tên giải đấu', _tournamentData['name'] ?? ''),
            _buildPreviewRow('Môn thi đấu', _tournamentData['gameType'] ?? ''),
            _buildPreviewRow('Hình thức', _tournamentData['format'] ?? ''),
            _buildPreviewRow('Số người tham gia', '${_tournamentData['maxParticipants'] ?? 0}'),
            _buildPreviewRow('Phí đăng ký', '₫${_tournamentData['entryFee'] ?? 0}'),
            _buildPreviewRow('Tổng giải thưởng', '₫${_tournamentData['prizePool'] ?? 0}'),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value.isEmpty ? '-' : value),
          ),
        ],
      ),
    );
  }

  void _validateAndPublish() async {
    debugPrint('🔍 Tournament creation validation started');
    
    // Validate all forms
    bool isValid = true;
    _errors.clear();

    // Validate current step form
    if (!_validateCurrentStep()) {
      debugPrint('❌ Current step validation failed');
      isValid = false;
    }

    // Manual validation of required fields - check from controllers
    debugPrint('🔍 Validating fields:');
    debugPrint('  Name: "${_nameController.text}"');
    debugPrint('  Venue: "${_venueController.text}"');
    debugPrint('  Registration Start: ${_tournamentData['registrationStartDate']}');
    debugPrint('  Tournament Start: ${_tournamentData['tournamentStartDate']}');
    
    if (_nameController.text.isEmpty) {
      _errors['name'] = 'Vui lòng nhập tên giải đấu';
      isValid = false;
      debugPrint('❌ Name validation failed');
    }

    if (_venueController.text.isEmpty) {
      _errors['venue'] = 'Vui lòng nhập địa chỉ tổ chức';
      isValid = false;
      debugPrint('❌ Venue validation failed');
    }

    if (_tournamentData['registrationStartDate'] == null) {
      _errors['registrationStartDate'] = 'Vui lòng chọn thời gian mở đăng ký';
      isValid = false;
    }

    if (_tournamentData['tournamentStartDate'] == null) {
      _errors['tournamentStartDate'] = 'Vui lòng chọn thời gian bắt đầu giải';
      isValid = false;
    }

    if (!isValid) {
      debugPrint('❌ Validation failed with errors: $_errors');
      _showValidationErrors();
      return;
    }
    
    debugPrint('✅ All validation passed, creating tournament...');

    // Sync final data from controllers
    _tournamentData['name'] = _nameController.text;
    _tournamentData['description'] = _descriptionController.text;
    _tournamentData['venue'] = _venueController.text;
    _tournamentData['entryFee'] = double.tryParse(_entryFeeController.text) ?? 0.0;
    _tournamentData['prizePool'] = double.tryParse(_prizePoolController.text) ?? 0.0;
    _tournamentData['rules'] = _rulesController.text;
    _tournamentData['contactInfo'] = _contactInfoController.text;

    // Set loading state
    setState(() => _isCreating = true);

    try {
      // Create tournament using service with proper parameters
      final tournament = await _tournamentService.createTournament(
        clubId: widget.clubId ?? '',
        title: _tournamentData['name'] ?? '',
        description: _tournamentData['description'] ?? '',
        startDate: _tournamentData['tournamentStartDate'] ?? DateTime.now(),
        registrationDeadline: _tournamentData['registrationEndDate'] ?? DateTime.now(),
        maxParticipants: _tournamentData['maxParticipants'] ?? 16,
        entryFee: _tournamentData['entryFee'] ?? 0.0,
        prizePool: _tournamentData['prizePool'] ?? 0.0,
        // skillLevelRequired: removed - không dùng nữa
        rules: _tournamentData['rules'],
        requirements: _buildRequirements(),
      );
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Giải đấu "${tournament.title}" đã được tạo thành công!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Return tournament data to parent
      Navigator.of(context).pop(tournament);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi tạo giải đấu: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isCreating = false);
    }
  }

  String _buildRequirements() {
    List<String> requirements = [];
    
    if (_tournamentData['minRank']?.isNotEmpty == true) {
      requirements.add('Hạng tối thiểu: ${_tournamentData['minRank']}');
    }
    
    if (_tournamentData['maxRank']?.isNotEmpty == true) {
      requirements.add('Hạng tối đa: ${_tournamentData['maxRank']}');
    }
    
    if (_tournamentData['gameType']?.isNotEmpty == true) {
      requirements.add('Môn thi đấu: ${_tournamentData['gameType']}');
    }
    
    if (_tournamentData['format']?.isNotEmpty == true) {
      requirements.add('Hình thức: ${_tournamentData['format']}');
    }
    
    return requirements.join('; ');
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _basicInfoFormKey.currentState?.validate() ?? false;
      case 1:
        return _scheduleFormKey.currentState?.validate() ?? false;
      case 2:
        return _financialFormKey.currentState?.validate() ?? false;
      case 3:
        return _reviewFormKey.currentState?.validate() ?? false;
      case 4:
        // Bracket creation step - always valid (optional step)
        return true;
      default:
        return true;
    }
  }

  Widget _buildBracketCreationStep(BuildContext context) {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade50, Colors.blue.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12.w),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: appTheme.primary,
                    borderRadius: BorderRadius.circular(8.w),
                  ),
                  child: Icon(
                    Icons.account_tree,
                    color: Colors.white,
                    size: 24.w,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tạo bảng đấu',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: appTheme.primary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Tùy chọn tạo bảng đấu ngay sau khi tạo giải đấu thành công',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 24.h),
          
          // Create bracket option
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8.w),
            ),
            child: CheckboxListTile(
              value: _createBracketNow,
              onChanged: (value) {
                setState(() {
                  _createBracketNow = value ?? false;
                });
              },
              title: Text(
                'Tạo bảng đấu ngay',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                'Tự động tạo bảng đấu dựa trên thể thức và seeding đã chọn',
                style: theme.textTheme.bodySmall,
              ),
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ),
          
          if (_createBracketNow) ...[
            SizedBox(height: 20.h),
            
            // Tournament format selection
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8.w),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
                    child: Text(
                      'Thể thức thi đấu',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  
                  ..._buildFormatOptions(),
                  
                  SizedBox(height: 8.h),
                ],
              ),
            ),
            
            SizedBox(height: 16.h),
            
            // Seeding method selection
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8.w),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
                    child: Text(
                      'Phương thức xếp hạng (Seeding)',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  
                  ..._buildSeedingOptions(),
                  
                  SizedBox(height: 8.h),
                ],
              ),
            ),
            
            SizedBox(height: 20.h),
            
            // Preview info
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8.w),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.orange.shade700,
                    size: 20.w,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Thông tin bảng đấu',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.orange.shade700,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Format: ${_getFormatDisplayName(_selectedBracketFormat)}\n'
                          'Seeding: ${_getSeedingDisplayName(_selectedSeedingMethod)}\n'
                          'Số người tối đa: ${_tournamentData['maxParticipants'] ?? 16} người',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.orange.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          if (!_createBracketNow) ...[
            SizedBox(height: 20.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8.w),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.schedule,
                    color: Colors.grey.shade600,
                    size: 20.w,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'Bạn có thể tạo bảng đấu sau khi giải đấu đã có đủ người tham gia trong phần quản lý giải đấu.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          SizedBox(height: 40.h),
        ],
      ),
    );
  }

  List<Widget> _buildFormatOptions() {
    final formats = [
      {'key': 'single_elimination', 'name': 'Loại trực tiếp', 'desc': 'Thua 1 trận bị loại'},
      {'key': 'double_elimination', 'name': 'Loại kép', 'desc': 'Thua 2 trận mới bị loại'},
      {'key': 'round_robin', 'name': 'Vòng tròn', 'desc': 'Mọi người đấu với nhau'},
      {'key': 'swiss_system', 'name': 'Hệ thống Thụy Sĩ', 'desc': 'Ghép cặp theo điểm'},
    ];
    
    return formats.map((format) => RadioListTile<String>(
      value: format['key']!,
      groupValue: _selectedBracketFormat,
      onChanged: (value) {
        setState(() {
          _selectedBracketFormat = value!;
        });
      },
      title: Text(format['name']!),
      subtitle: Text(format['desc']!),
      dense: true,
    )).toList();
  }

  List<Widget> _buildSeedingOptions() {
    final methods = [
      {'key': 'elo_rating', 'name': 'Theo ELO Rating', 'desc': 'Xếp hạng theo điểm ELO'},
      {'key': 'ranking', 'name': 'Theo Rank', 'desc': 'Xếp hạng theo cấp độ'},
      {'key': 'random', 'name': 'Ngẫu nhiên', 'desc': 'Xáo trộn ngẫu nhiên'},
      {'key': 'manual', 'name': 'Thủ công', 'desc': 'Sắp xếp thủ công sau'},
    ];
    
    return methods.map((method) => RadioListTile<String>(
      value: method['key']!,
      groupValue: _selectedSeedingMethod,
      onChanged: (value) {
        setState(() {
          _selectedSeedingMethod = value!;
        });
      },
      title: Text(method['name']!),
      subtitle: Text(method['desc']!),
      dense: true,
    )).toList();
  }

  String _getFormatDisplayName(String format) {
    switch (format) {
      case 'single_elimination': return 'Loại trực tiếp';
      case 'double_elimination': return 'Loại kép';
      case 'round_robin': return 'Vòng tròn';
      case 'swiss_system': return 'Hệ thống Thụy Sĩ';
      default: return format;
    }
  }

  String _getSeedingDisplayName(String seeding) {
    switch (seeding) {
      case 'elo_rating': return 'Theo ELO Rating';
      case 'ranking': return 'Theo Rank';
      case 'random': return 'Ngẫu nhiên';
      case 'manual': return 'Thủ công';
      default: return seeding;
    }
  }

  Future<void> _createTournament() async {
    setState(() {
      _isCreating = true;
    });

    try {
      // Create tournament data
      final tournamentData = {
        'title': _tournamentData['name'],
        'description': _tournamentData['description'],
        'format': _selectedBracketFormat,
        'game_type': _tournamentData['gameType'],
        'max_participants': _tournamentData['maxParticipants'],
        'registration_start_date': _tournamentData['registrationStartDate']?.toIso8601String(),
        'registration_end_date': _tournamentData['registrationEndDate']?.toIso8601String(),
        'start_date': _tournamentData['tournamentStartDate']?.toIso8601String(),
        'end_date': _tournamentData['tournamentEndDate']?.toIso8601String(),
        'entry_fee': double.tryParse(_entryFeeController.text) ?? 0.0,
        'prize_pool': double.tryParse(_prizePoolController.text) ?? 0.0,
        'venue': _tournamentData['venue'],
        'contact_info': _tournamentData['contactInfo'],
        'rules': _tournamentData['rules'],
        'club_id': widget.clubId,
        'status': 'upcoming',
        'has_third_place_match': _tournamentData['hasThirdPlaceMatch'] ?? false,
      };

      // Create tournament
      debugPrint('🏆 Creating tournament with data: ${tournamentData.toString()}');
      
      // Here you would call your tournament service
      // final tournamentId = await _tournamentService.createTournament(tournamentData);
      // For now, simulate the creation
      await Future.delayed(Duration(seconds: 2));
      final tournamentId = 'mock_tournament_${DateTime.now().millisecondsSinceEpoch}';
      
      _createdTournamentId = tournamentId;
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Tạo giải đấu thành công!'),
          backgroundColor: Colors.green,
        ),
      );

      // If user chose to create bracket, show bracket creation dialog
      if (_createBracketNow) {
        await _showBracketCreationDialog();
      } else {
        // Navigate back or to tournament detail
        Navigator.of(context).pop(tournamentId);
      }

    } catch (e) {
      debugPrint('❌ Error creating tournament: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Lỗi tạo giải đấu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  Future<void> _showBracketCreationDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.account_tree, color: Colors.blue),
            SizedBox(width: 8.w),
            Text('Tạo bảng đấu'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Giải đấu đã được tạo thành công!'),
            SizedBox(height: 12.h),
            Text('Bạn có muốn tạo bảng đấu ngay bây giờ không?'),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8.w),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thông tin bảng đấu:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4.h),
                  Text('• Format: ${_getFormatDisplayName(_selectedBracketFormat)}'),
                  Text('• Seeding: ${_getSeedingDisplayName(_selectedSeedingMethod)}'),
                  Text('• Số người tối đa: ${_tournamentData['maxParticipants'] ?? 16}'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).pop(_createdTournamentId);
            },
            child: Text('Tạo sau'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _createBracketForTournament();
              Navigator.of(context).pop(_createdTournamentId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: Text('Tạo ngay'),
          ),
        ],
      ),
    );
  }

  Future<void> _createBracketForTournament() async {
    try {
      debugPrint('🏗️ Creating bracket for tournament: $_createdTournamentId');
      debugPrint('   Format: $_selectedBracketFormat');
      debugPrint('   Seeding: $_selectedSeedingMethod');
      
      // Here you would call bracket generator service
      // For now, just show success message
      await Future.delayed(Duration(seconds: 1));
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Bảng đấu đã được tạo thành công!'),
          backgroundColor: Colors.green,
        ),
      );
      
    } catch (e) {
      debugPrint('❌ Error creating bracket: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Lỗi tạo bảng đấu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showValidationErrors() {
    final errorMessages = _errors.values.join('\n');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Lỗi validation'),
        content: Text(errorMessages),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }



}