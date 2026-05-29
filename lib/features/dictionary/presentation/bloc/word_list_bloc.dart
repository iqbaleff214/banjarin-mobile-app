import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/word_repository.dart';
import '../../domain/usecases/get_word_list.dart';
import 'word_list_event.dart';
import 'word_list_state.dart';

class WordListBloc extends Bloc<WordListEvent, WordListState> {
  final GetWordList _getWordList;
  static const _perPage = 20;

  WordListBloc({required GetWordList getWordList})
      : _getWordList = getWordList,
        super(const WordListState()) {
    on<LoadWords>(_onLoadWords);
    on<LoadMoreWords>(_onLoadMoreWords);
    on<RefreshWords>(_onRefreshWords);
    on<FilterChanged>(_onFilterChanged);
    on<SortChanged>(_onSortChanged);
  }

  WordListParams _buildParams(WordListState s, {int page = 1}) {
    return WordListParams(
      page: page,
      perPage: _perPage,
      wordClass: s.filterWordClass,
      isRoot: s.filterIsRoot,
      source: s.filterSource,
      sort: s.sort,
    );
  }

  Future<void> _onLoadWords(LoadWords event, Emitter<WordListState> emit) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    final result = await _getWordList(_buildParams(state));
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, error: failure)),
      (paginated) => emit(state.copyWith(
        isLoading: false,
        words: paginated.items,
        currentPage: paginated.page,
        hasMore: paginated.hasMore,
        clearError: true,
      )),
    );
  }

  Future<void> _onLoadMoreWords(
    LoadMoreWords event,
    Emitter<WordListState> emit,
  ) async {
    if (!state.hasMore || state.isLoadingMore) return;
    emit(state.copyWith(isLoadingMore: true));
    final result = await _getWordList(_buildParams(state, page: state.currentPage + 1));
    result.fold(
      (failure) => emit(state.copyWith(isLoadingMore: false, error: failure)),
      (paginated) => emit(state.copyWith(
        isLoadingMore: false,
        words: [...state.words, ...paginated.items],
        currentPage: paginated.page,
        hasMore: paginated.hasMore,
      )),
    );
  }

  Future<void> _onRefreshWords(
    RefreshWords event,
    Emitter<WordListState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, words: [], currentPage: 0, hasMore: true, clearError: true));
    final result = await _getWordList(_buildParams(state));
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, error: failure)),
      (paginated) => emit(state.copyWith(
        isLoading: false,
        words: paginated.items,
        currentPage: paginated.page,
        hasMore: paginated.hasMore,
      )),
    );
  }

  Future<void> _onFilterChanged(
    FilterChanged event,
    Emitter<WordListState> emit,
  ) async {
    final newState = WordListState(
      filterWordClass: event.wordClass,
      filterIsRoot: event.isRoot,
      filterSource: event.source,
      sort: state.sort,
      isLoading: true,
    );
    emit(newState);
    final result = await _getWordList(_buildParams(newState));
    result.fold(
      (failure) => emit(newState.copyWith(isLoading: false, error: failure)),
      (paginated) => emit(newState.copyWith(
        isLoading: false,
        words: paginated.items,
        currentPage: paginated.page,
        hasMore: paginated.hasMore,
      )),
    );
  }

  Future<void> _onSortChanged(
    SortChanged event,
    Emitter<WordListState> emit,
  ) async {
    final newState = WordListState(
      filterWordClass: state.filterWordClass,
      filterIsRoot: state.filterIsRoot,
      filterSource: state.filterSource,
      sort: event.sort,
      isLoading: true,
    );
    emit(newState);
    final result = await _getWordList(_buildParams(newState));
    result.fold(
      (failure) => emit(newState.copyWith(isLoading: false, error: failure)),
      (paginated) => emit(newState.copyWith(
        isLoading: false,
        words: paginated.items,
        currentPage: paginated.page,
        hasMore: paginated.hasMore,
      )),
    );
  }
}
