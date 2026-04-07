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
      // 1. Check user balance first
      final profileRes = await _supabase.from('profiles').select('coins').eq('id', userId).single();
      final currentCoins = profileRes['coins'] as int;
      
      if (currentCoins < price) return false;

      // 2. Perform purchase (In a real app, use an RPC for atomic transaction)
      // For now, we'll do sequential updates
      
      // Add to orders
      await _supabase.from('orders').insert({
        'user_id': userId,
        'item_id': itemId,
        'price_paid': price,
      });

      // Deduct coins
      await _supabase.from('profiles').update({
        'coins': currentCoins - price,
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
