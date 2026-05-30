import '../../domain/entities/content_source.dart';
import '../../domain/entities/word.dart';
import '../../domain/entities/word_class.dart';
import 'definition_model.dart';
import 'example_model.dart';

class WordModel {
  final String id;
  final String banjar;
  final String? banjarSyllabified;
  final String dialect;
  final WordClass wordClass;
  final int homonymNumber;
  final bool isRoot;
  final String? rootWordId;
  final List<DefinitionModel> definitions;
  final List<ExampleModel> examples;
  final List<String> relatedWordIds;
  final WordStatus status;
  final ContentSource source;
  final String? sourceReference;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WordModel({
    required this.id,
    required this.banjar,
    this.banjarSyllabified,
    required this.dialect,
    required this.wordClass,
    required this.homonymNumber,
    required this.isRoot,
    this.rootWordId,
    required this.definitions,
    required this.examples,
    required this.relatedWordIds,
    required this.status,
    required this.source,
    this.sourceReference,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WordModel.fromJson(Map<String, dynamic> json) {
    return WordModel(
      id: json['id'] as String? ?? '',
      banjar: json['banjar'] as String? ?? '',
      banjarSyllabified: json['banjar_syllabified'] as String?,
      dialect: json['dialect'] as String? ?? 'hulu',
      wordClass: WordClass.fromString(json['word_class'] as String? ?? 'n'),
      homonymNumber: json['homonym_number'] as int? ?? 1,
      isRoot: json['is_root'] as bool? ?? true,
      rootWordId: json['root_word_id'] as String?,
      definitions: (json['definitions'] as List<dynamic>?)
              ?.map((e) => DefinitionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      examples: (json['examples'] as List<dynamic>?)
              ?.map((e) => ExampleModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      relatedWordIds: (json['related_words'] as List<dynamic>?)
              ?.whereType<String>()
              .toList() ??
          [],
      status: WordStatus.fromString(json['status'] as String? ?? 'active'),
      source: ContentSource.fromString(json['source'] as String? ?? 'seeded'),
      sourceReference: json['source_reference'] as String?,
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String? ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'banjar': banjar,
        'banjar_syllabified': banjarSyllabified,
        'dialect': dialect,
        'word_class': wordClass.name,
        'homonym_number': homonymNumber,
        'is_root': isRoot,
        'root_word_id': rootWordId,
        'definitions': definitions.map((d) => d.toJson()).toList(),
        'examples': examples.map((e) => e.toJson()).toList(),
        'related_words': relatedWordIds,
        'status': status.name,
        'source': source.name,
        'source_reference': sourceReference,
        'created_by': createdBy,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  Word toEntity() => Word(
        id: id,
        banjar: banjar,
        banjarSyllabified: banjarSyllabified,
        dialect: dialect,
        wordClass: wordClass,
        homonymNumber: homonymNumber,
        isRoot: isRoot,
        rootWordId: rootWordId,
        definitions: definitions.map((d) => d.toEntity()).toList(),
        examples: examples.map((e) => e.toEntity()).toList(),
        relatedWordIds: relatedWordIds,
        status: status,
        source: source,
        sourceReference: sourceReference,
        createdBy: createdBy,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
