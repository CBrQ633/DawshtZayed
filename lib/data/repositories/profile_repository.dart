import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dawsha_app/data/models/profile_model.dart';
import 'package:dawsha_app/data/repositories/auth_repository.dart';

class ProfileRepository {
  final SupabaseClient _supabase;

  ProfileRepository(this._supabase);

  // Fetch current user profile
  Future<ProfileModel?> getProfile(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      
      return ProfileModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // Update profile data
  Future<void> updateProfile(ProfileModel profile) async {
    await _supabase
        .from('profiles')
        .update(profile.toJson())
        .eq('id', profile.id);
  }

  // Stream of profile updates
  Stream<ProfileModel?> profileStream(String userId) {
    return _supabase
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('id', userId)
        .map((event) => event.isNotEmpty ? ProfileModel.fromJson(event.first) : null);
  }

  // Fetch leaderboard users (ranked by total_km)
  Future<List<ProfileModel>> getLeaderboard({int limit = 50}) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .order('total_km', ascending: false)
          .limit(limit);
      
      return (response as List).map((e) => ProfileModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }
}

// Provider for Profile repository
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return ProfileRepository(supabase);
});

// Current user profile provider
final currentUserProfileProvider = FutureProvider<ProfileModel?>((ref) async {
  final authState = ref.watch(authStateProvider);
  final user = authState.value?.session?.user;
  
  if (user != null) {
    return ref.watch(profileRepositoryProvider).getProfile(user.id);
  }
  return null;
});

// Leaderboard provider
final leaderboardProvider = FutureProvider<List<ProfileModel>>((ref) async {
  return ref.watch(profileRepositoryProvider).getLeaderboard();
});
