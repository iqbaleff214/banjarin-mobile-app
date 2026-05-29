import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/paginated_result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/word_summary.dart';
import '../repositories/word_repository.dart';

class SearchWords implements UseCase<PaginatedResult<WordSummary>, SearchParams> {
  final WordRepository _repository;

  SearchWords(this._repository);

  @override
  Future<Either<Failure, PaginatedResult<WordSummary>>> call(
    SearchParams params,
  ) async {
    if (params.query.trim().isEmpty) {
      return Left(ValidationFailure(
        fieldErrors: {'q': ['Query tidak boleh kosong.']},
      ));
    }
    return _repository.searchWords(params);
  }
}
