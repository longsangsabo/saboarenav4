import 'package:flutter/material.dart';

import '../../../models/user_profile.dart';
import './map_view_widget.dart';
import './player_card_widget.dart';

class SocialPlayTab extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;
  final List<UserProfile> players;
  final bool isMapView;
  final VoidCallback onRefresh;

  const SocialPlayTab({
    super.key,
    required this.isLoading,
    required this.errorMessage,
    required this.players,
    required this.isMapView,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Đang tìm người chơi để giao lưu...'),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return _buildErrorState(context);
    }

    if (players.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      children: [
        // Info banner for social play
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.people, color: Colors.blue[600]),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Giao lưu thân thiện',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tìm đối thủ để chơi casual, học hỏi kinh nghiệm',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Players list/map
        Expanded(
          child: isMapView
              ? MapViewWidget(players: players.map((p) => p.toJson()).toList())
              : ListView.builder(
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 80),
                  itemCount: players.length,
                  itemBuilder: (context, index) {
                    return PlayerCardWidget(
                      player: players[index],
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'Đã xảy ra lỗi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage ?? 'Không thể tải danh sách người chơi. Vui lòng thử lại.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRefresh,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có người chơi nào',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Thử mở rộng phạm vi tìm kiếm hoặc thay đổi bộ lọc',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRefresh,
              child: const Text('Tải lại'),
            ),
          ],
        ),
      ),
    );
  }
}

// Enum to distinguish play types
enum PlayType {
  social,     // Giao lưu thân thiện
  competitive // Thách đấu ranked
}
