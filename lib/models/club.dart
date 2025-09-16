class Club {
  final String id;
  final String ownerId;
  final String name;
  final String? description;
  final String? address;
  final String? phone;
  final String? email;
  final String? websiteUrl;
  final String? coverImageUrl;
  final String? profileImageUrl;
  final int? establishedYear;
  final int totalTables;
  final Map<String, dynamic>? openingHours;
  final List<String>? amenities;
  final double? pricePerHour;
  final bool isVerified;
  final bool isActive;
  final double rating;
  final int totalReviews;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Club({
    required this.id,
    required this.ownerId,
    required this.name,
    this.description,
    this.address,
    this.phone,
    this.email,
    this.websiteUrl,
    this.coverImageUrl,
    this.profileImageUrl,
    this.establishedYear,
    required this.totalTables,
    this.openingHours,
    this.amenities,
    this.pricePerHour,
    required this.isVerified,
    required this.isActive,
    required this.rating,
    required this.totalReviews,
    this.latitude,
    this.longitude,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Club.fromJson(Map<String, dynamic> json) {
    return Club(
      id: json['id'] ?? '',
      ownerId: json['owner_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      address: json['address'],
      phone: json['phone'],
      email: json['email'],
      websiteUrl: json['website_url'],
      coverImageUrl: json['cover_image_url'],
      profileImageUrl: json['profile_image_url'],
      establishedYear: json['established_year'],
      totalTables: json['total_tables'] ?? 1,
      openingHours: json['opening_hours'],
      amenities: json['amenities'] != null
          ? List<String>.from(json['amenities'])
          : null,
      pricePerHour: json['price_per_hour'] != null
          ? (json['price_per_hour'] as num).toDouble()
          : null,
      isVerified: json['is_verified'] ?? false,
      isActive: json['is_active'] ?? true,
      rating: (json['rating'] ?? 0.0).toDouble(),
      totalReviews: json['total_reviews'] ?? 0,
      latitude: json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'name': name,
      'description': description,
      'address': address,
      'phone': phone,
      'email': email,
      'website_url': websiteUrl,
      'cover_image_url': coverImageUrl,
      'profile_image_url': profileImageUrl,
      'established_year': establishedYear,
      'total_tables': totalTables,
      'opening_hours': openingHours,
      'amenities': amenities,
      'price_per_hour': pricePerHour,
      'is_verified': isVerified,
      'is_active': isActive,
      'rating': rating,
      'total_reviews': totalReviews,
      'latitude': latitude,
      'longitude': longitude,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get ratingDisplay {
    if (totalReviews == 0) return 'Chưa có đánh giá';
    return '${rating.toStringAsFixed(1)} ($totalReviews đánh giá)';
  }

  String get priceDisplay {
    if (pricePerHour == null) return 'Liên hệ';
    return '${pricePerHour!.toInt().toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',')}đ/giờ';
  }

  String get tablesDisplay {
    return '$totalTables bàn';
  }

  bool get hasLocation => latitude != null && longitude != null;

  String? get openingHoursDisplay {
    if (openingHours == null) return null;
    // Simplified display - you can expand this based on your data structure
    return 'Xem chi tiết';
  }
}
