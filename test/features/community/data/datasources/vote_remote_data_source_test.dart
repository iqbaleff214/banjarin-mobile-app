import 'package:banjarin/features/community/data/datasources/vote_remote_data_source.dart';
import 'package:banjarin/features/community/domain/entities/vote.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late VoteRemoteDataSourceImpl dataSource;

  final tVoteResponse = {
    'success': true,
    'data': {
      'id': '1',
      'user_id': 'u1',
      'target_type': 'word',
      'target_id': 'w1',
      'value': 'up',
      'created_at': '2024-01-01T00:00:00.000Z',
    },
  };

  setUp(() {
    mockDio = MockDio();
    dataSource = VoteRemoteDataSourceImpl(dio: mockDio);
    registerFallbackValue(RequestOptions(path: '/'));
    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue(VoteTargetType.word);
    registerFallbackValue(VoteValue.up);
  });

  group('castVote', () {
    test('on word sends to /words/{id}/votes', () async {
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          data: tVoteResponse,
          statusCode: 201,
          requestOptions: RequestOptions(path: '/words/w1/votes'),
        ),
      );

      await dataSource.castVote(
        targetId: 'w1',
        targetType: VoteTargetType.word,
        value: VoteValue.up,
      );

      final captured = verify(
        () => mockDio.post(captureAny(), data: any(named: 'data')),
      ).captured;
      expect(captured.first, '/words/w1/votes');
    });

    test('on definition sends to /definitions/{id}/votes', () async {
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          data: tVoteResponse,
          statusCode: 201,
          requestOptions: RequestOptions(path: '/definitions/d1/votes'),
        ),
      );

      await dataSource.castVote(
        targetId: 'd1',
        targetType: VoteTargetType.definition,
        value: VoteValue.up,
      );

      final captured = verify(
        () => mockDio.post(captureAny(), data: any(named: 'data')),
      ).captured;
      expect(captured.first, '/definitions/d1/votes');
    });
  });

  group('removeVote', () {
    test('on word sends DELETE to /words/{id}/votes', () async {
      when(() => mockDio.delete(any())).thenAnswer(
        (_) async => Response(
          statusCode: 204,
          requestOptions: RequestOptions(path: '/words/w1/votes'),
        ),
      );

      await dataSource.removeVote(
        targetId: 'w1',
        targetType: VoteTargetType.word,
      );

      final captured = verify(() => mockDio.delete(captureAny())).captured;
      expect(captured.first, '/words/w1/votes');
    });
  });
}
