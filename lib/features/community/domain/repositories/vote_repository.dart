import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/vote.dart';

abstract class VoteRepository {
  Future<Either<Failure, Vote>> castVote({
    required String targetId,
    required VoteTargetType targetType,
    required VoteValue value,
  });

  Future<Either<Failure, void>> removeVote({
    required String targetId,
    required VoteTargetType targetType,
  });
}
