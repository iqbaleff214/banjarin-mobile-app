import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/paginated_result.dart';
import '../entities/contribution.dart';

abstract class ContributionRepository {
  Future<Either<Failure, Contribution>> submit({
    required ContributionType type,
    String? targetWordId,
    required Map<String, dynamic> payload,
  });

  Future<Either<Failure, PaginatedResult<Contribution>>> getContributions({
    ContributionStatus? status,
    ContributionType? type,
    int page = 1,
    int perPage = 20,
  });

  Future<Either<Failure, Contribution>> getContributionDetail({
    required String contributionId,
  });

  Future<Either<Failure, Contribution>> withdraw({
    required String contributionId,
  });
}
