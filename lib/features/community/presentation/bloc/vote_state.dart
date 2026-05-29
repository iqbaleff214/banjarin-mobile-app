import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/vote.dart';

sealed class VoteState extends Equatable {
  const VoteState();
}

final class VoteInitial extends VoteState {
  final int upvotes;
  final int downvotes;

  const VoteInitial({this.upvotes = 0, this.downvotes = 0});

  @override
  List<Object?> get props => [upvotes, downvotes];
}

final class Voting extends VoteState {
  final VoteValue? currentVote;
  final int upvotes;
  final int downvotes;

  const Voting({this.currentVote, required this.upvotes, required this.downvotes});

  @override
  List<Object?> get props => [currentVote, upvotes, downvotes];
}

final class VoteUpdated extends VoteState {
  final VoteValue? currentVote;
  final int upvotes;
  final int downvotes;

  const VoteUpdated({this.currentVote, required this.upvotes, required this.downvotes});

  @override
  List<Object?> get props => [currentVote, upvotes, downvotes];
}

final class VoteError extends VoteState {
  final Failure failure;
  final VoteValue? currentVote;
  final int upvotes;
  final int downvotes;

  const VoteError({
    required this.failure,
    this.currentVote,
    required this.upvotes,
    required this.downvotes,
  });

  @override
  List<Object?> get props => [failure, currentVote, upvotes, downvotes];
}
