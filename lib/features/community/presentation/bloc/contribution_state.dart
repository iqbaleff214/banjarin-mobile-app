import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/contribution.dart';

sealed class ContributionState extends Equatable {
  const ContributionState();
}

final class ContributionInitial extends ContributionState {
  const ContributionInitial();
  @override List<Object?> get props => [];
}

final class ContributionLoading extends ContributionState {
  const ContributionLoading();
  @override List<Object?> get props => [];
}

final class ContributionLoaded extends ContributionState {
  final List<Contribution> contributions;
  final bool hasMore;
  final int currentPage;
  final ContributionStatus? filterStatus;

  const ContributionLoaded({
    required this.contributions,
    required this.hasMore,
    required this.currentPage,
    this.filterStatus,
  });

  @override
  List<Object?> get props => [contributions, hasMore, currentPage, filterStatus];
}

final class ContributionSubmitting extends ContributionState {
  const ContributionSubmitting();
  @override List<Object?> get props => [];
}

final class ContributionSubmitted extends ContributionState {
  final Contribution contribution;

  const ContributionSubmitted(this.contribution);

  @override
  List<Object?> get props => [contribution];
}

final class ContributionWithdrawing extends ContributionState {
  final List<Contribution> currentContributions;

  const ContributionWithdrawing(this.currentContributions);

  @override
  List<Object?> get props => [currentContributions];
}

final class ContributionWithdrawn extends ContributionState {
  final List<Contribution> contributions;
  final String withdrawnId;

  const ContributionWithdrawn({
    required this.contributions,
    required this.withdrawnId,
  });

  @override
  List<Object?> get props => [contributions, withdrawnId];
}

final class ContributionError extends ContributionState {
  final Failure failure;

  const ContributionError(this.failure);

  @override
  List<Object?> get props => [failure];
}
