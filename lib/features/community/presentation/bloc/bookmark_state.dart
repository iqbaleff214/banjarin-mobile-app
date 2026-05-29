import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/bookmark.dart';

sealed class BookmarkState extends Equatable {
  const BookmarkState();
}

final class BookmarkInitial extends BookmarkState {
  const BookmarkInitial();
  @override List<Object?> get props => [];
}

final class BookmarkLoading extends BookmarkState {
  const BookmarkLoading();
  @override List<Object?> get props => [];
}

final class BookmarkLoaded extends BookmarkState {
  final List<Bookmark> bookmarks;
  final bool hasMore;
  final int currentPage;
  final bool? isBookmarked;
  final String? currentWordId;
  final bool isToggling;

  const BookmarkLoaded({
    this.bookmarks = const [],
    this.hasMore = false,
    this.currentPage = 1,
    this.isBookmarked,
    this.currentWordId,
    this.isToggling = false,
  });

  BookmarkLoaded copyWith({
    List<Bookmark>? bookmarks,
    bool? hasMore,
    int? currentPage,
    bool? isBookmarked,
    String? currentWordId,
    bool? isToggling,
  }) {
    return BookmarkLoaded(
      bookmarks: bookmarks ?? this.bookmarks,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      currentWordId: currentWordId ?? this.currentWordId,
      isToggling: isToggling ?? this.isToggling,
    );
  }

  @override
  List<Object?> get props =>
      [bookmarks, hasMore, currentPage, isBookmarked, currentWordId, isToggling];
}

final class Bookmarked extends BookmarkLoaded {
  const Bookmarked({
    super.bookmarks,
    super.hasMore,
    super.currentPage,
    super.currentWordId,
  }) : super(isBookmarked: true, isToggling: false);
}

final class Unbookmarked extends BookmarkLoaded {
  const Unbookmarked({
    super.bookmarks,
    super.hasMore,
    super.currentPage,
    super.currentWordId,
  }) : super(isBookmarked: false, isToggling: false);
}

final class BookmarkError extends BookmarkState {
  final Failure failure;
  final bool? previousIsBookmarked;

  const BookmarkError(this.failure, {this.previousIsBookmarked});

  @override
  List<Object?> get props => [failure, previousIsBookmarked];
}
