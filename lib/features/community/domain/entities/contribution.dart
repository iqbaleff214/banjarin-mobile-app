import 'package:equatable/equatable.dart';

enum ContributionType {
  // ignore: constant_identifier_names
  new_word,
  // ignore: constant_identifier_names
  new_definition,
  // ignore: constant_identifier_names
  new_example,
  // ignore: constant_identifier_names
  edit_word;

  String get label => switch (this) {
        ContributionType.new_word => 'Kata Baru',
        ContributionType.new_definition => 'Definisi',
        ContributionType.new_example => 'Contoh',
        ContributionType.edit_word => 'Edit Kata',
      };

  static ContributionType fromString(String v) => ContributionType.values
      .firstWhere((e) => e.name == v, orElse: () => ContributionType.new_word);
}

enum ContributionStatus {
  pending,
  approved,
  rejected,
  withdrawn;

  static ContributionStatus fromString(String v) =>
      ContributionStatus.values.firstWhere((e) => e.name == v,
          orElse: () => ContributionStatus.pending);
}

class Contribution extends Equatable {
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

  const Contribution({
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

  Contribution copyWith({ContributionStatus? status}) {
    return Contribution(
      id: id,
      type: type,
      contributorId: contributorId,
      targetWordId: targetWordId,
      payload: payload,
      status: status ?? this.status,
      reviewerId: reviewerId,
      reviewerNote: reviewerNote,
      submittedAt: submittedAt,
      reviewedAt: reviewedAt,
    );
  }

  @override
  List<Object?> get props => [
        id, type, contributorId, targetWordId, payload, status,
        reviewerId, reviewerNote, submittedAt, reviewedAt,
      ];
}
