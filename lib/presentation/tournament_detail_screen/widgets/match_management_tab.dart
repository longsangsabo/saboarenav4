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
  // 🔥 STANDARDIZED: Filter by bracket_type + stage_round instead of round_number
  String? _selectedBracketType; // null = show all, 'WB', 'LB', 'GF'
  int? _selectedStageRound; // null = show all
  String? _selectedBracketGroup; // null = show all, 'A', 'B', 'CROSS'
  int _totalParticipants = 0; // Dynamic participant count

  // 🔥 NEW: Get hierarchical structure for complex formats (SABO DE32/DE16)
  Map<String, dynamic> _getHierarchicalStructure() {
    // Apply status filter first
    final filteredMatches = _getFilteredMatches();
    
    if (filteredMatches.isEmpty) return {};
    
    // Detect format by checking bracket_group presence
    bool hasBracketGroups = filteredMatches.any((m) => m['bracket_group'] != null);
    debugPrint('🔍 Hierarchical structure: hasBracketGroups=$hasBracketGroups, total matches=${filteredMatches.length}');
    if (filteredMatches.isNotEmpty) {
      final firstMatch = filteredMatches.first;
      debugPrint('  First match: bracket_group=${firstMatch['bracket_group']}, bracket_type=${firstMatch['bracket_type']}, stage_round=${firstMatch['stage_round']}');
    }
    
    Map<String, dynamic> structure = {};
    
    for (var match in filteredMatches) {
      final bracketGroup = match['bracket_group']; // 'A', 'B', null
      final bracketType = match['bracket_type'] ?? 'WB'; // 'WB', 'LB-A', 'LB-B', 'CROSS', 'GF'
      final stageRound = match['stage_round'] ?? match['round_number'] ?? 1;
      final displayOrder = match['display_order'] ?? 0;
      
      // Level 1: Bracket Group (only for SABO DE32+)
      String level1Key;
      String level1Label;
      
      if (hasBracketGroups) {
        if (bracketGroup == 'A') {
          level1Key = 'group_a';
          level1Label = '📁 Group A';
        } else if (bracketGroup == 'B') {
          level1Key = 'group_b';
          level1Label = '📁 Group B';
        } else {
          // Cross Finals or other
          level1Key = 'cross_finals';
          level1Label = '🏆 Cross Finals';
        }
      } else {
        // Regular DE16 or SE - use bracket_type as top level
        level1Key = bracketType.toLowerCase();
        if (bracketType == 'WB') {
          level1Label = '🎯 Winner Bracket';
        } else if (bracketType == 'LB') {
          level1Label = '🔄 Loser Bracket';
        } else if (bracketType == 'GF') {
          level1Label = '🏆 Grand Final';
        } else {
          level1Label = bracketType;
        }
      }
      
      // Level 2: Bracket Type (for SABO) or Stage Round (for regular formats)
      String level2Key;
      String level2Label;
      
      if (hasBracketGroups) {
        // SABO format - use bracket_type as level 2
        level2Key = bracketType;
        if (bracketType == 'WB') {
          level2Label = '  ├─ WB (Winner Bracket)';
        } else if (bracketType == 'LB-A') {
          level2Label = '  ├─ LB-A (Loser Branch A)';
        } else if (bracketType == 'LB-B') {
          level2Label = '  └─ LB-B (Loser Branch B)';
        } else if (bracketType == 'CROSS') {
          level2Label = '  ├─ Semi-Finals';
        } else if (bracketType == 'GF') {
          level2Label = '  └─ Grand Final';
        } else {
          level2Label = '  ├─ $bracketType';
        }
      } else {
        // Regular format - stage_round is the key
        level2Key = 'round_$stageRound';
        level2Label = '  Round $stageRound';
      }
      
      // Level 3: Stage Round (always)
      String level3Key = 'round_$stageRound';
      String level3Label = '    └─ Round $stageRound';
      
      // Initialize structure
      if (!structure.containsKey(level1Key)) {
        structure[level1Key] = {
          'label': level1Label,
          'display_order': displayOrder,
          'children': <String, dynamic>{},
          'matches': <Map<String, dynamic>>[],
        };
      }
      
      if (hasBracketGroups) {
        // 3-level hierarchy for SABO
        if (!structure[level1Key]['children'].containsKey(level2Key)) {
          structure[level1Key]['children'][level2Key] = {
            'label': level2Label,
            'display_order': displayOrder,
            'children': <String, dynamic>{},
            'matches': <Map<String, dynamic>>[],
          };
        }
        
        if (!structure[level1Key]['children'][level2Key]['children'].containsKey(level3Key)) {
          structure[level1Key]['children'][level2Key]['children'][level3Key] = {
            'label': level3Label,
            'display_order': displayOrder,
            'matches': <Map<String, dynamic>>[],
          };
        }
        
        structure[level1Key]['children'][level2Key]['children'][level3Key]['matches'].add(match);
      } else {
        // 2-level hierarchy for regular formats
        if (!structure[level1Key]['children'].containsKey(level2Key)) {
          structure[level1Key]['children'][level2Key] = {
            'label': level2Label,
            'display_order': displayOrder,
            'matches': <Map<String, dynamic>>[],
          };
        }
        
        structure[level1Key]['children'][level2Key]['matches'].add(match);
      }
    }
    
    return structure;
  }

  // 🔥 STANDARDIZED: Get round name using bracket_type + stage_round
  String _getRoundName(String bracketType, int stageRound, String? bracketGroup) {
    // For SABO formats with bracket_group
    if (bracketGroup != null) {
      if (bracketGroup == 'A' || bracketGroup == 'B') {
        if (bracketType == 'WB') {
          return 'Group $bracketGroup - WB R$stageRound';
        } else if (bracketType == 'LB-A') {
          return 'Group $bracketGroup - LB-A R$stageRound';
        } else if (bracketType == 'LB-B') {
          return 'Group $bracketGroup - LB-B R$stageRound';
        }
      } else {
        // Cross Finals
        if (bracketType == 'CROSS') {
          return 'Cross Finals - SF $stageRound';
        } else if (bracketType == 'GF') {
          return 'Grand Final';
        }
      }
    }
    
    // For regular formats without bracket_group
    switch (bracketType) {
      case 'WB': // Winner Bracket
        return 'WB - Round $stageRound';
      
      case 'LB': // Loser Bracket
        return 'LB - Round $stageRound';
      
      case 'GF': // Grand Final
        return 'Grand Final';
      
      default:
        return 'Round $stageRound';
    }
  }

  // 🔥 STANDARDIZED: Get available rounds using bracket_type + stage_round
  // 🔥 NEW: Get available bracket groups (A, B, CROSS)
  List<Map<String, dynamic>> _getAvailableBracketGroups() {
    if (_matches.isEmpty) return [];
    
    // Detect if tournament has bracket groups
    bool hasBracketGroups = _matches.any((m) => m['bracket_group'] != null);
    if (!hasBracketGroups) return [];
    
    Map<String, int> groupCounts = {};
    
    for (var match in _matches) {
      final bracketGroup = match['bracket_group'];
      if (bracketGroup != null) {
        groupCounts[bracketGroup] = (groupCounts[bracketGroup] ?? 0) + 1;
      } else {
        groupCounts['CROSS'] = (groupCounts['CROSS'] ?? 0) + 1;
      }
    }
    
    List<Map<String, dynamic>> groups = [];
    groupCounts.forEach((group, count) {
      groups.add({
        'key': group,
        'label': group == 'CROSS' ? '🏆 Cross/GF' : '📁 Group $group',
        'count': count,
      });
    });
    
    // Sort: A, B, CROSS
    groups.sort((a, b) {
      const order = {'A': 0, 'B': 1, 'CROSS': 2};
      return (order[a['key']] ?? 99).compareTo(order[b['key']] ?? 99);
    });
    
    return groups;
  }

  List<Map<String, dynamic>> _getAvailableRounds() {
    if (_matches.isEmpty) return [];
    
    // Group matches by bracket_type + stage_round + bracket_group
    Map<String, List<Map<String, dynamic>>> groupedMatches = {};
    
    for (var match in _matches) {
      // Use new standardized fields
      final bracketType = match['bracket_type'] ?? 'WB';
      final stageRound = match['stage_round'] ?? match['round_number'] ?? 1;
      final bracketGroup = match['bracket_group'];
      
      // Create unique key for this round tab
      final key = '$bracketType-$stageRound-${bracketGroup ?? ""}';
      
      if (!groupedMatches.containsKey(key)) {
        groupedMatches[key] = [];
      }
      groupedMatches[key]!.add(match);
    }
    
    // Convert to list and sort by display_order
    List<Map<String, dynamic>> rounds = [];
    groupedMatches.forEach((key, matches) {
      final firstMatch = matches.first;
      final bracketType = firstMatch['bracket_type'] ?? 'WB';
      final stageRound = firstMatch['stage_round'] ?? firstMatch['round_number'] ?? 1;
      final bracketGroup = firstMatch['bracket_group'];
      final displayOrder = firstMatch['display_order'] ?? 0;
      
      rounds.add({
        'bracket_type': bracketType,
        'stage_round': stageRound,
        'bracket_group': bracketGroup,
        'display_order': displayOrder,
        'name': _getRoundName(bracketType, stageRound, bracketGroup),
        'matches': matches.length,
      });
    });
    
    // Sort by display_order
    rounds.sort((a, b) => (a['display_order'] as int).compareTo(b['display_order'] as int));
    
    return rounds;
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

  // 🔥 UPDATED: Filter matches based on selected status
  List<Map<String, dynamic>> _getFilteredMatches() {
    var filtered = _matches;
    
    // 🔥 Filter by bracket_group (Group A, B, CROSS)
    if (_selectedBracketGroup != null) {
      filtered = filtered.where((m) {
        final bracketGroup = m['bracket_group'];
        if (_selectedBracketGroup == 'CROSS') {
          return bracketGroup == 'CROSS' || bracketGroup == null;
        }
        return bracketGroup == _selectedBracketGroup;
      }).toList();
    }
    
    // Filter by status
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
            expandedHeight: _getAvailableBracketGroups().isNotEmpty ? 125.sp : 95.sp, // 3 rows nếu có groups, 2 rows nếu không
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
                    // Row 2: Group filters (if SABO DE32 format)
                    if (_getAvailableBracketGroups().isNotEmpty) ...[
                      SizedBox(height: 4.sp),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            // "All Groups" button
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 2.sp),
                              child: _buildGroupFilterButton('🔵 All Groups', _matches.length, null),
                            ),
                            // Individual group buttons
                            ..._getAvailableBracketGroups().map((groupData) => 
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 2.sp),
                                child: _buildGroupFilterButton(
                                  groupData['label'],
                                  groupData['count'],
                                  groupData['key'],
                                ),
                              )
                            ).toList(),
                          ],
                        ),
                      ),
                    ],
                    // Row 3: Dynamic round filters based on bracket_type + stage_round
                    if (_matches.isNotEmpty) ...[
                      SizedBox(height: 4.sp),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _getAvailableRounds().map((roundData) => 
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 2.sp),
                              child: _buildRoundFilterButton(
                                roundData['name'], 
                                roundData['matches'].toString(), 
                                roundData['bracket_type'], // 🔥 NEW: bracket type
                                roundData['stage_round'], // 🔥 NEW: stage round
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
      body: _buildHierarchicalMatchList(),
    );
  }

  // 🔥 NEW: Build hierarchical match list with expandable sections
  Widget _buildHierarchicalMatchList() {
    final structure = _getHierarchicalStructure();
    
    if (structure.isEmpty) {
      return Center(child: Text('Không có trận đấu'));
    }
    
    // Sort top-level keys by display_order
    final sortedLevel1Keys = structure.keys.toList()
      ..sort((a, b) => (structure[a]['display_order'] as int)
          .compareTo(structure[b]['display_order'] as int));
    
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 8.sp),
      itemCount: sortedLevel1Keys.length,
      itemBuilder: (context, index) {
        final key = sortedLevel1Keys[index];
        final section = structure[key];
        return _buildExpandableSection(
          label: section['label'],
          children: section['children'],
          matches: section['matches'],
        );
      },
    );
  }

  // 🔥 NEW: Build expandable section for each level
  Widget _buildExpandableSection({
    required String label,
    required Map<String, dynamic> children,
    required List<Map<String, dynamic>> matches,
  }) {
    // Count total matches in this section (including children)
    int totalMatches = matches.length;
    children.forEach((key, child) {
      totalMatches += _countMatches(child);
    });
    
    // If no children, just show matches
    if (children.isEmpty && matches.isNotEmpty) {
      return Card(
        margin: EdgeInsets.only(bottom: 8.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(12.sp),
              color: Colors.blue[50],
              child: Row(
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 4.sp),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(12.sp),
                    ),
                    child: Text(
                      '$totalMatches trận',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ...matches.map((match) => _buildMatchCard(match)).toList(),
          ],
        ),
      );
    }
    
    // Has children - create expandable tile
    return Card(
      margin: EdgeInsets.only(bottom: 8.sp),
      child: ExpansionTile(
        initiallyExpanded: true,
        title: Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: Colors.blue[800],
          ),
        ),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 4.sp),
          decoration: BoxDecoration(
            color: Colors.blue[100],
            borderRadius: BorderRadius.circular(12.sp),
          ),
          child: Text(
            '$totalMatches trận',
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
        ),
        children: [
          // Sort children by display_order
          ...(() {
            final sortedChildKeys = children.keys.toList()
              ..sort((a, b) => (children[a]['display_order'] as int)
                  .compareTo(children[b]['display_order'] as int));
            
            return sortedChildKeys.map((childKey) {
              final child = children[childKey];
              
              // If child has its own children (3-level hierarchy), recurse
              if (child['children'] != null && (child['children'] as Map).isNotEmpty) {
                return Padding(
                  padding: EdgeInsets.only(left: 16.sp),
                  child: _buildExpandableSection(
                    label: child['label'],
                    children: child['children'],
                    matches: child['matches'] ?? [],
                  ),
                );
              }
              
              // Leaf node - show matches directly
              final childMatches = child['matches'] as List<Map<String, dynamic>>;
              return Padding(
                padding: EdgeInsets.only(left: 16.sp),
                child: Card(
                  margin: EdgeInsets.only(bottom: 8.sp),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.sp),
                        color: Colors.grey[100],
                        child: Row(
                          children: [
                            Text(
                              child['label'],
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                            ),
                            Spacer(),
                            Text(
                              '${childMatches.length} trận',
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      ...childMatches.map((match) => _buildMatchCard(match)).toList(),
                    ],
                  ),
                ),
              );
            }).toList();
          })(),
        ],
      ),
    );
  }

  // Helper: Count total matches in a section
  int _countMatches(Map<String, dynamic> section) {
    int count = (section['matches'] as List?)?.length ?? 0;
    
    if (section['children'] != null) {
      (section['children'] as Map).forEach((key, child) {
        count += _countMatches(child);
      });
    }
    
    return count;
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

  // 🔥 NEW: Build group filter button (for SABO DE32 bracket_group filtering)
  Widget _buildGroupFilterButton(String label, int count, String? groupKey) {
    bool isSelected = _selectedBracketGroup == groupKey;
    
    return InkWell(
      onTap: () => setState(() {
        if (isSelected) {
          _selectedBracketGroup = null; // Toggle off
        } else {
          _selectedBracketGroup = groupKey; // Select this group
        }
      }),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 3.sp, horizontal: 6.sp),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[700] : Colors.grey[100],
          borderRadius: BorderRadius.circular(8.sp),
          border: Border.all(
            color: isSelected ? Colors.blue[900]! : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, 
                 style: TextStyle(
                   fontSize: 9.sp,
                   fontWeight: FontWeight.bold,
                   color: isSelected ? Colors.white : Colors.grey[700],
                 )),
            SizedBox(width: 4.sp),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4.sp, vertical: 1.sp),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.blue[100],
                borderRadius: BorderRadius.circular(10.sp),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 8.sp,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.blue[700] : Colors.blue[900],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 STANDARDIZED: Build round filter button with bracket_type + stage_round filtering
  Widget _buildRoundFilterButton(String label, String value, String bracketType, int stageRound) {
    bool isSelected = _selectedBracketType == bracketType && _selectedStageRound == stageRound;
    
    return InkWell(
      onTap: () => setState(() {
        if (isSelected) {
          // Toggle: click again to show all
          _selectedBracketType = null;
          _selectedStageRound = null;
        } else {
          _selectedBracketType = bracketType;
          _selectedStageRound = stageRound;
        }
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
      final winnerAdvancesTo = completedMatch['winner_advances_to']; // This is display_order
      final loserAdvancesTo = completedMatch['loser_advances_to']; // This is display_order
      
      debugPrint('📍 Current Match Number: $currentMatchNumber');
      debugPrint('🎯 Winner Advances To Display Order: $winnerAdvancesTo');
      debugPrint('🎯 Loser Advances To Display Order: $loserAdvancesTo');
      
      // Get loser ID (the player who didn't win)
      final player1Id = completedMatch['player1_id'];
      final player2Id = completedMatch['player2_id'];
      final loserId = (winnerId == player1Id) ? player2Id : player1Id;
      
      // ADVANCE WINNER
      if (winnerAdvancesTo != null) {
        await _advancePlayerToMatch(
          playerId: winnerId,
          targetDisplayOrder: winnerAdvancesTo,
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
          targetDisplayOrder: loserAdvancesTo,
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
    required int targetDisplayOrder,
    required int currentMatchNumber,
    required String role,
  }) async {
    try {
      debugPrint('🎯 Advancing $role: $playerId from match $currentMatchNumber → display_order $targetDisplayOrder');
      
      // ✅ FIXED: Search by display_order instead of match_number
      final targetMatches = await Supabase.instance.client
          .from('matches')
          .select('*')
          .eq('tournament_id', widget.tournamentId)
          .eq('display_order', targetDisplayOrder);
      
      if (targetMatches.isEmpty) {
        debugPrint('⚠️ Target match with display_order $targetDisplayOrder not found!');
        return;
      }
      
      final targetMatch = targetMatches.first;
      final targetMatchNumber = targetMatch['match_number'];
      debugPrint('📋 Target match found: M$targetMatchNumber (ID: ${targetMatch['id']})');
      
      // Determine which slot (player1_id or player2_id) to place player
      String playerSlot;
      
      final player1 = targetMatch['player1_id'];
      final player2 = targetMatch['player2_id'];
      
      // Fill first empty slot (works for both winners and losers)
      if (player1 == null) {
        playerSlot = 'player1_id';
        debugPrint('🎪 Assigning $role to player1_id (slot was empty)');
      } else if (player2 == null) {
        playerSlot = 'player2_id';
        debugPrint('🎪 Assigning $role to player2_id (slot was empty)');
      } else {
        debugPrint('⚠️ Both slots already filled in target match M$targetMatchNumber! Skipping.');
        return;
      }
      
      // Update the target match with the player
      await Supabase.instance.client
          .from('matches')
          .update({playerSlot: playerId})
          .eq('id', targetMatch['id']);
      
      // Check if both players now populated → set status to 'pending'
      final updatedPlayer1 = player1 ?? (playerSlot == 'player1_id' ? playerId : null);
      final updatedPlayer2 = player2 ?? (playerSlot == 'player2_id' ? playerId : null);
      
      if (updatedPlayer1 != null && updatedPlayer2 != null) {
        await Supabase.instance.client
            .from('matches')
            .update({'status': 'pending'})
            .eq('id', targetMatch['id']);
        debugPrint('🎮 Match M$targetMatchNumber ready to play (both players populated)');
      }
      
      debugPrint('✅ $role ADVANCED SUCCESSFULLY! $playerId → Match M$targetMatchNumber (Round ${targetMatch['round_number']})');
      
    } catch (e) {
      debugPrint('❌ Error advancing $role: $e');
    }
  }
}