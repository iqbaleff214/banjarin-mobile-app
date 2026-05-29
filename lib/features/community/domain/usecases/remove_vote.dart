import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/vote.dart';
import '../repositories/vote_repository.dart';

class RemoveVoteParams {
  final String targetId;
  final VoteTargetType targetType;
  final bool isAuthenticated;

  const RemoveVoteParams({
    required this.targetId,
    required this.targetType,
    required this.isAuthenticated,
  });
}

class RemoveVote implements UseCase<void, RemoveVoteParams> {
  final VoteRepository _repository;

  RemoveVote(this._repository);

  @override
  Future<Either<Failure, void>> call(RemoveVoteParams params) async {
    if (!params.isAuthenticated) {
      return const Left(UnauthorizedFailure());
    }
    return _repository.removeVote(
      targetId: params.targetId,
      targetType: params.targetType,
    );
  }
}
