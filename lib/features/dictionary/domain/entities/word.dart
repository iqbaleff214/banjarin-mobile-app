import 'package:equatable/equatable.dart';

import 'content_source.dart';
import 'definition.dart';
import 'example.dart';
import 'word_class.dart';

enum WordStatus {
  active,
  deprecated;

  static WordStatus fromString(String v) =>
      v == 'deprecated' ? WordStatus.deprecated : WordStatus.active;
}

class Word extends Equatable {
  final String id;
  final String banjar;
  final String? banjarSyllabified;
  final String dialect;
  final WordClass wordClass;
  final int homonymNumber;
  final bool isRoot;
  final String? rootWordId;
  final List<Definition> definitions;
  final List<Example> examples;
  final List<String> relatedWordIds;
  final WordStatus status;
  final ContentSource source;
  final String? sourceReference;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Word({
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

  bool get isHomonym => homonymNumber > 1;
  bool get isActive => status == WordStatus.active;

  @override
  List<Object?> get props => [
        id,
        banjar,
        banjarSyllabified,
        dialect,
        wordClass,
        homonymNumber,
        isRoot,
        rootWordId,
        definitions,
        examples,
        relatedWordIds,
        status,
        source,
        sourceReference,
        createdBy,
        createdAt,
        updatedAt,
      ];
}
