import 'package:flutter/material.dart';

import '../../models/club.dart';
import '../../services/club_service.dart';
import 'widgets/horizontal_club_list.dart';
import 'widgets/club_detail_section.dart';

class ClubMainScreen extends StatefulWidget {
  const ClubMainScreen({super.key});

  @override
  State<ClubMainScreen> createState() => _ClubMainScreenState();
}

class _ClubMainScreenState extends State<ClubMainScreen> {
  Club? _selectedClub;
  List<Club> _clubs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClubs();
  }

  void _loadClubs() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load clubs from Supabase
      final clubs = await ClubService.instance.getClubs(limit: 10);
      
      setState(() {
        _clubs = clubs;
        _selectedClub = clubs.isNotEmpty ? clubs.first : null;
        _isLoading = false;
      });
    } catch (error) {
      // If Supabase fails, fallback to mock data
      debugPrint('Error loading clubs from Supabase: $error');
      setState(() {
        _clubs = _getMockClubs();
        _selectedClub = _clubs.isNotEmpty ? _clubs.first : null;
        _isLoading = false;
      });
    }
  }

  void _onClubSelected(Club club) {
    setState(() {
      _selectedClub = club;
    });
  }

  void _handleBottomNavTap(String route) {
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Câu lạc bộ',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Top section: Horizontal Club List (1/3 screen)
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.25,
                  child: HorizontalClubList(
                    clubs: _clubs,
                    selectedClub: _selectedClub,
                    onClubSelected: _onClubSelected,
                  ),
                ),

                // Divider
                Container(
                  height: 1,
                  color: colorScheme.outline.withOpacity(0.2),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                ),

                // Bottom section: Club Detail (2/3 screen)
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.1, 0),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeInOut,
                          )),
                          child: child,
                        ),
                      );
                    },
                    child: _selectedClub != null
                        ? ClubDetailSection(
                            key: ValueKey(_selectedClub!.id),
                            club: _selectedClub!,
                          )
                        : Center(
                            key: const ValueKey('empty'),
                            child: Text(
                              'Chọn một câu lạc bộ để xem chi tiết',
                              style: TextStyle(
                                fontSize: 16,
                                color: colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(
                color: Colors.grey.withOpacity(0.2),
                width: 1,
              ),
            ),
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: 3, // Club tab
            selectedItemColor: Colors.green,
            unselectedItemColor: Colors.grey,
            backgroundColor: Colors.white,
            elevation: 0,
            onTap: (index) {
              switch (index) {
                case 0:
                  _handleBottomNavTap('/home');
                  break;
                case 1:
                  _handleBottomNavTap('/find-opponents');
                  break;
                case 2:
                  _handleBottomNavTap('/tournaments');
                  break;
                case 3:
                  // Already on club
                  break;
                case 4:
                  _handleBottomNavTap('/profile');
                  break;
              }
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Trang chủ',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people_outline),
                activeIcon: Icon(Icons.people),
                label: 'Đối thủ',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.emoji_events_outlined),
                activeIcon: Icon(Icons.emoji_events),
                label: 'Giải đấu',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.business_outlined),
                activeIcon: Icon(Icons.business),
                label: 'Câu lạc bộ',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Cá nhân',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Mock data for testing
  List<Club> _getMockClubs() {
    return [
      Club(
        id: '1',
        ownerId: 'owner1',
        name: 'Billiards Club Sài Gòn',
        description: 'Câu lạc bộ billiards hàng đầu tại Sài Gòn với hơn 20 năm kinh nghiệm.',
        address: '123 Nguyễn Huệ, Phường Bến Nghé, Quận 1, TP. Hồ Chí Minh',
        phone: '0901234567',
        email: 'contact@billiardsclubsg.com',
        coverImageUrl: 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?fm=jpg&q=60&w=3000',
        profileImageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?fm=jpg&q=60&w=3000',
        totalTables: 30,
        isVerified: true,
        isActive: true,
        rating: 4.8,
        totalReviews: 234,
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
        updatedAt: DateTime.now(),
      ),
      Club(
        id: '2',
        ownerId: 'owner2',
        name: 'Pool Center Hà Nội',
        description: 'Trung tâm bi-a hiện đại với không gian rộng rãi và thoáng mát.',
        address: '456 Hoàng Diệu, Ba Đình, Hà Nội',
        phone: '0912345678',
        email: 'info@poolcenterhn.com',
        coverImageUrl: 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?fm=jpg&q=60&w=3000',
        profileImageUrl: 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?fm=jpg&q=60&w=3000',
        totalTables: 25,
        isVerified: true,
        isActive: true,
        rating: 4.6,
        totalReviews: 189,
        createdAt: DateTime.now().subtract(const Duration(days: 200)),
        updatedAt: DateTime.now(),
      ),
      Club(
        id: '3',
        ownerId: 'owner3',
        name: 'Elite Billiards Đà Nẵng',
        description: 'Câu lạc bộ cao cấp dành cho những người yêu thích billiards.',
        address: '789 Trần Phú, Hải Châu, Đà Nẵng',
        phone: '0923456789',
        email: 'contact@elitebilliardsdn.com',
        coverImageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?fm=jpg&q=60&w=3000',
        profileImageUrl: 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?fm=jpg&q=60&w=3000',
        totalTables: 20,
        isVerified: true,
        isActive: true,
        rating: 4.9,
        totalReviews: 156,
        createdAt: DateTime.now().subtract(const Duration(days: 150)),
        updatedAt: DateTime.now(),
      ),
    ];
  }
}