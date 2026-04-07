class EventModel {
  final String id;
  final String title;
  final String? description;
  final String location;
  final DateTime date;
  final String imageUrl;
  final int participantsCount;
  final String distance;
  final bool isFeatured;
  final String? difficulty;
  final String? coachName;

  EventModel({
    required this.id,
    required this.title,
    this.description,
    required this.location,
    required this.date,
    required this.imageUrl,
    this.participantsCount = 0,
    required this.distance,
    this.isFeatured = false,
    this.difficulty,
    this.coachName,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      description: json['description'],
      location: json['location'] ?? '',
      date: DateTime.tryParse(json['event_date']?.toString() ?? '') ?? DateTime.now(),
      imageUrl: json['image_url'] ?? '',
      participantsCount: json['participants_count'] ?? 0,
      distance: json['distance'] ?? '',
      isFeatured: json['is_featured'] ?? false,
      difficulty: json['difficulty'],
      coachName: json['coach_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'event_date': date.toIso8601String(),
      'image_url': imageUrl,
      'participants_count': participantsCount,
      'distance': distance,
      'is_featured': isFeatured,
      'difficulty': difficulty,
      'coach_name': coachName,
    };
  }
}

// Dummy Data
final List<EventModel> dummyEvents = [
  EventModel(
    id: '1',
    title: 'ماراثون زايد الخيري',
    location: 'ممشى زايد الدائري',
    date: DateTime.now().add(const Duration(days: 3)),
    imageUrl: 'https://images.unsplash.com/photo-1552674605-15cffe483f25?auto=format&fit=crop&q=80&w=1000',
    participantsCount: 342,
    distance: '5KM',
    isFeatured: true,
  ),
  EventModel(
    id: '2',
    title: 'جري صباحي في أكتوبر',
    location: 'نادي الصيد - 6 أكتوبر',
    date: DateTime.now().add(const Duration(days: 7)),
    imageUrl: 'https://images.unsplash.com/photo-1476480862126-209bfaa8edc8?auto=format&fit=crop&q=80&w=1000',
    participantsCount: 120,
    distance: '10KM',
  ),
];
