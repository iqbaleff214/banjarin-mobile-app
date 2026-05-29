import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/ai_request.dart';
import '../repositories/admin_repository.dart';

class GetAIRequestDetailParams {
  final String requestId;
  const GetAIRequestDetailParams({required this.requestId});
}

class GetAIRequestDetail
    implements UseCase<AIRequest, GetAIRequestDetailParams> {
  final AdminRepository _repository;
  GetAIRequestDetail(this._repository);

  @override
  Future<Either<Failure, AIRequest>> call(GetAIRequestDetailParams params) =>
      _repository.getAIRequestDetail(requestId: params.requestId);
}
