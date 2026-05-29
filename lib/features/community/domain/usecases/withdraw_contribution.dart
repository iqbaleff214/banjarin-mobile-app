import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/contribution.dart';
import '../repositories/contribution_repository.dart';

class WithdrawContributionParams {
  final String contributionId;
  final ContributionStatus currentStatus;

  const WithdrawContributionParams({
    required this.contributionId,
    required this.currentStatus,
  });
}

class WithdrawContribution
    implements UseCase<Contribution, WithdrawContributionParams> {
  final ContributionRepository _repository;

  WithdrawContribution(this._repository);

  @override
  Future<Either<Failure, Contribution>> call(
    WithdrawContributionParams params,
  ) async {
    if (params.currentStatus != ContributionStatus.pending) {
      return const Left(ConflictFailure(
        'Hanya kontribusi yang menunggu dapat dicabut.',
      ));
    }
    return _repository.withdraw(contributionId: params.contributionId);
  }
}
