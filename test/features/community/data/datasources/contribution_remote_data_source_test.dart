import 'package:banjarin/core/error/exceptions.dart';
import 'package:banjarin/features/community/data/datasources/contribution_remote_data_source.dart';
import 'package:banjarin/features/community/domain/entities/contribution.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late ContributionRemoteDataSourceImpl dataSource;

  final tContributionJson = {
    'id': 'c1',
    'type': 'new_word',
    'contributor_id': 'u1',
    'target_word_id': null,
    'payload': {'banjar': 'abah', 'word_class': 'n', 'definitions': []},
    'status': 'pending',
    'reviewer_id': null,
    'reviewer_note': null,
    'submitted_at': '2024-01-01T00:00:00.000Z',
    'reviewed_at': null,
  };

  setUp(() {
    mockDio = MockDio();
    dataSource = ContributionRemoteDataSourceImpl(dio: mockDio);
    registerFallbackValue(RequestOptions(path: '/'));
    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue(ContributionType.new_word);
    registerFallbackValue(ContributionStatus.pending);
  });

  group('ContributionRemoteDataSource', () {
    test('submit on 201 returns ContributionModel', () async {
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          data: {'success': true, 'data': tContributionJson},
          statusCode: 201,
          requestOptions: RequestOptions(path: '/contributions'),
        ),
      );

      final result = await dataSource.submit(
        type: ContributionType.new_word,
        payload: const {'banjar': 'abah', 'word_class': 'n', 'definitions': []},
      );

      expect(result.id, 'c1');
      expect(result.type, ContributionType.new_word);
    });

    test('submit on 429 throws RateLimited DioException', () async {
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/contributions'),
          error: const ServerException(
            code: 'RATE_LIMITED',
            message: 'Too many contributions',
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      expect(
        () => dataSource.submit(
          type: ContributionType.new_word,
          payload: const {},
        ),
        throwsA(isA<DioException>()),
      );
    });

    test('withdraw on 409 throws ConflictFailure DioException', () async {
      when(() => mockDio.patch(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/contributions/c1/withdraw'),
          error: const ServerException(
            code: 'CONFLICT',
            message: 'Cannot withdraw',
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      expect(
        () => dataSource.withdraw(contributionId: 'c1'),
        throwsA(isA<DioException>()),
      );
    });
  });
}
