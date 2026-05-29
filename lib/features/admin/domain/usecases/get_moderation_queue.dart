import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/paginated_result.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../community/domain/entities/contribution.dart';
import '../repositories/admin_repository.dart';

class GetModerationQueue
    implements
        UseCase<PaginatedResult<Contribution>, GetModerationQueueParams> {
  final AdminRepository _repository;
  GetModerationQueue(this._repository);

  @override
  Future<Either<Failure, PaginatedResult<Contribution>>> call(
    GetModerationQueueParams params,
  ) =>
      _repository.getModerationQueue(params);
}
