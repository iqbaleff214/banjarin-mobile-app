import 'package:equatable/equatable.dart';

import '../../../community/domain/entities/contribution.dart';

sealed class ModerationEvent extends Equatable {
  const ModerationEvent();
}

final class LoadModerationQueue extends ModerationEvent {
  final ContributionType? type;
  const LoadModerationQueue({this.type});
  @override List<Object?> get props => [type];
}

final class LoadModerationStats extends ModerationEvent {
  const LoadModerationStats();
  @override List<Object?> get props => [];
}

final class LoadFlaggedComments extends ModerationEvent {
  const LoadFlaggedComments();
  @override List<Object?> get props => [];
}

final class ApproveContributionEvent extends ModerationEvent {
  final String contributionId;
  final String? note;
  const ApproveContributionEvent({required this.contributionId, this.note});
  @override List<Object?> get props => [contributionId, note];
}

final class RejectContributionEvent extends ModerationEvent {
  final String contributionId;
  final String note;
  const RejectContributionEvent({required this.contributionId, required this.note});
  @override List<Object?> get props => [contributionId, note];
}
