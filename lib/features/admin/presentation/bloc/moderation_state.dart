import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../community/domain/entities/comment.dart';
import '../../../community/domain/entities/contribution.dart';
import '../../domain/entities/moderation_stats.dart';

sealed class ModerationState extends Equatable {
  const ModerationState();
}

final class ModerationInitial extends ModerationState {
  const ModerationInitial();
  @override List<Object?> get props => [];
}

final class ModerationLoading extends ModerationState {
  const ModerationLoading();
  @override List<Object?> get props => [];
}

final class ModerationLoaded extends ModerationState {
  final List<Contribution> queue;
  final List<Comment> flaggedComments;
  final ModerationStats? stats;
  final bool hasMoreQueue;
  final int currentPage;

  const ModerationLoaded({
    this.queue = const [],
    this.flaggedComments = const [],
    this.stats,
    this.hasMoreQueue = false,
    this.currentPage = 1,
  });

  ModerationLoaded copyWith({
    List<Contribution>? queue,
    List<Comment>? flaggedComments,
    ModerationStats? stats,
    bool? hasMoreQueue,
    int? currentPage,
  }) {
    return ModerationLoaded(
      queue: queue ?? this.queue,
      flaggedComments: flaggedComments ?? this.flaggedComments,
      stats: stats ?? this.stats,
      hasMoreQueue: hasMoreQueue ?? this.hasMoreQueue,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props =>
      [queue, flaggedComments, stats, hasMoreQueue, currentPage];
}

final class ModerationApproving extends ModerationState {
  final List<Contribution> currentQueue;
  const ModerationApproving(this.currentQueue);
  @override List<Object?> get props => [currentQueue];
}

final class ModerationApproved extends ModerationState {
  final List<Contribution> queue;
  final ModerationStats? stats;
  final String approvedId;

  const ModerationApproved({
    required this.queue,
    this.stats,
    required this.approvedId,
  });

  @override
  List<Object?> get props => [queue, stats, approvedId];
}

final class ModerationRejecting extends ModerationState {
  final List<Contribution> currentQueue;
  const ModerationRejecting(this.currentQueue);
  @override List<Object?> get props => [currentQueue];
}

final class ModerationRejected extends ModerationState {
  final List<Contribution> queue;
  final ModerationStats? stats;
  final String rejectedId;

  const ModerationRejected({
    required this.queue,
    this.stats,
    required this.rejectedId,
  });

  @override
  List<Object?> get props => [queue, stats, rejectedId];
}

final class ModerationError extends ModerationState {
  final Failure failure;
  const ModerationError(this.failure);
  @override List<Object?> get props => [failure];
}
