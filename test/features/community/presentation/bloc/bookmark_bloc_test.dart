import 'package:banjarin/core/error/failures.dart';
import 'package:banjarin/core/usecase/paginated_result.dart';
import 'package:banjarin/features/community/domain/entities/bookmark.dart';
import 'package:banjarin/features/community/domain/usecases/add_bookmark.dart';
import 'package:banjarin/features/community/domain/usecases/get_bookmarks.dart';
import 'package:banjarin/features/community/domain/usecases/remove_bookmark.dart';
import 'package:banjarin/features/community/presentation/bloc/bookmark_bloc.dart';
import 'package:banjarin/features/community/presentation/bloc/bookmark_event.dart';
import 'package:banjarin/features/community/presentation/bloc/bookmark_state.dart';
import 'package:banjarin/features/dictionary/domain/entities/content_source.dart';
import 'package:banjarin/features/dictionary/domain/entities/word_class.dart';
import 'package:banjarin/features/dictionary/domain/entities/word_summary.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockGetBookmarks extends Mock implements GetBookmarks {}
class MockAddBookmark extends Mock implements AddBookmark {}
class MockRemoveBookmark extends Mock implements RemoveBookmark {}

void main() {
  late MockGetBookmarks mockGet;
  late MockAddBookmark mockAdd;
  late MockRemoveBookmark mockRemove;

  final tWordSummary = WordSummary(
    id: 'w1', banjar: 'abah', dialect: 'hulu',
    wordClass: WordClass.n, homonymNumber: 1, isRoot: true,
    primaryMeaning: 'ayah', source: ContentSource.seeded,
    createdAt: DateTime(2024),
  );

  final tBookmark = Bookmark(
    id: 'b1', wordId: 'w1', word: tWordSummary, createdAt: DateTime(2024),
  );

  setUp(() {
    mockGet = MockGetBookmarks();
    mockAdd = MockAddBookmark();
    mockRemove = MockRemoveBookmark();
    registerFallbackValue(const GetBookmarksParams());
    registerFallbackValue(const AddBookmarkParams(wordId: ''));
    registerFallbackValue(const RemoveBookmarkParams(wordId: ''));
  });

  BookmarkBloc makeBloc() =>
      BookmarkBloc(getBookmarks: mockGet, addBookmark: mockAdd, removeBookmark: mockRemove);

  group('BookmarkBloc', () {
    blocTest<BookmarkBloc, BookmarkState>(
      'LoadBookmarks emits [Loading, Loaded] with list',
      build: () {
        when(() => mockGet(any())).thenAnswer((_) async => Right(PaginatedResult(
          items: [tBookmark], page: 1, perPage: 20, total: 1,
        )));
        return makeBloc();
      },
      act: (bloc) => bloc.add(const LoadBookmarks()),
      expect: () => [isA<BookmarkLoading>(), isA<BookmarkLoaded>()],
      verify: (bloc) {
        final loaded = bloc.state as BookmarkLoaded;
        expect(loaded.bookmarks.length, 1);
      },
    );

    blocTest<BookmarkBloc, BookmarkState>(
      'ToggleBookmark when not bookmarked emits [Toggling, Bookmarked]',
      build: () {
        when(() => mockAdd(any())).thenAnswer((_) async => Right(tBookmark));
        return makeBloc();
      },
      seed: () => const BookmarkLoaded(),
      act: (bloc) => bloc.add(const ToggleBookmark(
        wordId: 'w1', isCurrentlyBookmarked: false,
      )),
      expect: () => [
        isA<BookmarkLoaded>().having((s) => s.isToggling, 'toggling', isTrue),
        isA<Bookmarked>(),
      ],
    );

    blocTest<BookmarkBloc, BookmarkState>(
      'ToggleBookmark when bookmarked emits [Toggling, Unbookmarked]',
      build: () {
        when(() => mockRemove(any())).thenAnswer((_) async => const Right(null));
        return makeBloc();
      },
      seed: () => BookmarkLoaded(bookmarks: [tBookmark]),
      act: (bloc) => bloc.add(const ToggleBookmark(
        wordId: 'w1', isCurrentlyBookmarked: true,
      )),
      expect: () => [
        isA<BookmarkLoaded>().having((s) => s.isToggling, 'toggling', isTrue),
        isA<Unbookmarked>(),
      ],
    );

    blocTest<BookmarkBloc, BookmarkState>(
      'ToggleBookmark on failure reverts state',
      build: () {
        when(() => mockAdd(any()))
            .thenAnswer((_) async => const Left(NetworkFailure()));
        return makeBloc();
      },
      seed: () => const BookmarkLoaded(isBookmarked: false),
      act: (bloc) => bloc.add(const ToggleBookmark(
        wordId: 'w1', isCurrentlyBookmarked: false,
      )),
      expect: () => [
        isA<BookmarkLoaded>().having((s) => s.isToggling, 'toggling', isTrue),
        isA<BookmarkError>(),
      ],
    );
  });
}
