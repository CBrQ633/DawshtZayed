import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dawsha_app/data/models/event_model.dart';
import 'package:dawsha_app/data/repositories/auth_repository.dart';

class EventRepository {
  final SupabaseClient _supabase;

  EventRepository(this._supabase);

  Future<List<EventModel>> getEvents(String? userId) async {
    try {
      final response = await _supabase
          .from('events')
          .select('*, event_participants(user_id)')
          .order('event_date', ascending: true);
      
      return (response as List).map((e) {
        final participants = (e['event_participants'] as List?) ?? [];
        final isJoined = userId != null && participants.any((p) => p['user_id'] == userId);
        
        return EventModel.fromJson({
          ...e,
          'is_joined_by_me': isJoined,
        });
      }).toList();
    } catch (e) {
      return dummyEvents;
    }
  }

  Future<bool> toggleJoinEvent(String eventId, String userId, bool currentlyJoined) async {
    try {
      if (currentlyJoined) {
        await _supabase
            .from('event_participants')
            .delete()
            .match({'event_id': eventId, 'user_id': userId});
      } else {
        await _supabase
            .from('event_participants')
            .insert({'event_id': eventId, 'user_id': userId});
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return EventRepository(supabase);
});

final eventsProvider = FutureProvider<List<EventModel>>((ref) async {
  final user = ref.watch(authStateProvider).value?.session?.user;
  return ref.watch(eventRepositoryProvider).getEvents(user?.id);
});
