import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/content_source.dart';
import '../../domain/entities/sort_words.dart';
import '../../domain/entities/word_class.dart';
import '../../domain/entities/word_summary.dart';

class WordListState extends Equatable {
  final List<WordSummary> words;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int currentPage;
  final WordClass? filterWordClass;
  final bool? filterIsRoot;
  final ContentSource? filterSource;
  final SortWords sort;
  final Failure? error;

  const WordListState({
    this.words = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.currentPage = 0,
    this.filterWordClass,
    this.filterIsRoot,
    this.filterSource,
    this.sort = SortWords.alphabetical,
    this.error,
  });

  WordListState copyWith({
    List<WordSummary>? words,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? currentPage,
    WordClass? filterWordClass,
    bool? clearWordClass,
    bool? filterIsRoot,
    bool? clearIsRoot,
    ContentSource? filterSource,
    bool? clearSource,
    SortWords? sort,
    Failure? error,
    bool? clearError,
  }) {
    return WordListState(
      words: words ?? this.words,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      filterWordClass: clearWordClass == true ? null : (filterWordClass ?? this.filterWordClass),
      filterIsRoot: clearIsRoot == true ? null : (filterIsRoot ?? this.filterIsRoot),
      filterSource: clearSource == true ? null : (filterSource ?? this.filterSource),
      sort: sort ?? this.sort,
      error: clearError == true ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
        words,
        isLoading,
        isLoadingMore,
        hasMore,
        currentPage,
        filterWordClass,
        filterIsRoot,
        filterSource,
        sort,
        error,
      ];
}
