import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dawsha_app/core/constants/app_constants.dart';
import 'package:dawsha_app/data/models/store_item_model.dart';
import 'package:dawsha_app/data/repositories/store_repository.dart';
import 'package:dawsha_app/data/repositories/profile_repository.dart';
import 'package:dawsha_app/features/store/presentation/widgets/balance_header.dart';
import 'package:dawsha_app/features/store/presentation/widgets/store_item_card.dart';

class StoreScreen extends ConsumerStatefulWidget {
  const StoreScreen({super.key});

  @override
  ConsumerState<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends ConsumerState<StoreScreen> {
  String selectedCategory = 'all';

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentUserProfileProvider);
    final userBalance = profileAsync.value?.coins ?? 0;
    
    final storeItemsAsync = ref.watch(storeItemsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('المتجر', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: AppColors.primaryGreen)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: BalanceHeader(balance: userBalance),
          ),
          SliverToBoxAdapter(
            child: _buildCategories(),
          ),
          storeItemsAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)),
            ),
            error: (err, stack) => SliverFillRemaining(
              child: Center(child: Text('خطأ في تحميل المتجر: $err')),
            ),
            data: (items) {
              final filteredItems = selectedCategory == 'all'
                  ? items
                  : items.where((item) => item.category == selectedCategory).toList();

              if (filteredItems.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: Text('لا توجد منتجات في هذا القسم حالياً.')),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = filteredItems[index];
                      return StoreItemCard(
                        item: item,
                        canAfford: userBalance >= item.price,
                        onTap: () => _showPurchaseDialog(context, item, userBalance),
                      );
                    },
                    childCount: filteredItems.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    final categories = [
      {'id': 'all', 'label': 'الكل'},
      {'id': 'gear', 'label': 'أدوات رياضية'},
      {'id': 'voucher', 'label': 'قسائم شراء'},
      {'id': 'badge', 'label': 'شارات'},
    ];

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = selectedCategory == cat['id'];
          return Padding(
            padding: const EdgeInsets.only(left: 8),
            child: ChoiceChip(
              label: Text(
                cat['label']!,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              selectedColor: AppColors.primaryGreen,
              backgroundColor: AppColors.surface,
              onSelected: (selected) {
                if (selected) {
                  setState(() => selectedCategory = cat['id']!);
                }
              },
            ),
          );
        },
      ),
    );
  }

  void _showPurchaseDialog(BuildContext context, StoreItemModel item, int balance) {
    if (balance < item.price) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('رصيدك لا يكفي لإتمام هذه العملية!')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الشراء', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('هل أنت متأكد من شراء "${item.name}" مقابل ${item.price} عملة؟'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              final profile = ref.read(currentUserProfileProvider).value;
              if (profile == null) return;

              final success = await ref.read(storeRepositoryProvider).purchaseItem(
                item.id, 
                item.price, 
                profile.id,
              );

              if (success) {
                // Refresh profile to see new balance
                ref.invalidate(currentUserProfileProvider);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم شراء "${item.name}" بنجاح! 🎉'),
                    backgroundColor: AppColors.primaryGreen,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('حدث خطأ أثناء إتمام عملية الشراء.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('شراء', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
