// Custom exceptions for data layer errors.

class ServerException implements Exception {
  final String message;
  final String? code;

  const ServerException({required this.message, this.code});

  @override
  String toString() => 'ServerException($code): $message';
}

class CacheException implements Exception {
  final String message;

  const CacheException({required this.message});

  @override
  String toString() => 'CacheException: $message';
}

class AuthException implements Exception {
  final String message;
  final String? code;

  const AuthException({required this.message, this.code});

  @override
  String toString() => 'AuthException($code): $message';
}

class StorageException implements Exception {
  final String message;
  final String? code;

  const StorageException({required this.message, this.code});

  @override
  String toString() => 'StorageException($code): $message';
}

class ValidationException implements Exception {
  final String message;
  final Map<String, String>? fieldErrors;

  const ValidationException({required this.message, this.fieldErrors});

  @override
  String toString() => 'ValidationException: $message';
}
