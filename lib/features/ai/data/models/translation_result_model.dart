import '../../domain/entities/confidence_level.dart';
import '../../domain/entities/translation_result.dart';

class TranslationResultModel {
  final String original;
  final String translation;
  final String dialect;
  final String model;
  final ConfidenceLevel confidence;
  final String? notes;

  const TranslationResultModel({
    required this.original,
    required this.translation,
    required this.dialect,
    required this.model,
    required this.confidence,
    this.notes,
  });

  factory TranslationResultModel.fromJson(Map<String, dynamic> json) {
    return TranslationResultModel(
      original: json['original'] as String,
      translation: json['translation'] as String,
      dialect: json['dialect'] as String? ?? 'hulu',
      model: json['model'] as String? ?? '',
      confidence: ConfidenceLevel.fromString(
        json['confidence'] as String? ?? 'high',
      ),
      notes: json['notes'] as String?,
    );
  }

  TranslationResult toEntity() => TranslationResult(
        original: original,
        translation: translation,
        dialect: dialect,
        model: model,
        confidence: confidence,
        notes: notes,
      );
}
