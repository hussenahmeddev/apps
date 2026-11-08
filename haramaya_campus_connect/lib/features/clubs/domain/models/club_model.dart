import 'package:cloud_firestore/cloud_firestore.dart';

class ClubModel {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final String? coverImageUrl;
  final String category;
  final String organizerId;
  final String organizerName;
  final int memberCount;
  final List<String> memberIds;
  final bool isActive;
  final String? meetingSchedule;
  final String? contactEmail;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ClubModel({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    this.coverImageUrl,
    required this.category,
    required this.organizerId,
    required this.organizerName,
    this.memberCount = 0,
    this.memberIds = const [],
    this.isActive = true,
    this.meetingSchedule,
    this.contactEmail,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ClubModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ClubModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      description: data['description'] as String? ?? '',
      imageUrl: data['imageUrl'] as String?,
      coverImageUrl: data['coverImageUrl'] as String?,
      category: data['category'] as String? ?? 'General',
      organizerId: data['organizerId'] as String? ?? '',
      organizerName: data['organizerName'] as String? ?? '',
      memberCount: data['memberCount'] as int? ?? 0,
      memberIds: List<String>.from(data['memberIds'] ?? []),
      isActive: data['isActive'] as bool? ?? true,
      meetingSchedule: data['meetingSchedule'] as String?,
      contactEmail: data['contactEmail'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'coverImageUrl': coverImageUrl,
      'category': category,
      'organizerId': organizerId,
      'organizerName': organizerName,
      'memberCount': memberCount,
      'memberIds': memberIds,
      'isActive': isActive,
      'meetingSchedule': meetingSchedule,
      'contactEmail': contactEmail,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  ClubModel copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    String? coverImageUrl,
    String? category,
    String? organizerId,
    String? organizerName,
    int? memberCount,
    List<String>? memberIds,
    bool? isActive,
    String? meetingSchedule,
    String? contactEmail,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ClubModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      category: category ?? this.category,
      organizerId: organizerId ?? this.organizerId,
      organizerName: organizerName ?? this.organizerName,
      memberCount: memberCount ?? this.memberCount,
      memberIds: memberIds ?? this.memberIds,
      isActive: isActive ?? this.isActive,
      meetingSchedule: meetingSchedule ?? this.meetingSchedule,
      contactEmail: contactEmail ?? this.contactEmail,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool isMember(String userId) => memberIds.contains(userId);
  bool isOrganizer(String userId) => organizerId == userId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ClubModel && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

