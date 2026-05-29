import 'package:banjarin/core/error/failures.dart';
import 'package:banjarin/core/network/api_error_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApiErrorMapper.mapCode', () {
    test('VALIDATION_ERROR returns ValidationFailure with field errors', () {
      final result = ApiErrorMapper.mapCode(
        'VALIDATION_ERROR',
        'Invalid data',
        {
          'email': ['Email tidak valid'],
          'password': ['Minimal 8 karakter'],
        },
      );

      expect(result, isA<ValidationFailure>());
      final vf = result as ValidationFailure;
      expect(vf.message, 'Invalid data');
      expect(vf.fieldErrors['email'], contains('Email tidak valid'));
      expect(vf.fieldErrors['password'], contains('Minimal 8 karakter'));
    });

    test('VALIDATION_ERROR with null details returns empty fieldErrors', () {
      final result = ApiErrorMapper.mapCode(
        'VALIDATION_ERROR',
        'Invalid',
        null,
      );

      expect(result, isA<ValidationFailure>());
      expect((result as ValidationFailure).fieldErrors, isEmpty);
    });

    test('UNAUTHORIZED returns UnauthorizedFailure', () {
      final result = ApiErrorMapper.mapCode(
        'UNAUTHORIZED',
        'Auth required',
        null,
      );
      expect(result, isA<UnauthorizedFailure>());
      expect(result.message, 'Auth required');
    });

    test('FORBIDDEN returns ForbiddenFailure', () {
      final result =
          ApiErrorMapper.mapCode('FORBIDDEN', 'No permission', null);
      expect(result, isA<ForbiddenFailure>());
    });

    test('NOT_FOUND returns NotFoundFailure', () {
      final result =
          ApiErrorMapper.mapCode('NOT_FOUND', 'Not found', null);
      expect(result, isA<NotFoundFailure>());
    });

    test('CONFLICT returns ConflictFailure', () {
      final result =
          ApiErrorMapper.mapCode('CONFLICT', 'Already exists', null);
      expect(result, isA<ConflictFailure>());
    });

    test('RATE_LIMITED returns RateLimitedFailure with retryAfterSeconds', () {
      final result = ApiErrorMapper.mapCode(
        'RATE_LIMITED',
        'Too many requests',
        {'retry_after': 120},
      );

      expect(result, isA<RateLimitedFailure>());
      expect((result as RateLimitedFailure).retryAfterSeconds, 120);
    });

    test(
        'RATE_LIMITED defaults retryAfterSeconds to 60 when not in details', () {
      final result = ApiErrorMapper.mapCode(
        'RATE_LIMITED',
        'Too many requests',
        null,
      );

      expect(result, isA<RateLimitedFailure>());
      expect((result as RateLimitedFailure).retryAfterSeconds, 60);
    });

    test(
        'RATE_LIMITED defaults retryAfterSeconds to 60 when retry_after is absent',
        () {
      final result = ApiErrorMapper.mapCode(
        'RATE_LIMITED',
        'Too many requests',
        {'other_key': 'value'},
      );

      expect(result, isA<RateLimitedFailure>());
      expect((result as RateLimitedFailure).retryAfterSeconds, 60);
    });

    test('AI_UNAVAILABLE returns AIUnavailableFailure', () {
      final result =
          ApiErrorMapper.mapCode('AI_UNAVAILABLE', 'AI down', null);
      expect(result, isA<AIUnavailableFailure>());
    });

    test('INTERNAL_ERROR returns ServerFailure', () {
      final result =
          ApiErrorMapper.mapCode('INTERNAL_ERROR', 'Server error', null);
      expect(result, isA<ServerFailure>());
    });

    test('unknown code returns ServerFailure', () {
      final result = ApiErrorMapper.mapCode('UNKNOWN_CODE', 'Unknown', null);
      expect(result, isA<ServerFailure>());
    });
  });
}
