import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:sabo_arena/core/app_export.dart';
import 'package:sabo_arena/theme/app_theme.dart';
import 'package:sabo_arena/services/tournament_service.dart';
import 'package:sabo_arena/services/cached_tournament_service.dart';
import 'package:sabo_arena/services/tournament_progression_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Safe debug print wrapper to avoid null debug service errors
void _safeDebugPrint(String message) {
  try {
    debugPrint(message);
  } catch (e) {
    // Ignore debug service errors in production
    print(message);
  }
}

class MatchManagementTab extends StatefulWidget {
  final String tournamentId;
  final VoidCallback? onMatchScoreUpdated;

  const MatchManagementTab({
    super.key, 
    required this.tournamentId,
    this.onMatchScoreUpdated,
  });

  @override
  _MatchManagementTabState createState() => _MatchManagementTabState();
}

class _MatchManagementTabState extends State<MatchManagementTab> {
  final TournamentService _tournamentService = TournamentService.instance;
  
  List<Map<String, dynamic>> _matches = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedFilter = 'all'; // all, pending, in_progress, completed
  int? _selectedRound; // null = show all, specific number = filter by round_number
  int _totalParticipants = 0; // Dynamic participant count

  // Dynamic round name calculation based on participants
  String _getRoundName(int roundNumber, int totalParticipants) {
    // Special handling for SABO DE16 format (31 matches, complex structure)
    if (totalParticipants == 16) {
      switch (roundNumber) {
        case 1: return 'VÒNG 1';
        case 2: return 'VÒNG 2'; 
        case 3: return 'VÒNG 3';
        case 4: return 'VÒNG 4';
        case 101: return 'BẢNG THUA A1';
        case 102: return 'BẢNG THUA A2';
        case 103: return 'BẢNG THUA A3';
        case 104: return 'BẢNG THUA A4';
        case 201: return 'BẢNG THUA B1';
        case 202: return 'BẢNG THUA B2';
        case 250: return 'BÁN KẾT';
        case 251: return 'BÁN KẾT 2';
        case 999: return 'CHUNG KẾT';
        default: return 'VÒNG $roundNumber';
      }
    }

    // Special handling for SABO DE32 format (55 matches, two-group structure)
    if (totalParticipants == 32) {
      switch (roundNumber) {
        case 1: return 'VÒNG 1';
        case 2: return 'VÒNG 2'; 
        case 3: return 'VÒNG 3';
        case 4: return 'VÒNG 4';
        case 101: return 'BẢNG THUA 1';
        case 102: return 'BẢNG THUA 2';
        case 103: return 'BẢNG THUA 3';
        case 104: return 'BẢNG THUA 4';
        case 105: return 'BẢNG THUA 5';
        case 106: return 'BẢNG THUA 6';
        case 400: return 'BÁN KẾT 1';
        case 401: return 'BÁN KẾT 2';
        case 500: return 'CHUNG KẾT';
        default: return 'VÒNG $roundNumber';
      }
    }
    
    // Calculate players remaining after this round for standard formats
    int divisor = (1 << roundNumber);
    if (divisor == 0 || totalParticipants == 0) {
      return 'VÒNG $roundNumber';
    }
    
    int playersAfterRound = totalParticipants ~/ divisor;
    
    switch (playersAfterRound) {
      case 1:
        return 'CHUNG KẾT';
      case 2:
        return 'BÁN KẾT';
      case 4:
        return 'TỨ KẾT';
      case 8:
        return 'VÒNG 1/8';
      case 16:
        return 'VÒNG 1/16';
      case 32:
        return 'VÒNG 1/32';
      default:
        if (roundNumber == 1) {
          return 'VÒNG 1';
        }
        return 'VÒNG $roundNumber';
    }
  }

