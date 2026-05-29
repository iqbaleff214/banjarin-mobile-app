import '../error/failures.dart';

class ApiErrorMapper {
  ApiErrorMapper._();

  static Failure mapCode(
    String code,
    String message,
    Map<String, dynamic>? details,
  ) {
    switch (code) {
      case 'VALIDATION_ERROR':
        final fieldErrors = <String, List<String>>{};
        if (details != null) {
          details.forEach((key, value) {
            if (value is List) {
              fieldErrors[key] = value.whereType<String>().toList();
            }
          });
        }
        return ValidationFailure(fieldErrors: fieldErrors, message: message);

      case 'UNAUTHORIZED':
        return UnauthorizedFailure(message);

      case 'FORBIDDEN':
        return ForbiddenFailure(message);

      case 'NOT_FOUND':
        return NotFoundFailure(message);

      case 'CONFLICT':
        return ConflictFailure(message);

      case 'RATE_LIMITED':
        final retryAfter = details?['retry_after'];
        final retryAfterSeconds =
            retryAfter is int ? retryAfter : 60;
        return RateLimitedFailure(
          retryAfterSeconds: retryAfterSeconds,
          message: message,
        );

      case 'AI_UNAVAILABLE':
        return AIUnavailableFailure(message);

      default:
        return ServerFailure(message);
    }
  }
}
