import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/vote.dart';
import '../../domain/usecases/cast_vote.dart';
import '../../domain/usecases/remove_vote.dart';
import 'vote_event.dart';
import 'vote_state.dart';

class VoteBloc extends Bloc<VoteEvent, VoteState> {
  final CastVote _castVote;
  final RemoveVote _removeVote;

  VoteBloc({required CastVote castVote, required RemoveVote removeVote})
      : _castVote = castVote,
        _removeVote = removeVote,
        super(const VoteInitial()) {
    on<InitVote>(_onInit);
    on<CastVoteEvent>(_onCastVote);
  }

  void _onInit(InitVote event, Emitter<VoteState> emit) {
    emit(VoteUpdated(
      currentVote: event.currentVote,
      upvotes: event.upvotes,
      downvotes: event.downvotes,
    ));
  }

  Future<void> _onCastVote(
    CastVoteEvent event,
    Emitter<VoteState> emit,
  ) async {
    // Get current counts from previous state
    final (prevVote, prevUp, prevDown) = _currentCounts(state);

    if (!event.isAuthenticated) {
      emit(VoteError(
        failure: const UnauthorizedFailure('Masuk untuk memberikan suara.'),
        currentVote: prevVote,
        upvotes: prevUp,
        downvotes: prevDown,
      ));
      return;
    }

    // Toggle: same value = remove vote
    final isSameVote = prevVote == event.value;

    if (isSameVote) {
      // Optimistic: remove vote
      final (optUp, optDown) = _optimisticRemove(prevVote, prevUp, prevDown);
      emit(Voting(currentVote: null, upvotes: optUp, downvotes: optDown));

      final result = await _removeVote(RemoveVoteParams(
        targetId: event.targetId,
        targetType: event.targetType,
        isAuthenticated: event.isAuthenticated,
      ));

      result.fold(
        (failure) => emit(VoteError(
          failure: failure,
          currentVote: prevVote,
          upvotes: prevUp,
          downvotes: prevDown,
        )),
        (_) => emit(VoteUpdated(
          currentVote: null,
          upvotes: optUp,
          downvotes: optDown,
        )),
      );
    } else {
      // Optimistic: cast new vote
      final (optUp, optDown) = _optimisticCast(
        prevVote,
        event.value,
        prevUp,
        prevDown,
      );
      emit(Voting(currentVote: event.value, upvotes: optUp, downvotes: optDown));

      final result = await _castVote(CastVoteParams(
        targetId: event.targetId,
        targetType: event.targetType,
        value: event.value,
        isAuthenticated: event.isAuthenticated,
      ));

      result.fold(
        (failure) => emit(VoteError(
          failure: failure,
          currentVote: prevVote,
          upvotes: prevUp,
          downvotes: prevDown,
        )),
        (_) => emit(VoteUpdated(
          currentVote: event.value,
          upvotes: optUp,
          downvotes: optDown,
        )),
      );
    }
  }

  (VoteValue?, int, int) _currentCounts(VoteState s) {
    return switch (s) {
      VoteInitial(:final upvotes, :final downvotes) => (null, upvotes, downvotes),
      VoteUpdated(:final currentVote, :final upvotes, :final downvotes) =>
        (currentVote, upvotes, downvotes),
      Voting(:final currentVote, :final upvotes, :final downvotes) =>
        (currentVote, upvotes, downvotes),
      VoteError(:final currentVote, :final upvotes, :final downvotes) =>
        (currentVote, upvotes, downvotes),
    };
  }

  (int, int) _optimisticRemove(VoteValue? prev, int up, int down) {
    if (prev == VoteValue.up) return (up - 1, down);
    if (prev == VoteValue.down) return (up, down - 1);
    return (up, down);
  }

  (int, int) _optimisticCast(
    VoteValue? prev,
    VoteValue newVal,
    int up,
    int down,
  ) {
    // First undo previous vote
    var (u, d) = _optimisticRemove(prev, up, down);
    // Then add new vote
    if (newVal == VoteValue.up) return (u + 1, d);
    return (u, d + 1);
  }
}

