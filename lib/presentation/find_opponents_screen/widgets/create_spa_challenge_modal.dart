import 'package:flutter/material.dart';

import '../../../models/user_profile.dart';
import '../../../services/club_spa_service.dart';
import '../../../services/simple_challenge_service.dart';
import '../../../services/user_service.dart';

class CreateSpaChallengeModal extends StatefulWidget {
  final UserProfile? currentUser;
  final List<UserProfile> opponents;

  const CreateSpaChallengeModal({
    super.key,
    required this.currentUser,
    required this.opponents,
  });

  @override
  State<CreateSpaChallengeModal> createState() => _CreateSpaChallengeModalState();
}

class _CreateSpaChallengeModalState extends State<CreateSpaChallengeModal> {
  final ClubSpaService _clubSpaService = ClubSpaService();
  final SimpleChallengeService _challengeService = SimpleChallengeService.instance;
  final UserService _userService = UserService.instance;

  UserProfile? _selectedOpponent;
  int _selectedSpaBonus = 100; // Default SPA bonus
  bool _isCreating = false;
  
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  bool get _canCreateChallenge {
    return _selectedOpponent != null;
  }

  Future<void> _createChallenge() async {
    if (!_canCreateChallenge) return;

    setState(() => _isCreating = true);

    try {
      // Get current user profile
      final currentUser = await _userService.getCurrentUserProfile();
      if (currentUser == null) {
        throw Exception('Không thể lấy thông tin người dùng');
      }

      // For now, use a default club ID since UserProfile doesn't have clubId field
      // In a real implementation, you would get the user's club from another service
      const String defaultClubId = 'default-club-id'; // This should be retrieved from user's club membership
      
      // Check club SPA balance
      final clubBalance = await _clubSpaService.getClubSpaBalance(defaultClubId);
      if (clubBalance == null) {
        // If no club balance record exists, we can still create the challenge
        // The SPA reward will be handled when the match is completed
        debugPrint('⚠️ No club SPA balance found, proceeding with challenge creation');
      } else {
        final availableSpa = clubBalance['available_spa'] ?? 0.0;
        if (availableSpa < _selectedSpaBonus) {
          throw Exception('Club không đủ SPA để tạo thách đấu (Cần: $_selectedSpaBonus, Có: ${availableSpa.toInt()})');
        }
      }

      // Create the challenge with SPA stakes
      final challengeResult = await _challengeService.sendChallenge(
        challengedUserId: _selectedOpponent!.id,
        challengeType: 'thach_dau', // SPA challenges are competitive
        gameType: '8-ball', // Default game type for SPA challenges
        scheduledTime: DateTime.now().add(const Duration(hours: 24)), // Default scheduled time
        location: 'TBD', // To be determined
        spaPoints: _selectedSpaBonus,
        message: _noteController.text.trim().isEmpty 
            ? 'Thách đấu SPA với phần thưởng $_selectedSpaBonus SPA' 
            : _noteController.text.trim(),
      );

      if (challengeResult != null) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Thách đấu SPA đã được gửi thành công!\n'
                'Đối thủ: ${_selectedOpponent!.displayName}\n'
                'Phần thưởng: $_selectedSpaBonus SPA\n'
                'ID thách đấu: ${challengeResult['id']}',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } else {
        throw Exception('Không thể tạo thách đấu');
      }
    } catch (e) {
      debugPrint('Error creating SPA challenge: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tạo thách đấu: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Header
          Row(
            children: [
              const Icon(Icons.sports_martial_arts, size: 28, color: Colors.green),
              const SizedBox(width: 12),
              const Text(
                'Tạo thách đấu SPA',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Opponent Selection
                  const Text(
            'Chọn đối thủ',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.opponents.length,
              itemBuilder: (context, index) {
                final opponent = widget.opponents[index];
                final isSelected = _selectedOpponent?.id == opponent.id;
                
                return GestureDetector(
                  onTap: () => setState(() => _selectedOpponent = opponent),
                  child: Container(
                    width: 100,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.green.shade50 : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? Colors.green : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundImage: opponent.avatarUrl != null
                              ? NetworkImage(opponent.avatarUrl!)
                              : null,
                          child: opponent.avatarUrl == null
                              ? Text(opponent.displayName[0].toUpperCase())
                              : null,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          opponent.displayName,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Hạng: ${opponent.rank ?? 'N/A'}',
                          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          // SPA Bonus Selection
          const Text(
            'Phần thưởng SPA cho người thắng',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [100, 200, 500, 1000, 2000].map((amount) {
              final isSelected = _selectedSpaBonus == amount;
              return ChoiceChip(
                label: Text('$amount SPA'),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _selectedSpaBonus = amount);
                  }
                },
                selectedColor: Colors.green.shade100,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.green.shade800 : Colors.grey.shade700,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Info about SPA Challenge
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.blue.shade600, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Người thắng sẽ nhận được SPA bonus từ club pool',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Challenge Note
          const Text(
            'Ghi chú thách đấu (tùy chọn)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _noteController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Thêm lời nhắn cho đối thủ...',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => {}, // Note content is handled by controller
          ),
          const SizedBox(height: 100), // Extra space for the fixed button
                ],
              ),
            ),
          ),

          // Fixed Create Button at bottom
          Container(
            padding: const EdgeInsets.only(top: 16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _canCreateChallenge && !_isCreating ? _createChallenge : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isCreating
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Gửi thách đấu SPA',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}