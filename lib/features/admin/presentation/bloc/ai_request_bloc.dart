import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/ai_request.dart';
import '../../domain/repositories/admin_repository.dart';
import '../../domain/usecases/approve_ai_request.dart';
import '../../domain/usecases/get_ai_requests.dart';
import '../../domain/usecases/reject_ai_request.dart';
import '../../domain/usecases/run_quality_check.dart';
import '../../domain/usecases/trigger_ai_enrich.dart';
import '../../domain/usecases/trigger_ai_example.dart';
import '../../domain/usecases/trigger_ai_related.dart';
import 'ai_request_event.dart';
import 'ai_request_state.dart';

class AIRequestBloc extends Bloc<AIRequestEvent, AIRequestState> {
  final TriggerAIEnrich _triggerEnrich;
  final TriggerAIExample _triggerExample;
  final TriggerAIRelated _triggerRelated;
  final RunQualityCheck _runCheck;
  final GetAIRequests _getRequests;
  final ApproveAIRequest _approve;
  final RejectAIRequest _reject;

  AIRequestBloc({
    required TriggerAIEnrich triggerEnrich,
    required TriggerAIExample triggerExample,
    required TriggerAIRelated triggerRelated,
    required RunQualityCheck runCheck,
    required GetAIRequests getRequests,
    required ApproveAIRequest approve,
    required RejectAIRequest reject,
  })  : _triggerEnrich = triggerEnrich,
        _triggerExample = triggerExample,
        _triggerRelated = triggerRelated,
        _runCheck = runCheck,
        _getRequests = getRequests,
        _approve = approve,
        _reject = reject,
        super(const AIRequestInitial()) {
    on<TriggerAIEvent>(_onTrigger);
    on<LoadAIRequests>(_onLoad);
    on<ApproveAIRequestEvent>(_onApprove);
    on<RejectAIRequestEvent>(_onReject);
  }

  AIRequestLoaded? get _currentLoaded =>
      state is AIRequestLoaded ? state as AIRequestLoaded : null;

  Future<void> _onTrigger(
    TriggerAIEvent event,
    Emitter<AIRequestState> emit,
  ) async {
    emit(const Triggering());

    Either<Failure, AIRequest> result;
    switch (event.type) {
      case AIRequestType.enrich_definition:
        result = await _triggerEnrich(
            TriggerAIEnrichParams(wordId: event.wordId!));
      case AIRequestType.suggest_example:
        result = await _triggerExample(
            TriggerAIExampleParams(wordId: event.wordId!));
      case AIRequestType.suggest_related:
        result = await _triggerRelated(
            TriggerAIRelatedParams(wordId: event.wordId!));
      case AIRequestType.quality_check:
        result = await _runCheck(
            RunQualityCheckParams(contributionId: event.contributionId!));
    }

    result.fold(
      (failure) => emit(AIRequestError(failure)),
      (request) => emit(Triggered(request)),
    );
  }

  Future<void> _onLoad(
    LoadAIRequests event,
    Emitter<AIRequestState> emit,
  ) async {
    emit(const AIRequestLoading());
    final result = await _getRequests(GetAIRequestsParams(
      type: event.filterType,
      reviewStatus: event.filterReviewStatus,
    ));
    result.fold(
      (failure) => emit(AIRequestError(failure)),
      (paginated) => emit(AIRequestLoaded(
        requests: paginated.items,
        hasMore: paginated.hasMore,
        currentPage: paginated.page,
        filterType: event.filterType,
        filterReviewStatus: event.filterReviewStatus,
      )),
    );
  }

  Future<void> _onApprove(
    ApproveAIRequestEvent event,
    Emitter<AIRequestState> emit,
  ) async {
    final current = _currentLoaded;
    emit(Reviewing(current?.requests ?? []));

    final result = await _approve(ApproveAIRequestParams(
      requestId: event.requestId,
      type: event.type,
      reviewStatus: event.reviewStatus,
    ));

    result.fold(
      (failure) => emit(AIRequestError(failure)),
      (updated) {
        final updatedList = (current?.requests ?? [])
            .map((r) => r.id == updated.id ? updated : r)
            .toList();
        emit(Reviewed(
          requests: updatedList,
          reviewedId: updated.id,
          hasMore: current?.hasMore ?? false,
          currentPage: current?.currentPage ?? 1,
        ));
      },
    );
  }

  Future<void> _onReject(
    RejectAIRequestEvent event,
    Emitter<AIRequestState> emit,
  ) async {
    final current = _currentLoaded;
    emit(Reviewing(current?.requests ?? []));

    final result = await _reject(
        RejectAIRequestParams(requestId: event.requestId));

    result.fold(
      (failure) => emit(AIRequestError(failure)),
      (updated) {
        final updatedList = (current?.requests ?? [])
            .map((r) => r.id == updated.id ? updated : r)
            .toList();
        emit(Reviewed(
          requests: updatedList,
          reviewedId: updated.id,
          hasMore: current?.hasMore ?? false,
          currentPage: current?.currentPage ?? 1,
        ));
      },
    );
  }
}
