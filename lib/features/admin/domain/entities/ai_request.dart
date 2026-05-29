import 'package:equatable/equatable.dart';

enum AIRequestType {
  // ignore: constant_identifier_names
  enrich_definition,
  // ignore: constant_identifier_names
  suggest_example,
  // ignore: constant_identifier_names
  suggest_related,
  // ignore: constant_identifier_names
  quality_check;

  String get label => switch (this) {
        AIRequestType.enrich_definition => 'Perkaya Definisi',
        AIRequestType.suggest_example => 'Sarankan Contoh',
        AIRequestType.suggest_related => 'Sarankan Kata Terkait',
        AIRequestType.quality_check => 'Quality Check',
      };

  static AIRequestType fromString(String v) => AIRequestType.values
      .firstWhere((e) => e.name == v, orElse: () => AIRequestType.enrich_definition);
}

enum AIRequestStatus {
  pending,
  completed,
  failed;

  static AIRequestStatus fromString(String v) => AIRequestStatus.values
      .firstWhere((e) => e.name == v, orElse: () => AIRequestStatus.pending);
}

enum AIReviewStatus {
  unreviewed,
  approved,
  rejected;

  static AIReviewStatus fromString(String v) => AIReviewStatus.values
      .firstWhere((e) => e.name == v, orElse: () => AIReviewStatus.unreviewed);
}

class AIRequest extends Equatable {
  final String id;
  final AIRequestType type;
  final String? targetWordId;
  final String? targetContributionId;
  final String? requestedBy;
  final String model;
  final String? prompt;
  final Map<String, dynamic>? response;
  final Map<String, dynamic>? parsedOutput;
  final AIRequestStatus status;
  final AIReviewStatus reviewStatus;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final DateTime createdAt;

  const AIRequest({
    required this.id,
    required this.type,
    this.targetWordId,
    this.targetContributionId,
    this.requestedBy,
    required this.model,
    this.prompt,
    this.response,
    this.parsedOutput,
    required this.status,
    required this.reviewStatus,
    this.reviewedBy,
    this.reviewedAt,
    required this.createdAt,
  });

  AIRequest copyWith({AIReviewStatus? reviewStatus, String? reviewedBy}) {
    return AIRequest(
      id: id,
      type: type,
      targetWordId: targetWordId,
      targetContributionId: targetContributionId,
      requestedBy: requestedBy,
      model: model,
      prompt: prompt,
      response: response,
      parsedOutput: parsedOutput,
      status: status,
      reviewStatus: reviewStatus ?? this.reviewStatus,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewedAt: reviewedAt,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id, type, targetWordId, targetContributionId, requestedBy, model,
        prompt, response, parsedOutput, status, reviewStatus, reviewedBy,
        reviewedAt, createdAt,
      ];
}
