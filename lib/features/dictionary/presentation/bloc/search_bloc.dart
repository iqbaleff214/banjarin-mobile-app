import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_transform/stream_transform.dart';

import '../../domain/repositories/word_repository.dart';
import '../../domain/usecases/search_words.dart';
import 'search_event.dart';
import 'search_state.dart';

EventTransformer<E> _debounceEvents<E>(Duration duration) =>
    (events, mapper) => events.debounce(duration).switchMap(mapper);

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchWords _searchWords;
  static const _perPage = 20;
  static const _debounceDuration = Duration(milliseconds: 400);

  SearchBloc({required SearchWords searchWords})
      : _searchWords = searchWords,
        super(const SearchInitial()) {
    on<QueryChanged>(
      _onQueryChanged,
      transformer: _debounceEvents(_debounceDuration),
    );
    on<LoadMoreSearchResults>(_onLoadMore);
  }

  Future<void> _onQueryChanged(
    QueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    if (event.query.trim().isEmpty) {
      emit(const SearchEmpty());
      return;
    }
    emit(const SearchLoading());
    final result = await _searchWords(SearchParams(query: event.query.trim()));
    result.fold(
      (failure) => emit(SearchError(failure)),
      (paginated) => emit(SearchResults(
        query: event.query.trim(),
        words: paginated.items,
        hasMore: paginated.hasMore,
        currentPage: paginated.page,
      )),
    );
  }

  Future<void> _onLoadMore(
    LoadMoreSearchResults event,
    Emitter<SearchState> emit,
  ) async {
    final current = state;
    if (current is! SearchResults || !current.hasMore) return;

    final result = await _searchWords(SearchParams(
      query: current.query,
      page: current.currentPage + 1,
      perPage: _perPage,
    ));
    result.fold(
      (failure) => emit(SearchError(failure)),
      (paginated) => emit(SearchResults(
        query: current.query,
        words: [...current.words, ...paginated.items],
        hasMore: paginated.hasMore,
        currentPage: paginated.page,
      )),
    );
  }
}
