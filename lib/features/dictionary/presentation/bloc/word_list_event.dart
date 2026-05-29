import 'package:equatable/equatable.dart';

import '../../domain/entities/content_source.dart';
import '../../domain/entities/sort_words.dart';
import '../../domain/entities/word_class.dart';

sealed class WordListEvent extends Equatable {
  const WordListEvent();
}

final class LoadWords extends WordListEvent {
  const LoadWords();
  @override
  List<Object?> get props => [];
}

final class LoadMoreWords extends WordListEvent {
  const LoadMoreWords();
  @override
  List<Object?> get props => [];
}

final class RefreshWords extends WordListEvent {
  const RefreshWords();
  @override
  List<Object?> get props => [];
}

final class FilterChanged extends WordListEvent {
  final WordClass? wordClass;
  final bool? isRoot;
  final ContentSource? source;

  const FilterChanged({this.wordClass, this.isRoot, this.source});

  @override
  List<Object?> get props => [wordClass, isRoot, source];
}

final class SortChanged extends WordListEvent {
  final SortWords sort;

  const SortChanged(this.sort);

  @override
  List<Object?> get props => [sort];
}
