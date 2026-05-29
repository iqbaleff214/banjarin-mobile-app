import 'package:banjarin/core/error/exceptions.dart';
import 'package:banjarin/features/community/data/datasources/comment_remote_data_source.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late CommentRemoteDataSourceImpl dataSource;

  final tCommentJson = {
    'id': 'c1',
    'user_id': 'u1',
    'author_name': 'Ahmad',
    'target_type': 'word',
    'target_id': 'w1',
    'body': 'Great word!',
    'is_flagged': false,
    'created_at': '2024-01-01T00:00:00.000Z',
    'updated_at': '2024-01-01T00:00:00.000Z',
  };

  setUp(() {
    mockDio = MockDio();
    dataSource = CommentRemoteDataSourceImpl(dio: mockDio);
    registerFallbackValue(RequestOptions(path: '/'));
    registerFallbackValue(<String, dynamic>{});
  });

  group('getComments', () {
    test('on 200 returns list of CommentModel', () async {
      when(() => mockDio.get(any(), queryParameters: any(named: 'queryParameters')))
          .thenAnswer((_) async => Response(
                data: {
                  'success': true,
                  'data': [tCommentJson],
                  'meta': {'page': 1, 'per_page': 20, 'total': 1},
                },
                statusCode: 200,
                requestOptions: RequestOptions(path: '/words/w1/comments'),
              ));

      final result = await dataSource.getComments(wordId: 'w1');
      expect(result.items.length, 1);
      expect(result.items.first.body, 'Great word!');
    });
  });

  group('postComment', () {
    test('on 201 returns CommentModel', () async {
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          data: {'success': true, 'data': tCommentJson},
          statusCode: 201,
          requestOptions: RequestOptions(path: '/words/w1/comments'),
        ),
      );

      final result = await dataSource.postComment(wordId: 'w1', body: 'Great!');
      expect(result.body, 'Great word!');
    });
  });

  group('flagComment', () {
    test('on 409 throws DioException with ServerException CONFLICT', () async {
      when(() => mockDio.post(any())).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/comments/c1/flag'),
        error: const ServerException(code: 'CONFLICT', message: 'Already flagged'),
        type: DioExceptionType.badResponse,
      ));

      expect(
        () => dataSource.flagComment(commentId: 'c1'),
        throwsA(isA<DioException>()),
      );
    });
  });
}
