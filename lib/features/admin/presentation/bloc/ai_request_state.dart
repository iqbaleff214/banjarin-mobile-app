import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/ai_request.dart';

sealed class AIRequestState extends Equatable {
  const AIRequestState();
}

final class AIRequestInitial extends AIRequestState {
  const AIRequestInitial();
  @override List<Object?> get props => [];
}

final class Triggering extends AIRequestState {
  const Triggering();
  @override List<Object?> get props => [];
}

final class Triggered extends AIRequestState {
  final AIRequest aiRequest;
  const Triggered(this.aiRequest);
  @override List<Object?> get props => [aiRequest];
}

final class AIRequestLoading extends AIRequestState {
  const AIRequestLoading();
  @override List<Object?> get props => [];
}

final class AIRequestLoaded extends AIRequestState {
  final List<AIRequest> requests;
  final bool hasMore;
  final int currentPage;
  final AIRequestType? filterType;
  final AIReviewStatus? filterReviewStatus;

  const AIRequestLoaded({
    required this.requests,
    required this.hasMore,
    required this.currentPage,
    this.filterType,
    this.filterReviewStatus,
  });

  @override
  List<Object?> get props =>
      [requests, hasMore, currentPage, filterType, filterReviewStatus];
}

final class Reviewing extends AIRequestState {
  final List<AIRequest> currentRequests;
  const Reviewing(this.currentRequests);
  @override List<Object?> get props => [currentRequests];
}

final class Reviewed extends AIRequestState {
  final List<AIRequest> requests;
  final String reviewedId;
  final bool hasMore;
  final int currentPage;

  const Reviewed({
    required this.requests,
    required this.reviewedId,
    required this.hasMore,
    required this.currentPage,
  });

  @override
  List<Object?> get props => [requests, reviewedId, hasMore, currentPage];
}

final class AIRequestError extends AIRequestState {
  final Failure failure;
  const AIRequestError(this.failure);
  @override List<Object?> get props => [failure];
}
