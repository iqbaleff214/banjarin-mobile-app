import '../../domain/entities/content_source.dart';
import '../../domain/entities/example.dart';

class ExampleModel {
  final String id;
  final String banjarSentence;
  final String indonesianTranslation;
  final ContentSource source;

  const ExampleModel({
    required this.id,
    required this.banjarSentence,
    required this.indonesianTranslation,
    required this.source,
  });

  factory ExampleModel.fromJson(Map<String, dynamic> json) {
    return ExampleModel(
      id: json['id'] as String,
      banjarSentence: json['banjar_sentence'] as String,
      indonesianTranslation: json['indonesian_translation'] as String,
      source: ContentSource.fromString(json['source'] as String? ?? 'seeded'),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'banjar_sentence': banjarSentence,
        'indonesian_translation': indonesianTranslation,
        'source': source.name,
      };

  Example toEntity() => Example(
        id: id,
        banjarSentence: banjarSentence,
        indonesianTranslation: indonesianTranslation,
        source: source,
      );
}
