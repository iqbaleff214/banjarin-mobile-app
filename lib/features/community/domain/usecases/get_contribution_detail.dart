import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/contribution.dart';
import '../repositories/contribution_repository.dart';

class GetContributionDetailParams {
  final String contributionId;

  const GetContributionDetailParams({required this.contributionId});
}

class GetContributionDetail
    implements UseCase<Contribution, GetContributionDetailParams> {
  final ContributionRepository _repository;

  GetContributionDetail(this._repository);

  @override
  Future<Either<Failure, Contribution>> call(
    GetContributionDetailParams params,
  ) {
    return _repository.getContributionDetail(
      contributionId: params.contributionId,
    );
  }
}
