/// User roles with hierarchical permission levels.
enum UserRole {
  student('student', 'Student'),
  clubOrganizer('club_organizer', 'Club Organizer'),
  admin('admin', 'Admin');

  final String value;
  final String displayName;

  const UserRole(this.value, this.displayName);

  /// Parses a string to UserRole, defaults to student.
  static UserRole fromString(String? value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.student,
    );
  }

  bool get isAdmin => this == UserRole.admin;
  bool get isOrganizer => this == UserRole.clubOrganizer || this == UserRole.admin;
  bool get isStudent => this == UserRole.student;

  /// Returns true if this role has at least the same privileges as [other].
  bool hasPermission(UserRole other) {
    return index >= other.index;
  }
}

