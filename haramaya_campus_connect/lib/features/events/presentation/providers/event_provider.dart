import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haramaya_campus_connect/features/events/data/repositories/event_repository_impl.dart';
import 'package:haramaya_campus_connect/features/events/domain/enums/event_category.dart';
import 'package:haramaya_campus_connect/features/events/domain/models/event_model.dart';
import 'package:haramaya_campus_connect/features/events/domain/models/registration_model.dart';
import 'package:haramaya_campus_connect/features/events/domain/repositories/event_repository.dart';
import 'package:haramaya_campus_connect/shared/providers/firebase_providers.dart';

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return EventRepositoryImpl(firestore: ref.watch(firestoreProvider));
});

class EventFilterState {
  final EventCategory? category;
  final String searchQuery;
  final bool upcomingOnly;

  const EventFilterState({
    this.category,
    this.searchQuery = '',
    this.upcomingOnly = true,
  });

  EventFilterState copyWith({
    EventCategory? category,
    String? searchQuery,
    bool? upcomingOnly,
    bool clearCategory = false,
  }) {
    return EventFilterState(
      category: clearCategory ? null : (category ?? this.category),
      searchQuery: searchQuery ?? this.searchQuery,
      upcomingOnly: upcomingOnly ?? this.upcomingOnly,
    );
  }
}

class EventFilterNotifier extends StateNotifier<EventFilterState> {
  EventFilterNotifier() : super(const EventFilterState());

  void setCategory(EventCategory? cat) {
    if (state.category == cat) {
      state = state.copyWith(clearCategory: true);
    } else {
      state = state.copyWith(category: cat);
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void toggleUpcomingOnly(bool val) {
    state = state.copyWith(upcomingOnly: val);
  }
}

final eventFilterProvider =
    StateNotifierProvider<EventFilterNotifier, EventFilterState>((ref) {
  return EventFilterNotifier();
});

final eventsStreamProvider = StreamProvider<List<EventModel>>((ref) async* {
  final user = ref.watch(currentFirebaseUserProvider);
  if (user == null) {
    yield [];
    return;
  }

  try {
    await FirebaseAuth.instance.currentUser?.getIdToken();
  } catch (_) {}

  final filter = ref.watch(eventFilterProvider);
  final repo = ref.watch(eventRepositoryProvider);

  int retries = 0;
  while (true) {
    try {
      final stream = repo.getEvents(
        category: filter.category,
        searchQuery: filter.searchQuery,
        upcomingOnly: filter.upcomingOnly,
      );
      await for (final events in stream) {
        yield events;
      }
      break;
    } catch (e) {
      if (retries < 3) {
        retries++;
        await Future.delayed(const Duration(milliseconds: 500));
        continue;
      }
      rethrow;
    }
  }
});

final featuredEventsProvider = StreamProvider<List<EventModel>>((ref) async* {
  final user = ref.watch(currentFirebaseUserProvider);
  if (user == null) {
    yield [];
    return;
  }

  try {
    await FirebaseAuth.instance.currentUser?.getIdToken();
  } catch (_) {}

  final repo = ref.watch(eventRepositoryProvider);

  int retries = 0;
  while (true) {
    try {
      final stream = repo.getFeaturedEvents();
      await for (final events in stream) {
        yield events;
      }
      break;
    } catch (e) {
      if (retries < 3) {
        retries++;
        await Future.delayed(const Duration(milliseconds: 500));
        continue;
      }
      rethrow;
    }
  }
});

final upcomingEventsProvider = StreamProvider<List<EventModel>>((ref) async* {
  final user = ref.watch(currentFirebaseUserProvider);
  if (user == null) {
    yield [];
    return;
  }

  try {
    await FirebaseAuth.instance.currentUser?.getIdToken();
  } catch (_) {}

  final repo = ref.watch(eventRepositoryProvider);

  int retries = 0;
  while (true) {
    try {
      final stream = repo.getUpcomingEvents(limit: 6);
      await for (final events in stream) {
        yield events;
      }
      break;
    } catch (e) {
      if (retries < 3) {
        retries++;
        await Future.delayed(const Duration(milliseconds: 500));
        continue;
      }
      rethrow;
    }
  }
});

final eventDetailProvider =
    FutureProvider.family<EventModel?, String>((ref, eventId) {
  return ref.watch(eventRepositoryProvider).getEventById(eventId);
});

final isUserRegisteredForEventProvider =
    StreamProvider.family<bool, String>((ref, eventId) {
  final user = ref.watch(currentFirebaseUserProvider);
  if (user == null) return Stream.value(false);
  return ref
      .watch(eventRepositoryProvider)
      .isUserRegistered(eventId: eventId, userId: user.uid);
});

final userRegistrationsStreamProvider =
    StreamProvider<List<RegistrationModel>>((ref) {
  final user = ref.watch(currentFirebaseUserProvider);
  if (user == null) return Stream.value([]);
  return ref.watch(eventRepositoryProvider).getUserRegistrations(user.uid);
});

