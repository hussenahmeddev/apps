import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haramaya_campus_connect/features/clubs/data/repositories/club_repository_impl.dart';
import 'package:haramaya_campus_connect/features/clubs/domain/models/club_model.dart';
import 'package:haramaya_campus_connect/features/clubs/domain/repositories/club_repository.dart';
import 'package:haramaya_campus_connect/features/events/domain/models/event_model.dart';
import 'package:haramaya_campus_connect/shared/providers/firebase_providers.dart';

final clubRepositoryProvider = Provider<ClubRepository>((ref) {
  return ClubRepositoryImpl(firestore: ref.watch(firestoreProvider));
});

class ClubFilterState {
  final String category;
  final String searchQuery;

  const ClubFilterState({this.category = 'All', this.searchQuery = ''});

  ClubFilterState copyWith({String? category, String? searchQuery}) {
    return ClubFilterState(
      category: category ?? this.category,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class ClubFilterNotifier extends StateNotifier<ClubFilterState> {
  ClubFilterNotifier() : super(const ClubFilterState());

  void setCategory(String category) =>
      state = state.copyWith(category: category);
  void setSearch(String query) => state = state.copyWith(searchQuery: query);
}

final clubFilterProvider =
    StateNotifierProvider<ClubFilterNotifier, ClubFilterState>((ref) {
  return ClubFilterNotifier();
});

final clubsStreamProvider = StreamProvider<List<ClubModel>>((ref) async* {
  final user = ref.watch(currentFirebaseUserProvider);
  if (user == null) {
    yield [];
    return;
  }

  try {
    await FirebaseAuth.instance.currentUser?.getIdToken();
  } catch (_) {}

  final filter = ref.watch(clubFilterProvider);
  final repo = ref.watch(clubRepositoryProvider);

  int retries = 0;
  while (true) {
    try {
      final stream = repo.getClubs(
        category: filter.category,
        searchQuery: filter.searchQuery,
      );
      await for (final clubs in stream) {
        yield clubs;
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

final popularClubsProvider = StreamProvider<List<ClubModel>>((ref) async* {
  final user = ref.watch(currentFirebaseUserProvider);
  if (user == null) {
    yield [];
    return;
  }

  try {
    await FirebaseAuth.instance.currentUser?.getIdToken();
  } catch (_) {}

  final repo = ref.watch(clubRepositoryProvider);

  int retries = 0;
  while (true) {
    try {
      final stream = repo.getPopularClubs(limit: 8);
      await for (final clubs in stream) {
        yield clubs;
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

final clubDetailProvider =
    FutureProvider.family<ClubModel?, String>((ref, clubId) {
  return ref.watch(clubRepositoryProvider).getClubById(clubId);
});

final userJoinedClubsProvider = StreamProvider<List<ClubModel>>((ref) {
  final user = ref.watch(currentFirebaseUserProvider);
  if (user == null) return Stream.value([]);
  return ref.watch(clubRepositoryProvider).getUserClubs(user.uid);
});

final isUserClubMemberProvider = Provider.family<bool, ClubModel>((ref, club) {
  final user = ref.watch(currentFirebaseUserProvider);
  if (user == null) return false;
  return club.isMember(user.uid);
});

final clubEventsProvider =
    StreamProvider.family<List<EventModel>, String>((ref, clubId) {
  return ref.watch(clubRepositoryProvider).getClubEvents(clubId);
});
