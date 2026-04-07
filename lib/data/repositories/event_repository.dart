import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dawsha_app/data/models/event_model.dart';
import 'package:dawsha_app/data/repositories/auth_repository.dart';

class EventRepository {
  final SupabaseClient _supabase;

  EventRepository(this._supabase);

  Future<List<EventModel>> getEvents() async {
    try {
      final response = await _supabase
          .from('events')
          .select()
          .order('event_date', ascending: true);
      
      final events = (response as List).map((e) => EventModel.fromJson(e)).toList();
      return events.isNotEmpty ? events : dummyEvents;
    } catch (e) {
      return dummyEvents;
    }
  }
}

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return EventRepository(supabase);
});

final eventsProvider = FutureProvider<List<EventModel>>((ref) async {
  return ref.watch(eventRepositoryProvider).getEvents();
});
