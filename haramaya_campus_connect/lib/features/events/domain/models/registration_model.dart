import 'package:cloud_firestore/cloud_firestore.dart';

enum RegistrationStatus {
  registered('registered', 'Registered'),
  cancelled('cancelled', 'Cancelled'),
  attended('attended', 'Attended');

  final String value;
  final String displayName;

  const RegistrationStatus(this.value, this.displayName);

  static RegistrationStatus fromString(String? value) {
    return RegistrationStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () => RegistrationStatus.registered,
    );
  }
}

class RegistrationModel {
  final String id;
  final String eventId;
  final String eventTitle;
  final String userId;
  final String userName;
  final RegistrationStatus status;
  final DateTime registeredAt;
  final DateTime? cancelledAt;

  const RegistrationModel({
    required this.id,
    required this.eventId,
    required this.eventTitle,
    required this.userId,
    required this.userName,
    this.status = RegistrationStatus.registered,
    required this.registeredAt,
    this.cancelledAt,
  });

  factory RegistrationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RegistrationModel(
      id: doc.id,
      eventId: data['eventId'] as String? ?? '',
      eventTitle: data['eventTitle'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      userName: data['userName'] as String? ?? '',
      status: RegistrationStatus.fromString(data['status'] as String?),
      registeredAt: (data['registeredAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      cancelledAt: (data['cancelledAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'eventId': eventId,
      'eventTitle': eventTitle,
      'userId': userId,
      'userName': userName,
      'status': status.value,
      'registeredAt': Timestamp.fromDate(registeredAt),
      'cancelledAt': cancelledAt != null ? Timestamp.fromDate(cancelledAt!) : null,
    };
  }

  RegistrationModel copyWith({
    String? id,
    String? eventId,
    String? eventTitle,
    String? userId,
    String? userName,
    RegistrationStatus? status,
    DateTime? registeredAt,
    DateTime? cancelledAt,
  }) {
    return RegistrationModel(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      eventTitle: eventTitle ?? this.eventTitle,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      status: status ?? this.status,
      registeredAt: registeredAt ?? this.registeredAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
    );
  }

  bool get isActive => status == RegistrationStatus.registered;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is RegistrationModel && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

