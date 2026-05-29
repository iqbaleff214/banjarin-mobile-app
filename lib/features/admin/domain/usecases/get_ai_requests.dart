import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/paginated_result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/ai_request.dart';
import '../repositories/admin_repository.dart';

class GetAIRequests
    implements UseCase<PaginatedResult<AIRequest>, GetAIRequestsParams> {
  final AdminRepository _repository;
  GetAIRequests(this._repository);

  @override
  Future<Either<Failure, PaginatedResult<AIRequest>>> call(
    GetAIRequestsParams params,
  ) =>
      _repository.getAIRequests(params);
}
