enum RankType { beginner, amateur, intermediate, advanced, professional }
enum MembershipType { regular, vip, premium }
enum MemberStatus { active, inactive, suspended, pending }

class MemberData {
  final String id;
  final UserInfo user;
  final MembershipInfo membershipInfo;
  final ActivityStats activityStats;
  final EngagementStats engagement;

  MemberData({
    required this.id,
    required this.user,
    required this.membershipInfo,
    required this.activityStats,
    required this.engagement,
  });

  factory MemberData.fromSupabaseData(Map<String, dynamic> data) {
    final userProfile = data['users'] ?? {};
    
    return MemberData(
      id: data['id'] ?? '',
      user: UserInfo(
        avatar: userProfile['avatar_url'] ?? '',
        name: userProfile['display_name'] ?? userProfile['username'] ?? 'Unknown User',
        username: userProfile['username'] ?? userProfile['email'] ?? '',
        rank: _parseRankType(userProfile['rank'] ?? 'beginner'),
        elo: userProfile['elo_rating'] ?? 1000,
        isOnline: userProfile['is_online'] ?? false,
      ),
      membershipInfo: MembershipInfo(
        type: _parseMembershipType(data['role'] ?? 'regular'), // Use role instead of membership_type
        status: _parseMemberStatus(data['status'] ?? 'active'),
        joinDate: DateTime.parse(data['joined_at'] ?? DateTime.now().toIso8601String()),
        membershipId: data['id'] ?? '',
        expiryDate: null, // club_members doesn't have expiry date
        autoRenewal: false, // club_members doesn't have auto renewal
      ),
      activityStats: ActivityStats(
        lastActive: DateTime.parse(userProfile['last_seen'] ?? DateTime.now().toIso8601String()),
        totalMatches: userProfile['total_matches'] ?? 0,
        tournamentsJoined: userProfile['tournaments_played'] ?? 0,
        winRate: userProfile['total_matches'] > 0 ? (userProfile['wins'] ?? 0) / userProfile['total_matches'] : 0.0,
        activityScore: (userProfile['spa_points'] ?? 0) + (userProfile['elo_rating'] ?? 1000) ~/ 10,
      ),
      engagement: EngagementStats(
        postsCount: 0, // Would need to implement if needed
        commentsCount: 0, // Would need to implement if needed
        likesReceived: 0, // Would need to implement if needed
        socialScore: userProfile['spa_points'] ?? 0,
      ),
    );
  }

  static RankType _parseRankType(String rank) {
    switch (rank.toLowerCase()) {
      case 'amateur': return RankType.amateur;
      case 'intermediate': return RankType.intermediate;
      case 'advanced': return RankType.advanced;
      case 'professional': return RankType.professional;
      default: return RankType.beginner;
    }
  }

  static MembershipType _parseMembershipType(String type) {
    switch (type.toLowerCase()) {
      case 'vip': return MembershipType.vip;
      case 'premium': return MembershipType.premium;
      default: return MembershipType.regular;
    }
  }

  static MemberStatus _parseMemberStatus(String status) {
    switch (status.toLowerCase()) {
      case 'inactive': return MemberStatus.inactive;
      case 'suspended': return MemberStatus.suspended;
      case 'pending': return MemberStatus.pending;
      default: return MemberStatus.active;
    }
  }
}

class UserInfo {
  final String avatar;
  final String name;
  final String username;
  final RankType rank;
  final int elo;
  final bool isOnline;

  UserInfo({
    required this.avatar,
    required this.name,
    required this.username,
    required this.rank,
    required this.elo,
    required this.isOnline,
  });
}

class MembershipInfo {
  final MembershipType type;
  final MemberStatus status;
  final DateTime joinDate;
  final String membershipId;
  final DateTime? expiryDate;
  final bool autoRenewal;

  MembershipInfo({
    required this.type,
    required this.status,
    required this.joinDate,
    required this.membershipId,
    this.expiryDate,
    required this.autoRenewal,
  });
}

class ActivityStats {
  final DateTime lastActive;
  final int totalMatches;
  final int tournamentsJoined;
  final double winRate;
  final int activityScore;

  ActivityStats({
    required this.lastActive,
    required this.totalMatches,
    required this.tournamentsJoined,
    required this.winRate,
    required this.activityScore,
  });
}

class EngagementStats {
  final int postsCount;
  final int commentsCount;
  final int likesReceived;
  final int socialScore;

  EngagementStats({
    required this.postsCount,
    required this.commentsCount,
    required this.likesReceived,
    required this.socialScore,
  });
}

class AdvancedFilters {
  final List<MembershipType> membershipTypes;
  final RankType? minRank;
  final RankType? maxRank;
  final DateTime? joinStartDate;
  final DateTime? joinEndDate;
  final List<String> activityLevels;
  final int? minElo;
  final int? maxElo;

  AdvancedFilters({
    this.membershipTypes = const [],
    this.minRank,
    this.maxRank,
    this.joinStartDate,
    this.joinEndDate,
    this.activityLevels = const [],
    this.minElo,
    this.maxElo,
  });
}