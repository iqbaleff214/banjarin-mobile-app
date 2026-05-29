import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/ai_request.dart';
import '../repositories/admin_repository.dart';

class TriggerAIEnrichParams {
  final String wordId;
  const TriggerAIEnrichParams({required this.wordId});
}

class TriggerAIEnrich implements UseCase<AIRequest, TriggerAIEnrichParams> {
  final AdminRepository _repository;
  TriggerAIEnrich(this._repository);

  @override
  Future<Either<Failure, AIRequest>> call(TriggerAIEnrichParams params) =>
      _repository.triggerEnrich(wordId: params.wordId);
}
