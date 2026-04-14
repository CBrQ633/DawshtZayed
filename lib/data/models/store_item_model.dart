class StoreItemModel {
  final String id;
  final String name;
  final String description;
  final int priceInCoins;
  final int? discountPercentage;
  final String imageUrl;
  final String category; // 'gear', 'voucher', 'badge'
  final String? storeName; // e.g., 'Adidas', 'Nike'
  final bool isAvailable;

  StoreItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.priceInCoins,
    this.discountPercentage,
    required this.imageUrl,
    required this.category,
    this.storeName,
    this.isAvailable = true,
  });

  factory StoreItemModel.fromJson(Map<String, dynamic> json) {
    return StoreItemModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      priceInCoins: json['price_in_coins'] ?? json['price'] ?? 0,
      discountPercentage: json['discount_percentage'],
      imageUrl: json['image_url'] ?? '',
      category: json['category'] ?? '',
      storeName: json['store_name'],
      isAvailable: json['is_available'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price_in_coins': priceInCoins,
      'discount_percentage': discountPercentage,
      'image_url': imageUrl,
      'category': category,
      'store_name': storeName,
      'is_available': isAvailable,
    };
  }
}

// Dummy Store Items Updated
final List<StoreItemModel> dummyStoreItems = [
  StoreItemModel(
    id: '1',
    name: 'خصم 50% على الأحذية',
    description: 'قسيمة خصم حصرية للأعضاء على أي حذاء رياضي.',
    priceInCoins: 500,
    discountPercentage: 50,
    storeName: 'Adidas',
    imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&q=80&w=400',
    category: 'voucher',
  ),
  StoreItemModel(
    id: '2',
    name: 'تيشيرت دوشة الرسمي',
    description: 'تيشيرت رياضي أصلي بشعار مجتمع دوشة.',
    priceInCoins: 300,
    storeName: 'Dawsha Official',
    imageUrl: 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?auto=format&fit=crop&q=80&w=400',
    category: 'gear',
  ),
  StoreItemModel(
    id: '3',
    name: 'قسيمة شراء 100 ج.م',
    description: 'قسيمة شرائية صالحة للاستخدام في جميع فروعنا.',
    priceInCoins: 1000,
    storeName: 'Nike',
    imageUrl: 'https://images.unsplash.com/photo-1549298916-b41d501d3772?auto=format&fit=crop&q=80&w=400',
    category: 'voucher',
  ),
];
