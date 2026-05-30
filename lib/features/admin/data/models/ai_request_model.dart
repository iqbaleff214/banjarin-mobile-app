import '../../domain/entities/ai_request.dart';

class AIRequestModel {
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

  const AIRequestModel({
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

  factory AIRequestModel.fromJson(Map<String, dynamic> json) {
    return AIRequestModel(
      id: json['id'] as String? ?? '',
      type: AIRequestType.fromString(json['type'] as String? ?? 'enrich_definition'),
      targetWordId: json['target_word_id'] as String?,
      targetContributionId: json['target_contribution_id'] as String?,
      requestedBy: json['requested_by'] as String?,
      model: json['model'] as String? ?? '',
      prompt: json['prompt'] as String?,
      response: json['response'] as Map<String, dynamic>?,
      parsedOutput: json['parsed_output'] as Map<String, dynamic>?,
      status: AIRequestStatus.fromString(json['status'] as String? ?? 'pending'),
      reviewStatus: AIReviewStatus.fromString(
        json['review_status'] as String? ?? 'unreviewed',
      ),
      reviewedBy: json['reviewed_by'] as String?,
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.parse(json['reviewed_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  AIRequest toEntity() => AIRequest(
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
        reviewStatus: reviewStatus,
        reviewedBy: reviewedBy,
        reviewedAt: reviewedAt,
        createdAt: createdAt,
      );
}
