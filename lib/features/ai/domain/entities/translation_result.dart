import 'package:equatable/equatable.dart';

import 'confidence_level.dart';

class TranslationResult extends Equatable {
  final String original;
  final String translation;
  final String dialect;
  final String model;
  final ConfidenceLevel confidence;
  final String? notes;

  const TranslationResult({
    required this.original,
    required this.translation,
    required this.dialect,
    required this.model,
    required this.confidence,
    this.notes,
  });

  @override
  List<Object?> get props =>
      [original, translation, dialect, model, confidence, notes];
}
