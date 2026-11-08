import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:haramaya_campus_connect/features/events/domain/enums/event_category.dart';

class EventModel {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final EventCategory category;
  final EventStatus status;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final String location;
  final String? locationDetails;
  final int capacity;
  final int registeredCount;
  final String organizerId;
  final String organizerName;
  final String? clubId;
  final String? clubName;
  final List<String> tags;
  final bool isFeatured;
  final bool requiresRegistration;
  final DateTime createdAt;
  final DateTime updatedAt;

  const EventModel({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.category,
    this.status = EventStatus.published,
    required this.startDateTime,
    required this.endDateTime,
    required this.location,
    this.locationDetails,
    required this.capacity,
    this.registeredCount = 0,
    required this.organizerId,
    required this.organizerName,
    this.clubId,
    this.clubName,
    this.tags = const [],
    this.isFeatured = false,
    this.requiresRegistration = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EventModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EventModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      imageUrl: data['imageUrl'] as String?,
      category: EventCategory.fromString(data['category'] as String?),
      status: EventStatus.fromString(data['status'] as String?),
      startDateTime: (data['startDateTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDateTime: (data['endDateTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      location: data['location'] as String? ?? '',
      locationDetails: data['locationDetails'] as String?,
      capacity: data['capacity'] as int? ?? 0,
      registeredCount: data['registeredCount'] as int? ?? 0,
      organizerId: data['organizerId'] as String? ?? '',
      organizerName: data['organizerName'] as String? ?? '',
      clubId: data['clubId'] as String?,
      clubName: data['clubName'] as String?,
      tags: List<String>.from(data['tags'] ?? []),
      isFeatured: data['isFeatured'] as bool? ?? false,
      requiresRegistration: data['requiresRegistration'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'category': category.value,
      'status': status.value,
      'startDateTime': Timestamp.fromDate(startDateTime),
      'endDateTime': Timestamp.fromDate(endDateTime),
      'location': location,
      'locationDetails': locationDetails,
      'capacity': capacity,
      'registeredCount': registeredCount,
      'organizerId': organizerId,
      'organizerName': organizerName,
      'clubId': clubId,
      'clubName': clubName,
      'tags': tags,
      'isFeatured': isFeatured,
      'requiresRegistration': requiresRegistration,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    EventCategory? category,
    EventStatus? status,
    DateTime? startDateTime,
    DateTime? endDateTime,
    String? location,
    String? locationDetails,
    int? capacity,
    int? registeredCount,
    String? organizerId,
    String? organizerName,
    String? clubId,
    String? clubName,
    List<String>? tags,
    bool? isFeatured,
    bool? requiresRegistration,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      status: status ?? this.status,
      startDateTime: startDateTime ?? this.startDateTime,
      endDateTime: endDateTime ?? this.endDateTime,
      location: location ?? this.location,
      locationDetails: locationDetails ?? this.locationDetails,
      capacity: capacity ?? this.capacity,
      registeredCount: registeredCount ?? this.registeredCount,
      organizerId: organizerId ?? this.organizerId,
      organizerName: organizerName ?? this.organizerName,
      clubId: clubId ?? this.clubId,
      clubName: clubName ?? this.clubName,
      tags: tags ?? this.tags,
      isFeatured: isFeatured ?? this.isFeatured,
      requiresRegistration: requiresRegistration ?? this.requiresRegistration,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isFull => registeredCount >= capacity;
  bool get isUpcoming => startDateTime.isAfter(DateTime.now());
  bool get isPast => endDateTime.isBefore(DateTime.now());
  bool get isOngoing =>
      DateTime.now().isAfter(startDateTime) && DateTime.now().isBefore(endDateTime);
  int get spotsLeft => (capacity - registeredCount).clamp(0, capacity);
  double get fillPercentage => capacity > 0 ? registeredCount / capacity : 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is EventModel && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

