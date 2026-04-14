class PostModel {
  final String id;
  final String userId;
  final String? caption;
  final List<String> mediaUrls;
  final String? mediaType;
  final String? locationTag;
  final double distanceKm;
  final int durationMinutes;
  final String pace;
  final int likesCount;
  final int commentsCount;
  final DateTime createdAt;
  final String? userName; // From profiles join
  final String? userAvatar; // From profiles join
  final bool isLikedByMe;

  PostModel({
    required this.id,
    required this.userId,
    this.caption,
    this.mediaUrls = const [],
    this.mediaType = 'image',
    this.locationTag,
    this.distanceKm = 0.0,
    this.durationMinutes = 0,
    required this.pace,
    this.likesCount = 0,
    this.commentsCount = 0,
    required this.createdAt,
    this.userName,
    this.userAvatar,
    this.isLikedByMe = false,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    // Handle mediaUrls which could be text[] from Supabase (comes as List<dynamic>)
    final List<dynamic> urls = json['media_urls'] ?? [];
    
    return PostModel(
      id: json['id'],
      userId: json['user_id'],
      caption: json['caption'],
      mediaUrls: urls.map((e) => e.toString()).toList(),
      mediaType: json['media_type'],
      locationTag: json['location_tag'],
      distanceKm: (json['distance_km'] ?? 0.0).toDouble(),
      durationMinutes: json['duration_minutes'] ?? 0,
      pace: json['pace'] ?? '',
      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      userName: json['profiles']?['name'],
      userAvatar: json['profiles']?['avatar_url'],
      isLikedByMe: json['is_liked_by_me'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'caption': caption,
      'media_urls': mediaUrls,
      'media_type': mediaType,
      'location_tag': locationTag,
      'distance_km': distanceKm,
      'duration_minutes': durationMinutes,
      'pace': pace,
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
