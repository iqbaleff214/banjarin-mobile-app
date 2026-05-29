import 'package:banjarin/core/error/exceptions.dart';
import 'package:banjarin/features/admin/data/datasources/admin_remote_data_source.dart';
import 'package:banjarin/features/admin/domain/repositories/admin_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late AdminRemoteDataSourceImpl dataSource;

  final tAIRequestJson = {
    'id': 'r1',
    'type': 'enrich_definition',
    'model': 'test-model',
    'status': 'pending',
    'review_status': 'unreviewed',
    'parsed_output': null,
    'created_at': '2024-01-01T00:00:00.000Z',
  };

  setUp(() {
    mockDio = MockDio();
    dataSource = AdminRemoteDataSourceImpl(dio: mockDio);
    registerFallbackValue(RequestOptions(path: '/'));
    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue(const GetAIRequestsParams());
  });

  group('AdminRemoteDataSource AI', () {
    test('triggerEnrich on 202 returns AIRequestModel with status pending',
        () async {
      when(() => mockDio.post(any())).thenAnswer(
        (_) async => Response(
          data: {'success': true, 'data': tAIRequestJson},
          statusCode: 202,
          requestOptions: RequestOptions(path: '/admin/ai/enrich/w1'),
        ),
      );

      final result = await dataSource.triggerEnrich(wordId: 'w1');
      expect(result.id, 'r1');
      expect(result.status.name, 'pending');
    });

    test('triggerEnrich on 429 throws DioException with RATE_LIMITED',
        () async {
      when(() => mockDio.post(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/admin/ai/enrich/w1'),
          error: const ServerException(
            code: 'RATE_LIMITED',
            message: 'Too many requests',
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      expect(
        () => dataSource.triggerEnrich(wordId: 'w1'),
        throwsA(isA<DioException>()),
      );
    });

    test('approveAIRequest on 409 throws DioException', () async {
      when(() => mockDio.patch(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/admin/ai/requests/r1/approve'),
          error: const ServerException(
            code: 'CONFLICT',
            message: 'Already approved',
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      expect(
        () => dataSource.approveAIRequest(requestId: 'r1'),
        throwsA(isA<DioException>()),
      );
    });
  });
}
