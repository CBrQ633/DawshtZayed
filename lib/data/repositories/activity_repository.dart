import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dawsha_app/data/models/activity_model.dart';
import 'package:dawsha_app/data/repositories/auth_repository.dart';

class ActivityRepository {
  final SupabaseClient _supabase;

  ActivityRepository(this._supabase);

  Future<void> saveActivity(ActivityModel activity) async {
    // Activities are now handled by a database trigger (tr_on_activity_saved)
    // which automatically updates profiles (stats, xp, coins) and challenge progress.
    await _supabase.from('activities').insert(activity.toJson());
  }

  // Get user activities
  Future<List<ActivityModel>> getActivities(String userId) async {
    final response = await _supabase
        .from('activities')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    
    return (response as List).map((e) => ActivityModel.fromJson(e)).toList();
  }

  // Stream of new activities for the feed (can be moved to FeedRepository later)
  Stream<List<ActivityModel>> getRecentActivities() {
    return _supabase
        .from('activities')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .limit(20)
        .map((event) => event.map((e) => ActivityModel.fromJson(e)).toList());
  }
}

// Provider for Activity repository
final activityRepositoryProvider = Provider<ActivityRepository>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return ActivityRepository(supabase);
});

// User activities provider
final userActivitiesProvider = FutureProvider<List<ActivityModel>>((ref) async {
  final user = ref.watch(authRepositoryProvider).currentUser;
  if (user != null) {
    return ref.watch(activityRepositoryProvider).getActivities(user.id);
  }
  return [];
});
