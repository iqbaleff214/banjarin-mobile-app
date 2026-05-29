import 'package:equatable/equatable.dart';

import '../../domain/entities/contribution.dart';

sealed class ContributionEvent extends Equatable {
  const ContributionEvent();
}

final class LoadContributions extends ContributionEvent {
  final ContributionStatus? filterStatus;

  const LoadContributions({this.filterStatus});

  @override
  List<Object?> get props => [filterStatus];
}

final class LoadMoreContributions extends ContributionEvent {
  const LoadMoreContributions();

  @override
  List<Object?> get props => [];
}

final class SubmitContributionEvent extends ContributionEvent {
  final ContributionType type;
  final String? targetWordId;
  final Map<String, dynamic> payload;

  const SubmitContributionEvent({
    required this.type,
    this.targetWordId,
    required this.payload,
  });

  @override
  List<Object?> get props => [type, targetWordId, payload];
}

final class WithdrawContributionEvent extends ContributionEvent {
  final String contributionId;
  final ContributionStatus currentStatus;

  const WithdrawContributionEvent({
    required this.contributionId,
    required this.currentStatus,
  });

  @override
  List<Object?> get props => [contributionId, currentStatus];
}
