import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dawsha_app/data/models/challenge_model.dart';
import 'package:dawsha_app/data/repositories/auth_repository.dart';

class ChallengeRepository {
  final SupabaseClient _supabase;

  ChallengeRepository(this._supabase);

  // Fetch all active challenges
  Future<List<ChallengeModel>> getActiveChallenges() async {
    try {
      final response = await _supabase
          .from('challenges')
          .select()
          .order('created_at', ascending: false);
      
      return (response as List).map((e) => ChallengeModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  // Fetch user's joined challenges
  Future<List<ChallengeParticipantModel>> getJoinedChallenges(String userId) async {
    try {
      final response = await _supabase
          .from('challenge_participants')
          .select()
          .eq('user_id', userId);
      
      return (response as List).map((e) => ChallengeParticipantModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  // Join a challenge
  Future<void> joinChallenge(String challengeId, String userId) async {
    await _supabase.from('challenge_participants').insert({
      'challenge_id': challengeId,
      'user_id': userId,
    });
  }
}

final challengeRepositoryProvider = Provider<ChallengeRepository>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return ChallengeRepository(supabase);
});

final activeChallengesProvider = FutureProvider<List<ChallengeModel>>((ref) async {
  return ref.watch(challengeRepositoryProvider).getActiveChallenges();
});

final userChallengesProvider = FutureProvider<List<ChallengeParticipantModel>>((ref) async {
  final user = ref.watch(authStateProvider).value?.session?.user;
  if (user != null) {
    return ref.watch(challengeRepositoryProvider).getJoinedChallenges(user.id);
  }
  return [];
});
