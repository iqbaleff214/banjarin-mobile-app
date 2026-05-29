import 'package:equatable/equatable.dart';

import '../../../dictionary/domain/entities/word_summary.dart';

class Bookmark extends Equatable {
  final String id;
  final String wordId;
  final WordSummary word;
  final DateTime createdAt;

  const Bookmark({
    required this.id,
    required this.wordId,
    required this.word,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, wordId, word, createdAt];
}
