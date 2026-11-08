import 'package:haramaya_campus_connect/features/clubs/domain/models/club_model.dart';
import 'package:haramaya_campus_connect/features/events/domain/models/event_model.dart';

abstract class ClubRepository {
  Stream<List<ClubModel>> getClubs({String? category, String? searchQuery});
  Future<ClubModel?> getClubById(String clubId);
  Stream<List<ClubModel>> getPopularClubs({int limit = 8});
  Stream<List<ClubModel>> getUserClubs(String userId);
  Future<String> createClub(ClubModel club);
  Future<void> updateClub(ClubModel club);
  Future<void> joinClub({required String clubId, required String userId});
  Future<void> leaveClub({required String clubId, required String userId});
  Stream<List<EventModel>> getClubEvents(String clubId);
}

