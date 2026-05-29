import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/definition.dart';
import '../../domain/entities/example.dart';
import '../../domain/entities/word_summary.dart';
import '../../domain/repositories/word_repository.dart';
import '../../domain/usecases/get_definitions.dart';
import '../../domain/usecases/get_examples.dart';
import '../../domain/usecases/get_related_words.dart';
import '../../domain/usecases/get_word_detail.dart';
import 'word_detail_event.dart';
import 'word_detail_state.dart';

class WordDetailBloc extends Bloc<WordDetailEvent, WordDetailState> {
  final GetWordDetail _getWordDetail;
  final GetDefinitions _getDefinitions;
  final GetExamples _getExamples;
  final GetRelatedWords _getRelatedWords;

  WordDetailBloc({
    required GetWordDetail getWordDetail,
    required GetDefinitions getDefinitions,
    required GetExamples getExamples,
    required GetRelatedWords getRelatedWords,
  })  : _getWordDetail = getWordDetail,
        _getDefinitions = getDefinitions,
        _getExamples = getExamples,
        _getRelatedWords = getRelatedWords,
        super(const WordDetailInitial()) {
    on<LoadWordDetail>(_onLoadWordDetail);
  }

  Future<void> _onLoadWordDetail(
    LoadWordDetail event,
    Emitter<WordDetailState> emit,
  ) async {
    emit(const WordDetailLoading());

    final params = WordIdParams(wordId: event.wordId);

    // Parallel fetch — each typed independently
    final wordFuture = _getWordDetail(params);
    final defsFuture = _getDefinitions(params);
    final exsFuture = _getExamples(params);
    final relFuture = _getRelatedWords(params);

    final wordResult = await wordFuture;
    final defsResult = await defsFuture;
    final exsResult = await exsFuture;
    final relResult = await relFuture;

    // Word is the primary resource — fail entirely if not found
    final wordOrNull = wordResult.fold((_) => null, (w) => w);
    if (wordOrNull == null) {
      final failure = wordResult.fold((f) => f, (_) => const ServerFailure());
      emit(WordDetailError(failure));
      return;
    }

    emit(WordDetailLoaded(
      word: wordOrNull,
      definitions: defsResult.fold((_) => <Definition>[], (d) => d),
      examples: exsResult.fold((_) => <Example>[], (e) => e),
      relatedWords: relResult.fold((_) => <WordSummary>[], (r) => r),
      definitionsError: defsResult.fold((f) => f, (_) => null),
      examplesError: exsResult.fold((f) => f, (_) => null),
      relatedError: relResult.fold((f) => f, (_) => null),
    ));
  }
}
