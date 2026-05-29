import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/add_bookmark.dart';
import '../../domain/usecases/get_bookmarks.dart';
import '../../domain/usecases/remove_bookmark.dart';
import 'bookmark_event.dart';
import 'bookmark_state.dart';

class BookmarkBloc extends Bloc<BookmarkEvent, BookmarkState> {
  final GetBookmarks _getBookmarks;
  final AddBookmark _addBookmark;
  final RemoveBookmark _removeBookmark;
  static const _perPage = 20;

  BookmarkBloc({
    required GetBookmarks getBookmarks,
    required AddBookmark addBookmark,
    required RemoveBookmark removeBookmark,
  })  : _getBookmarks = getBookmarks,
        _addBookmark = addBookmark,
        _removeBookmark = removeBookmark,
        super(const BookmarkInitial()) {
    on<LoadBookmarks>(_onLoadBookmarks);
    on<LoadMoreBookmarks>(_onLoadMore);
    on<CheckBookmarkStatus>(_onCheckStatus);
    on<ToggleBookmark>(_onToggle);
  }

  BookmarkLoaded get _currentLoaded =>
      state is BookmarkLoaded ? state as BookmarkLoaded : const BookmarkLoaded();

  Future<void> _onLoadBookmarks(
    LoadBookmarks event,
    Emitter<BookmarkState> emit,
  ) async {
    emit(const BookmarkLoading());
    final result = await _getBookmarks(const GetBookmarksParams());
    result.fold(
      (failure) => emit(BookmarkError(failure)),
      (paginated) => emit(BookmarkLoaded(
        bookmarks: paginated.items,
        hasMore: paginated.hasMore,
        currentPage: paginated.page,
      )),
    );
  }

  Future<void> _onLoadMore(
    LoadMoreBookmarks event,
    Emitter<BookmarkState> emit,
  ) async {
    final current = _currentLoaded;
    if (!current.hasMore) return;

    final result = await _getBookmarks(
      GetBookmarksParams(page: current.currentPage + 1, perPage: _perPage),
    );
    result.fold(
      (failure) => emit(BookmarkError(failure)),
      (paginated) => emit(current.copyWith(
        bookmarks: [...current.bookmarks, ...paginated.items],
        hasMore: paginated.hasMore,
        currentPage: paginated.page,
      )),
    );
  }

  Future<void> _onCheckStatus(
    CheckBookmarkStatus event,
    Emitter<BookmarkState> emit,
  ) async {
    // For now, mark as unknown (false) — actual status comes from server via
    // bookmarks list or would require a dedicated endpoint not in the API spec
    final current = _currentLoaded;
    final isBookmarked = current.bookmarks.any((b) => b.wordId == event.wordId);
    emit(current.copyWith(
      isBookmarked: isBookmarked,
      currentWordId: event.wordId,
    ));
  }

  Future<void> _onToggle(
    ToggleBookmark event,
    Emitter<BookmarkState> emit,
  ) async {
    final current = _currentLoaded;
    final wasBookmarked = event.isCurrentlyBookmarked;

    // Optimistic update
    emit(current.copyWith(
      isBookmarked: !wasBookmarked,
      currentWordId: event.wordId,
      isToggling: true,
    ));

    if (wasBookmarked) {
      final result = await _removeBookmark(
        RemoveBookmarkParams(wordId: event.wordId),
      );
      result.fold(
        (failure) {
          emit(BookmarkError(failure, previousIsBookmarked: wasBookmarked));
        },
        (_) => emit(Unbookmarked(
          bookmarks: current.bookmarks.where((b) => b.wordId != event.wordId).toList(),
          hasMore: current.hasMore,
          currentPage: current.currentPage,
          currentWordId: event.wordId,
        )),
      );
    } else {
      final result = await _addBookmark(
        AddBookmarkParams(wordId: event.wordId),
      );
      result.fold(
        (failure) {
          emit(BookmarkError(failure, previousIsBookmarked: wasBookmarked));
        },
        (bookmark) => emit(Bookmarked(
          bookmarks: [bookmark, ...current.bookmarks],
          hasMore: current.hasMore,
          currentPage: current.currentPage,
          currentWordId: event.wordId,
        )),
      );
    }
  }
}
