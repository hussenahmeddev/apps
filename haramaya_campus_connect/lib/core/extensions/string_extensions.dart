extension StringExtensions on String {
  /// Capitalizes the first letter
  String get capitalized {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Capitalizes each word
  String get titleCase {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalized).join(' ');
  }

  /// Returns initials (up to 2 characters)
  String get initials {
    if (isEmpty) return '';
    final words = trim().split(RegExp(r'\s+'));
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return words[0][0].toUpperCase();
  }

  /// Truncates with ellipsis
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }

  /// Checks if string is a valid email
  bool get isValidEmail {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(this);
  }

  /// Returns null if empty, otherwise returns trimmed string
  String? get nullIfEmpty {
    final trimmed = trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

