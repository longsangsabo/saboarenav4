class UserProfile {
  final String id;
  final String email;
  final String fullName;
  final String? username;
  final String? bio;
  final String? avatarUrl;
  final String? phone;
  final DateTime? dateOfBirth;
  final String role;
  final String skillLevel;
  final int totalWins;
  final int totalLosses;
  final int totalTournaments;
  final int rankingPoints;
  final bool isVerified;
  final bool isActive;
  final String? location;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    this.username,
    this.bio,
    this.avatarUrl,
    this.phone,
    this.dateOfBirth,
    required this.role,
    required this.skillLevel,
    required this.totalWins,
    required this.totalLosses,
    required this.totalTournaments,
    required this.rankingPoints,
    required this.isVerified,
    required this.isActive,
    this.location,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      username: json['username'],
      bio: json['bio'],
      avatarUrl: json['avatar_url'],
      phone: json['phone'],
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'])
          : null,
      role: json['role'] ?? 'player',
      skillLevel: json['skill_level'] ?? 'beginner',
      totalWins: json['total_wins'] ?? 0,
      totalLosses: json['total_losses'] ?? 0,
      totalTournaments: json['total_tournaments'] ?? 0,
      rankingPoints: json['ranking_points'] ?? 0,
      isVerified: json['is_verified'] ?? false,
      isActive: json['is_active'] ?? true,
      location: json['location'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'username': username,
      'bio': bio,
      'avatar_url': avatarUrl,
      'phone': phone,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'role': role,
      'skill_level': skillLevel,
      'total_wins': totalWins,
      'total_losses': totalLosses,
      'total_tournaments': totalTournaments,
      'ranking_points': rankingPoints,
      'is_verified': isVerified,
      'is_active': isActive,
      'location': location,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? fullName,
    String? username,
    String? bio,
    String? avatarUrl,
    String? phone,
    DateTime? dateOfBirth,
    String? skillLevel,
    String? location,
  }) {
    return UserProfile(
      id: id,
      email: email,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      role: role,
      skillLevel: skillLevel ?? this.skillLevel,
      totalWins: totalWins,
      totalLosses: totalLosses,
      totalTournaments: totalTournaments,
      rankingPoints: rankingPoints,
      isVerified: isVerified,
      isActive: isActive,
      location: location ?? this.location,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  double get winRate {
    int totalGames = totalWins + totalLosses;
    if (totalGames == 0) return 0.0;
    return (totalWins / totalGames) * 100;
  }

  String get skillLevelDisplay {
    switch (skillLevel) {
      case 'beginner':
        return 'Người mới';
      case 'intermediate':
        return 'Trung bình';
      case 'advanced':
        return 'Nâng cao';
      case 'professional':
        return 'Chuyên nghiệp';
      default:
        return 'Người mới';
    }
  }

  String get roleDisplay {
    switch (role) {
      case 'player':
        return 'Người chơi';
      case 'club_owner':
        return 'Chủ câu lạc bộ';
      case 'admin':
        return 'Quản trị viên';
      default:
        return 'Người chơi';
    }
  }
}
