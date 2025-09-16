import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sabo_arena/core/app_export.dart';

class BasicInfoStep extends StatefulWidget {
  final Map<String, dynamic> data;
  final Function(Map<String, dynamic>) onDataChanged;

  const BasicInfoStep({
    super.key,
    required this.data,
    required this.onDataChanged,
  });

  @override
  _BasicInfoStepState createState() => _BasicInfoStepState();
}

class _BasicInfoStepState extends State<BasicInfoStep>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _customParticipantsController = TextEditingController();
  final TextEditingController _customEntryFeeController = TextEditingController();

  String _selectedGameType = '8-ball';
  String _selectedTournamentType = 'single-elimination';
  int _selectedMaxParticipants = 16;
  int _selectedEntryFee = 100000;
  String _tournamentImage = '';
  bool _useCustomParticipants = false;
  bool _useCustomEntryFee = false;

  final List<GameType> _gameTypes = [
    GameType(
      value: '8-ball',
      label: '8 Bi',
      description: 'Pool 8 bi truyền thống',
      icon: '🎱',
      color: Colors.black87,
    ),
    GameType(
      value: '9-ball',
      label: '9 Bi',
      description: 'Pool 9 bi nhanh',
      icon: '🟡',
      color: Colors.orange,
    ),
    GameType(
      value: '10-ball',
      label: '10 Bi',
      description: 'Pool 10 bi chuyên nghiệp',
      icon: '🔟',
      color: Colors.blue,
    ),
  ];

  final List<TournamentType> _tournamentTypes = [
    TournamentType(
      value: 'single-elimination',
      label: 'Loại trực tiếp',
      description: 'Thua 1 trận là bị loại',
      icon: Icons.account_tree_outlined,
      pros: ['Nhanh gọn', 'Dễ tổ chức'],
      cons: ['Ít cơ hội cho người chơi'],
    ),
    TournamentType(
      value: 'double-elimination',
      label: 'Nhánh thắng/thua',
      description: 'Có cơ hội phục hồi',
      icon: Icons.alt_route_outlined,
      pros: ['Công bằng hơn', 'Nhiều trận đấu'],
      cons: ['Phức tạp hơn', 'Mất thời gian'],
    ),
    TournamentType(
      value: 'round-robin',
      label: 'Vòng tròn',
      description: 'Mọi người đấu với nhau',
      icon: Icons.loop_outlined,
      pros: ['Rất công bằng', 'Nhiều kinh nghiệm'],
      cons: ['Rất nhiều trận', 'Mất thời gian dài'],
    ),
  ];

  final List<int> _participantOptions = [8, 16, 32, 64];
  final List<int> _entryFeeOptions = [50000, 100000, 200000, 500000];

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
    _nameController.text = widget.data['tournamentName'] ?? '';
    _selectedGameType = widget.data['gameType'] ?? '8-ball';
    _selectedTournamentType = widget.data['tournamentType'] ?? 'single-elimination';
    _selectedMaxParticipants = widget.data['maxParticipants'] ?? 16;
    _selectedEntryFee = widget.data['entryFee'] ?? 100000;
    _tournamentImage = widget.data['tournamentImage'] ?? '';
    
    _customParticipantsController.text = _selectedMaxParticipants.toString();
    _customEntryFeeController.text = _selectedEntryFee.toString();
    
    _useCustomParticipants = !_participantOptions.contains(_selectedMaxParticipants);
    _useCustomEntryFee = !_entryFeeOptions.contains(_selectedEntryFee);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _customParticipantsController.dispose();
    _customEntryFeeController.dispose();
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
            padding: EdgeInsets.all(20.h),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Thông tin cơ bản", Icons.info_outline),
                  SizedBox(height: 16.v),
                  _buildTournamentNameField(),
                  
                  SizedBox(height: 24.v),
                  _buildSectionTitle("Loại game", Icons.sports_esports_outlined),
                  SizedBox(height: 16.v),
                  _buildGameTypeSelector(),
                  
                  SizedBox(height: 24.v),
                  _buildSectionTitle("Định dạng giải đấu", Icons.tournament_outlined),
                  SizedBox(height: 16.v),
                  _buildTournamentTypeSelector(),
                  
                  SizedBox(height: 24.v),
                  _buildSectionTitle("Số lượng tham gia", Icons.people_outline),
                  SizedBox(height: 16.v),
                  _buildMaxParticipantsSelector(),
                  
                  SizedBox(height: 24.v),
                  _buildSectionTitle("Lệ phí tham gia", Icons.payments_outlined),
                  SizedBox(height: 16.v),
                  _buildEntryFeeSelector(),
                  
                  SizedBox(height: 24.v),
                  _buildSectionTitle("Hình ảnh giải đấu", Icons.image_outlined),
                  SizedBox(height: 16.v),
                  _buildImageUploadSection(),
                  
                  SizedBox(height: 100.v), // Space for navigation buttons
                ],
              ),
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
          padding: EdgeInsets.all(8.h),
          decoration: BoxDecoration(
            color: appTheme.blue50,
            borderRadius: BorderRadius.circular(8.h),
          ),
          child: Icon(
            icon,
            color: appTheme.blue600,
            size: 20.adaptSize,
          ),
        ),
        SizedBox(width: 12.h),
        Text(
          title,
          style: TextStyle(
            fontSize: 18.fSize,
            fontWeight: FontWeight.bold,
            color: appTheme.gray900,
          ),
        ),
      ],
    );
  }

  Widget _buildTournamentNameField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.h),
        boxShadow: [
          BoxShadow(
            color: appTheme.black900.withOpacity(0.06),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: _nameController,
        decoration: InputDecoration(
          labelText: "Tên giải đấu *",
          hintText: "VD: Giải Bi-a Open 2024",
          prefixIcon: Icon(Icons.emoji_events_outlined, color: appTheme.gray600),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.h),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 16.v),
        ),
        validator: (value) {
          if (value?.isEmpty ?? true) {
            return 'Vui lòng nhập tên giải đấu';
          }
          if (value!.length < 5) {
            return 'Tên giải đấu phải có ít nhất 5 ký tự';
          }
          if (value.length > 50) {
            return 'Tên giải đấu không được quá 50 ký tự';
          }
          return null;
        },
        onChanged: (value) {
          _updateData();
        },
      ),
    );
  }

  Widget _buildGameTypeSelector() {
    return Column(
      children: _gameTypes.map((gameType) {
        final isSelected = _selectedGameType == gameType.value;
        
        return Container(
          margin: EdgeInsets.only(bottom: 12.v),
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedGameType = gameType.value;
              });
              _updateData();
            },
            borderRadius: BorderRadius.circular(12.h),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              padding: EdgeInsets.all(16.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.h),
                border: Border.all(
                  color: isSelected ? appTheme.blue600 : appTheme.gray200,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: appTheme.blue600.withOpacity(0.15),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ] : [
                  BoxShadow(
                    color: appTheme.black900.withOpacity(0.04),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 48.adaptSize,
                    height: 48.adaptSize,
                    decoration: BoxDecoration(
                      color: gameType.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.h),
                    ),
                    child: Center(
                      child: Text(
                        gameType.icon,
                        style: TextStyle(fontSize: 24.fSize),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.h),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          gameType.label,
                          style: TextStyle(
                            fontSize: 16.fSize,
                            fontWeight: FontWeight.bold,
                            color: appTheme.gray900,
                          ),
                        ),
                        Text(
                          gameType.description,
                          style: TextStyle(
                            fontSize: 14.fSize,
                            color: appTheme.gray600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Container(
                      padding: EdgeInsets.all(4.h),
                      decoration: BoxDecoration(
                        color: appTheme.blue600,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16.adaptSize,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTournamentTypeSelector() {
    return Column(
      children: _tournamentTypes.map((tournamentType) {
        final isSelected = _selectedTournamentType == tournamentType.value;
        
        return Container(
          margin: EdgeInsets.only(bottom: 12.v),
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedTournamentType = tournamentType.value;
              });
              _updateData();
            },
            borderRadius: BorderRadius.circular(12.h),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              padding: EdgeInsets.all(16.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.h),
                border: Border.all(
                  color: isSelected ? appTheme.green600 : appTheme.gray200,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: appTheme.green600.withOpacity(0.15),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ] : [
                  BoxShadow(
                    color: appTheme.black900.withOpacity(0.04),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.h),
                        decoration: BoxDecoration(
                          color: (isSelected ? appTheme.green600 : appTheme.gray600).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.h),
                        ),
                        child: Icon(
                          tournamentType.icon,
                          color: isSelected ? appTheme.green600 : appTheme.gray600,
                          size: 24.adaptSize,
                        ),
                      ),
                      SizedBox(width: 16.h),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tournamentType.label,
                              style: TextStyle(
                                fontSize: 16.fSize,
                                fontWeight: FontWeight.bold,
                                color: appTheme.gray900,
                              ),
                            ),
                            Text(
                              tournamentType.description,
                              style: TextStyle(
                                fontSize: 14.fSize,
                                color: appTheme.gray600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Container(
                          padding: EdgeInsets.all(4.h),
                          decoration: BoxDecoration(
                            color: appTheme.green600,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16.adaptSize,
                          ),
                        ),
                    ],
                  ),
                  
                  SizedBox(height: 12.v),
                  
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Ưu điểm:",
                              style: TextStyle(
                                fontSize: 12.fSize,
                                fontWeight: FontWeight.w600,
                                color: appTheme.green600,
                              ),
                            ),
                            ...tournamentType.pros.map((pro) => Text(
                              "• $pro",
                              style: TextStyle(
                                fontSize: 11.fSize,
                                color: appTheme.gray600,
                              ),
                            )),
                          ],
                        ),
                      ),
                      SizedBox(width: 16.h),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Nhược điểm:",
                              style: TextStyle(
                                fontSize: 12.fSize,
                                fontWeight: FontWeight.w600,
                                color: appTheme.orange600,
                              ),
                            ),
                            ...tournamentType.cons.map((con) => Text(
                              "• $con",
                              style: TextStyle(
                                fontSize: 11.fSize,
                                color: appTheme.gray600,
                              ),
                            )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMaxParticipantsSelector() {
    return Container(
      padding: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.h),
        boxShadow: [
          BoxShadow(
            color: appTheme.black900.withOpacity(0.06),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Chọn số lượng thí sinh tối đa:",
            style: TextStyle(
              fontSize: 14.fSize,
              fontWeight: FontWeight.w600,
              color: appTheme.gray700,
            ),
          ),
          SizedBox(height: 12.v),
          
          Wrap(
            spacing: 8.h,
            runSpacing: 8.v,
            children: _participantOptions.map((count) {
              final isSelected = !_useCustomParticipants && _selectedMaxParticipants == count;
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedMaxParticipants = count;
                    _useCustomParticipants = false;
                    _customParticipantsController.text = count.toString();
                  });
                  _updateData();
                },
                borderRadius: BorderRadius.circular(8.h),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 10.v),
                  decoration: BoxDecoration(
                    color: isSelected ? appTheme.blue600 : appTheme.gray100,
                    borderRadius: BorderRadius.circular(8.h),
                  ),
                  child: Text(
                    "$count người",
                    style: TextStyle(
                      color: isSelected ? Colors.white : appTheme.gray700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          
          SizedBox(height: 16.v),
          
          Row(
            children: [
              Checkbox(
                value: _useCustomParticipants,
                onChanged: (value) {
                  setState(() {
                    _useCustomParticipants = value ?? false;
                  });
                },
              ),
              Text(
                "Tùy chỉnh:",
                style: TextStyle(
                  fontSize: 14.fSize,
                  color: appTheme.gray700,
                ),
              ),
              SizedBox(width: 12.h),
              if (_useCustomParticipants) ...[
                Expanded(
                  child: TextFormField(
                    controller: _customParticipantsController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      hintText: "Nhập số",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.h),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.h, vertical: 8.v),
                      isDense: true,
                    ),
                    onChanged: (value) {
                      final intValue = int.tryParse(value);
                      if (intValue != null && intValue >= 4 && intValue <= 128) {
                        _selectedMaxParticipants = intValue;
                        _updateData();
                      }
                    },
                    validator: (value) {
                      if (_useCustomParticipants) {
                        final intValue = int.tryParse(value ?? '');
                        if (intValue == null) {
                          return 'Số không hợp lệ';
                        }
                        if (intValue < 4 || intValue > 128) {
                          return 'Từ 4 đến 128 người';
                        }
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ],
          ),
          
          if (_useCustomParticipants)
            Padding(
              padding: EdgeInsets.only(top: 8.v),
              child: Text(
                "Số lượng: 4 - 128 người",
                style: TextStyle(
                  fontSize: 12.fSize,
                  color: appTheme.gray500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEntryFeeSelector() {
    return Container(
      padding: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.h),
        boxShadow: [
          BoxShadow(
            color: appTheme.black900.withOpacity(0.06),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Lệ phí tham gia (VND):",
            style: TextStyle(
              fontSize: 14.fSize,
              fontWeight: FontWeight.w600,
              color: appTheme.gray700,
            ),
          ),
          SizedBox(height: 12.v),
          
          Wrap(
            spacing: 8.h,
            runSpacing: 8.v,
            children: _entryFeeOptions.map((fee) {
              final isSelected = !_useCustomEntryFee && _selectedEntryFee == fee;
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedEntryFee = fee;
                    _useCustomEntryFee = false;
                    _customEntryFeeController.text = fee.toString();
                  });
                  _updateData();
                },
                borderRadius: BorderRadius.circular(8.h),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 10.v),
                  decoration: BoxDecoration(
                    color: isSelected ? appTheme.green600 : appTheme.gray100,
                    borderRadius: BorderRadius.circular(8.h),
                  ),
                  child: Text(
                    "${fee.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} VND",
                    style: TextStyle(
                      color: isSelected ? Colors.white : appTheme.gray700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          
          SizedBox(height: 16.v),
          
          Row(
            children: [
              Checkbox(
                value: _useCustomEntryFee,
                onChanged: (value) {
                  setState(() {
                    _useCustomEntryFee = value ?? false;
                  });
                },
              ),
              Text(
                "Tùy chỉnh:",
                style: TextStyle(
                  fontSize: 14.fSize,
                  color: appTheme.gray700,
                ),
              ),
              SizedBox(width: 12.h),
              if (_useCustomEntryFee) ...[
                Expanded(
                  child: TextFormField(
                    controller: _customEntryFeeController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      hintText: "Nhập số tiền",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.h),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.h, vertical: 8.v),
                      isDense: true,
                      suffixText: "VND",
                    ),
                    onChanged: (value) {
                      final intValue = int.tryParse(value);
                      if (intValue != null) {
                        _selectedEntryFee = intValue;
                        _updateData();
                      }
                    },
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageUploadSection() {
    return Container(
      padding: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.h),
        border: Border.all(
          color: appTheme.gray200,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          if (_tournamentImage.isEmpty) ...[
            Container(
              height: 120.v,
              width: double.infinity,
              decoration: BoxDecoration(
                color: appTheme.gray100,
                borderRadius: BorderRadius.circular(8.h),
                border: Border.all(
                  color: appTheme.gray300,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_outlined,
                    color: appTheme.gray500,
                    size: 48.adaptSize,
                  ),
                  SizedBox(height: 8.v),
                  Text(
                    "Tải lên hình ảnh giải đấu",
                    style: TextStyle(
                      fontSize: 14.fSize,
                      color: appTheme.gray600,
                    ),
                  ),
                  Text(
                    "Khuyến nghị: 16:9 (1200x675px)",
                    style: TextStyle(
                      fontSize: 12.fSize,
                      color: appTheme.gray500,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Container(
              height: 120.v,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.h),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.h),
                child: CustomImageWidget(
                  imagePath: _tournamentImage,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
          
          SizedBox(height: 12.v),
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _selectImageFromGallery,
                  icon: Icon(Icons.photo_library_outlined),
                  label: Text("Thư viện"),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.v),
                  ),
                ),
              ),
              SizedBox(width: 12.h),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _selectImageFromCamera,
                  icon: Icon(Icons.camera_alt_outlined),
                  label: Text("Máy ảnh"),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.v),
                  ),
                ),
              ),
            ],
          ),
          
          if (_tournamentImage.isNotEmpty) ...[
            SizedBox(height: 8.v),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _tournamentImage = '';
                });
                _updateData();
              },
              icon: Icon(Icons.delete_outline, color: appTheme.red600),
              label: Text(
                "Xóa ảnh",
                style: TextStyle(color: appTheme.red600),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _selectImageFromGallery() {
    // Simulate image selection
    setState(() {
      _tournamentImage = 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=1200&h=675&fit=crop';
    });
    _updateData();
  }

  void _selectImageFromCamera() {
    // Simulate image capture
    setState(() {
      _tournamentImage = 'https://images.unsplash.com/photo-1594736797933-d0601ba2fe65?w=1200&h=675&fit=crop';
    });
    _updateData();
  }

  void _updateData() {
    widget.onDataChanged({
      'tournamentName': _nameController.text,
      'gameType': _selectedGameType,
      'tournamentType': _selectedTournamentType,
      'maxParticipants': _selectedMaxParticipants,
      'entryFee': _selectedEntryFee,
      'tournamentImage': _tournamentImage,
    });
  }
}

class GameType {
  final String value;
  final String label;
  final String description;
  final String icon;
  final Color color;

  GameType({
    required this.value,
    required this.label,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class TournamentType {
  final String value;
  final String label;
  final String description;
  final IconData icon;
  final List<String> pros;
  final List<String> cons;

  TournamentType({
    required this.value,
    required this.label,
    required this.description,
    required this.icon,
    required this.pros,
    required this.cons,
  });
}