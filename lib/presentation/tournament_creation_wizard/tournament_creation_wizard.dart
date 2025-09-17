import 'package:flutter/material.dart';
import 'package:sabo_arena/core/app_export.dart';
import 'widgets/basic_info_step.dart';
import 'widgets/schedule_step.dart';
import 'widgets/requirements_step.dart';
import 'widgets/prizes_step.dart';
import 'widgets/review_step.dart';
import 'widgets/schedule_step.dart';
import 'widgets/requirements_step.dart';
import 'widgets/prizes_step.dart';
import 'widgets/review_step.dart';

class TournamentCreationWizard extends StatefulWidget {
  final String? clubId;
  
  const TournamentCreationWizard({super.key, this.clubId});

  @override
  _TournamentCreationWizardState createState() => _TournamentCreationWizardState();
}

class _TournamentCreationWizardState extends State<TournamentCreationWizard>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _progressController;
  late Animation<double> _slideAnimation;
  late Animation<double> _progressAnimation;

  int _currentStep = 0;
  bool _isLoading = false;
  Map<String, dynamic> _tournamentData = {};

  final List<WizardStep> _steps = [
    WizardStep(
      id: "basic-info",
      title: "Thông tin cơ bản",
      icon: Icons.info_outline,
    ),
    WizardStep(
      id: "schedule", 
      title: "Lịch trình",
      icon: Icons.schedule_outlined,
    ),
    WizardStep(
      id: "requirements",
      title: "Yêu cầu tham gia",
      icon: Icons.rule_outlined,
    ),
    WizardStep(
      id: "prizes",
      title: "Giải thưởng",
      icon: Icons.emoji_events_outlined,
    ),
    WizardStep(
      id: "review",
      title: "Xem lại",
      icon: Icons.preview_outlined,
    ),
  ];

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOut,
    ));

    _initializeTournamentData();
    _progressController.forward();
  }

  void _initializeTournamentData() {
    _tournamentData = {
      'basicInfo': {
        'tournamentName': '',
        'gameType': '8-ball',
        'tournamentType': 'single-elimination',
        'maxParticipants': 16,
        'entryFee': 100000,
        'tournamentImage': '',
      },
      'schedule': {
        'registrationStartDate': DateTime.now(),
        'registrationEndDate': DateTime.now().add(Duration(days: 7)),
        'tournamentStartDate': DateTime.now().add(Duration(days: 8)),
        'tournamentEndDate': DateTime.now().add(Duration(days: 15)),
        'matchScheduling': 'flexible',
        'matchDuration': 60,
        'breakTime': 15,
        'dailyMatches': 3,
        'timeSlots': [],
      },
      'requirements': {
        'rankRequirements': {
          'enabled': false,
          'minRank': 'K',
          'maxRank': 'A',
        },
        'membershipRequirements': {
          'clubMembersOnly': false,
          'allowGuestPlayers': true,
          'guestFeeMultiplier': 1.5,
        },
        'ageRequirements': {
          'enabled': false,
          'minAge': 16,
          'maxAge': null,
          'requireParentalConsent': true,
        },
        'additionalRules': {
          'customRules': '',
        },
      },
      'prizes': {
        'prizePool': {
          'total': 0,
          'source': 'entry-fees',
          'clubContribution': 0,
        },
        'prizeDistribution': {
          'template': 'standard',
          'customDistribution': [],
        },
      },
    };
  }

  @override
  void dispose() {
    _animationController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: appTheme.gray50,
        appBar: _buildAppBar(),
        body: Column(
          children: [
            _buildProgressIndicator(),
            _buildStepIndicator(),
            Expanded(
              child: _buildStepContent(),
            ),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text(
        "Tạo giải đấu mới",
        style: TextStyle(
          fontSize: 18.fSize,
          fontWeight: FontWeight.bold,
          color: appTheme.gray900,
        ),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.close, color: appTheme.gray700),
        onPressed: () => _onBackPressed(),
      ),
      actions: [
        TextButton(
          onPressed: _saveDraft,
          child: Text(
            "Lưu nháp",
            style: TextStyle(
              color: appTheme.blue600,
              fontSize: 14.fSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Container(
          height: 1,
          color: appTheme.gray200,
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.h, vertical: 16.v),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Bước ${_currentStep + 1} / ${_steps.length}",
                style: TextStyle(
                  fontSize: 14.fSize,
                  color: appTheme.gray600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                "${(((_currentStep + 1) / _steps.length) * 100).toInt()}%",
                style: TextStyle(
                  fontSize: 14.fSize,
                  color: appTheme.blue600,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.v),
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Container(
                height: 6.v,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3.h),
                  color: appTheme.gray200,
                ),
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3.h),
                        gradient: LinearGradient(
                          colors: [
                            appTheme.blue600,
                            appTheme.blue400,
                          ],
                        ),
                      ),
                      width: (MediaQuery.of(context).size.width - 40.h) * 
                             ((_currentStep + 1) / _steps.length) * _progressAnimation.value,
                      height: 6.v,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.h, vertical: 16.v),
      color: Colors.white,
      child: Row(
        children: _steps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;
          
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 40.adaptSize,
                        height: 40.adaptSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCompleted 
                              ? appTheme.green600 
                              : isActive 
                                  ? appTheme.blue600 
                                  : appTheme.gray300,
                          boxShadow: isActive ? [
                            BoxShadow(
                              color: appTheme.blue600.withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ] : null,
                        ),
                        child: Icon(
                          isCompleted 
                              ? Icons.check 
                              : step.icon,
                          color: Colors.white,
                          size: 20.adaptSize,
                        ),
                      ),
                      SizedBox(height: 8.v),
                      Text(
                        step.title,
                        style: TextStyle(
                          fontSize: 10.fSize,
                          color: isActive 
                              ? appTheme.blue600 
                              : isCompleted 
                                  ? appTheme.green600 
                                  : appTheme.gray600,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (index < _steps.length - 1) ...[
                  SizedBox(width: 8.h),
                  Expanded(
                    child: Container(
                      height: 2.v,
                      decoration: BoxDecoration(
                        color: index < _currentStep 
                            ? appTheme.green600 
                            : appTheme.gray300,
                        borderRadius: BorderRadius.circular(1.h),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.h),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStepContent() {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(MediaQuery.of(context).size.width * _slideAnimation.value, 0),
          child: _getCurrentStepWidget(),
        );
      },
    );
  }

  Widget _getCurrentStepWidget() {
    switch (_currentStep) {
      case 0:
        return BasicInfoStep(
          data: _tournamentData['basicInfo'],
          onDataChanged: (data) => _updateStepData('basicInfo', data),
        );
      case 1:
        return ScheduleStep(
          data: _tournamentData['schedule'],
          onDataChanged: (data) => _updateStepData('schedule', data),
        );
      case 2:
        return RequirementsStep(
          data: _tournamentData['requirements'],
          onDataChanged: (data) => _updateStepData('requirements', data),
        );
      case 3:
        return PrizesStep(
          data: {
            ..._tournamentData['prizes'],
            'entryFee': _tournamentData['basicInfo']['entryFee'],
            'maxParticipants': _tournamentData['basicInfo']['maxParticipants'],
          },
          onDataChanged: (data) => _updateStepData('prizes', data),
        );
      case 4:
        return ReviewStep(
          data: {
            ..._tournamentData['basicInfo'],
            ..._tournamentData['schedule'],
            ..._tournamentData['requirements'],
            ..._tournamentData['prizes'],
          },
          onDataChanged: (data) {},
          onPublish: _publishTournament,
        );
      default:
        return Container();
    }
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: EdgeInsets.all(20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: appTheme.black900.withOpacity(0.08),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _isLoading ? null : _goToPreviousStep,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.v),
                  side: BorderSide(color: appTheme.gray400),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.h),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_back_ios, size: 16.adaptSize),
                    SizedBox(width: 8.h),
                    Text(
                      "Quay lại",
                      style: TextStyle(
                        fontSize: 16.fSize,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          if (_currentStep > 0) SizedBox(width: 16.h),
          
          Expanded(
            flex: _currentStep == 0 ? 1 : 1,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _goToNextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: appTheme.blue600,
                padding: EdgeInsets.symmetric(vertical: 16.v),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.h),
                ),
                elevation: 2,
              ),
              child: _isLoading
                  ? SizedBox(
                      width: 20.adaptSize,
                      height: 20.adaptSize,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _currentStep == _steps.length - 1 
                              ? "Xuất bản" 
                              : "Tiếp theo",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.fSize,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 8.h),
                        Icon(
                          _currentStep == _steps.length - 1 
                              ? Icons.publish 
                              : Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 16.adaptSize,
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _updateStepData(String stepKey, Map<String, dynamic> data) {
    setState(() {
      _tournamentData[stepKey] = data;
    });
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0: // Basic Info
        final basicInfo = _tournamentData['basicInfo'];
        return basicInfo['tournamentName']?.isNotEmpty == true &&
               basicInfo['gameType']?.isNotEmpty == true &&
               basicInfo['tournamentType']?.isNotEmpty == true;
      
      case 1: // Schedule  
        final schedule = _tournamentData['schedule'];
        final regEnd = schedule['registrationEndDate'] as DateTime?;
        final tournStart = schedule['tournamentStartDate'] as DateTime?;
        return regEnd != null && 
               tournStart != null && 
               tournStart.isAfter(regEnd);
      
      case 2: // Requirements
        return true; // Requirements are optional
      
      case 3: // Prizes
        return true; // Basic prize calculation is automatic
      
      case 4: // Review
        return true;
      
      default:
        return false;
    }
  }

  void _goToNextStep() {
    if (!_validateCurrentStep()) {
      _showValidationError();
      return;
    }

    if (_currentStep < _steps.length - 1) {
      _animationController.forward().then((_) {
        setState(() {
          _currentStep++;
        });
        _animationController.reverse();
        _updateProgressAnimation();
      });
    } else {
      _publishTournament();
    }
  }

  void _goToPreviousStep() {
    if (_currentStep > 0) {
      _animationController.forward().then((_) {
        setState(() {
          _currentStep--;
        });
        _animationController.reverse();
        _updateProgressAnimation();
      });
    }
  }

  void _updateProgressAnimation() {
    _progressController.reset();
    _progressController.forward();
  }

  void _showValidationError() {
    String message;
    switch (_currentStep) {
      case 0:
        message = "Vui lòng điền đầy đủ thông tin cơ bản của giải đấu";
        break;
      case 1:
        message = "Vui lòng thiết lập lịch trình hợp lệ cho giải đấu";
        break;
      default:
        message = "Vui lòng kiểm tra lại thông tin";
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: appTheme.red600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _saveDraft() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate saving draft
    await Future.delayed(Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Đã lưu nháp thành công"),
          backgroundColor: appTheme.green600,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _publishTournament() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate publishing tournament
    await Future.delayed(Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                color: appTheme.green600,
                size: 64.adaptSize,
              ),
              SizedBox(height: 16.v),
              Text(
                "Giải đấu đã được tạo thành công!",
                style: TextStyle(
                  fontSize: 18.fSize,
                  fontWeight: FontWeight.bold,
                  color: appTheme.gray900,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.v),
              Text(
                "Giải đấu '${_tournamentData['basicInfo']['tournamentName']}' đã được xuất bản và sẵn sàng nhận đăng ký.",
                style: TextStyle(
                  fontSize: 14.fSize,
                  color: appTheme.gray600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Close wizard
              },
              child: Text("Xem danh sách giải đấu"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Close wizard
                // Navigate to tournament detail
              },
              child: Text("Quản lý giải đấu"),
            ),
          ],
        ),
      );
    }
  }

  Future<bool> _onWillPop() async {
    return await _showExitDialog() ?? false;
  }

  void _onBackPressed() async {
    if (await _onWillPop()) {
      Navigator.of(context).pop();
    }
  }

  Future<bool?> _showExitDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Thoát tạo giải đấu?"),
        content: Text("Bạn có muốn lưu nháp trước khi thoát không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text("Thoát không lưu"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(false);
              _saveDraft();
              Navigator.of(context).pop(true);
            },
            child: Text("Lưu và thoát"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text("Tiếp tục tạo"),
          ),
        ],
      ),
    );
  }
}

class WizardStep {
  final String id;
  final String title;
  final IconData icon;

  WizardStep({
    required this.id,
    required this.title,
    required this.icon,
  });
}