import 'package:equatable/equatable.dart';

import '../../domain/entities/vote.dart';

sealed class VoteEvent extends Equatable {
  const VoteEvent();
}

final class InitVote extends VoteEvent {
  final VoteValue? currentVote;
  final int upvotes;
  final int downvotes;

  const InitVote({this.currentVote, required this.upvotes, required this.downvotes});

  @override
  List<Object?> get props => [currentVote, upvotes, downvotes];
}

final class CastVoteEvent extends VoteEvent {
  final String targetId;
  final VoteTargetType targetType;
  final VoteValue value;
  final bool isAuthenticated;

  const CastVoteEvent({
    required this.targetId,
    required this.targetType,
    required this.value,
    required this.isAuthenticated,
  });

  @override
  List<Object?> get props => [targetId, targetType, value, isAuthenticated];
}
