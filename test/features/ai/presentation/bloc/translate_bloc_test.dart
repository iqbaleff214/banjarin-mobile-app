import 'package:banjarin/core/error/failures.dart';
import 'package:banjarin/features/ai/domain/entities/confidence_level.dart';
import 'package:banjarin/features/ai/domain/entities/translation_result.dart';
import 'package:banjarin/features/ai/domain/usecases/translate_banjar.dart';
import 'package:banjarin/features/ai/presentation/bloc/translate_bloc.dart';
import 'package:banjarin/features/ai/presentation/bloc/translate_event.dart';
import 'package:banjarin/features/ai/presentation/bloc/translate_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockTranslateBanjar extends Mock implements TranslateBanjar {}

void main() {
  late MockTranslateBanjar mockTranslate;

  final tResult = TranslationResult(
    original: 'abah inya',
    translation: 'ayahnya',
    dialect: 'hulu',
    model: 'test-model',
    confidence: ConfidenceLevel.high,
  );

  setUp(() {
    mockTranslate = MockTranslateBanjar();
    registerFallbackValue(const TranslateBanjarParams(
      text: '',
      isAuthenticated: true,
    ));
  });

  TranslateBloc makeBloc() =>
      TranslateBloc(translateBanjar: mockTranslate);

  group('TranslateBloc', () {
    blocTest<TranslateBloc, TranslateState>(
      'Translate emits [Translating, TranslateSuccess]',
      build: () {
        when(() => mockTranslate(any()))
            .thenAnswer((_) async => Right(tResult));
        return makeBloc();
      },
      act: (bloc) => bloc.add(const Translate(
        text: 'abah inya',
        isAuthenticated: true,
      )),
      expect: () => [isA<Translating>(), isA<TranslateSuccess>()],
      verify: (bloc) {
        expect((bloc.state as TranslateSuccess).result.translation, 'ayahnya');
      },
    );

    blocTest<TranslateBloc, TranslateState>(
      'Translate on AIUnavailableFailure emits TranslateError',
      build: () {
        when(() => mockTranslate(any()))
            .thenAnswer((_) async => const Left(AIUnavailableFailure()));
        return makeBloc();
      },
      act: (bloc) => bloc.add(const Translate(
        text: 'test',
        isAuthenticated: true,
      )),
      expect: () => [isA<Translating>(), isA<TranslateError>()],
      verify: (bloc) {
        expect(
          (bloc.state as TranslateError).failure,
          isA<AIUnavailableFailure>(),
        );
      },
    );

    blocTest<TranslateBloc, TranslateState>(
      'Translate on RateLimitedFailure emits RateLimited with retryAfterSeconds',
      build: () {
        when(() => mockTranslate(any())).thenAnswer(
          (_) async => const Left(RateLimitedFailure(retryAfterSeconds: 3600)),
        );
        return makeBloc();
      },
      act: (bloc) => bloc.add(const Translate(
        text: 'test',
        isAuthenticated: true,
      )),
      expect: () => [isA<Translating>(), isA<RateLimited>()],
      verify: (bloc) {
        expect((bloc.state as RateLimited).retryAfterSeconds, 3600);
      },
    );

    blocTest<TranslateBloc, TranslateState>(
      'Translate on UnauthorizedFailure emits TranslateError',
      build: () {
        when(() => mockTranslate(any()))
            .thenAnswer((_) async => const Left(UnauthorizedFailure()));
        return makeBloc();
      },
      act: (bloc) => bloc.add(const Translate(
        text: 'test',
        isAuthenticated: false,
      )),
      expect: () => [isA<Translating>(), isA<TranslateError>()],
    );

    blocTest<TranslateBloc, TranslateState>(
      'ClearTranslation emits TranslateInitial',
      build: () => makeBloc(),
      seed: () => TranslateSuccess(tResult),
      act: (bloc) => bloc.add(const ClearTranslation()),
      expect: () => [isA<TranslateInitial>()],
    );
  });
}
