import 'package:equatable/equatable.dart';

sealed class SearchEvent extends Equatable {
  const SearchEvent();
}

final class QueryChanged extends SearchEvent {
  final String query;

  const QueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

final class LoadMoreSearchResults extends SearchEvent {
  const LoadMoreSearchResults();

  @override
  List<Object?> get props => [];
}
