import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:haramaya_campus_connect/features/auth/domain/enums/user_role.dart';

class UserModel {
  final String uid;
  final String email;
  final String fullName;
  final String? studentId;
  final String? phone;
  final String? bio;
  final String? photoUrl;
  final String? department;
  final int? year;
  final UserRole role;
  final List<String> joinedClubIds;
  final List<String> registeredEventIds;
  final String? fcmToken;
  final bool isActive;
  final bool emailVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    this.studentId,
    this.phone,
    this.bio,
    this.photoUrl,
    this.department,
    this.year,
    this.role = UserRole.student,
    this.joinedClubIds = const [],
    this.registeredEventIds = const [],
    this.fcmToken,
    this.isActive = true,
    this.emailVerified = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] as String? ?? '',
      fullName: data['fullName'] as String? ?? '',
      studentId: data['studentId'] as String?,
      phone: data['phone'] as String?,
      bio: data['bio'] as String?,
      photoUrl: data['photoUrl'] as String?,
      department: data['department'] as String?,
      year: data['year'] as int?,
      role: UserRole.fromString(data['role'] as String?),
      joinedClubIds: List<String>.from(data['joinedClubIds'] ?? []),
      registeredEventIds: List<String>.from(data['registeredEventIds'] ?? []),
      fcmToken: data['fcmToken'] as String?,
      isActive: data['isActive'] as bool? ?? true,
      emailVerified: data['emailVerified'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'fullName': fullName,
      'studentId': studentId,
      'phone': phone,
      'bio': bio,
      'photoUrl': photoUrl,
      'department': department,
      'year': year,
      'role': role.value,
      'joinedClubIds': joinedClubIds,
      'registeredEventIds': registeredEventIds,
      'fcmToken': fcmToken,
      'isActive': isActive,
      'emailVerified': emailVerified,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? fullName,
    String? studentId,
    String? phone,
    String? bio,
    String? photoUrl,
    String? department,
    int? year,
    UserRole? role,
    List<String>? joinedClubIds,
    List<String>? registeredEventIds,
    String? fcmToken,
    bool? isActive,
    bool? emailVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      studentId: studentId ?? this.studentId,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      photoUrl: photoUrl ?? this.photoUrl,
      department: department ?? this.department,
      year: year ?? this.year,
      role: role ?? this.role,
      joinedClubIds: joinedClubIds ?? this.joinedClubIds,
      registeredEventIds: registeredEventIds ?? this.registeredEventIds,
      fcmToken: fcmToken ?? this.fcmToken,
      isActive: isActive ?? this.isActive,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Creates a new user model for registration
  factory UserModel.create({
    required String uid,
    required String email,
    required String fullName,
    String? studentId,
    String? department,
    int? year,
  }) {
    final now = DateTime.now();
    return UserModel(
      uid: uid,
      email: email,
      fullName: fullName,
      studentId: studentId,
      department: department,
      year: year,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is UserModel && uid == other.uid;

  @override
  int get hashCode => uid.hashCode;
}

