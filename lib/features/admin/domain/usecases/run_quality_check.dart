import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/ai_request.dart';
import '../repositories/admin_repository.dart';

class RunQualityCheckParams {
  final String contributionId;
  const RunQualityCheckParams({required this.contributionId});
}

class RunQualityCheck implements UseCase<AIRequest, RunQualityCheckParams> {
  final AdminRepository _repository;
  RunQualityCheck(this._repository);

  @override
  Future<Either<Failure, AIRequest>> call(RunQualityCheckParams params) =>
      _repository.runQualityCheck(contributionId: params.contributionId);
}
