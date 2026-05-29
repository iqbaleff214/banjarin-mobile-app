import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'An unexpected server error occurred.']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network connection failed.']);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Authentication required.']);
}

class ForbiddenFailure extends Failure {
  const ForbiddenFailure(
      [super.message =
          'You do not have permission to perform this action.']);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(
      [super.message = 'The requested resource was not found.']);
}

class ConflictFailure extends Failure {
  const ConflictFailure([super.message = 'Resource already exists.']);
}

class RateLimitedFailure extends Failure {
  final int retryAfterSeconds;

  const RateLimitedFailure({
    this.retryAfterSeconds = 60,
    String message = 'Too many requests. Please slow down.',
  }) : super(message);

  @override
  List<Object?> get props => [message, retryAfterSeconds];
}

class ValidationFailure extends Failure {
  final Map<String, List<String>> fieldErrors;

  const ValidationFailure({
    required this.fieldErrors,
    String message = 'The given data was invalid.',
  }) : super(message);

  @override
  List<Object?> get props => [message, fieldErrors];
}

class AIUnavailableFailure extends Failure {
  const AIUnavailableFailure(
      [super.message = 'AI service is temporarily unavailable.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache operation failed.']);
}
