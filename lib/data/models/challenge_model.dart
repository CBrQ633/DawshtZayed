class ChallengeModel {
  final String id;
  final String title;
  final String description;
  final String type; // 'distance', 'speed', 'streak'
  final double goalValue;
  final int rewardCoins;
  final int rewardXp;
  final DateTime? endDate;
  final String? imageUrl;

  ChallengeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.goalValue,
    required this.rewardCoins,
    required this.rewardXp,
    this.endDate,
    this.imageUrl,
  });

  factory ChallengeModel.fromJson(Map<String, dynamic> json) {
    return ChallengeModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: json['type'],
      goalValue: (json['goal_value'] as num).toDouble(),
      rewardCoins: json['reward_coins'] ?? 0,
      rewardXp: json['reward_xp'] ?? 0,
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      imageUrl: json['image_url'],
    );
  }
}

class ChallengeParticipantModel {
  final String id;
  final String challengeId;
  final String userId;
  final double progress;
  final bool isCompleted;
  final DateTime? completedAt;

  ChallengeParticipantModel({
    required this.id,
    required this.challengeId,
    required this.userId,
    this.progress = 0.0,
    this.isCompleted = false,
    this.completedAt,
  });

  factory ChallengeParticipantModel.fromJson(Map<String, dynamic> json) {
    return ChallengeParticipantModel(
      id: json['id'],
      challengeId: json['challenge_id'],
      userId: json['user_id'],
      progress: (json['progress'] as num).toDouble(),
      isCompleted: json['is_completed'] ?? false,
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
    );
  }
}
