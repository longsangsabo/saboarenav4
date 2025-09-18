import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../services/admin_service.dart';

class AdminTournamentManagementScreen extends StatefulWidget {
  const AdminTournamentManagementScreen({super.key});

  @override
  State<AdminTournamentManagementScreen> createState() => _AdminTournamentManagementScreenState();
}

class _AdminTournamentManagementScreenState extends State<AdminTournamentManagementScreen> {
  final AdminService _adminService = AdminService.instance;
  
  List<Map<String, dynamic>> _tournaments = [];
  bool _isLoading = true;
  bool _isAdmin = false;
  String? _operationMessage;
  bool _isOperationInProgress = false;

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    try {
      final isAdmin = await _adminService.isCurrentUserAdmin();
      setState(() {
        _isAdmin = isAdmin;
      });
      
      if (isAdmin) {
        await _loadTournaments();
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadTournaments() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final tournaments = await _adminService.getTournamentsForAdmin(
        limit: 20,
      );

      setState(() {
        _tournaments = tournaments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Failed to load tournaments: $e');
    }
  }

  Future<void> _addAllUsersToTournament(String tournamentId, String tournamentTitle) async {
    try {
      setState(() {
        _isOperationInProgress = true;
        _operationMessage = null;
      });

      final result = await _adminService.addAllUsersToTournament(tournamentId);

      setState(() {
        _operationMessage = 'Success! Added ${result['users_added']} users to "$tournamentTitle". '
            'Total participants: ${result['total_participants']}/${result['max_participants']}';
      });

      // Reload tournaments to show updated participant counts
      await _loadTournaments();

    } catch (e) {
      setState(() {
        _operationMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _isOperationInProgress = false;
      });
    }
  }

  Future<void> _removeAllUsersFromTournament(String tournamentId, String tournamentTitle) async {
    try {
      setState(() {
        _isOperationInProgress = true;
        _operationMessage = null;
      });

      final result = await _adminService.removeAllUsersFromTournament(tournamentId);

      setState(() {
        _operationMessage = 'Success! Removed ${result['users_removed']} users from "$tournamentTitle". '
            'Remaining participants: ${result['remaining_participants']}';
      });

      // Reload tournaments to show updated participant counts
      await _loadTournaments();

    } catch (e) {
      setState(() {
        _operationMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _isOperationInProgress = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showConfirmDialog({
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Tournament Management'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadTournaments,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (!_isAdmin) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.admin_panel_settings,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 2.h),
            Text(
              'Access Denied',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'You need admin permissions to access this screen.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Operation Message
        if (_operationMessage != null)
          Container(
            width: double.infinity,
            margin: EdgeInsets.all(2.w),
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: _operationMessage!.startsWith('Error') 
                  ? Colors.red[50] 
                  : Colors.green[50],
              border: Border.all(
                color: _operationMessage!.startsWith('Error') 
                    ? Colors.red 
                    : Colors.green,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _operationMessage!,
              style: TextStyle(
                color: _operationMessage!.startsWith('Error') 
                    ? Colors.red[800] 
                    : Colors.green[800],
                fontSize: 12.sp,
              ),
            ),
          ),

        // Progress Indicator
        if (_isOperationInProgress)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(3.w),
            child: const LinearProgressIndicator(),
          ),

        // Tournament List
        Expanded(
          child: _tournaments.isEmpty
              ? _buildEmptyState()
              : _buildTournamentList(),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          SizedBox(height: 2.h),
          Text(
            'No Tournaments Found',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTournamentList() {
    return ListView.builder(
      padding: EdgeInsets.all(2.w),
      itemCount: _tournaments.length,
      itemBuilder: (context, index) {
        final tournament = _tournaments[index];
        return _buildTournamentCard(tournament);
      },
    );
  }

  Widget _buildTournamentCard(Map<String, dynamic> tournament) {
    final title = tournament['title'] ?? 'Unknown Tournament';
    final status = tournament['status'] ?? 'unknown';
    final currentParticipants = tournament['current_participants'] ?? 0;
    final maxParticipants = tournament['max_participants'] ?? 0;
    final clubName = tournament['club']?['name'] ?? 'No Club';
    
    final canAddUsers = status == 'upcoming' && currentParticipants < maxParticipants;
    final canRemoveUsers = currentParticipants > 0;

    return Card(
      margin: EdgeInsets.only(bottom: 2.h),
      child: Padding(
        padding: EdgeInsets.all(3.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tournament Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        'Club: $clubName',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 1.h),
            
            // Participants Info
            Row(
              children: [
                Icon(Icons.people, size: 16.sp, color: Colors.grey[600]),
                SizedBox(width: 1.w),
                Text(
                  'Participants: $currentParticipants/$maxParticipants',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 1.5.h),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: canAddUsers && !_isOperationInProgress
                        ? () => _showConfirmDialog(
                              title: 'Add All Users',
                              content: 'Are you sure you want to add all users to "$title"?',
                              onConfirm: () => _addAllUsersToTournament(
                                tournament['id'],
                                title,
                              ),
                            )
                        : null,
                    icon: const Icon(Icons.group_add, size: 16),
                    label: const Text('Add All Users'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: canRemoveUsers && !_isOperationInProgress
                        ? () => _showConfirmDialog(
                              title: 'Remove All Users',
                              content: 'Are you sure you want to remove all users from "$title"?',
                              onConfirm: () => _removeAllUsersFromTournament(
                                tournament['id'],
                                title,
                              ),
                            )
                        : null,
                    icon: const Icon(Icons.group_remove, size: 16),
                    label: const Text('Remove All'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'upcoming':
        return Colors.blue;
      case 'ongoing':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}