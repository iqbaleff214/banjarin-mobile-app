import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../community/domain/entities/contribution.dart';
import '../repositories/admin_repository.dart';

class ApproveContributionParams {
  final String contributionId;
  final String? note;

  const ApproveContributionParams({
    required this.contributionId,
    this.note,
  });
}

class ApproveContribution
    implements UseCase<Contribution, ApproveContributionParams> {
  final AdminRepository _repository;
  ApproveContribution(this._repository);

  @override
  Future<Either<Failure, Contribution>> call(
    ApproveContributionParams params,
  ) =>
      _repository.approveContribution(
        contributionId: params.contributionId,
        note: params.note,
      );
}
