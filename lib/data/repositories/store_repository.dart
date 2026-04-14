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
          .eq('is_available', true)
          .order('created_at', ascending: false);
          
      final items = (response as List).map((e) => StoreItemModel.fromJson(e)).toList();
      return items.isNotEmpty ? items : dummyStoreItems;
    } catch (e) {
      return dummyStoreItems;
    }
  }

  Future<bool> purchaseItem(String itemId, int price, String userId) async {
    try {
      // Step 1: Check user balance
      final profileResponse = await _supabase
          .from('profiles')
          .select('coins')
          .eq('id', userId)
          .single();
      
      final currentCoins = profileResponse['coins'] as int? ?? 0;
      
      if (currentCoins < price) return false;

      // Step 2: Record purchase in the new 'purchases' table
      await _supabase.from('purchases').insert({
        'user_id': userId,
        'item_id': itemId,
        'price_paid': price,
        'status': 'pending',
      });

      // Step 3: Deduct coins from profile
      await _supabase.from('profiles').update({
        'coins': currentCoins - price
      }).eq('id', userId);
      
      return true;
    } catch (e) {
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
