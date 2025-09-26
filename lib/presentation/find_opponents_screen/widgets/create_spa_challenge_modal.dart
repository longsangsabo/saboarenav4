import 'package:flutter/material.dart';

import '../../../models/user_profile.dart';
import '../../../services/club_spa_service.dart';

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

  UserProfile? _selectedOpponent;
  int _selectedSpaBonus = 100; // Default SPA bonus
  String _challengeNote = '';
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
      // For now, just show success message
      // In real implementation, this would integrate with match creation service
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Thách đấu SPA đã được tạo thành công!\n'
              'Đối thủ: ${_selectedOpponent!.displayName}\n'
              'Phần thưởng: $_selectedSpaBonus SPA',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error creating SPA challenge: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tạo thách đấu: $e'),
            backgroundColor: Colors.red,
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
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
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

          // Opponent Selection
          const Text(
            'Chọn đối thủ',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Container(
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
            onChanged: (value) => setState(() => _challengeNote = value),
          ),
          const SizedBox(height: 24),

          // Create Button
          SizedBox(
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
        ],
      ),
    );
  }
}