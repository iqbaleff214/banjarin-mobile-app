import 'package:equatable/equatable.dart';

import 'content_source.dart';
import 'word_class.dart';

class WordSummary extends Equatable {
  final String id;
  final String banjar;
  final String dialect;
  final WordClass wordClass;
  final int homonymNumber;
  final bool isRoot;
  final String primaryMeaning;
  final ContentSource source;
  final DateTime createdAt;

  const WordSummary({
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

  bool get isHomonym => homonymNumber > 1;

  @override
  List<Object?> get props => [
        id,
        banjar,
        dialect,
        wordClass,
        homonymNumber,
        isRoot,
        primaryMeaning,
        source,
        createdAt,
      ];
}
