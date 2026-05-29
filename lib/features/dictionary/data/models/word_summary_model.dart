import '../../domain/entities/content_source.dart';
import '../../domain/entities/word_class.dart';
import '../../domain/entities/word_summary.dart';

class WordSummaryModel {
  final String id;
  final String banjar;
  final String dialect;
  final WordClass wordClass;
  final int homonymNumber;
  final bool isRoot;
  final String primaryMeaning;
  final ContentSource source;
  final DateTime createdAt;

  const WordSummaryModel({
    required this.id,
    required this.banjar,
    required this.dialect,
    required this.wordClass,
    required this.homonymNumber,
    required this.isRoot,
    required this.primaryMeaning,
    required this.source,
    required this.createdAt,
  });

  factory WordSummaryModel.fromJson(Map<String, dynamic> json) {
    return WordSummaryModel(
      id: json['id'] as String,
      banjar: json['banjar'] as String,
      dialect: json['dialect'] as String? ?? 'hulu',
      wordClass: WordClass.fromString(json['word_class'] as String? ?? 'n'),
      homonymNumber: json['homonym_number'] as int? ?? 1,
      isRoot: json['is_root'] as bool? ?? true,
      primaryMeaning: json['primary_meaning'] as String? ?? '',
      source: ContentSource.fromString(json['source'] as String? ?? 'seeded'),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'banjar': banjar,
        'dialect': dialect,
        'word_class': wordClass.name,
        'homonym_number': homonymNumber,
        'is_root': isRoot,
        'primary_meaning': primaryMeaning,
        'source': source.name,
        'created_at': createdAt.toIso8601String(),
      };

  WordSummary toEntity() => WordSummary(
        id: id,
        banjar: banjar,
        dialect: dialect,
        wordClass: wordClass,
        homonymNumber: homonymNumber,
        isRoot: isRoot,
        primaryMeaning: primaryMeaning,
        source: source,
        createdAt: createdAt,
      );
}
