class ProfileModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final int? age;
  final String? gender;
  final String? city;
  final String? avatarUrl;
  final String? fitnessLevel;
  final String? preferredPace;
  final String rank;
  final int coins;
  final int xp;
  final double totalKm;
  final int streakDays;

  ProfileModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.age,
    this.gender,
    this.city,
    this.avatarUrl,
    this.fitnessLevel,
    this.preferredPace,
    this.rank = 'Runner',
    this.coins = 0,
    this.xp = 0,
    this.totalKm = 0.0,
    this.streakDays = 0,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      age: json['age'],
      gender: json['gender'],
      city: json['city'],
      avatarUrl: json['avatar_url'],
      fitnessLevel: json['fitness_level'],
      preferredPace: json['preferred_pace'],
      rank: json['rank'] ?? 'Runner',
      coins: json['coins'] ?? 0,
      xp: json['xp'] ?? 0,
      totalKm: (json['total_km'] ?? 0.0).toDouble(),
      streakDays: json['streak_days'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'age': age,
      'gender': gender,
      'city': city,
      'avatar_url': avatarUrl,
      'fitness_level': fitnessLevel,
      'preferred_pace': preferredPace,
      'rank': rank,
      'coins': coins,
      'xp': xp,
      'total_km': totalKm,
      'streak_days': streakDays,
    };
  }
}
