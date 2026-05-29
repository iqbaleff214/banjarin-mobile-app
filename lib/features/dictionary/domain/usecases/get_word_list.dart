import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/paginated_result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/word_summary.dart';
import '../repositories/word_repository.dart';

class GetWordList implements UseCase<PaginatedResult<WordSummary>, WordListParams> {
  final WordRepository _repository;

  GetWordList(this._repository);

  @override
  Future<Either<Failure, PaginatedResult<WordSummary>>> call(
    WordListParams params,
  ) {
    return _repository.getWordList(params);
  }
}
