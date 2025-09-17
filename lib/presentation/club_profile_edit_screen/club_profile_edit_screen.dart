import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


import 'widgets/image_upload_section_simple.dart';

class ClubProfileEditScreen extends StatefulWidget {
  const ClubProfileEditScreen({super.key});

  @override
  _ClubProfileEditScreenState createState() => _ClubProfileEditScreenState();
}

class _ClubProfileEditScreenState extends State<ClubProfileEditScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();

  // Form Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  final TextEditingController _facebookController = TextEditingController();
  final TextEditingController _instagramController = TextEditingController();
  final TextEditingController _tiktokController = TextEditingController();

  // Form State
  bool _isLoading = false;
  bool _hasUnsavedChanges = false;
  String _coverImageUrl = '';
  String _logoImageUrl = '';
  // Map<String, String> _operatingHours = {};  // Temporarily disabled
  Map<String, double> _location = {'lat': 0.0, 'lng': 0.0};
  List<String> _selectedFacilities = [];
  List<String> _tableTypes = [];
  int _totalTables = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _initializeFormData();
    _animationController.forward();
  }

  void _initializeFormData() {
    // Load existing club data
    _nameController.text = "SABO Arena Central";
    _usernameController.text = "saboarena_central";
    _descriptionController.text = "Arena bi-a hiện đại với hệ thống thi đấu chuyên nghiệp và không gian rộng rãi.";
    _phoneController.text = "+84 28 3944 5678";
    _emailController.text = "contact@saboarena.vn";
    _websiteController.text = "https://saboarena.vn";
    _addressController.text = "123 Nguyễn Huệ, Quận 1, TP.HCM";
    _minPriceController.text = "80000";
    _maxPriceController.text = "120000";
    _facebookController.text = "saboarena.central";
    _instagramController.text = "saboarena_central";
    _tiktokController.text = "saboarena.official";
    
    _coverImageUrl = 'https://images.unsplash.com/photo-1574631806042-182f10c4a017?w=800&h=400&fit=crop';
    _logoImageUrl = 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=200&h=200&fit=crop';
    
    // _operatingHours = {
    //   'monday': '08:00-24:00',
    //   'tuesday': '08:00-24:00',
    //   'wednesday': '08:00-24:00',
    //   'thursday': '08:00-24:00',
    //   'friday': '08:00-24:00',
    //   'saturday': '08:00-24:00',
    //   'sunday': '08:00-24:00',
    // };
    
    _location = {'lat': 10.7769, 'lng': 106.7009};
    _selectedFacilities = ['Bàn 8 bi', 'Bàn 9 bi', 'Cafeteria', 'WiFi miễn phí'];
    _tableTypes = ['Pool', 'Carom', 'Snooker'];
    _totalTables = 20;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    _scrollController.dispose();
    
    // Dispose controllers
    _nameController.dispose();
    _usernameController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _addressController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _facebookController.dispose();
    _instagramController.dispose();
    _tiktokController.dispose();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.grey[50]!,
        appBar: _buildAppBar(),
        body: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Column(
                children: [
                  _buildTabBar(),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildBasicInfoTab(),
                        _buildContactTab(),
                        _buildBusinessTab(),
                        _buildMediaTab(),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        bottomNavigationBar: _buildBottomActions(),
        floatingActionButton: _hasUnsavedChanges ? _buildSaveButton() : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text(
        "Chỉnh sửa hồ sơ",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.grey[900]!,
        ),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.close, color: Colors.grey[700]!),
        onPressed: _onClosePressed,
      ),
      actions: [
        if (_hasUnsavedChanges)
          TextButton(
            onPressed: _onSavePressed,
            child: Text(
              "Lưu",
              style: TextStyle(
                color: Colors.blue[600]!,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Container(
          height: 1,
          color: Colors.grey[200]!,
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        indicatorColor: Colors.blue[600]!,
        labelColor: Colors.blue[600]!,
        unselectedLabelColor: Colors.grey[600]!,
        labelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        tabs: [
          Tab(text: "Cơ bản"),
          Tab(text: "Liên hệ"),
          Tab(text: "Kinh doanh"),
          Tab(text: "Media"),
        ],
      ),
    );
  }

  Widget _buildBasicInfoTab() {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Images Section
            ImageUploadSection(
              coverImageUrl: _coverImageUrl,
              logoImageUrl: _logoImageUrl,
              onCoverChanged: (url) {
                setState(() {
                  _coverImageUrl = url;
                  _hasUnsavedChanges = true;
                });
              },
              onLogoChanged: (url) {
                setState(() {
                  _logoImageUrl = url;
                  _hasUnsavedChanges = true;
                });
              },
            ),
            
            SizedBox(height: 24),
            
            // Basic Information
            _buildSectionTitle("Thông tin cơ bản"),
            SizedBox(height: 16),
            
            _buildTextField(
              controller: _nameController,
              label: "Tên câu lạc bộ",
              hint: "Nhập tên câu lạc bộ",
              icon: Icons.business_outlined,
              required: true,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Vui lòng nhập tên câu lạc bộ';
                }
                return null;
              },
            ),
            
            SizedBox(height: 16),
            
            _buildTextField(
              controller: _usernameController,
              label: "Tên người dùng",
              hint: "username_club",
              icon: Icons.alternate_email_outlined,
              required: true,
              prefix: "@",
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Vui lòng nhập tên người dùng';
                }
                if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value!)) {
                  return 'Chỉ được sử dụng chữ, số và dấu _';
                }
                return null;
              },
            ),
            
            SizedBox(height: 16),
            
            _buildTextField(
              controller: _descriptionController,
              label: "Mô tả",
              hint: "Mô tả về câu lạc bộ của bạn...",
              icon: Icons.description_outlined,
              maxLines: 4,
              maxLength: 500,
            ),
            
            SizedBox(height: 24),
            
            // Facilities Section
            _buildSectionTitle("Tiện ích"),
            SizedBox(height: 16),
            _buildFacilitiesSelector(),
            
            SizedBox(height: 100), // Space for floating button
          ],
        ),
      ),
    );
  }

  Widget _buildContactTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Thông tin liên hệ"),
          SizedBox(height: 16),
          
          _buildTextField(
            controller: _phoneController,
            label: "Số điện thoại",
            hint: "+84 xxx xxx xxx",
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value?.isNotEmpty ?? false) {
                if (!RegExp(r'^\+?[0-9\s\-\(\)]+$').hasMatch(value!)) {
                  return 'Số điện thoại không hợp lệ';
                }
              }
              return null;
            },
          ),
          
          SizedBox(height: 16),
          
          _buildTextField(
            controller: _emailController,
            label: "Email",
            hint: "contact@club.com",
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value?.isNotEmpty ?? false) {
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                  return 'Email không hợp lệ';
                }
              }
              return null;
            },
          ),
          
          SizedBox(height: 16),
          
          _buildTextField(
            controller: _websiteController,
            label: "Website",
            hint: "https://website.com",
            icon: Icons.language_outlined,
            keyboardType: TextInputType.url,
          ),
          
          SizedBox(height: 24),
          
          _buildSectionTitle("Địa chỉ"),
          SizedBox(height: 16),
          
          _buildTextField(
            controller: _addressController,
            label: "Địa chỉ",
            hint: "Nhập địa chỉ câu lạc bộ",
            icon: Icons.location_on_outlined,
            maxLines: 2,
          ),
          
          SizedBox(height: 16),
          
          // Location Picker
          // LocationPicker - Simplified to basic location display
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.blue[600]),
                    SizedBox(width: 8),
                    Text(
                      "Vị trí club",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  "Lat: ${_location['lat']?.toStringAsFixed(4)}, Lng: ${_location['lng']?.toStringAsFixed(4)}",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    // Simplified: just show current location
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Location picker feature coming soon!")),
                    );
                  },
                  icon: Icon(Icons.edit_location, size: 18),
                  label: Text("Chỉnh sửa vị trí"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildBusinessTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Giờ hoạt động"),
          SizedBox(height: 16),
          
          // OperatingHoursEditor(
          //   initialHours: _operatingHours,
          //   onHoursChanged: (hours) {
          //     setState(() {
          //       _operatingHours = hours;
          //       _hasUnsavedChanges = true;
          //     });
          //   },
          // ),
          Container(
            padding: EdgeInsets.all(16),
            child: Text("Operating Hours Editor - Temporarily Disabled"),
          ),
          
          SizedBox(height: 24),
          
          _buildSectionTitle("Thông tin bàn chơi"),
          SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _minPriceController,
                  label: "Giá từ (VND)",
                  hint: "80000",
                  icon: Icons.attach_money_outlined,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _maxPriceController,
                  label: "Giá đến (VND)",
                  hint: "120000",
                  icon: Icons.attach_money_outlined,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16),
          
          _buildTableTypesSelector(),
          
          SizedBox(height: 16),
          
          _buildNumberSelector(
            title: "Tổng số bàn",
            value: _totalTables,
            onChanged: (value) {
              setState(() {
                _totalTables = value;
                _hasUnsavedChanges = true;
              });
            },
          ),
          
          SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildMediaTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Mạng xã hội"),
          SizedBox(height: 16),
          
          _buildTextField(
            controller: _facebookController,
            label: "Facebook",
            hint: "facebook_username",
            icon: Icons.facebook,
            prefix: "facebook.com/",
          ),
          
          SizedBox(height: 16),
          
          _buildTextField(
            controller: _instagramController,
            label: "Instagram",
            hint: "instagram_username",
            icon: Icons.camera_alt_outlined,
            prefix: "@",
          ),
          
          SizedBox(height: 16),
          
          _buildTextField(
            controller: _tiktokController,
            label: "TikTok",
            hint: "tiktok_username",
            icon: Icons.music_note,
            prefix: "@",
          ),
          
          SizedBox(height: 24),
          
          _buildSectionTitle("Thư viện ảnh"),
          SizedBox(height: 16),
          
          _buildGalleryManager(),
          
          SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.grey[900]!,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? prefix,
    int maxLines = 1,
    int? maxLength,
    bool required = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[900] ?? Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        maxLength: maxLength,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator,
        onChanged: (value) {
          setState(() {
            _hasUnsavedChanges = true;
          });
        },
        decoration: InputDecoration(
          labelText: required ? "$label *" : label,
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.grey[600]!),
          prefixText: prefix,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          labelStyle: TextStyle(color: Colors.grey[600]!),
          hintStyle: TextStyle(color: Colors.grey[400] ?? Colors.grey),
        ),
      ),
    );
  }

  Widget _buildFacilitiesSelector() {
    final allFacilities = [
      "Bàn 8 bi", "Bàn 9 bi", "Bàn Carom", "Bàn Snooker",
      "Cafeteria", "Bãi đỗ xe", "WiFi miễn phí", "Điều hòa",
      "Âm thanh chất lượng", "Livestream", "VIP Rooms", "Tủ đồ"
    ];

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Chọn tiện ích có sẵn",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700]!,
            ),
          ),
          SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: allFacilities.map((facility) {
              final isSelected = _selectedFacilities.contains(facility);
              return FilterChip(
                label: Text(facility),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedFacilities.add(facility);
                    } else {
                      _selectedFacilities.remove(facility);
                    }
                    _hasUnsavedChanges = true;
                  });
                },
                backgroundColor: Colors.white,
                selectedColor: Colors.blue[50],
                checkmarkColor: Colors.blue[600]!,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.blue[600]! : Colors.grey[700]!,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                side: BorderSide(
                  color: isSelected ? Colors.blue[600]! : Colors.grey[300] ?? Colors.grey,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTableTypesSelector() {
    final allTypes = ["Pool", "Carom", "Snooker", "3-Cushion", "English"];

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Loại bàn bi-a",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700]!,
            ),
          ),
          SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: allTypes.map((type) {
              final isSelected = _tableTypes.contains(type);
              return FilterChip(
                label: Text(type),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _tableTypes.add(type);
                    } else {
                      _tableTypes.remove(type);
                    }
                    _hasUnsavedChanges = true;
                  });
                },
                backgroundColor: Colors.white,
                selectedColor: Colors.green[50] ?? Colors.green,
                checkmarkColor: Colors.green[600] ?? Colors.green,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.green[600] ?? Colors.green : Colors.grey[700]!,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                side: BorderSide(
                  color: isSelected ? Colors.green[600] ?? Colors.green : Colors.grey[300] ?? Colors.grey,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberSelector({
    required String title,
    required int value,
    required Function(int) onChanged,
    int min = 1,
    int max = 100,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700]!,
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: value > min ? () => onChanged(value - 1) : null,
                icon: Icon(Icons.remove_circle_outline),
                color: value > min ? Colors.blue[600]! : Colors.grey[400] ?? Colors.grey,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  value.toString(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[600]!,
                  ),
                ),
              ),
              IconButton(
                onPressed: value < max ? () => onChanged(value + 1) : null,
                icon: Icon(Icons.add_circle_outline),
                color: value < max ? Colors.blue[600]! : Colors.grey[400] ?? Colors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryManager() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Ảnh hiện tại",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700]!,
                ),
              ),
              TextButton.icon(
                onPressed: _onAddPhotos,
                icon: Icon(Icons.add_photo_alternate_outlined, size: 20),
                label: Text("Thêm ảnh"),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue[600]!,
                  textStyle: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: 6, // Mock data
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[100] ?? Colors.grey,
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        'https://images.unsplash.com/photo-${1571019613454 + index}?w=200&h=200&fit=crop',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey[200]!,
                          child: Icon(Icons.image, color: Colors.grey[600]!),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _onRemovePhoto(index),
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(12),
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
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _onPreviewPressed,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12),
                side: BorderSide(color: Colors.blue[600]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "Xem trước",
                style: TextStyle(
                  color: Colors.blue[600]!,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading ? null : _onResetPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[600]!,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "Đặt lại",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return FloatingActionButton.extended(
      onPressed: _isLoading ? null : _onSavePressed,
      backgroundColor: Colors.green[600] ?? Colors.green,
      label: _isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Text(
              "Lưu thay đổi",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
      icon: _isLoading
          ? null
          : Icon(Icons.save_outlined, color: Colors.white),
    );
  }

  // Event Handlers
  Future<bool> _onWillPop() async {
    if (_hasUnsavedChanges) {
      return await _showUnsavedDialog() ?? false;
    }
    return true;
  }

  Future<bool?> _showUnsavedDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Thay đổi chưa được lưu"),
        content: Text("Bạn có muốn thoát mà không lưu thay đổi?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text("Ở lại"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text("Thoát"),
          ),
        ],
      ),
    );
  }

  void _onClosePressed() async {
    if (await _onWillPop()) {
      Navigator.of(context).pop();
    }
  }

  void _onSavePressed() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      // Simulate API call
      await Future.delayed(Duration(seconds: 2));

      setState(() {
        _isLoading = false;
        _hasUnsavedChanges = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Đã lưu thành công!"),
          backgroundColor: Colors.green[600] ?? Colors.green,
        ),
      );
    }
  }

  void _onPreviewPressed() {
    // Navigate to preview screen
    print("Preview pressed");
  }

  void _onResetPressed() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Đặt lại thông tin"),
        content: Text("Bạn có chắc chắn muốn đặt lại tất cả thông tin về mặc định?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Hủy"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _initializeFormData();
              setState(() {
                _hasUnsavedChanges = false;
              });
            },
            child: Text("Đặt lại"),
          ),
        ],
      ),
    );
  }

  void _onAddPhotos() {
    print("Add photos pressed");
  }

  void _onRemovePhoto(int index) {
    print("Remove photo at index $index");
  }
}
