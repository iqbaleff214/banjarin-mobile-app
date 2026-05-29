import 'package:equatable/equatable.dart';

sealed class BookmarkEvent extends Equatable {
  const BookmarkEvent();
}

final class LoadBookmarks extends BookmarkEvent {
  const LoadBookmarks();
  @override List<Object?> get props => [];
}

final class LoadMoreBookmarks extends BookmarkEvent {
  const LoadMoreBookmarks();
  @override List<Object?> get props => [];
}

final class CheckBookmarkStatus extends BookmarkEvent {
  final String wordId;
  const CheckBookmarkStatus(this.wordId);
  @override List<Object?> get props => [wordId];
}

final class ToggleBookmark extends BookmarkEvent {
  final String wordId;
  final bool isCurrentlyBookmarked;

  const ToggleBookmark({
    required this.wordId,
    required this.isCurrentlyBookmarked,
  });

  @override
  List<Object?> get props => [wordId, isCurrentlyBookmarked];
}
