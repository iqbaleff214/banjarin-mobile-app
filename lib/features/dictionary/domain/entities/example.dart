import 'package:equatable/equatable.dart';

import 'content_source.dart';

class Example extends Equatable {
  final String id;
  final String banjarSentence;
  final String indonesianTranslation;
  final ContentSource source;

  const Example({
    required this.id,
    required this.banjarSentence,
    required this.indonesianTranslation,
    required this.source,
  });

  @override
  List<Object?> get props => [id, banjarSentence, indonesianTranslation, source];
}
