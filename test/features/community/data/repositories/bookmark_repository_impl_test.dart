import 'package:banjarin/core/error/exceptions.dart';
import 'package:banjarin/core/error/failures.dart';
import 'package:banjarin/core/usecase/paginated_result.dart';
import 'package:banjarin/features/community/data/datasources/bookmark_local_data_source.dart';
import 'package:banjarin/features/community/data/datasources/bookmark_remote_data_source.dart';
import 'package:banjarin/features/community/data/models/bookmark_model.dart';
import 'package:banjarin/features/community/data/repositories/bookmark_repository_impl.dart';
import 'package:banjarin/features/dictionary/data/models/word_summary_model.dart';
import 'package:banjarin/features/dictionary/domain/entities/content_source.dart';
import 'package:banjarin/features/dictionary/domain/entities/word_class.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockBookmarkRemoteDataSource extends Mock
    implements BookmarkRemoteDataSource {}

class MockBookmarkLocalDataSource extends Mock
    implements BookmarkLocalDataSource {}

void main() {
  late MockBookmarkRemoteDataSource mockRemote;
  late MockBookmarkLocalDataSource mockLocal;
  late BookmarkRepositoryImpl repository;

  final tWordSummaryModel = WordSummaryModel(
    id: 'w1', banjar: 'abah', dialect: 'hulu',
    wordClass: WordClass.n, homonymNumber: 1, isRoot: true,
    primaryMeaning: 'ayah', source: ContentSource.seeded,
    createdAt: DateTime(2024),
  );

  final tBookmarkModel = BookmarkModel(
    id: 'b1', wordId: 'w1', word: tWordSummaryModel, createdAt: DateTime(2024),
  );

  final tPaginated = PaginatedResult(
    items: [tBookmarkModel], page: 1, perPage: 20, total: 1,
  );

  setUp(() {
    mockRemote = MockBookmarkRemoteDataSource();
    mockLocal = MockBookmarkLocalDataSource();
    repository = BookmarkRepositoryImpl(remote: mockRemote, local: mockLocal);
    registerFallbackValue(RequestOptions(path: '/'));
  });

  group('getBookmarks', () {
    test('returns cached bookmarks when cache is fresh', () async {
      when(() => mockLocal.getCachedBookmarks())
          .thenAnswer((_) async => [tBookmarkModel.toJson()]);

      final result = await repository.getBookmarks();
      expect(result.isRight(), isTrue);
      verifyNever(() => mockRemote.getBookmarks());
    });

    test('calls remote when cache is stale', () async {
      when(() => mockLocal.getCachedBookmarks()).thenAnswer((_) async => null);
      when(() => mockRemote.getBookmarks(
            page: any(named: 'page'),
            perPage: any(named: 'perPage'),
          )).thenAnswer((_) async => tPaginated);
      when(() => mockLocal.cacheBookmarks(any())).thenAnswer((_) async {});
      when(() => mockLocal.addBookmarkedId(any())).thenAnswer((_) async {});

      final result = await repository.getBookmarks();
      expect(result.isRight(), isTrue);
      verify(() => mockRemote.getBookmarks(page: 1, perPage: 20)).called(1);
    });
  });

  group('addBookmark', () {
    test('updates local cache on success', () async {
      when(() => mockLocal.addBookmarkedId(any())).thenAnswer((_) async {});
      when(() => mockRemote.addBookmark(wordId: any(named: 'wordId')))
          .thenAnswer((_) async => tBookmarkModel);
      when(() => mockLocal.invalidate()).thenAnswer((_) async {});

      final result = await repository.addBookmark(wordId: 'w1');
      expect(result.isRight(), isTrue);
      verify(() => mockLocal.addBookmarkedId('w1')).called(1);
    });

    test('rolls back local cache on network failure', () async {
      when(() => mockLocal.addBookmarkedId(any())).thenAnswer((_) async {});
      when(() => mockRemote.addBookmark(wordId: any(named: 'wordId')))
          .thenThrow(DioException(
        requestOptions: RequestOptions(path: '/bookmarks'),
        error: const NetworkException('No connection'),
        type: DioExceptionType.connectionError,
      ));
      when(() => mockLocal.removeBookmarkedId(any())).thenAnswer((_) async {});

      final result = await repository.addBookmark(wordId: 'w1');
      expect(result.fold((f) => f, (_) => null), isA<NetworkFailure>());
      verify(() => mockLocal.removeBookmarkedId('w1')).called(1);
    });
  });

  group('removeBookmark', () {
    test('removes from local cache on success', () async {
      when(() => mockLocal.removeBookmarkedId(any())).thenAnswer((_) async {});
      when(() => mockRemote.removeBookmark(wordId: any(named: 'wordId')))
          .thenAnswer((_) async {});
      when(() => mockLocal.invalidate()).thenAnswer((_) async {});

      final result = await repository.removeBookmark(wordId: 'w1');
      expect(result.isRight(), isTrue);
      verify(() => mockLocal.removeBookmarkedId('w1')).called(1);
    });
  });
}
