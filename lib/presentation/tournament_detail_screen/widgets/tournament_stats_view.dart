import 'package:flutter/material.dart';
import 'package:sabo_arena/core/app_export.dart';

class TournamentStatsView extends StatefulWidget {
  final String tournamentId;
  final String tournamentStatus;

  const TournamentStatsView({
    super.key,
    required this.tournamentId,
    required this.tournamentStatus,
  });

  @override
  _TournamentStatsViewState createState() => _TournamentStatsViewState();
}

class _TournamentStatsViewState extends State<TournamentStatsView>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<double>> _cardAnimations;
  
  bool _isLoading = true;
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _cardAnimations = List.generate(6, (index) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          index * 0.1,
          0.6 + (index * 0.1),
          curve: Curves.easeInOut,
        ),
      ));
    });

    _loadStats();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    // Simulate loading
    await Future.delayed(Duration(milliseconds: 800));
    
    setState(() {
      _stats = _generateMockStats();
      _isLoading = false;
    });
    
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.h)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _isLoading ? _buildLoadingState() : _buildStatsContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: appTheme.gray200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Thống kê giải đấu",
                  style: TextStyle(
                    fontSize: 18.fSize,
                    fontWeight: FontWeight.bold,
                    color: appTheme.gray900,
                  ),
                ),
                Text(
                  "Chi tiết và phân tích dữ liệu",
                  style: TextStyle(
                    fontSize: 12.fSize,
                    color: appTheme.gray600,
                  ),
                ),
              ],
            ),
          ),
          
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close, color: appTheme.gray600),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: appTheme.blue600),
          SizedBox(height: 16.v),
          Text(
            "Đang tải thống kê...",
            style: TextStyle(fontSize: 14.fSize, color: appTheme.gray600),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.h),
      child: Column(
        children: [
          _buildOverviewCards(),
          SizedBox(height: 24.v),
          _buildProgressChart(),
          SizedBox(height: 24.v),
          _buildParticipationAnalysis(),
          SizedBox(height: 24.v),
          _buildMatchStatistics(),
          SizedBox(height: 24.v),
          _buildPerformanceMetrics(),
        ],
      ),
    );
  }

  Widget _buildOverviewCards() {
    final overviewData = [
      {
        'title': 'Tổng người chơi',
        'value': _stats['total_participants']?.toString() ?? '0',
        'subtitle': 'Đã đăng ký',
        'icon': Icons.people,
        'color': appTheme.blue600,
      },
      {
        'title': 'Tỷ lệ hoàn thành',
        'value': '${_stats['completion_rate'] ?? 0}%',
        'subtitle': 'Trận đấu',
        'icon': Icons.pie_chart,
        'color': appTheme.green600,
      },
      {
        'title': 'Trận đấu',
        'value': '${_stats['completed_matches']}/${_stats['total_matches']}',
        'subtitle': 'Hoàn thành',
        'icon': Icons.sports_tennis,
        'color': appTheme.orange600,
      },
    ];

    return Row(
      children: overviewData.asMap().entries.map((entry) {
        final index = entry.key;
        final data = entry.value;
        
        return Expanded(
          child: AnimatedBuilder(
            animation: _cardAnimations[index],
            builder: (context, child) {
              return Transform.scale(
                scale: _cardAnimations[index].value,
                child: Container(
                  margin: EdgeInsets.only(right: index < 2 ? 8.h : 0),
                  padding: EdgeInsets.all(16.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        data['color'] as Color,
                        (data['color'] as Color).withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12.h),
                    boxShadow: [
                      BoxShadow(
                        color: (data['color'] as Color).withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        data['icon'] as IconData,
                        color: Colors.white.withOpacity(0.8),
                        size: 20.adaptSize,
                      ),
                      SizedBox(height: 8.v),
                      
                      Text(
                        data['value'] as String,
                        style: TextStyle(
                          fontSize: 18.fSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      
                      Text(
                        data['title'] as String,
                        style: TextStyle(
                          fontSize: 10.fSize,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      
                      Text(
                        data['subtitle'] as String,
                        style: TextStyle(
                          fontSize: 9.fSize,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProgressChart() {
    return AnimatedBuilder(
      animation: _cardAnimations[3],
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - _cardAnimations[3].value)),
          child: Opacity(
            opacity: _cardAnimations[3].value,
            child: Container(
              padding: EdgeInsets.all(16.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.h),
                border: Border.all(color: appTheme.gray200),
                boxShadow: [
                  BoxShadow(
                    color: appTheme.black900.withOpacity(0.05),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.trending_up, color: appTheme.blue600, size: 20.adaptSize),
                      SizedBox(width: 8.h),
                      Text(
                        "Tiến độ giải đấu",
                        style: TextStyle(
                          fontSize: 16.fSize,
                          fontWeight: FontWeight.bold,
                          color: appTheme.gray900,
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 16.v),
                  
                  // Progress timeline
                  Column(
                    children: _getProgressSteps().asMap().entries.map((entry) {
                      final index = entry.key;
                      final step = entry.value;
                      final isCompleted = step['completed'] as bool;
                      final isCurrent = step['current'] as bool;
                      
                      return Row(
                        children: [
                          Column(
                            children: [
                              Container(
                                width: 20.h,
                                height: 20.v,
                                decoration: BoxDecoration(
                                  color: isCompleted 
                                    ? appTheme.green600 
                                    : (isCurrent ? appTheme.blue600 : appTheme.gray300),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isCompleted ? Icons.check : Icons.circle,
                                  size: 12.adaptSize,
                                  color: Colors.white,
                                ),
                              ),
                              
                              if (index < _getProgressSteps().length - 1)
                                Container(
                                  width: 2.h,
                                  height: 30.v,
                                  color: isCompleted ? appTheme.green600 : appTheme.gray300,
                                ),
                            ],
                          ),
                          
                          SizedBox(width: 12.h),
                          
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 8.v),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    step['title'] as String,
                                    style: TextStyle(
                                      fontSize: 13.fSize,
                                      fontWeight: FontWeight.w600,
                                      color: isCompleted || isCurrent 
                                        ? appTheme.gray900 
                                        : appTheme.gray500,
                                    ),
                                  ),
                                  
                                  Text(
                                    step['subtitle'] as String,
                                    style: TextStyle(
                                      fontSize: 11.fSize,
                                      color: appTheme.gray600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          if (step['date'] != null)
                            Text(
                              step['date'] as String,
                              style: TextStyle(
                                fontSize: 10.fSize,
                                color: appTheme.gray500,
                              ),
                            ),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildParticipationAnalysis() {
    return AnimatedBuilder(
      animation: _cardAnimations[4],
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - _cardAnimations[4].value)),
          child: Opacity(
            opacity: _cardAnimations[4].value,
            child: Container(
              padding: EdgeInsets.all(16.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.h),
                border: Border.all(color: appTheme.gray200),
                boxShadow: [
                  BoxShadow(
                    color: appTheme.black900.withOpacity(0.05),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.analytics, color: appTheme.purple600, size: 20.adaptSize),
                      SizedBox(width: 8.h),
                      Text(
                        "Phân tích tham gia",
                        style: TextStyle(
                          fontSize: 16.fSize,
                          fontWeight: FontWeight.bold,
                          color: appTheme.gray900,
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 16.v),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildAnalysisItem(
                          "Theo rank",
                          _getRankDistribution(),
                          appTheme.blue600,
                        ),
                      ),
                      
                      SizedBox(width: 16.h),
                      
                      Expanded(
                        child: _buildAnalysisItem(
                          "Theo club",
                          _getClubDistribution(),
                          appTheme.green600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnalysisItem(String title, List<Map<String, dynamic>> data, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13.fSize,
            fontWeight: FontWeight.w600,
            color: appTheme.gray700,
          ),
        ),
        
        SizedBox(height: 8.v),
        
        ...data.map((item) => Container(
          margin: EdgeInsets.only(bottom: 4.v),
          child: Row(
            children: [
              Container(
                width: 8.h,
                height: 8.v,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              
              SizedBox(width: 6.h),
              
              Expanded(
                child: Text(
                  item['label'] as String,
                  style: TextStyle(
                    fontSize: 11.fSize,
                    color: appTheme.gray600,
                  ),
                ),
              ),
              
              Text(
                "${item['count']}",
                style: TextStyle(
                  fontSize: 11.fSize,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildMatchStatistics() {
    return AnimatedBuilder(
      animation: _cardAnimations[5],
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - _cardAnimations[5].value)),
          child: Opacity(
            opacity: _cardAnimations[5].value,
            child: Container(
              padding: EdgeInsets.all(16.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.h),
                border: Border.all(color: appTheme.gray200),
                boxShadow: [
                  BoxShadow(
                    color: appTheme.black900.withOpacity(0.05),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.sports_score, color: appTheme.orange600, size: 20.adaptSize),
                      SizedBox(width: 8.h),
                      Text(
                        "Thống kê trận đấu",
                        style: TextStyle(
                          fontSize: 16.fSize,
                          fontWeight: FontWeight.bold,
                          color: appTheme.gray900,
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 16.v),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          "Trung bình",
                          "${_stats['avg_match_duration']} phút",
                          "Thời gian/trận",
                          Icons.timer,
                          appTheme.blue600,
                        ),
                      ),
                      
                      Expanded(
                        child: _buildStatItem(
                          "Tỷ số cao nhất",
                          _stats['highest_score']?.toString() ?? "3-0",
                          "Trong giải",
                          Icons.trending_up,
                          appTheme.red600,
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 12.v),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          "Trận kịch tính",
                          "${_stats['close_matches']}",
                          "Hiệp phụ/Deuce",
                          Icons.flash_on,
                          appTheme.orange600,
                        ),
                      ),
                      
                      Expanded(
                        child: _buildStatItem(
                          "Thắng nhanh",
                          "${_stats['quick_wins']}",
                          "< 15 phút",
                          Icons.speed,
                          appTheme.green600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String value, String subtitle, String label, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12.h),
      margin: EdgeInsets.only(right: 8.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.h),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20.adaptSize),
          SizedBox(height: 4.v),
          
          Text(
            value,
            style: TextStyle(
              fontSize: 13.fSize,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11.fSize,
              fontWeight: FontWeight.w600,
              color: appTheme.gray700,
            ),
          ),
          
          Text(
            label,
            style: TextStyle(
              fontSize: 9.fSize,
              color: appTheme.gray500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetrics() {
    final topPerformers = _getTopPerformers();
    
    return Container(
      padding: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [appTheme.blue600.withOpacity(0.1), appTheme.purple600.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.h),
        border: Border.all(color: appTheme.blue600.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emoji_events, color: appTheme.amber600, size: 20.adaptSize),
              SizedBox(width: 8.h),
              Text(
                "Thành tích xuất sắc",
                style: TextStyle(
                  fontSize: 16.fSize,
                  fontWeight: FontWeight.bold,
                  color: appTheme.gray900,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16.v),
          
          ...topPerformers.asMap().entries.map((entry) {
            final index = entry.key;
            final performer = entry.value;
            
            return Container(
              margin: EdgeInsets.only(bottom: 8.v),
              padding: EdgeInsets.all(12.h),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(8.h),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24.h,
                    height: 24.v,
                    decoration: BoxDecoration(
                      color: _getRankColor(index),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        "${index + 1}",
                        style: TextStyle(
                          fontSize: 11.fSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(width: 12.h),
                  
                  CircleAvatar(
                    radius: 16.adaptSize,
                    backgroundImage: NetworkImage(performer['avatar'] as String),
                  ),
                  
                  SizedBox(width: 12.h),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          performer['name'] as String,
                          style: TextStyle(
                            fontSize: 13.fSize,
                            fontWeight: FontWeight.w600,
                            color: appTheme.gray900,
                          ),
                        ),
                        
                        Text(
                          performer['achievement'] as String,
                          style: TextStyle(
                            fontSize: 11.fSize,
                            color: appTheme.gray600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  Text(
                    performer['stat'] as String,
                    style: TextStyle(
                      fontSize: 12.fSize,
                      fontWeight: FontWeight.bold,
                      color: _getRankColor(index),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 0: return appTheme.amber600; // Gold
      case 1: return appTheme.gray500;  // Silver
      case 2: return appTheme.orange800; // Bronze
      default: return appTheme.blue600;
    }
  }

  Map<String, dynamic> _generateMockStats() {
    return {
      'total_participants': 18,
      'completion_rate': 65,
      'completed_matches': 11,
      'total_matches': 17,
      'avg_match_duration': 22,
      'highest_score': '3-0',
      'close_matches': 4,
      'quick_wins': 2,
    };
  }

  List<Map<String, dynamic>> _getProgressSteps() {
    return [
      {
        'title': 'Mở đăng ký',
        'subtitle': 'Bắt đầu nhận đăng ký từ người chơi',
        'completed': true,
        'current': false,
        'date': '10/01',
      },
      {
        'title': 'Đóng đăng ký',
        'subtitle': 'Hoàn thành việc tuyển chọn người chơi',
        'completed': true,
        'current': false,
        'date': '15/01',
      },
      {
        'title': 'Vòng bảng',
        'subtitle': 'Đang diễn ra các trận đấu vòng bảng',
        'completed': false,
        'current': true,
        'date': null,
      },
      {
        'title': 'Vòng loại trực tiếp',
        'subtitle': 'Tứ kết, bán kết và chung kết',
        'completed': false,
        'current': false,
        'date': null,
      },
      {
        'title': 'Trao giải',
        'subtitle': 'Lễ trao giải và kết thúc giải đấu',
        'completed': false,
        'current': false,
        'date': null,
      },
    ];
  }

  List<Map<String, dynamic>> _getRankDistribution() {
    return [
      {'label': 'Dưới 1000', 'count': 3},
      {'label': '1000-1500', 'count': 8},
      {'label': '1500-2000', 'count': 5},
      {'label': 'Trên 2000', 'count': 2},
    ];
  }

  List<Map<String, dynamic>> _getClubDistribution() {
    return [
      {'label': 'Saigon PP', 'count': 8},
      {'label': 'Hanoi TT', 'count': 5},
      {'label': 'Da Nang Sports', 'count': 3},
      {'label': 'Cá nhân', 'count': 2},
    ];
  }

  List<Map<String, dynamic>> _getTopPerformers() {
    return [
      {
        'name': 'Nguyễn Văn A',
        'achievement': 'Tỷ lệ thắng cao nhất',
        'stat': '100%',
        'avatar': 'https://images.unsplash.com/photo-1580000000001?w=100&h=100&fit=crop&crop=face',
      },
      {
        'name': 'Lê Văn B',
        'achievement': 'Nhiều trận thắng nhất',
        'stat': '8 trận',
        'avatar': 'https://images.unsplash.com/photo-1580000000002?w=100&h=100&fit=crop&crop=face',
      },
      {
        'name': 'Trần Văn C',
        'achievement': 'Trận đấu nhanh nhất',
        'stat': '12 phút',
        'avatar': 'https://images.unsplash.com/photo-1580000000003?w=100&h=100&fit=crop&crop=face',
      },
    ];
  }
}