import 'package:haramaya_campus_connect/features/events/domain/enums/event_category.dart';
import 'package:haramaya_campus_connect/features/events/domain/models/event_model.dart';
import 'package:haramaya_campus_connect/features/events/domain/models/registration_model.dart';

abstract class EventRepository {
  Stream<List<EventModel>> getEvents({
    EventCategory? category,
    String? searchQuery,
    bool upcomingOnly = true,
  });
  Future<EventModel?> getEventById(String eventId);
  Stream<List<EventModel>> getFeaturedEvents();
  Stream<List<EventModel>> getUpcomingEvents({int limit = 10});
  Future<String> createEvent(EventModel event);
  Future<void> updateEvent(EventModel event);
  Future<void> deleteEvent(String eventId);

  // Registrations with atomic capacity check
  Future<void> registerForEvent({
    required String eventId,
    required String userId,
    required String userName,
  });
  Future<void> cancelRegistration({
    required String eventId,
    required String userId,
  });
  Stream<bool> isUserRegistered({
    required String eventId,
    required String userId,
  });
  Stream<List<RegistrationModel>> getUserRegistrations(String userId);
}

