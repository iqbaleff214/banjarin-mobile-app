import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/vote.dart';
import '../repositories/vote_repository.dart';

class CastVoteParams {
  final String targetId;
  final VoteTargetType targetType;
  final VoteValue value;
  final bool isAuthenticated;

  const CastVoteParams({
    required this.targetId,
    required this.targetType,
    required this.value,
    required this.isAuthenticated,
  });
}

class CastVote implements UseCase<Vote, CastVoteParams> {
  final VoteRepository _repository;

  CastVote(this._repository);

  @override
  Future<Either<Failure, Vote>> call(CastVoteParams params) async {
    if (!params.isAuthenticated) {
      return const Left(UnauthorizedFailure());
    }
    return _repository.castVote(
      targetId: params.targetId,
      targetType: params.targetType,
      value: params.value,
    );
  }
}
