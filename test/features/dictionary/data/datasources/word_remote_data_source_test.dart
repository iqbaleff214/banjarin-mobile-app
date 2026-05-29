import 'package:banjarin/core/error/exceptions.dart';
import 'package:banjarin/features/dictionary/data/datasources/word_remote_data_source.dart';
import 'package:banjarin/features/dictionary/domain/repositories/word_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late WordRemoteDataSourceImpl dataSource;

  final tListResponse = {
    'success': true,
    'data': [
      {
        'id': '1',
        'banjar': 'abah',
        'dialect': 'hulu',
        'word_class': 'n',
        'homonym_number': 1,
        'is_root': true,
        'primary_meaning': 'ayah',
        'source': 'seeded',
        'created_at': '2024-01-01T00:00:00.000Z',
      }
    ],
    'meta': {'page': 1, 'per_page': 20, 'total': 1},
  };

  setUp(() {
    mockDio = MockDio();
    dataSource = WordRemoteDataSourceImpl(dio: mockDio);
    registerFallbackValue(RequestOptions(path: '/'));
    registerFallbackValue(<String, dynamic>{});
  });

  group('getWordList', () {
    test('on 200 returns list of WordSummaryModel', () async {
      when(() => mockDio.get(any(), queryParameters: any(named: 'queryParameters')))
          .thenAnswer(
        (_) async => Response(
          data: tListResponse,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/words'),
        ),
      );

      final result = await dataSource.getWordList(const WordListParams());

      expect(result.items.length, 1);
      expect(result.items.first.banjar, 'abah');
      expect(result.total, 1);
    });
  });

  group('getWordDetail', () {
    test('on 404 throws DioException with ServerException', () async {
      when(() => mockDio.get(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/words/bad'),
          error: const ServerException(code: 'NOT_FOUND', message: 'Not found'),
          type: DioExceptionType.badResponse,
        ),
      );

      expect(
        () => dataSource.getWordDetail('bad'),
        throwsA(isA<DioException>()),
      );
    });

    test('on 200 returns WordModel', () async {
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          data: {
            'success': true,
            'data': {
              'id': '1',
              'banjar': 'abah',
              'banjar_syllabified': 'a.bah',
              'dialect': 'hulu',
              'word_class': 'n',
              'homonym_number': 1,
              'is_root': true,
              'root_word_id': null,
              'definitions': [],
              'examples': [],
              'related_words': [],
              'status': 'active',
              'source': 'seeded',
              'source_reference': null,
              'created_by': null,
              'created_at': '2024-01-01T00:00:00.000Z',
              'updated_at': '2024-01-01T00:00:00.000Z',
            },
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: '/words/1'),
        ),
      );

      final result = await dataSource.getWordDetail('1');
      expect(result.banjar, 'abah');
      expect(result.banjarSyllabified, 'a.bah');
    });
  });
}
