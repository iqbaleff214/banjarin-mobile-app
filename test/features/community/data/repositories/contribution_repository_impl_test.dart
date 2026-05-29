import 'package:banjarin/core/error/exceptions.dart';
import 'package:banjarin/core/error/failures.dart';
import 'package:banjarin/features/community/data/datasources/contribution_remote_data_source.dart';
import 'package:banjarin/features/community/data/models/contribution_model.dart';
import 'package:banjarin/features/community/data/repositories/contribution_repository_impl.dart';
import 'package:banjarin/features/community/domain/entities/contribution.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockContributionRemoteDataSource extends Mock
    implements ContributionRemoteDataSource {}

void main() {
  late MockContributionRemoteDataSource mockDataSource;
  late ContributionRepositoryImpl repository;

  final tModel = ContributionModel(
    id: 'c1',
    type: ContributionType.new_word,
    contributorId: 'u1',
    payload: const {'banjar': 'abah', 'word_class': 'n', 'definitions': []},
    status: ContributionStatus.pending,
    submittedAt: DateTime(2024),
  );

  setUp(() {
    mockDataSource = MockContributionRemoteDataSource();
    repository = ContributionRepositoryImpl(remote: mockDataSource);
    registerFallbackValue(RequestOptions(path: '/'));
    registerFallbackValue(ContributionType.new_word);
    registerFallbackValue(ContributionStatus.pending);
    registerFallbackValue(<String, dynamic>{});
  });

  group('ContributionRepositoryImpl.submit', () {
    test('maps response to Contribution entity', () async {
      when(() => mockDataSource.submit(
            type: any(named: 'type'),
            targetWordId: any(named: 'targetWordId'),
            payload: any(named: 'payload'),
          )).thenAnswer((_) async => tModel);

      final result = await repository.submit(
        type: ContributionType.new_word,
        payload: const {'banjar': 'abah', 'word_class': 'n', 'definitions': []},
      );

      expect(result.isRight(), isTrue);
      expect(result.fold((_) => null, (c) => c.id), 'c1');
    });

    test('on RATE_LIMITED DioException returns RateLimitedFailure', () async {
      when(() => mockDataSource.submit(
            type: any(named: 'type'),
            targetWordId: any(named: 'targetWordId'),
            payload: any(named: 'payload'),
          )).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/contributions'),
        error: const ServerException(
          code: 'RATE_LIMITED',
          message: 'Too many',
        ),
        type: DioExceptionType.badResponse,
      ));

      final result = await repository.submit(
        type: ContributionType.new_word,
        payload: const {},
      );

      expect(result.fold((f) => f, (_) => null), isA<RateLimitedFailure>());
    });
  });
}
