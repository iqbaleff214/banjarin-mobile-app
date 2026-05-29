import '../../domain/entities/contribution.dart';

class ContributionModel {
  final String id;
  final ContributionType type;
  final String contributorId;
  final String? targetWordId;
  final Map<String, dynamic> payload;
  final ContributionStatus status;
  final String? reviewerId;
  final String? reviewerNote;
  final DateTime submittedAt;
  final DateTime? reviewedAt;

  const ContributionModel({
    required this.id,
    required this.type,
    required this.contributorId,
    this.targetWordId,
    required this.payload,
    required this.status,
    this.reviewerId,
    this.reviewerNote,
    required this.submittedAt,
    this.reviewedAt,
  });

  factory ContributionModel.fromJson(Map<String, dynamic> json) {
    return ContributionModel(
      id: json['id'] as String,
      type: ContributionType.fromString(json['type'] as String),
      contributorId: json['contributor_id'] as String,
      targetWordId: json['target_word_id'] as String?,
      payload: (json['payload'] as Map<String, dynamic>?) ?? {},
      status: ContributionStatus.fromString(json['status'] as String),
      reviewerId: json['reviewer_id'] as String?,
      reviewerNote: json['reviewer_note'] as String?,
      submittedAt: DateTime.parse(json['submitted_at'] as String? ?? DateTime.now().toIso8601String()),
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.parse(json['reviewed_at'] as String)
          : null,
    );
  }

  Contribution toEntity() => Contribution(
        id: id,
        type: type,
        contributorId: contributorId,
        targetWordId: targetWordId,
        payload: payload,
        status: status,
        reviewerId: reviewerId,
        reviewerNote: reviewerNote,
        submittedAt: submittedAt,
        reviewedAt: reviewedAt,
      );
}
