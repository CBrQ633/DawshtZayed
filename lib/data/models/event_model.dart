class EventModel {
  final String id;
  final String title;
  final String location;
  final DateTime date;
  final String imageUrl;
  final int participantsCount;
  final String distance;
  final bool isFeatured;

  EventModel({
    required this.id,
    required this.title,
    required this.location,
    required this.date,
    required this.imageUrl,
    this.participantsCount = 0,
    required this.distance,
    this.isFeatured = false,
  });
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
  EventModel(
    id: '3',
    title: 'تجمع المحترفين',
    location: 'أركان بلازا',
    date: DateTime.now().add(const Duration(days: 14)),
    imageUrl: 'https://images.unsplash.com/photo-1581404179373-fb910e5cfac1?auto=format&fit=crop&q=80&w=1000',
    participantsCount: 55,
    distance: '21KM',
  ),
];
