import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/ai_request.dart';
import '../repositories/admin_repository.dart';

class RejectAIRequestParams {
  final String requestId;
  const RejectAIRequestParams({required this.requestId});
}

class RejectAIRequest implements UseCase<AIRequest, RejectAIRequestParams> {
  final AdminRepository _repository;
  RejectAIRequest(this._repository);

  @override
  Future<Either<Failure, AIRequest>> call(RejectAIRequestParams params) =>
      _repository.rejectAIRequest(requestId: params.requestId);
}
