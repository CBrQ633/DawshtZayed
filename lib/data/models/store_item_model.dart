class StoreItemModel {
  final String id;
  final String name;
  final String description;
  final int price; // in coins
  final String imageUrl;
  final String category; // 'gear', 'voucher', 'badge'
  final bool isAvailable;
  final int stock;
  final bool isOfficial;

  StoreItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.isAvailable = true,
    this.stock = 0,
    this.isOfficial = false,
  });

  factory StoreItemModel.fromJson(Map<String, dynamic> json) {
    return StoreItemModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: json['price'] ?? 0,
      imageUrl: json['image_url'] ?? '',
      category: json['category'] ?? '',
      isAvailable: json['is_available'] ?? true,
      stock: json['stock'] ?? 0,
      isOfficial: json['is_official'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'category': category,
      'is_available': isAvailable,
      'stock': stock,
      'is_official': isOfficial,
    };
  }
}

// Dummy Store Items
final List<StoreItemModel> dummyStoreItems = [
  StoreItemModel(
    id: '1',
    name: 'تيشيرت دوشة الرياضي',
    description: 'تيشيرت رياضي مريح بشعار دوشة، مصنوع من القطن المصري.',
    price: 150,
    imageUrl: 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?auto=format&fit=crop&q=80&w=400',
    category: 'gear',
  ),
  StoreItemModel(
    id: '2',
    name: 'قسيمة ديكاتلون 50 ج.م',
    description: 'قسيمة شراء من ديكاتلون بقيمة 50 جنيه.',
    price: 200,
    imageUrl: 'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?auto=format&fit=crop&q=80&w=400',
    category: 'voucher',
  ),
  StoreItemModel(
    id: '3',
    name: 'شارة "ماراثوني"',
    description: 'شارة حصرية تظهر في بروفايلك بعد إتمام 100 كم.',
    price: 50,
    imageUrl: 'https://images.unsplash.com/photo-1569183091671-696402586b9c?auto=format&fit=crop&q=80&w=400',
    category: 'badge',
  ),
];
