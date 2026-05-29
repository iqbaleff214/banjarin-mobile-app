import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/ai_request.dart';
import '../repositories/admin_repository.dart';

class TriggerAIExampleParams {
  final String wordId;
  const TriggerAIExampleParams({required this.wordId});
}

class TriggerAIExample implements UseCase<AIRequest, TriggerAIExampleParams> {
  final AdminRepository _repository;
  TriggerAIExample(this._repository);

  @override
  Future<Either<Failure, AIRequest>> call(TriggerAIExampleParams params) =>
      _repository.triggerExample(wordId: params.wordId);
}
