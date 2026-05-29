import 'package:equatable/equatable.dart';

sealed class WordDetailEvent extends Equatable {
  const WordDetailEvent();
}

final class LoadWordDetail extends WordDetailEvent {
  final String wordId;

  const LoadWordDetail(this.wordId);

  @override
  List<Object?> get props => [wordId];
}
