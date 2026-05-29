import 'package:banjarin/core/error/exceptions.dart';
import 'package:banjarin/features/ai/data/datasources/ai_remote_data_source.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late AIRemoteDataSourceImpl dataSource;

  final tResponse = {
    'success': true,
    'data': {
      'original': 'abah inya',
      'translation': 'ayahnya',
      'dialect': 'hulu',
      'model': 'test-model',
      'confidence': 'high',
      'notes': null,
    },
  };

  setUp(() {
    mockDio = MockDio();
    dataSource = AIRemoteDataSourceImpl(dio: mockDio);
    registerFallbackValue(RequestOptions(path: '/'));
    registerFallbackValue(<String, dynamic>{});
  });

  group('AIRemoteDataSource.translate', () {
    test('on 200 returns TranslationResultModel', () async {
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          data: tResponse,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/ai/translate'),
        ),
      );

      final result = await dataSource.translate(text: 'abah inya');

      expect(result.original, 'abah inya');
      expect(result.translation, 'ayahnya');
    });

    test('on 503 throws DioException with AI_UNAVAILABLE ServerException',
        () async {
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/ai/translate'),
          error: const ServerException(
            code: 'AI_UNAVAILABLE',
            message: 'AI service is down',
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      expect(
        () => dataSource.translate(text: 'test'),
        throwsA(isA<DioException>().having(
          (e) => (e.error as ServerException).code,
          'code',
          'AI_UNAVAILABLE',
        )),
      );
    });

    test('on 429 throws DioException with RATE_LIMITED ServerException',
        () async {
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/ai/translate'),
          error: const ServerException(
            code: 'RATE_LIMITED',
            message: 'Too many requests',
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      expect(
        () => dataSource.translate(text: 'test'),
        throwsA(isA<DioException>()),
      );
    });
  });
}
