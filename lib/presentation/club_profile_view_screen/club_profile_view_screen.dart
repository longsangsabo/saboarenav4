import 'package:flutter/material.dart';
import 'package:sabo_arena/core/app_export.dart';
// import 'package:sabo_arena/widgets/custom_app_bar.dart';
import 'package:sabo_arena/widgets/custom_image_widget.dart';

class ClubProfileViewScreen extends StatefulWidget {
  const ClubProfileViewScreen({super.key});

  @override
  _ClubProfileViewScreenState createState() => _ClubProfileViewScreenState();
}

class _ClubProfileViewScreenState extends State<ClubProfileViewScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _coverAnimation;
  late Animation<double> _contentAnimation;
  late ScrollController _scrollController;
  
  bool _showAppBarTitle = false;
  final double _coverHeight = 280.0;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    _coverAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _contentAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(0.3, 1.0, curve: Curves.easeOut),
    ));

    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    
    _controller.forward();
  }

  void _onScroll() {
    final shouldShowTitle = _scrollController.offset > _coverHeight - 100;
    if (shouldShowTitle != _showAppBarTitle) {
      setState(() {
        _showAppBarTitle = shouldShowTitle;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50] ?? Colors.white,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: AnimatedBuilder(
              animation: _contentAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 50 * (1 - _contentAnimation.value)),
                  child: Opacity(
                    opacity: _contentAnimation.value,
                    child: Column(
                      children: [
                        _buildBasicInfoSection(),
                        _buildStatsSection(),
                        _buildContactInfoSection(),
                        _buildBusinessInfoSection(),
                        _buildFacilitiesSection(),
                        _buildGallerySection(),
                        _buildLocationSection(),
                        SizedBox(height: 100),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: _coverHeight,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white,
      title: AnimatedOpacity(
        opacity: _showAppBarTitle ? 1.0 : 0.0,
        duration: Duration(milliseconds: 200),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(
                'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=100&h=100&fit=crop',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "SABO Arena Central",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[900],
                    ),
                  ),
                  Text(
                    "@saboarena_central",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600] ?? Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.share_outlined, color: Colors.grey[700] ?? Colors.grey),
          onPressed: _onSharePressed,
        ),
        IconButton(
          icon: Icon(Icons.more_vert, color: Colors.grey[700] ?? Colors.grey),
          onPressed: _onMorePressed,
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: AnimatedBuilder(
          animation: _coverAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: 0.8 + (0.2 * _coverAnimation.value),
              child: Opacity(
                opacity: _coverAnimation.value,
                child: _buildCoverSection(),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCoverSection() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Cover Image
        CustomImageWidget(
          imageUrl: 'https://images.unsplash.com/photo-1574631806042-182f10c4a017?w=800&h=400&fit=crop',
          fit: BoxFit.cover,
        ),
        // Gradient Overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.3),
                Colors.black.withOpacity(0.7),
              ],
              stops: [0.0, 0.7, 1.0],
            ),
          ),
        ),
        // Edit Button
        Positioned(
          top: 40,
          right: 16,
          child: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.camera_alt_outlined,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
        // Club Logo and Info
        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: Row(
            children: [
              // Club Logo
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: CustomImageWidget(
                    imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=200&h=200&fit=crop',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 16),
              // Club Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            "SABO Arena Central",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.verified,
                          color: Colors.blue[600] ?? Colors.blue,
                          size: 24,
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      "@saboarena_central",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: Colors.white.withOpacity(0.8),
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            "123 Nguyễn Huệ, Quận 1, TP.HCM",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoSection() {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Thông tin cơ bản",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[900],
                ),
              ),
              IconButton(
                icon: Icon(Icons.edit_outlined, color: Colors.grey[600] ?? Colors.grey),
                onPressed: _onEditBasicInfo,
                iconSize: 20,
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            "Arena bi-a hiện đại với hệ thống thi đấu chuyên nghiệp và không gian rộng rãi. "
            "Chúng tôi cung cấp môi trường tốt nhất cho các tournament và giao lưu bi-a.",
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[700] ?? Colors.grey,
              height: 1.5,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              _buildInfoChip(
                icon: Icons.calendar_today_outlined,
                label: "Thành lập 2020",
                color: Colors.blue[600] ?? Colors.blue,
              ),
              SizedBox(width: 12),
              _buildInfoChip(
                icon: Icons.military_tech_outlined,
                label: "Xếp hạng #12",
                color: Colors.purple[600] ?? Colors.purple,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              title: "Thành viên",
              value: "156",
              icon: Icons.people_outline,
              color: Colors.green[600] ?? Colors.green,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              title: "Giải đấu",
              value: "24",
              icon: Icons.emoji_events_outlined,
              color: Colors.orange[600] ?? Colors.orange,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              title: "Bàn bi-a",
              value: "20",
              icon: Icons.table_restaurant_outlined,
              color: Colors.blue[600] ?? Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoSection() {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Liên hệ",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[900],
            ),
          ),
          SizedBox(height: 20),
          _buildContactItem(
            icon: Icons.phone_outlined,
            title: "Điện thoại",
            value: "+84 28 3944 5678",
            onTap: () => _onCallPressed("+84283944567"),
          ),
          _buildContactItem(
            icon: Icons.email_outlined,
            title: "Email",
            value: "contact@saboarena.vn",
            onTap: () => _onEmailPressed("contact@saboarena.vn"),
          ),
          _buildContactItem(
            icon: Icons.language_outlined,
            title: "Website",
            value: "https://saboarena.vn",
            onTap: () => _onWebsitePressed("https://saboarena.vn"),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Text(
                "Mạng xã hội:",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700] ?? Colors.grey,
                ),
              ),
              SizedBox(width: 16),
              _buildSocialButton(Icons.facebook, Colors.blue[600] ?? Colors.blue),
              SizedBox(width: 8),
              _buildSocialButton(Icons.camera_alt, Colors.pink[600] ?? Colors.pink),
              SizedBox(width: 8),
              _buildSocialButton(Icons.music_note, Colors.grey[900] ?? Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessInfoSection() {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Thông tin kinh doanh",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[900],
            ),
          ),
          SizedBox(height: 20),
          _buildBusinessItem(
            icon: Icons.access_time_outlined,
            title: "Giờ hoạt động",
            value: "08:00 - 24:00 (Hàng ngày)",
          ),
          _buildBusinessItem(
            icon: Icons.attach_money_outlined,
            title: "Giá thuê bàn",
            value: "80,000 - 120,000 VND/giờ",
          ),
          _buildBusinessItem(
            icon: Icons.table_restaurant_outlined,
            title: "Số bàn",
            value: "20 bàn (Pool + Carom + Snooker)",
          ),
        ],
      ),
    );
  }

  Widget _buildFacilitiesSection() {
    final facilities = [
      "Bàn 8 bi", "Bàn 9 bi", "Bàn Carom", "Bàn Snooker",
      "Cafeteria", "Bãi đỗ xe", "WiFi miễn phí", "Điều hòa",
      "Âm thanh chất lượng", "Livestream", "VIP Rooms",
    ];

    return Container(
      margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Tiện ích",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[900],
            ),
          ),
          SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: facilities.map((facility) => _buildFacilityChip(facility)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGallerySection() {
    final galleryImages = [
      'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=300&h=200&fit=crop',
      'https://images.unsplash.com/photo-1594736797933-d0601ba2fe65?w=300&h=200&fit=crop',
      'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=300&h=200&fit=crop',
      'https://images.unsplash.com/photo-1574631806042-182f10c4a017?w=300&h=200&fit=crop',
    ];

    return Container(
      margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Thư viện ảnh",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[900],
                ),
              ),
              TextButton(
                onPressed: _onViewAllPhotos,
                child: Text(
                  "Xem tất cả",
                  style: TextStyle(
                    color: Colors.blue[600] ?? Colors.blue,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
            ),
            itemCount: galleryImages.length,
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CustomImageWidget(
                  imageUrl: galleryImages[index],
                  fit: BoxFit.cover,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Vị trí",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[900],
                ),
              ),
              TextButton(
                onPressed: _onOpenMap,
                child: Text(
                  "Chỉ đường",
                  style: TextStyle(
                    color: Colors.blue[600] ?? Colors.blue,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[200] ?? Colors.grey,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.map_outlined,
                    color: Colors.grey[600] ?? Colors.grey,
                    size: 48,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Bản đồ sẽ được hiển thị ở đây",
                    style: TextStyle(
                      color: Colors.grey[600] ?? Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                color: Colors.grey[600] ?? Colors.grey,
                size: 20,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  "123 Nguyễn Huệ, Phường Bến Nghé, Quận 1, TP. Hồ Chí Minh",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[700] ?? Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _onEditProfile,
      backgroundColor: Colors.blue[600] ?? Colors.blue,
      label: Text(
        "Chỉnh sửa",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      icon: Icon(
        Icons.edit_outlined,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  // Helper Widgets
  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
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
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[900],
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600] ?? Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100] ?? Colors.grey,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.grey[600] ?? Colors.grey, size: 20),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500] ?? Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[900],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.grey[400] ?? Colors.grey,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBusinessItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600] ?? Colors.grey, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700] ?? Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600] ?? Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildFacilityChip(String facility) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: (Colors.blue[200] ?? Colors.blue)),
      ),
      child: Text(
        facility,
        style: TextStyle(
          fontSize: 12,
          color: Colors.blue[700] ?? Colors.blue,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // Event Handlers
  void _onSharePressed() => print('Share pressed');
  void _onMorePressed() => print('More pressed');
  void _onEditBasicInfo() => print('Edit basic info pressed');
  void _onCallPressed(String phone) => print('Call $phone');
  void _onEmailPressed(String email) => print('Email $email');
  void _onWebsitePressed(String website) => print('Open $website');
  void _onViewAllPhotos() => print('View all photos');
  void _onOpenMap() => print('Open map');
  void _onEditProfile() => print('Edit profile pressed');
}
