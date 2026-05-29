import 'package:banjarin/core/error/failures.dart';
import 'package:banjarin/features/ai/domain/entities/confidence_level.dart';
import 'package:banjarin/features/ai/domain/entities/translation_result.dart';
import 'package:banjarin/features/ai/domain/repositories/ai_repository.dart';
import 'package:banjarin/features/ai/domain/usecases/translate_banjar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockAIRepository extends Mock implements AIRepository {}

void main() {
  late MockAIRepository mockRepo;
  late TranslateBanjar translateBanjar;

  final tResult = TranslationResult(
    original: 'abah inya',
    translation: 'ayahnya',
    dialect: 'hulu',
    model: 'test-model',
    confidence: ConfidenceLevel.high,
  );

  setUp(() {
    mockRepo = MockAIRepository();
    translateBanjar = TranslateBanjar(mockRepo);
  });

  group('TranslateBanjar', () {
    test('when text is empty returns ValidationFailure', () async {
      final result = await translateBanjar(const TranslateBanjarParams(
        text: '',
        isAuthenticated: true,
      ));
      expect(result.fold((f) => f, (_) => null), isA<ValidationFailure>());
    });

    test('when text is only whitespace returns ValidationFailure', () async {
      final result = await translateBanjar(const TranslateBanjarParams(
        text: '   ',
        isAuthenticated: true,
      ));
      expect(result.fold((f) => f, (_) => null), isA<ValidationFailure>());
    });

    test('when text exceeds 1000 chars returns ValidationFailure', () async {
      final result = await translateBanjar(TranslateBanjarParams(
        text: 'a' * 1001,
        isAuthenticated: true,
      ));
      expect(result.fold((f) => f, (_) => null), isA<ValidationFailure>());
    });

    test('when unauthenticated returns UnauthorizedFailure', () async {
      final result = await translateBanjar(const TranslateBanjarParams(
        text: 'abah inya',
        isAuthenticated: false,
      ));
      expect(result.fold((f) => f, (_) => null), isA<UnauthorizedFailure>());
    });

    test('when authenticated and valid delegates to repository', () async {
      when(() => mockRepo.translate(
            text: any(named: 'text'),
            context: any(named: 'context'),
          )).thenAnswer((_) async => Right(tResult));

      final result = await translateBanjar(const TranslateBanjarParams(
        text: 'abah inya',
        isAuthenticated: true,
      ));

      expect(result.isRight(), isTrue);
      verify(() => mockRepo.translate(text: 'abah inya', context: null)).called(1);
    });

    test('when exactly 1000 chars is valid', () async {
      when(() => mockRepo.translate(
            text: any(named: 'text'),
            context: any(named: 'context'),
          )).thenAnswer((_) async => Right(tResult));

      final result = await translateBanjar(TranslateBanjarParams(
        text: 'a' * 1000,
        isAuthenticated: true,
      ));
      expect(result.isRight(), isTrue);
    });
  });
}
