import 'package:flutter/material.dart';
import 'package:dawsha_app/core/constants/app_constants.dart';
import 'package:dawsha_app/data/models/store_item_model.dart';

class StoreItemCard extends StatelessWidget {
  final StoreItemModel item;
  final VoidCallback onTap;
  final bool canAfford;

  const StoreItemCard({
    super.key,
    required this.item,
    required this.onTap,
    this.canAfford = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.isAvailable ? onTap : null,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    item.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported, color: Colors.grey),
                    ),
                  ),
                  if (!item.isAvailable || !canAfford)
                    Container(
                      color: Colors.black.withOpacity(0.5),
                      child: Center(
                        child: Text(
                          !item.isAvailable ? 'غير متوفر' : 'رصيد غير كافٍ',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(item.category),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getCategoryLabel(item.category),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.monetization_on_rounded,
                        color: AppColors.primaryGreen,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${item.price}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: canAfford ? AppColors.primaryGreen : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'gear':
        return Colors.blue;
      case 'voucher':
        return Colors.orange;
      case 'badge':
        return Colors.purple;
      default:
        return AppColors.primaryGreen;
    }
  }

  String _getCategoryLabel(String category) {
    switch (category) {
      case 'gear':
        return 'أدوات';
      case 'voucher':
        return 'قسائم';
      case 'badge':
        return 'شارات';
      default:
        return 'أخرى';
    }
  }
}
