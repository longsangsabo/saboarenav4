import 'package:flutter/material.dart';

import '../../../models/user_profile.dart';
import './challenge_modal_widget.dart';

class PlayerCardWidget extends StatelessWidget {
  final UserProfile player;

  const PlayerCardWidget({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    
    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: isTablet ? 24 : 16, 
        vertical: 8
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 20 : 16),
        child: Column(
          children: [
            Row(
              children: [
                // Player Avatar
                Container(
                  width: isTablet ? 60 : 50,
                  height: isTablet ? 60 : 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[200],
                  ),
                  child: player.avatarUrl != null
                      ? ClipOval(
                          child: Image.network(
                            player.avatarUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.person,
                              color: Colors.grey[400],
                            ),
                          ),
                        )
                      : Icon(Icons.person, color: Colors.grey[400]),
                ),
                SizedBox(width: isTablet ? 16 : 12),

                // Player Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        player.fullName,
                        style: TextStyle(
                          fontSize: isTablet ? 18 : 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (player.username != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          '@${player.username}',
                          style: TextStyle(
                            fontSize: isTablet ? 14 : 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),

                      // Skill Level Badge
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 10 : 8,
                          vertical: isTablet ? 3 : 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getSkillLevelColor(player.skillLevel),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          player.skillLevelDisplay,
                          style: TextStyle(
                            fontSize: isTablet ? 12 : 10,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Challenge Button
                ElevatedButton(
                  onPressed: () => _showChallengeModal(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 20 : 16,
                      vertical: isTablet ? 12 : 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Thách đấu',
                    style: TextStyle(
                      fontSize: isTablet ? 14 : 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Player Stats
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Thắng',
                    '${player.totalWins}',
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Thua',
                    '${player.totalLosses}',
                    Colors.red,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Tỷ lệ',
                    '${player.winRate.toStringAsFixed(1)}%',
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Điểm',
                    '${player.rankingPoints}',
                    Colors.purple,
                  ),
                ),
              ],
            ),

            if (player.location != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      player.location!,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
      ],
    );
  }

  Color _getSkillLevelColor(String skillLevel) {
    switch (skillLevel) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.blue;
      case 'advanced':
        return Colors.orange;
      case 'professional':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showChallengeModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ChallengeModalWidget(
        player: {
          'name': player.fullName,
          'username': player.username,
          'skillLevel': player.skillLevel,
        },
        challengeType: 'thach_dau',
      ),
    );
  }
}
