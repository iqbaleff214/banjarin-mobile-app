import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/word_summary.dart';

sealed class SearchState extends Equatable {
  const SearchState();
}

final class SearchInitial extends SearchState {
  const SearchInitial();
  @override
  List<Object?> get props => [];
}

final class SearchEmpty extends SearchState {
  const SearchEmpty();
  @override
  List<Object?> get props => [];
}

final class SearchLoading extends SearchState {
  const SearchLoading();
  @override
  List<Object?> get props => [];
}

final class SearchResults extends SearchState {
  final String query;
  final List<WordSummary> words;
  final bool hasMore;
  final int currentPage;

  const SearchResults({
    required this.query,
    required this.words,
    required this.hasMore,
    required this.currentPage,
  });

  @override
  List<Object?> get props => [query, words, hasMore, currentPage];
}

final class SearchError extends SearchState {
  final Failure failure;

  const SearchError(this.failure);

  @override
  List<Object?> get props => [failure];
}
