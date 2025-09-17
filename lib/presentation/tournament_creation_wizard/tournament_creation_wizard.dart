import 'package:flutter/material.dart';
import 'package:sabo_arena/core/app_export.dart';
import 'package:sabo_arena/theme/theme_extensions.dart';
import 'package:sabo_arena/utils/size_extensions.dart';

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
  
  // Tournament data with comprehensive fields
  Map<String, dynamic> _tournamentData = {
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
    super.dispose();
  }

  void _nextStep() {
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
                    onPressed: _currentStep < _stepTitles.length - 1
                        ? _nextStep
                        : null,
                    child: Text(_currentStep < _stepTitles.length - 1
                        ? 'Tiếp theo'
                        : 'Hoàn thành'),
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
            value: _tournamentData['gameType'],
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
            value: _tournamentData['format'],
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
            value: _tournamentData['maxParticipants'],
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
    );
  }

  Widget _buildScheduleVenueStep(BuildContext context) {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.h),
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
    );
  }

  Widget _buildFinancialRequirementsStep(BuildContext context) {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.h),
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
            value: _tournamentData['minRank']?.isEmpty == true ? null : _tournamentData['minRank'],
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
            value: _tournamentData['maxRank']?.isEmpty == true ? null : _tournamentData['maxRank'],
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
    );
  }

  Widget _buildRulesReviewStep(BuildContext context) {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.h),
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
              onPressed: _validateAndPublish,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                backgroundColor: appTheme.green600,
              ),
              child: Text(
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
    );
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
    final ranks = ['K', 'J', 'I', 'H', 'G', 'F', 'E', 'D', 'C', 'B', 'A', 'E+'];
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

  void _validateAndPublish() {
    // TODO: Add comprehensive validation
    if (_tournamentData['name']?.isEmpty == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng nhập tên giải đấu')),
      );
      return;
    }
    
    // TODO: Validate all required fields and business logic
    
    Navigator.of(context).pop(_tournamentData);
  }

}