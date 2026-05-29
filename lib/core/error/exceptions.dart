class ServerException implements Exception {
  final String code;
  final String message;
  final Map<String, dynamic>? details;

  const ServerException({
    required this.code,
    required this.message,
    this.details,
  });

  @override
  String toString() => 'ServerException(code: $code, message: $message)';
}

class CacheException implements Exception {
  final String message;

  const CacheException(this.message);

  @override
  String toString() => 'CacheException($message)';
}

class NetworkException implements Exception {
  final String message;

  const NetworkException(this.message);

  @override
  String toString() => 'NetworkException($message)';
}
