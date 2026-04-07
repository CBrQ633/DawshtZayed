class ActivityModel {
  final String id;
  final String userId;
  final String type; // 'Run', 'Walk', 'Cycle'
  final double distance; // in km
  final Duration duration;
  final double pace; // min/km
  final int calories;
  final List<Map<String, double>> route; // List of {lat, lng}
  final DateTime createdAt;

  ActivityModel({
    required this.id,
    required this.userId,
    this.type = 'Run',
    required this.distance,
    required this.duration,
    required this.pace,
    this.calories = 0,
    required this.route,
    required this.createdAt,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'],
      userId: json['user_id'],
      type: json['type'] ?? 'Run',
      distance: (json['distance'] ?? 0.0).toDouble(),
      duration: Duration(seconds: json['duration_seconds'] ?? 0),
      pace: (json['pace'] ?? 0.0).toDouble(),
      calories: json['calories'] ?? 0,
      route: (json['route'] as List?)?.map((e) => Map<String, double>.from(e)).toList() ?? [],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'distance': distance,
      'duration_seconds': duration.inSeconds,
      'pace': pace,
      'calories': calories,
      'route': route,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
