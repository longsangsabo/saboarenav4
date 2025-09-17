import 'package:flutter/material.dart';
// import 'package:sabo_arena/core/app_export.dart';

class LocationPicker extends StatefulWidget {
  final Map<String, double> initialLocation;
  final Function(Map<String, double>) onLocationChanged;

  const LocationPicker({
    super.key,
    required this.initialLocation,
    required this.onLocationChanged,
  });

  @override
  _LocationPickerState createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  Map<String, double> _currentLocation = {};
  bool _isExpanded = false;
  bool _isLoading = false;

  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, dynamic>> _searchResults = [];

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _currentLocation = Map.from(widget.initialLocation);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[900] ?? Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          AnimatedSize(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _isExpanded ? _buildExpandedContent() : _buildCollapsedContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return InkWell(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
        if (_isExpanded) {
          _animationController.forward();
        } else {
          _animationController.reverse();
        }
      },
      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      child: Container(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green[50] ?? Colors.green,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.location_on_outlined,
                color: Colors.green[600] ?? Colors.green,
                size: 20,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Vị trí trên bản đồ",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[900],
                    ),
                  ),
                  Text(
                    _getLocationSummary(),
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedRotation(
              turns: _isExpanded ? 0.5 : 0.0,
              duration: Duration(milliseconds: 300),
              child: Icon(
                Icons.expand_more,
                color: Theme.of(context).colorScheme.onSurface,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollapsedContent() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          Icon(
            Icons.my_location,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            size: 16,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              "Lat: ${_currentLocation['lat']?.toStringAsFixed(4)}, Lng: ${_currentLocation['lng']?.toStringAsFixed(4)}",
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          Text(
            "Nhấn để chỉnh sửa",
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedContent() {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                _buildSearchSection(),
                SizedBox(height: 16),
                _buildMapPreview(),
                SizedBox(height: 16),
                _buildCoordinatesInput(),
                SizedBox(height: 16),
                _buildQuickActions(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchSection() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.12)),
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "Tìm kiếm địa điểm...",
              prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.onSurface),
              suffixIcon: _isLoading 
                  ? Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    )
                  : IconButton(
                      icon: Icon(Icons.clear, color: Theme.of(context).colorScheme.onSurface),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchResults.clear();
                        });
                      },
                    ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: _onSearchChanged,
          ),
          
          if (_searchResults.isNotEmpty) ...[
            Container(
              height: 1,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final result = _searchResults[index];
                return InkWell(
                  onTap: () => _selectSearchResult(result),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Theme.of(context).colorScheme.onSurface,
                          size: 20,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                result['name'],
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[900],
                                ),
                              ),
                              Text(
                                result['address'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMapPreview() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300] ?? Colors.grey),
        color: Theme.of(context).colorScheme.surfaceVariant,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Map placeholder with pattern
            Container(
              decoration: BoxDecoration(
                color: Colors.blue[50],
                image: DecorationImage(
                  image: AssetImage('assets/images/map_pattern.png'),
                  repeat: ImageRepeat.repeat,
                  opacity: 0.1,
                ),
              ),
            ),
            
            // Center marker
            Center(
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.error.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.location_on,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            
            // Coordinates overlay
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${_currentLocation['lat']?.toStringAsFixed(4)}, ${_currentLocation['lng']?.toStringAsFixed(4)}",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            
            // Tap to select overlay
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _onMapTapped,
                  child: Container(
                    alignment: Alignment.bottomCenter,
                    padding: EdgeInsets.all(16),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.touch_app,
                            color: Colors.white,
                            size: 16,
                          ),
                          SizedBox(width: 6),
                          Text(
                            "Nhấn để chọn vị trí",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoordinatesInput() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Tọa độ chính xác",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildCoordinateField(
                  "Vĩ độ",
                  _currentLocation['lat']?.toString() ?? "0.0",
                  (value) => _updateCoordinate('lat', value),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildCoordinateField(
                  "Kinh độ",
                  _currentLocation['lng']?.toString() ?? "0.0",
                  (value) => _updateCoordinate('lng', value),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCoordinateField(String label, String value, Function(double) onChanged) {
    final controller = TextEditingController(text: value);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey[300] ?? Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey[300] ?? Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            isDense: true,
          ),
          onChanged: (text) {
            final doubleValue = double.tryParse(text);
            if (doubleValue != null) {
              onChanged(doubleValue);
            }
          },
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            "Vị trí hiện tại",
            Icons.my_location,
            _getCurrentLocation,
            Colors.green[600] ?? Colors.green,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            "Đặt lại",
            Icons.refresh,
            _resetLocation,
            Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onPressed, Color color) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color),
        padding: EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }

  String _getLocationSummary() {
    if (_currentLocation['lat'] == 0.0 && _currentLocation['lng'] == 0.0) {
      return "Chưa thiết lập vị trí";
    }
    return "Đã thiết lập tọa độ";
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults.clear();
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate search API call
    Future.delayed(Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _searchResults.clear();
          _searchResults.addAll(_getMockSearchResults(query));
        });
      }
    });
  }

  List<Map<String, dynamic>> _getMockSearchResults(String query) {
    // Mock search results for demonstration
    return [
      {
        'name': 'SABO Arena Central',
        'address': '123 Nguyễn Huệ, Quận 1, TP.HCM',
        'lat': 10.7769,
        'lng': 106.7009,
      },
      {
        'name': 'Bitexco Financial Tower',
        'address': '2 Hải Triều, Quận 1, TP.HCM',
        'lat': 10.7718,
        'lng': 106.7032,
      },
      {
        'name': 'Landmark 81',
        'address': '720A Điện Biên Phủ, Quận Bình Thạnh, TP.HCM',
        'lat': 10.7954,
        'lng': 106.7218,
      },
    ].where((item) => 
      (item['name'] as String?)?.toLowerCase().contains(query.toLowerCase()) ?? false ||
  (((item['address'] as String?) ?? '').toLowerCase()).contains(query.toLowerCase())
    ).take(3).toList();
  }

  void _selectSearchResult(Map<String, dynamic> result) {
    setState(() {
      _currentLocation = {
        'lat': result['lat'],
        'lng': result['lng'],
      };
      _searchController.clear();
      _searchResults.clear();
    });
    widget.onLocationChanged(_currentLocation);
  }

  void _updateCoordinate(String key, double value) {
    setState(() {
      _currentLocation[key] = value;
    });
    widget.onLocationChanged(_currentLocation);
  }

  void _onMapTapped() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Chọn vị trí trên bản đồ"),
        content: Text("Tính năng này sẽ mở bản đồ tương tác để bạn có thể chọn vị trí chính xác."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Đóng"),
          ),
        ],
      ),
    );
  }

  void _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate getting current location
    await Future.delayed(Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isLoading = false;
        _currentLocation = {
          'lat': 10.7769 + ((-1 + 2 * (DateTime.now().millisecond / 1000)) * 0.01),
          'lng': 106.7009 + ((-1 + 2 * (DateTime.now().microsecond / 1000000)) * 0.01),
        };
      });
      widget.onLocationChanged(_currentLocation);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Đã cập nhật vị trí hiện tại"),
          backgroundColor: Colors.green[600] ?? Colors.green,
        ),
      );
    }
  }

  void _resetLocation() {
    setState(() {
      _currentLocation = Map.from(widget.initialLocation);
    });
    widget.onLocationChanged(_currentLocation);
  }
}
