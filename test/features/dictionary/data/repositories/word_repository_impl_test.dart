import 'package:banjarin/core/error/exceptions.dart';
import 'package:banjarin/core/error/failures.dart';
import 'package:banjarin/core/network/connectivity_checker.dart';
import 'package:banjarin/core/usecase/paginated_result.dart';
import 'package:banjarin/features/dictionary/data/datasources/word_local_data_source.dart';
import 'package:banjarin/features/dictionary/data/datasources/word_remote_data_source.dart';
import 'package:banjarin/features/dictionary/data/models/word_summary_model.dart';
import 'package:banjarin/features/dictionary/data/repositories/word_repository_impl.dart';
import 'package:banjarin/features/dictionary/domain/entities/content_source.dart';
import 'package:banjarin/features/dictionary/domain/entities/word_class.dart';
import 'package:banjarin/features/dictionary/domain/repositories/word_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockWordRemoteDataSource extends Mock implements WordRemoteDataSource {}

class MockWordLocalDataSource extends Mock implements WordLocalDataSource {}
class MockConnectivityChecker extends Mock implements ConnectivityChecker {}

void main() {
  late MockWordRemoteDataSource mockRemote;
  late MockWordLocalDataSource mockLocal;
  late WordRepositoryImpl repository;

  final tModel = WordSummaryModel(
    id: '1',
    banjar: 'abah',
    dialect: 'hulu',
    wordClass: WordClass.n,
    homonymNumber: 1,
    isRoot: true,
    primaryMeaning: 'ayah',
    source: ContentSource.seeded,
    createdAt: DateTime(2024),
  );

  final tPaginated = PaginatedResult(
    items: [tModel],
    page: 1,
    perPage: 20,
    total: 1,
  );

  setUp(() {
    mockRemote = MockWordRemoteDataSource();
    mockLocal = MockWordLocalDataSource();
    final mockConn = MockConnectivityChecker();
    when(() => mockConn.isOnline()).thenAnswer((_) async => true);
    repository = WordRepositoryImpl(remote: mockRemote, local: mockLocal, connectivity: mockConn);
    registerFallbackValue(RequestOptions(path: '/'));
    registerFallbackValue(const WordListParams());
    registerFallbackValue(const SearchParams(query: 'test'));
    registerFallbackValue(const WordIdParams(wordId: '1'));
  });

  group('getWordList', () {
    test('returns cached data when cache is fresh', () async {
      when(() => mockLocal.getCachedWordList())
          .thenAnswer((_) async => [tModel.toJson()]);

      final result = await repository.getWordList(const WordListParams());

      expect(result.isRight(), isTrue);
      final paginated = result.fold((_) => null, (p) => p)!;
      expect(paginated.items.first.banjar, 'abah');
      verifyNever(() => mockRemote.getWordList(any()));
    });

    test('calls remote when cache is stale (returns null)', () async {
      when(() => mockLocal.getCachedWordList()).thenAnswer((_) async => null);
      when(() => mockRemote.getWordList(any()))
          .thenAnswer((_) async => tPaginated);
      when(() => mockLocal.cacheWordList(any())).thenAnswer((_) async {});

      final result = await repository.getWordList(const WordListParams());

      expect(result.isRight(), isTrue);
      verify(() => mockRemote.getWordList(any())).called(1);
    });

    test('updates cache after successful remote call', () async {
      when(() => mockLocal.getCachedWordList()).thenAnswer((_) async => null);
      when(() => mockRemote.getWordList(any()))
          .thenAnswer((_) async => tPaginated);
      when(() => mockLocal.cacheWordList(any())).thenAnswer((_) async {});

      await repository.getWordList(const WordListParams());

      verify(() => mockLocal.cacheWordList(any())).called(1);
    });

    test('on NetworkFailure returns NetworkFailure', () async {
      when(() => mockLocal.getCachedWordList()).thenAnswer((_) async => null);
      when(() => mockRemote.getWordList(any())).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/words'),
        error: const NetworkException('No connection'),
        type: DioExceptionType.connectionError,
      ));

      final result = await repository.getWordList(const WordListParams());

      expect(result.fold((f) => f, (_) => null), isA<NetworkFailure>());
    });
  });

  group('getWordDetail (cache-first)', () {
    test('returns cached word when cache hit', () async {
      final wordJson = {
        'id': '1',
        'banjar': 'abah',
        'banjar_syllabified': null,
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
      };
      when(() => mockLocal.getCachedWord('1')).thenAnswer((_) async => wordJson);

      final result = await repository.getWordDetail(const WordIdParams(wordId: '1'));

      expect(result.isRight(), isTrue);
      verifyNever(() => mockRemote.getWordDetail(any()));
    });
  });
}