  // Get available rounds for this tournament
  List<Map<String, dynamic>> _getAvailableRounds() {
    if (_matches.isEmpty) return [];
    
    // Get unique rounds from matches
    Set<int> uniqueRounds = _matches.map((m) => (m['round'] ?? m['round_number'] ?? 1) as int).toSet();
    List<int> sortedRounds = uniqueRounds.toList()..sort();
    
    // If _totalParticipants not available, estimate from matches
    int participantCount = _totalParticipants;
    if (participantCount == 0) {
      // Count unique player IDs in first round (Winner Bracket R1)
      Set<String> firstRoundPlayers = {};
      for (var match in _matches) {
        if ((match['round'] ?? match['round_number'] ?? 1) == 1) {
          if (match['player1_id'] != null) firstRoundPlayers.add(match['player1_id']);
          if (match['player2_id'] != null) firstRoundPlayers.add(match['player2_id']);
        }
      }
      participantCount = firstRoundPlayers.length;
      if (participantCount == 0) {
        // Fallback: estimate from match count (R1 matches = participants / 2)
        int r1Matches = _matches.where((m) => (m['round'] ?? m['round_number'] ?? 1) == 1).length;
        participantCount = r1Matches * 2;
      }
    }
    
    return sortedRounds.map((round) => {
      'round': round,
      'name': _getRoundName(round, participantCount),
      'matches': _matches.where((m) => (m['round'] ?? m['round_number'] ?? 1) == round).length,
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  Future<void> _loadMatches() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      _safeDebugPrint('🔄 MatchManagementTab: Loading matches for tournament ${widget.tournamentId}');
      
      // Load participants count for dynamic round calculation
      List<Map<String, dynamic>> participants = [];
      try {
        participants = await _tournamentService.getTournamentParticipantsWithPaymentStatus(widget.tournamentId);
        _totalParticipants = participants.length;
        _safeDebugPrint('👥 MatchManagementTab: Loaded $_totalParticipants participants');
      } catch (e) {
        _safeDebugPrint('⚠️ Failed to load participants: $e');
        _totalParticipants = 0;
      }
      
      // Try to load matches with better error handling
      List<Map<String, dynamic>> matches = [];
      String? loadError;
      
      // Use enhanced tournament service that includes user profiles
      try {
        matches = await _tournamentService.getTournamentMatches(widget.tournamentId);
        _safeDebugPrint('📋 Loaded ${matches.length} matches from enhanced service with user profiles');
      } catch (serviceError) {
        _safeDebugPrint('⚠️ Enhanced service failed: $serviceError');
        loadError = serviceError.toString();
        
        // Fallback to cached service (raw data only)
        try {
          matches = await CachedTournamentService.loadMatches(widget.tournamentId, forceRefresh: true);
          _safeDebugPrint('📋 Loaded ${matches.length} matches from cache/service (fallback)');
          loadError = null; // Clear error if cache works
        } catch (cacheError) {
          _safeDebugPrint('❌ Cache service also failed: $cacheError');
          loadError = 'Không thể tải trận đấu: ${cacheError.toString()}';
        }
      }
      
      // If we have matches, use them even if there were some errors
      if (matches.isNotEmpty) {
        setState(() {
          _matches = matches;
          _isLoading = false;
          _errorMessage = null; // Clear any previous errors
        });
        
        _safeDebugPrint('📊 MatchManagementTab: Successfully loaded ${matches.length} matches');
        if (matches.isNotEmpty) {
          final firstMatch = matches.first;
          _safeDebugPrint('🎯 MatchManagementTab: First match data:');
          _safeDebugPrint('   matchId: ${firstMatch['matchId']}');
          _safeDebugPrint('   player1: ${firstMatch['player1']}');
          _safeDebugPrint('   player2: ${firstMatch['player2']}');
        }
      } else if (loadError != null) {
        // Only show error if we have no matches and there's an error
        setState(() {
          _matches = [];
          _isLoading = false;
          _errorMessage = loadError;
        });
      } else {
        // No matches but no error - empty tournament
        setState(() {
          _matches = [];
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      _safeDebugPrint('❌ MatchManagementTab: Critical error loading matches: $e');
      setState(() {
        _errorMessage = 'Lỗi tải dữ liệu: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  // Method to manually refresh matches
  Future<void> _refreshMatches() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    _safeDebugPrint('🔄 Manual refresh triggered for tournament ${widget.tournamentId}');
    
    try {
      await _loadMatches();
      
      // Show success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Đã làm mới dữ liệu trận đấu'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // Show error feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Lỗi khi làm mới: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  List<Map<String, dynamic>> get _filteredMatches {
    var filtered = _matches;
    
    // First filter by round if selected
    if (_selectedRound != null) {
      filtered = filtered.where((m) => m['round_number'] == _selectedRound).toList();
    }
    
    // Then filter by status
    switch (_selectedFilter) {
      case 'pending':
        return filtered.where((m) => m['status'] == 'pending').toList();
      case 'in_progress':
        return filtered.where((m) => m['status'] == 'in_progress').toList();
      case 'completed':
        return filtered.where((m) => m['status'] == 'completed').toList();
      default:
        return filtered;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16.sp),
            Text('Đang tải trận đấu...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 40.sp, color: AppTheme.errorLight),
            SizedBox(height: 10.sp),
            Text("Lỗi tải dữ liệu", 
                 style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600)),
            SizedBox(height: 4.sp),
            Text(_errorMessage!, 
                 textAlign: TextAlign.center,
                 style: TextStyle(fontSize: 11.sp, color: Colors.grey[600])),
            SizedBox(height: 12.sp),
            ElevatedButton(
              onPressed: _loadMatches,
              child: Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_matches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sports_esports, size: 40.sp, color: AppTheme.dividerLight),
            SizedBox(height: 10.sp),
            Text("Chưa có trận đấu nào", 
                 style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600)),
            SizedBox(height: 4.sp),
            Text("Tạo bảng đấu để bắt đầu các trận đấu",
                 style: TextStyle(fontSize: 11.sp, color: Colors.grey[600])),
            SizedBox(height: 16.sp),
            ElevatedButton.icon(
              onPressed: _refreshMatches,
              icon: Icon(Icons.refresh, size: 16.sp),
              label: Text("Làm mới", style: TextStyle(fontSize: 12.sp)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 8.sp),
              ),
            ),
          ],
        ),
      );
    }

    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverAppBar(
            expandedHeight: 95.sp, // Tăng để chứa 2 rows filter
            floating: false,
            pinned: false,
            snap: false,
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                onPressed: _isLoading ? null : _refreshMatches,
                icon: Icon(Icons.refresh, color: Colors.blue),
                tooltip: 'Làm mới dữ liệu',
              ),
              SizedBox(width: 8.sp),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 1.sp),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                    // Row 1: Filter theo trạng thái
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatColumn('Tổng cộng', _matches.length.toString(), 'all'),
                        _buildStatColumn('Chờ đấu', 
                          _matches.where((m) => m['status'] == 'pending').length.toString(), 
                          'pending'),
                        _buildStatColumn('Đang đấu', 
                          _matches.where((m) => m['status'] == 'in_progress').length.toString(), 
                          'in_progress'),
                        _buildStatColumn('Hoàn thành', 
                          _matches.where((m) => m['status'] == 'completed').length.toString(), 
                          'completed'),
                      ],
                    ),
                    // Row 2: Dynamic round filters based on actual tournament data  
                    if (_totalParticipants > 0) ...[
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _getAvailableRounds().map((roundData) => 
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 2.sp),
                              child: _buildRoundFilterButton(
                                roundData['name'], 
                                roundData['matches'].toString(), 
                                roundData['round'], // Pass round number instead of string
                              ),
                            )
                          ).toList(),
                        ),
                      ),
                    ] else ...[
                      // Fallback for when participant data isn't loaded yet
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildRoundFilterColumn('VÒNG 1', 
                            _matches.where((m) => (m['round'] ?? m['round_number'] ?? 1) == 1).length.toString(), 
                            'round1'),
                          _buildRoundFilterColumn('VÒNG 2', 
                            _matches.where((m) => (m['round'] ?? m['round_number'] ?? 1) == 2).length.toString(), 
                            'round2'),
                          _buildRoundFilterColumn('VÒNG 3', 
                            _matches.where((m) => (m['round'] ?? m['round_number'] ?? 1) == 3).length.toString(), 
                            'round3'),
                          _buildRoundFilterColumn('VÒNG 4', 
                            _matches.where((m) => (m['round'] ?? m['round_number'] ?? 1) == 4).length.toString(), 
                            'round4'),
                        ],
                      ),
                    ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ];
      },
      body: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 12.sp),
        itemCount: _filteredMatches.length,
        itemBuilder: (context, index) {
          return _buildMatchCard(_filteredMatches[index]);
        },
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, String filter) {
    bool isSelected = _selectedFilter == filter;
    
    return InkWell(
      onTap: () => setState(() => _selectedFilter = filter),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 1.sp, horizontal: 4.sp), // Reduced vertical padding
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryLight.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8.sp),
          border: Border.all(
            color: isSelected ? AppTheme.primaryLight : Colors.transparent,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value, 
                 style: TextStyle(
                   fontSize: 12.sp, // Giảm từ 14.sp
                   fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                   color: isSelected ? AppTheme.primaryLight : Colors.black,
                 )),
            Text(label, 
                 textAlign: TextAlign.center,
                 style: TextStyle(
                   fontSize: 8.sp, // Giảm từ 9.sp
                   color: isSelected ? AppTheme.primaryLight : Colors.grey[600],
                 )),
          ],
        ),
      ),
    );
  }

  // Build round filter button with round_number filtering
  Widget _buildRoundFilterButton(String label, String value, int roundNumber) {
    bool isSelected = _selectedRound == roundNumber;
    
    return InkWell(
      onTap: () => setState(() {
        _selectedRound = isSelected ? null : roundNumber; // Toggle: click again to show all
        _selectedFilter = 'all'; // Reset status filter when changing rounds
      }),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2.sp, horizontal: 4.sp),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryDark.withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(6.sp),
          border: Border.all(
            color: isSelected ? AppTheme.primaryDark : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, 
                 textAlign: TextAlign.center,
                 style: TextStyle(
                   fontSize: 7.sp,
                   fontWeight: FontWeight.bold,
                   color: isSelected ? AppTheme.primaryDark : Colors.grey[700],
                 )),
            Text(value, 
                 style: TextStyle(
                   fontSize: 10.sp,
                   fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                   color: isSelected ? AppTheme.primaryDark : AppTheme.primaryLight,
                 )),
          ],
        ),
      ),
    );
  }

  // Legacy: Build round filter column with old string-based filtering (for fallback)
  Widget _buildRoundFilterColumn(String label, String value, String filter) {
    bool isSelected = _selectedFilter == filter;
    
    return InkWell(
      onTap: () => setState(() => _selectedFilter = filter),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2.sp, horizontal: 4.sp),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryDark.withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(6.sp),
          border: Border.all(
            color: isSelected ? AppTheme.primaryDark : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, 
                 textAlign: TextAlign.center,
                 style: TextStyle(
                   fontSize: 7.sp,
                   fontWeight: FontWeight.bold,
                   color: isSelected ? AppTheme.primaryDark : Colors.grey[700],
                 )),
            Text(value, 
                 style: TextStyle(
                   fontSize: 10.sp,
                   fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                   color: isSelected ? AppTheme.primaryDark : AppTheme.primaryLight,
                 )),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchCard(Map<String, dynamic> match) {
    final status = match['status'] ?? 'pending';
    
    // Use actual round_number and match_number from database
    int roundNumber = match['round_number'] ?? match['round'] ?? 1;
    int matchNumber = match['match_number'] ?? 1;
    
    // Debug output for verification - use both id and matchId for compatibility
    final matchId = match['id'] ?? match['matchId'];
    debugPrint('🔢 Match ID: $matchId -> R${roundNumber}M$matchNumber (from DB)');
    
    final player1Score = match['player1_score'] ?? 0;
    final player2Score = match['player2_score'] ?? 0;
    
    // Auto update status if both players are available but status is still pending
    String actualStatus = status;
    final hasPlayer1 = match['player1'] != null;
    final hasPlayer2 = match['player2'] != null;
    
    if (status == 'pending' && hasPlayer1 && hasPlayer2) {
      actualStatus = 'in_progress';
      // Update the match status in the backend - use compatible ID field
      final matchId = match['id'] ?? match['matchId'];
      if (matchId != null) {
        _autoUpdateMatchStatus(matchId, 'in_progress');
      }
    }

    return InkWell(
      onTap: () {
        if (actualStatus == 'completed') {
          _editCompletedMatch(match);
        } else {
          _enterScore(match);
        }
      },
      borderRadius: BorderRadius.circular(12.sp),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.sp),
        padding: EdgeInsets.all(16.sp),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.sp),
          border: Border.all(color: AppTheme.dividerLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with match code and next match progression
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Display match progression from database
                Flexible(
                  child: Text(
                    _buildMatchProgressionText(match),
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryLight,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8.sp),
                _buildMatchStatusBadge(actualStatus),
              ],
            ),
            SizedBox(height: 12.sp),
            
            // Players in single rows
            _buildCompactPlayerRow(match['player1'], player1Score, match['winner'] == 'player1', match, 'player1'),
            SizedBox(height: 8.sp),
            _buildCompactPlayerRow(match['player2'], player2Score, match['winner'] == 'player2', match, 'player2'),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactPlayerRow(dynamic player, int score, bool isWinner, Map<String, dynamic> match, String playerType) {
    // Get player name from different possible data structures
    String playerName = 'TBD';
    if (player != null) {
      if (player is Map<String, dynamic>) {
        playerName = player['name'] ?? player['full_name'] ?? player['display_name'] ?? 'Unknown Player';
      } else if (player is String) {
        playerName = player.isNotEmpty ? player : 'TBD';
      }
    }
    
    if (player == null || playerName == 'TBD') {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 8.sp),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8.sp),
          border: Border.all(color: AppTheme.dividerLight),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 12.sp,
              backgroundColor: Colors.grey[300],
              child: Icon(Icons.person, size: 12.sp, color: Colors.grey[600]),
            ),
            SizedBox(width: 8.sp),
            Text(
              'TBD',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[600],
              ),
            ),
            Spacer(),
            GestureDetector(
              onTap: () => _enterScore(match),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 4.sp),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4.sp),
                ),
                child: Text(
                  '0',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () => _enterScore(match),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 8.sp),
        decoration: BoxDecoration(
          color: isWinner ? AppTheme.successLight.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(8.sp),
          border: Border.all(
            color: isWinner ? AppTheme.successLight : AppTheme.dividerLight,
            width: isWinner ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 12.sp,
              backgroundImage: NetworkImage(
                player['avatar'] ?? 'https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png'
              ),
            ),
            SizedBox(width: 8.sp),
            // Player name with winner icon
            Expanded(
              child: Row(
                children: [
                  Text(
                    playerName,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: isWinner ? FontWeight.bold : FontWeight.w500,
                      color: isWinner ? AppTheme.successDark : Colors.black87,
                    ),
                  ),
                  if (isWinner) ...[
                    SizedBox(width: 4.sp),
                    Icon(
                      Icons.emoji_events,
                      color: AppTheme.successLight,
                      size: 12.sp,
                    ),
                  ],
                ],
              ),
            ),
            // Score (clickable)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 4.sp),
              decoration: BoxDecoration(
                color: isWinner ? AppTheme.successLight.withOpacity(0.2) : AppTheme.primaryLight.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4.sp),
              ),
              child: Text(
                score.toString(),
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: isWinner ? AppTheme.successDark : AppTheme.primaryLight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchStatusBadge(String status) {
    Color backgroundColor;
    Color textColor;
    String text;

    switch (status) {
      case 'pending':
        backgroundColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange;
        text = 'Chờ đấu';
        break;
      case 'in_progress':
        backgroundColor = Colors.blue.withOpacity(0.1);
        textColor = Colors.blue;
        text = 'Đang đấu';
        break;
      case 'completed':
        backgroundColor = AppTheme.successLight.withOpacity(0.1);
        textColor = AppTheme.successLight;
        text = 'Hoàn thành';
        break;
      default:
        backgroundColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey;
        text = status.toUpperCase();
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 4.sp),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.sp),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  void _enterScore(Map<String, dynamic> match) async {
    debugPrint('🎯 Enter score clicked for match: ${match['matchId'] ?? match['id']}');
    
    // Get player names using same logic as _buildCompactPlayerRow
    String player1Name = 'Player 1';
    String player2Name = 'Player 2';
    
    if (match['player1'] != null) {
      if (match['player1'] is Map<String, dynamic>) {
        player1Name = match['player1']['name'] ?? match['player1']['full_name'] ?? match['player1']['display_name'] ?? 'Player 1';
      } else if (match['player1'] is String) {
        player1Name = match['player1'].isNotEmpty ? match['player1'] : 'Player 1';
      }
    }
    
    if (match['player2'] != null) {
      if (match['player2'] is Map<String, dynamic>) {
        player2Name = match['player2']['name'] ?? match['player2']['full_name'] ?? match['player2']['display_name'] ?? 'Player 2';
      } else if (match['player2'] is String) {
        player2Name = match['player2'].isNotEmpty ? match['player2'] : 'Player 2';
      }
    }
    
    final TextEditingController player1Controller = TextEditingController();
    final TextEditingController player2Controller = TextEditingController();
    
    // Pre-fill current scores
    player1Controller.text = (match['player1_score'] ?? 0).toString();
    player2Controller.text = (match['player2_score'] ?? 0).toString();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Nhập tỷ số trận đấu',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Player 1 score input with +/- buttons
              _buildScoreInputRow(player1Name, player1Controller),
              SizedBox(height: 16.sp),
              // Player 2 score input with +/- buttons
              _buildScoreInputRow(player2Name, player2Controller),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                final p1Score = int.tryParse(player1Controller.text) ?? 0;
                final p2Score = int.tryParse(player2Controller.text) ?? 0;
                
                await _updateMatchScore(match, p1Score, p2Score);
                Navigator.of(context).pop();
              },
              child: Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateMatchScore(Map<String, dynamic> match, int player1Score, int player2Score) async {
    try {
      final matchId = match['id'] ?? match['matchId'];
      String winnerId = '';
      String status = 'completed';
      
      // Determine winner based on scores
      if (player1Score > player2Score) {
        winnerId = match['player1_id'] ?? '';
        debugPrint('🏆 Player 1 wins: ${winnerId.length > 8 ? winnerId.substring(0, 8) : winnerId}');
      } else if (player2Score > player1Score) {
        winnerId = match['player2_id'] ?? '';
        debugPrint('🏆 Player 2 wins: ${winnerId.length > 8 ? winnerId.substring(0, 8) : winnerId}');
      } else {
        debugPrint('🤝 Match tied - no winner');
      }
      
      // Validate winner_id
      if (winnerId.isEmpty && player1Score != player2Score) {
        debugPrint('⚠️ Warning: No winner_id despite different scores!');
      }
      
      // Update in database (with silent caching)
      debugPrint('💾 Updating match: P1=$player1Score, P2=$player2Score, Winner=${winnerId.isEmpty ? 'None' : (winnerId.length > 8 ? winnerId.substring(0, 8) : winnerId)}, Status=$status');
      
      try {
        // ⚡ CRITICAL FIX: Always update directly to database first
        // This ensures data is persisted before cache update
        debugPrint('💾 Updating database directly with scores: P1=$player1Score, P2=$player2Score');
        
        await Supabase.instance.client
            .from('matches')
            .update({
              'player1_score': player1Score,
              'player2_score': player2Score,
              'winner_id': winnerId.isEmpty ? null : winnerId,
              'status': status,
              // 'completed_at': status == 'completed' ? DateTime.now().toIso8601String() : null, // TODO: Add column to database
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', matchId);
        
        debugPrint('✅ Database update completed successfully');
        
        // Then update cache to reflect database state
        try {
          await CachedTournamentService.updateMatchScore(
            widget.tournamentId,
            matchId,
            player1Score: player1Score,
            player2Score: player2Score,
            winnerId: winnerId.isEmpty ? null : winnerId,
            status: status,
          );
          debugPrint('✅ Cache updated');
        } catch (cacheError) {
          debugPrint('⚠️ Cache update failed (non-critical): $cacheError');
          // Cache failure is non-critical since database is already updated
        }
        
      } catch (e) {
        debugPrint('❌ Database update failed: $e');
        throw e; // Rethrow to show error to user
      }
      
      // Update local state
      setState(() {
        final matchIndex = _matches.indexWhere((m) => (m['id'] ?? m['matchId']) == matchId);
        if (matchIndex != -1) {
          _matches[matchIndex]['player1_score'] = player1Score;
          _matches[matchIndex]['player2_score'] = player2Score;
          _matches[matchIndex]['winner_id'] = winnerId.isEmpty ? null : winnerId;
          _matches[matchIndex]['status'] = status;
          
          // Update winner field for UI display
          if (winnerId.isNotEmpty) {
            if (winnerId == match['player1_id']) {
              _matches[matchIndex]['winner'] = 'player1';
            } else if (winnerId == match['player2_id']) {
              _matches[matchIndex]['winner'] = 'player2';
            }
          } else {
            _matches[matchIndex]['winner'] = null;
          }
        }
      });
      
      debugPrint('✅ Match score updated successfully in database and local state');
      
      // 🎯 SIMPLE DIRECT WINNER ADVANCEMENT TRIGGER
      // Immediately advance winner when user saves score
      if (status == 'completed' && winnerId.isNotEmpty) {
        debugPrint('🚀 TRIGGER: Advancing winner directly...');
        await _advanceWinnerDirectly(matchId, winnerId, match);
      }
      
      // Show success message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Tỷ số đã cập nhật: $player1Score - $player2Score'
              '${winnerId.isNotEmpty ? '\n🏆 Người thắng đã được tiến vào vòng tiếp theo!' : ''}',
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
      
      // Notify parent widget about the score update to refresh bracket
      if (widget.onMatchScoreUpdated != null) {
        widget.onMatchScoreUpdated!();
      }
    } catch (e) {
      debugPrint('❌ Error updating match score: $e');
      
      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Lỗi cập nhật tỷ số: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }



  Future<void> _checkAndCreateNextRound(Map<String, dynamic> completedMatch) async {
    try {
      final currentRound = completedMatch['round'] ?? completedMatch['round_number'] ?? 1;
      debugPrint('🎯 Checking if Round ${currentRound + 1} needs to be created');
      debugPrint('🔍 Completed match details: round=$currentRound, id=${completedMatch['id'] ?? completedMatch['matchId']}');
      
      // Get all matches for the current round
      final currentRoundMatches = await Supabase.instance.client
          .from('matches')
          .select('id, round_number, status, winner_id, player1_id, player2_id')
          .eq('tournament_id', widget.tournamentId)
          .eq('round_number', currentRound);
      
      debugPrint('📊 Found ${currentRoundMatches.length} matches in Round $currentRound');
      
      // Get completed matches with winners (progressive creation)
      final completedMatches = currentRoundMatches
          .where((m) => m['status'] == 'completed' && m['winner_id'] != null)
          .toList();
      
      _safeDebugPrint('✅ Completed matches with winners: ${completedMatches.length}/${currentRoundMatches.length}');
      
      // Group completed matches into pairs for next round creation
      final availableWinners = completedMatches
          .map((m) => m['winner_id'] as String)
          .toList();
      
      // Only create next round matches if we have pairs of winners (every 2 winners = 1 next match)
      final possibleNextMatches = availableWinners.length ~/ 2;
      
      if (possibleNextMatches == 0) {
        debugPrint('⏳ Need at least 2 winners to create next round match. Currently have: ${availableWinners.length}');
        return;
      }
      
      // Check which next round matches already exist  
      final existingNextRoundMatches = await Supabase.instance.client
          .from('matches')
          .select('id, match_number')
          .eq('tournament_id', widget.tournamentId)
          .eq('round_number', currentRound + 1)
          .order('match_number');
      
      final maxPossibleNextMatches = currentRoundMatches.length ~/ 2;
      final existingCount = existingNextRoundMatches.length;
      
      debugPrint('🏆 Available winners: ${availableWinners.length}, Existing next matches: $existingCount/$maxPossibleNextMatches');
      
      if (existingCount >= maxPossibleNextMatches) {
        debugPrint('⚡ All possible Round ${currentRound + 1} matches already exist');
        return;
      }
      
      // Progressive creation: Only create matches for new winner pairs
      final matchesToCreate = possibleNextMatches - existingCount;
      
      if (matchesToCreate <= 0) {
        debugPrint('⚠️ No new matches to create. Need more completed matches.');
        return;
      }
      
      debugPrint('🎯 Creating $matchesToCreate new matches for Round ${currentRound + 1}...');
      
      // Create next round matches progressively
      final nextRoundMatches = <Map<String, dynamic>>[];
      final startIndex = existingCount * 2; // Skip already paired winners
      
      for (int i = startIndex; i < availableWinners.length && nextRoundMatches.length < matchesToCreate; i += 2) {
        if (i + 1 < availableWinners.length) {
          final matchNumber = existingCount + nextRoundMatches.length + 1;
          final matchData = {
            'tournament_id': widget.tournamentId,
            'round_number': currentRound + 1,
            'match_number': matchNumber,
            'player1_id': availableWinners[i],
            'player2_id': availableWinners[i + 1],
            'status': 'pending',
            'player1_score': 0,
            'player2_score': 0,
            'winner_id': null,
          };
          nextRoundMatches.add(matchData);
          
          final p1Short = availableWinners[i].length > 8 ? availableWinners[i].substring(0, 8) : availableWinners[i];
          final p2Short = availableWinners[i + 1].length > 8 ? availableWinners[i + 1].substring(0, 8) : availableWinners[i + 1];
          debugPrint('  R${currentRound + 1}M$matchNumber: $p1Short vs $p2Short');
        } else {
          // Odd number of winners - bye for the last player
          final playerShort = availableWinners[i].length > 8 ? availableWinners[i].substring(0, 8) : availableWinners[i];
          debugPrint('  Bye: $playerShort advances automatically');
        }
      }
      
      if (nextRoundMatches.isNotEmpty) {
        try {
          await Supabase.instance.client
              .from('matches')
              .insert(nextRoundMatches);
          
          debugPrint('🎉 Successfully created ${nextRoundMatches.length} matches for Round ${currentRound + 1}');
          
          // Refresh the matches list to show new round
          await _loadMatches();
          
          debugPrint('🔄 Matches refreshed - new round should be visible');
        } catch (e) {
          debugPrint('❌ Error creating next round matches: $e');
          rethrow;
        }
      } else {
        debugPrint('⚠️ No matches created for next round');
      }
      
    } catch (e) {
      debugPrint('❌ Error checking/creating next round: $e');
    }
  }

  Widget _buildScoreInputRow(String playerName, TextEditingController controller) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                playerName,
                style: TextStyle(fontSize: 14.sp),
              ),
            ),
            // Decrease button
            GestureDetector(
              onTap: () {
                int currentValue = int.tryParse(controller.text) ?? 0;
                if (currentValue > 0) {
                  setState(() {
                    controller.text = (currentValue - 1).toString();
                  });
                }
              },
              child: Container(
                width: 32.sp,
                height: 32.sp,
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6.sp),
                  border: Border.all(color: AppTheme.primaryLight.withOpacity(0.3)),
                ),
                child: Icon(
                  Icons.remove,
                  size: 16.sp,
                  color: AppTheme.primaryLight,
                ),
              ),
            ),
            SizedBox(width: 8.sp),
            // Score input
            SizedBox(
              width: 60.sp,
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6.sp),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 8.sp),
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
            SizedBox(width: 8.sp),
            // Increase button
            GestureDetector(
              onTap: () {
                int currentValue = int.tryParse(controller.text) ?? 0;
                setState(() {
                  controller.text = (currentValue + 1).toString();
                });
              },
              child: Container(
                width: 32.sp,
                height: 32.sp,
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6.sp),
                  border: Border.all(color: AppTheme.primaryLight.withOpacity(0.3)),
                ),
                child: Icon(
                  Icons.add,
                  size: 16.sp,
                  color: AppTheme.primaryLight,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _editCompletedMatch(Map<String, dynamic> match) {
    debugPrint('🎯 Edit completed match clicked: ${match['matchId'] ?? match['id']}');
  }

  Future<void> _autoUpdateMatchStatus(String matchId, String newStatus) async {
    try {
      debugPrint('🔄 Auto updating match $matchId status to $newStatus');
      
      // Update in database
      await Supabase.instance.client
          .from('matches')
          .update({'status': newStatus})
          .eq('id', matchId);
      
      // Update local state
      setState(() {
        final matchIndex = _matches.indexWhere((m) => (m['id'] ?? m['matchId']) == matchId);
        if (matchIndex != -1) {
          _matches[matchIndex]['status'] = newStatus;
        }
      });
      
      debugPrint('✅ Match status updated successfully');
    } catch (e) {
      debugPrint('❌ Error updating match status: $e');
    }
  }

  /// 🎯 SIMPLE DIRECT WINNER ADVANCEMENT
  /// Triggered immediately when user clicks "Lưu" with match result
  Future<void> _advanceWinnerDirectly(String completedMatchId, String winnerId, Map<String, dynamic> completedMatch) async {
    try {
      debugPrint('🚀 ADVANCING PLAYERS from match $completedMatchId');
      
      final currentMatchNumber = completedMatch['match_number'] ?? 1;
      final winnerAdvancesTo = completedMatch['winner_advances_to'];
      final loserAdvancesTo = completedMatch['loser_advances_to'];
      
      debugPrint('📍 Current Match Number: $currentMatchNumber');
      debugPrint('🎯 Winner Advances To Match: $winnerAdvancesTo');
      debugPrint('🎯 Loser Advances To Match: $loserAdvancesTo');
      
      // Get loser ID (the player who didn't win)
      final player1Id = completedMatch['player1_id'];
      final player2Id = completedMatch['player2_id'];
      final loserId = (winnerId == player1Id) ? player2Id : player1Id;
      
      // ADVANCE WINNER
      if (winnerAdvancesTo != null) {
        await _advancePlayerToMatch(
          playerId: winnerId,
          targetMatchNumber: winnerAdvancesTo,
          currentMatchNumber: currentMatchNumber,
          role: 'WINNER',
        );
      } else {
        debugPrint('🏆 NO NEXT MATCH FOR WINNER - THIS IS THE FINAL! Champion: $winnerId');
      }
      
      // ADVANCE LOSER (for Double Elimination)
      if (loserAdvancesTo != null && loserId != null) {
        await _advancePlayerToMatch(
          playerId: loserId,
          targetMatchNumber: loserAdvancesTo,
          currentMatchNumber: currentMatchNumber,
          role: 'LOSER',
        );
      }
      
      // Refresh the matches display to show the update
      await _refreshMatches();
      
    } catch (e) {
      debugPrint('❌ Error advancing winner: $e');
    }
  }

  /// Build match progression text from database values
  String _buildMatchProgressionText(Map<String, dynamic> match) {
    final matchNumber = match['match_number'] ?? 1;
    final winnerAdvancesTo = match['winner_advances_to'];
    final loserAdvancesTo = match['loser_advances_to'];
    
    // Base text
    String text = 'M$matchNumber';
    
    // Add winner progression if exists
    if (winnerAdvancesTo != null) {
      text += ' → M$winnerAdvancesTo';
      
      // Add loser progression if exists (for double elimination)
      if (loserAdvancesTo != null) {
        text += ' (L→M$loserAdvancesTo)';
      }
    } else {
      // Only Grand Final (match 31) has no winner advancement
      final roundNumber = match['round_number'] ?? 0;
      if (roundNumber == 999) {
        text = 'M$matchNumber (Final)';
      }
    }
    
    return text;
  }

  /// Helper function to advance a player to target match
  Future<void> _advancePlayerToMatch({
    required String playerId,
    required int targetMatchNumber,
    required int currentMatchNumber,
    required String role,
  }) async {
    try {
      debugPrint('🎯 Advancing $role: $playerId from match $currentMatchNumber → match $targetMatchNumber');
      
      // Find the target match by match_number
      final targetMatches = await Supabase.instance.client
          .from('matches')
          .select('*')
          .eq('tournament_id', widget.tournamentId)
          .eq('match_number', targetMatchNumber);
      
      if (targetMatches.isEmpty) {
        debugPrint('⚠️ Target match $targetMatchNumber not found!');
        return;
      }
      
      final targetMatch = targetMatches.first;
      debugPrint('📋 Target match found: ${targetMatch['id']}');
      
      // Determine which slot (player1_id or player2_id) to place player
      String playerSlot;
      
      if (role == 'LOSER') {
        // For losers: Fill first empty slot
        final player1 = targetMatch['player1_id'];
        final player2 = targetMatch['player2_id'];
        
        if (player1 == null) {
          playerSlot = 'player1_id';
          debugPrint('🎪 Assigning LOSER to player1_id (slot was empty)');
        } else if (player2 == null) {
          playerSlot = 'player2_id';
          debugPrint('🎪 Assigning LOSER to player2_id (slot was empty)');
        } else {
          debugPrint('⚠️ Both slots already filled in target match $targetMatchNumber! Skipping.');
          return;
        }
      } else {
        // For winners: Use even/odd logic (same as before)
        final isEvenCurrentMatch = currentMatchNumber % 2 == 0;
        playerSlot = isEvenCurrentMatch ? 'player2_id' : 'player1_id';
        debugPrint('🎪 Assigning WINNER to $playerSlot (Current match $currentMatchNumber is ${isEvenCurrentMatch ? 'even' : 'odd'})');
      }
      
      // Update the target match with the player
      await Supabase.instance.client
          .from('matches')
          .update({playerSlot: playerId})
          .eq('id', targetMatch['id']);
      
      debugPrint('✅ $role ADVANCED SUCCESSFULLY! $playerId → Match $targetMatchNumber (Round ${targetMatch['round_number']})');
      
    } catch (e) {
      debugPrint('❌ Error advancing $role: $e');
    }
  }
}