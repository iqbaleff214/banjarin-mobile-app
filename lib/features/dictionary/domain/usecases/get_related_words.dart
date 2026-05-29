import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/word_summary.dart';
import '../repositories/word_repository.dart';

class GetRelatedWords implements UseCase<List<WordSummary>, WordIdParams> {
  final WordRepository _repository;

  GetRelatedWords(this._repository);

  @override
  Future<Either<Failure, List<WordSummary>>> call(WordIdParams params) {
    return _repository.getRelatedWords(params);
  }
}
