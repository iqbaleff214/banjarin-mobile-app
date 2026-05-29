import 'package:banjarin/core/error/exceptions.dart';
import 'package:banjarin/core/error/failures.dart';
import 'package:banjarin/features/ai/data/datasources/ai_remote_data_source.dart';
import 'package:banjarin/features/ai/data/models/translation_result_model.dart';
import 'package:banjarin/features/ai/data/repositories/ai_repository_impl.dart';
import 'package:banjarin/features/ai/domain/entities/confidence_level.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAIRemoteDataSource extends Mock implements AIRemoteDataSource {}

void main() {
  late MockAIRemoteDataSource mockDataSource;
  late AIRepositoryImpl repository;

  final tModel = const TranslationResultModel(
    original: 'abah inya',
    translation: 'ayahnya',
    dialect: 'hulu',
    model: 'test',
    confidence: ConfidenceLevel.high,
  );

  setUp(() {
    mockDataSource = MockAIRemoteDataSource();
    repository = AIRepositoryImpl(remoteDataSource: mockDataSource);
    registerFallbackValue(RequestOptions(path: '/'));
  });

  group('AIRepositoryImpl.translate', () {
    test('on success returns TranslationResult entity', () async {
      when(() => mockDataSource.translate(
            text: any(named: 'text'),
            context: any(named: 'context'),
          )).thenAnswer((_) async => tModel);

      final result = await repository.translate(text: 'abah inya');

      expect(result.isRight(), isTrue);
    });

    test('never writes to cache (stateless)', () async {
      when(() => mockDataSource.translate(
            text: any(named: 'text'),
            context: any(named: 'context'),
          )).thenAnswer((_) async => tModel);

      await repository.translate(text: 'test');
      await repository.translate(text: 'test');

      // Each call goes to remote — no caching
      verify(() => mockDataSource.translate(
            text: any(named: 'text'),
            context: any(named: 'context'),
          )).called(2);
    });

    test('on AI_UNAVAILABLE returns AIUnavailableFailure', () async {
      when(() => mockDataSource.translate(
            text: any(named: 'text'),
            context: any(named: 'context'),
          )).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/ai/translate'),
        error: const ServerException(
          code: 'AI_UNAVAILABLE',
          message: 'Service down',
        ),
        type: DioExceptionType.badResponse,
      ));

      final result = await repository.translate(text: 'test');
      expect(result.fold((f) => f, (_) => null), isA<AIUnavailableFailure>());
    });

    test('on RATE_LIMITED returns RateLimitedFailure', () async {
      when(() => mockDataSource.translate(
            text: any(named: 'text'),
            context: any(named: 'context'),
          )).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/ai/translate'),
        error: const ServerException(
          code: 'RATE_LIMITED',
          message: 'Too many requests',
          details: {'retry_after': 3600},
        ),
        type: DioExceptionType.badResponse,
      ));

      final result = await repository.translate(text: 'test');
      expect(result.fold((f) => f, (_) => null), isA<RateLimitedFailure>());
    });
  });
}
