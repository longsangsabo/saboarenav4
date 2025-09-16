import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../services/tournament_service.dart';
import '../../models/tournament.dart';
import './widgets/tournament_card_widget.dart';
import './widgets/tournament_filter_bottom_sheet.dart';
import './widgets/tournament_search_delegate.dart';

class TournamentListScreen extends StatefulWidget {
  const TournamentListScreen({super.key});

  @override
  State<TournamentListScreen> createState() => _TournamentListScreenState();
}

class _TournamentListScreenState extends State<TournamentListScreen>
    with TickerProviderStateMixin {
  final TournamentService _tournamentService = TournamentService.instance;
  List<Tournament> _tournaments = [];
  bool _isLoading = true;
  String _selectedStatus = 'all';
  String _selectedSkillLevel = 'all';

  @override
  void initState() {
    super.initState();
    _loadTournaments();
  }

  Future<void> _loadTournaments() async {
    try {
      setState(() => _isLoading = true);

      final tournaments = await _tournamentService.getTournaments(
        status: _selectedStatus != 'all' ? _selectedStatus : null,
        skillLevel: _selectedSkillLevel != 'all' ? _selectedSkillLevel : null,
      );

      setState(() {
        _tournaments = tournaments;
        _isLoading = false;
      });
    } catch (error) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi tải giải đấu: $error')));
    }
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => TournamentFilterBottomSheet(
            currentFilters: {
              'status': _selectedStatus,
              'skillLevel': _selectedSkillLevel,
            },
            onFiltersApplied: (filters) {
              setState(() {
                _selectedStatus = filters['status'] ?? 'all';
                _selectedSkillLevel = filters['skillLevel'] ?? 'all';
              });
              _loadTournaments();
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Giải đấu',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            onPressed:
                () => showSearch(
                  context: context,
                  delegate: TournamentSearchDelegate(
                    tournaments:
                        _tournaments
                            .map(
                              (t) => {
                                'title': t.title,
                                'clubName': t.clubName ?? '',
                                'format': t.format ?? '',
                                'coverImage': t.coverImage ?? '',
                                'entryFee': t.entryFee.toString(),
                              },
                            )
                            .toList(),
                    onTournamentSelected: (tournament) {
                      // Handle tournament selection if needed
                    },
                  ),
                ),
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: _showFilterSheet,
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadTournaments,
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _tournaments.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                  padding: EdgeInsets.only(top: 8.h, bottom: 80.h),
                  itemCount: _tournaments.length,
                  itemBuilder: (context, index) {
                    return TournamentCardWidget(
                      tournament: _tournaments[index],
                    );
                  },
                ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 64.sp,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16.h),
            Text(
              'Không tìm thấy giải đấu',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Thử thay đổi bộ lọc hoặc tìm kiếm với từ khóa khác',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton(onPressed: _loadTournaments, child: Text('Tải lại')),
          ],
        ),
      ),
    );
  }
}
