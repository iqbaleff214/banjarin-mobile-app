import 'package:banjarin/core/error/exceptions.dart';
import 'package:banjarin/core/error/failures.dart';
import 'package:banjarin/features/community/data/datasources/vote_remote_data_source.dart';
import 'package:banjarin/features/community/data/models/vote_model.dart';
import 'package:banjarin/features/community/data/repositories/vote_repository_impl.dart';
import 'package:banjarin/features/community/domain/entities/vote.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockVoteRemoteDataSource extends Mock implements VoteRemoteDataSource {}

void main() {
  late MockVoteRemoteDataSource mockDataSource;
  late VoteRepositoryImpl repository;

  final tVoteModel = VoteModel(
    id: '1', userId: 'u1',
    targetType: VoteTargetType.word, targetId: 'w1',
    value: VoteValue.up, createdAt: DateTime(2024),
  );

  setUp(() {
    mockDataSource = MockVoteRemoteDataSource();
    repository = VoteRepositoryImpl(remoteDataSource: mockDataSource);
    registerFallbackValue(VoteTargetType.word);
    registerFallbackValue(VoteValue.up);
    registerFallbackValue(RequestOptions(path: '/'));
  });

  group('castVote', () {
    test('on success returns Vote entity', () async {
      when(() => mockDataSource.castVote(
            targetId: any(named: 'targetId'),
            targetType: any(named: 'targetType'),
            value: any(named: 'value'),
          )).thenAnswer((_) async => tVoteModel);

      final result = await repository.castVote(
        targetId: 'w1',
        targetType: VoteTargetType.word,
        value: VoteValue.up,
      );

      expect(result.isRight(), isTrue);
    });

    test('on 409 DioException returns ConflictFailure', () async {
      when(() => mockDataSource.castVote(
            targetId: any(named: 'targetId'),
            targetType: any(named: 'targetType'),
            value: any(named: 'value'),
          )).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/'),
        error: const ServerException(code: 'CONFLICT', message: 'Already voted'),
        type: DioExceptionType.badResponse,
      ));

      final result = await repository.castVote(
        targetId: 'w1',
        targetType: VoteTargetType.word,
        value: VoteValue.up,
      );

      expect(result.fold((f) => f, (_) => null), isA<ConflictFailure>());
    });
  });
}
