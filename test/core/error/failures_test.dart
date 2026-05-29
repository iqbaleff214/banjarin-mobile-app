import 'package:banjarin/core/error/failures.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Failure subtypes', () {
    test('are distinct types', () {
      const f1 = ServerFailure('error');
      const f2 = NetworkFailure('error');
      expect(f1, isNot(equals(f2)));
    });

    test('two failures of same type with same message are equal', () {
      const f1 = ServerFailure('error');
      const f2 = ServerFailure('error');
      expect(f1, equals(f2));
    });

    test('two failures of same type with different message are not equal', () {
      const f1 = ServerFailure('error a');
      const f2 = ServerFailure('error b');
      expect(f1, isNot(equals(f2)));
    });
  });

  group('ValidationFailure', () {
    test('stores field-level error map correctly', () {
      final failure = ValidationFailure(
        fieldErrors: {
          'email': ['Email tidak valid'],
          'password': ['Minimal 8 karakter'],
        },
      );

      expect(failure.fieldErrors['email'], contains('Email tidak valid'));
      expect(failure.fieldErrors['password'], contains('Minimal 8 karakter'));
    });

    test('uses default message when none provided', () {
      const failure = ValidationFailure(fieldErrors: {});
      expect(failure.message, 'The given data was invalid.');
    });

    test('props include both message and fieldErrors for equality', () {
      final f1 = ValidationFailure(
        fieldErrors: {'email': ['invalid']},
      );
      final f2 = ValidationFailure(
        fieldErrors: {'email': ['invalid']},
      );
      expect(f1, equals(f2));
    });
  });

  group('RateLimitedFailure', () {
    test('stores retryAfterSeconds', () {
      const failure = RateLimitedFailure(retryAfterSeconds: 120);
      expect(failure.retryAfterSeconds, 120);
    });

    test('defaults retryAfterSeconds to 60', () {
      const failure = RateLimitedFailure();
      expect(failure.retryAfterSeconds, 60);
    });

    test('two instances with same retryAfterSeconds are equal', () {
      const f1 = RateLimitedFailure(retryAfterSeconds: 30);
      const f2 = RateLimitedFailure(retryAfterSeconds: 30);
      expect(f1, equals(f2));
    });

    test('two instances with different retryAfterSeconds are not equal', () {
      const f1 = RateLimitedFailure(retryAfterSeconds: 30);
      const f2 = RateLimitedFailure(retryAfterSeconds: 60);
      expect(f1, isNot(equals(f2)));
    });
  });
}
