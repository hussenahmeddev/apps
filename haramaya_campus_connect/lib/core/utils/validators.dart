/// Input validators for forms throughout the app.
class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (value.trim().length > 50) {
      return 'Name must be less than 50 characters';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Phone is optional
    }
    final phoneRegex = RegExp(r'^\+?[\d\s-]{7,15}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  static String? studentId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Student ID is required';
    }
    if (value.trim().length < 4) {
      return 'Enter a valid student ID';
    }
    return null;
  }

  static String? eventCapacity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Capacity is required';
    }
    final capacity = int.tryParse(value.trim());
    if (capacity == null || capacity < 1) {
      return 'Enter a valid capacity (minimum 1)';
    }
    if (capacity > 10000) {
      return 'Maximum capacity is 10,000';
    }
    return null;
  }

  static String? maxLength(String? value, int maxLen, [String fieldName = 'This field']) {
    if (value != null && value.length > maxLen) {
      return '$fieldName must be less than $maxLen characters';
    }
    return null;
  }
}

