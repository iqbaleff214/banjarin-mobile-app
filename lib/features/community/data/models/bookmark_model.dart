import '../../../dictionary/data/models/word_summary_model.dart';
import '../../domain/entities/bookmark.dart';

class BookmarkModel {
  final String id;
  final String wordId;
  final WordSummaryModel word;
  final DateTime createdAt;

  const BookmarkModel({
    required this.id,
    required this.wordId,
    required this.word,
    required this.createdAt,
  });

  factory BookmarkModel.fromJson(Map<String, dynamic> json) {
    return BookmarkModel(
      id: json['id'] as String,
      wordId: json['word_id'] as String,
      word: WordSummaryModel.fromJson(json['word'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['created_at'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'word_id': wordId,
        'word': word.toJson(),
        'created_at': createdAt.toIso8601String(),
      };

  Bookmark toEntity() => Bookmark(
        id: id,
        wordId: wordId,
        word: word.toEntity(),
        createdAt: createdAt,
      );
}
