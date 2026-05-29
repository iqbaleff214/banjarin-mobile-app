import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/definition.dart';
import '../../domain/entities/example.dart';
import '../../domain/entities/word.dart';
import '../../domain/entities/word_summary.dart';

sealed class WordDetailState extends Equatable {
  const WordDetailState();
}

final class WordDetailInitial extends WordDetailState {
  const WordDetailInitial();
  @override
  List<Object?> get props => [];
}

final class WordDetailLoading extends WordDetailState {
  const WordDetailLoading();
  @override
  List<Object?> get props => [];
}

final class WordDetailLoaded extends WordDetailState {
  final Word word;
  final List<Definition> definitions;
  final List<Example> examples;
  final List<WordSummary> relatedWords;
  final Failure? definitionsError;
  final Failure? examplesError;
  final Failure? relatedError;

  const WordDetailLoaded({
    required this.word,
    required this.definitions,
    required this.examples,
    required this.relatedWords,
    this.definitionsError,
    this.examplesError,
    this.relatedError,
  });

  @override
  List<Object?> get props => [
        word,
        definitions,
        examples,
        relatedWords,
        definitionsError,
        examplesError,
        relatedError,
      ];
}

final class WordDetailError extends WordDetailState {
  final Failure failure;

  const WordDetailError(this.failure);

  @override
  List<Object?> get props => [failure];
}
