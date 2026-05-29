import 'package:banjarin/core/error/exceptions.dart';
import 'package:banjarin/features/admin/data/datasources/admin_remote_data_source.dart';
import 'package:banjarin/features/admin/domain/repositories/admin_repository.dart';
import 'package:banjarin/features/dictionary/domain/entities/word_class.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late AdminRemoteDataSourceImpl dataSource;

  final tStatsJson = {
    'pending_contributions': 5,
    'flagged_comments': 2,
    'approved_this_week': 10,
    'rejected_this_week': 3,
  };

  setUp(() {
    mockDio = MockDio();
    dataSource = AdminRemoteDataSourceImpl(dio: mockDio);
    registerFallbackValue(RequestOptions(path: '/'));
    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue(const CreateWordParams(
      banjar: 'abah', wordClass: WordClass.n, definitions: [],
    ));
  });

  group('AdminRemoteDataSource', () {
    test('createWord on 409 throws DioException', () async {
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/admin/words'),
          error: const ServerException(code: 'CONFLICT', message: 'Exists'),
          type: DioExceptionType.badResponse,
        ),
      );
      expect(
        () => dataSource.createWord(const CreateWordParams(
          banjar: 'abah', wordClass: WordClass.n,
          definitions: [{'meaning': 'ayah'}],
        )),
        throwsA(isA<DioException>()),
      );
    });

    test('deleteWord on 204 completes successfully', () async {
      when(() => mockDio.delete(any())).thenAnswer(
        (_) async => Response(
          statusCode: 204,
          requestOptions: RequestOptions(path: '/admin/words/w1'),
        ),
      );
      await expectLater(dataSource.deleteWord(wordId: 'w1'), completes);
    });

    test('banUser on 404 throws DioException', () async {
      when(() => mockDio.patch(any(), data: any(named: 'data'))).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/admin/users/u1/ban'),
          error: const ServerException(code: 'NOT_FOUND', message: 'Not found'),
          type: DioExceptionType.badResponse,
        ),
      );
      expect(
        () => dataSource.banUser(userId: 'u1', reason: 'Spam'),
        throwsA(isA<DioException>()),
      );
    });

    test('approveContribution on 409 throws DioException', () async {
      when(() => mockDio.patch(any(), data: any(named: 'data'))).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/contributions/c1/approve'),
          error: const ServerException(code: 'CONFLICT', message: 'Already done'),
          type: DioExceptionType.badResponse,
        ),
      );
      expect(
        () => dataSource.approveContribution(contributionId: 'c1'),
        throwsA(isA<DioException>()),
      );
    });

    test('getModerationStats on 200 returns ModerationStatsModel', () async {
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          data: {'success': true, 'data': tStatsJson},
          statusCode: 200,
          requestOptions: RequestOptions(path: '/admin/moderation/stats'),
        ),
      );
      final result = await dataSource.getModerationStats();
      expect(result.pendingContributions, 5);
    });
  });
}
