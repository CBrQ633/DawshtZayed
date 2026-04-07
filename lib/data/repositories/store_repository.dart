import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dawsha_app/data/models/store_item_model.dart';
import 'package:dawsha_app/data/repositories/auth_repository.dart';

class StoreRepository {
  final SupabaseClient _supabase;

  StoreRepository(this._supabase);

  Future<List<StoreItemModel>> getStoreItems() async {
    try {
      final response = await _supabase
          .from('store_items')
          .select()
          .eq('is_available', true);
          
      final items = (response as List).map((e) => StoreItemModel.fromJson(e)).toList();
      return items.isNotEmpty ? items : dummyStoreItems;
    } catch (e) {
      return dummyStoreItems;
    }
  }

  Future<bool> purchaseItem(String itemId, int price, String userId) async {
    try {
      final response = await _supabase.rpc(
        'rpc_purchase_item',
        params: {
          'p_item_id': itemId,
          'p_user_id': userId,
          'p_price': price,
        },
      );

      return response['success'] ?? false;
    } catch (e) {
      print('Error purchasing item: $e');
      return false;
    }
  }
}

final storeRepositoryProvider = Provider<StoreRepository>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return StoreRepository(supabase);
});

final storeItemsProvider = FutureProvider<List<StoreItemModel>>((ref) async {
  return ref.watch(storeRepositoryProvider).getStoreItems();
});
