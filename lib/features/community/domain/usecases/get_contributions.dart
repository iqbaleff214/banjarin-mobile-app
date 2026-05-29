import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/paginated_result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/contribution.dart';
import '../repositories/contribution_repository.dart';

class GetContributionsParams {
  final ContributionStatus? status;
  final ContributionType? type;
  final int page;
  final int perPage;

  const GetContributionsParams({
    this.status,
    this.type,
    this.page = 1,
    this.perPage = 20,
  });
}

class GetContributions
    implements UseCase<PaginatedResult<Contribution>, GetContributionsParams> {
  final ContributionRepository _repository;

  GetContributions(this._repository);

  @override
  Future<Either<Failure, PaginatedResult<Contribution>>> call(
    GetContributionsParams params,
  ) {
    return _repository.getContributions(
      status: params.status,
      type: params.type,
      page: params.page,
      perPage: params.perPage,
    );
  }
}
