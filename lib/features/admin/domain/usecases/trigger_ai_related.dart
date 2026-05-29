import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/ai_request.dart';
import '../repositories/admin_repository.dart';

class TriggerAIRelatedParams {
  final String wordId;
  const TriggerAIRelatedParams({required this.wordId});
}

class TriggerAIRelated implements UseCase<AIRequest, TriggerAIRelatedParams> {
  final AdminRepository _repository;
  TriggerAIRelated(this._repository);

  @override
  Future<Either<Failure, AIRequest>> call(TriggerAIRelatedParams params) =>
      _repository.triggerRelated(wordId: params.wordId);
}
