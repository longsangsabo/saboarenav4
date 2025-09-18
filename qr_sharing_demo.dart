import 'package:flutter/material.dart';
import 'package:sabo_arena/models/user_profile.dart';
import 'package:sabo_arena/services/share_service.dart';
import 'package:sabo_arena/widgets/user_qr_code_widget.dart';

// Demo script to test QR + Sharing system
void main() {
  runApp(QRSharingDemoApp());
}

class QRSharingDemoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SABO ARENA - QR & Sharing Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: QRSharingDemoScreen(),
    );
  }
}

class QRSharingDemoScreen extends StatelessWidget {
  // Sample user data for testing
  final UserProfile sampleUser = UserProfile(
    id: 'demo-user-123',
    email: 'demo@saboarena.com',
    fullName: 'Nguyễn Văn Demo',
    username: 'demo_player',
    bio: 'Cầu lông enthusiast • Tournament player',
    avatarUrl: 'https://images.pexels.com/photos/2379004/pexels-photo-2379004.jpeg',
    role: 'player',
    skillLevel: 'intermediate',
    rank: 'Gold',
    totalWins: 25,
    totalLosses: 8,
    totalTournaments: 5,
    eloRating: 1450,
    spaPoints: 1200,
    totalPrizePool: 2500000.0,
    isVerified: true,
    isActive: true,
    location: 'Hồ Chí Minh',
    createdAt: DateTime.now().subtract(Duration(days: 30)),
    updatedAt: DateTime.now(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🎯 QR & Sharing System Demo'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              '🎉 SABO ARENA QR & Sharing System',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Test tất cả tính năng QR Code và Sharing',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            
            SizedBox(height: 30),
            
            // User Info Card
            _buildUserInfoCard(context),
            
            SizedBox(height: 30),
            
            // QR Features Section
            _buildQRFeaturesSection(context),
            
            SizedBox(height: 30),
            
            // Sharing Features Section
            _buildSharingFeaturesSection(context),
            
            SizedBox(height: 30),
            
            // System Status
            _buildSystemStatus(context),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoCard(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '👤 Sample User Profile',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 15),
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(sampleUser.avatarUrl ?? ''),
                  backgroundColor: Colors.grey[300],
                ),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sampleUser.fullName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        sampleUser.bio ?? '',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'ELO: ${sampleUser.eloRating} • Rank: ${sampleUser.rank}',
                        style: TextStyle(
                          color: Colors.blue[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'User Code: ${ShareService.generateUserCode(sampleUser.id)}',
                        style: TextStyle(
                          color: Colors.green[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQRFeaturesSection(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📱 QR Code Features',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 15),
            
            // QR Modal Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => UserQRCodeModal.show(context, sampleUser),
                icon: Icon(Icons.qr_code),
                label: Text('Show QR Modal'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
            
            SizedBox(height: 10),
            
            // QR Bottom Sheet Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => UserQRCodeBottomSheet.show(context, sampleUser),
                icon: Icon(Icons.qr_code_scanner),
                label: Text('Show QR Bottom Sheet'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
            
            SizedBox(height: 15),
            Text(
              'QR Data: ${ShareService.generateUserQRData(sampleUser)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSharingFeaturesSection(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🚀 Sharing Features',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 15),
            
            // Share Profile Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => ShareService.shareUserProfile(sampleUser),
                icon: Icon(Icons.person_pin),
                label: Text('Share User Profile'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[600],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
            
            SizedBox(height: 10),
            
            // Share Tournament Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => ShareService.shareTournament(
                  tournamentId: 'demo-tournament-1',
                  tournamentName: 'SABO Arena Championship 2025',
                  startDate: '25/09/2025',
                  participants: 32,
                  prizePool: '10,000,000 VNĐ',
                ),
                icon: Icon(Icons.emoji_events),
                label: Text('Share Tournament'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[600],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
            
            SizedBox(height: 10),
            
            // Share App Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => ShareService.shareApp(),
                icon: Icon(Icons.mobile_friendly),
                label: Text('Share SABO Arena App'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemStatus(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '✅ System Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
            SizedBox(height: 15),
            
            _buildStatusItem('ShareService', 'Ready', Colors.green),
            _buildStatusItem('QR Code Generation', 'Working', Colors.green),
            _buildStatusItem('User Code System', 'Active', Colors.green),
            _buildStatusItem('Database Migration', 'Pending', Colors.orange),
            _buildStatusItem('UI Integration', 'Complete', Colors.green),
            
            SizedBox(height: 15),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[600]),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Để hoàn tất: Chạy SQL migration trong Supabase Dashboard',
                      style: TextStyle(
                        color: Colors.blue[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(String feature, String status, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              feature,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}