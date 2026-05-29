import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/repositories/admin_repository.dart';
import '../../domain/usecases/approve_contribution.dart';
import '../../domain/usecases/get_flagged_comments.dart';
import '../../domain/usecases/get_moderation_queue.dart';
import '../../domain/usecases/get_moderation_stats.dart';
import '../../domain/usecases/reject_contribution.dart';
import 'moderation_event.dart';
import 'moderation_state.dart';

class ModerationBloc extends Bloc<ModerationEvent, ModerationState> {
  final GetModerationQueue _getQueue;
  final GetFlaggedComments _getFlags;
  final GetModerationStats _getStats;
  final ApproveContribution _approve;
  final RejectContribution _reject;

  ModerationBloc({
    required GetModerationQueue getQueue,
    required GetFlaggedComments getFlags,
    required GetModerationStats getStats,
    required ApproveContribution approve,
    required RejectContribution reject,
  })  : _getQueue = getQueue,
        _getFlags = getFlags,
        _getStats = getStats,
        _approve = approve,
        _reject = reject,
        super(const ModerationInitial()) {
    on<LoadModerationQueue>(_onLoadQueue);
    on<LoadModerationStats>(_onLoadStats);
    on<LoadFlaggedComments>(_onLoadFlags);
    on<ApproveContributionEvent>(_onApprove);
    on<RejectContributionEvent>(_onReject);
  }

  ModerationLoaded get _currentLoaded =>
      state is ModerationLoaded ? state as ModerationLoaded : const ModerationLoaded();

  Future<void> _onLoadQueue(
      LoadModerationQueue event, Emitter<ModerationState> emit) async {
    emit(const ModerationLoading());
    final result = await _getQueue(
      GetModerationQueueParams(type: event.type),
    );
    result.fold(
      (f) => emit(ModerationError(f)),
      (p) => emit(ModerationLoaded(
        queue: p.items,
        hasMoreQueue: p.hasMore,
        currentPage: p.page,
      )),
    );
  }

  Future<void> _onLoadStats(
      LoadModerationStats event, Emitter<ModerationState> emit) async {
    final result = await _getStats(const NoParams());
    result.fold(
      (f) => emit(ModerationError(f)),
      (stats) => emit(_currentLoaded.copyWith(stats: stats)),
    );
  }

  Future<void> _onLoadFlags(
      LoadFlaggedComments event, Emitter<ModerationState> emit) async {
    final result = await _getFlags(const GetFlaggedCommentsParams());
    result.fold(
      (f) => emit(ModerationError(f)),
      (p) => emit(_currentLoaded.copyWith(flaggedComments: p.items)),
    );
  }

  Future<void> _onApprove(
      ApproveContributionEvent event, Emitter<ModerationState> emit) async {
    final current = _currentLoaded;
    emit(ModerationApproving(current.queue));
    final result = await _approve(ApproveContributionParams(
      contributionId: event.contributionId,
      note: event.note,
    ));
    result.fold(
      (f) => emit(ModerationError(f)),
      (_) => emit(ModerationApproved(
        queue: current.queue
            .where((c) => c.id != event.contributionId)
            .toList(),
        stats: current.stats,
        approvedId: event.contributionId,
      )),
    );
  }

  Future<void> _onReject(
      RejectContributionEvent event, Emitter<ModerationState> emit) async {
    final current = _currentLoaded;
    emit(ModerationRejecting(current.queue));
    final result = await _reject(RejectContributionParams(
      contributionId: event.contributionId,
      note: event.note,
    ));
    result.fold(
      (f) => emit(ModerationError(f)),
      (_) => emit(ModerationRejected(
        queue: current.queue
            .where((c) => c.id != event.contributionId)
            .toList(),
        stats: current.stats,
        rejectedId: event.contributionId,
      )),
    );
  }
}
