import 'package:equatable/equatable.dart';

import '../../domain/entities/ai_request.dart';

sealed class AIRequestEvent extends Equatable {
  const AIRequestEvent();
}

final class TriggerAIEvent extends AIRequestEvent {
  final AIRequestType type;
  final String? wordId;
  final String? contributionId;

  const TriggerAIEvent({
    required this.type,
    this.wordId,
    this.contributionId,
  });

  @override
  List<Object?> get props => [type, wordId, contributionId];
}

final class LoadAIRequests extends AIRequestEvent {
  final AIRequestType? filterType;
  final AIRequestStatus? filterStatus;
  final AIReviewStatus? filterReviewStatus;

  const LoadAIRequests({
    this.filterType,
    this.filterStatus,
    this.filterReviewStatus,
  });

  @override
  List<Object?> get props => [filterType, filterStatus, filterReviewStatus];
}

final class ApproveAIRequestEvent extends AIRequestEvent {
  final String requestId;
  final AIRequestType type;
  final AIReviewStatus reviewStatus;

  const ApproveAIRequestEvent({
    required this.requestId,
    required this.type,
    required this.reviewStatus,
  });

  @override
  List<Object?> get props => [requestId, type, reviewStatus];
}

final class RejectAIRequestEvent extends AIRequestEvent {
  final String requestId;

  const RejectAIRequestEvent(this.requestId);

  @override
  List<Object?> get props => [requestId];
}
